-- set to 'false' to disable middle-screen text
local show_big_threat = true

-- Let's make output frame
local BTMessageFrame 

local function createMessageFrame()
	if BTMessageFrame then return end
	BTMessageFrame = CreateFrame("MessageFrame", "BTMessageFrame", UIParent)
	BTMessageFrame:SetWidth(512)
	BTMessageFrame:SetHeight(80)
	
	BTMessageFrame:SetPoint("CENTER")
	BTMessageFrame:SetScale(1)
	BTMessageFrame:SetInsertMode("TOP")
	BTMessageFrame:SetFrameStrata("HIGH")
	BTMessageFrame:SetToplevel(true)
	BTMessageFrame:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
	BTMessageFrame:Show()
	BTMessageFrame:SetFadeDuration(2)
	BTMessageFrame:SetTimeVisible(0)
end

-- main addon
local threat = LibStub("LibDataBroker-1.1"):NewDataObject("Threat", { icon = "Interface\\Icons\\Ability_Warrior_FocusedRage", type = "data source", text = "" })

local eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, arg1) 
	if event == "ADDON_LOADED" then createMessageFrame()
	elseif event == "UNIT_THREAT_SITUATION_UPDATE" then threat:update(arg1)
	elseif event == "UNIT_THREAT_LIST_UPDATE" then threat:update(arg1)
	end
end)

local last_status = 0
local mob_name = ""
--[[
0 - none
1 - aggro
2 - 130%
3 - 110%
4 - 100%
5 - 90%
]]

local function out_message(current_status, ...)
	if show_big_threat == false then return end
	if current_status == last_status then return end
	
	local a = 1
	local ttl = 5
	
	if last_status == 1 then
		BTMessageFrame:AddMessage("- AGGRO -", 1, 1, 1, a, ttl)
	end
	
	last_status = current_status;
	
	local arg = {...}
	
	local r, g, b, a = 1, 1, 1, 1
	if(arg[1]) then r = arg[1] end
	if(arg[2]) then g = arg[2] end
	if(arg[3]) then b = arg[3] end
	
	if last_status == 2 then
		BTMessageFrame:AddMessage("130%", r, g, b, a, ttl)
	elseif last_status == 3 then
		BTMessageFrame:AddMessage("110%", r, g, b, a, ttl)
	elseif last_status == 4 then
		BTMessageFrame:AddMessage("100%", r, g, b, a, ttl)
	elseif last_status == 5 then
		BTMessageFrame:AddMessage("90%", r, g, b, a, ttl)
	elseif last_status == 1 then
		BTMessageFrame:AddMessage("+ AGGRO +", r, g, b, a, ttl)
	end
end

function threat:update(unit)
	if unit ~= "player" and unit ~= "target" then return end
	
	local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", "target")
	local r, g, b = 1,1,1
	if status and status > 0 then r, g, b = GetThreatStatusColor(status) end
	if isTanking == 1 then
		threat.text = "|cffff0000AGGRO|r"
		out_message(1, 1, 0, 0)
	elseif rawthreatpct == 0 or rawthreatpct == nil then
		threat.text = ""
		out_message(0, 0, 0, 0)
	else
		if rawthreatpct >= 130 then
			out_message(2, r, g, b)
		elseif rawthreatpct >= 110 then	
			out_message(3, r, g, b)
		elseif rawthreatpct >= 100 then
			out_message(4, r, g, b)
		elseif rawthreatpct >= 90 then
			out_message(5, r, g, b)
		else
			out_message(0)
		end
		threat.text = string.format("|cff%02x%02x%02x%d%%|r", r*255, g*255, b*255, rawthreatpct)
	end
end

