class Attachment < ApplicationRecord

  mount_uploader :file, AttachmentUploader

  belongs_to :page


  validates :title, presence: true

  def published?
    published_on.present?
  end

end
