## コーディング規約

### Rubocop（rubocop-rails-omakase）

- スタイルの正はRubocopの設定（`.rubocop.yml`）。コミット前に`bin/rubocop -a`で自動修正し、`bin/rubocop`で警告が出ないことを確認する。
- 文字列はダブルクォートを使う（`Style/StringLiterals`）。既存コード（`user.rb`の`class_name: 'User'`等）に違反箇所が残っているが、新規に書くコードでは踏襲しない。
- 配列リテラルの角括弧内にスペースを入れる（`Layout/SpaceInsideArrayLiteralBrackets`）: `%i[ mri windows ]`のようにGemfileで使われている書き方に合わせる。

### エラーメッセージ・国際化

- `config/locales`にActiveRecordのバリデーションメッセージ用エントリは用意されておらず、エラーメッセージはモデルのバリデーション内に日本語文字列で直接記述している（例: `alcohol_check.rb`の`errors.add(:checker, "は本人以外を選択してください")`）。新しいバリデーションを追加する際もこのパターンに合わせる。

### モデル

- enumはRails 7.1以降のキーワード引数記法`enum :name, value1: 0, value2: 1`を使う（旧来の`enum name: { ... }`は使わない）。
- 独自バリデーション（`validate :method_name`）はprivateメソッドとしてクラス下部にまとめ、`before_validation`系のコールバックも同様にprivateセクションに置く。

### コントローラー

- 認証・認可は`before_action`で行う（`authenticate_user!`、管理者限定アクションには`require_admin`）。ビュー側でリンクを隠すだけでなく、必ずコントローラー側でも権限チェックを行う。
- Strong Parametersは`#{リソース名}_params`という名前のprivateメソッドとして定義する。
- publicなアクションを先に書き、`private`以下にヘルパーメソッド（パラメータ取得、絞り込み用の共通処理など）をまとめる。`Admin::AlcoholChecksController`と`Admin::DashboardController`のように、同じ`parse_date`/`require_admin`が両方に必要な場合は重複を許容せず、共通化を検討する（現状は未共通化のため、触る際はconcernへの切り出しも検討する）。

### ビュー（ERB / Tailwind CSS）

- Tailwindのユーティリティクラスをそのまま`class:`属性に記述するスタイルを使う（コンポーネント化されたCSSクラスは使わない）。
- フォームヘルパーの引数が多い場合は、1つのキーワード引数ごとに改行してインデントを揃える（`dashboard/index.html.erb`の`f.collection_select`等を参照）。

### テスト（Minitest）

- テストは`test "日本語の説明文" do ... end`の形式で書き、説明文は日本語でテスト対象の仕様を明示する。
- `setup do`ブロックでfixture（`users(:one)`等）から必要なインスタンス変数を用意する。
- 1テストにつき1つの仕様を検証し、正常系・異常系（バリデーション違反、権限違反、未ログインなど）をペアで用意する（既存の`alcohol_check_test.rb`、`admin_access_test.rb`のパターンに従う）。
- 業務ルール（二重登録防止、権限制御など）はモデルレベルとコントローラー/統合テストレベルの両方でカバーする。
