require_relative  '../test_case'
require 'faraday'
require 'active_support'
require 'active_support/cache'
require_relative '../../lib/ontologies_api_client/middleware/faraday-object-cache'
require 'pry'
require 'benchmark'
require 'webmock'

class FaradayObjectCacheTest < LinkedData::Client::TestCase
  def setup
    WebMock.disable!
    apikey = LinkedData::Client.settings.apikey
    @url = "#{LinkedData::Client.settings.rest_url}/ontologies/SNOMEDCT?apikey=#{apikey}"

    @cache_store = ActiveSupport::Cache::MemoryStore.new
    @app = Faraday.new(url: @url) do |faraday|
      faraday.use Faraday::ObjectCache, store: @cache_store
      faraday.adapter :excon
    end
  end

  def test_cache_hit_for_get_request
    body1, body2 = nil
    # First request should not hit the cache
    time1 = Benchmark.realtime do
      response1 = @app.get
      assert_equal 200, response1.status
      assert uncached?(response1)

      body1 = JSON.parse(response1.body)
    end

    time2 = Benchmark.realtime do
      # Second request should hit the cache
      response2 = @app.get
      assert_equal 304, response2.status
      assert cached?(response2)
      body2 = response2.parsed_body.to_hash.stringify_keys
    end

    assert time2 < time1

    body2.each do |k,v|
      k = "@id" if k.eql?('id')
      k = "@type" if k.eql?('type')

      next if k.eql?('context') || k.eql?('links')

      assert_equal v, body1[k]
    end
  end


  def test_cache_invalidation
    # Make a request and cache the response
    response1 = @app.get
    assert_equal 200, response1.status

    response1 = @app.get
    assert_equal 304, response1.status
    assert cached?(response1)

    # Invalidate the cache
    response2 = @app.get do |req|
      req.headers['invalidate_cache'] = true
    end
    assert_equal 200, response2.status
    assert uncached?(response2)
  end

  def test_cache_expiration
    WebMock.enable!
    WebMock.stub_request(:get, @url)
           .to_return(headers: { 'Cache-Control': "max-age=1" , 'Last-Modified': Time.now.httpdate}, body: {result: 'hello'}.to_json)


    # Make a request and cache the response with a short expiry time
    response1 = @app.get
    assert_equal 200, response1.status

    # Wait for the cache to expire
    sleep 2

    response2 = @app.get

    assert_equal 200, response2.status
    assert uncached?(response2)

    sleep 2

    WebMock.stub_request(:get, @url)
           .to_return(headers: { 'Cache-Control': "max-age=100" , 'Last-Modified': Time.now.httpdate}, body: {result: 'hello'}.to_json)
    @app.get


    # Wait for the cache to expire
    sleep 2

    response2 = @app.get

    assert cached?(response2)

    WebMock.disable!
  end

  def test_cache_last_modified
    WebMock.enable!
    # Make a request with Last-Modified header
    WebMock.stub_request(:get, @url)
           .to_return(headers: { 'Cache-Control': "max-age=1", 'Last-Modified': 3.days.ago.to_time.httpdate}, body: {result: 'hello'}.to_json, status: 304)

    @app.get

    response2 = @app.get
    assert cached?(response2)

    sleep 1

    WebMock.stub_request(:get, @url)
           .to_return(headers: { 'Cache-Control': "max-age=10", 'Last-Modified': 1.days.ago.to_time.httpdate}, body: {result: 'hello'}.to_json, status: 304)

    response2 = @app.get
    assert refreshed?(response2)
    WebMock.disable!
  end


  private
  def cached?(response)
    response.env.response_headers['x-rack-cache'].eql?('hit')
  end

  def uncached?(response)
    response.env.response_headers['x-rack-cache'].eql?('miss')
  end

  def refreshed?(response)
    response.env.response_headers['x-rack-cache'].eql?('fresh')
  end
end
