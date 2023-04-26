# Salty Trivia Data Export Project

This project provides a minimal template to export a data file for Salty Trivia games.
The version of Godot Engine used to export the data files must be 3.5, not 4.

## The anatomy of a question data file

Question data is exported as a `.zip` file.
The contents that Salty Trivia will actually need are as follows, assuming that the question ID is `n001`:

```
n001.pck
  /q
    /n001
      /_question.gdcfg
      /title.wav
      /title.wav.import
      /intro.wav
      /intro.wav.import
      /question.wav
      /quesiton.wav.import
        (and so on)
```

Question data is stored in the folder `/q/n001`;
the second-level folder must match the file name and question ID.

Voice data must be saved as `.wav` files. `.wav.import` files will be generated automatically upon opening the project through Godot.

If you want to learn through example, check [the /q/ folder of this repo](https://github.com/JapanYoshi/salty_data/tree/main/q), where all the official questions are stored.

## `_question.gdcfg`

The question data file is a Godot configuration file (as suggested by the nonstandard file extension `.gdcfg`).
Its internal structure is an extended INI file compatible with [Godot’s `ConfigFile` object](https://docs.godotengine.org/en/3.5/classes/class_configfile.html).

Godot config files are text files made out of sections, each containing one or more key-value pairs.

```
[question]
t = "Which of these subjects could you study while reading a library book [#3191#]with the Dewey Decimal class “420”?"
v = "question"
s = "
Which of these subjects could you study while reading a library book[#3191#]
with the Dewey Decimal class “420”?
"

[options]
t = [
  "History of the English Language",
  "Ceramic Technology",
  "Cinematography and Videography",
  "Journalism"
]
v = "options"
s = "
History of the English Language,[#1635#]
Ceramic Technology,[#3170#]
Cinematography and Videography,[#4993#]
or Journalism?
"
i = 0
```

### Sections

Most sections correspond to one voice line, 
and contain the key `v` and `s`, sometimes `t`. They correspond to the file name, the subtitle string, and the text displayed on screen, respectively.

The required sections will change by question type, but some of them are in common.

This is an extract from the first official question:

### the `v` key: Voice file name

Generally, `v` is the file name of the voice line (minus `.wav`) to play during that section.

If the vaule is `""`, it will skip the line. The following sections may contain `""`:
  * `[intro]`

If the value is `"random"`, it will cause the game to randomize which variant of the line is used, from a pool of preset voice lines. Said voice lines and their subtitle text are stored in the game within `random_voicelines.json`. The key `s` will be ignored. The sections in the following list may contain `"random"` (quoted and formatted from `Loader.gd`):
```
# Normal / Candy Trivia
	"pretitle",
	"option0", "option1", "option2", "option3",
	"used_lifesaver",
	"reveal", "reveal_crickets", "reveal_jinx",
	"reveal_split", "reveal_correct",

# multiple special question types
	"skip", "buzz_in",

# Sorta Kinda
	"sort_segue", "sort_both", "sort_press_left", "sort_press_right",
	"sort_press_up", "sort_lifesaver",

# All Outta Salt
	"gib_tute0", "gib_tute1", "gib_tute2", "gib_tute3", "gib_tute4",
	"gib_early", "gib_wrong", "gib_late", "gib_blank",

# Thousand-Question Question
	"thou_segue", "thou_tute0", "thou_tute1", "thou_tute2", "thou_intro",

# Sugar Rush
	"rush_intro", "rush_tute0", "rush_tute1", "rush_tute2", "rush_tute3",
	"rush_ready",

# Like It or Leave It
	"like_intro",
	"like_tute0", "like_tute1", "like_tute2", "like_tute3",
	"like_title", "like_options", "like_ready",
	"like_outro"
```

If the value starts with `_`, it will choose one random voice line from the corresponding section in `random_voicelines.json` and load it from the game files. The key `s` will be ignored. For example, to make Miles say the question intro (i.e. to have the game load a voice line from the `pretitle_miles` section), you would write:
```
[pretitle]
v = "_pretitle_miles"
```

Any other value of `v` will be taken literally as the filename of the sound file, minus the file extension `.wav`.

### the `s` key: Subtitle text

Every voice line that is not random will require subtitle text. Each line of subtitle text may contain leading and trailing spaces, which will be automatically trimmed by the game.

To program timing changes for subtitles, use timestamps.

For example, a subtitle that changes from "foo" to "bar" after 3 seconds is as follows: `foo[#3000#]bar`

A timestamp starts with `[#`, contains the number of milliseconds *since the start of the voice line,* and ends with `#]`.

The final timestamp may be skipped, in which case, the subtitle automatically disappears when the voice line is over.

The question text also uses timestamps, but unlike subtitles, it does not trim leading or trailing newlines.

### the `t` key: Other on-screen text

The following sections contain miscellaneous on-screen text:

**Most question types**

* `[title]` - Question title. May contain BBCode: `[i]` and `[code]`.
* `[question]` - Question body text. May contain BBCode: `[i]`, `[b]`, and `[code]`. Also used for All Outta Salt’s nonsense phrase.
* `[options]` - Options for multiple choice questions. **Must be an array of size 4!** May contain BBCode: `[i]`, `[b]`, and `[code]`.

**Candy Trivia**

* `[setup]`, `[punchline]` - Candy Trivia joke, for questions containing a Laffy Taffy bar. May *not* contain BBCode.

**Sorta Kinda**
* `[sort_a]`, `[sort_b]` - Sorta Kinda “boxes”, long form. May contain BBCode: `[i]`.
* `[sort_a_short]`, `[sort_b_short]` - Sorta Kinda “boxes”, short form. May contain BBCode: `[i]`.
* `[sort_options]` - Items to sort in the Sorta Kinda. **Must be an array of size 7!** The same goes with the `s` and `a` keys. May contain BBCode: `[i]`

**All Outta Salt**
* `[gib_genre]` - The category of an All Outta Salt (e.g. If the line says “With what slogan does this rhyme?”, set it to `"slogan"`.) May contain BBCode: `[i]`.
* `[answer]` - All Outta Salt’s answer. May contain BBCode: `[i]`.

### Other keys

**Most question types**
* `root.type` - The single-character question type code. Due to a decision I made early in development, this must be an **uppercase** character in the following list: `NCOSGTRL`.
* `options.i` - The **zero-based** index of the correct answer to a 4-choice question.

**Sorta Kinda**
* `root.has_both` - Whether or not the “both” option is selectable.
* `sort_options.a` - An array of correct choices for each of the 7 items. 0 for Left, 1 for Right, 2 for Both.

**All Outta Salt**
* `answer.r` - The regular expression used to check whether the answer is correct. Can only contain uppercase letters, for simplicity, as user input will be restricted to a character set of uppercase letters, numerals, spaces, and limited punctuation.

**Sugar Rush** (For `section0` through `section5`)
* `section0.q` - Question text for the section.
* `section0.o` - An array of 6 options to choose from.
* `section0.a` - An array of correct choices for each of the 6 items. 0 for false, 1 for true.

**Like It or Leave It** (For `section0` through `section4` and `answer0` through `answer4`)
* `section0.o` - An array of 4 options to choose from.
* `answer0.a` - An array of correct choices for each of the 4 items. 0 for false, 1 for true.

## How the game downloads the data files

The game downloads the data files from the URL specified in `MenuRoot.gd` → `async_load_question(q)`, where `q` is the question ID. The official questions are located at `"https://haitouch.ga/me/salty/%s.pck" % q`; other versions will require you to change this Web address and point it to the location where you will host the files available for download.

Once the game loads the question, it is cached locally forever, until you manually clear it.
