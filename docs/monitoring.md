# 監視とヘルスチェック

本ドキュメントは、Sales Navigatorの監視とヘルスチェックに関する設定と運用方法を説明します。

## 監視スクリプト

### コンテナ監視スクリプト (`monitor-containers.sh`)

コンテナのCPU使用率、メモリ使用率、プロセス数を監視します。

#### 使用方法

```bash
# 基本監視（ログに記録）
./scripts/monitor-containers.sh

# アラートモード（閾値超過時に警告）
./scripts/monitor-containers.sh --alert
```

#### 監視項目

- **CPU使用率**: 各コンテナのCPU使用率（閾値: 80%）
- **メモリ使用率**: 各コンテナのメモリ使用率（閾値: 80%）
- **プロセス数**: 各コンテナ内のプロセス数（閾値: 50）
- **curlプロセス数**: ヘルスチェックの暴走を検出（警告閾値: 10）

#### ログ出力

監視結果は `/var/log/salesnav/monitor.log` に記録されます。

### フロントエンドエラー確認スクリプト (`check-frontend-errors.sh`)

フロントエンドコンテナのエラーを分析します。

#### 使用方法

```bash
./scripts/check-frontend-errors.sh
```

#### 確認項目

- エラータイプ別の集計
- 最近のエラーログ（最新20件）
- コンテナのヘルスステータス
- プロセス数（特にcurlプロセスの検出）

## ヘルスチェック設定

### 改善内容

504エラーの原因となったヘルスチェックの問題を改善しました：

1. **タイムアウト設定の改善**
   - タイムアウト: 10s → 15s
   - curlの接続タイムアウト: 3秒
   - curlの最大実行時間: 5秒

2. **プロセスのクリーンアップ**
   - `--max-time` オプションでcurlプロセスの暴走を防止
   - `start_period` を追加して起動時のチェックを緩和

3. **リトライ設定の最適化**
   - リトライ回数: 5回 → 3回（過度なリトライを防止）

### 設定ファイル

- `docker-compose/prd/docker-compose.yml`
  - `frontend` サービスのヘルスチェック設定
  - `backend` サービスのヘルスチェック設定

## Slack通知設定

### Slack Webhook URLの設定

**重要**: Slack通知を使用するには、Slackアプリの作成が必要です。ただし、Incoming Webhooksを使う方法が最も簡単で、約5分で設定できます。

詳細な手順は `docs/slack-setup-guide.md` を参照してください。

**簡単な手順**:
1. https://api.slack.com/apps にアクセス
2. "Create New App" → "From scratch" を選択
3. アプリ名とワークスペースを選択
4. "Incoming Webhooks" → "Activate Incoming Webhooks" をON
5. "Add New Webhook to Workspace" でチャンネルを選択
6. 生成されたWebhook URLをコピー

2. サーバー上で設定ファイルを作成

```bash
# 設定ファイルを作成
sudo nano /opt/salesnav/.slack-config

# 以下の内容を記入（Webhook URLを実際の値に置き換え）
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/***/***/***"

# ファイルの権限を設定（読み取り専用）
sudo chmod 600 /opt/salesnav/.slack-config
```

### 通知レベルの説明

- **info**: 情報通知（通常は使用しない）
- **warning**: 警告（CPU/メモリ使用率が高い、プロセス数が多いなど）
- **error**: エラー（コンテナが停止、リソース不足など）
- **critical**: 緊急（コンテナがダウン、システム障害など）

## 定期監視の設定

### Cronジョブの追加（推奨）

サーバー上で以下のcronジョブを設定することで、定期的な監視とSlack通知が可能です：

```bash
# 5分ごとに監視を実行（Slack通知付き）
*/5 * * * * /opt/salesnav/saleslist-infra/scripts/monitor-containers.sh --alert --slack >> /var/log/salesnav/monitor-cron.log 2>&1

# 1分ごとにコンテナ停止をチェック（Slack通知付き）
* * * * * /opt/salesnav/saleslist-infra/scripts/check-container-down.sh >> /var/log/salesnav/container-check.log 2>&1

# 1時間ごとにエラーチェックを実行
0 * * * * /opt/salesnav/saleslist-infra/scripts/check-frontend-errors.sh >> /var/log/salesnav/error-check.log 2>&1
```

