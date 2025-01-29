require 'test-unit'
require 'logger'
require 'active_support'
require 'active_support/logger'
require 'active_support/cache'
require_relative '../lib/ontologies_api_client'
require_relative '../config/config'
require 'webmock'

WebMock.allow_net_connect!

Logger = ::Logger unless defined?(Logger)
CACHE = ActiveSupport::Cache::MemoryStore.new

module LinkedData
  module Client
    class TestCase < Test::Unit::TestCase
    end
  end
end
