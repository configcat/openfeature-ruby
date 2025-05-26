# frozen_string_literal: true

require_relative "lib/configcat-openfeature-provider/version"

Gem::Specification.new do |spec|
  spec.name = "configcat-openfeature-provider"
  spec.version = ConfigCat::OpenFeature::VERSION
  spec.authors = ["ConfigCat"]
  spec.email = ["developer@configcat.com"]
  spec.licenses = ["MIT"]

  spec.summary = "ConfigCat OpenFeature Provider for Ruby."
  spec.description = "OpenFeature Provider that allows ConfigCat to be used with the OpenFeature Ruby SDK."

  spec.homepage = "https://configcat.com"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/configcat/openfeature-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/configcat/openfeature-ruby/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/configcat/openfeature-ruby/issues"
  spec.metadata["documentation_uri"] = "https://configcat.com/docs/sdk-reference/openfeature/ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "configcat", "~> 8.0.1"
  spec.add_dependency "openfeature-sdk", "~> 0.4.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "standard-performance"
end
