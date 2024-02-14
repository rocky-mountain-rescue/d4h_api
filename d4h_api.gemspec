# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "d4h_api"
  spec.version = "0.0.5"
  spec.authors = ["Pawel Osiczko"]
  spec.email = ["p.osiczko@tetrapyloctomy.org"]
  spec.homepage = "https://github.com/rockymountainrescue/d4h_api"
  spec.summary = "D4H API in Ruby"
  spec.license = "Hippocratic-2.1"
  spec.rdoc_options = ["--main", "README.md", "--markup", "tomdoc"]

  spec.metadata = {"label" => "D4H", "rubygems_mfa_required" => "true"}

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = File.open(".ruby-version").read.strip
  spec.add_dependency("refinements", "~> 12.0")
  spec.add_dependency("zeitwerk", "~> 2.6")

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]

  spec.add_dependency("dotenv", "~> 3.0.0")
  spec.add_dependency("faraday", "~> 2.9.0")
end
