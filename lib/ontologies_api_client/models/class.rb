require "cgi"
require_relative "../base"
require_relative "../request_federation"

module LinkedData
  module Client
    module Models

      class Class < LinkedData::Client::Base
        HTTP = LinkedData::Client::HTTP
        include LinkedData::Client::RequestFederation
        @media_type = %w[http://www.w3.org/2002/07/owl#Class http://www.w3.org/2004/02/skos/core#Concept]
        @include_attrs = "prefLabel,definition,synonym,obsolete,hasChildren,inScheme,memberOf"
        @include_attrs_full = "prefLabel,definition,synonym,obsolete,properties,hasChildren,childre,inScheme,memberOf"
        @attrs_always_present = :prefLabel, :definition, :synonym, :obsolete, :properties, :hasChildren, :children, :inScheme, :memberOf
        alias :fullId :id

        # triple store predicate is <http://www.w3.org/2002/07/owl#deprecated>
        def obsolete?
          self.obsolete && self.obsolete.to_s.eql?("true")
        end

        def prefLabel(options = {})
          if options[:use_html]
            if obsolete?
              return "<span class='obsolete_class' title='obsolete class'>#{@prefLabel}</span>"
            else
              return "<span class='prefLabel'>#{@prefLabel}</span>"
            end
          else
            return @prefLabel
          end
        end

        # TODO: Implement properly
        def relation_icon(parent)
          return "" if self.explore.ontology.explore.latest_submission.nil?
          return "" unless self.explore.ontology.explore.latest_submission.hasOntologyLanguage.eql?("OBO")
          non_subclassOf_parent_rel = !self.subClassOf ||
              (self.subClassOf && (self.subClassOf.include?("http://www.w3.org/2002/07/owl#Thing") || self.subClassOf.include?(parent.id)))
          return "" if non_subclassOf_parent_rel
          " <span class='ui-icon ui-icon-info' style='display: inline-block !important; vertical-align: -4px; cursor: help;' title='The parent of this class is not defined with a subClassOf relationship'></span>"
        end

        def to_jsonld
          HTTP.get(self.links["self"], {}, {raw: true})
        end

        def purl
          return "" if self.links.nil?
          return self.id if self.id.include?("purl.")
          ont = self.explore.ontology
          "#{LinkedData::Client.settings.purl_prefix}/#{ont.acronym}?conceptid=#{CGI.escape(self.id)}"
        end

        def ontology
          self.explore.ontology
        end

        def self.find(id, ontology, params = {})
          ontology = HTTP.get(ontology, params)
          ontology.explore.class(CGI.escape(id))
        end

        def self.search(*args)
          query = args.shift

          params = args.shift || {}

          params[:q] = query

          raise ArgumentError, "You must provide a search query: Class.search(query: 'melanoma')" if query.nil? || !query.is_a?(String)


          search_result = federated_get(params) do |url|
            "#{url}/search"
          end
          merged_collections = {collection: [], errors: []}
          search_result.each do |result|
            if result.collection
              merged_collections[:collection].concat(result.collection)
            elsif result.errors
              merged_collections[:errors] << result.errors
            end
          end
          OpenStruct.new(merged_collections)

        end

        def expanded?
          !self.children.nil? && self.children.length > 0
        end

      end
    end
  end
end
