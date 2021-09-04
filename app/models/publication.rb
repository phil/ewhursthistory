class Publication < ActiveRecord::Base

  default_scope -> { order "published_on DESC" }

  mount_uploader :cover, ImageUploader
  mount_uploader :download, AttachmentUploader
end
