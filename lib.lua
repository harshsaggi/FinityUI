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

	-- Create UI elements first
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
    })
    self2.modal.Parent = self2.userinterface

	-- Add the container to the UI
	self2.container.Parent = self2.userinterface

	if not finity.gs["RunService"]:IsStudio() then
		self2.userinterface.Parent = self.gs["CoreGui"]
	else
		self2.userinterface.Parent = self.gs["Players"].LocalPlayer:WaitForChild("PlayerGui")
	end

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
		if not self2.container or typeof(self2.container) ~= "Instance" then return end
		duration = duration or animationSpeed
		local tweenInfo = TweenInfo.new(duration, animationStyle, animationDirection)
		local tween = finity.gs["TweenService"]:Create(self2.container, tweenInfo, {[property] = targetValue})
		tween:Play()
		return tween
	end

	-- Window Focus Management
	local function updateWindowFocus()
		if not self2.container or typeof(self2.container) ~= "Instance" then return end
		local success, result = pcall(function()
			return self2.container:IsMouseOver()
		end)
		if not success then return end
		
		windowFocused = result
		if windowFocused ~= lastFocused then
			lastFocused = windowFocused
			if windowFocused then
				animateWindow("BackgroundTransparency", 0)
			else
				animateWindow("BackgroundTransparency", 0.1)
			end
		end
	end

	-- Add focus update to RunService
	task.spawn(function()
		task.wait(0.1) -- Small delay to ensure container is created
		if self2.container and typeof(self2.container) == "Instance" then
			finity.gs["RunService"].RenderStepped:Connect(updateWindowFocus)
		end
	end)

	-- Setup auto-save after all UI elements are created
	task.spawn(function()
		task.wait(0.1) -- Small delay to ensure UI elements are created
		if self2.container and typeof(self2.container) == "Instance" then
			finity.setupAutoSave()
		end
	end)

	-- Load saved state after container is created
	task.spawn(function()
		task.wait(0.1) -- Small delay to ensure container is created
		if self2.container and typeof(self2.container) == "Instance" then
			finity.loadConfig(currentConfig)
		end
	end)

	-- Add the rest of the UI elements
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

	-- Add UI elements to container
	self2.categories.Parent = self2.container
	self2.sidebar.Parent = self2.container
	self2.topbar.Parent = self2.container
	self2.tip.Parent = self2.topbar

	-- Add shadow
	self:addShadow(self2.container, 0)

	return self2, finityData
end

-- Configuration Management Functions
function finity.saveConfig(name)
    if not name then return end
    local config = {
        position = self2.container.Position,
        size = self2.container.Size,
        minimized = finityData.Minimized,
        maximized = finityData.Maximized
    }
    writefile(configFolder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
end

function finity.loadConfig(name)
    if not name then return end
    local success, config = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(configFolder .. "/" .. name .. ".json"))
    end)
    if success and config then
        if config.position then self2.container.Position = config.position end
        if config.size then self2.container.Size = config.size end
        if config.minimized then finityData.Minimized = config.minimized end
        if config.maximized then finityData.Maximized = config.maximized end
    end
end

function finity.deleteConfig(name)
    if not name then return end
    if isfile(configFolder .. "/" .. name .. ".json") then
        delfile(configFolder .. "/" .. name .. ".json")
    end
end

function finity.listConfigs()
    local configs = {}
    for _, file in ipairs(listfiles(configFolder)) do
        if file:match("%.json$") then
            table.insert(configs, file:match("([^/]+)%.json$"))
        end
    end
    return configs
end

function finity.setupAutoSave()
    if not self2.container then return end
    
    -- Save on position/size change
    if self2.container then
        self2.container:GetPropertyChangedSignal("Position"):Connect(function()
            if autoSave then finity.saveConfig(currentConfig) end
        end)
        self2.container:GetPropertyChangedSignal("Size"):Connect(function()
            if autoSave then finity.saveConfig(currentConfig) end
        end)
    end
    
    -- Save on category text change
    if self2.categories then
        for _, category in ipairs(self2.categories:GetChildren()) do
            if category:IsA("TextLabel") then
                category:GetPropertyChangedSignal("Text"):Connect(function()
                    if autoSave then finity.saveConfig(currentConfig) end
                end)
            end
        end
    end
