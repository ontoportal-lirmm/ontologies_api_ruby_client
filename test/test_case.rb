require 'test-unit'
require 'active_support'
require 'active_support/cache'
require_relative '../lib/ontologies_api_client'
require_relative '../config/config'
require 'webmock'

WebMock.allow_net_connect!

# Set up a cache for testing
CACHE = ActiveSupport::Cache::MemoryStore.new

module LinkedData
  module Client
    class TestCase < Test::Unit::TestCase
      # You can use CACHE in your tests if needed
    end
  end
end
