# The widgets run outside a login shell, so put jq and git on PATH explicitly.
export PATH="/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# printf %b escapes for cwd-path.sh. context-bar.sh and model-color.sh render
# inside jq and keep their colors there as literal escapes.
orange='\033[38;2;255;158;100m'
cyan='\033[38;2;125;207;255m'
muted='\033[38;2;86;95;137m'
fg_dark='\033[38;2;169;177;214m'
reset='\033[0m'
