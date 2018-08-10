alias la='ls -la'
alias tree='tree -N'

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# set color
export CLICOLOR=1 
export LSCOLORS=gxfxcxdxbxegedabagacad

alias gcd='cd $(ghq root)/$(ghq list | peco)'
alias gop='hub browse $(ghq list | peco)'
alias hubr='hub browse'

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

svtp_ssh () {
  cp ssh.config.template ssh.config
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  cp -f ./script/ansible.cfg.test ./ansible.cfg
}

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

awsc () {
  export AWS_DEFAULT_PROFILE=$(grep -oE "(\[).+(\])" ~/.aws/credentials | tr -d [] | peco)
}

source ~/.sshgate #secret
