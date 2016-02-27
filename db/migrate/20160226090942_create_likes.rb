class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string :title
      t.string :url
      t.string :description
      t.string :tags
      t.string :user_id
      t.timestamps null:false
    end
  end
end
