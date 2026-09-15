class CreateAlcoholChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :alcohol_checks do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :check_type, null: false
      t.decimal :alcohol_value, precision: 4, scale: 2, null: false
      t.references :checker, null: false, foreign_key: { to_table: :users }
      t.boolean :used_detector, null: false, default: true

      t.timestamps
    end
  end
end
