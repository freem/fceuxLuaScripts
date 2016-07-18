-- enhanced HUD for R.C. Pro-Am

Labels = {
	Rank_Red = 0x005C,
	Rank_Green = 0x005D,
	Rank_Orange = 0x005E,
	Rank_Blue = 0x005F,
	OrangeCarCounter = 0x0093,
	GameActive = 0x03F6,
	CurLevelNum = 0x044B,
	CurLoopNum = 0x044C,
	CurTrackNum = 0x044D,
	NumLapsRace = 0x044E,
	RaceFinished = 0x0450,
	Upgrade_Tire = 0x0453,
	Upgrade_Accel = 0x0454,
	Upgrade_Engine = 0x0455,
	CurAmmo = 0x0459,
	NumContinues = 0x045B,
	Checkpoint_Red = 0x053C,
	Checkpoint_Green = 0x053D,
	Checkpoint_Orange = 0x053E,
	Checkpoint_Blue = 0x053F,
	SubSpeed_Red = 0x05D8,
	SubSpeed_Green = 0x05D9,
	SubSpeed_Orange = 0x05DA,
	SubSpeed_Blue = 0x05DB,
	MainSpeed_Red = 0x05DC,
	MainSpeed_Green = 0x05DD,
	MainSpeed_Orange = 0x05DE,
	MainSpeed_Blue = 0x05DF,
	Laps_Red = 0x05FC,
	Laps_Green = 0x05FD,
	Laps_Orange = 0x05FE,
	Laps_Blue = 0x05FF,
	MaxSpeed_Red = 0x0604,
	MaxSpeed_Green = 0x0605,
	MaxSpeed_Orange = 0x0606,
	MaxSpeed_Blue = 0x0607,
	OrangeCarIsMad = 0x061A,
}

local function DrawOrangeCarCounter()
	local orangeCarCount = memory.readbyte(Labels.OrangeCarCounter)
	if memory.readbyte(Labels.OrangeCarIsMad) > 0 then
		gui.text(168,169,"ORANGE CAR MAD","P26","P0F")
	else
		gui.text(198,169,string.format("DANGER: %02d",orangeCarCount),"P26","P0F")
	end
end

local function DrawLapInfo_HUD()
	gui.rect(16,215,64,224,"P0F","P0F")
	gui.text(16,216,string.format("%dL",memory.readbyte(Labels.NumLapsRace)),"P30","P0F")
	gui.text(28+8,216,memory.readbyte(Labels.Laps_Red)+1,"P16","P0F")
	gui.text(28+16,216,memory.readbyte(Labels.Laps_Green)+1,"P2A","P0F")
	gui.text(28+24,216,memory.readbyte(Labels.Laps_Orange)+1,"P27","P0F")
	gui.text(28+32,216,memory.readbyte(Labels.Laps_Blue)+1,"P22","P0F")
end

local function DrawLevelInfo_HUD()
	local gameLevel = memory.readbyte(Labels.CurLevelNum)
	local trackLevel = memory.readbyte(Labels.CurTrackNum)
	local levelText = string.format("LV:%d T:%d",gameLevel+1,trackLevel)
	gui.text(16,224,levelText,"P26","P0F")
end

local function DrawSpeeds_HUD()
	local formatString = "%03d/%03d"
	local mainRed = memory.readbyte(Labels.MainSpeed_Red)
	local maxRed = memory.readbyte(Labels.MaxSpeed_Red)
	gui.text(200,184,string.format(formatString,mainRed,maxRed),"P16","P0F")
	local mainGreen = memory.readbyte(Labels.MainSpeed_Green)
	local maxGreen = memory.readbyte(Labels.MaxSpeed_Green)
	gui.text(200,192,string.format(formatString,mainRed,maxRed),"P2A","P0F")
	local mainOrange = memory.readbyte(Labels.MainSpeed_Orange)
	local maxOrange = memory.readbyte(Labels.MaxSpeed_Orange)
	gui.text(200,200,string.format(formatString,mainRed,maxRed),"P27","P0F")
	local mainBlue = memory.readbyte(Labels.MainSpeed_Blue)
	local maxBlue = memory.readbyte(Labels.MaxSpeed_Blue)
	gui.text(200,208,string.format(formatString,mainBlue,maxBlue),"P22","P0F")
end

while true do
	if memory.readbyte(Labels.GameActive) > 0 then
		if memory.readbyte(Labels.RaceFinished) == 0 then
			DrawOrangeCarCounter()
			DrawLapInfo_HUD()
			DrawLevelInfo_HUD()
			DrawSpeeds_HUD()
		end
	end

	emu.frameadvance();
end
