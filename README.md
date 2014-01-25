# Wayfinder - gem for the Pathfinder roleplaying game.


### What it does

Wayfinder fills the gap between the raw data describing your Pathfinder character and nicely formatted templates, it manages the bookeeping of your character
so you don't have to do the number crunching yourself. Every feat, item, skill, temporary buff and whatever other condition affecting your character is
aggregated passed on to a customizable template so your character is both easy to maintain - by manipulating the source files - and easy to use in your epic
aventures by looking at beautiful ouput that you can generate using html, markdown or whatever else you choose.

The chosen format for the source files of the chacracters is Yaml, the internal `Wayfinder::Character` class is agnostic from the source files though, so it should
be really easy to add other serialization strategies to it. Yaml is easy to read and write though, making it ideal for you to store and edit your character data
on the fly.

### What it doesn't do

Better programmers than me have tried and failed to build something that could take care of their bookkeeping for them, the problem is that Pathfiner - and
pretty much all other roleplayin games, really - is incredibly complex. Trying to emulate the whole rulebook including classes and races is hard but everything
just becomes plain impossible when trying to account for every possible feat, magical effect, weird class feature and random modifiers.

Wayfinder errs on the side of simplicity: your character doesn't have a class but it's composed of some extremely basic stuff like `stats` (Strenght, Dexterity, etc)
and `skills`, everything else in the game is considered to be a `modifier` and even though they are separated into different files to make the source of the characters
more readable `feats`, `buffs` and `gear` are all treated equally as "things" that modify your character final stats in one way or another.

Don't expect wayfinder to help you to level up your character or stick to the rules of Pathfinder, it aims only to be a simple way to add up all your numbers and
fill a template with data, the rest fellow adventurer, is up to you.

## Usage

As expected, you can install wayfinder via rubygems typing `gem install wayfinder` in your terminal.

Wayfinder assumes you'll have a set of files describing your character and a template file where to pass the aggregated data. By default the source files are expected to be in the `source` directory, and the template used is `source/template.md`, you can change this using the appropriate flags.

```
$ tree
├── README.md
└── source
  ├── buffs.yml         #=> Contains temporary modifiers that affect your character, you'll edit this often.
  ├── feats.yml         #=> Character feats
  ├── gear.yml          #=> Equipped items that affect the character stats.
  ├── meta.yml          #=> Saving throws, base attack bonus, hp and other data.
  ├── skills.yml        #=> Skill ranks and associated stat are described here.
  ├── stats.yml         #=> Base stats (STR, DEX, CON, INT, WIS, CHA).
  └── template.md       #=> Template file.
```

