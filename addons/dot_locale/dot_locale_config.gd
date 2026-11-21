@tool
class_name GSLocaleConfig
extends GSConfig

## Which language, where the messages are, and whether to pseudo-localise.
##
## Layered like every config here, so a tester can run a build in German with
## `--locale-language de` or pseudo-localised with `--locale-pseudo true` without a
## settings screen, and a player's choice from GameSpice Settings is one more layer on top.

## The player's language, as a tag ("de", "pt-BR"). Empty asks the operating system.
@export var language: String = ""

## Where the chain ends. The language every key must exist in.
@export var default_language: String = "en"

## The directory holding one sub-directory per language, each with one JSON file per
## namespace — the website's own layout.
@export var directory: String = "res://locales"

## Show every message pseudo-localised: accented, bracketed, a third longer.
@export var pseudo: bool = false


func env_prefix() -> String:
	return "DOT_LOCALE_"


func cli_prefix() -> String:
	return "--locale-"


func validate() -> GSResult:
	if GSLocaleCatalogue.normalise(default_language) == "":
		return GSResult.fail(GSError.CODE_INVALID, "a default language is required: it is where every fallback ends")
	return GSResult.success(null)


## Builds a [GSLocale] from this configuration, reading [member directory] if it exists.
## A missing directory is not an error: a game with no translations yet still gets keys
## back, and a key on screen is how the first missing string is found.
func make() -> GSResult:
	var valid := validate()
	if not valid.ok:
		return valid
	var cat := GSLocaleCatalogue.new()
	if DirAccess.dir_exists_absolute(directory):
		var loaded := cat.load_dir(directory)
		if not loaded.ok:
			GSLog.warn("locale", "some locale files did not load", {"detail": loaded.error.detail})
	var loc := GSLocale.new(cat, language, default_language)
	loc.pseudo = pseudo
	return GSResult.success(loc)


func describe_lines(_redact_sensitive: bool = true) -> PackedStringArray:
	return PackedStringArray([
		"locale: %s, falling back to %s, from %s%s" % [
			language if language != "" else "(the system's)", default_language, directory,
			", pseudo" if pseudo else "",
		],
	])
