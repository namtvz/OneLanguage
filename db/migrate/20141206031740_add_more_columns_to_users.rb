class AddMoreColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :is_translator, :boolean, default: false
    add_column :users, :is_guest, :boolean, default: false
  end
end
