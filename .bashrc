alias g='git'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
. "$HOME/.cargo/env"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
