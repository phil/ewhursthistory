ActiveAdmin.register Post do

  menu label: "Meetings / Events / News"

  permit_params :title, :body, :slug, :published_at, :post_type

  index do
    selectable_column
    column :title
    column :post_type
    column :published_at
    actions
  end

  form do |f|
    f.inputs "Post Details" do
      f.input :title
      f.input :body, as: :html_editor
    end
    f.inputs "Meta Details" do
      f.input :post_type, collection: Post::POST_TYPES, required: true
      f.input :published_at, as: :date_select
    end
    f.actions
  end

end
