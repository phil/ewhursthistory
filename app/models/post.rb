class Post < ActiveRecord::Base

  POST_TYPES = ["News", "Meeting", "Event"]

  #default_scope { order "published_at DESC" }
  scope :published, -> { where "published_at IS NOT NULL AND published_at <= ?", Time.current  }
  scope :future, -> { where "published_at >= ?", Time.current }

  # Past posts
  scope :news, -> { published.where(post_type: "News").order("published_at DESC") }
  # future posts
  scope :meetings, -> { where(post_type: "Meeting").order("published_at ASC") }
  scope :events, -> { where(post_type: "Event").order("published_at ASC") }

  def self.next_meeting
    self.meetings.future.first
  end

  def self.next_events
    self.events.future
  end

  def self.programme(for_date = Date.current)
    programme_starts_on = case for_date.month
    when 0..8
      Date.new(for_date.year - 1, 9, 1)
    else
      Date.new(for_date.year, 9, 1)
    end

    programme_ends_on = ((programme_starts_on + 1.year) - 1.day)

    where(published_at: (programme_starts_on..programme_ends_on)).where(post_type: ["Meeting", "Event"]).order("published_at ASC")
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

end
