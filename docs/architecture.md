# Saleslist インフラアーキテクチャ概要

本ドキュメントは、Saleslist の本番環境を支えるインフラ構成をまとめたものです。構築・運用作業や変更設計の際に参照してください。

## 1. 全体構成

```
Internet
  │
  ▼
[Sakura Cloud Firewall] ── (80/443, 22)
  │
  ▼
[Sakura Cloud VPS (Ubuntu)]
  │
  ├─ nginx (systemd) ──▶ 80/443 を終端し Docker コンテナへ転送
  │
  └─ Docker Compose (prd)
        ├─ frontend (Next.js, port 3000)
        ├─ backend  (Django REST, port 8000)
        ├─ worker   (Celery Worker)
        ├─ beat     (Celery Beat)
        ├─ redis    (Redis 7, port 6379)
        └─ db       (PostgreSQL 15, port 5432)
```

- 1 台の Sakura Cloud VPS 上で Docker Compose を用い、アプリ／ジョブ／データストアをコンテナとして稼働。
- nginx が公開ポート 80/443 を終端して Next.js / Django へリバースプロキシ。
- Redis / PostgreSQL は Docker ネットワーク内のみで公開しない。

## 2. コンポーネント詳細

| レイヤ | コンポーネント | 役割 | 備考 |
| --- | --- | --- | --- |
| OS | Ubuntu (VPS) | Docker Engine / Compose のホスト | `scripts/vps-init.sh` で初期セットアップ。 |
| Web | nginx | HTTPS → `frontend` / `backend` へルーティング | 設定ファイル: `/etc/nginx/sites-available/salesnav` |
| Docker | frontend | Next.js 本番ビルド。SSR / 静的配信 | 3000 番ポートで待受、nginx からアクセス |
| Docker | backend | Django REST API | 8000 番ポートで待受、Celery/DB/Redis を利用 |
| Docker | worker / beat | Celery 非同期処理 | `CELERY_BROKER_URL` で Redis を使用 |
| Docker | redis | ブローカー兼キャッシュ | Append-only モード、有状態サービス |
| Docker | db | PostgreSQL 15 | 永続ボリューム、`pg_isready` ヘルスチェック |

## 3. デプロイパイプライン

1. GitHub Actions `Deploy to Sakura VPS` が `deploy-*` タグ（または手動 `workflow_dispatch`）で起動。
2. `saleslist-backend` / `saleslist-front` / `saleslist-docs` / `saleslist-infra` の `main` をチェックアウト。
3. `bundle/` に各リポジトリを配置し、`rsync` で VPS (`/opt/salesnav`) へアップロード。
4. `docker compose -f saleslist-infra/docker-compose/prd/docker-compose.yml` で
   - イメージの `pull/build`
   - DB マイグレーション (`backend` コンテナ)
   - backend / worker / beat / frontend の再起動
5. デプロイ後、`docker builder prune` / `docker image prune` で不要イメージを削除。

タグの発行手順は `saleslist-docs/operations/release-tag-guide.md` を参照。

## 4. 環境と設定

| 環境 | 構成 | 備考 |
| --- | --- | --- |
| Production | Sakura Cloud VPS + Docker Compose | `deploy-*` タグで本番デプロイ |
| Staging | 同等構成を想定（Terraform 整備中） | 現状は手動構築ベース |
| Local Dev | Docker Compose (`docker-compose/dev/docker-compose.yml`) | `db / redis / backend / worker / beat / frontend` を一括起動 |

- GitHub Secrets で各種資格情報を管理し、ワークフローが `.env` を生成。
- 永続化ディレクトリ: `/var/lib/postgresql/data`, `/var/log/salesnav`, `/app/static`, `/app/media` など。

## 5. 運用メモ

- 障害発生時は VPS に SSH 接続し `docker compose -f saleslist-infra/docker-compose/prd/docker-compose.yml ps` や `docker logs` で状態確認。
- ログは `/var/log/salesnav/backend` / `/var/log/salesnav/frontend` 等に出力。`scripts/log-rotate.sh` でローテーション可能。
- ディスク圧迫対策として定期的に `docker image prune -a` 等を実施。
- 構成変更時は本ドキュメントと `saleslist-docs` の設計ドキュメントを併記で更新し、運用ルールとの整合性を保つ。
