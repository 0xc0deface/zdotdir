#!/bin/bash -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# use or create a bin directory
if [ -d "$HOME/bin" ]; then
	export BIN_DIR="$HOME/bin"
elif [ -d "$HOME/.local/bin" ]; then
	export BIN_DIR="$HOME/.local/bin"
else
	mkdir -p "$HOME/bin"
	export BIN_DIR="$HOME/bin"
fi

# make sure ~/.zshenv exists and make it point to this one.
touch ~/.zshenv
grep -qxF 'ZDOTDIR=$HOME/zdotdir' ~/.zshenv || cat >> ~/.zshenv<< 'EOF'
ZDOTDIR=$HOME/zdotdir
. $ZDOTDIR/.zshenv
EOF

# helper function to update from github
function update_from_github()
{
	# $1 = binary name
	# $2 = github repo releases url
	# $3 = download file name
	if [ -x "$BIN_DIR/$1" ]; then
		current_version=$($BIN_DIR/$1 --version 2>/dev/null | grep -E "[0-9]+\.[0-9]+\.[0-9]+" | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
	else
		current_version="none"
	fi

	v=$(wget -qO- $2/latest | grep -Eo --color "/v[0-9]+\.[0-9]+\.[0-9]+" | sed -E "s/\/(v)(.*)/\1/" | head -n 1)
	latest_version=$(wget -qO- $2/latest | grep -Eo --color "/v?[0-9]+\.[0-9]+\.[0-9]+" | sed -E "s/\/v?(.*)/\1/" | head -n 1)

	if [ "$current_version" != "$latest_version" ]; then
		echo "Updating $1: current version ($current_version), latest version ($latest_version)"
		download_file=$(echo $latest_version | sed -E "s/(.*)/$3/")
		
		if [[ -z $4 ]]; then
			extract_file=$1
		else
			extract_file=$(echo $latest_version | sed -E "s/(.*)/${4}/")
		fi

		source=$2/download/$v$latest_version/$download_file

		if [[ $download_file == *.tar.gz ]]; then
			# list what is in the directory
			wget -qO- $source | tar tvzf -
			wget -qO- $source | tar xvzfO - $extract_file > $BIN_DIR/$1
		elif [[ $download_file == *.tar.xz ]]; then
			# list what is in the directory
			wget -qO- $source | tar tvJf -
			wget -qO- $source | tar xvJfO - $extract_file > $BIN_DIR/$1
		elif [[ $download_file == *.xz ]]; then
			wget -qO- $source | xzdec > $BIN_DIR/$1
		elif [[ $download_file == *.gz ]]; then
			wget -qO- $source | gunzip -c > $BIN_DIR/$1
		else
			echo "Unsupported file format for $download_file"
			exit 1
		fi
		
		chmod +x $BIN_DIR/$1
		echo "$1 updated to version $latest_version"
	else
		echo "$1 is already up-to-date (version $current_version)"
	fi
}

if [ $(uname -m) == "x86_64" ]; then
	update_from_github fzf https://github.com/junegunn/fzf/releases 'fzf-\1-linux_amd64.tar.gz'
	update_from_github eza https://github.com/eza-community/eza/releases eza_x86_64-unknown-linux-gnu.tar.gz '.\/eza'
	update_from_github bat https://github.com/sharkdp/bat/releases 'bat-v\1-x86_64-unknown-linux-gnu.tar.gz' 'bat-v\1-x86_64-unknown-linux-gnu\/bat'
	update_from_github vivid https://github.com/sharkdp/vivid/releases 'vivid-v\1-x86_64-unknown-linux-gnu.tar.gz' 'vivid-v\1-x86_64-unknown-linux-gnu\/vivid'
	update_from_github glow https://github.com/charmbracelet/glow/releases 'glow_\1_Linux_x86_64.tar.gz' 'glow_\1_Linux_x86_64\/glow'
	update_from_github cheat https://github.com/cheat/cheat/releases 'cheat-linux-amd64.gz'
	#update_from_github chafa https://github.com/hpjansson/chafa/releases 'chafa-\1.tar.xz'
fi

if [ $(uname -m) == "aarch64" ]; then
	update_from_github fzf https://github.com/junegunn/fzf/releases 'fzf-\1-linux_arm64.tar.gz'
	update_from_github eza https://github.com/eza-community/eza/releases eza_aarch64-unknown-linux-gnu.tar.gz '.\/eza'
	update_from_github bat https://github.com/sharkdp/bat/releases "bat-v\1-aarch64-unknown-linux-gnu.tar.gz" 'bat-v\1-aarch64-unknown-linux-gnu\/bat'
	update_from_github vivid https://github.com/sharkdp/vivid/releases 'vivid-v\1-aarch64-unknown-linux-gnu.tar.gz' 'vivid-v\1-x86_64-unknown-linux-gnu\/vivid'
	update_from_github glow https://github.com/charmbracelet/glow/releases 'glow_\1_Linux_arm64.tar.gz' 'glow_\1_Linux_arm64\/glow'
fi

# install nerd fonts from github releases
function install_nerd_font()
{
	# $1 = font name (e.g., "Meslo")
	local font_name=$1
	local font_dir="$HOME/.local/share/fonts/NerdFonts"
	local releases_url="https://github.com/ryanoasis/nerd-fonts/releases"

	local latest_version=$(wget -qO- "$releases_url/latest" | grep -Eo '/v[0-9]+\.[0-9]+\.[0-9]+' | sed -E 's/\/v//' | head -n 1)

	if [ -z "$latest_version" ]; then
		echo "Failed to determine latest nerd-fonts version"
		return 1
	fi

	local version_file="$font_dir/.${font_name}_version"
	if [ -f "$version_file" ] && [ "$(cat "$version_file")" = "$latest_version" ]; then
		echo "Nerd Font '$font_name' is already up-to-date (version $latest_version)"
		return 0
	fi

	echo "Installing Nerd Font '$font_name' version $latest_version..."
	mkdir -p "$font_dir"
	wget -qO- "$releases_url/download/v${latest_version}/${font_name}.tar.xz" | tar xJf - -C "$font_dir"
	echo "$latest_version" > "$version_file"

	# refresh font cache
	if command -v fc-cache >/dev/null 2>&1; then
		fc-cache -f "$font_dir"
	fi

	echo "Nerd Font '$font_name' installed (version $latest_version)"
}

install_nerd_font Meslo

# install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
	curl -fsSL https://pyenv.run | bash
fi

# install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	echo "Installing TPM (Tmux Plugin Manager)..."
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	echo "TPM installed. Run 'tmux' then press Ctrl-Space + I to install plugins"
else
	echo "TPM already installed"
fi

# Check for clipboard tools (needed for tmux copy-paste)
# Note: On Wayland systems (KDE/GNOME), clipboard sync is handled automatically
# On remote X11 systems with SSH X11 forwarding, xsel is required
if command -v xsel >/dev/null 2>&1; then
	echo "xsel found: clipboard integration will work with X11 forwarding"
elif [ -n "$WAYLAND_DISPLAY" ]; then
	echo "Wayland detected: clipboard managed by desktop environment"
	echo "Note: For SSH X11 forwarding to work, install xsel on remote machines"
else
	echo "WARNING: xsel not found. Install it for tmux clipboard integration:"
	echo "  Debian/Ubuntu: sudo apt install xsel"
	echo "  Arch/Manjaro:  sudo pacman -S xsel"
	echo "  RHEL/Fedora:   sudo dnf install xsel"
fi

# note: nerd fonts are installed above via install_nerd_font
# the terminal/system still needs to be configured to use the font (e.g., "MesloLGM Nerd Font")

function link_if_not_exists()
{
	# $1 = source file
	# $2 = target file
	mkdir -p $(dirname $2)
	if [ ! -e "$2" ]; then
		ln -sf $(realpath "$1") "$2"
	else
		echo "$2 already exists, skipping symlink creation"
	fi
}

# link these files straight out of this repo so they all update on pull
link_if_not_exists "files/tmux.conf" "$HOME/.config/tmux/tmux.conf"
link_if_not_exists "files/MattsTilixTheme.json" "$HOME/.config/tilix/schemes/MattsTilixTheme.json"
link_if_not_exists "files/ghostty-config" "$HOME/.config/ghostty/config"
link_if_not_exists "files/ghostty-theme" "$HOME/.config/ghostty/themes/MattsTilixTheme"
link_if_not_exists "files/.backpack" "$HOME/.backpack"
link_if_not_exists "files/backpack" "$BIN_DIR/backpack"
link_if_not_exists "files/export_backpack" "$BIN_DIR/export_backpack"

echo ""
echo "========================================"
echo "Setup complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Start tmux (or restart if already running)"
echo "2. Press Ctrl-Space + I (capital I) to install tmux plugins"
echo "3. Wait for plugins to download (Dracula theme, fzf, etc.)"
echo ""
if [ -z "$WAYLAND_DISPLAY" ]; then
	echo "Note: For clipboard integration over SSH, ensure:"
	echo "  - xsel is installed on this machine"
	echo "  - SSH config has ForwardX11 yes"
	echo ""
fi
