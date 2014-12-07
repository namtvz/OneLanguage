class UpdateAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :user_id, :integer
    add_column :attachments, :channel_id, :integer
  end
end
