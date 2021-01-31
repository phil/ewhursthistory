class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|

      t.timestamps

      t.integer :page_id

      t.string :title
      t.text :description

      t.date :published_on

      t.string :file

    end
  end
end
