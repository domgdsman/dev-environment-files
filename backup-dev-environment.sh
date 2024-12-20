# Windows username
win_username=$(powershell.exe -Command '[System.Environment]::UserName' | tr -d '\r')

# Define source files
files=(
    "$HOME/.profile"
    "$HOME/.zprofile"
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.tmux-wsl2.conf"
    "$HOME/.wezterm.lua"
    "/mnt/c/Users/$win_username/.wezterm.lua"
    "$HOME/backup-dev-environment.sh"
    "$HOME/.config/nvim"
)

# Define destination directory
dest_dir="$HOME/dev-environment-files"

# Copy files to destination
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$dest_dir"
    elif [ -d "$file" ]; then
        cp -r "$file" "$dest_dir"
    else
        echo "Warning: $file does not exist."
    fi
done

# Navigate to destination directory
cd "$dest_dir" || exit 1

# Add files to git
git add .

# Check for changes
if git diff-index --quiet HEAD --; then
    echo "No changes to backup. Exiting."
    exit 0
fi

# Commit changes with current date
commit_message="backup: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_message"

# Push changes to remote repository
if git push; then
    echo "Dev environment successfully backed up to git."
    exit 0
else
    echo "Failed to push changes to git."
    exit 1
fi

