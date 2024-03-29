require 'rails_helper'

feature 'Publications', type: :feature do

  background do
    @publication = Publication.create title: "Ewhurst Houses and People", description: <<-TXT
      Ewhurst has a wealth of interesting houses, from medieval timber framed
      cottages to large Victorian 'Arts & Crafts' style houses. 'Ewhurst
      Houses and People' looks at the architecture, history and ownership of
      around 130 houses in the parish and is illustrated with nearly 200
      photographs, drawings and maps. The book is in A4 format and has 144 pages
      and costs £12.50. It is available from Hazelbank Stores or from Ewhurst
      History Society in person, by post, or online.
      TXT
  end

  scenario "Create Publications" do
    pending "admin_login"
    admin_login
  end

  scenario "Viewing" do
    visit root_url

    within "nav" do
      click_on "Publications"
    end

    expect(page).to have_text(@publication.title)
    expect(page).to have_text(@publication.description)
  end

end
