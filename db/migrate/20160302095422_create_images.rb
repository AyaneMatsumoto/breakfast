class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :url
      t.string :description
      t.string :tags
      t.timestamps null:false
    end
  end
end
