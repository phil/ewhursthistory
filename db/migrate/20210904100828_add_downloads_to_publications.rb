class AddDownloadsToPublications < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :download, :string
  end
end
