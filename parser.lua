local Glyphs = require("glyph")

local runSpell
local function GetSpells(code)
	local spells = {}
	for word in (code .. "᛬"):gmatch "(.-)᛬" do
		local spell = {}
		local oldword = ""
		while word ~= oldword do
			oldword = word
			word = word:gsub("(%d+)(%b())", function(n, b) return b:sub(2, #b - 1):rep(n) end)
		end
		oldword = ""
		while word ~= oldword do
			oldword = word
			word = word:gsub("(%d+)([%z\1-\127\194-\244][\128-\191]*)", function(n, b) return b:rep(n) end)
		end
		for glyph in word:gmatch "[%z\1-\127\194-\244][\128-\191]*" do
			spell[#spell + 1] = glyph
		end
		spells[#spells + 1] = spell
	end
	return spells
end

local function ParseGlyph(worldcontext, glyph, codeIndex, spellindex)
	local g = Glyphs[glyph]
	local context = { worldcontext = worldcontext, glyph = glyph, codeIndex = codeIndex, spellindex = spellindex,
		runSpell = function(relativeIndex)
			local ind = spellindex + relativeIndex
			while ind < 1 do ind = ind + #worldcontext.spells end
			while ind > #worldcontext.spells do ind = ind - #worldcontext.spells end
			runSpell(worldcontext, ind)
		end }
	if g then
		return g(context)
	end
end

local function RunSpell(worldcontext, index)
	worldcontext.mana = worldcontext.mana or {}
	worldcontext.runes = worldcontext.runes or ""
	local codeIndex = 1
	local spell = worldcontext.spells[index]
	while codeIndex <= #spell do
		local ind = ParseGlyph(worldcontext, spell[codeIndex], codeIndex, index)
		codeIndex = ind or codeIndex + 1
	end
	return worldcontext.mana
end

runSpell = RunSpell

return {
	GetSpells = GetSpells,
	RunSpell = RunSpell
}
