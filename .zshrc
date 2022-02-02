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
alias pcd='cd $(dirname $(find . | peco))'
alias gop='hub browse $(ghq list | grep github.com | cut -f 2,3 -d / | peco)'
alias gho='gh repo view --web'
alias diff='diff -u'
alias pbc='pbcopy'
alias ex='exit'
alias gg='git grep'
alias grm='git pull origin master && git rebase origin/master'
alias grd='git pull origin develop && git rebase origin/develop'
alias vdu='vagrant destroy -f;vagrant up'
alias gsp='git stash apply stash@{0}'
alias sed='gsed'
alias tf='terraform'
alias gsort="sort -V"
alias tff="terraform fmt --recursive"
alias date="/usr/local/bin/gdate"
alias ls='lsd'
alias ec2p="aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | [.InstanceId, (.Tags[] | select(.Key == \"Name\").Value), (.Tags[] | select(.Key == \"Environment\").Value), .PublicIpAddress, .PrivateIpAddress, .InstanceType, .State.Name] | @tsv' | peco | cut -f1 | xargs -I{} aws ec2 describe-instances --instance-ids {}"
alias vdu="vagrant destroy -f && vagrant up"
alias r53ap="aws route53 list-hosted-zones | jq -cr '.HostedZones[] | [.Id, .Name] | @tsv' | peco | cut -f1 | xargs -I {} aws route53 list-resource-record-sets --hosted-zone-id {} | jq -cr '.ResourceRecordSets[] | select(.AliasTarget != null) | [.Name, .Type, .AliasTarget.DNSName] | @tsv' | peco"
alias r53rp="aws route53 list-hosted-zones | jq -cr '.HostedZones[] | [.Id, .Name] | @tsv' | peco | cut -f1 | xargs -I {} aws route53 list-resource-record-sets --hosted-zone-id {} | jq -cr '.ResourceRecordSets[] | select(.ResourceRecords != null) | [.Name, .Type, .TTL, .ResourceRecords[].Value] | @tsv' | peco"
alias ghpc="gh pr create -d -f"
alias gupm="git fetch upstream && git checkout master && git merge upstream/master"
alias kbctx="kubectx"

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export PATH=$PATH:/usr/local/bin

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init - zsh)"

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# brew
export PATH=$PATH:/opt/homebrew/bin

# aqua
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
export AQUA_GLOBAL_CONFIG="${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"

# functions

unset-aws-cred () {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
}

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
    gh pr create -w -H develop -B "$branch" -t "$title" -b "To release"
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
  export AWS_DEFAULT_PROFILE=$(grep -oE "(\[).+(\])" ~/.aws/config | tr -d "[]" | cut -d ' ' -f2 | peco)
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

## AWS
function list-hosted-zones() {
  aws route53 list-hosted-zones | jq '.HostedZones[]' | jq -cr '[.Id,.Name]'
}

function list-resource-record-sets-a() {
  list-hosted-zones | peco | tr -d '[]' | cut -d',' -f 1 | xargs -I{} \
  aws route53 list-resource-record-sets --hosted-zone-id {} | jq -r '.ResourceRecordSets[]' | jq '. | select(.Type == "A" and (. | has("AliasTarget") | not))' | \
  jq -cr .
}

function pvi() {
  FILE=$(find . -type f | peco)
  if [[ -n $FILE ]]; then
    vi $FILE
  fi
}

# for devops test
function generate_logs() {
  cp -r $(ghq root)/github.com/quipper/devops-test/logs .
  cp $(ghq root)/github.com/quipper/devops-test/generate_logs.sh .
  ./generate_logs.sh
}

## peco git grep
function pgg() {
  if [ -z "${1}" ]; then
    :
  else
    RESULT=$(git grep $1 | peco)
    if [ -z "${RESULT}" ]; then
      :
    else
      vi $(echo ${RESULT} | cut -f 1 -d ":")
    fi
  fi
}

## peco git log
function pgl() {
  git log --oneline --pretty=format:'%h \[%cd\] %d %s \<%an\>' --date=format:'%Y/%m/%d %H:%M:%S' | \
  peco | \
  cut -d ' ' -f1 | \
  xargs git show
}

function zenhub_assignee_url() {
  assignee=$1
  URL="https://app.zenhub.com/workspaces/k12-sre-team-601d05eba026df000f1640fa/board?assignees=${assignee}&filterLogic=any&repos=35426098,18326008"
  echo "${URL}"
}

function open_zenhub_sre() {
  for m in yuya-takeyama chaspy motobrew suzuki-shunsuke int128 44smkn kyontan;
  do
    url=$(zenhub_assignee_url "${m}")
    open "${url}"
  done
}

# color for less
export LESS="-iMR"
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'

# for direnv
export EDITOR=vim
eval "$(direnv hook zsh)"

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
export HISTSIZE=10000
## Number of histories stored in file
export SAVEHIST=100000
## Remove duplicates
setopt hist_ignore_dups
## record start/end point
setopt EXTENDED_HISTORY

# gist
## Change remote url from https to git
# git remote set-url origin git@gist.github.com:b76751a0cb1474ecfafb9ab9f9eabdc9.git
function change_gist_url_to_git (){
  git remote set-url origin "git@gist.github.com:${1}.git"
}

# colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

 # pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# kubectl
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/opt/gettext/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/chaspy/go/src/github.com/chaspy/weekendersfm/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/chaspy/go/src/github.com/chaspy/weekendersfm/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/chaspy/go/src/github.com/chaspy/weekendersfm/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/chaspy/go/src/github.com/chaspy/weekendersfm/google-cloud-sdk/completion.zsh.inc'; fi
