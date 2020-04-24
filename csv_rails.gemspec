# frozen_string_literal: true

require_relative 'lib/csv_rails/version'

Gem::Specification.new do |spec|
  spec.name = 'csv_rails'
  spec.version = CsvRails::VERSION
  spec.authors = ['t-hane']
  spec.email = ['t-hane@gc-story.com']

  spec.summary = 'CSV Converter for Rails'
  spec.description = 'CSV Converter for Rails'
  spec.homepage = 'https://gc-stoyr.com'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/gc-ror'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/gc-ror/csv_rails'
  spec.metadata['changelog_uri'] = 'https://github.com/gc-ror/csv_rails'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
end
