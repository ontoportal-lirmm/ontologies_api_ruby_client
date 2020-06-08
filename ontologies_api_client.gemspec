# -*- encoding: utf-8 -*-
# stub: ontologies_api_client 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "ontologies_api_client".freeze
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Paul R Alexander".freeze]
  s.date = "2018-02-21"
  s.description = "Models and serializers for ontologies and related artifacts backed by 4store".freeze
  s.email = ["palexander@stanford.edu".freeze]
  s.files = [".gitignore".freeze, "Gemfile".freeze, "Gemfile.lock".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "lib/ontologies_api_client.rb".freeze, "lib/ontologies_api_client/analytics.rb".freeze, "lib/ontologies_api_client/base.rb".freeze, "lib/ontologies_api_client/collection.rb".freeze, "lib/ontologies_api_client/config.rb".freeze, "lib/ontologies_api_client/http.rb".freeze, "lib/ontologies_api_client/link_explorer.rb".freeze, "lib/ontologies_api_client/middleware/faraday-last-updated.rb".freeze, "lib/ontologies_api_client/middleware/faraday-long-requests.rb".freeze, "lib/ontologies_api_client/middleware/faraday-object-cache.rb".freeze, "lib/ontologies_api_client/middleware/faraday-slices.rb".freeze, "lib/ontologies_api_client/middleware/faraday-user-apikey.rb".freeze, "lib/ontologies_api_client/models/category.rb".freeze, "lib/ontologies_api_client/models/class.rb".freeze, "lib/ontologies_api_client/models/group.rb".freeze, "lib/ontologies_api_client/models/instance.rb".freeze, "lib/ontologies_api_client/models/mapping.rb".freeze, "lib/ontologies_api_client/models/metrics.rb".freeze, "lib/ontologies_api_client/models/note.rb".freeze, "lib/ontologies_api_client/models/ontology.rb".freeze, "lib/ontologies_api_client/models/ontology_submission.rb".freeze, "lib/ontologies_api_client/models/project.rb".freeze, "lib/ontologies_api_client/models/property.rb".freeze, "lib/ontologies_api_client/models/reply.rb".freeze, "lib/ontologies_api_client/models/review.rb".freeze, "lib/ontologies_api_client/models/slice.rb".freeze, "lib/ontologies_api_client/models/user.rb".freeze, "lib/ontologies_api_client/read_write.rb".freeze, "lib/ontologies_api_client/resource_index/resource_index.rb".freeze, "ontologies_api_client.gemspec".freeze, "test/benchmark/http.rb".freeze, "test/console.rb".freeze, "test/models/test_collection.rb".freeze, "test/test_case.rb".freeze]
  s.homepage = "https://github.com/ncbo/ontologies_api_ruby_client".freeze
  s.rubygems_version = "2.5.2.2".freeze
  s.summary = "This library can be used for interacting with a 4store instance that stores NCBO-based ontology information. Models in the library are based on Goo. Serializers support RDF serialization as Rack Middleware and automatic generation of hypermedia links.".freeze
  s.test_files = ["test/benchmark/http.rb".freeze, "test/console.rb".freeze, "test/models/test_collection.rb".freeze, "test/test_case.rb".freeze]

  s.installed_by_version = "2.5.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<oj>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<faraday>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<excon>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<lz4-ruby>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<spawnling>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["~> 4.2.1"])
    else
      s.add_dependency(%q<multi_json>.freeze, [">= 0"])
      s.add_dependency(%q<oj>.freeze, [">= 0"])
      s.add_dependency(%q<faraday>.freeze, [">= 0"])
      s.add_dependency(%q<excon>.freeze, [">= 0"])
      s.add_dependency(%q<lz4-ruby>.freeze, [">= 0"])
      s.add_dependency(%q<spawnling>.freeze, [">= 0"])
      s.add_dependency(%q<activesupport>.freeze, ["~> 4.2.1"])
    end
  else
    s.add_dependency(%q<multi_json>.freeze, [">= 0"])
    s.add_dependency(%q<oj>.freeze, [">= 0"])
    s.add_dependency(%q<faraday>.freeze, [">= 0"])
    s.add_dependency(%q<excon>.freeze, [">= 0"])
    s.add_dependency(%q<lz4-ruby>.freeze, [">= 0"])
    s.add_dependency(%q<spawnling>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, ["~> 4.2.1"])
  end
end
