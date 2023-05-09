# -*- encoding: utf-8 -*-
# stub: graphql-query-resolver 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "graphql-query-resolver".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["nettofarah".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-05-26"
  s.description = "GraphQL::QueryResolver is an add-on to graphql-ruby that allows your field resolvers to minimize N+1 SELECTS issued by ActiveRecord. ".freeze
  s.email = ["nettofarah@gmail.com".freeze]
  s.homepage = "https://github.com/nettofarah".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.12".freeze
  s.summary = "Minimize N+1 queries generated by GraphQL".freeze

  s.installed_by_version = "3.4.12" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<graphql>.freeze, ["~> 1.0", ">= 1.0.0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.11"])
  s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3", ">= 1.3.12"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.1.0", ">= 2.1.0"])
  s.add_development_dependency(%q<byebug>.freeze, ["~> 9.0.6", ">= 9.0.6"])
  s.add_development_dependency(%q<activerecord>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
end