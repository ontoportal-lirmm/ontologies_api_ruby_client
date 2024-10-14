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
            main_thread_locals.each { |key, value| Thread.current[key] = value }
            begin
              HTTP.get(link.call(conn.url_prefix.to_s.chomp('/')), params, connection: conn)
            rescue Exception => e
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
      end

    end
  end
end
