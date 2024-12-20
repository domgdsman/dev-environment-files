#!/bin/bash

# Disclaimer
echo "This script will download and install several packages from the internet. Proceed? (y/n)"
read -r response
if [ "$response" != "y" ]; then
    echo "Exiting."
    exit 0
fi

# Windows username
win_username=$(powershell.exe -Command '[System.Environment]::UserName' | tr -d '\r')

# Update packages
echo "Updating packages..."
sudo apt update
sudo apt upgrade -y

# Locale
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales


# Install packages
echo "Installing packages..."
sudo apt install -y git curl wget unzip ripgrep


# python
sudo apt install -y python3 python3-pip python3-dev pipx
pipx install poetry


# rust
if [ -x "$(command -v rustc)" ]; then
    echo "Rust is already installed."
else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi


# nvm
if [ -x "$(command -v nvm)" ]; then
    echo "nvm is already installed."
else
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi


# node
if [ -x "$(command -v node)" ]; then
    echo "Node.js is already installed."
else
    echo "Installing Node.js..."
    nvm install node
fi


# zsh
if [ -x "$(command -v zsh)" ]; then
    echo "zsh is already installed."
else
    echo "Installing zsh..."
    sudo apt install zsh -y
fi


# oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is already installed."
else
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ -d "$ZSH_CUSTOM/plugins/example" ]; then
        rm -rf "$ZSH_CUSTOM/plugins/example"
    fi
fi

# zsh-autosuggestions
if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "zsh-autosuggestions is already installed."
else
    echo "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi


# zsh-syntax-highlighting
if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "zsh-syntax-highlighting is already installed."
else
    echo "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi


# powerlevel10k
if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    echo "powerlevel10k is already installed."
else
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi


# meslo nerd font
if [ -f "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf" ]; then
    echo "Meslo Nerd Font is already installed."
else
    echo "Installing Meslo Nerd Font..."
    mkdir -p "$HOME/.local/share/fonts"
    curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o "$HOME/.local/share/fonts/MesloLGS NF Regular.ttf"
    curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o "$HOME/.local/share/fonts/MesloLGS NF Bold.ttf"
    curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -o "$HOME/.local/share/fonts/MesloLGS NF Italic.ttf"
    curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -o "$HOME/.local/share/fonts/MesloLGS NF Bold Italic.ttf"
    fc-cache -f -v
fi


# tmux
if [ -x "$(command -v tmux)" ]; then
    echo "tmux is already installed."
else
    echo "Installing tmux..."
    sudo apt install tmux -y
fi

# neovim
if [ -x "$(command -v nvim)" ]; then
    echo "Neovim is already installed."
else
    echo "Installing Neovim..."
    curl -Lo /tmp/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf /tmp/nvim-linux64.tar.gz
fi

# win32yank
if [ -d "/mnt/c/Users/$win_username/AppData/Local/win32yank" ]; then
    echo "win32yank is already installed."
else
    echo "Installing win32yank..."
    curl -Lo /tmp/win32yank-x64.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    powershell.exe -Command 'New-Item -ItemType Directory -Path "$env:USERPROFILE\AppData\Local" -Name "win32yank"'
    unzip /tmp/win32yank-x64.zip -d "/mnt/c/Users/$win_username/AppData/Local/win32yank"
fi
powershell.exe -Command '$path=[Environment]::GetEnvironmentVariable("Path", "User"); if (-not $path.Contains("$env:USERPROFILE\AppData\Local\win32yank")) { [Environment]::SetEnvironmentVariable("Path", $path + ";$env:USERPROFILE\AppData\Local\win32yank", "User") }'


# cleanup
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean -y


# Prompt to override config files
echo "Do you want to overwrite existing config files? (y/n)"
read -r response
if [ "$response" != "y" ]; then
    echo "Exiting."
    exit 0
fi


# Override config files
echo "Overwriting config files..."

backup_suffix=$(date +%Y%m%d%H%M%S)

if [ -f "/mnt/c/Users/$win_username/.wezterm.lua" ]; then
    echo "Backing up existing WezTerm config..."
    cp "/mnt/c/Users/$win_username/.wezterm.lua" "/mnt/c/Users/$win_username/.wezterm.lua.backup.$backup_suffix"
fi
echo "Overwriting WezTerm config..."
cp .wezterm.lua "/mnt/c/Users/$win_username/.wezterm.lua"

if [ -f "$HOME/.profile" ]; then
    echo "Backing up existing .profile..."
    cp "$HOME/.profile" "$HOME/.profile.backup.$backup_suffix"
fi
echo "Overwriting .profile..."
cp .profile "$HOME/.profile"

if [ -f "$HOME/.zprofile" ]; then
    echo "Backing up existing .zprofile..."
    cp "$HOME/.zprofile" "$HOME/.zprofile.backup.$backup_suffix"
fi
echo "Overwriting .zprofile..."
cp .zprofile "$HOME/.zprofile"

if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$backup_suffix"
fi
echo "Overwriting .zshrc..."
cp .zshrc "$HOME/.zshrc"

if [ -f "$HOME/.tmux.conf" ]; then
    echo "Backing up existing .tmux.conf..."
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$backup_suffix"
fi
echo "Overwriting .tmux.conf..."
cp .tmux.conf "$HOME/.tmux.conf"

if [ -f "$HOME/.tmux-wsl2.conf" ]; then
    echo "Backing up existing .tmux-wsl2.conf..."
    cp "$HOME/.tmux-wsl2.conf" "$HOME/.tmux-wsl2.conf.backup.$backup_suffix"
fi
echo "Overwriting .tmux-wsl2.conf..."
cp .tmux-wsl2.conf "$HOME/.tmux-wsl2.conf"

if [ -f "$HOME/backup-dev-environment.sh" ]; then
    echo "Backing up existing backup-dev-environment.sh..."
    cp "$HOME/backup-dev-environment.sh" "$HOME/backup-dev-environment.sh.backup.$backup_suffix"
fi
cp backup-dev-environment.sh "$HOME/backup-dev-environment.sh"


# Setup nvim (never overwrite)
if [ -d "$HOME/.config/nvim" ]; then
    echo "Neovim config folder already exists at $HOME/.config/nvim. Skipping."
else
    echo "Setting up Neovim..."
    mkdir -p "$HOME/.config/nvim"
    cp -r nvim/* "$HOME/.config/nvim"
fi


# Secrets
echo "Creating secrets file..."
touch "$HOME/.secrets.env"

# Done
echo "Please install the Meslo Nerd Font in Windows by downloading and double-clicking the font files from here:"
echo "https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#manual-font-installation"
echo "Then open zsh and run: $ source ~/.zshrc"
echo "Done."
