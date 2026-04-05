# Claude Remote 再ログイン手順

Claude Code が突然ログアウトしたときに、外出先から iPhone の Termius 経由で再ログインするための手順。

## 結論

`claude auth login` ではなく `claude setup-token` を使う。
dotfiles の `clogin` はそのラッパーにしてあり、発行された token は自動で `~/.config/claude/oauth-token.env` に保存される。

## 手順

1. Termius で自宅 Mac に SSH する
2. `clogin` を実行する
3. 画面に出た URL を iPhone のブラウザで開く
4. ブラウザで表示された code を Termius に貼って Enter
5. `Long-lived authentication token created successfully!` が出れば完了

## 保存先

- token file: `~/.config/claude/oauth-token.env`
- shell 起動時に `.zshrc` から自動で `source` する

## 補足

- `clogin` は URL を stderr に再掲し、`pbcopy` にも入れる
- wrapper は `claude setup-token` の出力から token を拾って自動保存する
- 既に開いているシェルは古い `clogin` 定義を保持する。更新後は `source ~/.zshrc` か `exec zsh` が必要
- 人間が手で入力する場合は普通に Enter でよい
- エージェントや自動化から code を送る場合は `\n` ではなく `\r` を送らないと確定されないことがある

## トラブルシュート

- `invalid oauth` が出たら URL の有効期限切れ。`clogin` をやり直して新しい URL を使う
- `loggedIn: false` のままなら `source ~/.config/claude/oauth-token.env` の後に `claude auth status` を確認する
