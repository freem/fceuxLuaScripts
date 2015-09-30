-- Tennis for NES | Sprite Viewer
-- Best used with a Tennis ROM patched with Tennis_sprview.ips
--============================================================================--
-- [Configuration]
--============================================================================--
-- StartingSpriteIndex: Sprite number the animations start using (0-63)
local StartingSpriteIndex = 2

-- MetaspriteTableAddr: Address of metasprite table (0xF28C in normal Tennis)
-- !! IF THIS IS NOT CORRECT, THE SCRIPT WILL HANG THE EMULATOR !!
local MetaspriteTableAddr = 0xf28c -- normal tennis

-- SpriteDisplayX, SpriteDisplayY: Base starting location for metasprite display.
local SpriteDisplayX = 220
local SpriteDisplayY = 160

--============================================================================--
-- [Viewer Variables]
--============================================================================--
-- BaseSprAddress: Index into OAM where the sprite viewer will dump the data
local BaseSprAddress = 0x0200 + (StartingSpriteIndex*4)

local CurAnimNumber = 0 -- possible values 0-62

local CurAnimNumTiles = 0 -- grabbed from reading a pointer

-- sprite data
local CurSpriteData = {}
CurSpriteData.RelPos = {}
CurSpriteData.Tiles = {}

--============================================================================--
-- [Sprite Routines]
--============================================================================--
-- Masks for checking flipping
local tileFlipMasks = { 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01 }

-- ClearSprite: Hides a sprite, instead of clearing it. ah well.
-- used when reading new metasprite
local function ClearSprite(sprNum)
	local sprAddr = BaseSprAddress + (sprNum*4)
	memory.writebyte(sprAddr,0xF8)
end

-- ClearAllSprites: Hides all sprites used by the animation viewer
local function ClearAllSprites()
	-- start at BaseSprAddress
	for i=StartingSpriteIndex,63 do
		local here = 0x0200+(i*4)
		memory.writebyte(here,0xF8)
	end
	print("----------------------------------------")
	print(string.format("Cleared sprites %i-63",StartingSpriteIndex))
end