end

-- Category Creation
function finityObject:Category(name)
    local category = {}
    local self3 = category
    
    self3.name = name
    self3.buttons = {}
    self3.sectors = {}
    
    -- Create category button
    self3.button = self:Create("TextButton", {
        Name = name,
        BackgroundColor3 = theme.category_button_background,
        BorderColor3 = theme.category_button_border,
        BorderSizePixel = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, #self2.sidebar:GetChildren() * 30),
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = theme.text_color,
        BackgroundTransparency = 1,
        TextTransparency = 0.3,
        ZIndex = 3
    })
    
    -- Create category frame
    self3.frame = self:Create("Frame", {
        Name = name,
        BackgroundColor3 = theme.main_container,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 2
    })
    
    -- Add scrolling frame for sectors
    self3.scrollframe = self:Create("ScrollingFrame", {
        Name = "ScrollFrame",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.scrollbar_color,
        ZIndex = 2
    })
    
    -- Add UIListLayout for sectors
    self3.listlayout = self:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Add button to sidebar
    self3.button.Parent = self2.sidebar
    self3.frame.Parent = self2.categories
    self3.scrollframe.Parent = self3.frame
    self3.listlayout.Parent = self3.scrollframe
    
    -- Handle button click
    self3.button.MouseButton1Click:Connect(function()
        for _, v in pairs(self2.categories:GetChildren()) do
            if v:IsA("Frame") then
                v.Visible = false
            end
        end
        self3.frame.Visible = true
        
        for _, v in pairs(self2.sidebar:GetChildren()) do
            if v:IsA("TextButton") then
                v.TextTransparency = 0.3
                v.BackgroundTransparency = 1
            end
        end
        self3.button.TextTransparency = 0
        self3.button.BackgroundTransparency = 0
    end)
    
    -- Sector Creation
    function category:Sector(name)
        local sector = {}
        local self4 = sector
        
        self4.name = name
        self4.buttons = {}
        self4.toggles = {}
        self4.sliders = {}
        self4.textboxes = {}
        self4.dropdowns = {}
        
        -- Create sector frame
        self4.frame = self:Create("Frame", {
            Name = name,
            BackgroundColor3 = theme.main_container,
            BorderColor3 = theme.separator_color,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -20, 0, 100),
            Position = UDim2.new(0, 10, 0, #self3.scrollframe:GetChildren() * 105),
            ZIndex = 2
        })
        
        -- Create sector title
        self4.title = self:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 0),
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = theme.text_color,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        
        -- Add sector to category
        self4.frame.Parent = self3.scrollframe
        self4.title.Parent = self4.frame
        
        -- Toggle Creation
        function sector:Toggle(name, default, callback)
            local toggle = {}
            local self5 = toggle
            
            self5.name = name
            self5.value = default
            self5.callback = callback
            
            -- Create toggle frame
            self5.frame = self:Create("Frame", {
                Name = name,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, #self4.frame:GetChildren() * 25),
                ZIndex = 2
            })
            
            -- Create toggle button
            self5.button = self:Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = theme.checkbox_outer,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 0, 0, 0),
                Text = "",
                ZIndex = 2
            })
            
            -- Create toggle inner
            self5.inner = self:Create("Frame", {
                Name = "Inner",
                BackgroundColor3 = theme.checkbox_inner,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0, 2),
                ZIndex = 2
            })
            
            -- Create toggle text
            self5.text = self:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 25, 0, 0),
                Text = name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextColor3 = theme.text_color,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            
            -- Add toggle to sector
            self5.frame.Parent = self4.frame
            self5.button.Parent = self5.frame
            self5.inner.Parent = self5.button
            self5.text.Parent = self5.frame
            
            -- Handle toggle click
            self5.button.MouseButton1Click:Connect(function()
                self5.value = not self5.value
                if self5.value then
                    self5.inner.BackgroundColor3 = theme.checkbox_checked
                else
                    self5.inner.BackgroundColor3 = theme.checkbox_inner
                end
                if self5.callback then
                    self5.callback(self5.value)
                end
            end)
            
            -- Set initial state
            if self5.value then
                self5.inner.BackgroundColor3 = theme.checkbox_checked
            end
            
            -- Add getter for value
            function toggle:GetValue()
                return self5.value
            end
            
            -- Add setter for value
            function toggle:SetValue(value)
                self5.value = value
                if self5.value then
                    self5.inner.BackgroundColor3 = theme.checkbox_checked
                else
                    self5.inner.BackgroundColor3 = theme.checkbox_inner
                end
                if self5.callback then
                    self5.callback(self5.value)
                end
            end
            
            table.insert(self4.toggles, toggle)
            return toggle
        end
        
        -- Button Creation
        function sector:Button(name, callback)
            local button = {}
            local self5 = button
            
            self5.name = name
            self5.callback = callback
            
            -- Create button frame
            self5.frame = self:Create("Frame", {
                Name = name,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, #self4.frame:GetChildren() * 25),
                ZIndex = 2
            })
            
            -- Create button
            self5.button = self:Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = theme.button_background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextColor3 = theme.text_color,
                ZIndex = 2
            })
            
            -- Add button to sector
            self5.frame.Parent = self4.frame
            self5.button.Parent = self5.frame
            
            -- Handle button click
            self5.button.MouseButton1Click:Connect(function()
                if self5.callback then
                    self5.callback()
                end
            end)
            
            -- Handle button hover
            self5.button.MouseEnter:Connect(function()
                self5.button.BackgroundColor3 = theme.button_background_hover
            end)
            
            self5.button.MouseLeave:Connect(function()
                self5.button.BackgroundColor3 = theme.button_background
            end)
            
            table.insert(self4.buttons, button)
            return button
        end
        
        -- Slider Creation
        function sector:Slider(name, min, max, default, callback)
            local slider = {}
            local self5 = slider
            
            self5.name = name
            self5.min = min
            self5.max = max
            self5.value = default
            self5.callback = callback
            
            -- Create slider frame
            self5.frame = self:Create("Frame", {
                Name = name,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, #self4.frame:GetChildren() * 45),
                ZIndex = 2
            })
            
            -- Create slider text
            self5.text = self:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 0),
                Text = name .. ": " .. default,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextColor3 = theme.text_color,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            
            -- Create slider background
            self5.background = self:Create("Frame", {
                Name = "Background",
                BackgroundColor3 = theme.slider_background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 0, 25),
                ZIndex = 2
            })
            
            -- Create slider fill
            self5.fill = self:Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = theme.slider_color,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 2
            })
            
            -- Add slider to sector
            self5.frame.Parent = self4.frame
            self5.text.Parent = self5.frame
            self5.background.Parent = self5.frame
            self5.fill.Parent = self5.background
            
            -- Handle slider dragging
            local dragging = false
            
            self5.background.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            self5.background.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            self5.background.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    self5.input = input
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == self5.input and dragging then
                    local pos = self5.background.AbsolutePosition
                    local size = self5.background.AbsoluteSize
                    local x = math.clamp(mouse.X - pos.X, 0, size.X)
                    local value = self5.min + (x / size.X) * (self5.max - self5.min)
                    value = math.floor(value)
                    self5.value = value
                    self5.fill.Size = UDim2.new(x / size.X, 0, 1, 0)
                    self5.text.Text = name .. ": " .. value
                    if self5.callback then
                        self5.callback(value)
                    end
                end
            end)
            
            -- Set initial state
            local x = (self5.value - self5.min) / (self5.max - self5.min)
            self5.fill.Size = UDim2.new(x, 0, 1, 0)
            
            table.insert(self4.sliders, slider)
            return slider
        end
        
        -- Textbox Creation
        function sector:Textbox(name, placeholder, callback)
            local textbox = {}
            local self5 = textbox
            
            self5.name = name
            self5.placeholder = placeholder
            self5.callback = callback
            
            -- Create textbox frame
            self5.frame = self:Create("Frame", {
                Name = name,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, #self4.frame:GetChildren() * 25),
                ZIndex = 2
            })
            
            -- Create textbox
            self5.textbox = self:Create("TextBox", {
                Name = "Textbox",
                BackgroundColor3 = theme.textbox_background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = "",
                PlaceholderText = placeholder,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextColor3 = theme.textbox_text,
                PlaceholderColor3 = theme.textbox_placeholder,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            
            -- Add textbox to sector
            self5.frame.Parent = self4.frame
            self5.textbox.Parent = self5.frame
            
            -- Handle textbox focus
            self5.textbox.Focused:Connect(function()
                self5.textbox.BackgroundColor3 = theme.textbox_background_hover
                self5.textbox.TextColor3 = theme.textbox_text_hover
            end)
            
            self5.textbox.FocusLost:Connect(function()
                self5.textbox.BackgroundColor3 = theme.textbox_background
                self5.textbox.TextColor3 = theme.textbox_text
                if self5.callback then
                    self5.callback(self5.textbox.Text)
                end
            end)
            
            table.insert(self4.textboxes, textbox)
            return textbox
        end
        
        -- Dropdown Creation
        function sector:Dropdown(name, options, default, callback)
            local dropdown = {}
            local self5 = dropdown
            
            self5.name = name
            self5.options = options
            self5.value = default
            self5.callback = callback
            self5.open = false
            
            -- Create dropdown frame
            self5.frame = self:Create("Frame", {
                Name = name,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, #self4.frame:GetChildren() * 25),
                ZIndex = 2
            })
            
            -- Create dropdown button
            self5.button = self:Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = theme.dropdown_background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = default,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextColor3 = theme.dropdown_text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            
            -- Create dropdown list
            self5.list = self:Create("Frame", {
                Name = "List",
                BackgroundColor3 = theme.dropdown_background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 20),
                Visible = false,
                ZIndex = 2
            })
            
            -- Add dropdown to sector
            self5.frame.Parent = self4.frame
            self5.button.Parent = self5.frame
            self5.list.Parent = self5.frame
            
            -- Create options
            for i, option in ipairs(options) do
                local optionButton = self:Create("TextButton", {
                    Name = option,
                    BackgroundColor3 = theme.dropdown_background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, (i - 1) * 20),
                    Text = option,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    TextColor3 = theme.dropdown_text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2
                })
                
                optionButton.Parent = self5.list
                
                optionButton.MouseButton1Click:Connect(function()
                    self5.value = option
                    self5.button.Text = option
                    self5.open = false
                    self5.list.Visible = false
                    if self5.callback then
                        self5.callback(option)
                    end
                end)
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.TextColor3 = theme.dropdown_text_hover
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.TextColor3 = theme.dropdown_text
                end)
            end
            
            -- Handle dropdown click
            self5.button.MouseButton1Click:Connect(function()
                self5.open = not self5.open
                self5.list.Visible = self5.open
                if self5.open then
                    self5.list.Size = UDim2.new(1, 0, 0, #options * 20)
                else
                    self5.list.Size = UDim2.new(1, 0, 0, 0)
                end
            end)
            
            -- Handle dropdown hover
            self5.button.MouseEnter:Connect(function()
                self5.button.TextColor3 = theme.dropdown_text_hover
            end)
            
            self5.button.MouseLeave:Connect(function()
                self5.button.TextColor3 = theme.dropdown_text
            end)
            
            table.insert(self4.dropdowns, dropdown)
            return dropdown
        end
        
        table.insert(self3.sectors, sector)
        return sector
    end
    
    table.insert(self2.categories, category)
    return category
end

return finity
