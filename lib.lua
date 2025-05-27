local finity = {}
finity.gs = {}

finity.theme = { -- light
	main_container = Color3.fromRGB(249, 249, 255),
	separator_color = Color3.fromRGB(223, 219, 228),

	text_color = Color3.fromRGB(96, 96, 96),

	category_button_background = Color3.fromRGB(223, 219, 228),
	category_button_border = Color3.fromRGB(200, 196, 204),

	checkbox_checked = Color3.fromRGB(114, 214, 112),
	checkbox_outer = Color3.fromRGB(198, 189, 202),
	checkbox_inner = Color3.fromRGB(249, 239, 255),

	slider_color = Color3.fromRGB(114, 214, 112),
	slider_color_sliding = Color3.fromRGB(114, 214, 112),
	slider_background = Color3.fromRGB(198, 188, 202),
	slider_text = Color3.fromRGB(112, 112, 112),

	textbox_background = Color3.fromRGB(198, 189, 202),
	textbox_background_hover = Color3.fromRGB(215, 206, 227),
	textbox_text = Color3.fromRGB(112, 112, 112),
	textbox_text_hover = Color3.fromRGB(50, 50, 50),
	textbox_placeholder = Color3.fromRGB(178, 178, 178),

	dropdown_background = Color3.fromRGB(198, 189, 202),
	dropdown_text = Color3.fromRGB(112, 112, 112),
	dropdown_text_hover = Color3.fromRGB(50, 50, 50),
	dropdown_scrollbar_color = Color3.fromRGB(198, 189, 202),
	
	button_background = Color3.fromRGB(198, 189, 202),
	button_background_hover = Color3.fromRGB(215, 206, 227),
	button_background_down = Color3.fromRGB(178, 169, 182),
	
	scrollbar_color = Color3.fromRGB(198, 189, 202),
}

finity.dark_theme = { -- dark
	main_container = Color3.fromRGB(32, 32, 33),
	separator_color = Color3.fromRGB(63, 63, 65),

	text_color = Color3.fromRGB(206, 206, 206),

	category_button_background = Color3.fromRGB(63, 62, 65),
	category_button_border = Color3.fromRGB(72, 71, 74),

	checkbox_checked = Color3.fromRGB(132, 255, 130),
	checkbox_outer = Color3.fromRGB(84, 81, 86),
	checkbox_inner = Color3.fromRGB(132, 132, 136),

	slider_color = Color3.fromRGB(177, 177, 177),
	slider_color_sliding = Color3.fromRGB(132, 255, 130),
	slider_background = Color3.fromRGB(88, 84, 90),
	slider_text = Color3.fromRGB(177, 177, 177),

	textbox_background = Color3.fromRGB(103, 103, 106),
	textbox_background_hover = Color3.fromRGB(137, 137, 141),
	textbox_text = Color3.fromRGB(195, 195, 195),
	textbox_text_hover = Color3.fromRGB(232, 232, 232),
	textbox_placeholder = Color3.fromRGB(135, 135, 138),

	dropdown_background = Color3.fromRGB(88, 88, 91),
	dropdown_text = Color3.fromRGB(195, 195, 195),
	dropdown_text_hover = Color3.fromRGB(232, 232, 232),
	dropdown_scrollbar_color = Color3.fromRGB(118, 118, 121),
	
	button_background = Color3.fromRGB(103, 103, 106),
	button_background_hover = Color3.fromRGB(137, 137, 141),
	button_background_down = Color3.fromRGB(70, 70, 81),
	
	scrollbar_color = Color3.fromRGB(118, 118, 121),
}

setmetatable(finity.gs, {
	__index = function(_, service)
		return game:GetService(service)
	end,
	__newindex = function(t, i)
		t[i] = nil
		return
	end
})


local mouse = finity.gs["Players"].LocalPlayer:GetMouse()

function finity:Create(class, properties)
	local object = Instance.new(class)

	for prop, val in next, properties do
		if object[prop] and prop ~= "Parent" then
			object[prop] = val
		end
	end

	return object
end

function finity:addShadow(object, transparency)
	local shadow = self:Create("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 4),
		Size = UDim2.new(1, 6, 1, 6),
		Image = "rbxassetid://1316045217",
		ImageTransparency = transparency and true or 0.5,
		ImageColor3 = Color3.fromRGB(35, 35, 35),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118)
	})

	shadow.Parent = object
end

