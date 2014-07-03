class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|

      t.timestamps
      t.string :post_type #Newsletter, Programme, News, Event
        
      t.string :title
      t.text :body


      t.datetime :published_at

    end
  end
end
