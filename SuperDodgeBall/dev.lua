-- settings
local showScrollVals=false

while true do
	if showScrollVals then
		--[[ scroll values ]]
		-- x/y bg scroll ($FD,$FC)
		local bgScrX = memory.readbyte(0xFD)
		local bgScrY = memory.readbyte(0xFC)
		-- x/y spr scroll ($C3,$C4)
		local sprScrX = memory.readbyte(0xC3)
		local sprScrY = memory.readbyte(0xC4)
		gui.text(0,224,string.format("bgX:%02X/bgY:%02X | spX:%02X/spY:%02X",bgScrX,bgScrY,sprScrX,sprScrY))
	end

	--gui.text(0,216,string.format("mus.spd:%02X",memory.readbyte(0x0717)))

	if memory.readbyte(0x034D) == 2 then
		-- in-match

		-- attack strength
		gui.text(212,224,string.format("atk:%02d",memory.readbyte(0xce)))

		-- anything not in bean ball mode
		if memory.readbyte(0x70) == 0x00 or memory.readbyte(0x70) == 0x20 then
			--[[ p1-1 location ]]
			--[[
			local p1X1 = memory.readbyte(0xBE)
			local p1X2 = memory.readbyte(0xBF)
			local p1Y = memory.readbyte(0xC0)
			gui.text(0,216,string.format("1-1x:%02X,%02X/1-1y:%02X",p1X1,p1X2,p1Y))
			--]]

			--[[ team energy (non bean-ball mode) --]]
			-- p1 team energy
			local energyP1_1 = memory.readbyte(0x058B)
			gui.text(64,16,energyP1_1)
			local energyP1_2 = memory.readbyte(0x0553)
			gui.text(64,24,energyP1_2)
			local energyP1_3 = memory.readbyte(0x051B)
			gui.text(64,32,energyP1_3)

			-- p2 team energy
			local energyP2_1 = memory.readbyte(0x043B)
			gui.text(176,16,energyP2_1)
			local energyP2_2 = memory.readbyte(0x0403)
			gui.text(176,24,energyP2_2)
			local energyP2_3 = memory.readbyte(0x03CB)
			gui.text(176,32,energyP2_3)
		end

	-- bean ball stuff
	elseif memory.readbyte(0x70) == 0x40 then
		-- sam
		local energy1 = memory.readbyte(0x0323)
		gui.text(64,16,energy1)
		-- mike
		local energy2 = memory.readbyte(0x0393)
		gui.text(64,24,energy2)
		-- randy
		local energy3 = memory.readbyte(0x0403)
		gui.text(64,32,energy3)
		-- john
		local energy4 = memory.readbyte(0x035b)
		gui.text(176,16,energy4)
		-- bill
		local energy5 = memory.readbyte(0x03cb)
		gui.text(176,24,energy5)
		-- steve
		local energy6 = memory.readbyte(0x043b)
		gui.text(176,32,energy6)
	end

	-- hand control back to the emulator
	emu.frameadvance();
end
