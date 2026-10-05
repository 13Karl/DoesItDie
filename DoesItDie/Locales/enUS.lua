-- DoesItDie locale: English. The reference language: spell names in DoesItDie.lua's tables are English, and
-- DoesItDie.lua reads English descriptions itself, so this entry only names the language.
--
-- Every other locale file adds one entry to ns.locales (see Locales/esES.lua), used by Locales/Locales.lua:
--   order               position in the options dropdown
--   label               name in the options dropdown
--   clients             GetLocale() values this locale is picked for by "Auto"
--   names               English spell name -> name in this language (the keys of DoesItDie.lua's spell tables)
--   normalize(desc)     optional: cleans up a description before it's read
--   isFinisher(desc)    whether the description is a finisher's (per-combo-point damage)
--   finisherPoints      pattern for one per-point entry of a finisher: captures points, damage, seconds
--   isNotDot(desc)      descriptions that look like a DoT but aren't one (weapon enchants, heals over time)
--   parseDot(desc)      total damage, school mask, duration and (if stated) tick interval, or nil
--   awardedComboPoints(desc)  combo points a builder awards, or nil

local ADDON_NAME, ns = ...
ns.locales = ns.locales or {}

ns.locales.en = {
    order = 1,
    label = "English",
    clients = { enUS = true, enGB = true },
    names = {},
}
