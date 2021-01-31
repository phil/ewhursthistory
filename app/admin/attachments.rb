ActiveAdmin.register Attachment do
  permit_params :title, :description, :file, :published_on

  #controller do 
  menu false
  belongs_to :site_page, parent_class: Page
  #end

  #index do
  #  #selectable_column
  #  column :file
  #  #column :published_at
  #  actions
  #end

  action_item :publish, only: :show do
    link_to('Publish', publish_admin_site_page_attachment_path(resource.page, resource), method: :patch) unless resource.published?
  end

  member_action :publish, method: :patch do
    resource.update!(published_on: Time.current)
    redirect_to admin_site_page_attachment_path(resource.page, resource), notice: "Published"
  end


  # controller do
  #   def new

  #   end

  #   def create
  #     @post = Post.new(permitted_params[:post])
  #     if @site_page.save!
  #       redirect_to :
  #     end
  #   end
  # end

  # form do |f|
  #   # f.inputs do
  #   # f.input :parent_id, as: :hidden
  #   # f.input :parent_type, value: "hello"

  #   # end

  #   f.inputs "File Upload" do
  #     f.input :file
  #   end
  # end
end
