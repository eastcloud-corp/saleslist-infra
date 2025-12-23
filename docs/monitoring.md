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

## 定期監視の設定

### Cronジョブの追加（推奨）

サーバー上で以下のcronジョブを設定することで、定期的な監視が可能です：

```bash
# 5分ごとに監視を実行
*/5 * * * * /opt/salesnav/saleslist-infra/scripts/monitor-containers.sh >> /var/log/salesnav/monitor-cron.log 2>&1

# 1時間ごとにエラーチェックを実行
0 * * * * /opt/salesnav/saleslist-infra/scripts/check-frontend-errors.sh >> /var/log/salesnav/error-check.log 2>&1
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

## 関連ファイル

- `scripts/monitor-containers.sh` - コンテナ監視スクリプト
- `scripts/check-frontend-errors.sh` - エラー確認スクリプト
- `docker-compose/prd/docker-compose.yml` - ヘルスチェック設定
- `docker/frontend/Dockerfile.prod` - フロントエンドDockerfile
- `saleslist-front/next.config.mjs` - Next.js設定

