# Slack設定方法の比較

本番環境でSlack通知を設定する方法は2つあります。それぞれのメリット・デメリットを説明します。

## 方法1: GitHub Secretsを使用（推奨）

### 設定手順

1. GitHubリポジトリの「Settings」→「Secrets and variables」→「Actions」に移動
2. 「New repository secret」をクリック
3. 以下を設定：
   - **Name**: `SLACK_WEBHOOK_URL`
   - **Secret**: Slack Webhook URL
4. 次回のデプロイ時に自動的に`.slack-config`ファイルが生成されます

### メリット

- ✅ **自動化**: デプロイ時に自動的に設定ファイルが生成される
- ✅ **セキュリティ**: GitHub Secretsで安全に管理される
- ✅ **一貫性**: デプロイごとに確実に設定される
- ✅ **チーム共有**: リポジトリの設定として管理される

### デメリット

- ⚠️ GitHub Secretsへのアクセス権限が必要

---

## 方法2: サーバー上で手動設定

### 設定手順

```bash
# サーバーにSSH接続
ssh ubuntu@153.120.128.27

# 設定ファイルを作成
sudo nano /opt/salesnav/saleslist-infra/scripts/.slack-config

# 以下の内容を記入
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/***/***/***"

# ファイルの権限を設定
sudo chmod 600 /opt/salesnav/saleslist-infra/scripts/.slack-config
```

### メリット

- ✅ **即座に設定可能**: GitHub Secretsへのアクセスがなくても設定できる
- ✅ **柔軟性**: サーバーごとに異なる設定が可能

### デメリット

- ⚠️ **手動作業**: デプロイのたびに手動で設定する必要がある
- ⚠️ **忘れやすい**: デプロイ後に設定を忘れる可能性がある
- ⚠️ **管理が分散**: 設定がサーバー上に残る

---

## 方法3: 環境変数として設定（システム全体）

### 設定手順

```bash
# サーバーにSSH接続
ssh ubuntu@153.120.128.27

# システム環境変数として設定
sudo nano /etc/environment

# 以下を追加
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/***/***/***"

# または、ユーザー環境変数として設定
nano ~/.bashrc

# 以下を追加
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/***/***/***"
```

### メリット

- ✅ **システム全体で有効**: すべてのスクリプトで使用可能
- ✅ **永続的**: サーバー再起動後も有効

### デメリット

- ⚠️ **セキュリティ**: 環境変数はプロセス一覧で見える可能性がある
- ⚠️ **管理が分散**: 設定がサーバー上に残る

---

## 推奨設定方法

**本番環境では「方法1: GitHub Secrets」を推奨します。**

理由：
- デプロイの自動化と一貫性が保たれる
- セキュリティが向上する
- チームで管理しやすい

## 設定の優先順位

スクリプトは以下の順序で設定を読み込みます：

1. **環境変数** `SLACK_WEBHOOK_URL`（最優先）
2. **ローカル設定ファイル** `scripts/.slack-config`（開発環境用）
3. **サーバー設定ファイル** `/opt/salesnav/.slack-config`（本番環境用）

この順序により、環境変数で上書きすることも可能です。

