class PostsController < ApplicationController

  def index
    @posts = Post.news.published.page(params[:page]).to_a

    @latest_post = @posts.shift
    @recent_posts = @posts.shift(3)
    @archive = @posts.shift(15)
  end

  def programme
    @programme_posts = Post.programme
  end

  def show
    @post = Post.find params[:id]
  end

  protected

  def recent_news_posts
    @recent_news_posts ||= Post.news.published.limit(10)
  end
  helper_method :recent_news_posts

end
