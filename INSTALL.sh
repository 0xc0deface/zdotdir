touch ~/.zshenv
grep -qxF '"ZDOTDIR=$HOME/zdotdir"' ~/.zshenv || echo 'ZDOTDIR="$HOME/zdotdir"\n. $ZDOTDIR/.zshenv' >> ~/.zshenv

fzf_source=https://github.com/junegunn/fzf/releases/download/v0.60.3/fzf-0.60.3-linux_amd64.tar.gz
wget -qO- $fzf_source | tar xvzfO - > ~/bin/fzf
chmod +x ~/bin/fzf

eza_source=https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz
wget -qO- $eza_source | tar xvzfO - > ~/bin/eza
chmod +x ~/bin/eza

curl -s https://ohmyposh.dev/install.sh | bash -s

oh-my-posh font install meslo