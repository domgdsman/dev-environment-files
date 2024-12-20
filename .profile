echo "Started login shell. Sourcing ~/.profile"

# load homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
