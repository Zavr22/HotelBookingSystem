# -*- encoding: utf-8 -*-
# stub: rails_current 2.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_current".freeze
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ara T. Howard".freeze]
  s.date = "2020-10-23"
  s.description = "track 'current_user' et all in a tidy, global, and thread-safe fashion for your rails apps".freeze
  s.email = "ara.t.howard@gmail.com".freeze
  s.homepage = "https://github.com/ahoward/rails_current".freeze
  s.licenses = ["Ruby".freeze]
  s.rubygems_version = "3.4.12".freeze
  s.summary = "rails_current".freeze

  s.installed_by_version = "3.4.12" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<map>.freeze, ["~> 6.0"])
end
