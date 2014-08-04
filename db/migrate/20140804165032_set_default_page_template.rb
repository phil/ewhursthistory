class SetDefaultPageTemplate < ActiveRecord::Migration
  def change
    change_column :pages, :template, :string, default: "default", null: false
  end
end