-- ReadMetasprite: Reads a metasprite into script memory and displays it.
local function ReadMetasprite(msprNum)
	print("----------------------------------------")
	-- base is MetaspriteTableAddr
	local lowByte = MetaspriteTableAddr+(msprNum*2)
	local highByte = MetaspriteTableAddr+(msprNum*2)+1
	local addrLow = memory.readbyte(lowByte)
	local addrHigh = memory.readbyte(highByte)

	local addr = tonumber(string.format("0x%02X%02X",addrHigh,addrLow),16)
	print(string.format("metasprite %i address: 0x%04X",msprNum,addr))
	CurSpriteData.MainPointer = addr

	-- Tennis metasprite format  --
	--|-------------------------|--
	-- 0x00,0x01: pointer to relative position pairs
	local relPairAddrLow  = memory.readbyte(addr)
	local relPairAddrHigh = memory.readbyte(addr+1)
	CurSpriteData.AddrRelativePos = tonumber(string.format("0x%02X%02X",relPairAddrHigh,relPairAddrLow),16)
	print(string.format("relative pairs at 0x%04X",CurSpriteData.AddrRelativePos))

	local listCounter = 0
	local curX,curY = 0,0

	CurSpriteData.RelPos = {}

	local curRelListAddr = CurSpriteData.AddrRelativePos
	local readByte = memory.readbyte(curRelListAddr)
	while readByte ~= 0xAA do
		-- if this isn't 0xAA, re-read as signed value
		readByte = memory.readbytesigned(curRelListAddr)
		if listCounter % 2 == 0 then
			curY = readByte
		else
			curX = readByte
			-- add to table
			table.insert(CurSpriteData.RelPos,{X=curX, Y=curY})
		end

		-- prepare for next
		listCounter = listCounter+1
		curRelListAddr = curRelListAddr+1
		readByte = memory.readbyte(curRelListAddr)
	end

	--[[
	for k,v in pairs(CurSpriteData.RelPos) do
		print(string.format("[Sprite %i] x:%i y:%i",k,v.X,v.Y))
	end
	--]]

	-- once 0xAA has been read, we can determine how many tiles are used
	CurAnimNumTiles = listCounter/2
	print(string.format("number of tiles: %i",CurAnimNumTiles))

	-- 0x02: currently unknown attribute byte 1
	local attrib1 = memory.readbyte(addr+2)
	CurSpriteData.Attrib1 = attrib1
	-- 0x03: currently unknown attribute byte 2
	local attrib2 = memory.readbyte(addr+3)
	CurSpriteData.Attrib2 = attrib2

	-- 0x04-end: tile numbers. length is determined by relative position list
	local tilesAddr = addr+4
	CurSpriteData.Tiles = {} -- reset table
	for i=1,CurAnimNumTiles do
		table.insert(CurSpriteData.Tiles,memory.readbyte(tilesAddr+(i-1)))
	end
	--[[
	for k,v in pairs(CurSpriteData.Tiles) do
		print(string.format("[Sprite %i] tile 0x%02X",k,v))
	end
	--]]

	-- part 2: displaying the sprite.
	local oamAddr = BaseSprAddress
	local curSprIndex = StartingSpriteIndex
	for i=1,CurAnimNumTiles do
		local curRelPos = CurSpriteData.RelPos[i]

		--[[
		print(
			string.format(
				"[%02i] tile 0x%02X; relative X: %i; relative Y: %i",
				i,CurSpriteData.Tiles[i],curRelPos.X,curRelPos.Y
			)
		)
		--]]

		memory.writebyte(oamAddr,SpriteDisplayY+curRelPos.Y)
		memory.writebyte(oamAddr+1,CurSpriteData.Tiles[i])

		-- attributes are calculated from two bytes in the metasprite
		-- palette is normally taken from byte at $B7, which won't be set here...
		local sprAttrib = 0
		local flipBit = 0
		if i < 9 then
			flipBit = AND(CurSpriteData.Attrib1,tileFlipMasks[i])
			if flipBit > 0 then
				sprAttrib = XOR(sprAttrib,0x40)
			end
		else
			flipBit = AND(CurSpriteData.Attrib2,tileFlipMasks[i-8])
			if flipBit > 0 then
				sprAttrib = XOR(sprAttrib,0x40)
			end
		end
		memory.writebyte(oamAddr+2,sprAttrib)

		memory.writebyte(oamAddr+3,SpriteDisplayX+curRelPos.X)

		-- update
		oamAddr = oamAddr+4
		curSprIndex = curSprIndex+1
	end

	for i=(63-CurAnimNumTiles),63 do
		ClearSprite(i)
	end
end

--============================================================================--
-- [User Interface]
--============================================================================--
-- ui defines
local UILayout = {
	PrevAnim = {
		box_x = 96,
		box_y = 172,
		box_w = 12,
		box_h = 12,
		label = "<"
	},
	ClearAnim = {
		box_x = 112,
		box_y = 172,
		box_w = 32,
		box_h = 12,
		label = "Clear"
	},
	NextAnim = {
		box_x = 148,
		box_y = 172,
		box_w = 12,
		box_h = 12,
		label = ">"
	},
}

-- Display the interface
local function DisplayInterface()
	gui.text(84,200,"Sprite Viewer Mode","white","clear")

	-- box prev anim
	gui.box(
		UILayout.PrevAnim.box_x,
		UILayout.PrevAnim.box_y,
		UILayout.PrevAnim.box_x+UILayout.PrevAnim.box_w,
		UILayout.PrevAnim.box_y+UILayout.PrevAnim.box_h,
		"blue"
	)
	-- text prev anim
	gui.text(
		UILayout.PrevAnim.box_x+4,
		UILayout.PrevAnim.box_y+3,
		UILayout.PrevAnim.label,
		"white","clear"
	)

	-- box clear anim
	gui.box(
		UILayout.ClearAnim.box_x,
		UILayout.ClearAnim.box_y,
		UILayout.ClearAnim.box_x+UILayout.ClearAnim.box_w,
		UILayout.ClearAnim.box_y+UILayout.ClearAnim.box_h,
		"blue"
	)
	-- text clear anim
	gui.text(
		UILayout.ClearAnim.box_x+6,
		UILayout.ClearAnim.box_y+3,
		UILayout.ClearAnim.label,
		"white","clear"
	)

	-- box next anim
	gui.box(
		UILayout.NextAnim.box_x,
		UILayout.NextAnim.box_y,
		UILayout.NextAnim.box_x+UILayout.NextAnim.box_w,
		UILayout.NextAnim.box_y+UILayout.NextAnim.box_h,
		"blue"
	)
	-- text next anim
	gui.text(
		UILayout.NextAnim.box_x+5,
		UILayout.NextAnim.box_y+3,
		UILayout.NextAnim.label,
		"white","clear"
	)
