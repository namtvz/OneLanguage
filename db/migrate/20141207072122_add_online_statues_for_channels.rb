class AddOnlineStatuesForChannels < ActiveRecord::Migration
  def change
    add_column :channels, :owner_online, :boolean, default: false
    add_column :channels, :translator_online, :boolean, default: false
    add_column :channels, :partner_online, :boolean, default: false
  end
end
