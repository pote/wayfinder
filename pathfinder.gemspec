# encoding: utf-8

Gem::Specification.new do |s|
  s.name              = "pathfinder"
  s.version           = "0.0.1"
  s.summary           = "Pathfinder RPG character bookkeeping made easy."
  s.description       = "pathfinder.rb assumes you'll keep your character described in yaml following a set of conventions, all the data points are
      aggregated together to generate a nicely formatted output from the input data, with all the numbers crunched in for you."
  s.authors           = ["PoTe"]
  s.email             = ["pote@tardis.com.uy"]
  s.homepage          = "https://github.com/pote/pathfinder.rb"
  s.files             = ['bin/pathfinder', 'lib/pathfinder.rb']
  s.license           = "MIT"
  s.executables.push("pathfinder")
  s.add_runtime_dependency('box')
  s.add_runtime_dependency('mote')
end
