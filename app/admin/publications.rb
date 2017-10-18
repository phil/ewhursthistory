ActiveAdmin.register Publication do
  permit_params :title, :published_at, :description, :cover

  index do
    selectable_column
    column :title
    column :published_on
    actions
  end

  show do
    div do
      raw publication.description
    end
  end

  sidebar "Cover", only: :show do
      image_tag publication.cover.url(:large)
  end

  #filter :email
  #filter :current_sign_in_at
  #filter :sign_in_count
  #filter :created_at

  form do |f|
    f.inputs "Publication Details" do
      f.input :title
      f.input :published_on, label: "Publication date"
      f.input :description, as: :html_editor
    end
    f.inputs "Images" do
      content_tag(:div, image_tag(f.object.cover.url(:small)))
      f.input :cover #, as: :file
    end
    f.actions
  end

end
