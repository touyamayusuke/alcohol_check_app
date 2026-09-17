class AddNotNullToCheckedOn < ActiveRecord::Migration[8.1]
  def change
    change_column_null :alcohol_checks, :checked_on, false
  end
end
