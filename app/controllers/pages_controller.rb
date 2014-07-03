class PagesController < ApplicationController

  def show
    #raise params.inspect
    @page = Page.for_path("/#{params[:path]}")
    render @page.template || :show
  end

end
