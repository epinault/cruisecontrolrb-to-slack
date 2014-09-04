# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cruisecontrolrb-to-slack/version'

Gem::Specification.new do |spec|
  spec.name          = "cruisecontrolrb-to-slack"
  spec.version       = CruisecontrolrbToSlack::VERSION
  spec.authors       = ["epinault"]
  spec.email         = ["emmanuel.pinault@zumobi.com"]
  spec.summary       = %q{A simple daemon to report last build status of projects and activities from cruisecontrol into Slack}
  spec.description   = %q{A simple daemon to report last build status of projects and activities from cruisecontrol into the awesome Slack (http://slack.com). It support multiple projects}
  spec.homepage      = "http://github.com/epinault/cruisecontrolrb-to-hipchat"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 1.9.3'
  
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "dante", "~> 0.2.0"
  spec.add_dependency "slack-notifier", "~> 0.6.0"
  spec.add_dependency "nokogiri", "~> 1.6.2"  
  spec.add_dependency "httparty", "~> 0.13.1"
  spec.add_dependency "rufus-scheduler"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
