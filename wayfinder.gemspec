# encoding: utf-8

Gem::Specification.new do |s|
  s.name              = "wayfinder"
  s.version           = "0.0.4"
  s.summary           = "Pathfinder RPG character bookkeeping made easy."
  s.description       = "Wayfinder assumes you'll keep your character described in yaml following a set of conventions, all the data points are
      aggregated together to generate a nicely formatted output from the input data, with all the numbers crunched in for you."
  s.authors           = ["PoTe"]
  s.email             = ["pote@tardis.com.uy"]
  s.homepage          = "https://github.com/pote/wayfinder"
  s.files             = ['bin/wayfinder', 'lib/wayfinder.rb']
  s.license           = "MIT"
  s.executables.push("wayfinder")
  s.add_runtime_dependency('box')
  s.add_runtime_dependency('mote')
  s.add_runtime_dependency('clap')
  s.add_runtime_dependency('debugger')
end
