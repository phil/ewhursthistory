require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"] || "MISSING ID",
    aws_secret_access_key: ENV["AWS_SECRET_KEY"] || "MISSING SECRET",
    region: 'eu-west-1',
    host: 's3-eu-west-1.amazonaws.com'
  }
  config.fog_directory  = "ewhursthistory"
  config.fog_public     = true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
