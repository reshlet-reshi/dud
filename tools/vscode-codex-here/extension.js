"use strict";

const vscode = require("vscode");
const childProcess = require("child_process");
const crypto = require("crypto");
const fs = require("fs");
const os = require("os");
const path = require("path");

const DEFAULT_PROMPT = [
  "Start by planning the work around the marked line.",
  "Inspect only the context needed to make the plan accurate.",
  "After presenting the plan, ask before making implementation edits.",
].join("\n");

const COMMENT_STYLES = {
  bat: { line: ["REM", "::"] },
  c: { line: ["//"], block: [["/*", "*/"]] },
  clojure: { line: [";"] },
  coffeescript: { line: ["#"] },
  cpp: { line: ["//"], block: [["/*", "*/"]] },
  csharp: { line: ["//"], block: [["/*", "*/"]] },
  css: { block: [["/*", "*/"]] },
  dockerfile: { line: ["#"] },
  elixir: { line: ["#"] },
  erlang: { line: ["%"] },
  go: { line: ["//"], block: [["/*", "*/"]] },
  groovy: { line: ["//"], block: [["/*", "*/"]] },
  hcl: { line: ["#", "//"], block: [["/*", "*/"]] },
  html: { block: [["<!--", "-->"]] },
  ini: { line: [";", "#"] },
  java: { line: ["//"], block: [["/*", "*/"]] },
  javascript: { line: ["//"], block: [["/*", "*/"]] },
  javascriptreact: { line: ["//"], block: [["/*", "*/"]] },
  jsonc: { line: ["//"], block: [["/*", "*/"]] },
  julia: { line: ["#"], block: [["#=", "=#"]] },
  kotlin: { line: ["//"], block: [["/*", "*/"]] },
  less: { line: ["//"], block: [["/*", "*/"]] },
  lua: { line: ["--"], block: [["--[[", "]]"]] },
  makefile: { line: ["#"] },
  markdown: { block: [["<!--", "-->"]] },
  mdx: { block: [["<!--", "-->"]] },
  "objective-c": { line: ["//"], block: [["/*", "*/"]] },
  "objective-cpp": { line: ["//"], block: [["/*", "*/"]] },
  perl: { line: ["#"] },
  php: { line: ["//", "#"], block: [["/*", "*/"]] },
  plaintext: { line: ["#"] },
  powershell: { line: ["#"], block: [["<#", "#>"]] },
  properties: { line: ["#", "!"] },
  python: { line: ["#"] },
  r: { line: ["#"] },
  ruby: { line: ["#"] },
  rust: { line: ["//"], block: [["/*", "*/"]] },
  sass: { line: ["//"] },
  scss: { line: ["//"], block: [["/*", "*/"]] },
  shellscript: { line: ["#"] },
  sql: { line: ["--"], block: [["/*", "*/"]] },
  svelte: { line: ["//"], block: [["<!--", "-->"], ["/*", "*/"]] },
  swift: { line: ["//"], block: [["/*", "*/"]] },
  terraform: { line: ["#", "//"], block: [["/*", "*/"]] },
  toml: { line: ["#"] },
  typescript: { line: ["//"], block: [["/*", "*/"]] },
  typescriptreact: { line: ["//"], block: [["/*", "*/"]] },
  vue: { line: ["//"], block: [["<!--", "-->"], ["/*", "*/"]] },
  xml: { block: [["<!--", "-->"]] },
  yaml: { line: ["#"] },
};

function activate(context) {
  const provider = new CodexHereCodeLensProvider();
  context.subscriptions.push(
    vscode.languages.registerCodeLensProvider([{ scheme: "file" }, { scheme: "untitled" }], provider),
    vscode.workspace.onDidChangeConfiguration((event) => {
      if (event.affectsConfiguration("codexHere")) {
        provider.refresh();
      }
    }),
    vscode.commands.registerCommand("codexHere.openAtMarker", openAtMarker)
  );
}

function deactivate() {}

class CodexHereCodeLensProvider {
  constructor() {
    this.emitter = new vscode.EventEmitter();
    this.onDidChangeCodeLenses = this.emitter.event;
  }

  refresh() {
    this.emitter.fire();
  }

