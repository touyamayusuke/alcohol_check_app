class AddCheckedOnToAlcoholChecks < ActiveRecord::Migration[8.1]
  def change
    add_column :alcohol_checks, :checked_on, :date
  end
end
