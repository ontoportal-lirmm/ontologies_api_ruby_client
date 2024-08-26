require 'test-unit'
require_relative '../lib/ontologies_api_client'
require_relative '../config/config'
require 'webmock'

WebMock.allow_net_connect!
module LinkedData
  module Client
    class TestCase < Test::Unit::TestCase
    end
  end
end
