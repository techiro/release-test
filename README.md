# Project Documentation

## Features
- Automated version management
- CI/CD pipeline integration
- Release note generation
- GitHub Actions workflow examples
- Repository integration via repository_dispatch

## Debugging

### actコマンドを使用したワークフローのローカル実行

```bash
brew install act
```

#### 基本的な使い方
1. Dockerデーモンを実行する：`open -a Docker`
2. ワークフローのリストを表示する：`act -l`
3. 特定のジョブを実行する：`act -j JOB_NAME`（例：`act push -j check-date`）
4. 詳細なログを表示する：`act -v -j JOB_NAME`

#### イベントタイプ別の実行方法

以下のイベントタイプでワークフローを実行できます：

1. プッシュイベント：`act push`
2. プルリクエストイベント：`act pull_request`
3. 手動トリガー（workflow_dispatch）：`act workflow_dispatch`
4. スケジュールイベント：`act schedule`
5. リポジトリディスパッチイベント：`act repository_dispatch -e repository_dispatch_event.json`

#### event.jsonを使ったイベントデータの指定

カスタムイベントデータを使用してワークフローを実行する場合は、`-e`または`--eventpath`オプションを使用します：

1. 標準の`event.json`を使用する場合：`act workflow_dispatch -e event.json`
2. カスタムイベントファイルを使用する場合：`act issue_comment -e issue_comment_event.json`
3. リポジトリディスパッチイベントの場合：`act repository_dispatch -e repository_dispatch_event.json`
4. 特定のジョブのみを実行する場合：`act workflow_dispatch -e event.json -j JOB_NAME` (例: `act issue_comment -e issue_comment_event.json -j deploy-command`)

#### 秘密情報と環境変数の設定

actでは`.actrc`ファイルと`.env`ファイルを使用して秘密情報や環境変数を設定できます：

1. `.env`ファイルの設定方法：
   ```bash
   # トークンを直接設定
   GITHUB_TOKEN=ghp_your_token_here
   GITHUB_APP_ID=your_app_id_here

   # 複数行の秘密鍵を設定
   GITHUB_APP_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
   MII...
   ...
   -----END RSA PRIVATE KEY-----"
   ```

2. 環境変数を使用してactを実行：
   ```bash
   # .envファイルからシークレット変数を読み込んで実行
   act --secret-file .env workflow_dispatch
   # .env.var ファイルから変数を読み込んで実行
    act --secret-file .env --var-file .env.var workflow_dispatch -j generate-token -s GITHUB_TOKEN="$(gh auth token)"
   ```
