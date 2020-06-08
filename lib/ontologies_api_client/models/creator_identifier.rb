require_relative "../base"

module LinkedData
  module Client
    module Models
      class CreatorIdentifier < LinkedData::Client::Base
        include LinkedData::Client::ReadWrite
        @media_type = "http://data.ecoportal.org/metadata/CreatorIdentifier"             
      end
    end
  end
end
