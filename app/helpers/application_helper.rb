module ApplicationHelper

  def page_title text
    content_for(:page_title) { text || "Ewhurst History Society" }
    text
  end
end
