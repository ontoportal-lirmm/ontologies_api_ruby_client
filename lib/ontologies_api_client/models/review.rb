require_relative "../base"

module LinkedData
  module Client
    module Models
      class Review < LinkedData::Client::Base
        include LinkedData::Client::Collection
        include LinkedData::Client::ReadWrite

        @media_type = "http://data.bioontology.org/metadata/Review"
        @include_attrs = "all"

        def self.more_recent_review(r1, r2)
          time1 = r1.created
          time2 = r2.created

          time2 <=> time1 # reversed order
        end

        def self.sort_reviews(reviews)
          reviews.sort { |r1, r2| more_recent_review(r1, r2) }
        end

        def self.sort_reviews!(reviews)
          reviews.sort! { |r1, r2| more_recent_review(r1, r2) }
          reviews
        end
      end
    end
  end
end
