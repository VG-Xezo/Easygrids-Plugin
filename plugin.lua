local toolbar = plugin:CreateToolbar("Easy Grids")

local GridPluginIcon = toolbar:CreateButton("Easy Grids", "Easily Create Grids", "rbxassetid://8737858272")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Opened = false

local spacing = 0

local partSize = Vector3.new(1,1,1)

local customPart = nil

local GridSizeX = 0
local GridSizeZ = 0

local GridWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	800,    -- Default width of the floating window
	600,    -- Default height of the floating window
	800,    -- Minimum width of the floating window (optional)
	600     -- Minimum height of the floating window (optional)
)

local GridWidget = plugin:CreateDockWidgetPluginGui("EasyGrids", GridWidgetInfo)
GridWidget.Title = "Easy Grids"

local pluginGui = script:WaitForChild("PluginFrame")
pluginGui.Parent = GridWidget

local RowSizeXBox = pluginGui.GridSettings.RowSizeX
local RowSizeZBox = pluginGui.GridSettings.RowSizeZ
local SpacingBox = pluginGui.GridSettings.Spacing

local PartSizeXBox = pluginGui.PartSettings.PartSizeX
local PartSizeYBox = pluginGui.PartSettings.PartSizeY
local PartSizeZBox = pluginGui.PartSettings.PartSizeZ

local CustomPartSelection = pluginGui.PartSettings.CustomPart

local PlayerMessages = pluginGui.PlayerMessages

local GenerateButton = pluginGui.GenerateButton

function alertPlayer(message, messageType)
	PlayerMessages.Text = message
	PlayerMessages.Visible = true

	if messageType == "Error" then
		PlayerMessages.TextColor3 = Color3.fromRGB(255, 0, 0)
	end

	if messageType == "Success" then
		PlayerMessages.TextColor3 = Color3.fromRGB(85, 170, 127)
	end
	
	task.wait(5)
	
	PlayerMessages.Visible = false
end

function generateGrid()
	local gridPartsFolder = Instance.new("Folder")
	gridPartsFolder.Parent = game.Workspace
	gridPartsFolder.Name = "EasyGrids_GridGeneration"
	
	local lastPartPosX = nil
	local lastPartPosZ = nil
	
	for x = 1, GridSizeX, 1 do
		
		local GridPart
		
		if customPart then
			GridPart = customPart:Clone()
			GridPart.Parent = gridPartsFolder
			GridPart.Name = "GridPartX_" .. tostring(x) .. "Z_1"
		else
			GridPart = Instance.new("Part")
			GridPart.Parent = gridPartsFolder
			GridPart.Name = "GridPartX_" .. tostring(x) .. "Z_1"
			GridPart.Size = partSize	
		end
		
		if not lastPartPosX then
			
			local partPosition = Vector3.new(0,0,0)
			
			if GridPart:IsA("Model") then
				GridPart:MoveTo(partPosition)
			else
				GridPart.Position = partPosition
			end
			
			lastPartPosX = partPosition
		else
			
			local partPosition = Vector3.new(lastPartPosX.X + spacing, 0, 0)
			
			if GridPart:IsA("Model") then
				GridPart:MoveTo(partPosition)
			else
				GridPart.Position = partPosition
			end

			lastPartPosX = partPosition
		end
		for z = 1, GridSizeZ - 1, 1 do
			
			local GridPart

			if customPart then
				GridPart = customPart:Clone()
				GridPart.Parent = gridPartsFolder
				GridPart.Name = "GridPartX_" .. tostring(x) .. "Z_" .. tostring(z)
			else
				GridPart = Instance.new("Part")
				GridPart.Parent = gridPartsFolder
				GridPart.Name = "GridPartX_" .. tostring(x) .. "Z_" .. tostring(z)
				GridPart.Size = partSize	
			end
			
			if not lastPartPosZ then				
				local partPosition = Vector3.new(lastPartPosX.X,0, spacing)

				if GridPart:IsA("Model") then
					GridPart:MoveTo(partPosition)
				else
					GridPart.Position = partPosition
				end

				lastPartPosZ = partPosition
				
			else				
				local partPosition = Vector3.new(lastPartPosX.X, 0, lastPartPosZ.Z + spacing)

				if GridPart:IsA("Model") then
					GridPart:MoveTo(partPosition)
				else
					GridPart.Position = partPosition
				end

				lastPartPosZ = partPosition
			end

		end
		lastPartPosZ = nil
	end
	
	alertPlayer("Generated Grid!", "Success")
	ChangeHistoryService:SetWaypoint("Generated Grid")
end

function validateInfo()
	if #RowSizeXBox.Text > 0 then
		if tonumber(RowSizeXBox.Text) > 0 then
			GridSizeX = tonumber(RowSizeXBox.Text)
		else
			alertPlayer("Grid Settings Must Be >0!", "Error")
			return
		end
	else
		alertPlayer("Missing Grid Settings!", "Error")
		return
	end
	
	if #RowSizeZBox.Text > 0 then
		if tonumber(RowSizeZBox.Text) > 0 then
			GridSizeZ = tonumber(RowSizeZBox.Text)
		else
			alertPlayer("Grid Settings Must Be >0!", "Error")
			return
		end
	else
		alertPlayer("Missing Grid Settings!", "Error")
		return
	end
	
	if #SpacingBox.Text > 0 then
		if tonumber(SpacingBox.Text) > 0 then
			spacing = tonumber(SpacingBox.Text)
		else
			alertPlayer("Grid Settings Must Be >0!", "Error")
			return
		end
	else
		alertPlayer("Missing Grid Settings!", "Error")
		return
	end
	
	if #PartSizeXBox.Text > 0 and #PartSizeYBox.Text > 0 and #PartSizeZBox.Text > 0 then
		if tonumber(PartSizeXBox.Text) > 0 and tonumber(PartSizeYBox.Text) > 0 and tonumber(PartSizeZBox.Text) > 0 then
			partSize = Vector3.new(tonumber(PartSizeXBox.Text), tonumber(PartSizeYBox.Text), tonumber(PartSizeZBox.Text))
		else
			alertPlayer("Part Settings Must Be >0!", "Error")
			return
		end
	else
		if not customPart then
			alertPlayer("Missing Part Settings!", "Error")
			return
		end
	end
	
	generateGrid()
end

function openGui()
	if Opened then
		customPart = nil
		GridWidget.Enabled = false
		Opened = false
	else
		GridWidget.Enabled = true
		Opened = true
	end
	
end

function getCustomPart()
	local selectionCustomPart = Selection:Get()
	
	if #selectionCustomPart == 1 then
		if selectionCustomPart[1]:IsA("Model") or selectionCustomPart[1]:IsA("Union") or selectionCustomPart[1]:IsA("Part") then
			customPart = selectionCustomPart[1]
			alertPlayer("Selected Custom Part!", "Success")
		else
			alertPlayer("Sorry, EasyGrids doesnt support that part type!", "Error")
		end
	else
		customPart = nil
		alertPlayer("Please Select A Part!", "Error")
		return
	end
end

CustomPartSelection.MouseButton1Click:Connect(getCustomPart)
GenerateButton.MouseButton1Click:Connect(validateInfo)
GridPluginIcon.Click:Connect(openGui)
