# Shared environment for the ccstatusline widget scripts. Sourced (not executed)
# by each widget via `. "${0%/*}/lib.sh"`.
# PATH: the widgets run outside a login shell, so locate jq/git explicitly.
export PATH="/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Tokyo Night palette as printf %b escapes, used by cwd-path.sh. (context-bar.sh and model-color.sh
# render entirely inside jq and keep their colors there as literal escapes.)
orange='\033[38;2;255;158;100m'
cyan='\033[38;2;125;207;255m'
muted='\033[38;2;86;95;137m'
fg_dark='\033[38;2;169;177;214m'
reset='\033[0m'
