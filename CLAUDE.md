# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

社内のアルコールチェック業務をWeb上で記録・管理するRailsアプリケーション。従業員が出発時・到着時のアルコールチェック結果を登録し、管理者が実施状況を日付別に確認・CSV出力できる。

技術スタック: Ruby on Rails 8.1 / PostgreSQL / ERB + Tailwind CSS / Hotwire (Turbo, Stimulus) / Devise / Kamal（デプロイ）

## よく使うコマンド

```sh
# セットアップ（依存関係インストール、DB準備、Tailwindビルド等）
bin/setup

# 開発サーバー起動（Rails + Tailwind watcher を同時起動。Procfile.devに基づく）
bin/dev

# DB準備
bin/rails db:prepare

# 全テスト実行
bin/rails test

# 単一のテストファイルを実行
bin/rails test test/models/alcohol_check_test.rb

# 特定の1テストのみ実行（行番号指定）
bin/rails test test/models/alcohol_check_test.rb:12

# システムテスト（Capybara + Selenium）
bin/rails test:system

# Lint（Rubocop、rubocop-rails-omakase準拠）
bin/rubocop

# セキュリティスキャン
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit

# デプロイ（Kamal、160.251.204.239へ）
bin/kamal deploy
```

CIはGitHub Actions（`.github/workflows/ci.yml`）で `scan_ruby`（brakeman/bundler-audit）、`scan_js`（importmap audit）、`lint`（rubocop）、`test`、`system-test` を実行する。PRを出す際はこれらが通ることを意識する。

## アーキテクチャ

### ドメインモデル

- `User`（`app/models/user.rb`）: 社員。`employee_number`でDevise認証（`authentication_keys: [:employee_number]`、メールアドレスではない）。`role` enum（`employee` / `admin`）で権限管理。
- `AlcoholCheck`（`app/models/alcohol_check.rb`）: アルコールチェック記録。`user`（実施者）と`checker`（確認者、`class_name: 'User'`のエイリアス関連）の2つの`User`関連を持つ。`check_type` enum（`arrival`＝出社時 / `departure`＝帰社時）。

### 重要な業務ルール（バリデーション）

- **同日・同種チェックの二重登録防止**: `user_id` + `check_type` + `checked_on`の組み合わせがモデルバリデーション（`only_one_check_per_type_per_day`）とDBのユニークインデックス（`index_alcohol_checks_on_user_type_and_date`）の両方で防止されている。片方だけ直しても不十分なので、ロジックを変更する場合は両方を確認すること。
- **確認者は本人不可**: `checker_id == user_id`はバリデーションエラーになる（`checker_must_be_different_from_user`）。
- `checked_on`は`before_validation`で`Date.current`（Railsのタイムゾーン基準）が自動セットされる。

### コントローラー構成と権限制御

- 一般ユーザー向け: `DashboardController`（自分の当日チェック状況表示）、`AlcoholChecksController`（チェック登録、`create`のみ）。
- 管理者向け: `Admin::DashboardController`、`Admin::AlcoholChecksController`（`namespace :admin`配下）。両方とも`before_action :require_admin`で`current_user.admin?`を確認し、一般社員が直接URLアクセスしても弾かれる（ビューでリンクを隠すだけでなくコントローラー側でも制御している点が意図的な設計）。
- 管理者用`Admin::AlcoholChecksController#index`は`format.csv`でCSVエクスポートに対応。`includes(:user, :checker)`でN+1を回避している。
- フォーム失敗時、`AlcoholChecksController#create`は`dashboard/index`ビューを`unprocessable_entity`で再描画する（専用のerrorビューは持たない）。

### ルーティング

`config/routes.rb`はシンプルな構成。`devise_for :users`でDevise標準ルート、`namespace :admin`配下に管理者機能、トップレベルに一般ユーザー機能。新しいリソースを追加する際はこの構成パターン（`admin`名前空間の有無で権限を分離）に従う。

### デプロイ

Kamal（`config/deploy.yml`）でVPS（160.251.204.239）にDockerコンテナとしてデプロイ。PostgreSQLはaccessoryコンテナとして同一サーバー上で稼働。`bin/kamal console` / `bin/kamal shell` / `bin/kamal logs` / `bin/kamal dbc`のエイリアスあり。
