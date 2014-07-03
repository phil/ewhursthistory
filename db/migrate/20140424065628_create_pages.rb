class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|

      t.timestamps

      t.string :title
      t.text :body

      t.datetime :published_at

      t.string :slug
      t.string :full_path
      t.string :ancestry

    end
  end
end
