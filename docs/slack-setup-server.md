# 本番サーバーでのSlack設定手順

## 概要

本番サーバーでSlack通知を有効にするための手順です。`.slack-config`ファイルは`.gitignore`に追加されているため、GitHubにはコミットされません。サーバー上で直接設定ファイルを作成する必要があります。

## 設定手順

### 1. サーバーにSSH接続

```bash
ssh -i ~/.ssh/salesnav_vps_key.key ubuntu@153.120.128.27
```

### 2. 設定ファイルを作成

```bash
# 設定ファイルを作成
sudo nano /opt/salesnav/.slack-config
```

### 3. Webhook URLを記入

以下の内容を記入します（Webhook URLを実際の値に置き換え）：

```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### 4. ファイルの権限を設定

```bash
# 読み取り専用に設定（セキュリティのため）
sudo chmod 600 /opt/salesnav/.slack-config

# 所有者を確認（必要に応じて変更）
sudo chown ubuntu:ubuntu /opt/salesnav/.slack-config
```

### 5. 動作確認

```bash
# テスト通知を送信
/opt/salesnav/saleslist-infra/scripts/slack-notify.sh "サーバーからのテスト通知です" --level info
```

成功すると、Slackチャンネルに通知が届きます。

## 設定ファイルの場所

スクリプトは以下の順序で設定ファイルを探します：

1. **ローカル開発環境**: `scripts/.slack-config`（Gitにはコミットされません）
2. **本番サーバー**: `/opt/salesnav/.slack-config`（手動で作成が必要）
3. **環境変数**: `SLACK_WEBHOOK_URL`（任意）

## トラブルシューティング

### 通知が届かない場合

1. 設定ファイルが存在するか確認
   ```bash
   ls -la /opt/salesnav/.slack-config
   ```

2. 設定ファイルの内容を確認（Webhook URLが正しいか）
   ```bash
   cat /opt/salesnav/.slack-config
   ```

3. スクリプトが設定ファイルを読み込めるか確認
   ```bash
   source /opt/salesnav/.slack-config
   echo $SLACK_WEBHOOK_URL
   ```

4. 手動でテスト
   ```bash
   /opt/salesnav/saleslist-infra/scripts/slack-notify.sh "テスト" --level info
   ```

### 権限エラーの場合

```bash
# ファイルの権限を確認
ls -la /opt/salesnav/.slack-config

# 必要に応じて権限を修正
sudo chmod 600 /opt/salesnav/.slack-config
sudo chown ubuntu:ubuntu /opt/salesnav/.slack-config
```

## セキュリティ注意事項

- Webhook URLは秘密情報です。Gitにコミットしないでください
- ファイルの権限は600（所有者のみ読み取り可能）に設定してください
- 定期的にWebhook URLを再生成することを推奨します

