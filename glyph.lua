--[[
local function ParseGlyph(glyph, codeIndex, spells, index, mana, runes, runSpell)
	if glyph == "ᛋ" or glyph == "ᛚ" or glyph == "ᛥ" then
		runes[#runes] = runes[#runes] .. glyph
	end
end
local worldcontext = {spells, runes, mana}
local context = {worldcontext, glyph, codeIndex, spellindex, runSpell}
]]
local g = {}

g["ᛋ"] = function(context)
	context.worldcontext.runes = context.worldcontext.runes .. context.glyph
end
g["ᛚ"] = g["ᛋ"]
g["ᛥ"] = g["ᛋ"]

g["ᚷ"] = function(context)
	if #context.worldcontext.runes == 0 then return end
	context.worldcontext.mana[context.worldcontext.runes] = (context.worldcontext.mana[context.worldcontext.runes] or 0) + 1
end

g["᛫"] = function(context)
	context.worldcontext.runes = ""
end

g["ᚳ"] = function(context)
	if #context.worldcontext.runes == 0 then return end
	context.worldcontext.mana["ᛋ"] = (context.worldcontext.mana["ᛋ"] or 0) +
		(context.worldcontext.mana[context.worldcontext.runes] or 0)
end

g["ᚾ"] = function(context)
	if #context.worldcontext.runes == 0 then return end
	context.worldcontext.mana[context.worldcontext.runes] = (context.worldcontext.mana[context.worldcontext.runes] or 0) +
		(context.worldcontext.mana["ᛋ"] or 0)
end

g["ᚫ"] = function(context)
	if #context.worldcontext.runes == 0 then return end
	context.worldcontext.mana[context.worldcontext.runes] = 0
end

g["ᚩ"] = function(context)
	if (context.worldcontext.mana["ᛋ"] or 0) == 0 then
		return
	end
	context.worldcontext.mana["ᛋ"] = context.worldcontext.mana["ᛋ"] - 1
	local manaUsed = "ᛚ"
	local distance = context.worldcontext.mana["ᛚ"]
	if distance == 0 or distance == nil then
		manaUsed = "ᛚᛥ";
		distance = -(context.worldcontext.mana["ᛚᛥ"] or 0);
	end
	distance = distance or 0
	if distance ~= 0 then
		context.worldcontext.mana[manaUsed] = 0
	end
	context.runSpell(-distance)
end

return g
