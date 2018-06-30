alias la='ls -la'
alias tree='tree -N'

# set color
export CLICOLOR=1 
export LSCOLORS=gxfxcxdxbxegedabagacad

alias gcd='cd $(ghq root)/$(ghq list | peco)'
alias gop='hub browse $(ghq list | peco)'

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

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

awsc () {
  export AWS_DEFAULT_PROFILE=$(grep -oE "(\[).+(\])" ~/.aws/credentials | tr -d [] | peco)
}
