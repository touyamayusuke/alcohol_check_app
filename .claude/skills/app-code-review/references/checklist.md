# レビュー観点チェックリスト

対象ファイルの種類に関係するセクションだけ使えばよい。ここは要約なので、詳細・最新は `CLAUDE.md` と `.claude/rules/coding.md` を参照する。

## 目次
1. 業務ルール
2. 権限制御・セキュリティ
3. モデル規約
4. コントローラー規約
5. ビュー規約
6. テスト規約

---

## 1. 業務ルール

- [ ] **同日・同種の二重登録防止**
  - モデル: `only_one_check_per_type_per_day`（`on: :create`）
  - DB: `index_alcohol_checks_on_user_type_and_date`（`user_id, check_type, checked_on` unique）
  - 両者が同じ条件を見ているか。バリデーションの検索条件が `checked_on` と異なる日付（`Date.current` など）を使っていると、`checked_on` を明示的に指定した場合や日付をまたぐ処理でモデルとDBの判定がずれる。
  - どちらかを変更する差分なら、もう片方も追随しているか。
- [ ] **確認者は本人不可**: `checker_must_be_different_from_user`。確認者の選択肢（`User.where.not(id: current_user.id)`）もあわせて整合しているか。
- [ ] **checked_on の自動設定**: `before_validation` で `Date.current`（Railsタイムゾーン基準）。`Date.today` / `Time.now` を使うとタイムゾーンがずれる。
- [ ] **check_type の表示ラベル**: `arrival`＝出社時、`departure`＝帰社時。画面・CSV・フラッシュで表記揺れがないか（例:「帰社前」と「帰社時」の混在）。
- [ ] **ユーザー削除時の扱い**: `dependent: :restrict_with_error` により、チェック記録のあるユーザーは削除できない。記録を消す方向への変更は法令上の記録保持に関わるので慎重に扱う。

## 2. 権限制御・セキュリティ

- [ ] admin 名前空間のコントローラーは `Admin::BaseController` を継承しているか（`authenticate_user!` と `require_admin` がそこで効く）。`ApplicationController` を直接継承していたら🔴。
- [ ] 一般ユーザー向けコントローラーに `before_action :authenticate_user!` があるか。
- [ ] 一般ユーザー向けアクションで、`params[:id]` 等から他人のレコードを取得・更新できないか（`current_user.alcohol_checks` 経由で絞っているか）。
- [ ] `user` はパラメータではなく `current_user` から設定しているか。
- [ ] Strong Parameters で permit してはいけないもの:
  - `alcohol_check_params`: `user_id`, `checked_on`（本人・当日の偽装になる）
  - `user_params`: 一般ユーザー向けの経路で `role` を permit すると権限昇格になる（admin 用コントローラーでは permit してよい）
- [ ] ビューでリンクを隠しているだけで、コントローラー側の権限チェックがない箇所はないか。
- [ ] CSV出力: ユーザー入力由来の値（氏名など）が `=`, `+`, `-`, `@` で始まるとExcelで式として解釈される（CSVインジェクション）。
- [ ] `ENV.fetch` など、未設定時に例外になる箇所の扱いが意図どおりか。
- [ ] `html_safe` / `raw` の使用（XSS）。

## 3. モデル規約

- [ ] enum は `enum :name, value1: 0, value2: 1` 記法（旧 `enum name: { ... }` は🟡）。
- [ ] 独自バリデーションと `before_validation` 等のコールバックは private セクションに置く。
- [ ] エラーメッセージは日本語で直接書く（locale ファイルは使っていない）。例: `errors.add(:checker, "は本人以外を選択してください")`。
- [ ] バリデーションを追加したら、対応するDB制約（`null: false`, unique index など）も検討されているか。

## 4. コントローラー規約

- [ ] 認証・認可は `before_action`。
- [ ] Strong Parameters は `#{リソース名}_params` という private メソッド名。
- [ ] public アクションが先、`private` 以下にヘルパー。
- [ ] 同じ private メソッドの重複（例: `parse_date` が `Admin::AlcoholChecksController` と `Admin::DashboardController` に重複）は🟡。`Admin::BaseController` か concern への切り出しを提案する。
- [ ] 一覧で関連を表示するなら `includes` で N+1 を回避しているか。
- [ ] 失敗時は `render ..., status: :unprocessable_entity`。
- [ ] 新リソースのルーティングは、admin 名前空間の有無で権限を分離するパターンに従っているか。

## 5. ビュー規約

- [ ] Tailwind のユーティリティクラスを `class:` に直接書く（独自のコンポーネントCSSクラスは使わない）。
- [ ] フォームヘルパーの引数が多い場合、キーワード引数ごとに改行してインデントを揃える（`dashboard/index.html.erb` の `f.collection_select` 参照）。
- [ ] 管理者向けリンクを `current_user.admin?` で出し分けている場合も、コントローラー側の制御があるか（→ 2章）。

## 6. テスト規約

- [ ] `test "日本語の説明文" do ... end` 形式で、説明文が仕様を表しているか。
- [ ] `setup do` ブロックで fixture（`users(:one)` 等）からインスタンス変数を用意しているか。
- [ ] 1テスト1仕様。
- [ ] 正常系と異常系（バリデーション違反、権限違反、未ログイン）がペアになっているか。
- [ ] 業務ルール（二重登録防止、権限制御）がモデルテストとコントローラー/統合テストの**両方**でカバーされているか。
- [ ] DB制約のテストは `save!(validate: false)` と `assert_raises ActiveRecord::RecordNotUnique` のパターン（`alcohol_check_test.rb` 参照）。
