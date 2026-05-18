# Tools

Generic repository helper tooling lives under `tools/`.

Tooling here should not contain policy-specific rule logic unless a future
reviewed plan says otherwise.

`tools/run-policy.py` runs marked executable sections from policy runbooks.

Use self-test mode with a policy runbook:

```sh
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
```

Use scan mode with a target file and output path:

```sh
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file PATH --output PATH
```

The runner validates runbook plumbing.

Policy-specific rule logic stays in the policy runbook.

During checkpoint 04, `policy/punctuation-policy.md` has no runnable section.

The runner should report that as a contract error until checkpoint 05.
