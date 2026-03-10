# frozen_string_literal: true

ruby file: ".ruby-version"
source "https://rubygems.org"

gemspec

group :code_quality do
  gem "reek", "~> 6.1"
  gem "simplecov", "~> 0.22", require: false
end

group :development do
  gem "rake", "~> 13.2"
end

group :test do
  gem "minitest", "~> 5.25"
  gem "minitest-reporters", "~> 1.7"
end

group :tools do
  gem "amazing_print", "~> 1.4"
  gem "debug", "~> 1.7"
end

gem "rubocop", "~> 1.75"
gem "rubocop-performance", "~> 1.25"
gem "rubocop-minitest", "~> 0.37"
gem "rubocop-rake", "~> 0.7"
gem "rubocop-shopify", "~> 2.16"
