class PagesController < ApplicationController

  def show
    @page = Page.for_path("/#{params[:path]}")
    render @page.template
  end

end
