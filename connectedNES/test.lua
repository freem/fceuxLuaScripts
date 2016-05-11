-- hacky fceux lua script (by freem) for testing connectedNES input.
-- more info at https://github.com/hxlnt/connectednes and http://www.nobadmemories.com/connectednes

-- controller inputs
-- $01 = right
-- $02 = left
-- $04 = down
-- $08 = up
-- $10 = start
-- $20 = select
-- $40 = B button
-- $80 = A button

-- input table for fceux joypad.set
-- up, down, left, right, A, B, start, select

-- characters map to the controller input...

--     |$00|$01|$02|$03|$04|$05|$06|$07|$08|$09|$0A|$0B|$0C|$0D|$0E|$0F
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $00 |   |n/a| @ |   |   |   |   |n/a|n/a|n/a| P |n/a| 0 |n/a| p |n/a|
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $10 |n/a|n/a| H |n/a| ( |n/a| h |n/a|n/a|n/a| X |n/a| 8 |n/a| x |n/a| hold Start
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $20 |n/a|n/a| D |n/a| $ |n/a| d |n/a|n/a|n/a| T |n/a| 4 |n/a| t |n/a| hold Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $30 |n/a|n/a| L |n/a| , |n/a| l |n/a|n/a|n/a|   |n/a|   |n/a|   |n/a| hold Start+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $40 |n/a|n/a| B |n/a| " |n/a| b |n/a|n/a|n/a| R |n/a| 2 |n/a| r |n/a| hold B
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $50 |n/a|n/a| J |n/a| * |n/a| j |n/a|n/a|n/a| Z |n/a| : |n/a| z |n/a| hold B+Start
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $60 |n/a|n/a| F |n/a| & |n/a| f |n/a|n/a|n/a| V |n/a| 6 |n/a| v |n/a| hold B+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $70 |n/a|n/a| N |n/a| . |n/a| n |n/a|n/a|n/a| ^ |n/a| > |n/a| ~ |n/a| hold B+Start+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $80 |n/a|n/a| A |n/a| ! |n/a| a |n/a|n/a|n/a| Q |n/a| 1 |n/a| q |n/a| hold A
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $90 |n/a|n/a| I |n/a| ) |n/a| i |n/a|n/a|n/a| Y |n/a| 9 |n/a| y |n/a| hold A+Start
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $A0 |n/a|n/a| E |n/a| % |n/a| e |n/a|n/a|n/a| U |n/a| 5 |n/a| u |n/a| hold A+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $B0 |n/a|n/a| M |n/a| - |n/a| m |n/a|n/a|n/a|   |n/a|   |n/a|   |n/a| hold A+Start+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $C0 |n/a|n/a| C |n/a| # |n/a| c |n/a|n/a|n/a| S |n/a| 3 |n/a| s |n/a| hold A+B
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $D0 |n/a|n/a| K |n/a| + |n/a| k |n/a|n/a|n/a|   |n/a|   |n/a|   |n/a| hold A+B+Start
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $E0 |n/a|n/a| G |n/a| ' |n/a| g |n/a|n/a|n/a| W |n/a| 7 |n/a| w |n/a| hold A+B+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
-- $F0 |n/a|n/a| O |n/a| / |n/a| o |n/a|n/a|n/a| _ |n/a| ? |n/a|   |n/a| hold A+B+Start+Select
-------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
--     |$00|$01|$02|$03|$04|$05|$06|$07|$08|$09|$0A|$0B|$0C|$0D|$0E|$0F|

local function hexToController(_hexval)
	return {
		right = AND(_hexval,0x01) ~= 0 and true or false,
		left = AND(_hexval,0x02) ~= 0 and true or false,
		down = AND(_hexval,0x04) ~= 0 and true or false,
		up = AND(_hexval,0x08) ~= 0 and true or false,
		start = AND(_hexval,0x10) ~= 0 and true or false,
		select = AND(_hexval,0x20) ~= 0 and true or false,
		B = AND(_hexval,0x40) ~= 0 and true or false,
		A = AND(_hexval,0x80) ~= 0 and true or false
	}
end

