# Saleslist Infrastructure

さくらのクラウド App Run を使用した営業リスト管理システムのインフラ構成

## アーキテクチャ

```
Internet → [Firewall] → [Frontend App Run] → [Backend App Run] → [Database App Run]
```

## 必要なさくらのクラウド設定情報

### 1. アカウント・認証情報
- **APIアクセスキー**: さくらのクラウドのコントロールパネルで生成
- **APIシークレットキー**: アクセスキーと対になるシークレット
- **ゾーン**: tk1v (東京第1ゾーン) を推奨

### 2. GitHub Container Registry設定
- **レジストリ**: ghcr.io（GitHub無料）
- **認証**: GitHub Token自動設定

### 3. GitHub Secrets設定

以下のシークレットをGitHubリポジトリに設定してください：

```
SAKURA_ACCESS_TOKEN=your_sakura_api_access_token
SAKURA_ACCESS_TOKEN_SECRET=your_sakura_api_secret
DB_PASSWORD=your_secure_database_password
DJANGO_SECRET_KEY=your_django_secret_key_50_chars_long
```

### 4. 初期セットアップ手順

#### Step 1: さくらのクラウドAPIキー取得
1. さくらのクラウドコントロールパネルにログイン
2. 「設定」→「APIキー」でアクセスキーを生成
3. 生成されたアクセスキーとシークレットをメモ

#### Step 2: GitHub Container Registry権限設定
```bash
# GitHubリポジトリの Settings → Actions → General で
# Workflow permissions を "Read and write permissions" に設定
```

#### Step 3: 手動デプロイ（初回のみ）
```bash
# Dockerイメージビルド・プッシュ
cd saleslist-infra
./scripts/deploy.sh staging
```

#### Step 4: GitHub Actions設定
1. GitHubリポジトリのSettings → Secrets and variablesでシークレット設定
2. mainブランチにプッシュで本番デプロイ自動実行
3. developブランチにプッシュでステージング環境デプロイ自動実行

## 環境別設定

### Staging環境
- **CPU/メモリ**: 控えめな設定
- **ドメイン**: saleslist-frontend-staging.sakura.app
- **データベース**: 10GBストレージ

### Production環境  
- **CPU/メモリ**: 本格運用向け設定
- **ドメイン**: budget-sales.com (カスタムドメイン)
- **データベース**: 100GBストレージ、自動バックアップ

## デプロイメント

### 自動デプロイ（推奨）
```bash
# Staging環境
git push origin develop

# Production環境
git push origin main
```

### 手動デプロイ
```bash
# Staging環境
./saleslist-infra/scripts/deploy.sh staging

# Production環境
./saleslist-infra/scripts/deploy.sh production
```

## ヘルスチェック

```bash
# デプロイ後の動作確認
./saleslist-infra/scripts/health-check.sh [staging|production]
```

## トラブルシューティング

### デプロイが失敗する場合
1. GitHub Secretsの設定を確認
2. さくらのクラウドのAPIキーの権限を確認
3. Terraform stateファイルの整合性を確認

### アプリケーションが起動しない場合
1. コンテナログを確認
2. 環境変数の設定を確認
3. データベース接続を確認

## 費用概算

### 共通スペック（Staging・Production）
- Frontend: 0.25 CPU / 512 MB ≈ 約2,000円/月
- Backend: 0.5 CPU / 1 GB ≈ 約4,000円/月  
- Database: 0.5 CPU / 1 GB / 20 GB ≈ 約4,000円/月
- GitHub Container Registry: **無料**
- **月額合計**: **約10,000円/月**

### デプロイゾーン
- **石狩第1ゾーン（is1a）** - 最安料金（東京より3-10%安い）

## Django管理者アカウント

初回デプロイ時に以下のスーパーユーザーが自動作成されます：

- **ユーザー名**: salesnav_admin
- **パスワード**: salesnav20250901
- **メールアドレス**: salesnav_admin@budget-sales.com

アクセス: https://[backend-url]/admin/