  provideCodeLenses(document) {
    const marker = getConfig("marker", "`codex-here`");
    return findMarkers(document, marker).map((markerInfo) => {
      const range = new vscode.Range(markerInfo.line, 0, markerInfo.line, 0);
      return new vscode.CodeLens(range, {
        title: "Open Codex Here",
        command: "codexHere.openAtMarker",
        arguments: [{ uri: document.uri, line: markerInfo.line }],
      });
    });
  }
}

async function openAtMarker(target) {
  if (!target || !target.uri || typeof target.line !== "number") {
    vscode.window.showErrorMessage("Codex Here could not determine the target line.");
    return;
  }

  const document = await vscode.workspace.openTextDocument(target.uri);
  const workspaceFolder = vscode.workspace.getWorkspaceFolder(document.uri);
  const repoRoot = workspaceFolder
    ? workspaceFolder.uri.fsPath
    : vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? path.dirname(document.uri.fsPath);

  const settings = getSettings();
  const relativePath = path.relative(repoRoot, document.uri.fsPath) || path.basename(document.uri.fsPath);
  const promptPath = await writePromptFile({ document, line: target.line, repoRoot, relativePath, settings });
  const codexExecutable = resolveCodexExecutable(settings.codexExecutable);
  const windowName = makeTmuxWindowName(relativePath, target.line);

  try {
    ensureExecutable("tmux", "tmux is required for Codex Here. Install tmux, then try again.");
    ensureExecutable(settings.ghosttyExecutable, `Ghostty executable not found: ${settings.ghosttyExecutable}`);
    ensureTmuxSession(settings.tmuxSession, repoRoot);
    const windowId = createCodexTmuxWindow({
      sessionName: settings.tmuxSession,
      windowName,
      repoRoot,
      codexExecutable,
      extraCodexArgs: settings.extraCodexArgs,
      promptPath,
    });
    selectTmuxWindow(windowId);
    if (hasGhosttyClient(settings.tmuxSession)) {
      vscode.window.showInformationMessage(`Codex Here opened in tmux window ${windowName}.`);
    } else {
      launchGhostty(settings.ghosttyExecutable, settings.tmuxSession, repoRoot);
      vscode.window.showInformationMessage(`Codex Here opened a Ghostty window for tmux session ${settings.tmuxSession}.`);
    }
  } catch (error) {
    vscode.window.showErrorMessage(error instanceof Error ? error.message : String(error));
  }
}

function findMarkers(document, marker) {
  const styles = getCommentStyles(document.languageId);
  const hits = [];
  const lines = [];
  for (let index = 0; index < document.lineCount; index += 1) {
    lines.push(document.lineAt(index).text);
  }

  for (let index = 0; index < lines.length; index += 1) {
    if (lineCommentBody(lines[index], styles.line) === marker) {
      hits.push({ line: index });
      continue;
    }

    const blockMatch = blockCommentBody(lines, index, styles.block);
    if (blockMatch) {
      if (blockMatch.body === marker) {
        hits.push({ line: index });
      }
      index = blockMatch.endLine;
    }
  }

  return hits;
}

function getCommentStyles(languageId) {
  return COMMENT_STYLES[languageId] ?? { line: ["//", "#"], block: [["/*", "*/"], ["<!--", "-->"]] };
}

function lineCommentBody(line, prefixes = []) {
  const trimmed = line.trimStart();
  for (const prefix of prefixes) {
    if (prefix === "REM" && !trimmed.toUpperCase().startsWith(prefix)) {
      continue;
    }
    if (prefix !== "REM" && !trimmed.startsWith(prefix)) {
      continue;
    }
    if (prefix === "REM" && !/^REM(?:\s|$)/i.test(trimmed)) {
      continue;
    }
    return trimmed.slice(prefix.length).trim();
  }
  return null;
}

function blockCommentBody(lines, startLine, delimiters = []) {
  const firstTrimmed = lines[startLine].trimStart();
  for (const [open, close] of delimiters) {
    if (!firstTrimmed.startsWith(open)) {
      continue;
    }

    const bodyLines = [];
    const firstRemainder = firstTrimmed.slice(open.length);
    const sameLineCloseIndex = firstRemainder.indexOf(close);
    if (sameLineCloseIndex !== -1) {
      if (firstRemainder.slice(sameLineCloseIndex + close.length).trim() !== "") {
        return null;
      }
      bodyLines.push(firstRemainder.slice(0, sameLineCloseIndex));
      return { body: normalizeBlockBody(bodyLines), endLine: startLine };
    }

    bodyLines.push(firstRemainder);
    for (let lineIndex = startLine + 1; lineIndex < lines.length; lineIndex += 1) {
      const closeIndex = lines[lineIndex].indexOf(close);
      if (closeIndex === -1) {
        bodyLines.push(lines[lineIndex]);
        continue;
      }
      if (lines[lineIndex].slice(closeIndex + close.length).trim() !== "") {
        return null;
      }
      bodyLines.push(lines[lineIndex].slice(0, closeIndex));
      return { body: normalizeBlockBody(bodyLines), endLine: lineIndex };
    }
  }
  return null;
}

