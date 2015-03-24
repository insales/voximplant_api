$:.push File.expand_path("../lib", __FILE__)
require "voximplant_api/version"

Gem::Specification.new do |s|
  s.name = "voximplant_api"
  s.version = VoximplantApi::VERSION
  s.date = "2014-03-24"
  s.summary = "VoxImplant.com HTTP API client"
  s.description = "VoxImplant.com HTTP API client"
  s.authors = ["Vladimir Shushlin"]
  s.email = 'v.shushlin@insales.ru'
  s.files = ["lib/voximplant_api.rb"]
  s.homepage = "https://github.com/insales/voximplant_api"

  s.add_runtime_dependency "rest-client"
end
