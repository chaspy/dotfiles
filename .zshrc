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
alias gcd='cd $(ghq root)/$(ghq list | peco)'
alias gop='hub browse $(ghq list | grep github.com | cut -f 2,3 -d / | peco)'
alias hubr='hub browse'
alias diff='diff -u'
alias pvi='vi $(find . -type f | peco)'
alias pgg='(){vi $(git grep $1 | peco | cut -f 1 -d ":")}'
alias less='bat'
alias pbc='pbcopy'
alias ex='exit'

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

# functions
## open pull-request
open-pr () {
    merge_commit=$(ruby -e 'print (File.readlines(ARGV[0]) & File.readlines(ARGV[1])).last' <(git rev-list --ancestry-path $1..master) <(git rev-list --first-parent $1..master))
    if git show $merge_commit | grep -q 'pull request'
    then
        pull_request_number=$(git log -1 --format=%B $merge_commit | sed -e 's/^.*#\([0-9]*\).*$/\1/' | head -1)
        url="`hub browse -u`/pull/${pull_request_number}"
    fi
    open $url
}

## open release pr
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

## for server-template
svtp_ssh () {
  cp ssh.config.template ssh.config
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  cp -f ./script/ansible.cfg.test ./ansible.cfg
}

## change aws default credential
awsc () {
  export AWS_DEFAULT_PROFILE=$(grep -oE "(\[).+(\])" ~/.aws/credentials | tr -d "[]" | peco)
}

function peco-select-history() {
    BUFFER="$(history -nr 1 | awk '!a[$0]++' | peco --query "$LBUFFER" | sed 's/\\n/\n/')"
    CURSOR=$#BUFFER             # カーソルを文末に移動
    zle -R -c                   # refresh
}
zle -N peco-select-history
bindkey '^R' peco-select-history

function git_rebase_from_master() {
  current_branch=$(git branch --contains | cut -d ' ' -f 2)
  git checkout master
  git pull origin master
  git checkout $current_branch
  git rebase master
}

# color for less
export LESS="-iMR"
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'

# for direnv
export EDITOR=vim
eval "$(direnv hook zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/take/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/take/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/take/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/take/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# node brew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# kubernetes cluster
alias kb='kubectl'
alias ka='kube-aws-credential'
alias ks='kubectl config get-contexts | sed "/^\ /d"'

alias -g @PO='$(kubectl get po     | peco | awk "{print \$1}")'
alias -g @RS='$(kubectl get rs     | peco | awk "{print \$1}")'
alias -g @DP='$(kubectl get deploy | peco | awk "{print \$1}")'
alias -g @DS='$(kubectl get ds     | peco | awk "{print \$1}")'
alias -g @SV='$(kubectl get svc    | peco | awk "{print \$1}")'

kc() {
  test "$1" = "-" && {
   kctx -
   return
  }
  kctx "$(kctx | peco)"
  kb auth can-i get pods > /dev/null || ka
}

kn() {
  test "$1" = "-" && {
   kns -
   return
  }
  kns "$(kns | peco)"
}

source <(kubectl completion zsh)

# not work Ctrl A
# http://sotarok.hatenablog.com/entry/20080926/1222368908
bindkey -e

# prompt
PROMPT="%d
 $ "

function rprompt-git-current-branch {
  local branch_name st branch_status

  if [ ! -e  ".git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]%f"
}

setopt prompt_subst
RPROMPT='`rprompt-git-current-branch`'

PROMPT='%m:%c $(kube_prompt_info) %(!.#.$) '

export KUBE_PROMPT_INFO_PREFIX="%{$fg[yellow]%}("
export KUBE_PROMPT_INFO_SUFFIX=")%{$reset_color%}"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# ruby
export PATH="$HOME/.rbenv/shims:$PATH"

# history
## File path where history is stored
export HISTFILE=${HOME}/.zsh_history
## Number of histories stored in memory
export HISTSIZE=1000
## Number of histories stored in file
export SAVEHIST=100000
## Remove duplicates
setopt hist_ignore_dups
## record start/end point
setopt EXTENDED_HISTORY
