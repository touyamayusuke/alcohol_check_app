class AddUniqueIndexToAlcoholChecks < ActiveRecord::Migration[8.1]
  def change
    add_index :alcohol_checks,
              [:user_id, :check_type, :checked_on],
              unique: true,
              name: "index_alcohol_checks_on_user_type_and_date"
  end
end
