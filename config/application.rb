require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EwhurstHistory
  class Application < Rails::Application
    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      #rewrite   '/wiki/John_Trupiano',  '/john'
      #r301      '/wiki/Yair_Flicker',   '/yair'
      #r302      '/wiki/Greg_Jastrab',   '/greg'
      #r301      %r{/wiki/(\w+)_\w+},    '/$1'
      r301 "/default.asp", "/"
      r301 "/v2/default.asp", "/"

      r301 "/about/ewhurstbriefhistory.php", "/about-ewhurst/a-brief-history-of-ewhurst"
    end
    #
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "London"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
     config.i18n.default_locale = :"en-GB"

  end
end
