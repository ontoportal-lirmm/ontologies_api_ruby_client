require_relative '../test_case'
require 'pry'

class LinkExploreTest < LinkedData::Client::TestCase

  def test_explore
    sub_direct_explore = LinkedData::Client::Models::Ontology.explore('MEDDRA').latest_submission(include: 'all')
    sub_indirect_explore = LinkedData::Client::Models::Ontology.find('MEDDRA').explore.latest_submission
    sub_direct_explore.to_hash.each do |key, value|
      value_to_compare = sub_indirect_explore[key]
      if value.class.ancestors.include?(LinkedData::Client::Base)
        value = value.to_hash
        value_to_compare = value_to_compare.to_hash
      end
      assert_equal value, value_to_compare
    end
  end

end
