-- DoesItDie spell language: picks a locale from ns.locales (the files before this one in the .toc) and reads
-- descriptions with it. English is read by DoesItDie.lua itself, which calls these first and falls back to its
-- own parsing when they return nil (always, on an English client; and for Forever text still in English).

local ADDON_NAME, ns = ...
local locale = {}
ns.locale = locale

-- The chosen locale: the setting (DoesItDieDB.language), or with "auto" (or a locale that's no longer there)
-- the one made for the client's language, else English.
local function chosen()
    local id = DoesItDieDB and DoesItDieDB.language or "auto"
    if id ~= "auto" and ns.locales[id] then return ns.locales[id] end
    local client = GetLocale and GetLocale()
    for _, entry in pairs(ns.locales) do
        if entry.clients[client] then return entry end
    end
    return ns.locales.en
end

-- The chosen locale if it isn't English, with the description as it reads it.
local function current(desc)
    local entry = chosen()
    if entry == ns.locales.en then return nil end
    return entry, entry.normalize and entry.normalize(desc) or desc
end

-- Adds every locale's spell names to DoesItDie.lua's English-keyed tables.
function locale.addNames(...)
    for _, names in pairs({ ... }) do
        for _, entry in pairs(ns.locales) do
            for english, translated in pairs(entry.names) do
                if names[english] ~= nil then names[translated] = names[english] end
            end
        end
    end
end

-- Finishers list their DoT per combo point (the locale's finisherPoints). Returns total, school (Physical),
-- duration for the given points (clamped to the listed range), or nil if there's no per-point DoT.
local function parseFinisher(desc, comboPoints, pattern)
    local byPoints, highest = {}, 0
    for pointsText, amount, secs in desc:gmatch(pattern) do
        local points = tonumber(pointsText)
        byPoints[points] = { total = tonumber(amount), duration = tonumber(secs) }
        highest = math.max(highest, points)
    end
    if highest == 0 then return nil end
    local entry = byPoints[math.max(1, math.min(comboPoints, highest))] or byPoints[highest]
    return entry.total, 1, entry.duration
end

-- Total damage, school mask, duration and (if stated) tick interval, or nil.
function locale.parseDot(desc, comboPoints)
    local entry, text = current(desc)
    if not entry then return nil end
    if entry.isFinisher(text) then return parseFinisher(text, comboPoints or 5, entry.finisherPoints) end
    if entry.isNotDot(text) then return nil end
    return entry.parseDot(text)
end

function locale.isFinisher(desc)
    local entry, text = current(desc)
    return entry ~= nil and entry.isFinisher(text)
end

function locale.awardedComboPoints(desc)
    local entry, text = current(desc)
    if entry then return entry.awardedComboPoints(text) end
end

-- Options dropdown entries: Auto, then every locale file.
function locale.list()
    local list, ids = { { id = "auto", label = "Auto (client language)" } }, {}
    for id in pairs(ns.locales) do table.insert(ids, id) end
    table.sort(ids, function(a, b) return ns.locales[a].order < ns.locales[b].order end)
    for _, id in ipairs(ids) do table.insert(list, { id = id, label = ns.locales[id].label }) end
    return list
end
