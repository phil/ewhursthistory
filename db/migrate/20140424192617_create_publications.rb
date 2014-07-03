class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|

      t.timestamps

      t.string :title
      t.text :description
    end
  end
end
