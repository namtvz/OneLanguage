class AddOwnerOfflineAt < ActiveRecord::Migration
  def change
    add_column :channels, :offline_at, :datetime
  end
end
