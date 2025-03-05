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
source ~/.githubtoken #secret

alias kb='kubectl'
alias ka='kube-aws-credential'
alias ks='kubectl config get-contexts | sed "/^\ /d"'
source ~/.nvm/nvm.sh

export PATH=$PATH:/Users/take/Library/Python/3.6/bin/
source /Users/take/github.com/chaspy/nginx-up-and-running/.secret

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/private/tmp/google-cloud-sdk/path.bash.inc' ]; then source '/private/tmp/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/private/tmp/google-cloud-sdk/completion.bash.inc' ]; then source '/private/tmp/google-cloud-sdk/completion.bash.inc'; fi

. "$HOME/.cargo/env"

# >>> JVM installed by coursier >>>
export JAVA_HOME="/Users/01045513/Library/Caches/Coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26%252B4/OpenJDK11U-jdk_aarch64_mac_hotspot_11.0.26_4.tar.gz/jdk-11.0.26+4/Contents/Home"
# <<< JVM installed by coursier <<<

# >>> coursier install directory >>>
export PATH="$PATH:/Users/01045513/Library/Application Support/Coursier/bin"
# <<< coursier install directory <<<
