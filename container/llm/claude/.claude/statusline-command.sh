#!/bin/sh
# Status line: model (effort) | context % | 5h % | 7d %
cat | jq -r '
  def pct(l; v): if v != null then l + ":" + (v | floor | tostring) + "%" else empty end;
  [
    ((.model.display_name // "") + (if .effort.level then " (" + .effort.level + ")" else "" end)),
    pct("ctx"; .context_window.used_percentage),
    pct("5h"; .rate_limits.five_hour.used_percentage),
    pct("7d"; .rate_limits.seven_day.used_percentage)
  ] | map(select(. != "")) | join(" | ")
'