function normalizeBlockBody(bodyLines) {
  return bodyLines
    .map((line) => line.trim().replace(/^\*\s?/, ""))
    .join("\n")
    .trim();
}

async function writePromptFile({ document, line, repoRoot, relativePath, settings }) {
  const projectPrompt = await readProjectPrompt(repoRoot, settings.promptFile);
  const contextBlock = nearbyContext(document, line, settings.contextLines);
  const prompt = [
    "# Codex Here",
    "",
    "## Project Prompt",
    "",
    projectPrompt,
    "",
    "## Target",
    "",
    `- Repository root: ${repoRoot}`,
    `- File: ${relativePath}`,
    `- Line: ${line + 1}`,
    `- Language: ${document.languageId}`,
    `- Marker: ${settings.marker}`,
    "",
    "## Nearby Context",
    "",
    `Lines ${contextBlock.startLine + 1}-${contextBlock.endLine + 1}:`,
    "",
    "```text",
    contextBlock.text,
    "```",
    "",
    "## Task",
    "",
    "Focus on the marked line. Start in planning mode: inspect only what you need, produce a concise plan, and ask before implementing. Do not edit files until implementation is explicitly approved.",
  ].join("\n");

  const promptRoot = path.join(os.tmpdir(), "codex-here", "prompts");
  await fs.promises.mkdir(promptRoot, { recursive: true });
  const basename = `${Date.now()}-${crypto.randomBytes(6).toString("hex")}.md`;
  const promptPath = path.join(promptRoot, basename);
  await fs.promises.writeFile(promptPath, prompt, "utf8");
  return promptPath;
}

async function readProjectPrompt(repoRoot, promptFile) {
  const promptPath = path.resolve(repoRoot, promptFile);
  try {
    return await fs.promises.readFile(promptPath, "utf8");
  } catch (error) {
    if (error && error.code === "ENOENT") {
      vscode.window.showWarningMessage(`Codex Here prompt file not found: ${promptFile}. Using fallback prompt.`);
      return DEFAULT_PROMPT;
    }
    throw error;
  }
}

function nearbyContext(document, markerLine, contextLines) {
  const startLine = Math.max(0, markerLine - contextLines);
  const endLine = Math.min(document.lineCount - 1, markerLine + contextLines);
  const numbered = [];
  for (let line = startLine; line <= endLine; line += 1) {
    const prefix = String(line + 1).padStart(5, " ");
    const marker = line === markerLine ? ">" : " ";
    numbered.push(`${marker} ${prefix}: ${document.lineAt(line).text}`);
  }
  return { startLine, endLine, text: numbered.join("\n") };
}

function ensureExecutable(executable, message) {
  const result = childProcess.spawnSync(executable, ["--version"], { encoding: "utf8" });
  if (result.error && result.error.code === "ENOENT") {
    throw new Error(message);
  }
}

function ensureTmuxSession(sessionName, repoRoot) {
  const hasSession = childProcess.spawnSync("tmux", ["has-session", "-t", sessionName]);
  if (hasSession.status === 0) {
    return;
  }
  const createSession = childProcess.spawnSync("tmux", ["new-session", "-d", "-s", sessionName, "-n", "home", "-c", repoRoot], {
    encoding: "utf8",
  });
  if (createSession.status !== 0) {
    throw new Error(`Failed to create tmux session ${sessionName}: ${stderrOf(createSession)}`);
  }
}

