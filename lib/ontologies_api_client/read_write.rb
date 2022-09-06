require 'active_support/core_ext/hash'
require_relative 'utils'

module LinkedData
  module Client
    module ReadWrite
      HTTP = LinkedData::Client::HTTP

      def save(options = {})        
        begin
          resp = HTTP.post(self.class.collection_path, self.to_hash)
          # LOGGER.debug("\n\n ONTOLOGIES_API_RUBY_CLIENT: LinkedData::Client::ReadWrite -> save : \n\n - resp -> #{resp}")
        # cache_refresh_all allow to avoid to refresh everything, to make it faster when saving new submission
        invalidate_cache(options[:cache_refresh_all] == false)
        resp
        rescue => e
          LOGGER.debug("\n\nECCEZIONE! ONTOLOGIES_API_RUBY_CLIENT: LinkedData::Client::ReadWrite - save()  #{e.message}\n#{e.backtrace.join("\n")}")
          raise e
        end
      end

      def update(options = {})
        begin
          values = options[:values] || changed_values()
          return if values.empty?
          resp = HTTP.patch(self.id, values)
        # When updating submission we avoid refreshing all cache to avoid calling /submissions?display=all that takes a lot of time
        invalidate_cache(options[:cache_refresh_all] == false)
        rescue => e
          LOGGER.debug("\n\n ECCEZIONE! ONTOLOGIES_API_RUBY_CLIENT: LinkedData::Client::ReadWrite: #{e.message}\n#{e.backtrace.join("\n")}")
          raise e
        end
        resp
      end

      def update_from_params(params)
        # We want to populate ALL the attributes from the REST
        # service so we know that what we're updating is
        # actually the full object
        all_values = HTTP.get(self.id, include: "all")
        all_values.instance_variables.each do |var|
          self.send("#{var}=", all_values.instance_variable_get(var))
        end

        # Now we override the retrieved attributes with new ones
        params.each do |k,v|
          self.send("#{k}=", v) rescue next
        end
        self
      end

      def changed_values
        begin
          existing = HTTP.get(self.id, include: "all")
          changed_attrs = {}
          self.instance_variables.each do |var|
            var_sym = var[1..-1].to_sym
            next if [:id, :type, :links, :context, :created].include?(var_sym)
            new_value = self.instance_variable_get(var)
            current_value = existing.instance_variable_get(var)
            changed_attrs[var_sym] = new_value unless equivalent?(current_value, new_value)
          end
        rescue => e
          LOGGER.debug("\n\nECCEZIONE! ONTOLOGIES_API_RUBY_CLIENT: LinkedData::Client::changed_values: #{e.message}\n#{e.backtrace.join("\n")}")
          raise e
        end
        changed_attrs
      end

      def delete
        resp = HTTP.delete(self.id)
        invalidate_cache()
        resp
      end

      private

      def equivalent?(current_value, new_value)
        # LOGGER.debug("\n\n----------------------\nONTOLOGIES_API_RUBY_CLIENT: LinkedData::Client::ReadWrite -> equivalent:\n\n    > current_value=#{current_value.inspect}\n\n    > new_value=#{new_value.inspect}")
        begin
          # If we're comparing an existing embedded object
          # then use the id for comparison
          if current_value.is_a?(LinkedData::Client::Base)
            #LOGGER.debug("    > current_value is a LinkedData::Client::Base \n   > current_value= #{current_value}\n   > new_value=#{new_value}")
            result_equivalent = current_value.id.eql?(new_value)
            #LOGGER.debug("    > > equivalent RESULT =#{result_equivalent}")
            return result_equivalent
          end

          # Otherwise, do some complex comparing
          case new_value
          when String
            #LOGGER.debug("    > new_value is a String\n   > current_value= #{current_value}\n   > new_value=#{new_value}")
            result_equivalent = current_value.to_s.eql?(new_value)
            #LOGGER.debug("    > > equivalent RESULT =#{result_equivalent}")
            return result_equivalent
          when Array, Hash
            new_value = nil if new_value.is_a?(Array) && new_value.empty? && current_value.nil?
            if new_value.is_a?(Hash) || (new_value.is_a?(Array) && (new_value.first.is_a?(Hash) || new_value.first.is_a?(OpenStruct)))
              #LOGGER.debug("    > new_value is an Array  && new_value.first is an Hash or OpenStruct")
             
              ordered_current = LinkedData::Client::Utils.order_inner_array_elements(current_value, true, [:id, :type, :links, :context, :created])
              # LOGGER.debug("    > > ordered_current=#{ordered_current}")

              clean_current = LinkedData::Client::Utils.recursive_symbolize_keys(ordered_current, true, [:id, :type, :links, :context, :created])
              # LOGGER.debug("    > > clean_current=#{clean_current}")
             
              # LOGGER.debug("    > > BEFORE elaboration PROVE:   new_value=#{new_value}")
              # LOGGER.debug("    > > BEFORE elaboration PROVE:   new_value.inspect= #{new_value.inspect}")
              # LOGGER.debug("    > > BEFORE elaboration PROVE:   new_value_symbolized: #{LinkedData::Client::Utils.recursive_symbolize_keys(new_value)}")
              #new_value.map{|e| LOGGER.debug("new_value.map: \n    e = #{e}\n   e.to_h = #{e.to_h}")}
              
              #new_value[0].each{ |k,v| LOGGER.debug("new_value[0].each [k,v] = [#{k},#{v}] => #{new_value[0]}")}
                            
              clean_new_to_order = LinkedData::Client::Utils.recursive_symbolize_keys(new_value, true, [:id, :type, :links, :context, :created])
              # LOGGER.debug("    > > clean_new_to_order=#{clean_new_to_order}")
              
              clean_new = LinkedData::Client::Utils.order_inner_array_elements(clean_new_to_order, true, [:id, :type, :links, :context, :created])
              #LOGGER.debug("    > > clean_new=#{clean_new}")
              
              result_equivalent = clean_current.eql?(clean_new) rescue clean_current == clean_new
              # LOGGER.debug("    > > equivalent RESULT =#{result_equivalent}")
              return result_equivalent
            else
              #LOGGER.debug("    > new_value is an Array  OR  Hash:\n   > current_value= #{current_value}\n   > new_value=#{new_value}")
              result_equivalent = current_value.sort.eql?(new_value.sort) rescue current_value == new_value
              #LOGGER.debug("    > > equivalent RESULT =#{result_equivalent}")
              return result_equivalent
            end
          end
          #LOGGER.debug("    > OTHERWISE CASE  > current_value= #{current_value}\n   > new_value=#{new_value}")
          result_equivalent = current_value.sort.eql?(new_value.sort) rescue current_value == new_value
          #LOGGER.debug("    > > equivalent RESULT =#{result_equivalent}")
          return result_equivalent
        rescue => e
          LOGGER.debug("\n\n ECCEZIONE! ONTOLOGIES_API_RUBY_CLIENT: LinkedData::Client::equivalent: #{e.message}\n#{e.backtrace.join("\n")}")
          raise e
        end
      end

      # NEW method Ecoportal
      # clean an annidate hash (hash with array, hash or array of hash)
      def clean_annidate_hash(obj)

      end


      def invalidate_cache(cache_refresh_all = true)
        self.class.all(invalidate_cache: true) if cache_refresh_all
        HTTP.get(self.id, invalidate_cache: true) if self.id
        session = Thread.current[:session]
        session[:last_updated] = Time.now.to_f if session
        refresh_cache
      end

      def refresh_cache
        Spawnling.new do
          LinkedData::Client::Models::Ontology.all
          LinkedData::Client::Models::OntologySubmission.all
          LinkedData::Client::Models::User.all
          exit
        end
      end

    end
  end
end
