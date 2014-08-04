class Page < ActiveRecord::Base
  has_ancestry # https://github.com/stefankroes/ancestry

  include Imageable

  TEMPLATES = [
    "world_war_one_index",
    "world_war_one_page"
  ]

  def images_not_in_page
    images.reject{ |image| body.match image.file.path }
  end

  before_validation :set_slug
  before_validation :set_full_path
  before_validation :set_label

  scope :published, ->{ where "published_at IS NOT NULL and published_at <= ?", Time.current}
  scope :top_level, ->{ where ancestry: nil}

  #default_scope ->{ order("published_at")

  def self.for_slug slug
    where(slug: slug).first
  end

  def self.for_path path
    where(full_path: path).first
  end

  def previous_sibling
    siblings.where("id != ? AND published_at < ?", id, published_at).order("published_at ASC").last
  end

  def next_sibling
    siblings.where("id != ? AND published_at > ?", id, published_at).order("published_at ASC").first
  end

  private

  def set_slug
    self.slug ||= self.title.parameterize
  end

  def set_full_path
    parts = Array.new
    parts << self.slug
    parts << self.parent.slug if self.parent
    parts << self.parent.parent.slug if self.parent && self.parent.parent
    self.full_path = "/#{parts.reverse.join("/")}"
  end

  def set_label
    self.label ||= self.title
  end

end
