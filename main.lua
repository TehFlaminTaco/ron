local Charset = require "charset"
local Parser = require "parser"

local args = { ... }

local simpleargs = {}
local flags = {}

for i = 1, #args do
	local arg = args[i]
	if arg:sub(1, 1) == "-" then
		if arg:sub(2, 2) == arg:sub(2, 2):upper() then
			flags[arg:sub(2, 2):lower()] = nil
		end
		flags[arg:sub(2, 2)] = arg:sub(3)
	else
		simpleargs[#simpleargs + 1] = arg
	end
end

if #simpleargs == 0 then
	print("Usage: lua main.lua <file> [options]")
	return
end

local file = simpleargs[1]
local f = io.open(file, "rb")
if not f then
	print("File not found: " .. file)
	return
end
local code = f:read "*a"
if flags["g"] then
	code = Charset.FromMixedLatin(code)
	code = Charset.OnlyCodeSymbols(code)
	code = Charset.CharsetToBinary(code)
	local binary = code
	code = Charset.BinaryToCharset(code)
	local count = 0
	for s in code:gmatch "[%z\1-\127\194-\244][\128-\191]*" do
		count = count + 1
	end
	print("Symbols: " .. count)
	print(code)
	print("Bytes: " .. #binary)
	for s in binary:gmatch "." do
		io.write(string.format("%02X ", s:byte()))
	end
	print()
else
	code = Charset.BinaryToCharset(code)
	code = Charset.OnlyCodeSymbols(code)
end

local spells = Parser.GetSpells(code)
local finalMana = Parser.RunSpell({ spells = spells }, #spells)

if flags["t"] then
	print("Latin: " .. Charset.CharsetToLatin(code))
end

if flags["m"] then
	for manaType, value in pairs(finalMana) do
		print(manaType .. ":", value)
	end
end
