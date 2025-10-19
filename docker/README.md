# Docker 多環境構成

`docker/` ディレクトリには開発・検証環境向けの Docker Compose 定義をまとめています。

## ディレクトリ構成

```
docker/
  ├─ dev/                 # ローカル開発専用の Compose 定義
  │   └─ docker-compose.yml
  ├─ backend/             # 将来的な backend 用 Compose テンプレート
  ├─ frontend/            # 将来的な frontend 用 Compose テンプレート
  └─ docker-compose.yml   # サンプル構成（ベースライン）
```

## ローカル開発環境の起動

```bash
cd saleslist-infra/docker/dev
docker compose up -d
```

- 起動するサービス
  - PostgreSQL (`localhost:5434`)
  - Django Backend (`localhost:8002`)
  - Next.js Frontend (`localhost:3002`)
- ホットリロード対応。バックエンド／フロントエンドのソースを直接マウントしています。

## サンプル構成

ルートの `docker-compose.yml` は、将来的な本番相当環境のベースライン例です。必要に応じて `production` ディレクトリなどを追加して管理してください。
