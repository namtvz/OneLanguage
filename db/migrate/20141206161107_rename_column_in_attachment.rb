class RenameColumnInAttachment < ActiveRecord::Migration
  def change
    remove_column :attachments, :file_file_name
    remove_column :attachments, :file_content_type
    remove_column :attachments, :file_file_size
    remove_column :attachments, :file_updated_at

    change_table(:attachments) do |t|
      t.attachment :data
    end
  end
end
