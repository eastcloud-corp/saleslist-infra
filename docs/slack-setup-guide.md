# Slack通知設定ガイド

## 概要

Slack通知機能を使用するには、Slackアプリを作成してIncoming Webhookを設定する必要があります。手順は簡単で、約5分で完了します。

## ステップバイステップ手順

### 1. Slack APIサイトにアクセス

1. https://api.slack.com/apps にアクセス
2. 右上の「Your Apps」をクリック
3. 「Create New App」をクリック

### 2. アプリの基本設定

1. **「From scratch」を選択**
   - アプリ名: `Sales Navigator Monitoring`（任意の名前でOK）
   - ワークスペース: 通知を送信したいワークスペースを選択
2. 「Create App」をクリック

### 3. Incoming Webhooksを有効化

1. 左側のメニューから「**Incoming Webhooks**」を選択
2. 「**Activate Incoming Webhooks**」のトグルをONにする
3. ページ下部の「**Add New Webhook to Workspace**」をクリック
4. 通知を送信したいチャンネルを選択（例: `#monitoring`, `#alerts`）
5. 「**Allow**」をクリック

### 4. Webhook URLをコピー

1. 生成されたWebhook URLをコピー
   - 形式: `https://hooks.slack.com/services/***/***/***`
2. このURLをサーバー上の設定ファイルに保存

### 5. サーバー上で設定

```bash
# 設定ファイルを作成
sudo nano /opt/salesnav/.slack-config

# 以下の内容を記入（Webhook URLを実際の値に置き換え）
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/***/***/***"

# ファイルの権限を設定（読み取り専用）
sudo chmod 600 /opt/salesnav/.slack-config
```

### 6. テスト

```bash
# 通知のテスト
/opt/salesnav/saleslist-infra/scripts/slack-notify.sh "テスト通知です" --level info
```

## よくある質問

### Q: Slackアプリを作成する必要があるの？

**A: はい、必要です。** ただし、Incoming Webhooksを使う方法が最も簡単です。上記の手順で約5分で設定できます。

### Q: ワークスペースの管理者権限が必要？

**A: 通常は不要です。** ただし、ワークスペースの設定によっては管理者の承認が必要な場合があります。

### Q: セキュリティは大丈夫？

**A: Webhook URLは秘密情報として扱ってください。**
- 設定ファイルの権限を600に設定（所有者のみ読み取り可能）
- Webhook URLをGitにコミットしない
- 必要に応じて定期的にURLを再生成

### Q: 複数のチャンネルに通知したい

**A: 複数のWebhook URLを作成できます。**
- 各チャンネルごとにWebhook URLを作成
- 設定ファイルに複数のURLを設定（スクリプトを拡張）

## トラブルシューティング

### 通知が届かない場合

1. Webhook URLが正しいか確認
2. チャンネルが存在するか確認
3. アプリがワークスペースにインストールされているか確認
4. サーバーからインターネットに接続できるか確認

### 権限エラーが発生する場合

1. ワークスペースの管理者に相談
2. アプリの再インストールを試す

## 代替案

Slackアプリを作成したくない場合の代替案：

1. **メール通知**: SendGrid等を使用（既に設定済み）
2. **Discord Webhook**: Discordを使用している場合
3. **LINE Notify**: LINE通知を使用
4. **ログファイルのみ**: Slack通知なしでログファイルに記録

これらの代替案が必要な場合は、スクリプトを拡張できます。