end

-- DisplaySpriteData:
local function DisplaySpriteData()
	-- metasprite number
	gui.text(8,16,string.format("mspr 0x%02X",CurAnimNumber),"white","clear")

	-- metasprite pointer
	gui.text(8,24,string.format("data addr 0x%04X",CurSpriteData.MainPointer),"white","clear")

	-- relative list pointer
	gui.text(8,36,string.format("relpos\n0x%04X",CurSpriteData.AddrRelativePos),"white","clear")

	-- relative list data
	local relListY = 48
	for k,v in pairs(CurSpriteData.RelPos) do
		gui.text(8,relListY+(k*8),string.format("[%02i] x:%i\ty:%i",k,v.X,v.Y),"white","clear")
	end

	-- unknown byte 1
	gui.text(120,18,string.format("attr1 0x%02X",CurSpriteData.Attrib1),"white","clear")
	-- unknown byte 2
	gui.text(180,18,string.format("attr2 0x%02X",CurSpriteData.Attrib2),"white","clear")
end

-- PrevAnim: Switch to previous animation
local function PrevAnim()
	-- get current animation number
	if CurAnimNumber == 0 then
		-- wrap around
		CurAnimNumber = 62
	else
		CurAnimNumber = CurAnimNumber - 1
	end

	-- update animation
	ReadMetasprite(CurAnimNumber)
end

-- NextAnim: Switch to next animation
local function NextAnim()
	-- get current animation number
	if CurAnimNumber == 62 then
		-- wrap around
		CurAnimNumber = 0
	else
		CurAnimNumber = CurAnimNumber + 1
	end

	-- update animation
	ReadMetasprite(CurAnimNumber)
end

local function CheckUIClick(uiInput)
	-- get input
	local mouseX = uiInput.xmouse
	local mouseY = uiInput.ymouse

	-- check for click on previous
	if mouseX >= UILayout.PrevAnim.box_x
	and mouseX <= UILayout.PrevAnim.box_x+UILayout.PrevAnim.box_w
	and mouseY >= UILayout.PrevAnim.box_y
	and mouseY <= UILayout.PrevAnim.box_y+UILayout.PrevAnim.box_y
	then
		-- do previous
		PrevAnim()
	end

	-- check for click on clear
	if mouseX >= UILayout.ClearAnim.box_x
	and mouseX <= UILayout.ClearAnim.box_x+UILayout.ClearAnim.box_w
	and mouseY >= UILayout.ClearAnim.box_y
	and mouseY <= UILayout.ClearAnim.box_y+UILayout.ClearAnim.box_h
	then
		-- clear and reload
		ClearAllSprites()
		ReadMetasprite(CurAnimNumber)
	end

	-- check for click on next
	if mouseX >= UILayout.NextAnim.box_x
	and mouseX <= UILayout.NextAnim.box_x+UILayout.NextAnim.box_w
	and mouseY >= UILayout.NextAnim.box_y
	and mouseY <= UILayout.NextAnim.box_y+UILayout.NextAnim.box_y
	then
		-- do next
		NextAnim()
	end
end

--============================================================================--
-- [Helper Functions]
--============================================================================--
-- ForceTitle: perform some magic to stay on the title screen forever
local function ForceTitle()
	-- kill attract timer
	memory.writebyte(0x0025,0xFF)

	-- kill start button
	local input = joypad.getimmediate(1)
	if input.start then
		input.start = false
	end
	joypad.set(1,input)
end

-- OnExit: Restore display when exiting script
local function OnExit()
	ClearAllSprites()
	emu.setrenderplanes(true,true)
end

--============================================================================--
-- main script begins here
--============================================================================--
-- input states
local uiInput = nil
local lastInput = nil

-- begin with first metasprite
ReadMetasprite(0)

emu.setrenderplanes(true,false)
emu.registerexit(OnExit)

while true do
	-- do hack(s) to force title screen
	ForceTitle()

	-- draw metasprite data
	DisplaySpriteData()

	-- draw interface base
	DisplayInterface()

	-- check for clicks
	uiInput = input.get()
	if uiInput.leftclick and not lastInput.leftclick then
		CheckUIClick(uiInput)
	end
	lastInput = uiInput

	-- end
	FCEU.frameadvance();
end
