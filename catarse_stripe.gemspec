$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_stripe/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_stripe"
  s.version     = CatarseStripe::VERSION
  s.authors     = ["Luxn0va"]
  s.email       = ["lvx.n0va@gmail.com"]
  s.homepage    = "http://github.com/lvxn0va/catarse_stripe"
  s.summary     = "Stripe Payments Integration with Catarse."
  s.description = "Stripe Payments Integration with Catarse crowdfunding platform."

  s.files      = `git ls-files`.split($\)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "activemerchant", ">= 1.17.0"
  s.add_dependency "stripe", :git => 'https://github.com/stripe/stripe-ruby'
  s.add_dependency "omniauth-stripe-connect"
  #s.add_dependency "stripe_event"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
end
