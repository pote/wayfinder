require File.expand_path("../lib/wayfinder", File.dirname(__FILE__))
require 'yaml'

test 'load basic ability scores and stats' do
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

  ## Ability scores should be accessible from the character
  assert_equal c.strength, 16
  assert_equal c.wisdom, 8

  ## Ability score modifiers should be accurate
  assert_equal c.strength_modifier, 3
  assert_equal c.wisdom_modifier, -1

  ## Other basic stuff should be loaded, like the Armor Class
  ## AC = Base (10) + Dexterety Bonus (2)
  assert_equal c.ac, 12
end

test 'modifiers are applied (or not) appropriately' do
  main = YAML.load("
ability_scores:
  strength: 16
  dexterity: 14
  constitution: 14
  intelligence: 12
  wisdom: 8
  charisma: 16
  ")

  modifiers = YAML.load("
- name: 'Mithril Chain Shirt +2'
  active: true
  modifiers:
    ac: 6

- name: 'Ring of Protection'
  type: 'deflection'
  active: false
  modifiers:
    ac: 2
  ")

  c = Wayfinder::Character.new({
    main: main,
    modifiers: modifiers,
    skills: []
  })

  ## Only one of the modifiers should be taken into account.
  assert_equal c.active_stack.count, 1

  ## The stack_for 'ac' should take the chain shirt
  ## into account, but not the ring.
  assert_equal c.stack_for('ac').count, 1
  assert_equal c.stack_for('ac').first.name, 'Mithril Chain Shirt +2'

  # AC = Base (10) + Dex (2) + Chain Shirt (6)
  assert_equal c.ac, 18
end
