eval "(rbenv init -)"
alias la='ls -la'
alias tree='tree -N'

alias gcd='cd $(ghq root)/$(ghq list | peco)'
alias gop='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
