function say(message) {
  print message | "cat >&2"
}

function fence_marker(line, ch) {
  ch = substr(line, 1, 1)
  if (ch != "`" && ch != "~") {
    return ""
  }
  if (substr(line, 2, 1) != ch || substr(line, 3, 1) != ch) {
    return ""
  }
  return ch
}

function fence_length(line, ch, len) {
  len = 0
  while (substr(line, len + 1, 1) == ch) {
    len++
  }
  return len
}

function closes_fence(line, ch, min_length, len, rest) {
  len = fence_length(line, ch)
  if (len < min_length) {
    return 0
  }
  rest = substr(line, len + 1)
  return rest ~ /^[	 ]*$/
}

function fence_info(line, ch, len) {
  return substr(line, len + 1)
}

function has_token_info(info) {
  return info == token || index(info, token " ") == 1 || index(info, token "\t") == 1
}

function is_token_info(info) {
  sub(/^[	 ]*/, "", info)
  sub(/[	 ]*$/, "", info)
  return has_token_info(info)
}

BEGIN {
  if (token == "") {
    say("missing required awk variable: token")
    fatal = 1
    exit 1
  }
  fatal = 0
  state = "text"
  count = 0
  bad = 0
  token_marker = ""
  token_length = 0
  other_marker = ""
  other_length = 0
}

state == "text" {
  marker = fence_marker($0)
  if (marker != "") {
    fence_len = fence_length($0, marker)
    if (is_token_info(fence_info($0, marker, fence_len))) {
      state = "token"
      count++
      token_marker = marker
      token_length = fence_len
      if (count > 1) {
        print ""
      }
      next
    }
    state = "other"
    other_marker = marker
    other_length = fence_len
    next
  }
}

state == "token" {
  marker = fence_marker($0)
  if (marker != "" && is_token_info(fence_info($0, marker, fence_length($0, marker)))) {
    say(FILENAME ":" FNR ": nested " token " fence")
    bad = 1
    next
  }
}

state == "token" && closes_fence($0, token_marker, token_length) {
  state = "text"
  token_marker = ""
  token_length = 0
  next
}

state == "token" {
  print
  next
}

state == "other" && closes_fence($0, other_marker, other_length) {
  state = "text"
  other_marker = ""
  other_length = 0
  next
}

END {
  if (fatal) {
    exit 1
  }
  if (state == "token") {
    say(FILENAME ":" FNR ": unterminated " token " fence")
    bad = 1
  }
  if (count == 0) {
    say(FILENAME ": no " token " fences found")
    bad = 1
  }
  exit bad
}
