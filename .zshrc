# fix command typo
setopt correct

# don't leave duplicate command in history
setopt HIST_IGNORE_DUPS

# カスタムの zsh 補完ディレクトリを先頭に追加
fpath=("${HOME}/.zsh" $fpath)
# 現在の fpath から不要なディレクトリを除外（例として /usr/local/share/zsh/site-functions）
fpath=(${fpath:#/usr/local/share/zsh/site-functions})


# 以降、通常の初期化処理
autoload -Uz compinit
compinit -i

# alias
alias grp='cd $(ghq root)/$(ghq list | peco)'
alias pcd='cd $(dirname $(find . | peco))'
alias gop='hub browse $(ghq list | grep github.com | cut -f 2,3 -d / | peco)'
alias gho='gh repo view --web'
alias diff='diff -u'
alias pbc='pbcopy'
alias ex='exit'
alias vdu='vagrant destroy -f;vagrant up'
alias sed='gsed'
alias tf='terraform'
alias gsort="sort -V"
alias tff="terraform fmt --recursive"
alias ec2p="aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | [.InstanceId, (.Tags[] | select(.Key == \"Name\").Value), (.Tags[] | select(.Key == \"Environment\").Value), .PublicIpAddress, .PrivateIpAddress, .InstanceType, .State.Name] | @tsv' | peco | cut -f1 | xargs -I{} aws ec2 describe-instances --instance-ids {}"
alias vdu="vagrant destroy -f && vagrant up"
alias r53ap="aws route53 list-hosted-zones | jq -cr '.HostedZones[] | [.Id, .Name] | @tsv' | peco | cut -f1 | xargs -I {} aws route53 list-resource-record-sets --hosted-zone-id {} | jq -cr '.ResourceRecordSets[] | select(.AliasTarget != null) | [.Name, .Type, .AliasTarget.DNSName] | @tsv' | peco"
alias r53rp="aws route53 list-hosted-zones | jq -cr '.HostedZones[] | [.Id, .Name] | @tsv' | peco | cut -f1 | xargs -I {} aws route53 list-resource-record-sets --hosted-zone-id {} | jq -cr '.ResourceRecordSets[] | select(.ResourceRecords != null) | [.Name, .Type, .TTL, .ResourceRecords[].Value] | @tsv' | peco"
alias ghpc="gh pr create -d -f"
alias shuf='gshuf'
alias a='cd ..'
alias aa='cd ../..'

# https://github.com/Nutlope/aicommits
alias aic='aicommits  --type conventional --generate 5'

# docker-compose
alias dcr='docker-compose run'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcb='docker-compose build'

# kubernetes
alias k='kubectl'
alias kbctx="kubectx"
alias kall='kubectl get $(kubectl api-resources --namespaced=true --verbs=list -o name | tr "\n" "," | sed -e "s/,$//")'

alias -g @PO='$(kubectl get po     | peco | awk "{print \$1}")'
alias -g @RS='$(kubectl get rs     | peco | awk "{print \$1}")'
alias -g @DP='$(kubectl get deploy | peco | awk "{print \$1}")'
alias -g @DS='$(kubectl get ds     | peco | awk "{print \$1}")'
alias -g @SV='$(kubectl get svc    | peco | awk "{print \$1}")'

alias kb='kustomize build'

alias python='python3'

kc() {
  test "$1" = "-" && {
   kubectx -
   return
  }
  kubectx "$(kubectx | peco)"
  kubectl auth can-i get pods > /dev/null || ka
}

kn() {
  test "$1" = "-" && {
   kubens -
   return
  }
  kubens "$(kubens | peco)"
}

# git
alias git='/opt/homebrew/bin/git'
alias g='git'
alias gs='git status'
alias gupm="git fetch upstream && git checkout master && git merge upstream/master"
alias gsp='git stash apply stash@{0}'
alias gg='git grep'
alias grm='git pull origin master && git rebase origin/master'
alias grd='git pull origin develop && git rebase origin/develop'
alias releasestg='gh pr create --head feature/develop --base develop --title "Release(stg)" --web'
alias gcfd='git checkout feature/develop && git pull'
alias ga='git add'
alias gcm='git checkout master && git pull origin master'
alias gcma='git checkout main && git pull origin main'
alias gcd='git checkout develop && git pull origin develop'
alias cdt='cd "$(git rev-parse --show-toplevel)"'
alias gcf='git commit --amend --no-edit'

# brew
export PATH=$PATH:/opt/homebrew/bin

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export PATH=/usr/local/bin:$PATH
export PATH="/opt/homebrew/opt/go@1.20/bin:$PATH"

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH=$"$PATH:$HOME/.rbenv/bin"
eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init - zsh)"

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# aqua
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
export AQUA_GLOBAL_CONFIG="${AQUA_GLOBAL_CONFIG:-}:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"

# functions

gr () {
  git rebase -i HEAD~$1
}

b64d () {
  echo "${1}" | base64 --decode
}

unset-aws-cred () {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
}

## Create an issue
ghc-pddm () {
  if [ -z "${2}" ]; then
    echo "usage: ghc-pddm title body"
  else
    gh issue create -a chaspy -b "${2}" -t "${1}" --repo quipper/k12-pdd-management-jp
  fi
}

## open pull-request
open-pr () {
    merge_commit=$(buby -e 'print (File.readlines(ARGV[0]) & File.readlines(ARGV[1])).last' <(git rev-list --ancestry-path $1..master) <(git rev-list --first-parent $1..master))
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

# replace all
function grepsed() {
  if [ -z "${2}" ]; then
    echo "usage: grepsed old new"
  fi
  git grep -r $1 | cut -d':' -f1 | awk '!a[$0]++{print}' | xargs -I{} sed -i '' s/$1/$2/g {}
}

# color for less
export LESS="-iMR"
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'

# for direnv
export EDITOR=vim
eval "$(direnv hook zsh)"

# node brew
export PATH=$HOME/.nodebrew/current/bin:$PATH

source <(kubectl completion zsh)

# not work Ctrl A
# http://sotarok.hatenablog.com/entry/20080926/1222368908
bindkey -e

# prompt
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

PROMPT='%~ %F{45}($ZSH_KUBECTL_PROMPT)%f $ '

# rust
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

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
export DVM_DIR="/Users/chaspy/.dvm"
export PATH="$DVM_DIR/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/01045513/Downloads/google-cloud-sdk 2/path.zsh.inc' ]; then . '/Users/01045513/Downloads/google-cloud-sdk 2/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/01045513/Downloads/google-cloud-sdk 2/completion.zsh.inc' ]; then . '/Users/01045513/Downloads/google-cloud-sdk 2/completion.zsh.inc'; fi

PATH="/Users/01045513/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/01045513/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/01045513/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/01045513/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/01045513/perl5"; export PERL_MM_OPT;

export PATH="/Library/TeX/texbin:$PATH"

export PATH="/Users/01045513/.local/bin:$PATH"

# flutter
export PATH="/Users/chaspy/flutter/bin:$PATH"

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Created by `pipx` on 2024-09-06 00:44:09
export PATH="$PATH:/Users/chaspy/.local/bin"

# Perl
if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi

# chaspy/renovate-safety
export RENOVATE_SAFETY_LANGUAGE=ja

# claude code
export MAX_THINKING_TOKENS=31999

export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
