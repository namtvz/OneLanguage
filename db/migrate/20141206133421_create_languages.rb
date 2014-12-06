class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
