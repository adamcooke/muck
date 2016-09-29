$:.push File.expand_path("../lib", __FILE__)

require "muck/version"

Gem::Specification.new do |s|
  s.name        = "muck"
  s.version     = Muck::VERSION
  s.authors     = ["Adam Cooke"]
  s.email       = ["adam@atechmedia.com"]
  s.homepage    = "http://adamcooke.io"
  s.licenses    = ['MIT']
  s.summary     = "A tool to handle the backup & storage of remote MySQL databases."
  s.description = "This tool will automatically backup & store MySQL dump files from remote servers."
  s.files = Dir["**/*"]
  s.bindir = "bin"
  s.executables << 'muck'
  s.add_dependency "net-ssh", '>= 3.2', '< 4.0'
end
