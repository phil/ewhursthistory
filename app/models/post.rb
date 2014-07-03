class Post < ActiveRecord::Base

  POST_TYPES = ["News", "Meeting", "Event"]

  #default_scope { order "published_at DESC" }
  scope :published, -> { where "published_at IS NOT NULL AND published_at <= ?", Time.current  }
  scope :future, -> { where "published_at >= ?", Time.current }

  # Past posts
  scope :news, -> { published.where(post_type: "News").order("published_at DESC") }
  scope :meetings, -> { future.where(post_type: "Programme").order("published_at ASC") }
  # future posts
  scope :events, -> { future.where(post_type: "Programme").order("published_at ASC") }

  def self.next_meeting
    self.meetings.first
  end
  def self.next_events
    self.events
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

  private

end