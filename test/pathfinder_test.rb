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

  # Other basic stuff should be loaded, like the Armor Class
  # AC = Base (10) + Dexterety Bonus (2)
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

  # Only one of the modifiers should be taken into account.
  assert_equal c.active_stack.count, 1

  # The stack_for 'ac' should take the chain shirt
  # into account, but not the ring.
  assert_equal c.stack_for('ac').count, 1
  assert_equal c.stack_for('ac').first.name, 'Mithril Chain Shirt +2'
  assert_equal c.modifier_for('ac'), 6


  # AC = Base (10) + Dex (2) + Chain Shirt (6)
  assert_equal c.ac, 18
end

test 'modifiers should stack properly' do
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
- name: 'DiBlasi Rapier of Awesome +3'
  active: true
  modifiers:
    to_hit: 3
    damage: 3

- name: 'Weapon Focus (Rapier)'
  active: true
  modifiers:
    to_hit: 1
  ")

  c = Wayfinder::Character.new({
    main: main,
    modifiers: modifiers,
    skills: []
  })

  assert_equal c.stack_for('to_hit').count, 2
  assert_equal c.modifier_for('to_hit'), 4
end

test 'modifiers from the same type should not stack' do
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
- name:   'Prayer'
  active: true
  type: 'morale'
  modifiers:
    will:       1
    fortitude:  1
    reflex:     1
    damage:     1
    to_hit:     1

- name:   'Heroism'
  active: true
  type:  'morale'
  modifiers:
    to_hit:     2
    fortitude:  2
    reflex:     2
    will:       2
    made_up:    1
  ")

  c = Wayfinder::Character.new({
    main: main,
    modifiers: modifiers,
    skills: []
  })

  # Both modifiers should be active
  assert_equal c.stack_for('damage').count, 1
  assert_equal c.stack_for('made_up').count, 1

  # Yet only the greater one should apply to attributes affected
  # by both.
  assert_equal c.stack_for('to_hit').count, 1
  assert_equal c.modifier_for('to_hit'), 2
end

test 'saving throws should work' do
  main = YAML.load("
saving_throws:
  fortitude:  6
  reflex:     8
  will:       7
ability_scores:
  strength: 16
  dexterity: 14
  constitution: 14
  intelligence: 12
  wisdom: 8
  charisma: 16
  ")

  modifiers = YAML.load("
- name:   'Heroism'
  active: true
  type:  'morale'
  modifiers:
    to_hit:     2
    fortitude:  2
    reflex:     2
    will:       2
    made_up:    1
  ")

  c = Wayfinder::Character.new({
    main: main,
    modifiers: modifiers,
    skills: []
  })

  assert_equal c.fortitude, 10
  assert_equal c.reflex,    12
  assert_equal c.will,      8
end

test 'skills should work' do
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
- name: 'Ioun Stone'
  active: true
  modifiers:
    escape_artist: 1
  ")

  skills = YAML.load("
bluff:
  stat: 'charisma'
  ranks: 6
escape_artist:
  class: true
  stat: 'dexterity'
  ranks: 5
   ")

  c = Wayfinder::Character.new({
    main: main,
    modifiers: modifiers,
    skills: skills
  })

  # Basic output should be ranks + ability score modifier.
  assert_equal c.skills.bluff, 9

  # Class skills should have an automatic +3
  # this one in particular is also affected by a modifier.
  assert_equal c.skills.escape_artist, 11
end