function createCodexTmuxWindow({ sessionName, windowName, repoRoot, codexExecutable, extraCodexArgs, promptPath }) {
  const codexCommand = [
    shellQuote(codexExecutable),
    ...extraCodexArgs.map(shellQuote),
    "-C",
    shellQuote(repoRoot),
    '"$(cat "$CODEX_HERE_PROMPT")"',
  ].join(" ");
  const shellCommand = [
    `export CODEX_HERE_PROMPT=${shellQuote(promptPath)}`,
    codexCommand,
    "status=$?",
    "printf '\\n[Codex exited with status %s]\\n' \"$status\"",
    "exec bash -l",
  ].join("; ");

  const result = childProcess.spawnSync(
    "tmux",
    ["new-window", "-P", "-F", "#{window_id}", "-t", sessionName, "-n", windowName, "-c", repoRoot, `bash -lc ${shellQuote(shellCommand)}`],
    { encoding: "utf8" }
  );
  if (result.status !== 0) {
    throw new Error(`Failed to create Codex tmux window: ${stderrOf(result)}`);
  }
  return result.stdout.trim();
}

function selectTmuxWindow(windowId) {
  const result = childProcess.spawnSync("tmux", ["select-window", "-t", windowId], { encoding: "utf8" });
  if (result.status !== 0) {
    throw new Error(`Failed to select tmux window ${windowId}: ${stderrOf(result)}`);
  }
}

function hasGhosttyClient(sessionName) {
  const result = childProcess.spawnSync("tmux", ["list-clients", "-t", sessionName, "-F", "#{client_termname}"], {
    encoding: "utf8",
  });
  if (result.status !== 0) {
    return false;
  }
  return result.stdout
    .split(/\r?\n/)
    .map((line) => line.trim().toLowerCase())
    .some((line) => line.includes("ghostty"));
}

function launchGhostty(ghosttyExecutable, sessionName, repoRoot) {
  const child = childProcess.spawn(
    ghosttyExecutable,
    [
      "+new-window",
      "--class=codex-here",
      "--title=Codex Here",
      `--working-directory=${repoRoot}`,
      "-e",
      "tmux",
      "attach",
      "-t",
      sessionName,
    ],
    { detached: true, stdio: "ignore" }
  );
  child.unref();
}

function resolveCodexExecutable(override) {
  if (override && override.trim() !== "") {
    return override;
  }

  const configured = vscode.workspace.getConfiguration("chatgpt").get("cliExecutable");
  if (typeof configured === "string" && configured.trim() !== "") {
    return configured;
  }

  const extension = vscode.extensions.getExtension("openai.chatgpt");
  if (extension) {
    const bundled = path.join(extension.extensionPath, "bin", process.platform === "win32" ? "windows-x86_64" : "linux-x86_64", process.platform === "win32" ? "codex.exe" : "codex");
    if (fs.existsSync(bundled)) {
      return bundled;
    }
  }

  return "codex";
}

function getSettings() {
  return {
    marker: stringConfig("marker", "`codex-here`"),
    promptFile: stringConfig("promptFile", ".codex-here.md"),
    contextLines: numberConfig("contextLines", 40, 0, 500),
    tmuxSession: stringConfig("tmuxSession", "codex-here"),
    ghosttyExecutable: stringConfig("ghosttyExecutable", "ghostty"),
    codexExecutable: stringConfig("codexExecutable", ""),
    extraCodexArgs: getStringArrayConfig("extraCodexArgs"),
  };
}

function getConfig(key, fallback) {
  const value = vscode.workspace.getConfiguration("codexHere").get(key);
  return value === undefined || value === null ? fallback : value;
}

function stringConfig(key, fallback) {
  const value = getConfig(key, fallback);
  return typeof value === "string" && value.trim() !== "" ? value : fallback;
}

function numberConfig(key, fallback, min, max) {
  const value = getConfig(key, fallback);
  if (!Number.isFinite(value)) {
    return fallback;
  }
  return Math.max(min, Math.min(max, Math.floor(value)));
}

function getStringArrayConfig(key) {
  const value = vscode.workspace.getConfiguration("codexHere").get(key);
  return Array.isArray(value) ? value.filter((item) => typeof item === "string") : [];
}

function makeTmuxWindowName(relativePath, zeroBasedLine) {
  const baseName = path.basename(relativePath).replace(/[^A-Za-z0-9._-]/g, "-");
  return `codex:${baseName}:${zeroBasedLine + 1}`.slice(0, 80);
}

function shellQuote(value) {
  return `'${String(value).replace(/'/g, "'\\''")}'`;
}

function stderrOf(result) {
  return (result.stderr || result.error?.message || "unknown error").trim();
}

module.exports = {
  activate,
  deactivate,
  findMarkers,
  lineCommentBody,
  blockCommentBody,
  normalizeBlockBody,
  nearbyContext,
};
