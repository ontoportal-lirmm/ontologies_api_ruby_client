# config.rb is required for testing
# unit test makes calls to bioportal api so it needs a valid API key which can
# be set via ENV variable UT_APIKEY
abort('UT_APIKEY env variable is not set. Canceling tests') unless ENV.include?('UT_APIKEY')
abort('UT_APIKEY env variable is set to an empty value. Canceling tests') unless ENV['UT_APIKEY'].size > 5
$API_CLIENT_INVALIDATE_CACHE = false
$DEBUG_API_CLIENT = false
LinkedData::Client.config do |config|
  config.rest_url   = 'https://data.bioontology.org'
  config.apikey     = ENV['UT_APIKEY']
#  config.apikey     = 'xxxxx-xxxxx-xxxxxxxxxx'
  config.links_attr = 'links'
  config.cache      = false
end
