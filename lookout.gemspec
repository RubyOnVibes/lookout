require_relative "lib/lookout/version"

Gem::Specification.new do |spec|
  spec.name        = "lookout"
  spec.version     = Lookout::VERSION
  spec.authors     = ["nativestranger"]
  spec.email       = ["eric@rubyonvibes.com"]
  spec.homepage    = spec.metadata["homepage_uri"]
  spec.summary     = "A full-featured, mountable analytics dashboard for Rails, powered by Ahoy. SQLite & PostgreSQL support."
  spec.description = "Lookout is a fork of Ahoy Captain with SQLite support, continued maintenance, and modern Rails 8 compatibility. Full-featured analytics dashboard with conversion funnels, goals tracking, and beautiful visualizations."
  spec.license     = "MIT"
  
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = "https://github.com/RubyOnVibes/lookout"
  spec.metadata["source_code_uri"] = "https://github.com/RubyOnVibes/lookout"
  spec.metadata["changelog_uri"] = "https://github.com/RubyOnVibes/lookout/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/RubyOnVibes/lookout/issues"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "ransack", ">= 2.3"
  spec.add_dependency "turbo-rails", ">= 1.2"
  spec.add_dependency "view_component", ">= 3.0"
  spec.add_dependency "importmap-rails", ">= 1.0"
  spec.add_dependency "stimulus-rails", ">= 1.1"
  spec.add_dependency "ahoy_matey", ">= 1.1"
  spec.add_dependency "chartkick", ">= 4.0"
  spec.add_dependency "groupdate", ">= 5.0"
  spec.add_dependency "pagy", "~> 9.0"
  spec.add_dependency "rubyzip"
  # Ruby 3.4+ compatibility - these were removed from stdlib
  spec.add_dependency "base64", "~> 0.2"
  spec.add_dependency "bigdecimal", "~> 3.1"
  spec.add_dependency "mutex_m", "~> 0.2"
  spec.add_dependency "observer", "~> 0.1"
  spec.add_dependency "drb", "~> 2.2"
  spec.add_dependency "csv", "~> 3.3"

  spec.add_development_dependency "rails", ">= 6"
  spec.add_development_dependency "sprockets-rails"
  spec.add_development_dependency "better_errors"
  spec.add_development_dependency "binding_of_caller"
  spec.add_development_dependency "sassc"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "pg"
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end

