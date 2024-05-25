require_relative 'request_federation'

module LinkedData::Client
  class Analytics
    HTTP = LinkedData::Client::HTTP
    include LinkedData::Client::RequestFederation

    attr_accessor :onts, :date

    def self.all(params = {})
      get(:analytics)
    end

    def self.last_month
      data = self.new
      last_month = DateTime.now.prev_month
      year_num = last_month.year
      month_num = last_month.month
      params = { year: year_num, month: month_num }

      responses = federated_get(params) do |url|
        "#{url}/analytics"
      end

      portals = request_portals
      onts = []
      responses.each_with_index do |portal_views, index|
        next nil if portal_views&.errors

        portal_views = portal_views.to_h

        url = portals[index].url_prefix.to_s.chomp('/')
        portal_views.delete(:links)
        portal_views.delete(:context)
        portal_views.keys.map do |ont|
          views = portal_views[ont][:"#{year_num}"][:"#{month_num}"]
          onts << { ont: "#{url}/ontologies/#{ont}", views: views }
        end
      end

      data.onts = onts.flatten.compact
      data
    end

    private

    def self.get(path, params = {})
      path = path.to_s
      path = "/" + path unless path.start_with?("/")
      HTTP.get(path, params)
    end

  end
end