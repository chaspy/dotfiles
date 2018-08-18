# completion
autoload -Uz compinit
compinit

# fill selected parts
zstyle ':completion:*' menu select

# fix command typo
setopt correct

# don't leave duplicate command in history
setopt HIST_IGNORE_DUPS

# alias
alias gcd='ghq look $(ghq list | peco)'
alias gop='hub browse $(ghq list | peco)'
alias hubr='hub browse'

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# secret
source ~/.sshgate #secret
source ~/.githubtoken #secret

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
