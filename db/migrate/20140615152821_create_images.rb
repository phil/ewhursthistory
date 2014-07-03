class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.timestamps

      t.integer :parent_id
      t.string :parent_type

      t.string :file
    end
  end
end
