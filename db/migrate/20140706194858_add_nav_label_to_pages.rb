class AddNavLabelToPages < ActiveRecord::Migration
  def change
    add_column :pages, :label, :string
  end
end
