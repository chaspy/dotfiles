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

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# open pr
open-release-pr () {
  local branches=$(
      git for-each-ref --format='%(refname)' --sort=-committerdate refs/heads refs/remotes |
      perl -pne 's{^refs/(heads|remotes)/}{}' |
      grep '^origin/release/' |
      sed 's|origin/||' |
      peco
  )
  test -z "$branches" && return 0
  for branch in $(echo $branches)
  do
    title="Release ${branch#release/}"
    hub browse -- "compare/${branch}...master?expand=1&title=${title}&body=To release "
  done
}

# for server-template
svtp_ssh () {
  cp ssh.config.template ssh.config
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  cp -f ./script/ansible.cfg.test ./ansible.cfg
}

# change aws default credential
awsc () {
  export AWS_DEFAULT_PROFILE=$(grep -oE "(\[).+(\])" ~/.aws/credentials | tr -d "[]" | peco)
}
