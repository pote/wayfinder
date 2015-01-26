require 'hashdot'

module Wayfinder
  BASE_STATS = %w(strength dexterity constitution wisdom charisma intelligence)

  class Character

    ## :source_data must be a hash with the following keys, each containing the data of
    ## its corresponding yaml file.
    #
    #  * main         - contains hp, base attack bonus, saving throws, xp, name,
    #                   basic stats, str, dex, con, wis, int and cha.
    #
    #  * modifiers    - contains descriptions of items, feats, magical effects, or
    #                   any other thing that modifies character attributes.
    #
    #  * skills       - skills contain data on the ranks and associated stats for
    #                   each given skill.

    attr_accessor :source_data

    def initialize(source_data = {})
      self.source_data = source_data
    end

    BASE_STATS.each do |base_stat|
      define_method(base_stat) do
        base_ability_scores[base_stat] + modifier_for(base_stat)
      end

      define_method("#{ base_stat }_modifier") do
        stat = base_ability_scores[base_stat] + modifier_for(base_stat)
        (stat - 10) / 2
      end
    end

    def base_ability_scores
      source_data.main.ability_scores
    end

    def base_saving_throws
      source_data.main.saving_throws
    end

    def fortitude
      base_saving_throws.fortitude + constitution_modifier + modifier_for('fortitude')
    end

    def reflex
      base_saving_throws.reflex + dexterity_modifier + modifier_for('reflex')
    end

    def will
      base_saving_throws.will + wisdom_modifier + modifier_for('will')
    end

    def saving_throws
      {
        fortitude:  fortitude,
        reflex:     reflex,
        will:       will
      }
    end

    ## Returns an array of items in the modifier stack marked with 'active: true'
    def active_stack
      source_data.modifiers.keep_if { |item| item.active }
    end

    ## Returns an array of object who affect the specified attribute
    def stack_for(attribute)
      applicable_stack = []

      # TODO:
      # Bonuses of the same type do not stack, we need to pick the biggest one
      # and only apply that.

      active_stack.keep_if { |item|
        item.fetch('modifiers', {}).keys.include?(attribute)
      }

      applicable_stack
    end

    ## Outputs the final numeric modifier for the specified attribute.
    def modifier_for(attribute)
      modifier = 0

      stack_for(attribute).each do |mod|
        modifier += mod.fetch('modifiers', {}).fetch(attribute, 0)
      end

      modifier
    end

    def name
      source_data.main.name
    end

    def xp
      source_data.main.xp
    end

    def hp
      source_data.main.hp + modifier_for('hp')
    end

    def received_damage
      source_data.main.received_damage
    end

    def current_hp
      hp - received_damage
    end

    def speed
      30 + modifier_for('speed')
    end

    def initiative
      dexterity_modifier + modifier_for('initiative')
    end

    def bab
      source.main.bab
    end

    def to_hit(base_attack = self.bab)
      base_attack + strength_modifier + modifier_for('to_hit')
    end

    def damage
      strength_modifier + modifier_for('damage')
    end

    def full_attack
      attack_babs = [bab]

      ## Fuck yeah I used a while in ruby, fuck you, fuck everything, EVERYTHING.
      while attack_babs.last - 5 >= 1
        attack_babs << attack_babs.last - 5
      end

      attack_babs.map { |attack| to_hit(attack) }
    end

    def ac
      10 + dexterity_modifier + modifier_for('ac')
    end

    def cmd
      10 + bab + strength_modifier + dexterity_modifier + modifier_for('cmd')
    end

    def cmb
      10 + bab + strength_modifier + modifier_for('cmd')
    end

    def damage_reduction
      0 + modifier_for('damage_reduction')
    end

    def skill(skill_name)
      skill = source_data.skills.fetch(skill_name, {})

      computed_score = skill.fetch('ranks', 0) +
                       self.send("#{ skill['stat'] }_modifier") +
                       modifier_for(skill_name) +
                       modifier_for('all_skills')

      computed_score += 3 if skill['class']

      computed_score
    end
  end
end
