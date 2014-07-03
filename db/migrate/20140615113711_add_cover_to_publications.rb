class AddCoverToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :cover, :string
  end
end
