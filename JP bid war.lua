-- UNIT ITEM / BID ESP + TOTAL VALUE (200 STUD RADIUS)
-- Script Author: Adii
-- Status: Personal Build (Testing Phase)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ================= CONFIG =================
local VALUE_KEYS = {
	"Value",
	"Price",
	"Cost",
	"Bid",
	"BidValue",
	"Worth",
	"Amount"
}

local ESP_COLOR = Color3.fromRGB(255, 170, 0)
local TEXT_SIZE = 14
local SCAN_RADIUS = 200 -- studs

-- ================= STATE =================
local trackedItems = {}
local totalValue = 0

-- ================= TOTAL VALUE UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "TotalValueUI"
gui.Parent = game.CoreGui

local totalLabel = Instance.new("TextLabel")
totalLabel.Parent = gui
totalLabel.Size = UDim2.new(0, 280, 0, 38)
totalLabel.Position = UDim2.new(0.5, -140, 0, 12)
totalLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
totalLabel.BackgroundTransparency = 0.2
totalLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
totalLabel.TextStrokeTransparency = 0
totalLabel.Font = Enum.Font.SourceSansBold
totalLabel.TextSize = 16
totalLabel.Text = "TOTAL VALUE: ₹0"

Instance.new("UICorner", totalLabel)

local function updateTotal()
	totalLabel.Text = "TOTAL VALUE: ₹" .. totalValue
end

-- ================= UTILS =================
local function getRoot()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getValueObject(obj)
	for _, key in ipairs(VALUE_KEYS) do
		local val = obj:FindFirstChild(key, true)
		if val and (val:IsA("IntValue") or val:IsA("NumberValue")) then
			return val
		end
	end
end

local function getPart(obj)
	if obj:IsA("Model") then
		return obj:FindFirstChildWhichIsA("BasePart", true)
	elseif obj:IsA("BasePart") then
		return obj
	end
end

-- ================= ESP =================
local function createESP(item, valueObj, part)
	local bb = Instance.new("BillboardGui")
	bb.Name = "ItemESP"
	bb.Adornee = part
	bb.Size = UDim2.new(0, 220, 0, 36)
	bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = item

	local txt = Instance.new("TextLabel")
	txt.Parent = bb
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.TextStrokeTransparency = 0
	txt.Font = Enum.Font.SourceSansBold
	txt.TextSize = TEXT_SIZE
	txt.TextColor3 = ESP_COLOR
	txt.Text = item.Name .. " | ₹" .. valueObj.Value

	valueObj:GetPropertyChangedSignal("Value"):Connect(function()
		txt.Text = item.Name .. " | ₹" .. valueObj.Value
	end)
end

-- ================= SCAN LOOP =================
task.spawn(function()
	while task.wait(0.7) do
		local root = getRoot()
		if not root then continue end

		local found = 0
		local newTotal = 0

		for _, obj in ipairs(workspace:GetDescendants()) do
			if Players:GetPlayerFromCharacter(obj) then continue end

			local part = getPart(obj)
			if not part or part.Transparency >= 1 then continue end

			if (part.Position - root.Position).Magnitude > SCAN_RADIUS then
				continue
			end

			local valueObj = getValueObject(obj)
			if not valueObj then continue end

			found += 1
			newTotal += valueObj.Value

			if not trackedItems[obj] then
				trackedItems[obj] = true
				createESP(obj, valueObj, part)
			end
		end

		-- Auto reset when round clears
		if found == 0 then
			trackedItems = {}
			totalValue = 0
		else
			totalValue = newTotal
		end

		updateTotal()
	end
end)

-- ================= NOTIFICATION =================
pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "Item ESP Loaded",
		Text = "Made by Harry • Still in testing",
		Duration = 6
	})
end)
