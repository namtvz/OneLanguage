class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.integer :owner_id
      t.integer :translator_id
      t.integer :partner_id
      t.string :owner_language
      t.string :partner_language
      t.string :owner_uuid
      t.string :partner_uuid
      t.string :translator_uuid
      t.string :partner_access_code
      t.string :translator_access_code
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end

    add_index :channels, :owner_id
    add_index :channels, :translator_id
    add_index :channels, :partner_id
    add_index :channels, :partner_access_code
    add_index :channels, :translator_access_code
  end
end
