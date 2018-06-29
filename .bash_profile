alias la='ls -la'
alias tree='tree -N'

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
