# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'bonsai-searchkick'
  spec.version       = '0.0.0'

  spec.authors       = ['Rob Sears', 'Maddie Jones', 'Leo Shue Schuster', 'Nick Zadrozny']
  spec.email         = ['rob@onemorecloud.com', 'maddie@onemorecloud.com', 'leo@onemorecloud.com', 'nick@onemorecloud.com']

  spec.summary       = 'Initialize your Searchkick client with Bonsai.'
  spec.description   = <<-DESCRIPTION

  DESCRIPTION

  spec.homepage      = 'https://github.com/omc/bonsai-searchkick'
  spec.license       = 'MIT'

  spec.files         = ['lib/bonsai-searchkick.rb',
                        'lib/bonsai/searchkick/railtie.rb']
  spec.require_paths = ['lib']

  # This gem simply requires the listed gems to be installed, the actual version
  # does not matter. `gem build` throws an error if a version range is not
  # specified, so it's set arbitrarily high.
  spec.add_runtime_dependency 'searchkick', '< 99'

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '< 11.0'
end
# rubocop:enable Metrics/BlockLength
