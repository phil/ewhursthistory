ActiveAdmin.register Image do
  permit_params :file

  #controller do 
  menu false
  belongs_to :page, polymorphic: true, optional: true
  #end

  index do
    #selectable_column
    column :file
    #column :published_at
    actions
  end
end

__END__
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
    div class: "meta_details" do
      dl do
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
    h1 page.title

    div do
      raw page.body
    end
  end

  #filter :email
  #filter :current_sign_in_at
  #filter :sign_in_count
  #filter :created_at

  form do |f|
    f.inputs "Page Details" do
      f.input :title
      f.input :body, as: :html_editor
    end
    f.inputs "Metadata" do
      f.input :parent_id, as: :select, collection: Page.roots.map{|p| [p.title, p.id]}
      f.input :published_at
      f.input :slug
    end

    #f.inputs do
      #f.has_many :images, :allow_destroy => true, :heading => 'Attached Images', :new_record => true do |cf|
        #cf.input :file
      #end
    #end

    f.actions
  end

end
