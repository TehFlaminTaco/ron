local _charset = ("\\x00\\x09\\x20\\x0A\\x0D+-()0123456789ABCDEFx\\x5C/᛫᛬᛭ᚠᚢᚦᚩᚱᚳᚷᚹᚻᚾᛁᛄᛇᛈᛉᛋᛏᛒᛖᛗᛚᛝᛟᛞᚪᚫᛠᚣᛣᚸᛢᛥᛡ"
	):gsub("\\x(..)", function(hex)
		local num = tonumber("0x" .. hex)
		if num then
			return string.char(num)
		end
		return ""
	end)
local Charset = {};
for s in _charset:gmatch "[%z\1-\127\194-\244][\128-\191]*" do
	Charset[#Charset + 1] = s
end
function Charset:find(symbol)
	for i = 1, #Charset do
		if Charset[i] == symbol then
			return i
		end
	end
	return nil
end

local RuneToLatin = {
	["ᚠ"] = "f", -- Feoh 	wealth, cattle
	["ᚢ"] = "u", -- Ur   	aurochs
	["ᚦ"] = "th", -- Thorn   thorn
	["ᚩ"] = "o", -- Os   	heathen god ("mouth" in rune poem?)[5]
	["ᚱ"] = "r", -- Rad  	riding
	["ᚳ"] = "c", -- Cen  	torch
	["ᚷ"] = "g", -- Gyfu 	gift
	["ᚹ"] = "w", -- Wynn 	mirth
	["ᚻ"] = "h", -- Hægl 	hail
	["ᚾ"] = "n", -- Nyd  	need (as in "plight")
	["ᛁ"] = "i", -- Is   	ice
	["ᛄ"] = "j", -- Ger  	year
	["ᛇ"] = "iw", -- Eoh  	yew tree
	["ᛈ"] = "p", -- Peorð   ?
	["ᛉ"] = "x", -- Eolh 	elk's?
	["ᛋ"] = "s", -- Sigel	sun ("sail" in rune poem?)
	["ᛏ"] = "t", -- Tir  	Tiw ("Planet Mars" in rune poem?)[9]
	["ᛒ"] = "b", -- Beorc   birch tree
	["ᛖ"] = "e", -- Eh   	steed
	["ᛗ"] = "m", -- Mann 	man
	["ᛚ"] = "l", -- Lagu 	body of water (lake)
	["ᛝ"] = "ng", -- Ing  	Ing (Ingui-Frea)?
	["ᛟ"] = "oe", -- Eðel 	inherited land, native country
	["ᛞ"] = "d", -- Dæg  	day
	["ᚪ"] = "a", -- Ac   	oak tree
	["ᚫ"] = "ae", -- Ansuz   ash tree
	["ᛠ"] = "ea", -- Ear  	grave soil?
	["ᚣ"] = "y", -- Yr   	yewen bow?
	["ᛣ"] = "k", --	Calc	chalk? chalice? sandal?
	["ᚸ"] = "ga", -- Gar		spear
	["ᛢ"] = "q", -- Cweorð	Unknown
	["ᛥ"] = "st", -- Stan	Stone
	["ᛡ"] = "io", -- Ior
	["᛫"] = "single",
	["᛬"] = "multiple",
	["᛭"] = "cross"
}

local RuneNames = {
	["ᚠ"] = "Feoh",
	["ᚢ"] = "Ur",
	["ᚦ"] = "Thorn",
	["ᚩ"] = "Os",
	["ᚱ"] = "Rad",
	["ᚳ"] = "Cen",
	["ᚷ"] = "Gyfu",
	["ᚹ"] = "Wynn",
	["ᚻ"] = "Hægl",
	["ᚾ"] = "Nyd",
	["ᛁ"] = "Is",
	["ᛄ"] = "Ger",
	["ᛇ"] = "Eoh",
	["ᛈ"] = "Peorð",
	["ᛉ"] = "Eolh",
	["ᛋ"] = "Sigel",
	["ᛏ"] = "Tir",
	["ᛒ"] = "Beorc",
	["ᛖ"] = "Eh",
	["ᛗ"] = "Mann",
	["ᛚ"] = "Lagu",
	["ᛝ"] = "Ing",
	["ᛟ"] = "Eðel",
	["ᛞ"] = "Dæg",
	["ᚪ"] = "Ac",
	["ᚫ"] = "Ansuz",
	["ᛠ"] = "Ear",
	["ᚣ"] = "Yr",
	["ᛣ"] = "Calc",
	["ᚸ"] = "Gar",
	["ᛢ"] = "Cweorð",
	["ᛥ"] = "Stan",
	["ᛡ"] = "Ior",
	["᛫"] = "Space",
	["᛬"] = "Line",
	["᛭"] = "Paragraph"
}

local LatinToRune = {};
local LatinByLength = {}

for rune, latin in pairs(RuneToLatin) do
	LatinToRune[latin] = rune;
	LatinByLength[#LatinByLength + 1] = latin
end
table.sort(LatinByLength, function(a, b)
	if #a == #b then
		return a < b
	end
	return #a > #b
end)


function FromMixedLatin(chars)
	local index = 1
	local out = ""
	while index <= #chars do
		local any = false
		for _, latin in ipairs(LatinByLength) do
			if chars:sub(index, index + #latin - 1) == latin then
				out = out .. LatinToRune[latin]
				index = index + #latin
				any = true
				break
			end
		end
		if not any then
			out = out .. chars:sub(index, index)
			index = index + 1
		end
	end
	return out
end

function CharsetToBinary(chars)
	local out = "";
	local bits = 0;
	local n = 0;
	for s in chars:gmatch "[%z\1-\127\194-\244][\128-\191]*" do
		local index = Charset:find(s);
		if index then
			n = n * (2 ^ 6);
			n = n + index - 1;
			bits = bits + 6;
		end
		while bits >= 8 do
			local high = math.floor(n / (2 ^ (bits - 8)))
			n = n - (high * (2 ^ (bits - 8)))
			out = out .. string.char(high)
			bits = bits - 8
		end
	end
	while bits % 8 ~= 0 do
		bits = bits + 1
		n = n * 2
	end
	if bits > 0 then
		out = out .. string.char(n)
	end
	return out
end

function BinaryToCharset(bytes)
	local out = ""
	local bits = 0
	local n = 0
	for s in bytes:gmatch "." do
		n = n * (2 ^ 8)
		n = n + s:byte()
		bits = bits + 8
		while bits >= 6 do
			local high = math.floor(n / (2 ^ (bits - 6)))
			n = n - (high * (2 ^ (bits - 6)))
			out = out .. Charset[high + 1]
			bits = bits - 6
		end
	end
	return out
end

local testCode = "helloworld"
local asRunes = FromMixedLatin(testCode)
print("asRunes:", asRunes)
local asBinary = CharsetToBinary(asRunes)
local backAsChars = BinaryToCharset(asBinary)
print("withoutGarbage:", backAsChars)