require 'active_support/core_ext/hash'
require 'active_support/cache'

module LinkedData
  module Client
    module RequestFederation

      CACHE = ActiveSupport::Cache::MemoryStore.new

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

            unless CACHE.read("federation_portal_up_#{portal_name}").nil?
              portal_status = CACHE.read("federation_portal_up_#{portal_name}")
            end

            unless portal_status
              next [OpenStruct.new(errors: "Problem retrieving #{portal_name}")]
            end

            main_thread_locals.each { |key, value| Thread.current[key] = value }
            begin
              HTTP.get(link.call(conn.url_prefix.to_s.chomp('/')), params, connection: conn)
            rescue Exception => e
              CACHE.write("federation_portal_up_#{portal_name}", false, expires_in: 10.minutes)
              [OpenStruct.new(errors: "Problem retrieving #{link.call(conn.url_prefix.to_s.chomp('/')) || conn.url_prefix}")]
            end
          end

          connections.flatten
        end



        def request_portals(params = {})
          federate = params.delete(:federate) || ::RequestStore.store[:federated_portals]

          portals = [LinkedData::Client::HTTP.conn]

          if federate.is_a?(Array)
            portals += LinkedData::Client::HTTP.federated_conn
                                               .select { |portal_name, _| federate.include?(portal_name) || federate.include?(portal_name.to_s) }
                                               .values
          elsif !federate.blank? # all
            portals += LinkedData::Client::HTTP.federated_conn.values
          end

          portals
        end


        def portal_name_from_id(id)
          LinkedData::Client::HTTP.federated_conn.find { |_, value| value.url_prefix.to_s.eql?(id) }&.first || ''
        end
      end

    end
  end
end
