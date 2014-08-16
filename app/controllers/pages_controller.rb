class PagesController < ApplicationController

  def show
    if @page = Page.for_path("/#{params[:path]}")
      render @page.template
    else
      render_404
    end
  end

end
