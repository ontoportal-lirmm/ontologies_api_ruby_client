require 'active_support/core_ext/hash'

module LinkedData
  module Client
    module RequestFederation

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def federated_get(params = {}, &link)
          portals = request_portals(params)
          main_thread_locals = Thread.current.keys.map { |key| [key, Thread.current[key]] }.to_h

          connections = Parallel.map(portals, in_threads: portals.size) do |conn|
            portal_name = portal_name_from_id(conn.url_prefix.to_s)
            portal_status = true

            unless Rails.cache.read("federation_portal_up_#{portal_name}").nil?
              portal_status = Rails.cache.read("federation_portal_up_#{portal_name}")
            end

            unless portal_status
              HTTP.log("Error in federation #{portal_name} is down status cached for 10 minutes")
              next [OpenStruct.new(errors: "Problem retrieving #{portal_name}")]
            end

            main_thread_locals.each { |key, value| Thread.current[key] = value }
            begin
              portal_params = params[portal_name.to_s.downcase] || params
              HTTP.get(link.call(conn.url_prefix.to_s.chomp('/')), portal_params, connection: conn)
            rescue Exception => e
              HTTP.log("Error in federation #{portal_name} is down status cached for 10 minutes")
              Rails.cache.write("federation_portal_up_#{portal_name}", false, expires_in: 10.minutes) unless internal_call?(conn)
              [OpenStruct.new(errors: "Problem retrieving #{link.call(conn.url_prefix.to_s.chomp('/')) || conn.url_prefix}")]
            end
          end

          connections.flatten
        end



        def federated_portals_names(params = {})
          params[:federate] || ::RequestStore.store[:federated_portals]
        end

        def request_portals(params = {})
          federate = federated_portals_names(params)
          portals = [LinkedData::Client::HTTP.conn]
          params.delete(:federate)

          if federate.is_a?(Array)
            portals += LinkedData::Client::HTTP.federated_conn
                                               .select { |portal_name, _| federate.include?(portal_name) || federate.include?(portal_name.to_s) }
                                               .values
          elsif !federate.blank? # all
            portals += LinkedData::Client::HTTP.federated_conn.values
          end

          portals
        end

        def internal_call?(conn)
          conn.url_prefix.to_s.start_with?(LinkedData::Client::HTTP.conn.url_prefix.to_s)
        end

        def portal_name_from_id(id)
          LinkedData::Client::HTTP.federated_conn.find { |_, value| value.url_prefix.to_s.eql?(id) }&.first || ''
        end
      end

    end
  end
end
