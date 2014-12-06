class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.integer :user_id
      t.string :language
      t.timestamps
    end
  end
end
