class Image < ActiveRecord::Base

  mount_uploader :file, ImageUploader

  belongs_to :parent, polymorphic: true

end
