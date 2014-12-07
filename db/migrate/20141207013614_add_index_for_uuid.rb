class AddIndexForUuid < ActiveRecord::Migration
  def change
    add_index :channels, :uuid
  end
end