local asciiToController = {
	[" "] = hexToController(0x04),
	["!"] = hexToController(0x84),
	["\""] = hexToController(0x44),
	["#"] = hexToController(0xC4),
	["$"] = hexToController(0x24),
	["%"] = hexToController(0xA4),
	["&"] = hexToController(0x64),
	["'"] = hexToController(0xE4),
	["("] = hexToController(0x14),
	[")"] = hexToController(0x94),
	["*"] = hexToController(0x54),
	["+"] = hexToController(0xD4),
	[","] = hexToController(0x34),
	["-"] = hexToController(0xB4),
	["."] = hexToController(0x74),
	["/"] = hexToController(0xF4),
	-------------------------------
	["0"] = hexToController(0x0C),
	["1"] = hexToController(0x8C),
	["2"] = hexToController(0x4C),
	["3"] = hexToController(0xCC),
	["4"] = hexToController(0x2C),
	["5"] = hexToController(0xAC),
	["6"] = hexToController(0x6C),
	["7"] = hexToController(0xEC),
	["8"] = hexToController(0x1C),
	["9"] = hexToController(0x9C),
	[":"] = hexToController(0x5C),
	[";"] = hexToController(0x00), -- likely $DC
	["<"] = hexToController(0x00), -- likely $3C
	["="] = hexToController(0x00), -- likely $BC
	[">"] = hexToController(0x7C),
	["?"] = hexToController(0xFC),
	-------------------------------
	["@"] = hexToController(0x02),
	["A"] = hexToController(0x82),
	["B"] = hexToController(0x42),
	["C"] = hexToController(0xC2),
	["D"] = hexToController(0x22),
	["E"] = hexToController(0xA2),
	["F"] = hexToController(0x62),
	["G"] = hexToController(0xE2),
	["H"] = hexToController(0x12),
	["I"] = hexToController(0x92),
	["J"] = hexToController(0x52),
	["K"] = hexToController(0xD2),
	["L"] = hexToController(0x32),
	["M"] = hexToController(0xB2),
	["N"] = hexToController(0x72),
	["O"] = hexToController(0xF2),
	-------------------------------
	["P"] = hexToController(0x0A),
	["Q"] = hexToController(0x8A),
	["R"] = hexToController(0x4A),
	["S"] = hexToController(0xCA),
	["T"] = hexToController(0x2A),
	["U"] = hexToController(0xAA),
	["V"] = hexToController(0x6A),
	["W"] = hexToController(0xEA),
	["X"] = hexToController(0x1A),
	["Y"] = hexToController(0x9A),
	["Z"] = hexToController(0x5A),
	["["] = hexToController(0x00),  -- likely $DA
	["\\"] = hexToController(0x00), -- likely $3A
	["]"] = hexToController(0x00),  -- likely $BA
	["^"] = hexToController(0x7A),
	["_"] = hexToController(0xFA),
	-------------------------------
	["`"] = hexToController(0x00),
	["a"] = hexToController(0x86),
	["b"] = hexToController(0x46),
	["c"] = hexToController(0xC6),
	["d"] = hexToController(0x26),
	["e"] = hexToController(0xA6),
	["f"] = hexToController(0x66),
	["g"] = hexToController(0xE6),
	["h"] = hexToController(0x16),
	["i"] = hexToController(0x96),
	["j"] = hexToController(0x56),
	["k"] = hexToController(0xD6),
	["l"] = hexToController(0x36),
	["m"] = hexToController(0xB6),
	["n"] = hexToController(0x76),
	["o"] = hexToController(0xF6),
	-------------------------------
	["p"] = hexToController(0x0E),
	["q"] = hexToController(0x8E),
	["r"] = hexToController(0x4E),
	["s"] = hexToController(0xCE),
	["t"] = hexToController(0x2E),
	["u"] = hexToController(0xAE),
	["v"] = hexToController(0x6E),
	["w"] = hexToController(0xEE),
	["x"] = hexToController(0x1E),
	["y"] = hexToController(0x9E),
	["z"] = hexToController(0x5E),
	["{"] = hexToController(0x00), -- likely $DE
	["|"] = hexToController(0x00), -- likely $3E
	["}"] = hexToController(0x00), -- likely $BE
	["~"] = hexToController(0x7E),
}

local messageDone = false
local testMessage = "Hello World!"

while true do
	local counter = 1 -- start at beginning of the string
	while not messageDone do
		-- check for string transmission finish
		if counter == #testMessage then
			messageDone = true
		end

		-- send character
		local controls = asciiToController[string.sub(testMessage,counter,counter)]
		if not controls then
			-- let go of all buttons
			controls = {up=false,down=false,left=false,right=false,A=false,B=false,start=false,select=false}
		end
		joypad.set(2,controls)

		counter = counter + 1
		-- need to frame advance, otherwise only the last character is printed
		emu.frameadvance();
	end

	-- return to our regularly scheduled programming
	emu.frameadvance();
end
