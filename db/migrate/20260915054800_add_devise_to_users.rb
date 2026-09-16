class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :password_digest, :string

    add_column :users, :encrypted_password, :string,
               null: false,
               default: ""
  end
end
