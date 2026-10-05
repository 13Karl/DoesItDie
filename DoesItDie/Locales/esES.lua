-- DoesItDie locale: Spanish (Spain, esES). Fields are described in Locales/enUS.lua.
-- Names and description wording checked against Wowhead Forever's Spanish pages (wowhead.com/forever/es).

local ADDON_NAME, ns = ...
ns.locales = ns.locales or {}

-- Spanish school names, as they follow "p. de daño" ("de las Sombras", "Arcano"). Pirofrío (Frostfire) first,
-- before the schools it combines.
local SCHOOLS = {
    { "Pirofrío", 4 + 16 }, { "Sombras", 32 }, { "Fuego", 4 }, { "Naturaleza", 8 }, { "Escarcha", 16 },
    { "Arcano", 64 }, { "Sagrado", 2 },
}
local PHYSICAL = 1

local function schoolFromWords(words)
    for _, entry in ipairs(SCHOOLS) do
        if words:find(entry[1], 1, true) then return entry[2] end
    end
    return PHYSICAL
end

ns.locales.es = {
    order = 2,
    label = "Español (España)",
    clients = { esES = true },
    names = {
        ["Serpent Sting"] = "Aguijón de serpiente",
        ["Fireball"] = "Bola de Fuego",
        ["Pyroblast"] = "Piroexplosión",
        ["Frostfire Bolt"] = "Descarga de Pirofrío",
        ["Insect Swarm"] = "Enjambre de insectos",
        ["Curse of Agony"] = "Maldición de Agonía",
        ["Bane of Agony"] = "Terror de agonía",
        ["Holy Fire"] = "Fuego Sagrado",
        ["Rip"] = "Destripar",
        ["Rupture"] = "Ruptura",
        ["Siphon Life"] = "Succionar vida",
        ["Rain of Fire"] = "Lluvia de Fuego",
        ["Hellfire"] = "Piroinferno",
        ["Blizzard"] = "Ventisca",
        ["Flamestrike"] = "Fogonazo",
        ["Consecration"] = "Consagración",
        ["Hurricane"] = "Huracán",
        ["Volley"] = "Lluvia",
        ["Drain Life"] = "Drenar vida",
        ["Drain Soul"] = "Drenar alma",
        ["Drain Mana"] = "Drenar maná",
        ["Health Funnel"] = "Cauce de salud",
        ["Mind Flay"] = "Despelleje mental",
        ["Arcane Missiles"] = "Misiles Arcanos",
        ["Starshards"] = "Fragmentos estelares",
        ["Immolation Trap"] = "Trampa de inmolación",
        ["Explosive Trap"] = "Trampa explosiva",
        ["Wyvern Sting"] = "Picadura de dracoleón",
        -- Options preview only
        ["Corruption"] = "Corrupción",
        ["Immolate"] = "Inmolar",
    },

    -- Thousands separator and decimal comma: "1.314" -> "1314", "1,5 s" -> "1.5 s".
    normalize = function(desc) return (desc:gsub("(%d)%.(%d%d%d)", "%1%2"):gsub("(%d),(%d)", "%1.%2")) end,

    -- "Remate que inflige daño en el tiempo...: 1 punto: 44 de daño durante 12 s." (Destripar),
    -- "1 punto: 25 p. de daño durante 8 s" (Ruptura)
    isFinisher = function(desc) return desc:find("^Remate") ~= nil end,
    finisherPoints = "(%d+) puntos?%s*:%s*(%d+)%D-durante (%d+%.?%d*) s",

    -- Venenos ("Cubre un arma con veneno...") and heals over time ("Cura el objetivo en 45 p. de daño durante 15 s.").
    isNotDot = function(desc)
        return desc:find("[Cc]ubre un arma") ~= nil or desc:find("^Cura") ~= nil
    end,

    --   "causando 40 p. de daño de las Sombras durante 12 s."           (Corrupción)
    --   "15 p. de daño de Fuego más durante 15 s." / "2 p. de daño de Fuego extra durante 4 s."  (Inmolar, Bola de Fuego)
    --   "un daño extra de 48 p. durante 9 s."                            (Arañazo)
    --   "Transfiere 11 p. de salud del objetivo al taumaturgo cada 3 s. Dura 30 s."  (Succionar vida)
    -- The amount is the last number before "durante", and must read as an amount ("p." or "de daño" after it, not
    -- "40% durante" as in Seccionar) of damage. Takes the last such clause, like the English parser.
    parseDot = function(desc)
        local total, school, duration
        for pos, amount, words, secs in desc:gmatch("()(%d+)(%D-)durante (%d+%.?%d*) s") do
            local isAmount = words:find("^%s*p%.") or words:find("^%s*de daño")
            local isDamage = words:find("daño") or desc:sub(math.max(1, pos - 20), pos - 1):find("daño")
            if isAmount and isDamage then
                total, school, duration = tonumber(amount), schoolFromWords(words), tonumber(secs)
            end
        end
        if total and duration > 0 then return total, school, duration end

        local amount, words, every = desc:match("(%d+)(%D-)cada (%d+%.?%d*) s")
        local lasts = desc:match("[Dd]ura (%d+%.?%d*) s")
        if amount and every and lasts and (words:find("daño") or words:find("salud")) then
            every, lasts = tonumber(every), tonumber(lasts)
            if every > 0 and lasts > 0 then
                return tonumber(amount) * math.floor(lasts / every + 0.5), schoolFromWords(words), lasts, every
            end
        end
    end,

    -- "Otorga 1 punto de combo." (Garrote) or "Otorga 1 p. de combo." (Golpe siniestro).
    awardedComboPoints = function(desc)
        return tonumber(desc:match("Otorga (%d+) puntos? de combo") or desc:match("Otorga (%d+) p%. de combo"))
    end,
}
