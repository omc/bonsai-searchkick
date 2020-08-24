# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'bonsai-searchkick'
  spec.version       = '0.0.2'

  spec.authors       = ['Rob Sears', 'Maddie Jones', 'Leo Shue Schuster', 'Nick Zadrozny']
  spec.email         = ['rob@onemorecloud.com', 'maddie@onemorecloud.com', 'leo@onemorecloud.com', 'nick@onemorecloud.com']

  spec.summary       = 'Initialize your Searchkick client with Bonsai.'
  spec.description   = <<-DESCRIPTION
  This gem offers a shim to set up Searchkick to work with a Bonsai
  Elasticsearch cluster. The bonsai-searchkick gem automatically sets up the
  Searchkick client correctly so users don't need to worry about configuring it
  in their code or writing an initializer. Further details and documentation
  can be found on this gem's Github repository.
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
  spec.add_runtime_dependency 'redis', '~> 4.0'
  spec.add_runtime_dependency 'activejob-traffic_control', '> 0'
  spec.add_runtime_dependency 'typhoeus', '> 0'
  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rails', '> 0'
end
# rubocop:enable Metrics/BlockLength