function finity.new(isdark, gprojectName, thinProject)
	local finityObject = {}
	local self2 = finityObject
	local self = finity

	-- Configuration Management
	local configs = {}
	local currentConfig = "default"
	local autoSave = true
	local configFolder = "FinityConfigs"
	
	-- Create config folder if it doesn't exist
	if not isfolder(configFolder) then
		makefolder(configFolder)
	end

	-- Configuration Functions
	self2.SaveConfig = function(name)
		name = name or currentConfig
		local config = {
			Theme = isdark and "Dark" or "Light",
			WindowState = {
				Position = self2.container.Position,
				Size = self2.container.Size,
				Minimized = minimized,
				Maximized = maximized
			},
			Settings = {}
		}
		
		-- Save all UI element states
		for _, category in pairs(self2.categories:GetChildren()) do
			if category:IsA("ScrollingFrame") then
				for _, element in pairs(category:GetDescendants()) do
					if element:IsA("TextButton") or element:IsA("TextBox") then
						config.Settings[element.Name] = {
							Value = element.Text,
							Visible = element.Visible
						}
					end
				end
			end
		end
		
		writefile(configFolder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
		configs[name] = config
	end

	self2.LoadConfig = function(name)
		name = name or currentConfig
		local success, config = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile(configFolder .. "/" .. name .. ".json"))
		end)
		
		if success and config then
			-- Apply theme
			if config.Theme == "Dark" and not isdark then
				isdark = true
				theme = finity.dark_theme
			elseif config.Theme == "Light" and isdark then
				isdark = false
				theme = finity.theme
			end
			
			-- Apply window state
			if config.WindowState then
				self2.container.Position = config.WindowState.Position
				self2.container.Size = config.WindowState.Size
				minimized = config.WindowState.Minimized
				maximized = config.WindowState.Maximized
			end
			
			-- Apply settings
			if config.Settings then
				for name, setting in pairs(config.Settings) do
					local element = self2.container:FindFirstChild(name, true)
					if element then
						element.Text = setting.Value
						element.Visible = setting.Visible
					end
				end
			end
			
			configs[name] = config
			currentConfig = name
		end
	end

	self2.DeleteConfig = function(name)
		if name == "default" then return end
		if delfile(configFolder .. "/" .. name .. ".json") then
			configs[name] = nil
		end
	end

	self2.ListConfigs = function()
		local list = {}
		for _, file in pairs(listfiles(configFolder)) do
			local name = string.match(file, "([^/]+)%.json$")
			if name then
				table.insert(list, name)
			end
		end
		return list
	end

	self2.SetAutoSave = function(enabled)
		autoSave = enabled
	end

	-- Auto-save on changes
	local function setupAutoSave()
		if autoSave then
			-- Use a delayed check to ensure UI elements are created
			task.spawn(function()
				task.wait(0.1) -- Small delay to ensure UI elements are created
				
				-- Save when window state changes
				if self2.container then
					self2.container:GetPropertyChangedSignal("Position"):Connect(function()
						self2.SaveConfig()
					end)
					
					self2.container:GetPropertyChangedSignal("Size"):Connect(function()
						self2.SaveConfig()
					end)
				end
				
				-- Save when UI elements change
				if self2.categories then
					for _, category in pairs(self2.categories:GetChildren()) do
						if category:IsA("ScrollingFrame") then
							for _, element in pairs(category:GetDescendants()) do
								if element:IsA("TextButton") or element:IsA("TextBox") then
									element:GetPropertyChangedSignal("Text"):Connect(function()
										self2.SaveConfig()
									end)
								end
							end
						end
					end
				end
			end)
		end
	end

	-- Load default config on startup
	self2.LoadConfig("default")
	
	-- Move setupAutoSave call to after UI initialization
	if not finity.gs["RunService"]:IsStudio() and self.gs["CoreGui"]:FindFirstChild("FinityUI") then
		self.gs["CoreGui"]:FindFirstChild("FinityUI"):Destroy()
	end

	local theme = finity.theme
	local projectName = false
	local thinMenu = false
	
	if isdark == true then theme = finity.dark_theme end
	if gprojectName then projectName = gprojectName end
	if thinProject then thinMenu = thinProject end
	
	local toggled = true
	local typing = false
	local firstCategory = true
    local savedposition = UDim2.new(0.5, 0, 0.5, 0)
    local minimized = false
    local maximized = false
    local originalSize = UDim2.new(0, 800, 0, 500)
    local originalPosition = UDim2.new(0.5, 0, 0.5, 0)
    local dragging = false
    local dragStart
    local startPos

	local finityData
	finityData = {
		UpConnection = nil,
		ToggleKey = Enum.KeyCode.Home,
		Minimized = false,
		Maximized = false,
		Dragging = false,
		Resizing = false,
		OriginalSize = originalSize,
		OriginalPosition = originalPosition
	}

	-- Window State Management
	local windowStates = {
		Normal = "Normal",
		Minimized = "Minimized",
		Maximized = "Maximized"
	}
	
	local currentState = windowStates.Normal
	local windowFocused = true
	local lastFocused = true
	local animationSpeed = 0.3
	local animationStyle = Enum.EasingStyle.Sine
	local animationDirection = Enum.EasingDirection.Out

	-- Window Animation Functions
	local function animateWindow(property, targetValue, duration)
		duration = duration or animationSpeed
		local tweenInfo = TweenInfo.new(duration, animationStyle, animationDirection)
		local tween = finity.gs["TweenService"]:Create(self2.container, tweenInfo, {[property] = targetValue})
		tween:Play()
		return tween
	end

	-- Window Focus Management
	local function updateWindowFocus()
		windowFocused = self2.container:IsMouseOver()
		if windowFocused ~= lastFocused then
			lastFocused = windowFocused
			if windowFocused then
				animateWindow("BackgroundTransparency", 0)
			else
				animateWindow("BackgroundTransparency", 0.1)
			end
		end
	end

	-- Window State Saving
	local function saveWindowState()
		local state = {
			Position = self2.container.Position,
			Size = self2.container.Size,
			State = currentState,
			Theme = isdark and "Dark" or "Light"
		}
		pcall(function()
			game:GetService("HttpService"):SetAsync("FinityUI_State", state)
		end)
	end

	local function loadWindowState()
		local success, state = pcall(function()
			return game:GetService("HttpService"):GetAsync("FinityUI_State")
		end)
		
		if success and state then
			if state.Theme == "Dark" and not isdark then
				isdark = true
				theme = finity.dark_theme
			elseif state.Theme == "Light" and isdark then
				isdark = false
				theme = finity.theme
			end
			
			if state.State == windowStates.Minimized then
				self2.Minimize()
			elseif state.State == windowStates.Maximized then
				self2.Maximize()
			end
			
			if state.Position and state.Size then
				self2.container.Position = state.Position
				self2.container.Size = state.Size
				originalSize = state.Size
				originalPosition = state.Position
			end
		end
	end

	-- Update window state management
	self2.Minimize = function()
		if currentState ~= windowStates.Minimized then
			currentState = windowStates.Minimized
			finityData.Minimized = true
			animateWindow("Size", UDim2.new(0, 800, 0, 30))
			animateWindow("Position", UDim2.new(0.5, 0, 1, -30))
			saveWindowState()
		else
			currentState = windowStates.Normal
			finityData.Minimized = false
			animateWindow("Size", originalSize)
			animateWindow("Position", originalPosition)
			saveWindowState()
		end
	end

	self2.Maximize = function()
		if currentState ~= windowStates.Maximized then
			currentState = windowStates.Maximized
			finityData.Maximized = true
			originalSize = self2.container.Size
			originalPosition = self2.container.Position
			animateWindow("Size", UDim2.new(1, -20, 1, -20))
			animateWindow("Position", UDim2.new(0.5, 0, 0.5, 0))
			saveWindowState()
		else
			currentState = windowStates.Normal
			finityData.Maximized = false
			animateWindow("Size", originalSize)
			animateWindow("Position", originalPosition)
			saveWindowState()
		end
	end

	-- Add focus update to RunService
	finity.gs["RunService"].RenderStepped:Connect(updateWindowFocus)

	-- Load saved state
	loadWindowState()

	-- Window Controls
	self2.Close = function()
		self2.userinterface:Destroy()
	end

	-- Window Controls UI
	local controls = self:Create("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -90, 0, 0),
		Size = UDim2.new(0, 90, 0, 30),
		ZIndex = 3
	})

	local minimizeButton = self:Create("TextButton", {
		Name = "Minimize",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Text = "─",
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.text_color,
		TextSize = 14,
		ZIndex = 3
	})

	local maximizeButton = self:Create("TextButton", {
		Name = "Maximize",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Text = "□",
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.text_color,
		TextSize = 14,
		ZIndex = 3
	})

	local closeButton = self:Create("TextButton", {
		Name = "Close",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 60, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.text_color,
		TextSize = 14,
		ZIndex = 3
	})

	-- Window Controls Events
	minimizeButton.MouseButton1Click:Connect(self2.Minimize)
	maximizeButton.MouseButton1Click:Connect(self2.Maximize)
	closeButton.MouseButton1Click:Connect(self2.Close)

	-- Window Dragging
	self2.container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < 30 then
			dragging = true
			dragStart = input.Position
			startPos = self2.container.Position
		end
	end)

	self2.container.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	self2.container.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if dragging then
				local delta = input.Position - dragStart
				local newPosition = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
				
				local snapPosition = checkSnap(newPosition)
				if snapPosition then
					animateWindow("Position", snapPosition)
				else
					self2.container.Position = newPosition
				end
			end
		end
	end)

	-- Window Resizing
	local resizeHandle = self:Create("Frame", {
		Name = "ResizeHandle",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -10, 1, -10),
		Size = UDim2.new(0, 10, 0, 10),
		ZIndex = 3
	})

	local resizing = false
	local resizeStart
	local startSize

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = self2.container.Size
		end
	end)

	resizeHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	resizeHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if resizing then
				local delta = input.Position - resizeStart
				local newSize = UDim2.new(
					startSize.X.Scale,
					math.max(400, startSize.X.Offset + delta.X),
					startSize.Y.Scale,
					math.max(300, startSize.Y.Offset + delta.Y)
				)
				self2.container.Size = newSize
			end
		end
	end)

	-- Add controls to UI
	controls.Parent = self2.container
	minimizeButton.Parent = controls
	maximizeButton.Parent = controls
	closeButton.Parent = controls
	resizeHandle.Parent = self2.container

	self2.ChangeToggleKey = function(NewKey)
		finityData.ToggleKey = NewKey
		
		if not projectName then
			self2.tip.Text = "Press '".. string.sub(tostring(NewKey), 14) .."' to hide this menu"
		end
		
		if finityData.UpConnection then
			finityData.UpConnection:Disconnect()
		end

		finityData.UpConnection = finity.gs["UserInputService"].InputEnded:Connect(function(Input)
			if Input.KeyCode == finityData.ToggleKey and not typing then
                toggled = not toggled

                pcall(function() self2.modal.Modal = toggled end)

                if toggled then
					pcall(self2.container.TweenPosition, self2.container, savedposition, "Out", "Sine", 0.5, true)
                else
                    savedposition = self2.container.Position;
					pcall(self2.container.TweenPosition, self2.container, UDim2.new(savedposition.Width.Scale, savedposition.Width.Offset, 1.5, 0), "Out", "Sine", 0.5, true)
				end
			end
		end)
	end
	
	self2.ChangeBackgroundImage = function(ImageID, Transparency)
		self2.container.Image = ImageID
		
		if Transparency then
			self2.container.ImageTransparency = Transparency
		else
			self2.container.ImageTransparency = 0.8
		end
	end

	finityData.UpConnection = finity.gs["UserInputService"].InputEnded:Connect(function(Input)
		if Input.KeyCode == finityData.ToggleKey and not typing then
			toggled = not toggled

			if toggled then
				self2.container:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Sine", 0.5, true)
			else
				self2.container:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), "Out", "Sine", 0.5, true)
			end
		end
	end)

	self2.userinterface = self:Create("ScreenGui", {
		Name = "FinityUI",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		ResetOnSpawn = false,
	})

	self2.container = self:Create("ImageLabel", {
		Draggable = true,
		Active = true,
		Name = "Container",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		BackgroundColor3 = theme.main_container,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 800, 0, 500),
		ZIndex = 2,
		ImageTransparency = 1
    })
    
    self2.modal = self:Create("TextButton", {
        Text = "";
        Transparency = 1;
        Modal = true;
    }) self2.modal.Parent = self2.userinterface;
	
	if thinProject and typeof(thinProject) == "UDim2" then
		self2.container.Size = thinProject
	end

	self2.container.Draggable = true
	self2.container.Active = true

	self2.sidebar = self:Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Color3.new(0.976471, 0.937255, 1),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.new(0.745098, 0.713726, 0.760784),
		Size = UDim2.new(0, 120, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		ZIndex = 2,
	})

	self2.categories = self:Create("Frame", {
		Name = "Categories",
		BackgroundColor3 = Color3.new(0.976471, 0.937255, 1),
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.new(0.745098, 0.713726, 0.760784),
		Size = UDim2.new(1, -120, 1, -30),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 30),
		ZIndex = 2,
	})
	self2.categories.ClipsDescendants = true

	self2.topbar = self:Create("Frame", {
		Name = "Topbar",
		ZIndex = 2,
		Size = UDim2.new(1,0,0,30),
		BackgroundTransparency = 2
	})

	self2.tip = self:Create("TextLabel", {
		Name = "TopbarTip",
		ZIndex = 2,
		Size = UDim2.new(1, -30, 0, 30),
		Position = UDim2.new(0, 30, 0, 0),
		Text = "Press '".. string.sub(tostring(self.ToggleKey), 14) .."' to hide this menu",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextColor3 = theme.text_color,
	})
	
	if projectName then
		self2.tip.Text = projectName
	else
		self2.tip.Text = "Press '".. string.sub(tostring(self.ToggleKey), 14) .."' to hide this menu"
	end
    
    function finity.settitle(text)
        self2.tip.Text = tostring(text)
    end

	local separator = self:Create("Frame", {
		Name = "Separator",
		BackgroundColor3 = theme.separator_color,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 118, 0, 30),
		Size = UDim2.new(0, 1, 1, -30),
		ZIndex = 6,
	})
	separator.Parent = self2.container
	separator = nil

	local separator = self:Create("Frame", {
		Name = "Separator",
		BackgroundColor3 = theme.separator_color,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 6,
	})
	separator.Parent = self2.container
	separator = nil

	local uipagelayout = self:Create("UIPageLayout", {
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Vertical,
		TweenTime = 0.7,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.InOut,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	uipagelayout.Parent = self2.categories
	uipagelayout = nil

	local uipadding = self:Create("UIPadding", {
		PaddingTop = UDim.new(0, 3),
		PaddingLeft = UDim.new(0, 2)
	})
	uipadding.Parent = self2.sidebar
	uipadding = nil

	local uilistlayout = self:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	uilistlayout.Parent = self2.sidebar
	uilistlayout = nil

	-- Window Snapping
	local snapThreshold = 10
	local snapPositions = {
		Left = UDim2.new(0, 0, 0.5, 0),
		Right = UDim2.new(1, -800, 0.5, 0),
		Top = UDim2.new(0.5, 0, 0, 0),
		Bottom = UDim2.new(0.5, 0, 1, -500)
	}

	local function checkSnap(position)
		local screenSize = workspace.CurrentCamera.ViewportSize
		local windowSize = self2.container.AbsoluteSize
		
		-- Check left snap
		if math.abs(position.X.Offset) < snapThreshold then
			return snapPositions.Left
		end
		
		-- Check right snap
		if math.abs(screenSize.X - (position.X.Offset + windowSize.X)) < snapThreshold then
			return snapPositions.Right
		end
		
		-- Check top snap
		if math.abs(position.Y.Offset) < snapThreshold then
			return snapPositions.Top
		end
		
		-- Check bottom snap
		if math.abs(screenSize.Y - (position.Y.Offset + windowSize.Y)) < snapThreshold then
			return snapPositions.Bottom
		end
		
		return nil
	end

	-- Window Transparency Controls
	local transparencyLevels = {
		Normal = 0,
		Hover = 0.1,
		Inactive = 0.2
	}

	self2.SetTransparency = function(level)
		if transparencyLevels[level] then
			animateWindow("BackgroundTransparency", transparencyLevels[level])
		end
	end

	-- Window Blur Effect
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 0
	blurEffect.Parent = workspace.CurrentCamera

	self2.SetBlur = function(enabled, size)
		size = size or 10
		if enabled then
			animateWindow("BackgroundTransparency", 0.5)
			blurEffect.Size = size
		else
			animateWindow("BackgroundTransparency", 0)
			blurEffect.Size = 0
		end
	end

	-- Setup auto-save after all UI elements are created
	setupAutoSave()

	self:addShadow(self2.container, 0)

	self2.categories.ClipsDescendants = true
	
	if not finity.gs["RunService"]:IsStudio() then
		self2.userinterface.Parent = self.gs["CoreGui"]
	else
		self2.userinterface.Parent = self.gs["Players"].LocalPlayer:WaitForChild("PlayerGui")
	end
	
	self2.container.Parent = self2.userinterface
	self2.categories.Parent = self2.container
	self2.sidebar.Parent = self2.container
	self2.topbar.Parent = self2.container
	self2.tip.Parent = self2.topbar

	return self2, finityData
end

return finity
