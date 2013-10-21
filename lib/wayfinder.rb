module Wayfinder

  BASE_STATS = %w(strength dexterity constitution wisdom charisma intelligence)

  class Character

    ## :source must be a hash with the following keys, each containing the data of
    ## its appropriate yaml file.
    #
    #  * meta         - contains hp, base attack bonus, saving throws, xp, name,
    #                   and other metadata.
    #  * stats        - contains basic stats, str, dex, con, wis, int and cha.
    #  * gear         - contains descriptions of items that modify the final
    #                   computed stats for the character.
    #  * feats        - character feats, similar to gear in that it contributes
    #                   to the final stack.
    #  * buffs        - buffs are temporary modifiers that are expected to change
    #                   often, but act much like feats and gear.
    #  * skills       - skills contain data on the ranks and associated stats for
    #                   each given skill.
    #
    ## :modifier_stack is an array of gear, feats and buffs and is what will be
    ## iterated while computing final modifiers for all character stats.

    attr_accessor :source, :modifier_stack

    def initialize(source_data = {})
      self.source = source_data
      self.modifier_stack = [
        self.source[:gear],
        self.source[:feats],
        self.source[:buffs]
      ]
    end

    BASE_STATS.each do |base_stat|
      define_method(base_stat) do
        self.source[:stats][base_stat] + modifier_for(base_stat)
      end

      define_method("#{ base_stat }_modifier") do
        stat = self.source[:stats][base_stat] + modifier_for(base_stat)
        (stat - 10) / 2
      end
    end

    ## Returns an array of object who affect the specified attribute
    def stack_for(attribute)
      self.modifier_stack.map(&:values).flatten.keep_if do |item|
        item['active'] && item.fetch('modifiers', {}).keys.include?(attribute)
      end
    end

    ## Outputs the final modifier for the specified attribute.
    def modifier_for(attribute)
      modifier = 0
      stack_for(attribute).each do |mod|
        modifier += mod['modifiers'][attribute]
      end

      modifier
    end

    ## Combat

    def hp
      self.source[:meta]['hp'] + modifier_for('hp')
    end

    def received_damage
      self.source[:meta]['received_damage']
    end

    def current_hp
      self.hp - self.received_damage
    end

    def speed
      30 + modifier_for('speed')
    end

    def initiative
      dexterity_modifier + modifier_for('initiative')
    end

    def bab
      self.source[:meta]['bab']
    end

    def to_hit(base_attack = self.bab)
      base_attack + strength_modifier + modifier_for('to_hit')
    end

    def damage
      strength_modifier + modifier_for('damage')
    end

    def full_attack
      attack_babs = [self.bab]

      ## Fuck yeah I used a while in ruby, fuck you, fuck everything, EVERYTHING.
      while attack_babs.last - 5 >= 1
        attack_babs << attack_babs.last - 5
      end

      attack_babs.map { |attack| to_hit(attack) }
    end

    def ac
      10 + dexterity_modifier + modifier_for('ac')
    end

    def damage_reduction
      0 + modifier_for('damage_reduction')
    end

    ## Saving Throws
    def saving_throws
      {
        fortitude: self.fortitude,
        reflex: self.reflex,
        will: self.will
      }
    end

    def fortitude
      self.source[:meta]['fortitude'] + constitution_modifier + modifier_for('fortitude')
    end

    def reflex
      self.source[:meta]['reflex'] + dexterity_modifier + modifier_for('reflex')
    end

    def will
      self.source[:meta]['will'] + wisdom_modifier + modifier_for('will')
    end

    def skill(skill_name)
      skill = self.source[:skills].fetch(skill_name, {})
      computed_score = skill.fetch('ranks', 0) + self.send("#{ skill['stat'] }_modifier") + modifier_for(skill_name)

      if skill['class']
        computed_score += 3
      end

      computed_score
    end

    def skills
      all_skills = {}
      self.source[:skills].keys.each { |s| all_skills[s] = self.skill(s) }
      all_skills
    end
  end
end
