require File.expand_path("../lib/wayfinder", File.dirname(__FILE__))
require 'yaml'

test 'load basic ability scores' do
  main = YAML.load("
ability_scores:
  strength: 16
  dexterity: 14
  constitution: 14
  intelligence: 12
  wisdom: 8
  charisma: 16
  ")

  c = Wayfinder::Character.new({
    main: main,
    modifiers: [],
    skills: []
  })

  assert_equal c.strength, 16
  assert_equal c.wisdom, 8
end
