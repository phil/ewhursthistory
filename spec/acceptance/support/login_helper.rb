module LoginHelper

  def create_user
    @user = User.create do |user|
      user.email = "admin@example.com"
      user.password = "password"
      user.password_confirmation = "password"
    end
  end

  def admin_login user = nil
    user ||= create_user
    visit "/admin"

    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => 'password'

    click_on "Login"
  end

end
