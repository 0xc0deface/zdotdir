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
	current_version=$($BIN_DIR/$1 --version 2>/dev/null | grep -E "[0-9]+\.[0-9]+\.[0-9]+" | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || echo "none")
	latest_version=$(wget -qO- $2/latest | grep -Eo --color "/v[0-9]+\.[0-9]+\.[0-9]+" | sed -E "s/\/v(.*)/\1/" | head -n 1)

	if [ "$current_version" != "$latest_version" ]; then
		echo "Updating $1: current version ($current_version), latest version ($latest_version)"
		download_file=$(echo $latest_version | sed -E "s/(.*)/$3/")
		source=$2/download/v$latest_version/$download_file
		echo $source
		wget -qO- $source | tar xvzfO - > $BIN_DIR/$1
		chmod +x $BIN_DIR/$1
		echo "$1 updated to version $latest_version"
	else
		echo "$1 is already up-to-date (version $current_version)"
	fi
}

# install fzf
update_from_github fzf https://github.com/junegunn/fzf/releases 'fzf-\1-linux_amd64.tar.gz'

#install eza
update_from_github eza https://github.com/eza-community/eza/releases eza_x86_64-unknown-linux-gnu.tar.gz

# install ohmyposh
curl -s https://ohmyposh.dev/install.sh | bash -s

# Install nerd-fonts via oh-my-posh (still needs to be configured to be used by system/terminal)
oh-my-posh font install meslo

# install pyenv
curl -fsSL https://pyenv.run | bash
