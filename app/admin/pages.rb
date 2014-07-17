ActiveAdmin.register Page do

  permit_params :title, :body, :parent_id, :label, :published_at

  index do
    Page.top_level.each do |page|
      h2 link_to(page.title, resource_path(page))

      ul do
        page.children.each do |child_page|
          li link_to(child_page.title, resource_path(child_page))
        end
      end

    end
  end

  show do
    raw page.body
  end

  sidebar "details", only: :show do
    dl do
      dt "Label"
      dd page.label

      if page.parent
        dt "Parent"
        dd link_to page.parent.title, resource_path(page.parent)
      end

      if page.children
        dt "Child pages"
        page.children.each do |child_page|
          dd link_to child_page.title, resource_path(child_page)
        end
      end

      dt "Slug"
      dd page.slug

      dt "Published date"
      dd page.published_at
    end
  end
  sidebar "Images", only: :show do 
    text_node link_to("New image", [:new, :admin, page, :image])
    render "images/list", images: page.images
  end

  form do |f|
    f.inputs "Page Details" do
      f.input :title
      f.input :body, as: :html_editor
    end
    f.inputs "Metadata" do
      f.input :parent_id, as: :select, collection: Page.roots.map{|p| [p.title, p.id]}
      f.input :published_at
      f.input :label, label: "Navigation label"
      f.input :slug
    end

    f.actions
  end

end
