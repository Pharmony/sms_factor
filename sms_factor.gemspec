# frozen_string_literal: true

Gem::Specification.new do |s| # rubocop:disable Gemspec/RequireMFA
  s.name          = 'sms_factor'
  s.version       = '0.2.2'
  s.summary       = 'An easy way to send SMS through SmsFactor API'
  s.description   = 'An easy way to use API SMS from http://www.smsfactor.com/ (http://www.smsfactor.com/api-sms)'
  s.authors       = ['Julien Séveno']
  s.email         = 'jseveno@gmail.com'
  s.files         = Dir['lib/**/*', 'LICENSE', 'README.md']
  s.homepage      = 'https://github.com/juseveno/sms_factor'
  s.licenses      = ['LGPL']
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.required_ruby_version = ">= #{ENV.fetch('RUBY_VERSION', '2.7')}"

  if Gem::Version.new(ENV.fetch('RUBY_VERSION', '2.7')) < Gem::Version.new('3.0')
    s.add_runtime_dependency 'nokogiri', '~> 1.13', '< 1.14'
  else
    s.add_runtime_dependency 'nokogiri', '~> 1.14'
  end
  s.add_runtime_dependency 'dry-struct', '~> 1.6'
  s.add_runtime_dependency 'dry-types', '~> 1.7'
  s.add_runtime_dependency 'rest-client', '~> 2.0.2', '>= 2.0.2'
end
