if [ -d "$HOME/bin" ]; then
	export BIN_DIR="$HOME/bin"
elif [ -d "$HOME/.local/bin" ]; then
	export BIN_DIR="$HOME/.local/bin"
else
	mkdir -p "$HOME/bin"
	export BIN_DIR="$HOME/bin"
fi

touch ~/.zshenv
grep -qxF 'ZDOTDIR=$HOME/zdotdir' ~/.zshenv || echo 'ZDOTDIR=$HOME/zdotdir'\\n'$ZDOTDIR/.zshenv' >> ~/.zshenv

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

update_from_github fzf https://github.com/junegunn/fzf/releases 'fzf-\1-linux_amd64.tar.gz'
update_from_github eza https://github.com/eza-community/eza/releases eza_x86_64-unknown-linux-gnu.tar.gz

curl -s https://ohmyposh.dev/install.sh | bash -s

oh-my-posh font install meslo