### 手動実行（テスト用）

```bash
# 監視スクリプトの実行（Slack通知なし）
./scripts/monitor-containers.sh --alert

# 監視スクリプトの実行（Slack通知あり）
./scripts/monitor-containers.sh --alert --slack

# コンテナ停止チェック（Slack通知あり）
./scripts/check-container-down.sh

# Slack通知のテスト
./scripts/slack-notify.sh "テスト通知です" --level info
```

### 手動実行

```bash
# 監視スクリプトの実行
cd /opt/salesnav/saleslist-infra
./scripts/monitor-containers.sh

# エラーチェックの実行
./scripts/check-frontend-errors.sh
```

## トラブルシューティング

### 504エラーが発生した場合

1. フロントエンドコンテナの状態を確認
   ```bash
   docker ps --filter name=saleslist_frontend_prd
   docker logs --tail 50 saleslist_frontend_prd
   ```

2. ヘルスチェックの状態を確認
   ```bash
   docker inspect saleslist_frontend_prd --format '{{json .State.Health}}' | jq
   ```

3. curlプロセスの数を確認
   ```bash
   docker top saleslist_frontend_prd | grep curl | wc -l
   ```

4. 必要に応じてコンテナを再起動
   ```bash
   cd /opt/salesnav/saleslist-infra/docker-compose/prd
   docker compose restart frontend
   ```

### CPU使用率が高い場合

1. 監視スクリプトで詳細を確認
   ```bash
   ./scripts/monitor-containers.sh --alert
   ```

2. プロセス数を確認
   ```bash
   docker top saleslist_frontend_prd
   ```

3. 不要なプロセスをクリーンアップ（コンテナ再起動）
   ```bash
   docker compose restart frontend
   ```

## Next.jsエラー対策

### Server Actionエラー

Next.js 15のServer Actions機能に関するエラーが発生する場合：

1. `next.config.mjs` の設定を確認
   - `experimental.serverActions` の設定が適切か確認

2. デプロイメントの整合性を確認
   - 古いデプロイメントからのリクエストが原因の可能性
   - 完全な再デプロイを実施

### フォーム処理エラー

マルチパートフォームの処理エラーが発生する場合：

1. リクエストサイズの確認
   - `bodySizeLimit` の設定を確認（デフォルト: 2MB）

2. クライアント側のフォーム送信を確認
   - ブラウザの開発者ツールでネットワークリクエストを確認

## Slack通知機能

### 通知されるイベント

以下のイベントが発生した場合、Slackに通知が送信されます：

1. **コンテナ停止** (critical)
   - いずれかのコンテナが停止した場合

2. **CPU使用率超過** (error)
   - コンテナのCPU使用率が80%を超えた場合

3. **メモリ使用率超過** (error)
   - コンテナのメモリ使用率が80%を超えた場合

4. **プロセス数超過** (warning)
   - コンテナ内のプロセス数が50を超えた場合

5. **curlプロセス暴走** (warning)
   - コンテナ内のcurlプロセスが10を超えた場合（ヘルスチェック問題の可能性）

6. **ディスク使用率超過** (warning)
   - ディスク使用率が85%を超えた場合

### 通知メッセージの形式

Slack通知には以下の情報が含まれます：
- サーバー名（hostname）
- 発生時刻
- アラートレベル（色分け）
- 詳細メッセージ

## 関連ファイル

- `scripts/monitor-containers.sh` - コンテナ監視スクリプト（Slack通知対応）
- `scripts/check-container-down.sh` - コンテナ停止チェックスクリプト
- `scripts/slack-notify.sh` - Slack通知送信スクリプト
- `scripts/check-frontend-errors.sh` - エラー確認スクリプト
- `scripts/.slack-config.example` - Slack設定ファイルのテンプレート
- `docker-compose/prd/docker-compose.yml` - ヘルスチェック設定
- `docker/frontend/Dockerfile.prod` - フロントエンドDockerfile
- `saleslist-front/next.config.mjs` - Next.js設定

