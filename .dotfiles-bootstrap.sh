# Install tmux plugin manager
mkdir -p $HOME/.tmux/plugins/tpm &>/dev/null
git clone --depth 1 https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm &

# Install zsh plugin manager
mkdir -p $HOME/.local/bin &>/dev/null
curl -fsSL git.io/antigen > $HOME/.local/bin/antigen.zsh &

# Wait for plugin managers to install
wait

# Clone large dotfiles and those that require post install
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-tmux.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-x11.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-zsh.git &

# Wait for dotfiles cloning to finish
wait

# Cache zsh plugins
zsh -c "source $HOME/.zshrc" &

# Cache tmux plugins
zsh -c $HOME/.tmux/plugins/tpm/bin/install_plugins &

# Wait for zsh and tmux caching to finish
wait

# Clone static dotfiles
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-alacritty.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-alsa.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-autorandr.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-code.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-compton.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-crt.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-dnsmasq.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-dunst.git &
vcsh clone https://bonegames@github.com/bonegames/dotfiles-git.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-gtk.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-i3.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-jobber.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-mime.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-mpd.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-musikcube.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-ncmpcpp.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-pcmanfm.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-pulseaudio.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-ranger.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-scripts.git &
vcsh clone https://bonegames@github.com/bonegames/dotfiles-ssh.git &
vcsh clone https://sabrehagen@github.com/sabrehagen/dotfiles-xdg.git &

# Wait for dotfiles cloning to finish
wait

# Ignore wal-generated gtk files
vcsh dotfiles-gtk ls-files $HOME | \
  xargs -n 1 vcsh dotfiles-gtk update-index --assume-unchanged

# Start an x server for applications that require one to function (wal, code)
export DISPLAY=:2
vncserver $DISPLAY \
  -autokill \
  -SecurityTypes none \
  -xstartup /usr/bin/i3

# Install code settings sync extension, clear extension download history, start code so extensions install, forcibly terminate code after extensions install (race condition), generate wal cache
code --install-extension Shan.code-settings-sync && \
  sed -i '/lastDownload/d' $HOME/.config/Code/User/syncLocalSettings.json && \
  code && sleep 90 && pkill -f code && \
  code && sleep 5 && pkill -f code && \
  vcsh dotfiles-code reset HEAD ~ && \
  vcsh dotfiles-code co ~ && \
  git clone https://github.com/Bluedrack28/vscode-wal.git ~/.vscode/extensions/vscode-wal && \
  mkdir ~/.vscode/extensions/vscode-wal/themes && \
  cp ~/.vscode/extensions/vscode-wal/templates/colors-vscode-theme.json ~/.config/wal/templates && \
  ln -sf ~/.cache/wal/colors-vscode-theme.json ~/.vscode/extensions/vscode-wal/themes/vs-wal-color-theme.json && \
  ~/.config/scripts/wal.sh

# Terminate x server and wait for shutdown
kill -HUP $(pgrep Xtigervnc) && sleep 2
