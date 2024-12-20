echo "Started login shell. Sourcing ~/.zprofile"

# load homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
