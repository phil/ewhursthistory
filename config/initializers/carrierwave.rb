require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"] || "MISSING ID",                        # required
    :aws_secret_access_key  => ENV["AWS_SECRET_KEY"] || "MISSING SECRET",                        # required
  }
  config.fog_directory  = "ewhursthistory"# required
  config.fog_public     = true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
