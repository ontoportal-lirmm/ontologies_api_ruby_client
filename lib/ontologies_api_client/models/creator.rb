require_relative "../base"

module LinkedData
  module Client
    module Models
      class Creator < LinkedData::Client::Base
        include LinkedData::Client::ReadWrite
        @media_type = "http://data.ecoportal.org/metadata/Creator"        
      end
    end
  end
end
