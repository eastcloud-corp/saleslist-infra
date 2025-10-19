# Docker 多環境構成

`docker/` ディレクトリには開発・検証環境向けの Docker Compose 定義をまとめています。

## ディレクトリ構成

```
docker/
  ├─ dev/                   # ローカル開発専用の Compose 定義
  │   └─ docker-compose.yml
  ├─ backend/               # (prod 用) backend Dockerfile など
  ├─ frontend/              # (prod 用) frontend Dockerfile など
  └─ docker-compose.yml     # サンプル構成（ベースライン）

env/
  ├─ dev/
  │   ├─ backend.env        # 開発用バックエンド環境変数
  │   └─ frontend.env       # 開発用フロントエンド環境変数
  └─ prod/
      ├─ backend.env        # 本番用バックエンド環境変数（テンプレート）
      └─ frontend.env       # 本番用フロントエンド環境変数（テンプレート）
```

## ローカル開発環境の起動

```bash
cd saleslist-infra/docker/dev
docker compose up -d
```

- 環境変数は `env/dev/backend.env` / `env/dev/frontend.env` にまとまっています。必要に応じて API URL や `DJANGO_DEBUG` などを書き換えてください。
- 起動するサービス
  - PostgreSQL (`localhost:5434`)
  - Django Backend (`localhost:8002`)
  - Next.js Frontend (`localhost:3002`)
- ホットリロード対応。バックエンド／フロントエンドのソースを直接マウントしています。

## サンプル構成

ルートの `docker-compose.yml` は、将来的な本番相当環境のベースライン例です。必要に応じて `production` ディレクトリなどを追加して管理してください。

- 本番向けの環境変数は `env/prod/backend.env` / `env/prod/frontend.env` をベースに Secrets から注入してください。
