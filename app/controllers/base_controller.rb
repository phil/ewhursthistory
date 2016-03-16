class BaseController < ApplicationController

  def index
    @current_first_world_war_page = Page.where(slug: "ewhurst-in-the-great-war").first&.children&.published&.last
    @posts = Post.news.published.limit(1)
    @publications = Publication.all
    @next_meeting = Post.next_meeting
    @next_events = Post.next_events
  end

  private

  def nav_class
    
  end

end
