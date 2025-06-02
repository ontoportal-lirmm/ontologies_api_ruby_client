require_relative "../base"

module LinkedData
  module Client
    module Models
      class SemanticArtefactCatalog < LinkedData::Client::Base
        include LinkedData::Client::Collection
        include LinkedData::Client::ReadWrite

        @media_type = "https://w3id.org/mod#SemanticArtefactCatalog"
      end
    end
  end
end
