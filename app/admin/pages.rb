ActiveAdmin.register Page, as: "SitePage" do

  permit_params :title, :body, :parent_id, :label, :published_at, :template,
    :attachments_attributes

  index do
    Page.top_level.each do |page|
      h2 link_to(page.title, resource_path(page)), style: "margin-top: 2em"
      #text_node content_tag :p, link_to("New #{content_tag :em, page.title} page".html_safe, new_resource_path)

      unless page.children.empty?
        table do
          thead do
            tr do
              th "#{content_tag :em, page.title} sub pages".html_safe
              th "Published"
              th "Page Template"
            end
          end

          page.children.each do |child_page|
            tr do
              td link_to(child_page.title, resource_path(child_page))
              td child_page.published_at, style: "width: 20%"
              td child_page.template, style: "width: 20%"
            end
          end
        end
      end
    end

  end

  show do
    div do
      raw site_page.body
    end

    h2 "Attachments"

    site_page.attachments.each do |attachment|
      hr

      h3 do 
        text_node attachment.title
         status_tag "un-published" if attachment.published_on.blank?
      end

      div do
        text_node link_to("Edit", admin_site_page_attachment_path(attachment.page, attachment)) + " | " + link_to("Download", attachment.file.url)

        div do
          attachment.description
        end
      end

    end
  end

  sidebar "details", only: :show do
    dl do
      dt "Label"
      dd site_page.label

      if site_page.parent
        dt "Parent"
        dd link_to site_page.parent.title, resource_path(site_page.parent)
      end

      if site_page.children
        dt "Child pages"
        site_page.children.each do |child_page|
          dd link_to child_page.title, resource_path(child_page)
        end
      end

      dt "Slug"
      dd site_page.slug

      dt "Template"
      dd site_page.template

      dt "Published date"
      dd site_page.published_at
    end
  end

  sidebar "Images", only: :show do 
    text_node link_to("New image", new_admin_site_page_image_path(site_page)) #[:new, :admin, site_page, :image])
    render "images/list", images: site_page.images
  end

  sidebar "Attachments", only: :show do
    text_node link_to("New attachment", new_admin_site_page_attachment_path(site_page)) #[:new, :admin, site_page, :image])
  end

  form do |f|
    f.inputs "Page Details" do
      f.input :title
      f.input :body, as: :html_editor
    end
    f.inputs "Metadata" do
      f.input :parent_id, as: :select, collection: Page.roots.map{|p| [p.title, p.id]}
      f.input :template, as: :select, collection: Page::TEMPLATES
      f.input :published_at
      f.input :label, label: "Navigation label"
      f.input :slug
    end

    f.actions
  end

end
