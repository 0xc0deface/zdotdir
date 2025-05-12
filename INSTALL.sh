#!/bin/bash -e

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

# install ohmyposh
#curl -s https://ohmyposh.dev/install.sh | bash -s

# Install nerd-fonts via oh-my-posh (still needs to be configured to be used by system/terminal)
#oh-my-posh font install meslo

# install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
	curl -fsSL https://pyenv.run | bash
fi

#install fonts (still need to be set in terminal/system)
mkdir -p ~/.local/share/fonts
pushd ~/.local/share/fonts
curl -fL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o "MesloLGS NF Regular.ttf"
curl -fL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o "MesloLGS NF Bold.ttf"
curl -fL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -o "MesloLGS NF Italic.ttf"
curl -fL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -o "MesloLGS NF Bold Italic.ttf"
popd

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
link_if_not_exists "files/.backpack" "$HOME/.backpack"
link_if_not_exists "files/backpack" "$BIN_DIR/backpack"
link_if_not_exists "files/export_backpack" "$BIN_DIR/export_backpack"
