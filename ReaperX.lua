local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local localPlayer = game:GetService("Players").LocalPlayer
local configFileName = localPlayer.Name .. ".Json"

local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
gethui = gethui or function()
	return CoreGui
end

local currentCamera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()
local touchEnabled = UserInputService.TouchEnabled or false

-- ป้องกัน UI ซ้อนเมื่อรันซ้ำ: ถ้ามี instance เก่าของ library นี้อยู่ ให้ Unload ก่อนสร้างใหม่
local sharedEnv = getgenv and getgenv() or nil
local SHARED_KEY = "ReaperXLibrary"
if sharedEnv and sharedEnv[SHARED_KEY] then
	local ok, err = pcall(function()
		sharedEnv[SHARED_KEY]:Unload()
	end)
	if not ok then
		warn("[ReaperX] unload previous instance failed: " .. tostring(err))
	end
	sharedEnv[SHARED_KEY] = nil
end

local Library = {
	Theme = {},
	MenuKeybind = tostring(Enum.KeyCode.RightControl),
	Flags = {},
	Tween = {
		Time = 0.3, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out,
	},
	FadeSpeed = 0.2,
	Folders = {
		Directory = "Anime Mysterious", Configs = "Anime_Mysterious/Configs",
	},
	Pages = {},
	Sections = {},
	Connections = {},
	Threads = {},
	ThemeMap = {},
	ThemeItems = {},
	OpenFrames = {},
	WorldObjects = {},
	SetFlags = {},
	UnnamedConnections = 0,
	UnnamedFlags = 0,
	Holder = nil,
	NotifHolder = nil,
	UnusedHolder = nil,
	Font = nil,
}

Library.__index = Library
Library.Sections.__index = Library.Sections
Library.Pages.__index = Library.Pages

local keyNames = {
	Unknown = "Unknown",
	Backspace = "Back",
	Tab = "Tab",
	Clear = "Clear",
	Return = "Return",
	Pause = "Pause",
	Escape = "Escape",
	Space = "Space",
	QuotedDouble = "\"",
	Hash = "#",
	Dollar = "$",
	Percent = "%",
	Ampersand = "&",
	Quote = "'",
	LeftParenthesis = "(",
	RightParenthesis = " )",
	Asterisk = "*",
	Plus = "+",
	Comma = ",",
	Minus = "-",
	Period = ".",
	Slash = "`",
	Three = "3",
	Seven = "7",
	Eight = "8",
	Colon = ":",
	Semicolon = ";",
	LessThan = "<",
	GreaterThan = ">",
	Question = "?",
	Equals = "=",
	At = "@",
	LeftBracket = "LeftBracket",
	RightBracket = "RightBracked",
	BackSlash = "BackSlash",
	Caret = "^",
	Underscore = "_",
	Backquote = "`",
	LeftCurly = "{",
	Pipe = "|",
	RightCurly = "}",
	Tilde = "~",
	Delete = "Delete",
	End = "End",
	KeypadZero = "Keypad0",
	KeypadOne = "Keypad1",
	KeypadTwo = "Keypad2",
	KeypadThree = "Keypad3",
	KeypadFour = "Keypad4",
	KeypadFive = "Keypad5",
	KeypadSix = "Keypad6",
	KeypadSeven = "Keypad7",
	KeypadEight = "Keypad8",
	KeypadNine = "Keypad9",
	KeypadPeriod = "Keypad.",
	KeypadDivide = "Keypad/",
	KeypadMultiply = "KeypadM",
	KeypadMinus = "KeypadM",
	KeypadPlus = "KeypadP",
	KeypadEnter = "KeypadE",
	KeypadEquals = "KeypadE",
	Insert = "Insert",
	Home = "Home",
	PageUp = "PageUp",
	PageDown = "PageDown",
	RightShift = "RightShift",
	LeftShift = "LeftShift",
	RightControl = "RightControl",
	LeftControl = "LeftControl",
	LeftAlt = "LeftAlt",
	RightAlt = "RightAlt",
}

Library.Theme = table.clone(({
	Preset = {
		AccentGradient = Color3.fromRGB(0, 116, 200), ["Background 2"] = Color3.fromRGB(10, 10, 12),
		Background = Color3.fromRGB(12, 12, 14), Text = Color3.fromRGB(235, 235, 235), Outline = Color3.fromRGB(25, 25, 28),
		["Section Top"] = Color3.fromRGB(28, 26, 32), ["Section Background"] = Color3.fromRGB(10, 10, 12),
		["Section Background 2"] = Color3.fromRGB(14, 14, 16), Accent = Color3.fromRGB(0, 85, 255), Element = Color3.fromRGB(16, 16, 18),
	},
}).Preset)
for _, folder in Library.Folders do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

local TweenObject = {}
TweenObject.__index = TweenObject

function TweenObject:Create(target, tweenInfo, goal, isRawInstance)
	local instance = isRawInstance and target or target.Instance
	tweenInfo = tweenInfo or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
	local tweenObject = { Tween = TweenService:Create(instance, tweenInfo, goal), Info = tweenInfo, Goal = goal, Item = instance }
	tweenObject.Tween:Play()
	setmetatable(tweenObject, TweenObject)
	return tweenObject
end

function TweenObject:GetProperty(instance)
	local item = instance or self.Item
	if item:IsA("Frame") then
		return { "BackgroundTransparency" }
	end
	if item:IsA("TextLabel") or item:IsA("TextButton") then
		return { "TextTransparency", "BackgroundTransparency" }
	end
	if item:IsA("ImageLabel") or item:IsA("ImageButton") then
		return { "BackgroundTransparency", "ImageTransparency" }
	end
	if item:IsA("ScrollingFrame") then
		return { "BackgroundTransparency", "ScrollBarImageTransparency" }
	end
	if item:IsA("TextBox") then
		return { "TextTransparency", "BackgroundTransparency" }
	end
	if item:IsA("UIStroke") then
		return { "Transparency" }
	end
end

function TweenObject:FadeItem(instance, property, fadeIn, duration)
	local item = instance or self.Item
	local originalValue = item[property]
	item[property] = fadeIn and 1 or originalValue
	local tweenInfo = TweenInfo.new(duration or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
	local goal = {}
	goal[property] = fadeIn and originalValue or 1
	local fadeTween = TweenObject:Create(item, tweenInfo, goal, true)
	Library:Connect(fadeTween.Tween.Completed, function()
		if not fadeIn then
			task.wait()
			item[property] = originalValue
		end
	end)
	return fadeTween
end

function TweenObject:Get()
	if not self.Tween then
		return
	end
	return self.Tween, self.Info, self.Goal
end

function TweenObject:Pause()
	if not self.Tween then
		return
	end
	self.Tween:Pause()
end

function TweenObject:Play()
	if not self.Tween then
		return
	end
	self.Tween:Play()
end

function TweenObject:Clean()
	if not self.Tween then
		return
	end
	TweenObject:Pause()
end

local UIObject = {}
UIObject.__index = UIObject

function UIObject:Create(className, properties)
	local object = { Instance = Instance.new(className), Properties = properties, Class = className }
	setmetatable(object, UIObject)
	local instance = object.Instance
	instance.Name = "\0"
	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
		instance.BorderColor3 = Color3.fromRGB(0, 0, 0)
		instance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	for propertyName, value in object.Properties do
		instance[propertyName] = value
	end
	return object
end

function UIObject:FadeItem(visible, duration)
	local instance = self.Instance
	if visible == true then
		instance.Visible = true
	end
	local descendants = instance:GetDescendants()
	table.insert(descendants, instance)
	for _, descendant in descendants do
		local property = TweenObject:GetProperty(descendant)
		if property then
			if type(property) == "table" then
				for _, propertyName in property do
					TweenObject:FadeItem(descendant, propertyName, not visible, duration)
				end
			else
				TweenObject:FadeItem(descendant, property, not visible, duration)
			end
		end
	end
end

function UIObject:AddToTheme(properties)
	if not self.Instance then
		return
	end
	Library:AddToTheme(self, properties)
end

function UIObject:ChangeItemTheme(properties)
	if not self.Instance then
		return
	end
	Library:ChangeItemTheme(self, properties)
end

function UIObject:Connect(eventName, callback, name)
	if not self.Instance then
		return
	end
	if eventName == "MouseButton1Down" or eventName == "MouseButton1Click" then
		if self.Instance:IsA("GuiButton") then
			eventName = "Activated"
		elseif touchEnabled then
			return Library:Connect(self.Instance.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					callback(input)
				end
			end, name)
		end
	elseif eventName == "MouseButton1Click" or eventName == "MouseButton2Click" then
		if touchEnabled then
			eventName = "TouchLongPress"
		end
	end
	if not self.Instance[eventName] then
		return
	end
	return Library:Connect(self.Instance[eventName], callback, name)
end

function UIObject:Tween(tweenInfo, goal)
	if not self.Instance then
		return
	end
	return TweenObject:Create(self, tweenInfo, goal)
end

function UIObject:Disconnect(name)
	if not self.Instance then
		return
	end
	return Library:Disconnect(name)
end

function UIObject:Clean()
	if not self.Instance then
		return
	end
	self.Instance:Destroy()
end

function UIObject:MakeDraggable()
	if not self.Instance then
		return
	end
	local instance = self.Instance
	local dragging = false
	local dragStart = nil
	local startPosition = nil
	local function updateDrag(input)
		local delta = input.Position - dragStart
		local newX = startPosition.X.Offset + delta.X
		local newY = startPosition.Y.Offset + delta.Y
		local parentSize = instance.Parent.AbsoluteSize
		local frameSize = instance.AbsoluteSize
		local clampedX = math.clamp(newX, 0, parentSize.X - frameSize.X)
		local clampedY = math.clamp(newY, 0, parentSize.Y - frameSize.Y)
		self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, clampedX, 0, clampedY) })
	end
	local connection = nil
	self:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = instance.Position
			if connection then
				return
			end
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				updateDrag(input)
			end
		end
	end)
	return dragging
end

function UIObject:MakeResizeable(minSize, maxSize, edgeSizes)
	if not self.Instance then
		return
	end
	local instance = self.Instance
	local resizing = false
	local activeSide = nil
	local startMouse = nil
	local startPosition = nil
	local startSize = nil
	local function createHandle(side, position, size)
		local button = UIObject:Create("TextButton", {
			Size = size,
			Position = position,
			BackgroundColor3 = Color3.fromRGB(166, 147, 243),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = instance,
			ZIndex = 99999,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
		})
		button:AddToTheme({ BackgroundColor3 = "Accent" })
		return button
	end
	local handles = {}
	local leftHandle = { Button = createHandle("Left", UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 1, 0)), Side = "L" }
	local rightHandle = { Button = createHandle("Right", UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 1, 0)), Side = "R" }
	local topHandle = { Button = createHandle("Top", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 2)), Side = "T" }
	local bottomHandle = { Button = createHandle("Bottom", UDim2.new(0, 0, 1, -2), UDim2.new(1, 0, 0, 2)), Side = "B" }
	handles[1] = leftHandle
	handles[2] = rightHandle
	handles[3] = topHandle
	handles[4] = bottomHandle
	local function startResize(side)
		resizing = true
		activeSide = side
		startMouse = UserInputService:GetMouseLocation()
		startPosition = Vector2.new(instance.Position.X.Offset, instance.Position.Y.Offset)
		startSize = Vector2.new(instance.Size.X.Offset, instance.Size.Y.Offset)
		for _, handle in handles do
			handle.Button:Tween(nil, { BackgroundTransparency = handle.Side == side and 0 or 1 })
		end
	end
	local function stopResize()
		resizing = false
		activeSide = nil
		for _, handle in handles do
			handle.Button.Instance.BackgroundTransparency = 1
		end
	end
	for _, handle in handles do
		handle.Button:Connect("InputBegan", function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				startResize(handle.Side)
			end
		end)
	end
	Library:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if resizing then
				stopResize()
			end
		end
	end)
	Library:Connect(RunService.RenderStepped, function()
		if not resizing or not activeSide then
			return
		end
		local currentMouse = UserInputService:GetMouseLocation()
		local deltaX = currentMouse.X - startMouse.X
		local deltaY = currentMouse.Y - startMouse.Y
		local x = startPosition.X
		local y = startPosition.Y
		local width = startSize.X
		local height = startSize.Y
		if activeSide == "Left" then
			x = startPosition.X + deltaX
			width = startSize.X - deltaX
			if edgeSizes then
				edgeSizes.Left.Y = height
			end
		elseif activeSide == "Right" then
			local newWidth = startSize.X + deltaX
			if edgeSizes then
				edgeSizes.Right.Y = height
				width = newWidth
			else
				width = newWidth
			end
		elseif activeSide == "Top" then
			y = startPosition.Y + deltaY
			height = startSize.Y - deltaY
			if edgeSizes then
				edgeSizes.Top.X = width
			end
		elseif activeSide == "B" then
			height = startSize.Y + deltaY
			if edgeSizes then
				edgeSizes.Bottom.X = width
			end
		end
		if width < minSize.X then
			if activeSide == "L" then
				x -= minSize.X - width
			end
			width = minSize.X
		end
		if height < minSize.Y then
			if activeSide == "T" then
				y -= minSize.Y - height
			end
			height = minSize.Y
		end
		self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.fromOffset(x, y) })
		self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.fromOffset(width, height) })
	end)
end

function UIObject:OnHover(callback)
	if not self.Instance then
		return
	end
	return Library:Connect(self.Instance.MouseEnter, callback)
end

function UIObject:OnHoverLeave(callback)
	if not self.Instance then
		return
	end
	return Library:Connect(self.Instance.MouseLeave, callback)
end

local customFont = {
	New = function(self, fontName, weight, style, asset)
		if not isfile(asset.Id) then
			writefile(asset.Id, game:HttpGet(asset.Url))
		end
		local fontData = {
			name = fontName, faces = { { name = fontName, weight = weight, style = style, assetId = getcustomasset(asset.Id) } },
		}
		writefile(("%*/%*.font"):format(Library.Folders.Assets, fontName), HttpService:JSONEncode(fontData))
		local fontPath = ("%*/%*.font"):format(Library.Folders.Assets, fontName)
		return getcustomasset(fontPath)
	end
}

local font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

Library.Fonts = {
	SemiBold = font,
	Regular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Light = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal),
}

Library.Font = font

Library.Holder = UIObject:Create("ScreenGui", {
	Parent = gethui(), Name = "ReaperX", ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 2, ResetOnSpawn = false,
})

Library.UnusedHolder = UIObject:Create("ScreenGui", {
	Parent = gethui(), ZIndexBehavior = Enum.ZIndexBehavior.Global, Enabled = false, ResetOnSpawn = false,
})

Library.NotifHolder = UIObject:Create("Frame", {
	Parent = Library.Holder.Instance, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum
.AutomaticSize.X,
})

UIObject:Create("UIListLayout", {
	Parent = Library.NotifHolder.Instance, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder,
})

UIObject:Create("UIPadding", {
	Parent = Library.NotifHolder.Instance,
	PaddingTop = UDim.new(0, 12),
	PaddingBottom = UDim.new(0, 12),
	PaddingRight = UDim.new(0, 12),
	PaddingLeft = UDim.new(0, 12),
})

function Library:Unload()
	for _, connectionData in self.Connections do
		if connectionData.Connection then
			connectionData.Connection:Disconnect()
		end
	end
	for _, thread in self.Threads do
		-- thread ที่กำลังทำงานอยู่ถูกปิดไม่ได้ (coroutine.close จะ error) จึงข้ามไป
		pcall(coroutine.close, thread)
	end
	for _, instance in self.WorldObjects do
		instance:Destroy()
	end
	if self.Holder then
		self.Holder:Clean()
	end
	if self.UnusedHolder then
		self.UnusedHolder:Clean()
	end
	if sharedEnv and sharedEnv[SHARED_KEY] == self then
		sharedEnv[SHARED_KEY] = nil
	end
	Library = nil
end

function Library:GetImage(name)
	local image = self.Images[name]
	if not image then
		return
	end
	return getcustomasset(self.Folders.Assets .. "/" .. image[1])
end

function Library:Round(number, step)
	local factor = 1 / (step or 1)
	return math.floor(number * factor) / factor
end

function Library:Thread(callback)
	local thread = coroutine.create(callback)
	coroutine.wrap(function()
		coroutine.resume(thread)
	end)()
	table.insert(self.Threads, thread)
	return thread
end

function Library:SafeCall(callback, ...)
	local ok = pcall(callback, table.unpack({ ... }))
	if not ok then
		return false
	end
	return ok
end

function Library:Connect(signal, callback, name)
	local connectionData = {
		Event = signal,
		Callback = callback,
		Name = name or
		string.format("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false)),
		Connection = nil,
	}
	Library:Thread(function()
		connectionData.Connection = signal:Connect(callback)
	end)
	table.insert(self.Connections, connectionData)
	return connectionData
end

function Library:Disconnect(name)
	for _, connectionData in self.Connections do
		if connectionData.Name == name then
			connectionData.Connection:Disconnect()
			break
		end
	end
end

function Library:NextFlag()
	return string.format("flag_number_%s_%s", self.UnnamedFlags + 1, HttpService:GenerateGUID(false))
end

function Library:AddToTheme(object, properties)
	local instance = object.Instance or object
	local themeItem = { Item = instance, Properties = properties }
	for propertyName, themeValue in themeItem.Properties do
		if type(themeValue) == "string" then
			instance[propertyName] = self.Theme[themeValue]
		else
			instance[propertyName] = themeValue()
		end
	end
	table.insert(self.ThemeItems, themeItem)
	self.ThemeMap[instance] = themeItem
end

function Library:ToRich(text, color)
	return (("<font color=\"rgb(%*, %*, %*)\">%*</font>"):format(math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255), text))
end

function Library:ReadConfigFile(fileName)
	if type(fileName) ~= "string" or fileName == "" then
		return nil
	end
	local path = Library.Folders.Configs .. "/" .. fileName
	local ok, result = pcall(function()
		if not isfile(path) then
			return nil
		end
		return HttpService:JSONDecode(readfile(path))
	end)
	return ok and type(result) == "table" and result or nil
end

function Library:GetConfig(existingConfig)
	local config = {}
	Library:SafeCall(function()
		for flag, flagValue in Library.Flags do
			if type(flagValue) == "table" and flagValue.Key then
				config[flag] = { Key = tostring(flagValue.Key), Mode = flagValue.Mode }
			elseif type(flagValue) == "table" and flagValue.Color then
				config[flag] = { Color = "#" .. flagValue.HexValue, Alpha = flagValue.Alpha }
			else
				config[flag] = flagValue
			end
		end
	end)
	local previousConfig = type(existingConfig) == "table" and existingConfig or Library:ReadConfigFile(existingConfig)
	if previousConfig then
		Library:SafeCall(function()
			for key, savedValue in previousConfig do
				if config[key] == nil and Library.SetFlags[key] == nil then
					config[key] = savedValue
				end
			end
		end)
	end
	return HttpService:JSONEncode(config)
end

local ignoredConfigKeys = { "Default", "Auto Load", "Macro Record" }

function Library:LoadConfig(json, currentConfig)
	local data = HttpService:JSONDecode(json)
	local ok, err = Library:SafeCall(function()
		for key, value in data do
			if not table.find(ignoredConfigKeys, tostring(key)) then
				local setter = Library.SetFlags[key]
				if setter then
					if type(value) == "table" and value.Key then
						setter(value)
					elseif type(value) == "table" and value.Color then
						setter(value.Color, value.Alpha)
					else
						setter(value)
					end
				end
			end
		end
	end)
	Library.CurrentConfig = currentConfig
	return ok, err
end

function Library.AutoSave()
	pcall(function()
		if not Library.Loading then
			return
		end
		if Library.CurrentConfig ~= configFileName then
			return
		end
		if isfile(Library.Folders.Configs .. "/" .. configFileName) then
			if Library.CurrentConfig == configFileName then
				writefile(Library.Folders.Configs .. "/" .. configFileName, Library:GetConfig(configFileName))
			end
		end
	end)
end

function Library:DeleteConfig(fileName)
	if isfile(Library.Folders.Configs .. "/" .. fileName) then
		delfile(Library.Folders.Configs .. "/" .. fileName)
	end
end

function Library:RefreshConfigsList(listbox)
	local currentList = {}
	local files = {}
	local configsSubfolder = string.gsub(Library.Folders.Configs, Library.Folders.Directory .. "/", "")
	for key, config in listfiles(Library.Folders.Configs) do
		files[key] = string.gsub(config, Library.Folders.Directory .. "\\" .. configsSubfolder .. "\\", "")
	end
	if not (#files ~= currentList) then
		for i = 1, #files do
			if files[i] ~= currentList[i] then
				break
			end
		end
	else
		listbox:Refresh(files)
	end
end

function Library:ChangeItemTheme(object, properties)
	local instance = object.Instance or object
	if not self.ThemeMap[instance] then
		return
	end
	self.ThemeMap[instance].Properties = properties
	self.ThemeMap[instance] = self.ThemeMap[instance]
end

function Library:ChangeTheme(themeKey, color)
	self.Theme[themeKey] = color
	for _, themeItem in self.ThemeItems do
		for propertyName, themeValue in themeItem.Properties do
			if type(themeValue) == "string" and themeValue == themeKey then
				themeItem.Item[propertyName] = color
			elseif type(themeValue) == "function" then
				themeItem.Item[propertyName] = themeValue()
			end
		end
	end
end

function Library:IsMouseOverFrame(object)
	local instance = object.Instance
	local mousePosition = Vector2.new(mouse.X, mouse.Y)
	return mousePosition.X >= instance.AbsolutePosition.X and mousePosition.X <= instance.AbsolutePosition.X + instance.AbsoluteSize.X and
	mousePosition.Y >= instance.AbsolutePosition.Y and mousePosition.Y <= instance.AbsolutePosition.Y + instance.AbsoluteSize.Y
end

function Library:Lerp(from, to, alpha)
	return from + (to - from) * alpha
end

function Library:CompareVectors(vectorA, vectorB)
	return vectorA.X < vectorB.X or vectorA.Y < vectorB.Y
end

function Library:IsClipped(child, container)
	local containerPosition = container.AbsolutePosition
	local containerEnd = containerPosition + container.AbsoluteSize
	local childPosition = child.AbsolutePosition
	local childEnd = childPosition + child.AbsoluteSize
	return Library:CompareVectors(childPosition, containerPosition) or Library:CompareVectors(containerEnd, childEnd)
end

function Library:GetCalculatedRayPosition(planePoint, planeNormal, rayOrigin, rayDirection)
	local offset = rayOrigin - planePoint
	return rayOrigin +
	-(planeNormal.x * offset.x + planeNormal.y * offset.y + planeNormal.z * offset.z) / (planeNormal.x * rayDirection.x + planeNormal.y * rayDirection.y + planeNormal.z * rayDirection.z) * rayDirection
end

function Library:UpdateText()
	for _, descendant in self.UnusedHolder.Instance:GetDescendants() do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			descendant.FontFace = Library.Font
		end
	end
	for _, descendant in self.Holder.Instance:GetDescendants() do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			descendant.FontFace = Library.Font
		end
	end
end

function Library:MakeBlurred(object, window)
	local instance = object.Instance
	local blurPart = UIObject:Create("Part", {
		Material = Enum.Material.Glass,
		Transparency = 1,
		Reflectance = 1,
		CastShadow = false,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CollisionGroup = "Default",
		Size = Vector3.new(1, 1, 1) * 0.01,
		Color = Color3.fromRGB(0, 0, 0),
		Parent = currentCamera,
		Name = "Part",
	})
	local blurMesh = UIObject:Create("BlockMesh", { Parent = blurPart.Instance, Name = "BlockMesh" })
	local depthOfField = UIObject:Create("DepthOfFieldEffect", {
		Parent = Lighting, Enabled = true, FarIntensity = 0, FocusDistance = 0, InFocusRadius = 1000, NearIntensity = 1, Name =
	"",
	})
	table.insert(Library.WorldObjects, blurPart.Instance)
	table.insert(Library.WorldObjects, depthOfField.Instance)
	local elapsed = 0
	local blurActive = false
	Library:Connect(RunService.RenderStepped, function(deltaTime)
		elapsed += deltaTime
		if elapsed < 0.033333333333333333 then
			return
		end
		elapsed = 0
		if not (window.IsOpen and instance.Visible) then
			if blurActive then
				blurActive = false
				depthOfField.Instance.NearIntensity = 0
				blurMesh.Instance.Offset = Vector3.new(0, 0, 0)
				blurMesh.Instance.Scale = Vector3.new(0, 0, 0)
			end
			return
		end
		if not blurActive then
			blurActive = true
			depthOfField.Instance.NearIntensity = 1
			blurPart.Instance.Transparency = 0.85
			blurPart.Instance.Size = Vector3.new(1, 1, 1) * 0.01
		end
		local topLeft = instance.AbsolutePosition
		local bottomRight = topLeft + instance.AbsoluteSize
		local topLeftRay = currentCamera:ScreenPointToRay(topLeft.X, topLeft.Y, 1)
		local bottomRightRay = currentCamera:ScreenPointToRay(bottomRight.X, bottomRight.Y, 1)
		local planePoint = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * (1 - currentCamera.NearPlaneZ)
		local lookVector = currentCamera.CFrame.LookVector
		local topLeftPoint = Library:GetCalculatedRayPosition(planePoint, lookVector, topLeftRay.Origin, topLeftRay.Direction)
		local bottomRightPoint = Library:GetCalculatedRayPosition(planePoint, lookVector, bottomRightRay.Origin, bottomRightRay.Direction)
		local topLeftLocal = currentCamera.CFrame:PointToObjectSpace(topLeftPoint)
		local bottomRightLocal = currentCamera.CFrame:PointToObjectSpace(bottomRightPoint)
		blurMesh.Instance.Offset = (topLeftLocal + bottomRightLocal) / 2
		blurMesh.Instance.Scale = (bottomRightLocal - topLeftLocal) / 100
		blurPart.Instance.CFrame = currentCamera.CFrame
	end)
end

function Library:EscapePattern(text)
	local hasSpecial = false
	if string.match(text, "[%(%)%.%%%+%-%*%?%[%]%^%$]") then
		hasSpecial = true
	end
	if hasSpecial then
		return string.gsub(text, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
	end
	return text
end

function Library:CreateColorpicker(properties)
	local colorpicker = {
		Flag = properties.Flag,
		Hue = 0,
		Saturation = 0,
		Value = 0,
		Alpha = 0,
		Color = Color3.fromRGB(0, 0, 0),
		HexValue = "#000000",
		SavedColors = {},
		IsOpen = false,
	}
	local ui = {
		ColorpickerButton = UIObject:Create("TextButton", {
			Parent = properties.Parent.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 100, 0, 20),
			ZIndex = 2,
			TextSize = 14,
		}),
	}
	if not properties.Parent2.Instance:FindFirstChild("nig") then
		ui.PaletteIcon = UIObject:Create("ImageLabel", {
			Parent = properties.Parent2.Instance,
			ImageColor3 = Color3.fromRGB(141, 141, 150),
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0.5, 1),
			Image = "rbxassetid://92464809279921",
			Name = "nig",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -16, 1, -6),
			ZIndex = 2,
		})
		ui.PaletteIcon:OnHover(function()
			ui.PaletteIcon:Tween(nil, { ImageColor3 = Library.Theme.Accent })
		end)
		ui.PaletteIcon:OnHoverLeave(function()
			ui.PaletteIcon:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
		end)
	end
	ui.Color = UIObject:Create("Frame", {
		Parent = ui.ColorpickerButton.Instance,
		Size = UDim2.new(0, 15, 0, 15),
		Position = UDim2.new(0, 0, 0, 2),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(124, 77, 255),
	})
	UIObject:Create("UICorner", { Parent = ui.Color.Instance, CornerRadius = UDim.new(1, 0) })
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.ColorpickerButton.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "#7842ff",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 25, 0, 2),
		ZIndex = 2,
		TextSize = 14,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.ColorpickerWindow = UIObject:Create("TextButton", {
		Parent = Library.UnusedHolder.Instance,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
		Position = UDim2.new(0.5, 0, 0.0336427167, 0),
		Size = UDim2.new(0, 235, 0, 270),
		BackgroundColor3 = Color3.fromRGB(255, 255, 25),
	})
	ui.ColorpickerWindow:AddToTheme({ BackgroundColor3 = "Background" })
	UIObject:Create("UICorner", { Parent = ui.ColorpickerWindow.Instance, CornerRadius = UDim.new(0, 6) })
	ui.Palette = UIObject:Create("TextButton", {
		Parent = ui.ColorpickerWindow.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.new(0, 15, 0, 10),
		Size = UDim2.new(1, -31, 1, -159),
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(90, 163, 255),
	})
	ui.Saturation = UIObject:Create("Frame", {
		Parent = ui.Palette.Instance, Size = UDim2.new(1, 1, 1, 0),
	})
	UIObject:Create("UIGradient", {
		Parent = ui.Saturation.Instance,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
	})
	UIObject:Create("UICorner", { Parent = ui.Saturation.Instance, CornerRadius = UDim.new(0, 4) })
	ui.Value = UIObject:Create("Frame", {
		Parent = ui.Palette.Instance, Size = UDim2.new(1, 1, 1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})
	UIObject:Create("UIGradient", {
		Parent = ui.Value.Instance,
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
	})
	UIObject:Create("UICorner", { Parent = ui.Value.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UICorner", { Parent = ui.Palette.Instance, CornerRadius = UDim.new(0, 4) })
	ui.PaletteDragger = UIObject:Create("Frame", {
		Parent = ui.Palette.Instance, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(
	0, 10, 0, 10),
	})
	UIObject:Create("UIStroke", {
		Parent = ui.PaletteDragger.Instance, Color = Color3.fromRGB(255, 255, 255), ApplyStrokeMode = Enum
	.ApplyStrokeMode.Border,
	})
	UIObject:Create("UICorner", { Parent = ui.PaletteDragger.Instance })
	ui.Hue = UIObject:Create("TextButton", {
		Parent = ui.ColorpickerWindow.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 15, 1, -125),
		Size = UDim2.new(1, -31, 0, 6),
		TextSize = 14,
	})
	UIObject:Create("UICorner", { Parent = ui.Hue.Instance, CornerRadius = UDim.new(1, 0) })
	ui.HueInline = UIObject:Create("TextButton", {
		Parent = ui.Hue.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 1, 0),
		TextSize = 14,
	})
	UIObject:Create("UICorner", { Parent = ui.HueInline.Instance, CornerRadius = UDim.new(1, 0) })
	local hueGradientProps = { Parent = ui.HueInline.Instance, Name = "\0" }
	local hueKeypoints = {}
	local redKey = ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0))
	local yellowKey = ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0))
	local greenKey = ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0))
	local cyanKey = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255))
	local blueKey = ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255))
	local magentaKey = ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255))
	hueKeypoints[1] = redKey
	hueKeypoints[2] = yellowKey
	hueKeypoints[3] = greenKey
	hueKeypoints[4] = cyanKey
	hueKeypoints[5] = blueKey
	hueKeypoints[6] = magentaKey
	local values = table.pack(ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)))
	table.move(values, 1, values.n, 7, hueKeypoints)
	hueGradientProps.Color = ColorSequence.new(hueKeypoints)
	UIObject:Create("UIGradient", hueGradientProps)
	ui.HueDragger = UIObject:Create("Frame", {
		Parent = ui.HueInline.Instance,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 15, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
	})
	UIObject:Create("UICorner", { Parent = ui.HueDragger.Instance, CornerRadius = UDim.new(1, 0) })
	ui.Alpha = UIObject:Create("TextButton", {
		Parent = ui.ColorpickerWindow.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 15, 1, -107),
		Size = UDim2.new(1, -32, 0, 6),
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(90, 163, 255),
	})
	UIObject:Create("UICorner", { Parent = ui.Alpha.Instance, CornerRadius = UDim.new(1, 0) })
	UIObject:Create("UIGradient", {
		Parent = ui.Alpha.Instance,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1,
			Color3.fromRGB(255, 255, 255)) }),
	})
	ui.AlphaDragger = UIObject:Create("Frame", {
		Parent = ui.Alpha.Instance, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 15, 0.5, 0), Size = UDim2
	.new(0, 12, 0, 12),
	})
	UIObject:Create("UICorner", { Parent = ui.AlphaDragger.Instance, CornerRadius = UDim.new(1, 0) })
	ui.SavedColors = UIObject:Create("ScrollingFrame", {
		Parent = ui.ColorpickerWindow.Instance,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageColor3 = Color3.fromRGB(124, 163, 255),
		MidImage = "rbxassetid://86870199131153",
		ScrollBarThickness = 0,
		Size = UDim2.new(1, -20, 0, 69),
		Selectable = false,
		TopImage = "rbxassetid://86870199131153",
		Position = UDim2.new(0, 10, 1, -30),
		BottomImage = "rbxassetid://86870199131153",
		BackgroundTransparency = 1,
	})
	UIObject:Create("UIGridLayout", {
		Parent = ui.SavedColors.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder,
		CellPadding = UDim2.new(0, 10, 0, 10),
		CellSize = UDim2.new(0, 25, 0, 27),
	})
	UIObject:Create("UIPadding", {
		Parent = ui.SavedColors.Instance,
		PaddingLeft = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, -125),
		PaddingBottom = UDim.new(0, 5),
	})
	ui.HEXInput = UIObject:Create("TextBox", {
		Parent = ui.ColorpickerWindow.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		ClearTextOnFocus = false,
		Text = "#7ca3ff",
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.new(0, 140, 0, 24),
		TextTransparency = 0.5,
		PlaceholderColor3 = Color3.fromRGB(185, 185, 185),
		Position = UDim2.new(1, -8, 1, -8),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(30, 29, 31),
	})
	ui.HEXInput:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UIPadding", { Parent = ui.HEXInput.Instance, PaddingLeft = UDim.new(0, 5) })
	ui.HexLabel = UIObject:Create("TextLabel", {
		Parent = ui.ColorpickerWindow.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "Custom:",
		TextTransparency = 0.5,
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.new(0, 40, 0, 24),
		Position = UDim2.new(0, 10, 1, -8),
		TextSize = 14,
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(30, 29, 32),
	})
	ui.HexLabel:AddToTheme({ TextColor3 = "Text" })
	UIObject:Create("UICorner", { Parent = ui.HEXInput.Instance, CornerRadius = UDim.new(0, 4) })
	function colorpicker.Get()
		return colorpicker.Color, colorpicker.Alpha
	end
	function colorpicker:Update(skipAlphaUpdate)
		local hue = colorpicker.Hue
		colorpicker.Color = Color3.fromHSV(hue, colorpicker.Saturation, colorpicker.Value)
		colorpicker.HexValue = colorpicker.Color:ToHex()
		Library.Flags[colorpicker.Flag] = { Alpha = colorpicker.Alpha, Color = colorpicker.Color, HexValue = colorpicker.HexValue, Transparency = 1 -
		colorpicker.Alpha }
		ui.Color:Tween(nil, { BackgroundColor3 = colorpicker.Color })
		ui.Palette:Tween(nil, { BackgroundColor3 = Color3.fromHSV(hue, 1, 1) })
		ui.Text.Instance.Text = ("#" .. colorpicker.HexValue):upper()
		ui.HEXInput.Instance.Text = "#" .. colorpicker.HexValue
		if not skipAlphaUpdate then
			ui.Alpha:Tween(nil, { BackgroundColor3 = colorpicker.Color })
		end
		if properties.Callback then
			Library:SafeCall(properties.Callback, colorpicker.Color, colorpicker.Alpha)
		end
	end
	local draggingPalette = false
	local paletteConnection = nil
	function colorpicker:SlidePalette(input)
		if not input or not draggingPalette then
			return
		end
		local saturation = math.clamp(
		1 - (input.Position.X - ui.Palette.Instance.AbsolutePosition.X) / ui.Palette.Instance.AbsoluteSize.X, 0, 1)
		local brightness = math.clamp(
		1 - (input.Position.Y - ui.Palette.Instance.AbsolutePosition.Y) / ui.Palette.Instance.AbsoluteSize.Y, 0, 1)
		colorpicker.Saturation = saturation
		colorpicker.Value = brightness
		local dragX = math.clamp(
		(input.Position.X - ui.Palette.Instance.AbsolutePosition.X) / ui.Palette.Instance.AbsoluteSize.X, 0, 0.955)
		local dragY = math.clamp(
		(input.Position.Y - ui.Palette.Instance.AbsolutePosition.Y) / ui.Palette.Instance.AbsoluteSize.Y, 0, 0.955)
		ui.PaletteDragger:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(dragX, 0, dragY, 0) })
		colorpicker:Update()
	end
	local draggingHue = false
	local hueConnection = nil
	function colorpicker:SlideHue(input)
		if not input or not draggingHue then
			return
		end
		colorpicker.Hue = math.clamp((input.Position.X - ui.Hue.Instance.AbsolutePosition.X) / ui.Hue.Instance.AbsoluteSize.X, 0,
			1)
		local dragX = math.clamp((input.Position.X - ui.Hue.Instance.AbsolutePosition.X) / ui.Hue.Instance.AbsoluteSize.X,
			0, 0.955)
		ui.HueDragger:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(dragX, 0, 0.5, 0) })
		colorpicker:Update()
	end
	local draggingAlpha = false
	local alphaConnection = nil
	function colorpicker:SlideAlpha(input)
		if not input or not draggingAlpha then
			return
		end
		colorpicker.Alpha = math.clamp(
		(input.Position.X - ui.Alpha.Instance.AbsolutePosition.X) / ui.Alpha.Instance.AbsoluteSize.X, 0, 1)
		local dragX = math.clamp(
		(input.Position.X - ui.Alpha.Instance.AbsolutePosition.X) / ui.Alpha.Instance.AbsoluteSize.X, 0, 0.955)
		ui.AlphaDragger:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(dragX, 0, 0.5, 0) })
		colorpicker:Update(true)
	end
	local animating = false
	local followConnection = nil
	function colorpicker:SetOpen(isOpen)
		if animating then
			return
		end
		colorpicker.IsOpen = isOpen
		animating = true
		if colorpicker.IsOpen then
			ui.ColorpickerWindow.Instance.Visible = true
			ui.ColorpickerWindow.Instance.Parent = Library.Holder.Instance
			followConnection = RunService.RenderStepped:Connect(function()
				ui.ColorpickerWindow.Instance.Position = UDim2.new(0, ui.ColorpickerButton.Instance.AbsolutePosition.X,
					0,
					ui.ColorpickerButton.Instance.AbsolutePosition.Y + ui.ColorpickerButton.Instance.AbsoluteSize.Y + 5)
			end)
			if properties.Section.IsSettings ~= true then
				for _, openFrame in Library.OpenFrames do
					if openFrame ~= colorpicker then
						openFrame:SetOpen(false)
					end
				end
			end
			Library.OpenFrames[colorpicker] = colorpicker
		else
			if not properties.Section.IsSettings then
				if Library.OpenFrames[colorpicker] then
					Library.OpenFrames[colorpicker] = nil
				end
			end
			if followConnection then
				followConnection:Disconnect()
				followConnection = nil
			end
		end
		local descendants = ui.ColorpickerWindow.Instance:GetDescendants()
		table.insert(descendants, ui.ColorpickerWindow.Instance)
		local lastTween = nil
		for _, descendant in descendants do
			local property = TweenObject:GetProperty(descendant)
			if property then
				if not descendant.ClassName:find("UI") then
					local settingsZIndex = colorpicker.IsOpen and properties.Section.IsSettings and 9
					local zIndex
					if settingsZIndex then
						zIndex = settingsZIndex
					else
						zIndex = colorpicker.IsOpen and not properties.Section.IsSettings and 3
					end
					zIndex = zIndex or 1
					descendant.ZIndex = zIndex
				end
				if type(property) == "table" then
					for _, propertyName in property do
						lastTween = TweenObject:FadeItem(descendant, propertyName, isOpen, Library.FadeSpeed)
					end
				else
					lastTween = TweenObject:FadeItem(descendant, property, isOpen, Library.FadeSpeed)
				end
			end
		end
		lastTween.Tween.Completed:Connect(function()
			animating = false
			ui.ColorpickerWindow.Instance.Visible = colorpicker.IsOpen
			task.wait(0.2)
			ui.ColorpickerWindow.Instance.Parent = not colorpicker.IsOpen and Library.UnusedHolder.Instance or
			Library.Holder.Instance
		end)
	end
	function colorpicker:Set(color, alpha)
		if type(color) == "table" then
			color = Color3.fromRGB(color[1], color[2], color[3])
			alpha = color[4]
		elseif type(color) == "string" then
			color = Color3.fromHex(color)
		end
		local hue, saturation, brightness = color:ToHSV()
		colorpicker.Hue = hue
		colorpicker.Saturation = saturation
		colorpicker.Value = brightness
		colorpicker.Alpha = alpha or 0
		local paletteX = math.clamp(1 - colorpicker.Saturation, 0, 0.955)
		local paletteY = math.clamp(1 - colorpicker.Value, 0, 0.955)
		local alphaX = math.clamp(colorpicker.Alpha, 0, 0.955)
		local hueX = math.clamp(colorpicker.Hue, 0, 0.955)
		ui.PaletteDragger:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(paletteX, 0, paletteY, 0) })
		ui.HueDragger:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(hueX, 0, 0.5, 0) })
		ui.AlphaDragger:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(alphaX, 0, 0.5, 0) })
		colorpicker:Update()
	end
	ui.ColorpickerButton:Connect("MouseButton1Down", function()
		colorpicker:SetOpen(not colorpicker.IsOpen)
	end)
	ui.Palette:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingPalette = true
			colorpicker:SlidePalette(input)
			if paletteConnection then
				return
			end
			paletteConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingPalette = false
					paletteConnection:Disconnect()
					paletteConnection = nil
				end
			end)
		end
	end)
	ui.HueInline:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			colorpicker:SlideHue(input)
			if hueConnection then
				return
			end
			hueConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingHue = false
					hueConnection:Disconnect()
					hueConnection = nil
				end
			end)
		end
	end)
	ui.Alpha:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingAlpha = true
			colorpicker:SlideAlpha(input)
			if alphaConnection then
				return
			end
			alphaConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingAlpha = false
					alphaConnection:Disconnect()
					alphaConnection = nil
				end
			end)
		end
	end)
	AddColor = function(color)
		local slot = #colorpicker.SavedColors + 1
		local button = UIObject:Create("TextButton", {
			Parent = ui.SavedColors.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 200, 0, 50),
			TextSize = 14,
			BackgroundTransparency = 1,
			ZIndex = 4,
			BackgroundColor3 = color,
		})
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 6) })
		local stroke = UIObject:Create("UIStroke", {
			Parent = button.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1.5,
			Transparency = 1,
		})
		button:OnHover(function()
			stroke:Tween(nil, { Transparency = 0 })
		end)
		button:OnHoverLeave(function()
			stroke:Tween(nil, { Transparency = 1 })
		end)
		colorpicker.SavedColors[slot] = { Color = color, Alpha = colorpicker.Alpha }
		button:Connect("MouseButton1Down", function()
			local saved = colorpicker.SavedColors[slot]
			colorpicker:Set(saved.Color, saved.Alpha)
		end)
		button:Tween(nil, { BackgroundTransparency = 0 })
	end
	local presetColors = {
		Orange = Color3.fromRGB(245, 114, 66),
		Pink = Color3.fromRGB(245, 66, 191),
		Purple = Color3.fromRGB(124, 54, 245),
		["Pink 2"] = Color3.fromRGB(202, 110, 255),
		["Pink 3"] = Color3.fromRGB(250, 142, 239),
		Yellow = Color3.fromRGB(214, 200, 92),
		["Orange 2"] = Color3.fromRGB(255, 93, 48),
		["Orange 3"] = Color3.fromRGB(255, 150, 56),
		Green = Color3.fromRGB(0, 255, 0),
		Blue = Color3.fromRGB(0, 116, 200),
		Maroon = Color3.fromRGB(128, 0, 76),
		["Whiteish Pink"] = Color3.fromRGB(255, 194, 245),
		White = Color3.fromRGB(255, 255, 255),
		Red = Color3.fromRGB(255, 0, 0),
		["Sky Blue"] = Color3.fromRGB(171, 209, 255),
	}
	AddColor(presetColors.Orange)
	AddColor(presetColors.Pink)
	AddColor(presetColors.Purple)
	AddColor(presetColors["Pink 2"])
	AddColor(presetColors["Pink 3"])
	AddColor(presetColors.Yellow)
	AddColor(presetColors["Orange 2"])
	AddColor(presetColors["Orange 3"])
	AddColor(presetColors.Green)
	AddColor(presetColors.Blue)
	AddColor(presetColors.Maroon)
	AddColor(presetColors["Whiteish Pink"])
	AddColor(presetColors.White)
	AddColor(presetColors.Red)
	AddColor(presetColors["Sky Blue"])
	ui.HEXInput:Connect("FocusLost", function()
		local alpha = colorpicker.Alpha
		colorpicker:Set(tostring(ui.HEXInput.Instance.Text), alpha)
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if draggingPalette then
				colorpicker:SlidePalette(input)
			end
			if draggingHue then
				colorpicker:SlideHue(input)
			end
			if draggingAlpha then
				colorpicker:SlideAlpha(input)
			end
		end
	end)
	Library:Connect(UserInputService.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not colorpicker.IsOpen then
				return
			end
			if Library:IsMouseOverFrame(ui.ColorpickerWindow) or Library:IsMouseOverFrame(ui.PaletteIcon) and not properties.Section.IsSettings then
				return
			end
			colorpicker:SetOpen(false)
		end
	end)
	if properties.Default then
		colorpicker:Set(properties.Default, properties.Alpha)
	end
	Library.SetFlags[colorpicker.Flag] = function(color, alpha)
		colorpicker:Set(color, alpha)
	end
	return colorpicker, ui
end

function Library:KeybindList(title)
	local keyList = {}
	Library.KeyList = keyList
	local ui = {
		KeybindsList = UIObject:Create("Frame", {
			Parent = Library.Holder.Instance,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 0.3,
			Position = UDim2.new(0, 20, 0.5, 20),
			Size = UDim2.new(0, 100, 0, 30),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(27, 25, 29),
		}),
	}
	ui.KeybindsList:AddToTheme({ BackgroundColor3 = "Section Background" })
	ui.KeybindsList:MakeDraggable()
	UIObject:Create("UICorner", { Parent = ui.KeybindsList.Instance })
	ui.Top = UIObject:Create("Frame", {
		Parent = ui.KeybindsList.Instance, Size = UDim2.new(1, 12, 0, 40), BackgroundColor3 = Color3.fromRGB(31, 31, 36),
	})
	ui.Top:AddToTheme({ BackgroundColor3 = "Section Background 2" })
	ui.Icon = UIObject:Create("ImageLabel", {
		Parent = ui.Top.Instance,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, 21, 0, 20),
		AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxassetid://81598136527047",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0.5, 0),
		ZIndex = 2,
	})
	UIObject:Create("UIGradient", {
		Parent = ui.Icon.Instance,
		Name = "\0",
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 125, 125)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(255, 255, 255)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Title = UIObject:Create("TextLabel", {
		Parent = ui.Top.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(248, 248, 248),
		Text = title,
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 45, 0.5, -1),
		ZIndex = 2,
		TextSize = 15,
	})
	ui.Title:AddToTheme({ TextColor3 = "Text" })
	UIObject:Create("UICorner", { Parent = ui.Top.Instance })
	UIObject:Create("Frame", {
		Parent = ui.Top.Instance,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(0, 10, 0, 5),
		BackgroundColor3 = Color3.fromRGB(31, 31, 36),
	}):AddToTheme({ BackgroundColor3 = "Section Background 2" })
	UIObject:Create("Frame", {
		Parent = ui.Top.Instance,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(0, 10, 0, 5),
		BackgroundColor3 = Color3.fromRGB(32, 31, 36),
	}):AddToTheme({ BackgroundColor3 = "Section Background 2" })
	ui.Content = UIObject:Create("Frame", {
		Parent = ui.KeybindsList.Instance,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 12, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	UIObject:Create("UIListLayout", {
		Parent = ui.Content.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", {
		Parent = ui.Content.Instance,
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
	})
	UIObject:Create("UIPadding", { Parent = ui.KeybindsList.Instance, PaddingRight = UDim.new(0, 12) })
	function keyList.SetVisibility()
		ui.KeybindsList.Instance.Visible = false
	end
	function keyList:Add(name, key)
		local button = UIObject:Create("TextButton", {
			Parent = ui.Content.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			TextSize = 14,
		})
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 6, 0, 6),
		})
		UIObject:Create("UIGradient", {
			Parent = frame.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		UIObject:Create("UICorner", { Parent = frame.Instance })
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = 0.3,
			Text = name .. " [" .. key .. "]",
			Size = UDim2.new(0, 0, 0, 15),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 14,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		function button:Set(name, key)
			label.Instance.Text = name .. " [" .. key .. "]"
		end
		function button:SetStatus(active)
			if active then
				label:Tween(nil, { Position = UDim2.new(0, 15, 0.5, 0), TextTransparency = 0 })
				frame:Tween(nil, { BackgroundTransparency = 0 })
			else
				label:Tween(nil, { Position = UDim2.new(0, 0, 0.5, 0), TextTransparency = 0.3 })
				frame:Tween(nil, { BackgroundTransparency = 1 })
			end
		end
		return button
	end
	return keyList
end

function Library:Notification(properties)
	local ui = {
		Notification = UIObject:Create("Frame", {
			Parent = Library.NotifHolder.Instance,
			BackgroundTransparency = 0.35,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(27, 25, 29),
		}),
	}
	ui.Title = UIObject:Create("TextLabel", {
		Parent = ui.Notification.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = properties.Title,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 15),
		RichText = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 14,
	})
	ui.Title:AddToTheme({ TextColor3 = "Text" })
	UIObject:Create("UIPadding", {
		Parent = ui.Notification.Instance,
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
	})
	UIObject:Create("UICorner", { Parent = ui.Notification.Instance, CornerRadius = UDim.new(0, 5) })
	ui.Description = UIObject:Create("TextLabel", {
		Parent = ui.Notification.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.3,
		Text = properties.Description,
		Size = UDim2.new(0, 0, 0, 15),
		RichText = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 14,
	})
	ui.Description:AddToTheme({ TextColor3 = "Text" })
	ui.Accent = UIObject:Create("Frame", {
		Parent = ui.Notification.Instance,
		Position = UDim2.new(0, 0, 0, ui.Description.Instance.AbsoluteSize.Y + ui.Title.Instance.AbsoluteSize.Y + 12),
		Size = UDim2.new(0, 0, 0, 6),
	})
	UIObject:Create("UICorner", { Parent = ui.Accent.Instance, CornerRadius = UDim.new(1, 0) })
	UIObject:Create("UIGradient", {
		Parent = ui.Accent.Instance,
		Name = "\0",
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Icon = UIObject:Create("ImageLabel", {
		Parent = ui.Notification.Instance,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(1, 0),
		Image = "rbxassetid://" .. properties.Icon,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 16, 0, 16),
	})
	if not properties.IconColor then
		UIObject:Create("UIGradient", {
			Parent = ui.Icon.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
	else
		local end_ = properties.IconColor.End
		UIObject:Create("UIGradient", {
			Parent = ui.Icon.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, properties.IconColor.Start), ColorSequenceKeypoint.new(1,
				end_) }),
		})
	end
	local absoluteSize = ui.Notification.Instance.AbsoluteSize
	ui.Notification.Instance.Size = UDim2.new(0, 0, 0, 0)
	for _, uiElement in ui do
		if uiElement.Instance:IsA("Frame") then
			uiElement.Instance.BackgroundTransparency = 1
		elseif uiElement.Instance:IsA("TextLabel") then
			uiElement.Instance.TextTransparency = 1
		elseif uiElement.Instance:IsA("ImageLabel") then
			uiElement.Instance.ImageTransparency = 1
		end
	end
	task.wait(0.2)
	ui.Notification.Instance.AutomaticSize = Enum.AutomaticSize.Y
	Library:Thread(function()
		for _, uiElement in ui do
			if uiElement.Instance:IsA("Frame") then
				uiElement:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{ BackgroundTransparency = 0 })
			elseif uiElement.Instance:IsA("TextLabel") then
				uiElement:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{ TextTransparency = 0 })
			elseif uiElement.Instance:IsA("ImageLabel") then
				uiElement:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{ ImageTransparency = 0 })
			end
		end
		ui.Notification:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
			{ Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y) })
		ui.Accent:Tween(TweenInfo.new(properties.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
			{ Size = UDim2.new(1, 0, 0, 6) })
		task.delay(properties.Duration + 0.15, function()
			for _, uiElement in ui do
				if uiElement.Instance:IsA("Frame") then
					uiElement:Tween(nil, { BackgroundTransparency = 1 })
				elseif uiElement.Instance:IsA("TextLabel") then
					uiElement:Tween(nil, { TextTransparency = 1 })
				elseif uiElement.Instance:IsA("ImageLabel") then
					uiElement:Tween(nil, { ImageTransparency = 1 })
				end
			end
			ui.Notification:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
				{ Size = UDim2.new(0, 0, 0, 0) })
			task.wait(0.5)
			ui.Notification:Clean()
		end)
	end)
end

function Library:Window(properties)
	local options = properties or {}
	local window = {
		Name = options.Name or options.name or "Window",
		SubName = options.SubName or options.subname or "Fine-tuning for sure wins",
		Logo = options.Logo or options.logo or "1l20959262762131",
		Pages = {},
		Items = {},
		IsOpen = false,
		CurrentAlignment = "LeftTabs",
	}
	local items = {
		MainFrame = UIObject:Create("Frame", {
			Parent = Library.Holder.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.12,
			Position = UDim2.new(0.552, 0, 0.5, 0),
			Size = UDim2.new(0, 609, 0, 580),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 25, 29),
		}),
	}
	items.MainFrame:AddToTheme({ BackgroundColor3 = "Background" })
	if touchEnabled then
		items.UIScale = UIObject:Create("UIScale", { Parent = items.MainFrame.Instance, Scale = 0.7 })
	else
		items.UIScale = UIObject:Create("UIScale", { Parent = items.MainFrame.Instance, Scale = 0.875 })
	end
	local function createResizeGrip(anchor, position, direction)
		local button = UIObject:Create("TextButton", {
			Parent = items.MainFrame.Instance,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 20, 0, 20),
			AnchorPoint = anchor,
			Position = position,
			BackgroundTransparency = 1,
			ZIndex = 5,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
			BorderColor3 = Color3.fromRGB(27, 42, 53),
		})
		button:AddToTheme({ BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 6) })
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			Size = UDim2.new(0, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
			ZIndex = 5,
			BorderColor3 = Color3.fromRGB(27, 42, 53),
		})
		UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 6) })
		UIObject:Create("UIGradient", {
			Parent = frame.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		for i = 1, 3 do
			local offset = 3 + (i - 1) * 3
			local frame = UIObject:Create("Frame", {
				Parent = button.Instance,
				Size = UDim2.new(0, 2, 0, 7),
				AnchorPoint = anchor,
				Position = UDim2.new(anchor.X, anchor.X == 1 and -offset or offset, anchor.Y, anchor.Y == 1 and -offset or offset),
				Rotation = -45,
				BackgroundTransparency = 0.35,
				ZIndex = 6,
				BackgroundColor3 = Color3.fromRGB(220, 220, 220),
				BorderColor3 = Color3.fromRGB(27, 42, 53),
			})
			frame:AddToTheme({ BackgroundColor3 = "Text" })
			UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(1, 0) })
		end
		button:OnHover(function()
			frame:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
			button:Tween(nil, { BackgroundTransparency = 0.3 })
		end)
		button:OnHoverLeave(function()
			frame:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
			button:Tween(nil, { BackgroundTransparency = 1 })
		end)
		local resizing = false
		local startMouse = nil
		local startScale = nil
		local startPosition = nil
		local baseSize = nil
		local connection = nil
		button:Connect("InputBegan", function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startMouse = UserInputService:GetMouseLocation()
				startScale = items.UIScale.Instance.Scale
				startPosition = items.MainFrame.Instance.Position
				local absoluteSize = items.MainFrame.Instance.AbsoluteSize
				baseSize = Vector2.new(absoluteSize.X / startScale, absoluteSize.Y / startScale)
				if connection then
					return
				end
				connection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
						connection:Disconnect()
						connection = nil
					end
				end)
			end
		end)
		Library:Connect(UserInputService.InputChanged, function(input)
			if not resizing then
				return
			end
			if not startMouse or not baseSize or not startPosition or not startScale then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local currentMouse = UserInputService:GetMouseLocation()
			local newScale = math.clamp(
			startScale +
			(currentMouse.X - startMouse.X + currentMouse.Y - startMouse.Y) / 2 / (baseSize.X + baseSize.Y) / 2 * direction,
				0.4, 2.5)
			items.UIScale.Instance.Scale = newScale
			if direction == -1 then
				local scaleDelta = newScale - startScale
				items.MainFrame.Instance.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset - baseSize.X * scaleDelta,
					startPosition.Y.Scale, startPosition.Y.Offset - baseSize.Y * scaleDelta)
			end
		end)
		return button
	end
	items.ResizeBR = createResizeGrip(Vector2.new(1, 1), UDim2.new(1, -6, 1, -6), 1)
	items.ResizeTL = createResizeGrip(Vector2.new(0, 0), UDim2.new(0, 6, 0, 6), -1)
	items.MainFrame:MakeResizeable(
	Vector2.new(items.MainFrame.Instance.AbsoluteSize.X, items.MainFrame.Instance.AbsoluteSize.Y),
		Vector2.new(9999, 9999), OriginalSizes)
	Library:MakeBlurred(items.MainFrame, window)
	items.LeftTabs = UIObject:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Visible = true,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.15,
		Size = UDim2.new(0, 203, 1, 0),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(27, 25, 29),
	})
	items.LeftTabs:AddToTheme({ BackgroundColor3 = "Background" })
	Library:MakeBlurred(items.LeftTabs, window)
	local mainFrame = items.MainFrame.Instance
	local dragging = false
	local dragStart = nil
	local startPosition = nil
	local function updateDrag(input)
		local delta = input.Position - dragStart
		items.MainFrame:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y) })
	end
	items.MainFrame:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if items.ResizeBR and Library:IsMouseOverFrame(items.ResizeBR) then
				return
			end
			if items.ResizeTL and Library:IsMouseOverFrame(items.ResizeTL) then
				return
			end
			dragging = true
			dragStart = input.Position
			startPosition = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	items.LeftTabs:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				updateDrag(input)
			end
		end
	end)
	items.FloatingButton = UIObject:Create("TextButton", {
		Parent = Library.Holder.Instance,
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.new(0.5, 0, 0, 20),
		AnchorPoint = Vector2.new(0.5, 0),
		Visible = true,
		Size = UDim2.new(0, 50, 0, 50),
		BackgroundTransparency = 0.5,
		ZIndex = 127,
		BackgroundColor3 = Library.Theme.Background,
	})
	items.FloatingButton:AddToTheme({ BackgroundColor3 = "Background" })
	local floatingButton = items.FloatingButton.Instance
	local draggingButton = false
	local buttonDragStart = nil
	local buttonStartPosition = nil
	local function updateButtonDrag(input)
		local delta = input.Position - buttonDragStart
		items.FloatingButton:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(buttonStartPosition.X.Scale, buttonStartPosition.X.Offset + delta.X, buttonStartPosition.Y.Scale,
				buttonStartPosition.Y.Offset + delta.Y) })
	end
	items.FloatingButton:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingButton = true
			buttonDragStart = input.Position
			buttonStartPosition = floatingButton.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingButton = false
				end
			end)
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if draggingButton then
				updateButtonDrag(input)
			end
		end
	end)
	items.FloatingLogo = UIObject:Create("ImageLabel", {
		Parent = items.FloatingButton.Instance,
		Image = "rbxassetid://" .. window.Logo,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 127,
		Size = UDim2.new(1, -27, 1, -25),
	})
	UIObject:Create("UICorner",
		{ Parent = items.FloatingButton.Instance, CornerRadius = UDim.new(1, 0), Name = "UICorner" })
	UIObject:Create("UIGradient", {
		Parent = items.FloatingLogo.Instance,
		Enabled = true,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.PagePlaceholder = UIObject:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Visible = true,
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
	})
	UIObject:Create("UIListLayout", {
		Parent = items.LeftTabs.Instance, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", {
		Parent = items.LeftTabs.Instance,
		PaddingTop = UDim.new(0, 15),
		PaddingBottom = UDim.new(0, 15),
		PaddingRight = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
	})
	items.Logo = UIObject:Create("ImageLabel", {
		Parent = items.MainFrame.Instance,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.new(0, 35, 0, 35),
		Image = "rbxassetid://" .. window.Logo,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 12),
		ZIndex = 2,
	})
	UIObject:Create("UIGradient", {
		Parent = items.Logo.Instance,
		Enabled = true,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.Title = UIObject:Create("TextLabel", {
		Parent = items.MainFrame.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = window.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 52, 0, 13),
		ZIndex = 2,
		TextSize = 16,
	})
	items.Title:AddToTheme({ TextColor3 = "Text" })
	items.SubTitle = UIObject:Create("TextLabel", {
		Parent = items.MainFrame.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.4,
		Text = window.SubName,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 52, 0, 30),
		ZIndex = 2,
		TextSize = 14,
	})
	items.SubTitle:AddToTheme({ TextColor3 = "Text" })
	function window:SetSubName(text)
		items.SubTitle.Instance.Text = tostring(text)
	end
	items.Content = UIObject:Create("Frame", {
		Parent = items.MainFrame.Instance,
		BackgroundTransparency = 0.75,
		Position = UDim2.new(0, 0, 0, 55),
		Size = UDim2.new(1, 0, 1, -55),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(27, 27, 29),
	})
	items.Content:AddToTheme({ BackgroundColor3 = "Background" })
	items.CloseButton = UIObject:Create("TextButton", {
		Parent = items.MainFrame.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.2,
		Position = UDim2.new(1, -14, 0, 11),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 2,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(27, 27, 29),
	})
	items.CloseButton:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = items.CloseButton.Instance, CornerRadius = UDim.new(0, 7) })
	items.CloseIcon = UIObject:Create("ImageLabel", {
		Parent = items.CloseButton.Instance,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		ImageTransparency = 0.3,
		Size = UDim2.new(0, 11, 0, 11),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://130510492706892",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 3,
	})
	items.CloseIcon:AddToTheme({ ImageColor3 = "Text" })
	items.CloseButton:Connect("MouseButton1Down", function()
		Library:Unload()
	end)
	items.CloseIconAccent = UIObject:Create("Frame", {
		Parent = items.CloseButton.Instance,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		BackgroundTransparency = 1,
	})
	UIObject:Create("UICorner", { Parent = items.CloseIconAccent.Instance, CornerRadius = UDim.new(0, 7) })
	UIObject:Create("UICorner", { Parent = items.MainFrame.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UICorner", { Parent = items.LeftTabs.Instance, CornerRadius = UDim.new(0, 4) })
	items.LeftBottomPixels = UIObject:Create("Frame", {
		Parent = items.MainFrame.Instance,
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 1, 1, 0),
		Size = UDim2.new(0, 5, 0, 5),
		ZIndex = 2,
	})
	items.___1 = UIObject:Create("Frame", {
		Parent = items.LeftBottomPixels.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 2, 1, 0),
		Size = UDim2.new(0, 1, 0, 1),
	})
	items.___1:AddToTheme({ BackgroundColor3 = "Background" })
	items.___2 = UIObject:Create("Frame", {
		Parent = items.LeftBottomPixels.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 4, 1, 0),
		Size = UDim2.new(0, 1, 0, 1),
	})
	items.___2:AddToTheme({ BackgroundColor3 = "Background" })
	items.___3 = UIObject:Create("Frame", {
		Parent = items.LeftBottomPixels.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 3, 1, 0),
		Size = UDim2.new(0, 1, 0, 1),
	})
	items.___3:AddToTheme({ BackgroundColor3 = "Background" })
	items.___4 = UIObject:Create("Frame", {
		Parent = items.LeftBottomPixels.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 3, 1, -1),
		Size = UDim2.new(0, 1, 0, 1),
	})
	items.___4:AddToTheme({ BackgroundColor3 = "Background" })
	items.___5 = UIObject:Create("Frame", {
		Parent = items.LeftBottomPixels.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 4, 1, -1),
		Size = UDim2.new(0, 1, 0, 1),
	})
	items.___5:AddToTheme({ BackgroundColor3 = "Background" })
	items.___6 = UIObject:Create("Frame", {
		Parent = items.LeftBottomPixels.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 5, 1, 0),
		Size = UDim2.new(0, 1, 0, 1),
	})
	items.___6:AddToTheme({ BackgroundColor3 = "Background" })
	items.LeftTopPixels = UIObject:Create("Frame", {
		Parent = items.MainFrame.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 1, 0, 0),
		Size = UDim2.new(0, 5, 0, 5),
		ZIndex = 2,
	})
	items.___7 = UIObject:Create("Frame", {
		Parent = items.LeftTopPixels.Instance,
		Size = UDim2.new(0, 1, 0, 1),
		Position = UDim2.new(0, 2, 0, 0),
		ZIndex = 2,
		BackgroundTransparency = 0.12,
	})
	items.___7:AddToTheme({ BackgroundColor3 = "Background" })
	items.___8 = UIObject:Create("Frame", {
		Parent = items.LeftTopPixels.Instance,
		Size = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, 3, 0, 0),
		ZIndex = 2,
	})
	items.___8:AddToTheme({ BackgroundColor3 = "Background" })
	items.___9 = UIObject:Create("Frame", {
		Parent = items.LeftTopPixels.Instance,
		Size = UDim2.new(0, 1, 0, 1),
		Position = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 0.12,
		ZIndex = 2,
	})
	items.___9:AddToTheme({ BackgroundColor3 = "Background" })
	items.___10 = UIObject:Create("Frame", {
		Parent = items.LeftTopPixels.Instance,
		Size = UDim2.new(0, 1, 0, 1),
		Position = UDim2.new(0, 5, 0, 0),
		BackgroundTransparency = 0.12,
		ZIndex = 2,
	})
	items.___10:AddToTheme({ BackgroundColor3 = "Background" })
	items.___11 = UIObject:Create("Frame", {
		Parent = items.LeftTopPixels.Instance,
		Size = UDim2.new(0, 1, 0, 1),
		Position = UDim2.new(0, 3, 0, 1),
		ZIndex = 2,
		BackgroundTransparency = 0.12,
	})
	items.___11:AddToTheme({ BackgroundColor3 = "Background" })
	items.___12 = UIObject:Create("Frame", {
		Parent = items.LeftTopPixels.Instance,
		Size = UDim2.new(0, 1, 0, 1),
		Position = UDim2.new(0, 4, 0, 1),
		ZIndex = 2,
		BackgroundTransparency = 0.12,
	})
	items.___12:AddToTheme({ BackgroundColor3 = "Background" })
	function window.SetTransparency()
		items.MainFrame.Instance.BackgroundTransparency = Library.Flags.BackgroundTransparency
		items.LeftTabs.Instance.BackgroundTransparency = Library.Flags.BackgroundTransparency
		if touchEnabled then
			items.FloatingButton.Instance.BackgroundTransparency = Library.Flags.BackgroundTransparency
		end
		for key, value in items do
			if key:find("___") then
				value.Instance.BackgroundTransparency = tonumber(Library.Flags.BackgroundTransparency)
			end
		end
	end
	UIObject:Create("UIGradient", {
		Parent = items.CloseIconAccent.Instance,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
		Rotation = -115,
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.SettingsButton = UIObject:Create("TextButton", {
		Parent = items.MainFrame.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.2,
		Position = UDim2.new(1, -98, 0, 11),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 2,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(27, 25, 29),
	})
	items.SettingsButton:AddToTheme({ BackgroundColor3 = "Element" })
	items.SearchButton = UIObject:Create("TextButton", {
		Parent = items.MainFrame.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.2,
		Position = UDim2.new(1, -56, 0, 11),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 2,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(27, 25, 29),
	})
	items.SearchButton:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = items.SearchButton.Instance, CornerRadius = UDim.new(0, 7) })
	items.SearchIcon = UIObject:Create("ImageLabel", {
		Parent = items.SearchButton.Instance,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		ImageTransparency = 0.3,
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(964, 324),
		ImageRectSize = Vector2.new(36, 36),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 3,
	})
	items.SearchIcon:AddToTheme({ ImageColor3 = "Text" })
	items.SearchIconAccent = UIObject:Create("Frame", {
		Parent = items.SearchButton.Instance,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		BackgroundTransparency = 1,
	})
	UIObject:Create("UICorner", { Parent = items.SearchIconAccent.Instance, CornerRadius = UDim.new(0, 7) })
	UIObject:Create("UIGradient", {
		Parent = items.SearchIconAccent.Instance,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
		Rotation = -115,
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.SearchButton:OnHover(function()
		items.SearchIconAccent:Tween(
		TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
	end)
	items.SearchButton:OnHoverLeave(function()
		items.SearchIconAccent:Tween(
		TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
	end)
	items.SearchOverlay = UIObject:Create("TextButton", {
		Parent = Library.UnusedHolder.Instance,
		Visible = false,
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 50,
		ClipsDescendants = true,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	})
	items.SearchPanel = UIObject:Create("Frame", {
		Parent = items.SearchOverlay.Instance,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.8, 0, 0.7, 0),
		ZIndex = 51,
		BackgroundColor3 = Color3.fromRGB(27, 27, 29),
	})
	items.SearchPanel:AddToTheme({ BackgroundColor3 = "Background" })
	UIObject:Create("UICorner", { Parent = items.SearchPanel.Instance, CornerRadius = UDim.new(0, 8) })
	UIObject:Create("UIStroke", {
		Parent = items.SearchPanel.Instance,
		Color = Color3.fromRGB(35, 33, 38),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
	}):AddToTheme({ Color = "Outline" })
	items.SearchInputContainer = UIObject:Create("Frame", {
		Parent = items.SearchPanel.Instance,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -24, 0, 36),
		ZIndex = 52,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	items.SearchInputContainer:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UISizeConstraint", {
		Parent = items.SearchPanel.Instance, MaxSize = Vector2.new(480, 380), MinSize = Vector2.new(300, 240),
	})
	UIObject:Create("UICorner", { Parent = items.SearchInputContainer.Instance, CornerRadius = UDim.new(0, 6) })
	items.SearchInputIcon = UIObject:Create("ImageLabel", {
		Parent = items.SearchInputContainer.Instance,
		ImageColor3 = Color3.fromRGB(141, 141, 150),
		Size = UDim2.new(0, 16, 0, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(964, 324),
		ImageRectSize = Vector2.new(36, 36),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0.5, 0),
		ZIndex = 53,
	})
	items.SearchInput = UIObject:Create("TextBox", {
		Parent = items.SearchInputContainer.Instance,
		FontFace = Library.Font,
		CursorPosition = -1,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "",
		ZIndex = 53,
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 38, 0, 0),
		PlaceholderColor3 = Color3.fromRGB(140, 140, 140),
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = "Search sections...",
		TextSize = 14,
		BackgroundTransparency = 1,
	})
	items.SearchInput:AddToTheme({ TextColor3 = "Text" })
	items.SearchResults = UIObject:Create("ScrollingFrame", {
		Parent = items.SearchPanel.Instance,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, -16, 1, -68),
		Position = UDim2.new(0, 8, 0, 56),
		BackgroundTransparency = 1,
		ZIndex = 52,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	items.SearchResults:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UIListLayout", {
		Parent = items.SearchResults.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", {
		Parent = items.SearchResults.Instance,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 8),
	})
	items.SearchEmpty = UIObject:Create("TextLabel", {
		Parent = items.SearchPanel.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(141, 141, 150),
		Text = "No sections found",
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		TextSize = 13,
		Visible = false,
		ZIndex = 52,
	})
	items.SearchHint = UIObject:Create("TextLabel", {
		Parent = items.SearchPanel.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(120, 120, 130),
		Text = "ESC to close",
		Size = UDim2.new(1, -24, 0, 20),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -8),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 12,
		ZIndex = 52,
	})
	local searchOpen = false
	local searchResults = {}
	local function clearSearchResults()
		for _, result in searchResults do
			result.Frame:Clean()
		end
		searchResults = {}
	end
	local function focusSection(section)
		local parent = section.Items.Section.Instance.Parent
		if not parent or not parent:IsA("ScrollingFrame") then
			return
		end
		local targetY = section.Items.Section.Instance.AbsolutePosition.Y - parent.AbsolutePosition.Y + parent.CanvasPosition.Y
		TweenObject:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ CanvasPosition = Vector2.new(0, math.max(0, targetY - 10)) }, true)
		local topBackground = section.Items.TopBackground
		local originalColor = topBackground.Instance.BackgroundColor3
		local flashGoal = { BackgroundColor3 = Library.Theme.Accent }
		topBackground:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), flashGoal)
		task.delay(0.6, function()
			local restoreGoal = { BackgroundColor3 = originalColor }
			topBackground:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), restoreGoal)
		end)
	end
	local function createSearchResult(page, section)
		local resultButton = UIObject:Create("TextButton", {
			Parent = items.SearchResults.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 56),
			ZIndex = 53,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(31, 29, 33),
		})
		resultButton:AddToTheme({ BackgroundColor3 = "Section Top" })
		UIObject:Create("UICorner", { Parent = resultButton.Instance, CornerRadius = UDim.new(0, 6) })
		local iconHolder = UIObject:Create("Frame", {
			Parent = resultButton.Instance,
			Size = UDim2.new(0, 32, 0, 32),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			ZIndex = 54,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		})
		iconHolder:AddToTheme({ BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = iconHolder.Instance, CornerRadius = UDim.new(0, 6) })
		local icon = UIObject:Create("ImageLabel", {
			Parent = iconHolder.Instance,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://" .. (section.Icon or "123944728972740"),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = 55,
		})
		UIObject:Create("UIGradient", { Parent = icon.Instance }):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		local titleLabel = UIObject:Create("TextLabel", {
			Parent = resultButton.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			Text = "",
			RichText = true,
			Size = UDim2.new(1, -60, 0, 16),
			Position = UDim2.new(0, 52, 0, 10),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 54,
			TextSize = 14,
		})
		titleLabel:AddToTheme({ TextColor3 = "Text" })
		local descriptionLabel = UIObject:Create("TextLabel", {
			Parent = resultButton.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(160, 160, 160),
			TextTransparency = 0.2,
			Text = section.Description ~= "" and section.Description or "(no description)",
			Size = UDim2.new(1, -60, 0, 14),
			Position = UDim2.new(0, 52, 0, 30),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 54,
			TextSize = 12,
		})
		local accentBar = UIObject:Create("Frame", {
			Parent = resultButton.Instance,
			Size = UDim2.new(0, 3, 0.7, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundTransparency = 1,
			ZIndex = 55,
		})
		UIObject:Create("UICorner", { Parent = accentBar.Instance, CornerRadius = UDim.new(1, 0) })
		UIObject:Create("UIGradient", { Parent = accentBar.Instance, Rotation = 90 }):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		resultButton:OnHover(function()
			resultButton:Tween(nil, { BackgroundTransparency = 0 })
			accentBar:Tween(nil, { BackgroundTransparency = 0 })
		end)
		resultButton:OnHoverLeave(function()
			resultButton:Tween(nil, { BackgroundTransparency = 0.2 })
			accentBar:Tween(nil, { BackgroundTransparency = 1 })
		end)
		return { Frame = resultButton, Title = titleLabel, Desc = descriptionLabel, Icon = icon, Page = page, Section = section }
	end
	local function highlightMatch(text, query)
		if not query or query == "" then
			return text
		end
		local lowerText = string.lower(text)
		local lowerQuery = string.lower(query)
		local pattern = Library:EscapePattern(lowerQuery)
		local cursor = 1
		local result = ""
		while true do
			local matchStart, matchEnd = string.find(lowerText, pattern, cursor)
			if matchStart then
				result = (result .. string.sub(text, cursor, matchStart - 1)) ..
				Library:ToRich(string.sub(text, matchStart, matchEnd), Library.Theme.Accent)
				cursor = matchEnd + 1
				continue
			end
			break
		end
		return result .. string.sub(text, cursor)
	end
	local function updateSearch(query)
		clearSearchResults()
		query = query or ""
		local lowerQuery = string.lower(query)
		local hasResults = false
		for _, page in window.Pages do
			for _, section in page.Sections do
				local sectionName = section.Name or ""
				local description = section.Description or ""
				local pageName = page.Name or ""
				local matches = query == ""
				if not matches then
					matches = string.find(string.lower(sectionName), Library:EscapePattern(lowerQuery))
				end
				if not matches then
					matches = string.find(string.lower(description), Library:EscapePattern(lowerQuery))
				end
				if not matches then
					matches = string.find(string.lower(pageName), Library:EscapePattern(lowerQuery))
				end
				if matches then
					local result = createSearchResult(page, section)
					local highlightedPage = highlightMatch(pageName, query)
					local highlightedSection = highlightMatch(sectionName, query)
					result.Title.Instance.Text = Library:ToRich(highlightedPage, Color3.fromRGB(141, 141, 150)) .. "  ›  " .. highlightedSection
					if query ~= "" and description ~= "" then
						result.Desc.Instance.Text = highlightMatch(description, query)
						result.Desc.Instance.RichText = true
					end
					result.Frame:Connect("MouseButton1Down", function()
						window:CloseSearch()
						if not page.Active then
							for _, otherPage in window.Pages do
								otherPage:Turn(otherPage == page)
							end
						end
						task.delay(0.4, function()
							focusSection(section)
						end)
					end)
					table.insert(searchResults, result)
					hasResults = true
				end
			end
		end
		items.SearchEmpty.Instance.Visible = not hasResults
	end
	function window.OpenSearch()
		if searchOpen then
			return
		end
		searchOpen = true
		items.SearchOverlay.Instance.Parent = items.MainFrame.Instance
		items.SearchOverlay.Instance.Visible = true
		items.SearchInput.Instance.Text = ""
		updateSearch("")
		items.SearchOverlay.Instance.BackgroundTransparency = 1
		items.SearchOverlay:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.4 })
		items.SearchPanel.Instance.Position = UDim2.new(0.5, 0, 0.5, -24)
		items.SearchPanel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0.5, 0) })
		task.wait(0.05)
		items.SearchInput.Instance:CaptureFocus()
	end
	function window.CloseSearch()
		if not searchOpen then
			return
		end
		searchOpen = false
		items.SearchInput.Instance:ReleaseFocus()
		items.SearchOverlay:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 })
		task.delay(0.2, function()
			if not searchOpen then
				items.SearchOverlay.Instance.Visible = false
				items.SearchOverlay.Instance.Parent = Library.UnusedHolder.Instance
				clearSearchResults()
			end
		end)
	end
	Library:Connect(items.SearchInput.Instance:GetPropertyChangedSignal("Text"), function()
		updateSearch(items.SearchInput.Instance.Text)
	end)
	items.SearchButton:Connect("MouseButton1Down", function()
		window:OpenSearch()
	end)
	items.SearchOverlay:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not Library:IsMouseOverFrame(items.SearchPanel) then
				window:CloseSearch()
			end
		end
	end)
	Library:Connect(UserInputService.InputBegan, function(input)
		if input.KeyCode == Enum.KeyCode.Escape and searchOpen then
			window:CloseSearch()
		end
	end)
	items.SearchOverlay.Instance.Active = true
	UIObject:Create("UICorner", { Parent = items.SettingsButton.Instance, CornerRadius = UDim.new(0, 7) })
	items.SettingsIcon = UIObject:Create("ImageLabel", {
		Parent = items.SettingsButton.Instance,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		ImageTransparency = 0.3,
		Size = UDim2.new(0, 15, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://122669828593160",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 3,
	})
	items.SettingsIcon:AddToTheme({ ImageColor3 = "Text" })
	items.SettingsIconAccent = UIObject:Create("Frame", {
		Parent = items.SettingsButton.Instance,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		BackgroundTransparency = 1,
	})
	UIObject:Create("UICorner", { Parent = items.SettingsIconAccent.Instance, CornerRadius = UDim.new(0, 7) })
	UIObject:Create("UIGradient", {
		Parent = items.SettingsIconAccent.Instance,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
		Rotation = -115,
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.SettingsButton:OnHover(function()
		items.SettingsIconAccent:Tween(
		TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
	end)
	items.SettingsButton:OnHoverLeave(function()
		items.SettingsIconAccent:Tween(
		TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
	end)
	items.CloseButton:OnHover(function()
		items.CloseIconAccent:Tween(
		TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
	end)
	items.CloseButton:OnHoverLeave(function()
		items.CloseIconAccent:Tween(
		TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
	end)
	local settingsPanel = { IsOpen = false, Name = "" .. #Library.Sections, Items = {}, IsSettings = true, Elements = {} }
	local settingsItems = {
		Settings = UIObject:Create("Frame", {
			Parent = Library.UnusedHolder.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.894960463, 0, 0.29451856, 0),
			Size = UDim2.new(0, 245, 0, 159),
			ZIndex = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(21, 21, 24),
		}),
	}
	settingsItems.Settings:AddToTheme({ BackgroundColor3 = "Section Background 2" })
	UIObject:Create("UICorner", { Parent = settingsItems.Settings.Instance, CornerRadius = UDim.new(0, 6) })
	settingsItems.CloseButton = UIObject:Create("TextButton", {
		Parent = settingsItems.Settings.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 32),
		ZIndex = 2,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	settingsItems.CloseButton:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = settingsItems.CloseButton.Instance, CornerRadius = UDim.new(0, 4) })
	settingsItems.Text = UIObject:Create("TextLabel", {
		Parent = settingsItems.CloseButton.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "Close",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 2,
		TextSize = 14,
	})
	settingsItems.Content = UIObject:Create("ScrollingFrame", {
		Parent = settingsItems.Settings.Instance,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Selectable = false,
		Size = UDim2.new(1, -8, 1, -46),
		Position = UDim2.new(0, 4, 0, 4),
		ScrollBarThickness = 2,
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	settingsItems.Content:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UIListLayout", {
		Parent = settingsItems.Content.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", {
		Parent = settingsItems.Content.Instance,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
	})
	settingsItems.Accent = UIObject:Create("Frame", {
		Parent = settingsItems.CloseButton.Instance,
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	settingsItems.Gradient = UIObject:Create("UIGradient", {
		Parent = settingsItems.Accent.Instance,
		Enabled = true,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	})
	settingsItems.Gradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	UIObject:Create("UICorner", { Parent = settingsItems.Accent.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UICorner", { Parent = settingsItems.CloseButton.Instance, CornerRadius = UDim.new(0, 4) })
	settingsItems.CloseButton:OnHover(function()
		settingsItems.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
	end)
	settingsItems.CloseButton:OnHoverLeave(function()
		settingsItems.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
	end)
	local connection = nil
	local animating = false
	function settingsPanel:SetOpen(isOpen)
		if animating then
			return
		end
		settingsPanel.IsOpen = isOpen
		animating = true
		if settingsPanel.IsOpen then
			for _, element in settingsPanel.Elements do
				element:RefreshPosition(true)
				task.wait(0.03)
			end
			settingsItems.Settings.Instance.Visible = true
			settingsItems.Settings.Instance.Parent = Library.Holder.Instance
			connection = RunService.RenderStepped:Connect(function()
				settingsItems.Settings.Instance.Position = UDim2.new(0, items.SettingsIcon.Instance.AbsolutePosition.X, 0,
					items.SettingsIcon.Instance.AbsolutePosition.Y + items.SettingsButton.Instance.AbsoluteSize.Y + 108)
				settingsItems.Settings.Instance.Size = UDim2.new(0, 325, 0, 230)
			end)
			for _, openFrame in Library.OpenFrames do
				if openFrame ~= settingsPanel then
					openFrame:SetOpen(false)
				end
			end
			Library.OpenFrames[settingsPanel] = settingsPanel
		else
			for _, element in settingsPanel.Elements do
				element:RefreshPosition(false)
			end
			if Library.OpenFrames[settingsPanel] then
				Library.OpenFrames[settingsPanel] = nil
			end
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
		local descendants = settingsItems.Settings.Instance:GetDescendants()
		table.insert(descendants, settingsItems.Settings.Instance)
		local lastTween = nil
		for _, descendant in descendants do
			local property = TweenObject:GetProperty(descendant)
			if property then
				if not descendant.ClassName:find("UI") then
					descendant.ZIndex = settingsPanel.IsOpen and 7 or 1
					settingsItems.Text.Instance.ZIndex = 8
				end
				if type(property) == "table" then
					for _, propertyName in property do
						lastTween = TweenObject:FadeItem(descendant, propertyName, isOpen, Library.FadeSpeed)
					end
				else
					lastTween = TweenObject:FadeItem(descendant, property, isOpen, Library.FadeSpeed)
				end
			end
		end
		lastTween.Tween.Completed:Connect(function()
			animating = false
			settingsItems.Settings.Instance.Visible = settingsPanel.IsOpen
			task.wait(0.2)
			settingsItems.Settings.Instance.Parent = not settingsPanel.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
		end)
	end
	settingsItems.CloseButton:Connect("MouseButton1Down", function()
		settingsPanel:SetOpen(false)
	end)
	items.SettingsButton:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			settingsPanel:SetOpen(not settingsPanel.IsOpen)
		end
	end)
	settingsPanel.Items = settingsItems
	setmetatable(settingsPanel, Library.Sections)
	settingsPanel:Label("First gradient color"):Colorpicker({
		Flag = "AccentColor",
		Default = Library.Theme.Accent,
		Callback = function(accent)
			Library.Theme.Accent = accent
			Library:ChangeTheme("Accent", accent)
		end,
	})
	settingsPanel:Label("Second gradient color"):Colorpicker({
		Flag = "AccentGradientColor",
		Default = Library.Theme.AccentGradient,
		Callback = function(accentGradient)
			Library.Theme.AccentGradient = accentGradient
			Library:ChangeTheme("AccentGradient", accentGradient)
		end,
	})
	settingsPanel:Dropdown({
		Name = "Font weight",
		Flag = "FontStyle",
		Default = "SemiBold",
		Items = { "Light", "Regular", "SemiBold" },
		Searchable = true,
		Callback = function(fontName)
			local font = Library.Fonts[fontName]
			if font then
				Library.Font = font
				Library:UpdateText()
			end
		end,
	})
	settingsPanel:Slider({
		Name = "Background Transparency",
		Default = 0,
		Decimals = 0.01,
		Max = 1,
		Min = 0,
		Suffix = "%",
		Flag = "BackgroundTransparency",
		Callback = function(transparency)
			window:SetTransparency(transparency)
		end,
	})
	settingsPanel:Keybind({
		Name = "Menu Keybind",
		Flag = "MenuBind",
		Default = Enum.KeyCode.LeftControl,
		Callback = function(toggled)
			window:SetOpen(toggled)
		end,
	})
	window.Items = items
	local animating = false
	function window.SetCenter()
		local absolutePosition = items.MainFrame.Instance.AbsolutePosition
		task.wait()
		items.MainFrame.Instance.AnchorPoint = Vector2.new(0, 0)
		items.MainFrame.Instance.Position = UDim2.new(0, absolutePosition.X, 0, absolutePosition.Y)
	end
	function window:SetOpen(isOpen)
		if animating then
			return
		end
		window.IsOpen = isOpen
		animating = true
		if window.IsOpen then
			items.MainFrame.Instance.Visible = true
		end
		local descendants = items.MainFrame.Instance:GetDescendants()
		table.insert(descendants, items.MainFrame.Instance)
		local lastTween = nil
		for _, descendant in descendants do
			local property = TweenObject:GetProperty(descendant)
			if property then
				if type(property) == "table" then
					for _, propertyName in property do
						lastTween = TweenObject:FadeItem(descendant, propertyName, isOpen, Library.FadeSpeed)
					end
				else
					lastTween = TweenObject:FadeItem(descendant, property, isOpen, Library.FadeSpeed)
				end
			end
		end
		lastTween.Tween.Completed:Connect(function()
			animating = false
			items.MainFrame.Instance.Visible = window.IsOpen
		end)
	end
	items.FloatingButton:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			window:SetOpen(not window.IsOpen)
		end
	end)
	function window.Init()
		for _, page in window.Pages do
			if page.Active then
				for _, section in page.Sections do
					task.spawn(function()
						section:TweenElements(true)
					end)
				end
			end
		end
	end
	window:SetCenter()
	task.wait()
	window:SetOpen(true)
	return setmetatable(window, Library)
end

function Library:Category(name)
	({
		Category = UIObject:Create("TextLabel", {
			Parent = self.Items.LeftTabs.Instance, FontFace = Library.Font, TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.4, Text = name, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(1, 0, 0, 15),
			BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, TextSize = 14,
		}),
	}).Category:AddToTheme({ TextColor3 = "Text" })
end

function Library:Page(properties)
	local options = properties or {}
	local page = {
		Window = self,
		Name = options.Name or options.name or "Page",
		Icon = options.Icon or options.icon or "100050851789190",
		Columns = options.Columns or options.columns or 2,
		Items = {},
		ColumnsData = {},
		Sections = {},
		Active = false,
	}
	local items = {
		Inactive = UIObject:Create("TextButton", {
			Parent = page.Window.Items.LeftTabs.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 40),
			ZIndex = 2,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(124, 77, 255),
		}),
	}
	items.Inactive:AddToTheme({ BackgroundColor3 = "Accent" })
	UIObject:Create("UICorner", { Parent = items.Inactive.Instance, CornerRadius = UDim.new(0, 5) })
	local gradientProps = { Parent = items.Inactive.Instance, Name = "\0" }
	local transparencyKeypoints = {}
	local keypointStart = NumberSequenceKeypoint.new(0, 0.41875)
	local keypointMiddle = NumberSequenceKeypoint.new(0.445, 0.78125)
	local keypointEnd = NumberSequenceKeypoint.new(0.751, 0.9375)
	transparencyKeypoints[1] = keypointStart
	transparencyKeypoints[2] = keypointMiddle
	transparencyKeypoints[3] = keypointEnd
	local values = table.pack(NumberSequenceKeypoint.new(1, 1))
	table.move(values, 1, values.n, 4, transparencyKeypoints)
	gradientProps.Transparency = NumberSequence.new(transparencyKeypoints)
	items.Gradient = UIObject:Create("UIGradient", gradientProps)
	items.Icon = UIObject:Create("ImageLabel", {
		Parent = items.Inactive.Instance,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, 18, 0, 18),
		AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxassetid://" .. page.Icon,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0.5, 0),
		ZIndex = 2,
	})
	UIObject:Create("UIGradient", { Parent = items.Icon.Instance, Rotation = -115 }):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.Text = UIObject:Create("TextLabel", {
		Parent = items.Inactive.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = page.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 45, 0.5, 0),
		ZIndex = 2,
		TextSize = 14,
	})
	items.Text:AddToTheme({ TextColor3 = "Text" })
	items.Page = UIObject:Create("Frame", {
		Parent = Library.UnusedHolder.Instance,
		Visible = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		Position = UDim2.new(0, 0, 0, 60),
	})
	UIObject:Create("UIListLayout", {
		Parent = items.Page.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalFlex = Enum.UIFlexAlignment.Fill,
	})
	UIObject:Create("UIPadding", {
		Parent = items.Page.Instance,
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
	})
	for i = 1, page.Columns do
		local scrollFrame = UIObject:Create("ScrollingFrame", {
			Parent = items.Page.Instance,
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 100, 0, 100),
			ZIndex = 2,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		})
		UIObject:Create("UIListLayout", {
			Parent = scrollFrame.Instance, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
		})
		page.ColumnsData[i] = scrollFrame
	end
	page.Items = items
	local animating = false
	function page:Turn(active)
		if animating then
			return
		end
		page.Active = active
		animating = true
		items.Page.Instance.Visible = active
		items.Page.Instance.Parent = active and page.Window.Items.Content.Instance or Library.UnusedHolder.Instance
		if page.Active then
			items.Inactive:Tween(nil, { BackgroundTransparency = 0.25 })
			items.Page:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) })
			for _, section in page.Sections do
				task.spawn(function()
					section:TweenElements(true, true)
				end)
			end
		else
			items.Inactive:Tween(nil, { BackgroundTransparency = 1 })
			items.Page:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 60) })
		end
		local children = items.Page.Instance:GetChildren()
		table.insert(children, items.Page.Instance)
		local lastTween = nil
		for _, child in children do
			local property = TweenObject:GetProperty(child)
			if property then
				if type(property) == "table" then
					for _, propertyName in property do
						lastTween = TweenObject:FadeItem(child, propertyName, active, Library.FadeSpeed)
					end
				else
					lastTween = TweenObject:FadeItem(child, property, active, Library.FadeSpeed)
				end
			end
		end
		if not lastTween then
			animating = false
			return
		end
		Library:Connect(lastTween.Tween.Completed, function()
			animating = false
		end)
	end
	items.Inactive:Connect("MouseButton1Down", function()
		for _, otherPage in page.Window.Pages do
			if otherPage == page and page.Active then
				return
			end
			otherPage:Turn(otherPage == page)
		end
	end)
	if #page.Window.Pages == 0 then
		page:Turn(true)
	end
	table.insert(page.Window.Pages, page)
	return setmetatable(page, Library.Pages)
end

function Library.Pages:GlobalChat(column)
	local globalChatt = {}
	Library.GlobalChatt = globalChatt
	local ui = {
		GlobalChat = UIObject:Create("Frame", {
			Parent = self.ColumnsData[column].Instance,
			BackgroundTransparency = 0.3,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 25, 29),
		}),
	}
	ui.GlobalChat:AddToTheme({ BackgroundColor3 = "Section Background 2" })
	ui.GlobalChat:MakeDraggable()
	UIObject:Create("UICorner", { Parent = ui.GlobalChat.Instance, CornerRadius = UDim.new(0, 6) })
	ui.Title = UIObject:Create("TextLabel", {
		Parent = ui.GlobalChat.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "GLOBAL CHAT",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 13),
		ZIndex = 2,
		TextSize = 16,
	})
	ui.Title:AddToTheme({ TextColor3 = "Text" })
	ui.SubTitle = UIObject:Create("TextLabel", {
		Parent = ui.GlobalChat.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.4,
		Text = "Chat with other users here.",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 30),
		ZIndex = 2,
		TextSize = 14,
	})
	ui.SubTitle:AddToTheme({ TextColor3 = "Text" })
	ui.Message = UIObject:Create("Frame", {
		Parent = ui.GlobalChat.Instance,
		Active = true,
		AnchorPoint = Vector2.new(0, 1),
		Selectable = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 1, -12),
		Size = UDim2.new(1, -66, 0, 32),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 29),
	})
	ui.Message:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Message.Instance, CornerRadius = UDim.new(0, 4) })
	ui.Background = UIObject:Create("Frame", {
		Parent = ui.Message.Instance,
		Active = true,
		Size = UDim2.new(1, 0, 1, 0),
		Selectable = true,
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	ui.Background:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Background.Instance, CornerRadius = UDim.new(0, 4) })
	ui.Input = UIObject:Create("TextBox", {
		Parent = ui.Background.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "",
		ZIndex = 2,
		Size = UDim2.new(1, -20, 0, 15),
		Position = UDim2.new(0, 10, 0, 8),
		BackgroundTransparency = 1,
		PlaceholderColor3 = Color3.fromRGB(185, 185, 185),
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = "Message...",
		TextSize = 14,
	})
	ui.Input:AddToTheme({ TextColor3 = "Text" })
	ui.SendButton = UIObject:Create("TextButton", {
		Parent = ui.GlobalChat.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.new(0, 32, 0, 32),
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(26, 26, 29),
	})
	ui.SendButton:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.SendButton.Instance, CornerRadius = UDim.new(0, 4) })
	ui.SendIcon = UIObject:Create("ImageLabel", {
		Parent = ui.SendButton.Instance,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://101636617799068",
		BackgroundTransparency = 1,
		ZIndex = 3,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22),
	})
	ui.Accent = UIObject:Create("Frame", {
		Parent = ui.SendButton.Instance,
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	UIObject:Create("UICorner", { Parent = ui.Accent.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UIGradient", {
		Parent = ui.Accent.Instance,
		Enabled = true,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.SendButton:OnHover(function()
		ui.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
	end)
	ui.SendButton:OnHoverLeave(function()
		ui.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
	end)
	ui.Messages = UIObject:Create("ScrollingFrame", {
		Parent = ui.GlobalChat.Instance,
		ScrollBarImageColor3 = Color3.fromRGB(124, 163, 255),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, -24, 1, -115),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 60),
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	ui.Messages:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UIListLayout", {
		Parent = ui.Messages.Instance, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", {
		Parent = ui.Messages.Instance,
		PaddingTop = UDim.new(0, 0),
		PaddingBottom = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 0),
	})
	ui.Status = UIObject:Create("Frame", {
		Parent = ui.GlobalChat.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.new(0, 100, 0, 24),
	})
	ui.StatusCircle = UIObject:Create("Frame", {
		Parent = ui.Status.Instance,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = Color3.fromRGB(255, 210, 62),
	})
	ui.Glow = UIObject:Create("ImageLabel", {
		Parent = ui.StatusCircle.Instance,
		ImageColor3 = Color3.fromRGB(255, 210, 62),
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 0.3,
		Size = UDim2.new(1, 8, 1, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "http://www.roblox.com/asset/?id=18245826428",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 2,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
	})
	UIObject:Create("UICorner", { Parent = ui.StatusCircle.Instance, CornerRadius = UDim.new(1, 0) })
	ui.StatusText = UIObject:Create("TextLabel", {
		Parent = ui.Status.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(255, 210, 62),
		Text = "67 Active | Connected",
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextSize = 14,
	})
	function globalChatt:SetVisibility(visible)
		ui.GlobalChat.Instance.Visible = visible
		ui.GlobalChat.Instance.Parent = visible and Data.MainFrame.Instance or Library.UnusedHolder
	end
	function globalChatt:SetStatus(text, color)
		ui.StatusText.Instance.Text = text
		ui.StatusText.Instance.TextColor3 = color
		ui.StatusCircle.Instance.BackgroundColor3 = color
	end
	function globalChatt:SetStatusText(text)
		if not Done then
			ui.StatusText.Instance.TextColor3 = Color3.fromRGB(62, 255, 91)
			ui.Glow.Instance.ImageColor3 = Color3.fromRGB(62, 255, 91)
			ui.StatusCircle.Instance.BackgroundColor3 = Color3.fromRGB(62, 255, 91)
			Done = true
		end
		ui.StatusText.Instance.Text = text
	end
	local sendCallback = nil
	function globalChatt:OnMessageSendPressed(callback)
		sendCallback = callback
	end
	function globalChatt.GetTypedMessage()
		return ui.Input.Instance.Text
	end
	function globalChatt.ClearText()
		ui.Input.Instance.Text = ""
	end
	function globalChatt:SendMessage(avatar, playerName, message, isOwnMessage)
		local messageUi = {}
		if not isOwnMessage then
			messageUi.Message1 = UIObject:Create("Frame", {
				Parent = ui.Messages.Instance,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 45),
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			messageUi.PlayerName = UIObject:Create("TextLabel", {
				Parent = messageUi.Message1.Instance,
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				Text = playerName,
				Size = UDim2.new(0, 0, 0, 15),
				BackgroundTransparency = 1,
				RichText = true,
				Position = UDim2.new(0, 38, 0, 0),
				TextTransparency = 0.3,
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 14,
			})
			messageUi.PlayerName:AddToTheme({ TextColor3 = "Text" })
			messageUi.RealMessage = UIObject:Create("Frame", {
				Parent = messageUi.Message1.Instance,
				Position = UDim2.new(0, 38, 0, 20),
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(27, 25, 29),
			})
			messageUi.RealMessage:AddToTheme({ BackgroundColor3 = "Background" })
			UIObject:Create("UISizeConstraint", { Parent = messageUi.RealMessage.Instance, MaxSize = Vector2.new(370, 70) })
			UIObject:Create("UICorner", { Parent = messageUi.RealMessage.Instance, CornerRadius = UDim.new(0, 4) })
			messageUi.MessageText = UIObject:Create("TextLabel", {
				Parent = messageUi.RealMessage.Instance,
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				Text = message,
				BackgroundTransparency = 1,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.XY,
				TextSize = 14,
				ZIndex = 2,
			})
			messageUi.MessageText:AddToTheme({ TextColor3 = "Text" })
			UIObject:Create("UIPadding", {
				Parent = messageUi.RealMessage.Instance,
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
			})
			messageUi.Avatar = UIObject:Create("ImageLabel", {
				Parent = messageUi.Message1.Instance,
				AnchorPoint = Vector2.new(0, 0.5),
				Image = avatar,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 26, 0, 30),
				ZIndex = 2,
			})
			UIObject:Create("UICorner", { Parent = messageUi.Avatar.Instance, CornerRadius = UDim.new(0, 4) })
		else
			messageUi.Message1 = UIObject:Create("Frame", {
				Parent = ui.Messages.Instance,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 45),
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			messageUi.PlayerName = UIObject:Create("TextLabel", {
				Parent = messageUi.Message1.Instance,
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				Text = playerName,
				RichText = true,
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.new(0, 0, 0, 15),
				ZIndex = 2,
				TextTransparency = 0.3,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -38, 0, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 14,
			})
			messageUi.PlayerName:AddToTheme({ TextColor3 = "Text" })
			messageUi.RealMessage = UIObject:Create("Frame", {
				Parent = messageUi.Message1.Instance,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -38, 0, 20),
				ZIndex = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(27, 25, 29),
			})
			messageUi.RealMessage:AddToTheme({ BackgroundColor3 = "Background" })
			UIObject:Create("UISizeConstraint", { Parent = messageUi.RealMessage.Instance, MaxSize = Vector2.new(370, 75) })
			UIObject:Create("UICorner", { Parent = messageUi.RealMessage.Instance, CornerRadius = UDim.new(0, 4) })
			messageUi.MessageText = UIObject:Create("TextLabel", {
				Parent = messageUi.RealMessage.Instance,
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				Text = message,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.XY,
				ZIndex = 2,
				TextWrapped = true,
				TextSize = 14,
			})
			messageUi.MessageText:AddToTheme({ TextColor3 = "Text" })
			UIObject:Create("UIPadding", {
				Parent = messageUi.RealMessage.Instance,
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
			})
			messageUi.Avatar = UIObject:Create("ImageLabel", {
				Parent = messageUi.Message1.Instance,
				AnchorPoint = Vector2.new(1, 0.5),
				Image = avatar,
				ZIndex = 2,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 30, 0, 30),
			})
			UIObject:Create("UICorner", { Parent = messageUi.Avatar.Instance, CornerRadius = UDim.new(0, 4) })
		end
	end
	ui.SendButton:Connect("MouseButton1Down", function()
		if globalChatt:GetTypedMessage() == "" then
			return
		end
		sendCallback()
	end)
	ui.Messages:Connect("ChildAdded", function()
		task.wait()
		ui.Messages:Tween(nil, {
			CanvasPosition = Vector2.new(0,
				ui.Messages.Instance.AbsoluteCanvasSize.Y - ui.Messages.Instance.AbsoluteSize.Y),
		})
	end)
	for _, descendant in ui.GlobalChat.Instance:GetDescendants() do
		if not descendant.ClassName:find("UI") then
			descendant.ZIndex = 2
		end
	end
	ui.GlobalChat.Instance.ZIndex = 2
	ui.SendIcon.Instance.ZIndex = 3
	return globalChatt
end

function Library.Pages:Section(properties)
	local options = properties or {}
	local section = {
		Window = self.Window,
		Page = self,
		Name = options.Name or options.name or "Section",
		Description = options.Description or options.Description or "",
		Icon = options.Icon or options.icon or "123944728972740",
		Side = options.Side or options.side or 1,
		Items = {},
		IsActive = true,
		IsCollapsed = false,
		ExpandedHeight = nil,
		Elements = {},
	}
	local items = {
		Section = UIObject:Create("Frame", {
			Parent = section.Page.ColumnsData[section.Side].Instance,
			BackgroundTransparency = 0.65,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 45),
			ZIndex = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(29, 28, 32),
		}),
	}
	items.Section:AddToTheme({ BackgroundColor3 = "Section Background 2" })
	items.Top = UIObject:Create("Frame", {
		Parent = items.Section.Instance,
		BackgroundTransparency = 0.65,
		Size = UDim2.new(1, 0, 0, 55),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(31, 31, 36),
	})
	items.Top:AddToTheme({ BackgroundColor3 = "Outline" })
	items.TopBackground = UIObject:Create("Frame", {
		Parent = items.Top.Instance,
		BackgroundTransparency = 0.65,
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})
	items.TopBackground:AddToTheme({ BackgroundColor3 = "Section Top" })
	items.Icon = UIObject:Create("ImageLabel", {
		Parent = items.TopBackground.Instance,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, 21, 0, 24),
		AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxassetid://" .. section.Icon,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0.5, 0),
		ZIndex = 2,
	})
	UIObject:Create("UIGradient", {
		Parent = items.Icon.Instance,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(131, 131, 131)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(255, 255, 255)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	items.Description = UIObject:Create("TextLabel", {
		Parent = items.TopBackground.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(183, 183, 183),
		Text = section.Description,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0, 28),
		TextTransparency = 0.4,
		ZIndex = 2,
		TextSize = 15,
	})
	items.Description:AddToTheme({ TextColor3 = "Text" })
	UIObject:Create("UICorner", { Parent = items.TopBackground.Instance, CornerRadius = UDim.new(0, 4) })
	items.Title = UIObject:Create("TextLabel", {
		Parent = items.TopBackground.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(248, 248, 248),
		Text = section.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0, 10),
		ZIndex = 2,
		TextSize = 15,
	})
	items.Title:AddToTheme({ TextColor3 = "Text" })
	items.Toggle = UIObject:Create("TextButton", {
		Parent = items.Top.Instance,
		Active = true,
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Selectable = false,
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 16),
		ZIndex = 2,
	})
	items.Circle = UIObject:Create("Frame", {
		Parent = items.Toggle.Instance,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.new(0, 8, 0, 8),
		ZIndex = 2,
	})
	items.Circle:AddToTheme({ BackgroundColor3 = "Text" })
	UIObject:Create("UICorner", { Parent = items.Circle.Instance, CornerRadius = UDim.new(0, 99999) })
	UIObject:Create("UICorner", { Parent = items.Toggle.Instance, CornerRadius = UDim.new(0, 9) })
	items.Gradient = UIObject:Create("UIGradient", {
		Parent = items.Toggle.Instance,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	})
	items.Gradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	UIObject:Create("UICorner", { Parent = items.Top.Instance, CornerRadius = UDim.new(0, 4) })
	items.Fill = UIObject:Create("Frame", {
		Parent = items.Top.Instance,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 1, 1, -4),
		Size = UDim2.new(1, -2, 0, 4),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})
	items.Fill:AddToTheme({ BackgroundColor3 = "Section Background" })
	UIObject:Create("UICorner", { Parent = items.Fill.Instance, CornerRadius = UDim.new(0, 4) })
	items.TopFills = UIObject:Create("Frame", {
		Parent = items.Top.Instance,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 3),
	})
	items.Right1 = UIObject:Create("Frame", {
		Parent = items.TopFills.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.65,
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
	})
	items.Right1:AddToTheme({ BackgroundColor3 = "Section Background" })
	items.Right2 = UIObject:Create("Frame", {
		Parent = items.TopFills.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.65,
		Position = UDim2.new(1, -1, 0, 1),
		Size = UDim2.new(0, 1, 0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
	})
	items.Right2:AddToTheme({ BackgroundColor3 = "Section Background" })
	items.Right3 = UIObject:Create("Frame", {
		Parent = items.TopFills.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.65,
		Position = UDim2.new(1, -2, 0, 1),
		Size = UDim2.new(0, 1, 0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
	})
	items.Right3:AddToTheme({ BackgroundColor3 = "Section Background" })
	items.Left1 = UIObject:Create("Frame", {
		Parent = items.TopFills.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.65,
		Position = UDim2.new(0, 2, 0, 0),
		Size = UDim2.new(0, 1, 0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
	})
	items.Left1:AddToTheme({ BackgroundColor3 = "Section Background" })
	items.Left2 = UIObject:Create("Frame", {
		Parent = items.TopFills.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.65,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(0, 1, 0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
	})
	items.Left2:AddToTheme({ BackgroundColor3 = "Section Background" })
	items.Left3 = UIObject:Create("Frame", {
		Parent = items.TopFills.Instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 0.65,
		Position = UDim2.new(0, 3, 0, 1),
		Size = UDim2.new(0, 1, 0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 30),
	})
	items.Left3:AddToTheme({ BackgroundColor3 = "Section Background" })
	UIObject:Create("UICorner", { Parent = items.Section.Instance, CornerRadius = UDim.new(0, 4) })
	items.Background = UIObject:Create("Frame", {
		Parent = items.Section.Instance,
		BackgroundTransparency = 0.65,
		Position = UDim2.new(0, 1, 0, 55),
		Size = UDim2.new(1, -2, 1, -56),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(24, 22, 25),
	})
	items.Background:AddToTheme({ BackgroundColor3 = "Section Background" })
	items.Content = UIObject:Create("Frame", {
		Parent = items.Background.Instance,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 15),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	UIObject:Create("UIListLayout", {
		Parent = items.Content.Instance, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	items.Fade = UIObject:Create("TextButton", {
		Parent = items.Background.Instance,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 10, 0),
		AutoButtonColor = false,
		Visible = false,
		Text = "",
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(24, 22, 25),
	})
	items.Fade:AddToTheme({ BackgroundColor3 = "Section Background" })
	UIObject:Create("UICorner", { Parent = items.Fade.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UIPadding", { Parent = items.Content.Instance, PaddingBottom = UDim.new(0, 10) })
	section.Items = items
	function section:SetCollapsed(isCollapsed, instant)
		isCollapsed = isCollapsed and true or false
		if section.IsCollapsed == isCollapsed then
			return
		end
		section.IsCollapsed = isCollapsed
		section.IsActive = not isCollapsed
		local instance = items.Section.Instance
		if isCollapsed then
			local y = instance.AbsoluteSize.Y
			if y > 55 then
				section.ExpandedHeight = y
			end
			instance.AutomaticSize = Enum.AutomaticSize.None
			instance.Size = UDim2.new(1, 0, 0, math.max(y, 55))
			if instant then
				instance.Size = UDim2.new(1, 0, 0, 55)
				items.Background.Instance.Visible = false
			else
				items.Section:Tween(nil, { Size = UDim2.new(1, 0, 0, 55) })
				task.delay(Library.Tween.Time, function()
					if section.IsCollapsed then
						items.Background.Instance.Visible = false
					end
				end)
			end
		else
			items.Background.Instance.Visible = true
			if instant then
				instance.Size = UDim2.new(1, 0, 0, 45)
				instance.AutomaticSize = Enum.AutomaticSize.Y
			else
				items.Section:Tween(nil,
					{ Size = UDim2.new(1, 0, 0, section.ExpandedHeight or 70 + items.Content.Instance.AbsoluteSize.Y) })
				task.delay(Library.Tween.Time, function()
					if section.IsCollapsed then
						return
					end
					instance.Size = UDim2.new(1, 0, 0, 45)
					instance.AutomaticSize = Enum.AutomaticSize.Y
				end)
			end
		end
		if isCollapsed then
			items.Gradient.Instance.Enabled = false
			items.Toggle:ChangeItemTheme({ BackgroundColor3 = "Element" })
			items.Toggle:Tween(nil, { BackgroundColor3 = Library.Theme.Element })
			items.Circle:Tween(nil, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 4, 0.5, 0),
				BackgroundColor3 = Library.Theme.Text,
				BackgroundTransparency = 0.6,
			})
		else
			items.Gradient.Instance.Enabled = true
			items.Toggle:ChangeItemTheme({ BackgroundColor3 = "Text" })
			items.Toggle:Tween(nil, { BackgroundColor3 = Library.Theme.Text })
			items.Circle:Tween(nil, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -4, 0.5, 0),
				BackgroundColor3 = Library.Theme.Text,
				BackgroundTransparency = 0,
			})
		end
	end
	function section:Collapse(instant)
		section:SetCollapsed(true, instant)
	end
	function section:Expand(instant)
		section:SetCollapsed(false, instant)
	end
	function section.ToggleBackground()
		section:SetCollapsed(not section.IsCollapsed)
	end
	Library:Connect(items.Content.Instance.Changed, function(property)
		if property == "AbsoluteSize" then
			items.Fade.Instance.Size = UDim2.new(1, 0, 0, items.Content.Instance.AbsoluteSize.Y + 10)
		end
	end)
	function section:TweenElements(show, force)
		if #section.Elements > 15 or force then
			for _, element in section.Elements do
				element:RefreshPosition(show)
			end
			return
		end
		for _, element in section.Elements do
			element:RefreshPosition(show)
			task.wait(0.03)
		end
	end
	items.Toggle:Connect("MouseButton1Down", function()
		section:ToggleBackground()
	end)
	if options.Collapsed or options.collapsed then
		task.defer(function()
			section:SetCollapsed(true, true)
		end)
	end
	section.Page.Sections[section.Name] = section
	return setmetatable(section, Library.Sections)
end

function Library.Sections:Toggle(properties)
	local options = properties or {}
	local toggle = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Toggle" }
	toggle.Flag = options.Flag or options.flag or Library:NextFlag()
	toggle.Default = options.Default or options.default or false
	toggle.Callback = options.Callback or options.callback or function() end
	toggle.Value = false
	local ui = {
		Toggle = UIObject:Create("TextButton", {
			Parent = toggle.Section.Items.Content.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Toggle:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Toggle.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Toggle.Instance,
		Size = UDim2.new(0, 2, 1, -12),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	ui.AccentBarGradient = UIObject:Create("UIGradient", {
		Parent = ui.AccentBar.Instance,
		Enabled = false,
		Rotation = 90,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	})
	ui.AccentBarGradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Toggle.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = toggle.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		Position = UDim2.new(0, 14, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		TextSize = 14,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.Indicator = UIObject:Create("Frame", {
		Parent = ui.Toggle.Instance,
		Size = UDim2.new(0, 18, 0, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		ZIndex = 3,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.Indicator:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.Indicator.Instance, CornerRadius = UDim.new(0, 4) })
	ui.Accent = UIObject:Create("Frame", {
		Parent = ui.Indicator.Instance,
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 3,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	UIObject:Create("UICorner", { Parent = ui.Accent.Instance, CornerRadius = UDim.new(0, 4) })
	ui.CheckImage = UIObject:Create("ImageLabel", {
		Parent = ui.Accent.Instance,
		Size = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://121760666525660",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 4,
		ImageTransparency = 1,
	})
	ui.CheckImage:AddToTheme({ ImageColor3 = "Text" })
	ui.Gradient = UIObject:Create("UIGradient", {
		Parent = ui.Accent.Instance,
		Enabled = true,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	})
	ui.Gradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Toggle:OnHover(function()
		ui.Toggle:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.15 })
	end)
	ui.Toggle:OnHoverLeave(function()
		local hoverGoal = { BackgroundTransparency = 0 }
		ui.Toggle:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), hoverGoal)
	end)
	function toggle.Get()
		return toggle.Value
	end
	function toggle:Set(value)
		toggle.Value = value
		Library.Flags[toggle.Flag] = value
		if toggle.Value then
			ui.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 0, Size = UDim2.new(1, 0, 1, 0) })
			ui.CheckImage:Tween(nil, { ImageTransparency = 0, Size = UDim2.new(0, 10, 0, 9) })
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0 })
			ui.AccentBarGradient.Instance.Enabled = true
			ui.Text:Tween(nil, { TextTransparency = 0 })
		else
			ui.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0) })
			ui.CheckImage:Tween(nil, { ImageTransparency = 1, Size = UDim2.new(0, 0, 0, 0) })
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0.5 })
			ui.AccentBarGradient.Instance.Enabled = false
			ui.Text:Tween(nil, { TextTransparency = 0.3 })
		end
		if toggle.Callback then
			Library:SafeCall(toggle.Callback, toggle.Value)
		end
	end
	function toggle:SetVisibility(visible)
		ui.Toggle.Instance.Visible = visible
	end
	function toggle:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0.5, 0) })
			ui.Indicator:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -8, 0.5, 0) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Text.Instance.Position = UDim2.new(0, 74, 0.5, 0)
			ui.Indicator.Instance.Position = UDim2.new(1, 52, 0.5, 0)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	local items = {}
	function toggle:Settings(height)
		local settings_ = { IsOpen = false, Name = "", Items = {}, IsSettings = true, Elements = {} }
		toggle.Settings = settings_
		items = {}
		items.Settings = UIObject:Create("Frame", {
			Parent = Library.UnusedHolder.Instance,
			Visible = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.894960463, 0, 0.29451856, 0),
			Size = UDim2.new(0, 245, 0, 159),
			ZIndex = 2,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(21, 21, 24),
		})
		items.Settings:AddToTheme({ BackgroundColor3 = "Background" })
		UIObject:Create("UICorner", { Parent = items.Settings.Instance, CornerRadius = UDim.new(0, 6) })
		items.SettingsIcon = UIObject:Create("ImageLabel", {
			Parent = ui.Text.Instance,
			ImageColor3 = Color3.fromRGB(141, 141, 150),
			Size = UDim2.new(0, 14, 0, 14),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://101500482366184",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 6, 0.5, 1),
			ZIndex = 3,
		})
		ui.SettingsIcon = items.SettingsIcon
		items.Content = UIObject:Create("ScrollingFrame", {
			Parent = items.Settings.Instance,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Selectable = false,
			Size = UDim2.new(1, -8, 1, -46),
			Position = UDim2.new(0, 4, 0, 4),
			ScrollBarThickness = 2,
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		})
		items.Content:AddToTheme({ ScrollBarImageColor3 = "Accent" })
		UIObject:Create("UIListLayout", {
			Parent = items.Content.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
		})
		UIObject:Create("UIPadding", {
			Parent = items.Content.Instance,
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
		})
		items.Button = UIObject:Create("TextButton", {
			Parent = items.Settings.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, -16, 0, 32),
			ZIndex = 2,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 8, 1, -8),
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		})
		items.Button:AddToTheme({ BackgroundColor3 = "Element" })
		items.Accent = UIObject:Create("Frame", {
			Parent = items.Button.Instance,
			Size = UDim2.new(0, 0, 0, 0),
			ZIndex = 2,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
		})
		items.Gradient = UIObject:Create("UIGradient", {
			Parent = items.Accent.Instance,
			Enabled = true,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		})
		items.Gradient:AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		UIObject:Create("UICorner", { Parent = items.Accent.Instance, CornerRadius = UDim.new(0, 4) })
		UIObject:Create("UICorner", { Parent = items.Button.Instance, CornerRadius = UDim.new(0, 4) })
		items.Text = UIObject:Create("TextLabel", {
			Parent = items.Button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.3,
			Text = "Close",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 15),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = 2,
			TextSize = 14,
		})
		items.Text:AddToTheme({ TextColor3 = "Text" })
		items.Button:OnHover(function()
			items.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
		end)
		items.Button:OnHoverLeave(function()
			items.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
		end)
		local connection = nil
		local animating = false
		function settings_:SetOpen(isOpen)
			if animating then
				return
			end
			settings_.IsOpen = isOpen
			animating = true
			if settings_.IsOpen then
				task.spawn(function()
					for _, element in settings_.Elements do
						element:RefreshPosition(true)
						task.wait(0.03)
					end
				end)
				items.Settings.Instance.Visible = true
				items.Settings.Instance.Parent = Library.Holder.Instance
				connection = RunService.RenderStepped:Connect(function()
					items.Settings.Instance.Position = UDim2.new(0,
						ui.Toggle.Instance.AbsolutePosition.X + ui.Toggle.Instance.AbsoluteSize.X / 1.9 + 15, 0,
						ui.Toggle.Instance.AbsolutePosition.Y + ui.Toggle.Instance.AbsoluteSize.Y + height / 1.9)
					items.Settings.Instance.Size = UDim2.new(0, 245, 0, height)
				end)
				for _, openFrame in Library.OpenFrames do
					if openFrame ~= settings_ then
						openFrame:SetOpen(false)
					end
				end
				Library.OpenFrames[settings_] = settings_
			else
				for _, element in settings_.Elements do
					element:RefreshPosition(false)
				end
				if Library.OpenFrames[settings_] then
					Library.OpenFrames[settings_] = nil
				end
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end
			local descendants = items.Settings.Instance:GetDescendants()
			table.insert(descendants, items.Settings.Instance)
			local lastTween = nil
			for _, descendant in descendants do
				local property = TweenObject:GetProperty(descendant)
				if property then
					if not descendant.ClassName:find("UI") then
						descendant.ZIndex = settings_.IsOpen and 7 or 1
					end
					if type(property) == "table" then
						for _, propertyName in property do
							lastTween = TweenObject:FadeItem(descendant, propertyName, isOpen, Library.FadeSpeed)
						end
					else
						lastTween = TweenObject:FadeItem(descendant, property, isOpen, Library.FadeSpeed)
					end
				end
			end
			lastTween.Tween.Completed:Connect(function()
				animating = false
				items.Settings.Instance.Visible = settings_.IsOpen
				task.wait(0.2)
				items.Settings.Instance.Parent = not settings_.IsOpen and Library.UnusedHolder and
				Library.UnusedHolder.Instance or Library.Holder.Instance
			end)
		end
		items.Button:Connect("MouseButton1Down", function()
			settings_:SetOpen(false)
		end)
		items.SettingsIcon:Connect("InputBegan", function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				settings_:SetOpen(not settings_.IsOpen)
			end
		end)
		Library:Connect(UserInputService.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if Library:IsMouseOverFrame(items.Settings) then
					return
				end
				settings_:SetOpen(false)
			end
		end)
		settings_.Items = items
		setmetatable(settings_, Library.Sections)
		return settings_
	end
	function toggle:Colorpicker(properties)
		local options = properties or {}
		local colorpicker = {
			Window = toggle.Window,
			Page = toggle.Page,
			Section = toggle.Section,
			Flag = options.Flag or options.flag or Library:NextFlag(),
			Default = options.Default or options.default or Color3.fromRGB(255, 255, 255),
			Callback = options.Callback or options.callback or function() end,
			Alpha = options.Alpha or options.alpha or false,
		}
		return (Library:CreateColorpicker({
			Parent = ui.SubElements, Page = colorpicker.Page, Section = colorpicker.Section, Flag = colorpicker.Flag, Default = colorpicker.Default,
			Callback = colorpicker.Callback, Alpha = colorpicker.Alpha,
		}))
	end
	function toggle:Keybind(properties)
		local options = properties or {}
		local keybind = {
			Window = toggle.Window,
			Page = toggle.Page,
			Section = toggle.Section,
			Flag = options.Flag or options.flag or Library:NextFlag(),
			Default = options.Default or options.default or Enum.KeyCode.E,
			Callback = options.Callback or options.callback or function() end,
			Mode = options.Mode or options.mode or "Toggle",
		}
		return (Library:CreateKeybind({
			Parent = ui.SubElements, Page = keybind.Page, Section = keybind.Section, Flag = keybind.Flag, Default = keybind.Default, Mode = keybind.Mode,
			Callback = keybind.Callback,
		}))
	end
	ui.Toggle:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if ui.SettingsIcon and Library:IsMouseOverFrame(ui.SettingsIcon) then
				return
			end
			toggle:Set(not toggle.Value)
		end
	end)
	toggle:Set(toggle.Default)
	Library.SetFlags[toggle.Flag] = function(value)
		task.delay(0.25, function()
			toggle:Set(value)
		end)
	end
	toggle.Section.Elements[#toggle.Section.Elements + 1] = toggle
	return toggle
end

function Library.Sections:Button(properties)
	local options = properties or {}
	local button = {
		Window = self.Window,
		Page = self.Page,
		Section = self,
		Name = options.Name or options.name or "Button",
		Icon = options.Icon or options.icon or nil,
		Callback = options.Callback or options.callback or function() end,
	}
	local ui = {
		Button = UIObject:Create("TextButton", {
			Parent = button.Section.Items.Content.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Button:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Button.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Button.Instance,
		Size = UDim2.new(0, 2, 1, -12),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	ui.AccentBarGradient = UIObject:Create("UIGradient",
		{ Parent = ui.AccentBar.Instance, Enabled = false, Rotation = 90 })
	ui.AccentBarGradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Accent = UIObject:Create("Frame", {
		Parent = ui.Button.Instance,
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	ui.Gradient = UIObject:Create("UIGradient", {
		Parent = ui.Accent.Instance,
		Enabled = true,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	})
	ui.Gradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	UIObject:Create("UICorner", { Parent = ui.Accent.Instance, CornerRadius = UDim.new(0, 5) })
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Button.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = button.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = 3,
		TextSize = 14,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	if button.Icon then
		ui.Icon = UIObject:Create("ImageLabel", {
			Parent = ui.Text.Instance,
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			ImageTransparency = 0.3,
			Size = UDim2.new(0, 18, 0, 18),
			AnchorPoint = Vector2.new(1, 0.5),
			Image = "rbxassetid://" .. button.Icon,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -8, 0.5, 0),
			ZIndex = 3,
		})
		ui.Icon:AddToTheme({ ImageColor3 = "Text" })
	end
	ui.Button:OnHover(function()
		ui.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
		ui.AccentBar:Tween(nil, { BackgroundTransparency = 0 })
		ui.AccentBarGradient.Instance.Enabled = true
	end)
	ui.Button:OnHoverLeave(function()
		ui.Accent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
		ui.AccentBar:Tween(nil, { BackgroundTransparency = 0.5 })
		ui.AccentBarGradient.Instance.Enabled = false
	end)
	function button:SetVisibility(visible)
		ui.Button.Instance.Visible = visible
	end
	function button.Press()
		ui.Button:ChangeItemTheme({ BackgroundColor3 = "Accent" })
		ui.Button:Tween(nil, { BackgroundColor3 = Library.Theme.Accent })
		ui.Text:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 0 })
		if button.Icon then
			ui.Icon:Tween(nil, { ImageColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0 })
		end
		task.wait(0.2)
		Library:SafeCall(button.Callback)
		ui.Button:ChangeItemTheme({ BackgroundColor3 = "Element" })
		ui.Button:Tween(nil, { BackgroundColor3 = Library.Theme.Element })
		ui.Text:Tween(nil, { TextColor3 = Library.Theme.Text, TextTransparency = 0.3 })
		if button.Icon then
			ui.Icon:Tween(nil, { ImageColor3 = Library.Theme.Text, ImageTransparency = 0.3 })
		end
	end
	ui.Button:Connect("MouseButton1Down", function()
		button:Press()
	end)
	return button
end

function Library.Sections:Slider(properties)
	local options = properties or {}
	local slider = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Slider" }
	slider.Flag = options.Flag or options.flag or Library:NextFlag()
	slider.Min = options.Min or options.min or 0
	slider.Default = options.Default or options.default or 0
	slider.Max = options.Max or options.max or 100
	slider.Suffix = options.Suffix or options.suffix or ""
	slider.Decimals = options.Decimals or options.decimals or 1
	slider.Callback = options.Callback or options.callback or function() end
	slider.Value = 0
	slider.Sliding = false
	local ui = {
		Slider = UIObject:Create("Frame", {
			Parent = slider.Section.Items.Content.Instance,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 48),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Slider:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Slider.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Slider.Instance,
		Size = UDim2.new(0, 2, 1, -14),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0,
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	UIObject:Create("UIGradient", {
		Parent = ui.AccentBar.Instance,
		Rotation = 90,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Slider.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.15,
		Text = slider.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 8),
		ZIndex = 3,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.Value = UIObject:Create("TextLabel", {
		Parent = ui.Slider.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "50%",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -14, 0, 8),
		ZIndex = 3,
		TextSize = 14,
	})
	ui.Value:AddToTheme({ TextColor3 = "Text" })
	ui.RealSlider = UIObject:Create("TextButton", {
		Parent = ui.Slider.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 34, 1, -10),
		Size = UDim2.new(1, -68, 0, 7),
		ZIndex = 3,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.RealSlider:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.RealSlider.Instance })
	ui.Accent = UIObject:Create("Frame", {
		Parent = ui.RealSlider.Instance, Size = UDim2.new(0.5, 0, 1, 0), ZIndex = 3,
	})
	UIObject:Create("UICorner", { Parent = ui.Accent.Instance })
	ui.Icon = UIObject:Create("ImageLabel", {
		Parent = ui.Accent.Instance,
		Size = UDim2.new(0, 16, 0, 12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxassetid://117786983271442",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 5, 0.5, 0),
		ZIndex = 4,
	})
	UIObject:Create("UIGradient", {
		Parent = ui.Accent.Instance,
		Rotation = -102,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(166, 166, 166)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Plus = UIObject:Create("TextButton", {
		Parent = ui.Slider.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "+",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -10, 1, -14),
		ZIndex = 3,
		TextSize = 16,
	})
	ui.Plus:AddToTheme({ TextColor3 = "Text" })
	ui.Minus = UIObject:Create("TextButton", {
		Parent = ui.Slider.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "-",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 20, 0, 24),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 1, -14),
		ZIndex = 3,
		TextSize = 16,
	})
	ui.Minus:AddToTheme({ TextColor3 = "Text" })
	ui.RealSlider:OnHover(function()
		ui.Icon:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 18, 0, 14) })
	end)
	ui.RealSlider:OnHoverLeave(function()
		ui.Icon:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 16, 0, 12) })
	end)
	function slider.Get()
		return slider.Value
	end
	function slider:SetVisibility(visible)
		ui.Slider.Instance.Visible = visible
	end
	function slider:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0, 8) })
			ui.Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -14, 0, 8) })
			ui.RealSlider:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 34, 1, -10) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Text.Instance.Position = UDim2.new(0, 74, 0, 8)
			ui.Value.Instance.Position = UDim2.new(1, 44, 0, 8)
			ui.RealSlider.Instance.Position = UDim2.new(0, 94, 1, -10)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	function slider:Set(value)
		local decimals = slider.Decimals
		slider.Value = Library:Round(math.clamp(value, slider.Min, slider.Max), decimals)
		Library.Flags[slider.Flag] = slider.Value
		ui.Accent:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0) })
		ui.Value.Instance.Text = string.format("%s%s", slider.Value, slider.Suffix)
		if slider.Value >= slider.Max then
			ui.Icon.Instance.Position = UDim2.new(1, -5, 0.5, 0)
		else
			ui.Icon.Instance.Position = UDim2.new(1, 5, 0.5, 0)
		end
		if slider.Callback then
			Library:SafeCall(slider.Callback, slider.Value)
		end
	end
	ui.Plus:Connect("MouseButton1Down", function()
		slider:Set(slider.Value + slider.Decimals)
	end)
	ui.Minus:Connect("MouseButton1Down", function()
		slider:Set(slider.Value - slider.Decimals)
	end)
	local connection = nil
	ui.RealSlider:Connect("InputBegan", function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			slider.Sliding = true
			slider:Set((slider.Max - slider.Min) * (input.Position.X - ui.RealSlider.Instance.AbsolutePosition.X) /
			ui.RealSlider.Instance.AbsoluteSize.X + slider.Min)
			if connection then
				return
			end
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					slider.Sliding = false
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if slider.Sliding then
				slider:Set((slider.Max - slider.Min) * (input.Position.X - ui.RealSlider.Instance.AbsolutePosition.X) /
				ui.RealSlider.Instance.AbsoluteSize.X + slider.Min)
			end
		end
	end)
	if slider.Default then
		slider:Set(slider.Default)
	end
	Library.SetFlags[slider.Flag] = function(value)
		slider:Set(value)
	end
	slider.Section.Elements[#slider.Section.Elements + 1] = slider
	return slider
end

function Library.Sections:Dropdown(properties)
	local options = properties or {}
	local dropdown = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Dropdown" }
	dropdown.Flag = options.Flag or options.flag or Library:NextFlag()
	dropdown.Items = options.Items or options.items or { "One", "Two", "Three" }
	dropdown.Default = options.Default or options.default or nil
	dropdown.Callback = options.Callback or options.callback or function() end
	dropdown.Size = options.Size or options.size or 150
	dropdown.OptionHolderSize = options.OptionHolderSize or options.optionholder or 200
	dropdown.Multi = options.Multi or options.multi or false
	dropdown.Searchable = options.Searchable or options.searchable or false
	dropdown.Value = {}
	dropdown.Options = {}
	dropdown.OptionsWithIndexes = {}
	dropdown.IsOpen = false
	local ui = {
		Dropdown = UIObject:Create("Frame", {
			Parent = dropdown.Section.Items.Content.Instance,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Dropdown:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Dropdown.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Dropdown.Instance,
		Size = UDim2.new(0, 2, 1, -12),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 6,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	ui.AccentBarGradient = UIObject:Create("UIGradient",
		{ Parent = ui.AccentBar.Instance, Enabled = false, Rotation = 90 })
	ui.AccentBarGradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Dropdown.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = dropdown.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0.5, 0),
		ZIndex = 6,
		TextSize = 14,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.RealDropdown = UIObject:Create("TextButton", {
		Parent = ui.Dropdown.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		Size = UDim2.new(0, dropdown.Size or 125, 0, 24),
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		ZIndex = 6,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.RealDropdown:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.RealDropdown.Instance, CornerRadius = UDim.new(0, 4) })
	ui.Value = UIObject:Create("TextLabel", {
		Parent = ui.RealDropdown.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "-",
		Size = UDim2.new(1, -30, 0, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		TextSize = 13,
	})
	ui.Value:AddToTheme({ TextColor3 = "Text" })
	ui.ArrowIcon = UIObject:Create("ImageLabel", {
		Parent = ui.RealDropdown.Instance,
		ImageColor3 = Color3.fromRGB(141, 141, 150),
		Size = UDim2.new(0, 14, 0, 8),
		AnchorPoint = Vector2.new(1, 0.5),
		Image = "rbxassetid://123317177279443",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -6, 0.5, 0),
		ZIndex = 6,
	})
	ui.Gradient = UIObject:Create("UIGradient", { Parent = ui.ArrowIcon.Instance, Enabled = false })
	ui.Gradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.OptionHolder = UIObject:Create("TextButton", {
		Parent = Library.UnusedHolder.Instance,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		Position = UDim2.new(0, 897, 0, 101),
		Size = UDim2.new(0, 159, 0, 87),
		BackgroundColor3 = Color3.fromRGB(27, 25, 29),
	})
	ui.OptionHolder:AddToTheme({ BackgroundColor3 = "Background" })
	UIObject:Create("UIStroke", {
		Parent = ui.OptionHolder.Instance, Color = Color3.fromRGB(35, 33, 38), ApplyStrokeMode = Enum.ApplyStrokeMode
	.Border,
	}):AddToTheme({ Color = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.OptionHolder.Instance, CornerRadius = UDim.new(0, 5) })
	ui.Holder = UIObject:Create("ScrollingFrame", {
		Parent = ui.OptionHolder.Instance,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, -16, 1, -16),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 8),
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	ui.Holder:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	if dropdown.Searchable then
		ui.Search = UIObject:Create("TextBox", {
			Parent = ui.OptionHolder.Instance,
			FontFace = Library.Font,
			CursorPosition = -1,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			Text = "",
			ZIndex = 6,
			Size = UDim2.new(1, -16, 0, 26),
			Position = UDim2.new(0, 8, 0, 8),
			PlaceholderColor3 = Color3.fromRGB(185, 185, 185),
			TextXAlignment = Enum.TextXAlignment.Left,
			PlaceholderText = "Search..",
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(26, 26, 29),
		})
		ui.Search:AddToTheme({ TextColor3 = "Text", BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = ui.Search.Instance, CornerRadius = UDim.new(0, 4) })
		UIObject:Create("UIPadding", { Parent = ui.Search.Instance, PaddingLeft = UDim.new(0, 8) })
		ui.Holder.Instance.Position = UDim2.new(0, 8, 0, 40)
		ui.Holder.Instance.Size = UDim2.new(1, -16, 1, -48)
	end
	UIObject:Create("UIListLayout", {
		Parent = ui.Holder.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	function dropdown.Get()
		return dropdown.Value
	end
	function dropdown.GetValues()
		return dropdown.Items
	end
	function dropdown:SetVisibility(visible)
		ui.Dropdown.Instance.Visible = visible
	end
	function dropdown:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0.5, 0) })
			ui.RealDropdown:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -6, 0.5, 0) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Text.Instance.Position = UDim2.new(0, 74, 0.5, 0)
			ui.RealDropdown.Instance.Position = UDim2.new(1, 54, 0.5, 0)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	ui.RealDropdown:OnHover(function()
		if dropdown.IsOpen then
			return
		end
		ui.ArrowIcon:Tween(nil, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
		ui.Gradient.Instance.Enabled = true
	end)
	ui.RealDropdown:OnHoverLeave(function()
		if dropdown.IsOpen then
			return
		end
		ui.ArrowIcon:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
		ui.Gradient.Instance.Enabled = false
	end)
	local connection = nil
	function dropdown:SetOpen(isOpen)
		if Debounce then
			return
		end
		dropdown.IsOpen = isOpen
		Debounce = true
		if dropdown.IsOpen then
			ui.OptionHolder.Instance.Visible = true
			ui.OptionHolder.Instance.Parent = Library.Holder.Instance
			ui.ArrowIcon:Tween(nil, { Rotation = 180, ImageColor3 = Color3.fromRGB(255, 255, 255) })
			ui.Gradient.Instance.Enabled = true
			Library:Thread(function()
				for _, option in dropdown.OptionsWithIndexes do
					task.spawn(function()
						option:RefreshPosition(true)
					end)
					task.wait(1)
				end
			end)
			connection = RunService.RenderStepped:Connect(function()
				ui.OptionHolder.Instance.Position = UDim2.new(0, ui.RealDropdown.Instance.AbsolutePosition.X, 0,
					ui.RealDropdown.Instance.AbsolutePosition.Y + ui.RealDropdown.Instance.AbsoluteSize.Y + 5)
				ui.OptionHolder.Instance.Size = UDim2.new(0, ui.RealDropdown.Instance.AbsoluteSize.X, 0,
					dropdown.OptionHolderSize)
			end)
			for _, openFrame in Library.OpenFrames do
				if openFrame ~= dropdown and not dropdown.Section.IsSettings then
					openFrame:SetOpen(false)
				end
			end
			Library.OpenFrames[dropdown] = dropdown
		else
			if not dropdown.IsOpen then
				for _, option in dropdown.OptionsWithIndexes do
					task.spawn(function()
						option:RefreshPosition(false)
					end)
				end
			end
			if Library.OpenFrames[dropdown] then
				Library.OpenFrames[dropdown] = nil
			end
			if connection then
				connection:Disconnect()
				connection = nil
			end
			ui.ArrowIcon:Tween(nil, { Rotation = 0, ImageColor3 = Color3.fromRGB(141, 141, 150) })
			ui.Gradient.Instance.Enabled = false
		end
		local descendants = ui.OptionHolder.Instance:GetDescendants()
		table.insert(descendants, ui.OptionHolder.Instance)
		local lastTween = nil
		for _, descendant in descendants do
			local property = TweenObject:GetProperty(descendant)
			if property then
				if not descendant.ClassName:find("UI") then
					descendant.ZIndex = dropdown.IsOpen and dropdown.Section.IsSettings and 9 or dropdown.IsOpen and 6 or 1
				end
				if type(property) == "table" then
					for _, propertyName in property do
						lastTween = TweenObject:FadeItem(descendant, propertyName, isOpen, Library.FadeSpeed)
					end
				else
					lastTween = TweenObject:FadeItem(descendant, property, isOpen, Library.FadeSpeed)
				end
			end
		end
		lastTween.Tween.Completed:Connect(function()
			Debounce = false
			ui.OptionHolder.Instance.Visible = dropdown.IsOpen
			task.wait(0.2)
			ui.OptionHolder.Instance.Parent = not dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
		end)
	end
	local function updateAccent()
		local hasValue
		if dropdown.Multi then
			hasValue = #dropdown.Value > 0
		else
			hasValue = dropdown.Value ~= nil and dropdown.Value ~= ""
		end
		if hasValue then
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0 })
			ui.AccentBarGradient.Instance.Enabled = true
		else
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0.5 })
			ui.AccentBarGradient.Instance.Enabled = false
		end
	end
	function dropdown:Set(value)
		if dropdown.Multi then
			if type(value) ~= "table" then
				return
			end
			dropdown.Value = value
			Library.Flags[dropdown.Flag] = value
			for _, name in value do
				local option = dropdown.Options[name]
				if option then
					option.Selected = true
					option:Toggle("Active")
				end
			end
			ui.Value.Instance.Text = table.concat(value, ", ")
		else
			if not dropdown.Options[value] then
				return
			end
			local option = dropdown.Options[value]
			dropdown.Value = value
			Library.Flags[dropdown.Flag] = value
			for _, otherOption in dropdown.Options do
				if otherOption ~= option then
					otherOption.Selected = false
					otherOption:Toggle("Inactive")
				else
					otherOption.Selected = true
					otherOption:Toggle("Active")
				end
			end
			ui.Value.Instance.Text = value
		end
		updateAccent()
		if dropdown.Callback then
			Library:SafeCall(dropdown.Callback, dropdown.Value)
		end
	end
	function dropdown:Add(name)
		local button = UIObject:Create("TextButton", {
			Parent = ui.Holder.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			TextSize = 14,
		})
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 6, 0, 6),
		})
		UIObject:Create("UIGradient", {
			Parent = frame.Instance,
			Enabled = true,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		UIObject:Create("UICorner", { Parent = frame.Instance })
		local label = UIObject:Create("TextLabel", {
			Parent = frame.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = 0.3,
			Text = name,
			Size = UDim2.new(0, 0, 0, 15),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 30, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 14,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		local option
		option = {
			Button = button,
			Name = name,
			OptionText = label,
			OptionAccent = frame,
			IsSearching = false,
			Selected = false,
			Toggle = function(self, state)
				if state == "Active" then
					label:Tween(nil, { TextTransparency = 0, Position = UDim2.new(0, 15, 0.5, 0) })
					frame:Tween(nil, { BackgroundTransparency = 0 })
				else
					label:Tween(nil, { TextTransparency = 0.3, Position = UDim2.new(0, 0, 0.5, 0) })
					frame:Tween(nil, { BackgroundTransparency = 1 })
				end
			end,
			Search = function(self, hidden)
				Library:Thread(function()
					if hidden then
						option.IsSearching = true
						label:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ TextTransparency = 1 })
						task.wait(0.05)
						button:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ Size = UDim2.new(1, 0, 0, 0) })
						if option.Selected then
							local hideGoal = { BackgroundTransparency = 1 }
							frame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), hideGoal)
						end
					else
						option.IsSearching = false
						label:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ TextTransparency = option.Selected and 0 or 0.3 })
						task.wait(0.05)
						button:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ Size = UDim2.new(1, 0, 0, 20) })
						if option.Selected then
							frame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
								{ BackgroundTransparency = 0 })
						end
					end
				end)
			end,
			RefreshPosition = function(self, show)
				if show then
					if option.Selected then
						frame:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Position = UDim2.new(0, 0, 0.5, 0) })
						label:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Position = UDim2.new(0, 15, 0.5, 0) })
					else
						label:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{ Position = UDim2.new(0, 0, 0.5, 0) })
					end
				elseif option.Selected then
					frame.Instance.Position = UDim2.new(0, 30, 0.5, 0)
					label.Instance.Position = UDim2.new(0, 45, 0.5, 0)
				else
					label.Instance.Position = UDim2.new(0, 30, 0.5, 0)
				end
			end,
			Set = function()
				option.Selected = not option.Selected
				if dropdown.Multi then
					local selectedIndex = table.find(dropdown.Value, option.Name)
					if selectedIndex then
						table.remove(dropdown.Value, selectedIndex)
					else
						table.insert(dropdown.Value, option.Name)
					end
					option:Toggle(selectedIndex and "Inactive" or "Active")
					Library.Flags[dropdown.Flag] = dropdown.Value
					ui.Value.Instance.Text = #dropdown.Value > 0 and table.concat(dropdown.Value, ", ") or "..."
				elseif option.Selected then
					dropdown.Value = option.Name
					Library.Flags[dropdown.Flag] = option.Name
					option.Selected = true
					option:Toggle("Active")
					for _, otherOption in dropdown.Options do
						if otherOption ~= option then
							otherOption.Selected = false
							otherOption:Toggle("Inactive")
						end
					end
					ui.Value.Instance.Text = option.Name
				else
					dropdown.Value = nil
					Library.Flags[dropdown.Flag] = nil
					option.Selected = false
					option:Toggle("Inactive")
					ui.Value.Instance.Text = "..."
				end
				updateAccent()
				if dropdown.Callback then
					Library:SafeCall(dropdown.Callback, dropdown.Value)
				end
			end,
		}
		option.Button:Connect("MouseButton1Down", function()
			option:Set()
		end)
		dropdown.Options[option.Name] = option
		dropdown.OptionsWithIndexes[#dropdown.OptionsWithIndexes + 1] = option
		option:RefreshPosition(false)
		return option
	end
	function dropdown:Remove(name)
		if dropdown.Options[name] then
			dropdown.Options[name].Button:Clean()
			dropdown.Options[name] = nil
		end
	end
	function dropdown:Refresh(items)
		for _, option in dropdown.Options do
			dropdown:Remove(option.Name)
		end
		for _, item in items do
			dropdown:Add(item)
		end
	end
	ui.RealDropdown:Connect("MouseButton1Down", function()
		dropdown:SetOpen(not dropdown.IsOpen)
	end)
	Library:Connect(UserInputService.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dropdown.IsOpen then
				if Library:IsMouseOverFrame(ui.OptionHolder) then
					return
				end
				dropdown:SetOpen(false)
			end
		end
	end)
	ui.RealDropdown:Connect("Changed", function(property)
		if property == "AbsolutePosition" and dropdown.IsOpen then
			dropdown.IsOpen = not Library:IsClipped(ui.OptionHolder.Instance, dropdown.Section.Items.Section.Instance.Parent)
			ui.OptionHolder.Instance.Visible = dropdown.IsOpen
		end
	end)
	for _, item in dropdown.Items do
		dropdown:Add(item)
	end
	if dropdown.Default then
		dropdown:Set(dropdown.Default)
	end
	Library.SetFlags[dropdown.Flag] = function(value)
		dropdown:Set(value)
	end
	dropdown.Section.Elements[#dropdown.Section.Elements + 1] = dropdown
	if dropdown.Searchable and ui.Search then
		Library:Connect(ui.Search.Instance:GetPropertyChangedSignal("Text"), function()
			Library:Thread(function()
				for _, option in dropdown.Options do
					local text = ui.Search.Instance.Text
					if text ~= "" then
						if string.find(string.lower(option.Name), Library:EscapePattern(string.lower(text))) then
							option.Button.Instance.Visible = true
							option:Search(false)
						else
							option:Search(true)
							option.Button.Instance.Visible = false
						end
					else
						option:Search(false)
						option.Button.Instance.Visible = true
					end
				end
			end)
		end)
	end
	return dropdown
end

function Library.Sections:Label(text)
	local label = { Window = self.Window, Page = self.Page, Section = self, Name = text or "Label" }
	local ui = {
		Label = UIObject:Create("Frame", {
			Parent = label.Section.Items.Content.Instance,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Label:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Label.Instance, CornerRadius = UDim.new(0, 5) })
	UIObject:Create("UIPadding", {
		Parent = ui.Label.Instance,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Label.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = label.Name,
		Size = UDim2.new(1, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		RichText = true,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	function label:SetText(text)
		ui.Text.Instance.Text = tostring(text)
	end
	function label:SetVisibility(visible)
		ui.Label.Instance.Visible = visible
	end
	function label:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) })
			if ui.SubElements then
				ui.SubElements:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0, 0, 0, 30) })
				TweenObject:Create(ui.Label.Instance:FindFirstChild("nig"),
					TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(1, -16, 1, -6) }, true)
			end
		else
			ui.Text.Instance.Position = UDim2.new(0, 26, 0, 0)
			if ui.SubElements then
				ui.SubElements:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0, 30, 0, 30) })
				TweenObject:Create(ui.Label.Instance:FindFirstChild("nig"),
					TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(1, 26, 1, -6) }, true)
			end
		end
	end
	function label:Colorpicker(properties)
		local options = properties or {}
		local colorpicker = {
			Window = label.Window,
			Page = label.Page,
			Section = label.Section,
			Flag = options.Flag or options.flag or Library:NextFlag(),
			Default = options.Default or options.default or Color3.fromRGB(255, 255, 255),
			Callback = options.Callback or options.callback or function() end,
			Alpha = options.Alpha or options.alpha or false,
		}
		if not ui.SubElements then
			ui.SubElements = UIObject:Create("Frame", {
				Parent = ui.Label.Instance,
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.new(0, 0, 0, 30),
				ZIndex = 2,
				BackgroundColor3 = Color3.fromRGB(27, 26, 29),
			})
			ui.SubElements:AddToTheme({ BackgroundColor3 = "Outline" })
			UIObject:Create("UICorner", { Parent = ui.SubElements.Instance, CornerRadius = UDim.new(0, 5) })
			UIObject:Create("UIListLayout", {
				Parent = ui.SubElements.Instance,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			UIObject:Create("UIPadding", { Parent = ui.SubElements.Instance, PaddingLeft = UDim.new(0, 6) })
		end
		return (Library:CreateColorpicker({
			Parent = ui.SubElements, Page = colorpicker.Page, Section = colorpicker.Section, Flag = colorpicker.Flag, Default = colorpicker.Default,
			Callback = colorpicker.Callback, Parent2 = ui.Label, Alpha = colorpicker.Alpha,
		}))
	end
	label.Section.Elements[#label.Section.Elements + 1] = label
	return label
end

function Library.Sections:Keybind(properties)
	local options = properties or {}
	local keybind = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Keybind" }
	keybind.Flag = options.Flag or options.flag or Library:NextFlag()
	keybind.Default = options.Default or options.default or Enum.KeyCode.RightShift
	keybind.Callback = options.Callback or options.callback or function() end
	keybind.Mode = options.Mode or options.mode or Enum.KeyCode.RightShift
	keybind.Method = options.Method or options.method or nil
	keybind.Value = ""
	keybind.ModeSelected = ""
	keybind.Toggled = false
	keybind.Picking = false
	if keybind.Method ~= nil then
		local method = tostring(keybind.Method)
		local normalizedMethod = string.upper(string.sub(method, 1, 1)) .. string.lower(string.sub(method, 2))
		keybind.Method = table.find({ "Toggle", "Hold", "Always" }, normalizedMethod) and normalizedMethod or nil
	end
	local ui = {
		Label = UIObject:Create("Frame", {
			Parent = keybind.Section.Items.Content.Instance,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 66),
			BackgroundColor3 = Color3.fromRGB(26, 26, 29),
		}),
	}
	ui.Label:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Label.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Label.Instance,
		Size = UDim2.new(0, 2, 1, -14),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	ui.AccentBarGradient = UIObject:Create("UIGradient",
		{ Parent = ui.AccentBar.Instance, Enabled = false, Rotation = 90 })
	ui.AccentBarGradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Label.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = keybind.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 8),
		ZIndex = 3,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.SubElements = UIObject:Create("Frame", {
		Parent = ui.Label.Instance,
		Size = UDim2.new(0, 100, 0, 22),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		ZIndex = 3,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.SubElements:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.SubElements.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UIListLayout", {
		Parent = ui.SubElements.Instance,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	ui.KeyButton = UIObject:Create("TextButton", {
		Parent = ui.SubElements.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "None",
		AutoButtonColor = false,
		Size = UDim2.new(1, -12, 1, 0),
		BackgroundTransparency = 1,
		SelectionOrder = 2,
		ZIndex = 3,
		TextSize = 13,
	})
	ui.KeyButton:AddToTheme({ TextColor3 = "Text" })
	ui.Modes = UIObject:Create("Frame", {
		Parent = ui.Label.Instance,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -8),
		Size = UDim2.new(1, -22, 0, 24),
		ZIndex = 3,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.Modes:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.Modes.Instance, CornerRadius = UDim.new(0, 5) })
	ui.Background = UIObject:Create("Frame", {
		Parent = ui.Modes.Instance, Size = UDim2.new(0.35, 0, 1, 0), ZIndex = 3, BackgroundTransparency = 0,
	})
	UIObject:Create("UICorner", { Parent = ui.Background.Instance, CornerRadius = UDim.new(0, 5) })
	UIObject:Create("UIGradient", {
		Parent = ui.Background.Instance,
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(166, 166, 166)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Toggle = UIObject:Create("TextButton", {
		Parent = ui.Modes.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextTransparency = 0,
		Text = "Toggle",
		AutoButtonColor = false,
		Size = UDim2.new(0.35, 0, 1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 4,
		TextSize = 13,
	})
	ui.Toggle:AddToTheme({
		TextColor3 = function()
			return Library.Theme.Text
		end
	})
	ui.Hold = UIObject:Create("TextButton", {
		Parent = ui.Modes.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.2,
		Text = "Hold",
		AutoButtonColor = false,
		Size = UDim2.new(0.35, 0, 1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.35, 0, 0, 0),
		ZIndex = 4,
		TextSize = 13,
	})
	ui.Hold:AddToTheme({
		TextColor3 = function()
			return Library.Theme.Text
		end
	})
	ui.Always = UIObject:Create("TextButton", {
		Parent = ui.Modes.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.2,
		Text = "Always",
		AutoButtonColor = false,
		Size = UDim2.new(0.3, 0, 1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.7, 0, 0, 0),
		ZIndex = 4,
		TextSize = 13,
	})
	ui.Always:AddToTheme({
		TextColor3 = function()
			return Library.Theme.Text
		end
	})
	if keybind.Method then
		ui.Modes.Instance.Visible = false
		ui.Label.Instance.Size = UDim2.new(1, 0, 0, 34)
	end
	local keyListEntry = nil
	if Library.KeyList then
		keyListEntry = Library.KeyList:Add("", "")
	end
	local function updateKeyList()
		if keyListEntry then
			keyListEntry:Set(options.Name, keybind.Value)
			keyListEntry:SetStatus(keybind.Toggled)
		end
		if keybind.Toggled then
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0 })
			ui.AccentBarGradient.Instance.Enabled = true
		else
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0.5 })
			ui.AccentBarGradient.Instance.Enabled = false
		end
	end
	function keybind:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0, 8) })
			ui.SubElements:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -8, 0, 6) })
			ui.Modes:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 1, -8) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Text.Instance.Position = UDim2.new(0, 74, 0, 8)
			ui.SubElements.Instance.Position = UDim2.new(1, 52, 0, 6)
			ui.Modes.Instance.Position = UDim2.new(0, 74, 1, -8)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	function keybind:SetMode(mode)
		if keybind.Method then
			mode = keybind.Method
			keybind.ModeSelected = keybind.Method
		end
		if mode == "Toggle" then
			ui.Background:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.35, 0, 1, 0) })
			ui.Toggle:ChangeItemTheme({
				TextColor3 = function()
					return Color3.fromRGB(0, 0, 0)
				end
			})
			ui.Toggle:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0) })
			ui.Hold:ChangeItemTheme({
				TextColor3 = function()
					return Library.Theme.Text
				end
			})
			ui.Hold:Tween(nil, { TextColor3 = Library.Theme.Text })
			ui.Always:ChangeItemTheme({
				TextColor3 = function()
					return Library.Theme.Text
				end
			})
			ui.Always:Tween(nil, { TextColor3 = Library.Theme.Text })
		elseif mode == "Hold" then
			ui.Background:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0.35, 0, 0, 0), Size = UDim2.new(0.35, 0, 1, 0) })
			ui.Toggle:ChangeItemTheme({
				TextColor3 = function()
					return Library.Theme.Text
				end
			})
			ui.Toggle:Tween(nil, { TextColor3 = Library.Theme.Text })
			ui.Hold:ChangeItemTheme({
				TextColor3 = function()
					return Color3.fromRGB(0, 0, 0)
				end
			})
			ui.Hold:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0) })
			ui.Always:ChangeItemTheme({
				TextColor3 = function()
					return Library.Theme.Text
				end
			})
			ui.Always:Tween(nil, { TextColor3 = Library.Theme.Text })
		elseif mode == "Always" then
			ui.Background:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0.7, 0, 0, 0), Size = UDim2.new(0.3, 0, 1, 0) })
			ui.Toggle:ChangeItemTheme({
				TextColor3 = function()
					return Library.Theme.Text
				end
			})
			ui.Toggle:Tween(nil, { TextColor3 = Library.Theme.Text })
			ui.Hold:ChangeItemTheme({
				TextColor3 = function()
					return Library.Theme.Text
				end
			})
			ui.Hold:Tween(nil, { TextColor3 = Library.Theme.Text })
			ui.Always:ChangeItemTheme({
				TextColor3 = function()
					return Color3.fromRGB(0, 0, 0)
				end
			})
			ui.Always:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0) })
		end
		Library.Flags[keybind.Flag] = { Mode = keybind.ModeSelected, Key = keybind.Key, Toggled = keybind.Toggled }
		if options.Callback then
			Library:SafeCall(options.Callback, keybind.Toggled)
		end
	end
	function keybind:Press(toggled)
		if keybind.ModeSelected == "Toggle" then
			keybind.Toggled = not keybind.Toggled
		elseif keybind.ModeSelected == "Hold" then
			keybind.Toggled = toggled
		elseif keybind.ModeSelected == "Always" then
			keybind.Toggled = true
		end
		Library.Flags[keybind.Flag] = { Mode = keybind.ModeSelected, Key = keybind.Key, Toggled = keybind.Toggled }
		if options.Callback then
			Library:SafeCall(options.Callback, keybind.Toggled)
		end
		updateKeyList()
	end
	function keybind.Get()
		return keybind.Key, keybind.ModeSelected, keybind.Toggled
	end
	function keybind:Set(newKey)
		if string.find(tostring(newKey), "Enum") then
			keybind.Key = tostring(newKey)
			local value = string.gsub(
			string.gsub(
			keyNames[keybind.Key] or string.gsub(newKey.Name == "Backspace" and "None" or newKey.Name, "Enum.", "") or "None",
				"KeyCode.", ""), "UserInputType.", "") or "None"
			keybind.Value = value
			ui.KeyButton.Instance.Text = value
			Library.Flags[keybind.Flag] = { Mode = keybind.ModeSelected, Key = keybind.Key, Toggled = keybind.Toggled }
			if options.Callback then
				Library:SafeCall(options.Callback, keybind.Toggled)
			end
			updateKeyList()
		elseif type(newKey) == "table" then
			local key = newKey.Key == "Backspace" and "None" or newKey.Key
			keybind.Key = tostring(newKey.Key)
			if keybind.Method then
				keybind.ModeSelected = keybind.Method
				keybind:SetMode(keybind.Method)
			elseif newKey.ModeSelected then
				keybind.ModeSelected = newKey.Mode
				keybind:SetMode(newKey.Mode)
			else
				keybind.ModeSelected = "Toggle"
				keybind:SetMode("Toggle")
			end
			local keyName = keyNames[keybind.Key] or string.gsub(tostring(key), "Enum.", "") or key
			if keyName then
				string.gsub(string.gsub(keyName, "KeyCode.", ""), "UserInputType.", "")
			end
			local displayName = string.gsub(string.gsub(keyName, "KeyCode.", ""), "UserInputType.", "")
			keybind.Value = displayName
			ui.KeyButton.Instance.Text = displayName
			if options.Callback then
				Library:SafeCall(options.Callback, keybind.Toggled)
			end
			updateKeyList()
		elseif table.find({ "Toggle", "Hold", "Always" }, newKey) then
			keybind.ModeSelected = keybind.Method or newKey
			keybind:SetMode(keybind.ModeSelected)
			if options.Callback then
				Library:SafeCall(options.Callback, keybind.Toggled)
			end
			updateKeyList()
		end
		keybind.Picking = false
	end
	ui.KeyButton:Connect("MouseButton1Click", function()
		keybind.Picking = true
		ui.KeyButton.Instance.Text = "."
		Library:Thread(function()
			local dotCount = 1
			while keybind.Picking do
				if dotCount == 4 then
					dotCount = 1
				end
				ui.KeyButton.Instance.Text = dotCount == 1 and "." or dotCount == 2 and ".." or dotCount == 3 and "..."
				dotCount += 1
				task.wait(0.35)
			end
		end)
		local connection = nil
		connection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				keybind:Set(input.KeyCode)
			else
				keybind:Set(input.UserInputType)
			end
			connection:Disconnect()
			connection = nil
		end)
	end)
	Library:Connect(UserInputService.InputBegan, function(input)
		if keybind.Value == "None" then
			return
		end
		local key = keybind.Key
		if tostring(input.KeyCode) == key then
			if keybind.ModeSelected == "Toggle" then
				keybind:Press()
			elseif keybind.ModeSelected == "Hold" then
				keybind:Press(true)
			elseif keybind.ModeSelected == "Always" then
				keybind:Press(true)
			end
		else
			local boundKey = keybind.Key
			if tostring(input.UserInputType) == boundKey then
				if keybind.ModeSelected == "Toggle" then
					keybind:Press()
				elseif keybind.ModeSelected == "Hold" then
					keybind:Press(true)
				elseif keybind.ModeSelected == "Always" then
					keybind:Press(true)
				end
			end
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if keybind.Value == "None" then
			return
		end
		local key = keybind.Key
		if tostring(input.KeyCode) == key then
			if keybind.ModeSelected == "Hold" then
				keybind:Press(false)
			elseif keybind.ModeSelected == "Always" then
				keybind:Press(true)
			end
		else
			local boundKey = keybind.Key
			if tostring(input.UserInputType) == boundKey then
				if keybind.ModeSelected == "Hold" then
					keybind:Press(false)
				elseif keybind.ModeSelected == "Always" then
					keybind:Press(true)
				end
			end
		end
	end)
	ui.Toggle:Connect("MouseButton1Down", function()
		if keybind.Method then
			return
		end
		keybind.ModeSelected = "Toggle"
		keybind:SetMode("Toggle")
	end)
	ui.Hold:Connect("MouseButton1Down", function()
		if keybind.Method then
			return
		end
		keybind.ModeSelected = "Hold"
		keybind:SetMode("Hold")
	end)
	ui.Always:Connect("MouseButton1Down", function()
		if keybind.Method then
			return
		end
		keybind.ModeSelected = "Always"
		keybind:SetMode("Always")
	end)
	if keybind.Default then
		keybind:Set({ Mode = keybind.Method or keybind.Mode or "Toggle", Key = keybind.Default })
	end
	Library.SetFlags[keybind.Flag] = function(value)
		keybind:Set(value)
	end
	keybind.Section.Elements[#keybind.Section.Elements + 1] = keybind
	return keybind
end

function Library.Sections:Textbox(properties)
	local options = properties or {}
	local textbox = { Window = self.Window, Page = self.Page, Section = self }
	textbox.Flag = options.Flag or options.flag or Library:NextFlag()
	textbox.Default = options.Default or options.default or ""
	textbox.Callback = options.Callback or options.callback or function() end
	textbox.Placeholder = options.Placeholder or options.placeholder or "Placeholder"
	textbox.Numeric = options.Numeric or options.numeric or false
	textbox.Finished = options.Finished or options.finished or false
	textbox.ClearTextOnFocus = options.ClearTextOnFocus or false
	textbox.Value = ""
	local ui = {
		Textbox = UIObject:Create("Frame", {
			Parent = textbox.Section.Items.Content.Instance,
			Active = true,
			BackgroundTransparency = 0,
			Selectable = true,
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Textbox:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Textbox.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Textbox.Instance,
		Size = UDim2.new(0, 2, 1, -12),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	ui.AccentBarGradient = UIObject:Create("UIGradient",
		{ Parent = ui.AccentBar.Instance, Enabled = false, Rotation = 90 })
	ui.AccentBarGradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Input = UIObject:Create("TextBox", {
		Parent = ui.Textbox.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "",
		ZIndex = 3,
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = textbox.ClearTextOnFocus,
		PlaceholderColor3 = Color3.fromRGB(140, 140, 140),
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = textbox.Placeholder,
		TextSize = 14,
	})
	ui.Input:AddToTheme({ TextColor3 = "Text" })
	function textbox.Get()
		return textbox.Value
	end
	function textbox:SetVisibility(visible)
		ui.Textbox.Instance.Visible = visible
	end
	function textbox:RefreshPosition(show)
		if show then
			ui.Input:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0, 0) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Input.Instance.Position = UDim2.new(0, 74, 0, 0)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	function textbox:Set(value)
		if textbox.Numeric then
			local invalid = not tonumber(value)
			if invalid then
				invalid = string.len(tostring(value)) > 0
			end
			if invalid then
				value = textbox.Value
			end
		end
		textbox.Value = value
		ui.Input.Instance.Text = value
		Library.Flags[textbox.Flag] = value
		if value and value ~= "" then
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0 })
			ui.AccentBarGradient.Instance.Enabled = true
		else
			ui.AccentBar:Tween(nil, { BackgroundTransparency = 0.5 })
			ui.AccentBarGradient.Instance.Enabled = false
		end
		if textbox.Callback then
			Library:SafeCall(textbox.Callback, value)
		end
	end
	if textbox.Finished then
		ui.Input:Connect("FocusLost", function(enterPressed)
			if enterPressed then
				textbox:Set(ui.Input.Instance.Text)
			end
		end)
	else
		Library:Connect(ui.Input.Instance:GetPropertyChangedSignal("Text"), function()
			textbox:Set(ui.Input.Instance.Text)
		end)
	end
	if textbox.Default then
		textbox:Set(textbox.Default)
	end
	Library.SetFlags[textbox.Flag] = function(value)
		textbox:Set(value)
	end
	textbox.Section.Elements[#textbox.Section.Elements + 1] = textbox
	return textbox
end

function Library.Sections:Listbox(properties)
	local options = properties or {}
	local listbox = { Window = self.Window, Page = self.Page, Section = self }
	listbox.Flag = options.Flag or options.flag or Library:NextFlag()
	listbox.Items = options.Items or options.items or { "One", "Two", "Three" }
	listbox.Default = options.Default or options.default or nil
	listbox.Callback = options.Callback or options.callback or function() end
	listbox.Size = options.Size or options.size or 125
	listbox.Multi = options.Multi or options.multi or false
	listbox.Value = {}
	listbox.Options = {}
	listbox.IsOpen = false
	local ui = {
		Listbox = UIObject:Create("Frame", {
			Parent = listbox.Section.Items.Content.Instance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, listbox.Size), ZIndex = 2,
		}),
	}
	ui.Search = UIObject:Create("TextBox", {
		Parent = ui.Listbox.Instance,
		FontFace = Library.Font,
		CursorPosition = -1,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = "",
		ZIndex = 2,
		Size = UDim2.new(1, 0, 0, 30),
		PlaceholderColor3 = Color3.fromRGB(185, 185, 185),
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = "Search..",
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	ui.Search:AddToTheme({ TextColor3 = "Text", BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Search.Instance, CornerRadius = UDim.new(0, 6) })
	UIObject:Create("UIPadding", {
		Parent = ui.Search.Instance, PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 8),
	})
	ui.Background = UIObject:Create("Frame", {
		Parent = ui.Listbox.Instance,
		Active = true,
		Size = UDim2.new(1, 0, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		ZIndex = 2,
	})
	ui.Background:AddToTheme({ BackgroundColor3 = "Element" })
	ui.Holder = UIObject:Create("ScrollingFrame", {
		Parent = ui.Background.Instance,
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, -4, 1, -8),
		Position = UDim2.new(0, 0, 0, 4),
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		ZIndex = 2,
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	ui.Holder:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UICorner", { Parent = ui.Background.Instance, CornerRadius = UDim.new(0, 6) })
	UIObject:Create("UIListLayout", {
		Parent = ui.Holder.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", {
		Parent = ui.Holder.Instance,
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 8),
	})
	ui._ = UIObject:Create("Frame", {
		Parent = ui.Listbox.Instance,
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 0, 25),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	ui._:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("Frame", {
		Parent = ui._.Instance,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -3),
		AnchorPoint = Vector2.new(0, 1),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	}):AddToTheme({ BackgroundColor3 = "Outline" })
	function listbox.Get()
		return listbox.Value
	end
	function listbox:SetVisibility(visible)
		ui.Listbox.Instance.Visible = visible
	end
	function listbox:RefreshPosition(show)
		if show then
			ui.Background:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 30) })
			ui.Search:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) })
			ui._:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 25) })
		else
			ui.Background.Instance.Position = UDim2.new(0, 30, 0, 26)
			ui.Search.Instance.Position = UDim2.new(0, 30, 0, 0)
			ui._.Instance.Position = UDim2.new(0, 30, 0, 25)
		end
	end
	function listbox:Set(value)
		if listbox.Multi then
			if type(value) ~= "table" then
				return
			end
			listbox.Value = value
			Library.Flags[listbox.Flag] = value
			for _, name in value do
				local option = listbox.Options[name]
				if option then
					option.Selected = true
					option:Toggle("Active")
				end
			end
		else
			if not listbox.Options[value] then
				return
			end
			local option = listbox.Options[value]
			listbox.Value = value
			Library.Flags[listbox.Flag] = value
			for _, otherOption in listbox.Options do
				if otherOption ~= option then
					otherOption.Selected = false
					otherOption:Toggle("Inactive")
				else
					otherOption.Selected = true
					otherOption:Toggle("Active")
				end
			end
		end
		if listbox.Callback then
			Library:SafeCall(listbox.Callback, listbox.Value)
		end
	end
	function listbox:Add(name)
		local button = UIObject:Create("TextButton", {
			Parent = ui.Holder.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			ZIndex = 2,
			TextSize = 14,
		})
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 6, 0, 6),
		})
		UIObject:Create("UIGradient", {
			Parent = frame.Instance,
			Enabled = true,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		UIObject:Create("UICorner", { Parent = frame.Instance })
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = 0.3,
			Text = name,
			Size = UDim2.new(0, 0, 0, 15),
			AnchorPoint = Vector2.new(0, 0.5),
			ZIndex = 2,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 14,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		local option
		option = {
			Button = button,
			Name = name,
			OptionText = label,
			IsSearching = false,
			OptionAccent = frame,
			Selected = false,
			Toggle = function(self, state)
				if state == "Active" then
					label:Tween(nil, { TextTransparency = 0, Position = UDim2.new(0, 15, 0.5, 0) })
					frame:Tween(nil, { BackgroundTransparency = 0 })
				else
					label:Tween(nil, { TextTransparency = 0.3, Position = UDim2.new(0, 0, 0.5, 0) })
					frame:Tween(nil, { BackgroundTransparency = 1 })
				end
			end,
			Search = function(self, hidden)
				Library:Thread(function()
					if hidden then
						option.IsSearching = true
						local hideGoal = { TextTransparency = 1 }
						label:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), hideGoal)
						task.wait(0.08)
						button:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ Size = UDim2.new(1, 0, 0, 0) })
						if option.Selected then
							frame:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
								{ BackgroundTransparency = 1 })
						end
					else
						option.IsSearching = false
						label:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ TextTransparency = option.Selected and 0 or 0.3 })
						task.wait(0.08)
						button:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ Size = UDim2.new(1, 0, 0, 24) })
						if option.Selected then
							frame:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
								{ BackgroundTransparency = 0 })
						end
					end
				end)
			end,
			Set = function()
				option.Selected = not option.Selected
				if listbox.Multi then
					local selectedIndex = table.find(listbox.Value, option.Name)
					if selectedIndex then
						table.remove(listbox.Value, selectedIndex)
					else
						table.insert(listbox.Value, option.Name)
					end
					option:Toggle(selectedIndex and "Inactive" or "Active")
					Library.Flags[listbox.Flag] = listbox.Value
				elseif option.Selected then
					listbox.Value = option.Name
					Library.Flags[listbox.Flag] = option.Name
					option.Selected = true
					option:Toggle("Active")
					for _, otherOption in listbox.Options do
						if otherOption ~= option and not otherOption.IsSearching then
							otherOption.Selected = false
							otherOption:Toggle("Inactive")
						end
					end
				else
					listbox.Value = nil
					Library.Flags[listbox.Flag] = nil
					option.Selected = false
					option:Toggle("Inactive")
				end
				if listbox.Callback then
					Library:SafeCall(listbox.Callback, listbox.Value)
				end
			end,
		}
		option.Button:Connect("MouseButton1Down", function()
			option:Set()
		end)
		listbox.Options[option.Name] = option
		return option
	end
	function listbox:Remove(name)
		if listbox.Options[name] then
			listbox.Options[name].Button:Clean()
			listbox.Options[name] = nil
		end
	end
	function listbox:Refresh(items)
		for _, option in listbox.Options do
			listbox:Remove(option.Name)
		end
		for _, item in items do
			listbox:Add(item)
		end
	end
	Library:Connect(ui.Search.Instance:GetPropertyChangedSignal("Text"), function()
		Library:Thread(function()
			for _, option in listbox.Options do
				local text = ui.Search.Instance.Text
				if text ~= "" then
					if string.find(string.lower(option.Name), Library:EscapePattern(string.lower(text))) then
						option.Button.Instance.Visible = true
						option:Search(false)
					else
						option:Search(true)
						option.Button.Instance.Visible = false
					end
				else
					option:Search(false)
					option.Button.Instance.Visible = true
				end
			end
		end)
	end)
	for _, item in listbox.Items do
		listbox:Add(item)
	end
	if listbox.Default then
		listbox:Set(listbox.Default)
	end
	Library.SetFlags[listbox.Flag] = function(value)
		listbox:Set(value)
	end
	listbox.Section.Elements[#listbox.Section.Elements + 1] = listbox
	return listbox
end

function Library.Sections:DropdownEx(properties)
	local options = properties or {}
	local dropdownEx = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Dropdown" }
	dropdownEx.Flag = options.Flag or options.flag or Library:NextFlag()
	dropdownEx.Items = options.Items or options.items or {}
	dropdownEx.Default = options.Default or options.default or nil
	dropdownEx.Callback = options.Callback or options.callback or function() end
	dropdownEx.Size = options.Size or options.size or 125
	dropdownEx.OptionHolderSize = options.OptionHolderSize or options.optionholder or 280
	dropdownEx.Multi = options.Multi or options.multi or false
	dropdownEx.Searchable = options.Searchable ~= false
	dropdownEx.DefaultIcon = options.DefaultIcon or options.defaulticon or "123944728972740"
	dropdownEx.Value = options.Multi and {} or nil
	dropdownEx.Options = {}
	dropdownEx.OptionsWithIndexes = {}
	dropdownEx.IsOpen = false
	dropdownEx.SearchQuery = ""
	local ui = {
		Dropdown = UIObject:Create("Frame", {
			Parent = dropdownEx.Section.Items.Content.Instance,
			Name = "DropdownEx",
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Dropdown:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Dropdown.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Dropdown.Instance,
		Size = UDim2.new(0, 2, 1, -12),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	ui.AccentBarGradient = UIObject:Create("UIGradient",
		{ Parent = ui.AccentBar.Instance, Enabled = false, Rotation = 90 })
	ui.AccentBarGradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Dropdown.Instance,
		Name = "01",
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = dropdownEx.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0.5, 0),
		ZIndex = 2,
		TextSize = 14,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.RealDropdown = UIObject:Create("TextButton", {
		Parent = ui.Dropdown.Instance,
		Name = "02",
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		Size = UDim2.new(0, dropdownEx.Size or 125, 0, 24),
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		ZIndex = 2,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.RealDropdown:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.RealDropdown.Instance, CornerRadius = UDim.new(0, 6) })
	ui.Value = UIObject:Create("TextLabel", {
		Parent = ui.RealDropdown.Instance,
		Name = "03",
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = "-",
		Size = UDim2.new(1, -40, 0, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -1),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		TextSize = 14,
	})
	ui.Value:AddToTheme({ TextColor3 = "Text" })
	ui.Liner = UIObject:Create("Frame", {
		Parent = ui.RealDropdown.Instance,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -27, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	ui.Liner:AddToTheme({ BackgroundColor3 = "Element" })
	ui.ArrowIcon = UIObject:Create("ImageLabel", {
		Parent = ui.RealDropdown.Instance,
		ImageColor3 = Color3.fromRGB(141, 141, 150),
		Size = UDim2.new(0, 16, 0, 8),
		AnchorPoint = Vector2.new(1, 0.5),
		Image = "rbxassetid://123317177279443",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -5, 0.5, 0),
		ZIndex = 2,
	})
	ui.Gradient = UIObject:Create("UIGradient", {
		Parent = ui.ArrowIcon.Instance,
		Enabled = false,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(131, 131, 131)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(255, 255, 255)) }),
	})
	ui.Gradient:AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.OptionHolder = UIObject:Create("TextButton", {
		Parent = Library.UnusedHolder.Instance,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		Position = UDim2.new(0, 897, 0, 101),
		Size = UDim2.new(0, 280, 0, dropdownEx.OptionHolderSize),
		BackgroundColor3 = Color3.fromRGB(26, 25, 29),
	})
	ui.OptionHolder:AddToTheme({ BackgroundColor3 = "Background" })
	UIObject:Create("UIStroke", {
		Parent = ui.OptionHolder.Instance, Color = Color3.fromRGB(35, 33, 38), ApplyStrokeMode = Enum.ApplyStrokeMode
	.Border,
	}):AddToTheme({ Color = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.OptionHolder.Instance, CornerRadius = UDim.new(0, 6) })
	if dropdownEx.Searchable then
		ui.Search = UIObject:Create("TextBox", {
			Parent = ui.OptionHolder.Instance,
			FontFace = Library.Font,
			CursorPosition = -1,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			Text = "",
			ZIndex = 6,
			Size = UDim2.new(1, -16, 0, 28),
			Position = UDim2.new(0, 8, 0, 8),
			PlaceholderColor3 = Color3.fromRGB(185, 185, 185),
			TextXAlignment = Enum.TextXAlignment.Left,
			PlaceholderText = "Search..",
			TextSize = 13,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		})
		ui.Search:AddToTheme({ TextColor3 = "Text", BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = ui.Search.Instance, CornerRadius = UDim.new(0, 4) })
		UIObject:Create("UIPadding", { Parent = ui.Search.Instance, PaddingLeft = UDim.new(0, 28) })
		ui.SearchIcon = UIObject:Create("ImageLabel", {
			Parent = ui.Search.Instance,
			ImageColor3 = Color3.fromRGB(141, 141, 150),
			Size = UDim2.new(0, 14, 0, 14),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://3926305904",
			ImageRectOffset = Vector2.new(964, 324),
			ImageRectSize = Vector2.new(36, 36),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -20, 0.5, 0),
			ZIndex = 4,
		})
	end
	ui.Holder = UIObject:Create("ScrollingFrame", {
		Parent = ui.OptionHolder.Instance,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, -16, 1, dropdownEx.Searchable and -52 or -16),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, dropdownEx.Searchable and 44 or 8),
		ZIndex = 6,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	ui.Holder:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UIListLayout", {
		Parent = ui.Holder.Instance, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	ui.EmptyText = UIObject:Create("TextLabel", {
		Parent = ui.OptionHolder.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(141, 141, 150),
		Text = "No results",
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundTransparency = 1,
		TextSize = 13,
		Visible = false,
		ZIndex = 6,
	})
	ui.Text.Instance.Position = UDim2.new(0, 44, 0.5, 0)
	ui.RealDropdown.Instance.Position = UDim2.new(1, 24, 0.5, 0)
	ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
	function dropdownEx.Get()
		return dropdownEx.Value
	end
	function dropdownEx:SetVisibility(visible)
		ui.Dropdown.Instance.Visible = visible
	end
	function dropdownEx:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0.5, 0) })
			ui.RealDropdown:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -6, 0.5, 0) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Text.Instance.Position = UDim2.new(0, 44, 0.5, 0)
			ui.RealDropdown.Instance.Position = UDim2.new(1, 24, 0.5, 0)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	ui.RealDropdown:OnHover(function()
		if dropdownEx.IsOpen then
			return
		end
		ui.ArrowIcon:Tween(nil, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
		ui.Gradient.Instance.Enabled = true
	end)
	ui.RealDropdown:OnHoverLeave(function()
		if dropdownEx.IsOpen then
			return
		end
		ui.ArrowIcon:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
		ui.Gradient.Instance.Enabled = false
	end)
	function dropdownEx.RefreshSearch()
		local query = string.lower(dropdownEx.SearchQuery or "")
		local hasResults = false
		for _, option in dropdownEx.Options do
			if query == "" then
				option.Container.Instance.Visible = true
				hasResults = true
			else
				local visible = string.find(string.lower(option.Name), Library:EscapePattern(query)) ~= nil
				if not visible then
					visible = option.Description
					if visible then
						visible = string.find(string.lower(option.Description), Library:EscapePattern(query)) ~= nil
					end
				end
				option.Container.Instance.Visible = visible
				if visible then
					hasResults = true
				end
			end
		end
		ui.EmptyText.Instance.Visible = not hasResults
	end
	local connection = nil
	function dropdownEx:SetOpen(isOpen)
		if Debounce then
			return
		end
		dropdownEx.IsOpen = isOpen
		Debounce = true
		if dropdownEx.IsOpen then
			ui.OptionHolder.Instance.Visible = true
			ui.OptionHolder.Instance.Parent = Library.Holder.Instance
			ui.ArrowIcon:Tween(nil, { Rotation = 180, ImageColor3 = Color3.fromRGB(255, 255, 255) })
			ui.Gradient.Instance.Enabled = true
			connection = RunService.RenderStepped:Connect(function()
				ui.OptionHolder.Instance.Position = UDim2.new(0,
					ui.RealDropdown.Instance.AbsolutePosition.X - 280 - ui.RealDropdown.Instance.AbsoluteSize.X, 0,
					ui.RealDropdown.Instance.AbsolutePosition.Y + ui.RealDropdown.Instance.AbsoluteSize.Y + 5)
			end)
			for _, openFrame in Library.OpenFrames do
				if openFrame ~= dropdownEx and not dropdownEx.Section.IsSettings then
					openFrame:SetOpen(false)
				end
			end
			Library.OpenFrames[dropdownEx] = dropdownEx
		else
			if Library.OpenFrames[dropdownEx] then
				Library.OpenFrames[dropdownEx] = nil
			end
			if connection then
				connection:Disconnect()
				connection = nil
			end
			ui.ArrowIcon:Tween(nil, { Rotation = 0, ImageColor3 = Color3.fromRGB(141, 141, 150) })
			ui.Gradient.Instance.Enabled = false
			for _, option in dropdownEx.Options do
				if option.IsDescriptionOpen then
					option:ToggleDescription()
				end
			end
		end
		local descendants = ui.OptionHolder.Instance:GetDescendants()
		table.insert(descendants, ui.OptionHolder.Instance)
		local lastTween = nil
		for _, descendant in descendants do
			local property = TweenObject:GetProperty(descendant)
			if property then
				if not descendant.ClassName:find("UI") then
					descendant.ZIndex = dropdownEx.IsOpen and dropdownEx.Section.IsSettings and 9 or dropdownEx.IsOpen and 6 or 1
				end
				if type(property) == "table" then
					for _, propertyName in property do
						lastTween = TweenObject:FadeItem(descendant, propertyName, isOpen, Library.FadeSpeed)
					end
				else
					lastTween = TweenObject:FadeItem(descendant, property, isOpen, Library.FadeSpeed)
				end
			end
		end
		if lastTween then
			lastTween.Tween.Completed:Connect(function()
				Debounce = false
				ui.OptionHolder.Instance.Visible = dropdownEx.IsOpen
				task.wait(0.2)
				ui.OptionHolder.Instance.Parent = not dropdownEx.IsOpen and Library.UnusedHolder.Instance or
				Library.Holder.Instance
			end)
		else
			Debounce = false
		end
	end
	function dropdownEx.UpdateValueText()
		if dropdownEx.Multi then
			local selectedNames = {}
			for _, name in dropdownEx.Value do
				table.insert(selectedNames, name)
			end
			ui.Value.Instance.Text = #selectedNames > 0 and table.concat(selectedNames, ", ") or "..."
		else
			ui.Value.Instance.Text = dropdownEx.Value or "..."
		end
		local hasValue
		if dropdownEx.Multi then
			hasValue = #dropdownEx.Value > 0
		else
			hasValue = dropdownEx.Value ~= nil and dropdownEx.Value ~= ""
		end
		ui.AccentBar:Tween(nil, { BackgroundTransparency = hasValue and 0 or 0.5 })
		ui.AccentBarGradient.Instance.Enabled = hasValue
	end
	function dropdownEx:Set(value)
		if dropdownEx.Multi then
			if type(value) ~= "table" then
				return
			end
			dropdownEx.Value = value
			Library.Flags[dropdownEx.Flag] = value
			for _, option in dropdownEx.Options do
				local selected = table.find(value, option.Name) ~= nil
				option.Selected = selected
				option:Toggle(selected and "Active" or "Inactive")
			end
		else
			if not dropdownEx.Options[value] then
				return
			end
			local option = dropdownEx.Options[value]
			dropdownEx.Value = value
			Library.Flags[dropdownEx.Flag] = value
			for _, otherOption in dropdownEx.Options do
				if otherOption ~= option then
					otherOption.Selected = false
					otherOption:Toggle("Inactive")
				else
					otherOption.Selected = true
					otherOption:Toggle("Active")
				end
			end
		end
		dropdownEx:UpdateValueText()
		if dropdownEx.Callback then
			Library:SafeCall(dropdownEx.Callback, dropdownEx.Value)
		end
	end
	function dropdownEx:Add(item)
		local description = nil
		local icon = nil
		if type(item) == "table" then
			local name = item.Name or item.name
			description = item.Description or item.description
			icon = item.Icon
			if icon then
				item = name
			else
				icon = item.icon
				item = name
			end
		end
		if not item or dropdownEx.Options[item] then
			return
		end
		local hasDescription = description and description ~= ""
		local frame = UIObject:Create("Frame", {
			Parent = ui.Holder.Instance, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), ZIndex = 6, ClipsDescendants = true,
		})
		local button = UIObject:Create("TextButton", {
			Parent = frame.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 44),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 6,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(34, 32, 36),
		})
		button:AddToTheme({ BackgroundColor3 = "Section Top" })
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 4) })
		local selectBox = UIObject:Create("Frame", {
			Parent = button.Instance,
			Size = UDim2.new(0, 32, 0, 32),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 6, 0.5, 0),
			ZIndex = 4,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		})
		selectBox:AddToTheme({ BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = selectBox.Instance, CornerRadius = UDim.new(0, 4) })
		local image = UIObject:Create("ImageLabel", {
			Parent = selectBox.Instance,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(1, -6, 1, -6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://" .. (icon or dropdownEx.DefaultIcon),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = 5,
			ScaleType = Enum.ScaleType.Fit,
		})
		local selectIndicator = UIObject:Create("Frame", {
			Parent = button.Instance,
			Size = UDim2.new(0, 4, 0, 4),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 44, 0.5, 0),
			ZIndex = 4,
			BackgroundTransparency = 1,
		})
		UIObject:Create("UICorner", { Parent = selectIndicator.Instance, CornerRadius = UDim.new(1, 0) })
		UIObject:Create("UIGradient", { Parent = selectIndicator.Instance, Rotation = -115 }):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		local rightPadding = hasDescription and 88 or 60
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.3,
			Text = item,
			Size = UDim2.new(1, -rightPadding, 1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 54, 0, 0),
			ZIndex = 4,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextSize = 14,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		local infoButton = nil
		local descriptionPanel = nil
		local descriptionLabel = nil
		if hasDescription then
			infoButton = UIObject:Create("ImageButton", {
				Parent = button.Instance,
				ImageColor3 = Color3.fromRGB(141, 141, 150),
				Size = UDim2.new(0, 16, 0, 16),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://3926305904",
				ImageRectOffset = Vector2.new(764, 764),
				ImageRectSize = Vector2.new(36, 36),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -10, 0.5, 0),
				ZIndex = 5,
				AutoButtonColor = false,
			})
			descriptionPanel = UIObject:Create("Frame", {
				Parent = frame.Instance,
				BackgroundTransparency = 0,
				Size = UDim2.new(1, -8, 0, 0),
				Position = UDim2.new(0, 4, 0, 46),
				ZIndex = 6,
				ClipsDescendants = true,
				BackgroundColor3 = Color3.fromRGB(22, 21, 24),
			})
			descriptionPanel:AddToTheme({ BackgroundColor3 = "Background" })
			UIObject:Create("UICorner", { Parent = descriptionPanel.Instance, CornerRadius = UDim.new(0, 4) })
			local frame = UIObject:Create("Frame", {
				Parent = descriptionPanel.Instance, Size = UDim2.new(0, 2, 1, -8), Position = UDim2.new(0, 4, 0, 4), ZIndex = 4,
			})
			UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(1, 0) })
			UIObject:Create("UIGradient", { Parent = frame.Instance, Rotation = 90 }):AddToTheme({
				Color = function()
					local accentGradient = Library.Theme.AccentGradient
					return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint
						.new(1, accentGradient) })
				end
			})
			descriptionLabel = UIObject:Create("TextLabel", {
				Parent = descriptionPanel.Instance,
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextTransparency = 0.2,
				Text = description,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 6),
				Size = UDim2.new(1, -20, 1, -12),
				ZIndex = 4,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 12,
			})
			descriptionLabel:AddToTheme({ TextColor3 = "Text" })
			infoButton:OnHover(function()
				infoButton:Tween(nil, { ImageColor3 = Library.Theme.Accent })
			end)
			infoButton:OnHoverLeave(function()
				if not OptionData or not OptionData.IsDescriptionOpen then
					infoButton:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
				end
			end)
		end
		local option
		option = {
			Container = frame,
			Button = button,
			Name = item,
			Description = description,
			HasDescription = hasDescription,
			Icon = image,
			Text = label,
			SelectIndicator = selectIndicator,
			InfoButton = infoButton,
			DescriptionFrame = descriptionPanel,
			DescriptionText = descriptionLabel,
			Selected = false,
			IsDescriptionOpen = false,
			TargetHeight = 44,
			Toggle = function(self, state)
				if state == "Active" then
					label:Tween(nil, { TextTransparency = 0 })
					selectIndicator:Tween(nil, { BackgroundTransparency = 0, Size = UDim2.new(0, 4, 0, 22) })
					image:Tween(nil, { ImageTransparency = 0 })
				else
					label:Tween(nil, { TextTransparency = 0.3 })
					selectIndicator:Tween(nil, { BackgroundTransparency = 1, Size = UDim2.new(0, 4, 0, 4) })
					image:Tween(nil, { ImageTransparency = 0.3 })
				end
			end,
			ToggleDescription = function()
				if not hasDescription then
					return
				end
				option.IsDescriptionOpen = not option.IsDescriptionOpen
				if option.IsDescriptionOpen then
					descriptionLabel.Instance.Size = UDim2.new(0, frame.Instance.AbsoluteSize.X - 28, 0, 9999)
					local textHeight = descriptionLabel.Instance.TextBounds.Y + 12
					descriptionLabel.Instance.Size = UDim2.new(1, -20, 1, -12)
					option.TargetHeight = 44 + textHeight + 6
					frame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, option.TargetHeight) })
					descriptionPanel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, -8, 0, textHeight) })
					infoButton:Tween(nil, { ImageColor3 = Library.Theme.Accent, Rotation = 180 })
				else
					option.TargetHeight = 44
					frame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, 44) })
					descriptionPanel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, -8, 0, 0) })
					infoButton:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150), Rotation = 0 })
				end
			end,
			Set = function()
				option.Selected = not option.Selected
				if dropdownEx.Multi then
					local selectedIndex = table.find(dropdownEx.Value, option.Name)
					if selectedIndex then
						table.remove(dropdownEx.Value, selectedIndex)
					else
						table.insert(dropdownEx.Value, option.Name)
					end
					option:Toggle(selectedIndex and "Inactive" or "Active")
					Library.Flags[dropdownEx.Flag] = dropdownEx.Value
				elseif option.Selected then
					dropdownEx.Value = option.Name
					Library.Flags[dropdownEx.Flag] = option.Name
					option:Toggle("Active")
					for _, otherOption in dropdownEx.Options do
						if otherOption ~= option then
							otherOption.Selected = false
							otherOption:Toggle("Inactive")
						end
					end
				else
					dropdownEx.Value = nil
					Library.Flags[dropdownEx.Flag] = nil
					option:Toggle("Inactive")
				end
				dropdownEx:UpdateValueText()
				if dropdownEx.Callback then
					Library:SafeCall(dropdownEx.Callback, dropdownEx.Value)
				end
			end,
		}
		button:Connect("MouseButton1Down", function()
			if infoButton then
				local mouseLocation = UserInputService:GetMouseLocation()
				local absolutePosition = infoButton.Instance.AbsolutePosition
				local absoluteSize = infoButton.Instance.AbsoluteSize
				if mouseLocation.X >= absolutePosition.X and mouseLocation.X <= absolutePosition.X + absoluteSize.X and mouseLocation.Y >= absolutePosition.Y and mouseLocation.Y <= absolutePosition.Y + absoluteSize.Y then
					return
				end
			end
			option:Set()
		end)
		if infoButton then
			infoButton:Connect("MouseButton1Down", function()
				option:ToggleDescription()
			end)
		end
		button:OnHover(function()
			button:Tween(nil, { BackgroundTransparency = 0 })
		end)
		button:OnHoverLeave(function()
			button:Tween(nil, { BackgroundTransparency = 0.3 })
		end)
		button.Instance.BackgroundTransparency = 0.3
		dropdownEx.Options[item] = option
		table.insert(dropdownEx.OptionsWithIndexes, option)
		return option
	end
	function dropdownEx:Remove(name)
		if dropdownEx.Options[name] then
			dropdownEx.Options[name].Container:Clean()
			dropdownEx.Options[name] = nil
			for index, option in dropdownEx.OptionsWithIndexes do
				if option.Name == name then
					table.remove(dropdownEx.OptionsWithIndexes, index)
					break
				end
			end
		end
	end
	function dropdownEx:Refresh(items)
		for _, option in dropdownEx.Options do
			dropdownEx:Remove(option.Name)
		end
		for _, item in items do
			dropdownEx:Add(item)
		end
	end
	ui.RealDropdown:Connect("MouseButton1Down", function()
		dropdownEx:SetOpen(not dropdownEx.IsOpen)
	end)
	if dropdownEx.Searchable and ui.Search then
		Library:Connect(ui.Search.Instance:GetPropertyChangedSignal("Text"), function()
			dropdownEx.SearchQuery = ui.Search.Instance.Text
			dropdownEx:RefreshSearch()
		end)
	end
	Library:Connect(UserInputService.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dropdownEx.IsOpen then
				if Library:IsMouseOverFrame(ui.OptionHolder) then
					return
				end
				dropdownEx:SetOpen(false)
			end
		end
	end)
	for _, item in dropdownEx.Items do
		dropdownEx:Add(item)
	end
	if dropdownEx.Default then
		dropdownEx:Set(dropdownEx.Default)
	end
	Library.SetFlags[dropdownEx.Flag] = function(value)
		dropdownEx:Set(value)
	end
	dropdownEx.Section.Elements[#dropdownEx.Section.Elements + 1] = dropdownEx
	return dropdownEx
end

function Library.Sections:Priority(properties)
	local options = properties or {}
	local priority = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Priority" }
	priority.Flag = options.Flag or options.flag or Library:NextFlag()
	priority.Items = options.Items or options.items or {}
	priority.Size = options.Size or options.size or 150
	priority.Default = options.Default or options.default or nil
	priority.StartCollapsed = options.StartCollapsed or options.startcollapsed or false
	priority.Searchable = options.Searchable or options.searchable or false
	priority.Callback = options.Callback or options.callback or function() end
	priority.Value = {}
	priority.Options = {}
	priority.Dragging = nil
	priority.DragOffset = 0
	priority.IsCollapsed = false
	priority.SearchQuery = ""
	local searchHeight = priority.Searchable and 32 or 0
	local ui = {
		Priority = UIObject:Create("Frame", {
			Parent = priority.Section.Items.Content.Instance,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, priority.Size + 28 + searchHeight + 4),
			ZIndex = 2,
			ClipsDescendants = true,
		}),
	}
	ui.Header = UIObject:Create("TextButton", {
		Parent = ui.Priority.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	ui.Header:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Header.Instance, CornerRadius = UDim.new(0, 6) })
	ui.ArrowIcon = UIObject:Create("ImageLabel", {
		Parent = ui.Header.Instance,
		ImageColor3 = Color3.fromRGB(141, 141, 150),
		Size = UDim2.new(0, 14, 0, 8),
		AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxassetid://123317177279443",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, 0),
		ZIndex = 3,
		Rotation = 180,
	})
	ui.Title = UIObject:Create("TextLabel", {
		Parent = ui.Header.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = priority.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 32, 0.5, 0),
		ZIndex = 3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 14,
	})
	ui.Title:AddToTheme({ TextColor3 = "Text" })
	ui.Counter = UIObject:Create("TextLabel", {
		Parent = ui.Header.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(141, 141, 150),
		TextTransparency = 0.3,
		Text = "0 items",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		ZIndex = 3,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 13,
	})
	ui.Counter:AddToTheme({ TextColor3 = "Text" })
	if priority.Searchable then
		ui.Search = UIObject:Create("TextBox", {
			Parent = ui.Priority.Instance,
			FontFace = Library.Font,
			CursorPosition = -1,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			Text = "",
			ZIndex = 3,
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 32),
			PlaceholderColor3 = Color3.fromRGB(185, 185, 185),
			TextXAlignment = Enum.TextXAlignment.Left,
			PlaceholderText = "Search..",
			TextSize = 13,
			BackgroundColor3 = Color3.fromRGB(26, 26, 29),
		})
		ui.Search:AddToTheme({ TextColor3 = "Text", BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = ui.Search.Instance, CornerRadius = UDim.new(0, 4) })
		UIObject:Create("UIPadding", { Parent = ui.Search.Instance, PaddingLeft = UDim.new(0, 28) })
		ui.SearchIcon = UIObject:Create("ImageLabel", {
			Parent = ui.Search.Instance,
			ImageColor3 = Color3.fromRGB(141, 141, 150),
			Size = UDim2.new(0, 14, 0, 14),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://3926305904",
			ImageRectOffset = Vector2.new(964, 324),
			ImageRectSize = Vector2.new(36, 36),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, -20, 0.5, 0),
			ZIndex = 4,
		})
	end
	ui.Background = UIObject:Create("Frame", {
		Parent = ui.Priority.Instance,
		Size = UDim2.new(1, 0, 0, priority.Size),
		Position = UDim2.new(0, 0, 0, 28 + searchHeight + 4),
		ZIndex = 2,
		BackgroundColor3 = Color3.fromRGB(26, 26, 29),
	})
	ui.Background:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Background.Instance, CornerRadius = UDim.new(0, 6) })
	ui.Holder = UIObject:Create("ScrollingFrame", {
		Parent = ui.Background.Instance,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.new(0, 4, 0, 4),
		BackgroundTransparency = 1,
		ZIndex = 2,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	ui.Holder:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UIPadding", {
		Parent = ui.Holder.Instance, PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(
	0, 8),
	})
	function priority.UpdateCounter()
		local count = #priority.Value
		ui.Counter.Instance.Text = count .. (count == 1 and " item" or " items")
	end
	function priority:HighlightText(text, query)
		if not query or query == "" then
			return text
		end
		local lowerText = string.lower(text)
		local lowerQuery = string.lower(query)
		local pattern = Library:EscapePattern(lowerQuery)
		local accent = Library.Theme.Accent
		local cursor = 1
		local result = ""
		while true do
			local matchStart, matchEnd = string.find(lowerText, pattern, cursor)
			if not matchStart then
				break
			else
				result = (result .. string.sub(text, cursor, matchStart - 1)) .. Library:ToRich(string.sub(text, matchStart, matchEnd), accent)
				cursor = matchEnd + 1
			end
		end
		return result .. string.sub(text, cursor)
	end
	function priority.RefreshHighlights()
		for _, option in priority.Options do
			if priority.SearchQuery ~= "" then
				option.Text.Instance.RichText = true
				option.Text.Instance.Text = priority:HighlightText(option.Name, priority.SearchQuery)
				local searchQuery = priority.SearchQuery
				if string.find(string.lower(option.Name), Library:EscapePattern(string.lower(searchQuery))) ~= nil then
					option.Button:Tween(nil, { BackgroundTransparency = 0 })
					option.DragHandle:Tween(nil, { ImageColor3 = Library.Theme.Accent })
				else
					option.Button:Tween(nil, { BackgroundTransparency = 0.5 })
					option.DragHandle:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
				end
			else
				option.Text.Instance.RichText = false
				option.Text.Instance.Text = option.Name
				option.Button:Tween(nil, { BackgroundTransparency = 0 })
				option.DragHandle:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
			end
		end
	end
	function priority.ScrollToFirstMatch()
		if priority.SearchQuery == "" then
			return
		end
		local offsetY = 0
		for _, name in priority.Value do
			local option = priority.Options[name]
			if option then
				local searchQuery = priority.SearchQuery
				if string.find(string.lower(name), Library:EscapePattern(string.lower(searchQuery))) then
					ui.Holder:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ CanvasPosition = Vector2.new(0, math.max(0, offsetY - 10)) })
					break
				else
					offsetY = offsetY + option.Container.Instance.Size.Y.Offset + 4
				end
			end
		end
	end
	function priority:UpdatePositions(skipDragged)
		local offsetY = 0
		for index, name in priority.Value do
			local option = priority.Options[name]
			if option then
				local targetHeight = option.TargetHeight or option.Container.Instance.Size.Y.Offset
				if not (skipDragged and priority.Dragging == option) then
					option.Container:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0, 0, 0, offsetY) })
					option.RankLabel.Instance.Text = tostring(index)
				end
				offsetY = offsetY + targetHeight + 4
			end
		end
		priority:UpdateCounter()
	end
	function priority:SetCollapsed(isCollapsed)
		priority.IsCollapsed = isCollapsed
		if isCollapsed then
			ui.Priority:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 0, 28) })
			ui.ArrowIcon:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Rotation = 90 })
			ui.Background:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 0, 0) })
			if ui.Search then
				ui.Search:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{ Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, TextTransparency = 1 })
				if ui.SearchIcon then
					ui.SearchIcon:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ ImageTransparency = 1 })
				end
			end
		else
			ui.Priority:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 0, priority.Size + 28 + searchHeight + 4) })
			ui.ArrowIcon:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Rotation = 180 })
			ui.Background:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 0, priority.Size) })
			if ui.Search then
				ui.Search:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{ Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 0, TextTransparency = 0 })
				if ui.SearchIcon then
					local showGoal = { ImageTransparency = 0 }
					ui.SearchIcon:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), showGoal)
				end
			end
		end
	end
	function priority.Toggle()
		priority:SetCollapsed(not priority.IsCollapsed)
	end
	function priority.Get()
		return priority.Value
	end
	function priority:Set(items)
		local value = priority.Value
		priority.Value = {}
		for _, name in items do
			if priority.Options[name] and not table.find(priority.Value, name) then
				table.insert(priority.Value, name)
			end
		end
		for _, name in value do
			if not table.find(priority.Value, name) then
				table.insert(priority.Value, name)
			end
		end
		Library.Flags[priority.Flag] = priority.Value
		priority:UpdatePositions()
		if priority.Callback then
			Library:SafeCall(priority.Callback, priority.Value)
		end
	end
	function priority:SetVisibility(visible)
		ui.Priority.Instance.Visible = visible
	end
	function priority:RefreshPosition(show)
		if show then
			ui.Header:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) })
			ui.Background:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 28 + searchHeight + 4) })
			if ui.Search then
				ui.Search:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0, 0, 0, 32) })
			end
		else
			ui.Header.Instance.Position = UDim2.new(0, 30, 0, 0)
			ui.Background.Instance.Position = UDim2.new(0, 26, 0, 28 + searchHeight + 4)
			if ui.Search then
				ui.Search.Instance.Position = UDim2.new(0, 30, 0, 32)
			end
		end
	end
	function priority:Add(item, description)
		if type(item) == "table" then
			local name = item.Name or item.name
			description = item.Description or item.description or item.Desc
			if description then
				item = name
			else
				description = item.desc
				item = name
			end
		end
		if priority.Options[item] then
			return
		end
		local hasDescription = description and description ~= ""
		local frame = UIObject:Create("Frame", {
			Parent = ui.Holder.Instance,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 3,
			ClipsDescendants = true,
		})
		local button = UIObject:Create("TextButton", {
			Parent = frame.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 3,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(34, 32, 36),
		})
		button:AddToTheme({ BackgroundColor3 = "Section Top" })
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 4) })
		local image = UIObject:Create("ImageLabel", {
			Parent = button.Instance,
			ImageColor3 = Color3.fromRGB(141, 141, 150),
			Size = UDim2.new(0, 14, 0, 14),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://3994271045",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0.5, 0),
			ZIndex = 4,
		})
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.5,
			Text = "1",
			Size = UDim2.new(0, 24, 1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 26, 0, 0),
			ZIndex = 4,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 13,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		local nameLabel = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0,
			Text = item,
			RichText = false,
			Size = UDim2.new(1, hasDescription and -84 or -60, 1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 54, 0, 0),
			ZIndex = 4,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14,
		})
		nameLabel:AddToTheme({ TextColor3 = "Text" })
		local infoButton = nil
		local descriptionPanel = nil
		local descriptionLabel = nil
		if hasDescription then
			infoButton = UIObject:Create("ImageButton", {
				Parent = button.Instance,
				ImageColor3 = Color3.fromRGB(141, 141, 150),
				Size = UDim2.new(0, 16, 0, 16),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://3926305904",
				ImageRectOffset = Vector2.new(764, 764),
				ImageRectSize = Vector2.new(36, 36),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -10, 0.5, 0),
				ZIndex = 5,
				AutoButtonColor = false,
			})
			descriptionPanel = UIObject:Create("Frame", {
				Parent = frame.Instance,
				BackgroundTransparency = 0,
				Size = UDim2.new(1, -8, 0, 0),
				Position = UDim2.new(0, 4, 0, 30),
				ZIndex = 3,
				ClipsDescendants = true,
				BackgroundColor3 = Color3.fromRGB(22, 21, 24),
			})
			descriptionPanel:AddToTheme({ BackgroundColor3 = "Background" })
			UIObject:Create("UICorner", { Parent = descriptionPanel.Instance, CornerRadius = UDim.new(0, 4) })
			local frame = UIObject:Create("Frame", {
				Parent = descriptionPanel.Instance, Size = UDim2.new(0, 2, 1, -8), Position = UDim2.new(0, 4, 0, 4), ZIndex = 4,
			})
			UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(1, 0) })
			UIObject:Create("UIGradient", {
				Parent = frame.Instance,
				Name = "\0",
				Rotation = 90,
				Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
			}):AddToTheme({
				Color = function()
					local accentGradient = Library.Theme.AccentGradient
					return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint
						.new(1, accentGradient) })
				end
			})
			descriptionLabel = UIObject:Create("TextLabel", {
				Parent = descriptionPanel.Instance,
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextTransparency = 0.2,
				Text = description,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 6),
				Size = UDim2.new(1, -20, 1, -12),
				ZIndex = 4,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 12,
			})
			descriptionLabel:AddToTheme({ TextColor3 = "Text" })
			infoButton:OnHover(function()
				infoButton:Tween(nil, { ImageColor3 = Library.Theme.Accent })
			end)
			infoButton:OnHoverLeave(function()
				infoButton:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
			end)
		end
		local dragging
		dragging = {
			Container = frame,
			Button = button,
			Name = item,
			Description = description,
			HasDescription = hasDescription,
			DragHandle = image,
			RankLabel = label,
			Text = nameLabel,
			InfoButton = infoButton,
			DescriptionFrame = descriptionPanel,
			DescriptionText = descriptionLabel,
			IsDescriptionOpen = false,
			TargetHeight = 28,
			ToggleDescription = function()
				if not hasDescription then
					return
				end
				dragging.IsDescriptionOpen = not dragging.IsDescriptionOpen
				if dragging.IsDescriptionOpen then
					descriptionLabel.Instance.Size = UDim2.new(0, frame.Instance.AbsoluteSize.X - 28, 0, 9999)
					local textHeight = descriptionLabel.Instance.TextBounds.Y + 12
					descriptionLabel.Instance.Size = UDim2.new(1, -24, 1, -12)
					local targetHeight = 28 + textHeight + 6
					dragging.TargetHeight = targetHeight
					frame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, targetHeight) })
					descriptionPanel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, -8, 0, textHeight) })
					infoButton:Tween(nil, { ImageColor3 = Library.Theme.Accent, Rotation = 180 })
				else
					dragging.TargetHeight = 28
					frame:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, 28) })
					descriptionPanel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, -8, 0, 0) })
					infoButton:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150), Rotation = 0 })
				end
				priority:UpdatePositions()
			end,
		}
		if infoButton then
			infoButton:Connect("MouseButton1Down", function()
				dragging:ToggleDescription()
			end)
		end
		local connection = nil
		button:Connect("InputBegan", function(input)
			if priority.IsCollapsed then
				return
			end
			if infoButton then
				local mouseLocation = UserInputService:GetMouseLocation()
				local absolutePosition = infoButton.Instance.AbsolutePosition
				local absoluteSize = infoButton.Instance.AbsoluteSize
				if mouseLocation.X >= absolutePosition.X and mouseLocation.X <= absolutePosition.X + absoluteSize.X and mouseLocation.Y >= absolutePosition.Y and mouseLocation.Y <= absolutePosition.Y + absoluteSize.Y then
					return
				end
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				priority.Dragging = dragging
				local y = frame.Instance.AbsolutePosition.Y
				priority.DragOffset = UserInputService:GetMouseLocation().Y - y
				frame.Instance.ZIndex = 10
				for _, descendant in frame.Instance:GetDescendants() do
					if descendant:IsA("GuiObject") then
						descendant.ZIndex = descendant.ZIndex + 7
					end
				end
				image.Instance.ImageColor3 = Library.Theme.Accent
				button:Tween(nil, { BackgroundTransparency = 0.2 })
				if connection then
					return
				end
				connection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						priority.Dragging = nil
						frame.Instance.ZIndex = 3
						for _, descendant in frame.Instance:GetDescendants() do
							if descendant:IsA("GuiObject") then
								descendant.ZIndex = descendant.ZIndex - 7
							end
						end
						image.Instance.ImageColor3 = Color3.fromRGB(141, 141, 150)
						button:Tween(nil, { BackgroundTransparency = 0 })
						priority:UpdatePositions()
						priority:RefreshHighlights()
						Library.Flags[priority.Flag] = priority.Value
						if priority.Callback then
							Library:SafeCall(priority.Callback, priority.Value)
						end
						connection:Disconnect()
						connection = nil
					end
				end)
			end
		end)
		priority.Options[item] = dragging
		table.insert(priority.Value, item)
		Library.Flags[priority.Flag] = priority.Value
		priority:UpdatePositions()
		return dragging
	end
	function priority:Remove(name)
		if priority.Options[name] then
			priority.Options[name].Container:Clean()
			priority.Options[name] = nil
			local valueIndex = table.find(priority.Value, name)
			if valueIndex then
				table.remove(priority.Value, valueIndex)
			end
			priority:UpdatePositions()
		end
	end
	function priority:Refresh(items)
		for _, option in priority.Options do
			priority:Remove(option.Name)
		end
		for _, item in items do
			priority:Add(item)
		end
	end
	ui.Header:Connect("MouseButton1Down", function()
		priority:Toggle()
	end)
	ui.Header:OnHover(function()
		ui.ArrowIcon:Tween(nil, { ImageColor3 = Library.Theme.Accent })
	end)
	ui.Header:OnHoverLeave(function()
		ui.ArrowIcon:Tween(nil, { ImageColor3 = Color3.fromRGB(141, 141, 150) })
	end)
	if priority.Searchable and ui.Search then
		Library:Connect(ui.Search.Instance:GetPropertyChangedSignal("Text"), function()
			priority.SearchQuery = ui.Search.Instance.Text
			priority:RefreshHighlights()
			priority:ScrollToFirstMatch()
		end)
	end
	Library:Connect(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not priority.Dragging then
			return
		end
		local dragging = priority.Dragging
		local y = ui.Holder.Instance.AbsolutePosition.Y
		local mouseY = UserInputService:GetMouseLocation().Y
		local uiScale = priority.Window and priority.Window.Items and priority.Window.Items.UIScale
		local newY = dragging.Container.Instance.Position.Y.Offset +
		(mouseY - priority.DragOffset - dragging.Container.Instance.AbsolutePosition.Y) /
		(uiScale and uiScale.Instance.Scale or 1)
		dragging.Container.Instance.Position = UDim2.new(0, 0, 0, newY)
		local holderHeight = ui.Holder.Instance.AbsoluteSize.Y
		local relativeY = mouseY - y
		if relativeY < 20 then
			if not b3 then
				return
			end
			ui.Holder.Instance.CanvasPosition = Vector2.new(0, math.max(0, ui.Holder.Instance.CanvasPosition.Y - 8))
		elseif holderHeight - 20 < relativeY then
			ui.Holder.Instance.CanvasPosition = Vector2.new(0,
				math.min(ui.Holder.Instance.AbsoluteCanvasSize.Y - holderHeight, ui.Holder.Instance.CanvasPosition.Y + 8))
		end
		local targetIndex = 1
		local accumulated = 0
		for index, name in priority.Value do
			local option = priority.Options[name]
			if not option then
				continue
			else
				local offset = option.Container.Instance.Size.Y.Offset
				if accumulated < newY + 14 then
					accumulated = accumulated + offset + 4
					targetIndex = index
					continue
				end
			end
			break
		end
		local clampedIndex = math.clamp(targetIndex, 1, #priority.Value)
		local currentIndex = table.find(priority.Value, dragging.Name)
		if currentIndex and currentIndex ~= clampedIndex then
			table.remove(priority.Value, currentIndex)
			table.insert(priority.Value, clampedIndex, dragging.Name)
			priority:UpdatePositions(true)
		end
	end)
	for _, item in priority.Items do
		priority:Add(item)
	end
	if priority.Default then
		priority:Set(priority.Default)
	end
	if priority.StartCollapsed then
		priority:SetCollapsed(true)
	end
	Library.SetFlags[priority.Flag] = function(value)
		priority:Set(value)
	end
	priority.Section.Elements[#priority.Section.Elements + 1] = priority
	return priority
end

function Library.Sections:MapPicker(properties)
	local options = properties or {}
	local colors = options.Colors or options.colors
	local slotColors
	if colors then
		slotColors = colors
	else
		local defaultColors = {}
		local red = Color3.fromRGB(255, 70, 70)
		local green = Color3.fromRGB(90, 225, 100)
		local cyan = Color3.fromRGB(70, 230, 230)
		local blue = Color3.fromRGB(80, 145, 255)
		local yellow = Color3.fromRGB(245, 225, 70)
		local purple = Color3.fromRGB(200, 95, 255)
		local orange = Color3.fromRGB(255, 150, 60)
		defaultColors[1] = red
		defaultColors[2] = green
		defaultColors[3] = cyan
		defaultColors[4] = blue
		defaultColors[5] = yellow
		defaultColors[6] = purple
		defaultColors[7] = orange
		local values = table.pack(Color3.fromRGB(255, 120, 200))
		table.move(values, 1, values.n, 8, defaultColors)
		slotColors = defaultColors
	end
	local function toVector2(value)
		if typeof(value) == "Vector2" then
			return value
		end
		if typeof(value) == "Vector3" then
			return Vector2.new(value.X, value.Z)
		end
		if type(value) == "table" then
			return Vector2.new(tonumber(value.X or value.x or value[1]) or 0, tonumber(value.Z or value.z or value[2]) or 0)
		end
		return Vector2.new(0, 0)
	end
	local function round(number)
		return math.floor(number + 0.5)
	end
	local mapPicker = { Window = self.Window, Page = self.Page, Section = self, Name = options.Name or options.name or "Tower Placement" }
	mapPicker.Flag = options.Flag or options.flag or Library:NextFlag()
	mapPicker.ButtonText = options.ButtonText or options.buttontext or "Set"
	mapPicker.Title = options.Title or options.title or "Hologram"
	mapPicker.SlotCount = options.Slots or options.slots or 6
	mapPicker.MapImage = options.MapImage or options.mapimage or ""
	mapPicker.MapAspect = options.MapAspect or options.mapaspect or 1
	mapPicker.Height = options.Height or options.height or 0
	mapPicker.Live = options.Live or options.live or false
	mapPicker.Callback = options.Callback or options.callback or function() end
	mapPicker.MaxZoom = options.MaxZoom or options.maxzoom or 6
	mapPicker.AreaRadius = options.AreaRadius or options.arearadius or 5
	mapPicker.WorldPreview = options.WorldPreview ~= false
	mapPicker.RaycastGround = options.RaycastGround ~= false
	mapPicker.AreaBeam = options.AreaBeam ~= false
	mapPicker.KeepWorldPreview = options.KeepWorldPreview or options.keepworldpreview or false
	mapPicker.Corners = {}
	mapPicker.Value = {}
	mapPicker.Markers = {}
	mapPicker.Rows = {}
	mapPicker.Selected = 1
	mapPicker.Dragging = nil
	mapPicker.IsOpen = false
	mapPicker.Calibrating = false
	mapPicker.Zoom = 1
	mapPicker.PanU = 0
	mapPicker.PanV = 0
	mapPicker.Panning = nil
	mapPicker.PinchActive = false
	mapPicker.PinchStart = nil
	local cornerNames = { "TopLeft", "TopRight", "BottomLeft", "BottomRight" }
	local corners = options.Corners or options.corners or {
		TopLeft = Vector2.new(-300, 0),
		TopRight = Vector2.new(0, 0),
		BottomLeft = Vector2.new(-300, 300),
		BottomRight = Vector2.new(0, 300),
	}
	for _, cornerName in cornerNames do
		mapPicker.Corners[cornerName] = toVector2(corners[cornerName] or corners[string.lower(cornerName)])
	end
	for i = 1, mapPicker.SlotCount do
		mapPicker.Value[i] = { X = 0, Z = 0, Locked = false }
	end
	local function bilinear(corners, u, v)
		local top = corners.TopLeft + (corners.TopRight - corners.TopLeft) * u
		return top + (corners.BottomLeft + (corners.BottomRight - corners.BottomLeft) * u - top) * v
	end
	function mapPicker:UVToWorld(u, v)
		local point = bilinear(mapPicker.Corners, u, v)
		return point.X, point.Y
	end
	function mapPicker:WorldToUV(x, y)
		local corners = mapPicker.Corners
		local target = Vector2.new(x, y)
		local u = 0.5
		local v = 0.5
		for i = 1, 16 do
			local diff = bilinear(corners, u, v) - target
			if not (diff.Magnitude < 0.0001) then
				local dU = (corners.TopRight - corners.TopLeft) * (1 - v) +
				(corners.BottomRight - corners.BottomLeft) * v
				local dV = (corners.BottomLeft - corners.TopLeft) * (1 - u) +
				(corners.BottomRight - corners.TopRight) * u
				local determinant = dU.X * dV.Y - dV.X * dU.Y
				if not (math.abs(determinant) < 1e-09) then
					u -= (diff.X * dV.Y - dV.X * diff.Y) / determinant
					v -= (dU.X * diff.Y - diff.X * dU.Y) / determinant
					continue
				end
			end
			break
		end
		return math.clamp(u, 0, 1), math.clamp(v, 0, 1)
	end
	function mapPicker:SetCorners(corners)
		if type(corners) ~= "table" then
			return
		end
		for _, cornerName in cornerNames do
			if corners[cornerName] then
				mapPicker.Corners[cornerName] = toVector2(corners[cornerName])
			end
		end
		mapPicker:RefreshFromWorld()
	end
	function mapPicker:CalibrateFromTwoPoints(u1, v1, world1, u2, v2, world2)
		local point1 = toVector2(world1)
		local point2 = toVector2(world2)
		local du = u2 - u1
		local dv = v2 - v1
		if math.abs(du) < 0.02 or math.abs(dv) < 0.02 then
			return false, "จุด A กับ B ใกล้กันเกินไป (ต้องห่างกันทั้งแนวนอนและแนวตั้ง)"
		end
		local scaleX = (point2.X - point1.X) / du
		local scaleY = (point2.Y - point1.Y) / dv
		local originX = point1.X - scaleX * u1
		local originY = point1.Y - scaleY * v1
		mapPicker:SetCorners({
			TopLeft = Vector2.new(originX, originY),
			TopRight = Vector2.new(originX + scaleX, originY),
			BottomLeft = Vector2.new(originX, originY + scaleY),
			BottomRight = Vector2.new(originX + scaleX, originY + scaleY),
		})
		return true
	end
	local ui = {
		Block = UIObject:Create("Frame", {
			Parent = mapPicker.Section.Items.Content.Instance,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 34),
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		}),
	}
	ui.Block:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = ui.Block.Instance, CornerRadius = UDim.new(0, 5) })
	ui.AccentBar = UIObject:Create("Frame", {
		Parent = ui.Block.Instance,
		Size = UDim2.new(0, 2, 1, -12),
		Position = UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 3,
		BackgroundTransparency = 0,
	})
	UIObject:Create("UICorner", { Parent = ui.AccentBar.Instance, CornerRadius = UDim.new(1, 0) })
	UIObject:Create("UIGradient", {
		Parent = ui.AccentBar.Instance,
		Name = "\0",
		Rotation = 90,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.Text = UIObject:Create("TextLabel", {
		Parent = ui.Block.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.3,
		Text = mapPicker.Name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		TextSize = 14,
	})
	ui.Text:AddToTheme({ TextColor3 = "Text" })
	ui.OpenButton = UIObject:Create("TextButton", {
		Parent = ui.Block.Instance,
		FontFace = Library.Font,
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0, 74, 0, 24),
		ZIndex = 3,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(38, 36, 42),
	})
	ui.OpenButton:AddToTheme({ BackgroundColor3 = "Outline" })
	UIObject:Create("UICorner", { Parent = ui.OpenButton.Instance, CornerRadius = UDim.new(0, 4) })
	ui.OpenAccent = UIObject:Create("Frame", {
		Parent = ui.OpenButton.Instance,
		Size = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 3,
	})
	UIObject:Create("UICorner", { Parent = ui.OpenAccent.Instance, CornerRadius = UDim.new(0, 4) })
	UIObject:Create("UIGradient", {
		Parent = ui.OpenAccent.Instance,
		Name = "\0",
		Rotation = -115,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint
			.new(1, Color3.fromRGB(143, 143, 143)) }),
	}):AddToTheme({
		Color = function()
			local accentGradient = Library.Theme.AccentGradient
			return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1,
				accentGradient) })
		end
	})
	ui.OpenText = UIObject:Create("TextLabel", {
		Parent = ui.OpenButton.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.15,
		Text = mapPicker.ButtonText,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 4,
		TextSize = 13,
	})
	ui.OpenText:AddToTheme({ TextColor3 = "Text" })
	ui.OpenButton:OnHover(function()
		ui.OpenAccent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
		ui.OpenText:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0) })
	end)
	ui.OpenButton:OnHoverLeave(function()
		ui.OpenAccent:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
		ui.OpenText:Tween(nil, { TextColor3 = Library.Theme.Text })
	end)
	local mapUi = {
		Overlay = UIObject:Create("TextButton", {
			Parent = Library.UnusedHolder.Instance,
			Text = "",
			AutoButtonColor = false,
			Active = true,
			Visible = false,
			Position = UDim2.new(0, -203, 0, 0),
			Size = UDim2.new(1, 203, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 60,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		}),
	}
	mapUi.Panel = UIObject:Create("Frame", {
		Parent = mapUi.Overlay.Instance,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -20, 1, -24),
		ZIndex = 61,
		BackgroundColor3 = Color3.fromRGB(12, 12, 14),
	})
	mapUi.Panel:AddToTheme({ BackgroundColor3 = "Background" })
	UIObject:Create("UICorner", { Parent = mapUi.Panel.Instance, CornerRadius = UDim.new(0, 8) })
	UIObject:Create("UIStroke", {
		Parent = mapUi.Panel.Instance, Color = Color3.fromRGB(35, 33, 38), Thickness = 1, ApplyStrokeMode = Enum
	.ApplyStrokeMode.Border,
	}):AddToTheme({ Color = "Outline" })
	mapUi.Title = UIObject:Create("TextLabel", {
		Parent = mapUi.Panel.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		Text = mapPicker.Title,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 18),
		Position = UDim2.new(0, 14, 0, 12),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 62,
		TextSize = 17,
	})
	mapUi.Title:AddToTheme({ TextColor3 = "Text" })
	mapUi.SubTitle = UIObject:Create("TextLabel", {
		Parent = mapUi.Panel.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.55,
		Text = "ลากหมุดไปยังจุดที่ต้องการวางยูนิต",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 14),
		Position = UDim2.new(0, 15, 0, 31),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 62,
		TextSize = 13,
	})
	mapUi.SubTitle:AddToTheme({ TextColor3 = "Text" })
	mapUi.Close = UIObject:Create("TextButton", {
		Parent = mapUi.Panel.Instance,
		FontFace = Library.Font,
		Text = "✕",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.25,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.new(0, 26, 0, 26),
		ZIndex = 62,
		TextSize = 16,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	mapUi.Close:AddToTheme({ BackgroundColor3 = "Element", TextColor3 = "Text" })
	UIObject:Create("UICorner", { Parent = mapUi.Close.Instance, CornerRadius = UDim.new(0, 6) })
	mapUi.SlotList = UIObject:Create("ScrollingFrame", {
		Parent = mapUi.Panel.Instance,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		Position = UDim2.new(0, 10, 0, 52),
		Size = UDim2.new(0, 206, 1, -100),
		BackgroundTransparency = 1,
		ZIndex = 62,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	mapUi.SlotList:AddToTheme({ ScrollBarImageColor3 = "Accent" })
	UIObject:Create("UIListLayout", {
		Parent = mapUi.SlotList.Instance, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	UIObject:Create("UIPadding", { Parent = mapUi.SlotList.Instance, PaddingRight = UDim.new(0, 6) })
	mapUi.MapFrame = UIObject:Create("Frame", {
		Parent = mapUi.Panel.Instance,
		Position = UDim2.new(0, 200, 0, 52),
		Size = UDim2.new(1, -234, 1, -100),
		BackgroundTransparency = 0.5,
		ZIndex = 62,
		BackgroundColor3 = Color3.fromRGB(8, 8, 10),
	})
	mapUi.MapFrame:AddToTheme({ BackgroundColor3 = "Background" })
	UIObject:Create("UICorner", { Parent = mapUi.MapFrame.Instance, CornerRadius = UDim.new(0, 6) })
	mapUi.Viewport = UIObject:Create("Frame", {
		Parent = mapUi.MapFrame.Instance,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 62,
	})
	UIObject:Create("UICorner", { Parent = mapUi.Viewport.Instance, CornerRadius = UDim.new(0, 6) })
	mapUi.MapCanvas = UIObject:Create("Frame", {
		Parent = mapUi.Viewport.Instance,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 63,
	})
	mapUi.Aspect = UIObject:Create("UIAspectRatioConstraint", {
		Parent = mapUi.MapCanvas.Instance,
		AspectRatio = mapPicker.MapAspect,
		AspectType = Enum.AspectType.FitWithinMaxSize,
		DominantAxis = Enum.DominantAxis.Width,
	})
	mapUi.MapImage = UIObject:Create("ImageButton", {
		Parent = mapUi.MapCanvas.Instance,
		AutoButtonColor = false,
		Image = mapPicker.MapImage,
		ScaleType = Enum.ScaleType.Stretch,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 0.85,
		ZIndex = 63,
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
	})
	UIObject:Create("UICorner", { Parent = mapUi.MapImage.Instance, CornerRadius = UDim.new(0, 6) })
	mapUi.ZoomBar = UIObject:Create("Frame", {
		Parent = mapUi.MapFrame.Instance,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -10, 1, -10),
		Size = UDim2.new(0, 30, 0, 122),
		BackgroundTransparency = 1,
		ZIndex = 72,
	})
	UIObject:Create("UIListLayout", {
		Parent = mapUi.ZoomBar.Instance,
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	mapUi.ZoomLabel = UIObject:Create("TextLabel", {
		Parent = mapUi.ZoomBar.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.25,
		Text = "100%",
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		TextStrokeTransparency = 0.6,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 73,
		TextSize = 12,
	})
	mapUi.ZoomLabel:AddToTheme({ TextColor3 = "Text" })
	local function createZoomButton(text, order, textSize)
		local button = UIObject:Create("TextButton", {
			Parent = mapUi.ZoomBar.Instance,
			FontFace = Library.Font,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Size = UDim2.new(0, 26, 0, 30),
			BackgroundTransparency = 0.15,
			ZIndex = 73,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		})
		button:AddToTheme({ BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 6) })
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ZIndex = 73,
		})
		UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 6) })
		UIObject:Create("UIGradient", {
			Parent = frame.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.15,
			Text = text,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 74,
			TextSize = textSize or 18,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		button:OnHover(function()
			frame:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
			label:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 0 })
		end)
		button:OnHoverLeave(function()
			frame:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
			label:Tween(nil, { TextColor3 = Library.Theme.Text, TextTransparency = 0.15 })
		end)
		return button
	end
	mapUi.ZoomIn = createZoomButton("+", 1, 24)
	mapUi.ZoomOut = createZoomButton("-", 2, 24)
	mapUi.ZoomReset = createZoomButton("1:1", 3, 12)
	mapUi.Footer = UIObject:Create("Frame", {
		Parent = mapUi.Panel.Instance,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -10),
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundTransparency = 0,
		ZIndex = 62,
		BackgroundColor3 = Color3.fromRGB(27, 26, 29),
	})
	mapUi.Footer:AddToTheme({ BackgroundColor3 = "Element" })
	UIObject:Create("UICorner", { Parent = mapUi.Footer.Instance, CornerRadius = UDim.new(0, 6) })
	mapUi.Readout = UIObject:Create("TextLabel", {
		Parent = mapUi.Footer.Instance,
		FontFace = Library.Font,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = 0.15,
		RichText = true,
		Text = "",
		Size = UDim2.new(1, -400, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 63,
		TextSize = 13,
	})
	mapUi.Readout:AddToTheme({ TextColor3 = "Text" })
	mapUi.Actions = UIObject:Create("Frame", {
		Parent = mapUi.Footer.Instance,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 380, 0, 22),
		BackgroundTransparency = 1,
		ZIndex = 63,
	})
	UIObject:Create("UIListLayout", {
		Parent = mapUi.Actions.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local function fitMapSize(containerSize)
		local width = math.min(containerSize.X, containerSize.Y * mapPicker.MapAspect)
		return Vector2.new(width, width / mapPicker.MapAspect)
	end
	local function getMapRect()
		local instance = mapUi.Viewport.Instance
		local absoluteSize = instance.AbsoluteSize
		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return nil
		end
		local mapSize = fitMapSize(absoluteSize)
		local width = mapSize.X * mapPicker.Zoom
		local height = mapSize.Y * mapPicker.Zoom
		return instance.AbsolutePosition.X + absoluteSize.X * (0.5 + mapPicker.PanU) - width / 2,
			instance.AbsolutePosition.Y + absoluteSize.Y * (0.5 + mapPicker.PanV) - height / 2, width, height
	end
	function mapPicker:ApplyView(animate)
		local absoluteSize = mapUi.Viewport.Instance.AbsoluteSize
		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end
		local mapSize = fitMapSize(absoluteSize)
		local maxPanU = math.max(0, mapSize.X * mapPicker.Zoom / 2 * absoluteSize.X - 0.5)
		local maxPanV = math.max(0, mapSize.Y * mapPicker.Zoom / 2 * absoluteSize.Y - 0.5)
		mapPicker.PanU = math.clamp(mapPicker.PanU, -maxPanU, maxPanU)
		mapPicker.PanV = math.clamp(mapPicker.PanV, -maxPanV, maxPanV)
		local size = UDim2.new(mapPicker.Zoom, 0, mapPicker.Zoom, 0)
		local position = UDim2.new(0.5 + mapPicker.PanU, 0, 0.5 + mapPicker.PanV, 0)
		if animate then
			mapUi.MapCanvas.Instance.Size = size
			mapUi.MapCanvas.Instance.Position = position
		else
			mapUi.MapCanvas:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = size, Position = position })
		end
		mapUi.ZoomLabel.Instance.Text = string.format("%d%%", round(mapPicker.Zoom * 100))
	end
	function mapPicker:ZoomAt(zoom, screenPoint, animate)
		local newZoom = math.clamp(zoom, 1, mapPicker.MaxZoom)
		if math.abs(newZoom - mapPicker.Zoom) < 0.0005 then
			return
		end
		local instance = mapUi.Viewport.Instance
		local absoluteSize = instance.AbsoluteSize
		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end
		local mapX, mapY, mapWidth, mapHeight = getMapRect()
		if not mapX or mapWidth <= 0 or mapHeight <= 0 then
			return
		end
		local relX = (screenPoint.X - mapX) / mapWidth
		local relY = (screenPoint.Y - mapY) / mapHeight
		local zoomRatio = newZoom / mapPicker.Zoom
		local newWidth = mapWidth * zoomRatio
		local newHeight = mapHeight * zoomRatio
		local newCenterX = screenPoint.X - relX * newWidth + newWidth / 2
		local newCenterY = screenPoint.Y - relY * newHeight + newHeight / 2
		mapPicker.Zoom = newZoom
		mapPicker.PanU = (newCenterX - instance.AbsolutePosition.X) / absoluteSize.X - 0.5
		mapPicker.PanV = (newCenterY - instance.AbsolutePosition.Y) / absoluteSize.Y - 0.5
		mapPicker:ApplyView(animate)
	end
	function mapPicker:ZoomBy(factor)
		local instance = mapUi.Viewport.Instance
		local center = Vector2.new(instance.AbsolutePosition.X + instance.AbsoluteSize.X / 2,
			instance.AbsolutePosition.Y + instance.AbsoluteSize.Y / 2)
		mapPicker:ZoomAt(mapPicker.Zoom * factor, center)
	end
	function mapPicker.ResetView()
		mapPicker.Zoom = 1
		mapPicker.PanU = 0
		mapPicker.PanV = 0
		mapPicker:ApplyView()
	end
	local previewFolder = nil
	local worldRings = {}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local function getPreviewFolder()
		if previewFolder then
			return previewFolder
		end
		previewFolder = Instance.new("Folder")
		previewFolder.Name = "\0"
		previewFolder.Parent = currentCamera
		table.insert(Library.WorldObjects, previewFolder)
		return previewFolder
	end
	function mapPicker:GroundY(x, z)
		if not mapPicker.RaycastGround then
			return mapPicker.Height
		end
		local filterDescendantsInstances = {}
		if previewFolder then
			table.insert(filterDescendantsInstances, previewFolder)
		end
		if localPlayer.Character then
			table.insert(filterDescendantsInstances, localPlayer.Character)
		end
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local hit = workspace:Raycast(Vector3.new(x, mapPicker.Height + 25, z), Vector3.new(0, -1500, 0), raycastParams)
		if hit then
			return hit.Position.Y
		end
		return mapPicker.Height
	end
	local function createWorldRing(slot, color)
		local folder = getPreviewFolder()
		local diameter = mapPicker.AreaRadius * 2
		local ringPart = Instance.new("Part")
		ringPart.Name = "\0"
		ringPart.Anchored = true
		ringPart.CanCollide = false
		ringPart.CanQuery = false
		ringPart.CanTouch = false
		ringPart.CastShadow = false
		ringPart.Locked = true
		ringPart.Transparency = 1
		ringPart.Size = Vector3.new(diameter, 0.2, diameter)
		ringPart.Parent = folder
		local surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "\0"
		surfaceGui.Face = Enum.NormalId.Top
		surfaceGui.AlwaysOnTop = true
		surfaceGui.LightInfluence = 0
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 32
		surfaceGui.Adornee = ringPart
		surfaceGui.Parent = ringPart
		local ring = Instance.new("Frame")
		ring.Name = "\0"
		ring.Size = UDim2.new(1, 0, 1, 0)
		ring.BackgroundColor3 = color
		ring.BackgroundTransparency = 0.86
		ring.BorderSizePixel = 0
		ring.Parent = surfaceGui
		local ringCorner = Instance.new("UICorner")
		ringCorner.CornerRadius = UDim.new(1, 0)
		ringCorner.Parent = ring
		local ringStroke = Instance.new("UIStroke")
		ringStroke.Color = color
		ringStroke.Thickness = 6
		ringStroke.Transparency = 0.05
		ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ringStroke.Parent = ring
		local innerRing = Instance.new("Frame")
		innerRing.Name = "\0"
		innerRing.AnchorPoint = Vector2.new(0.5, 0.5)
		innerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerRing.Size = UDim2.new(0.62, 0, 0.62, 0)
		innerRing.BackgroundTransparency = 1
		innerRing.BorderSizePixel = 0
		innerRing.Parent = ring
		local innerCorner = Instance.new("UICorner")
		innerCorner.CornerRadius = UDim.new(1, 0)
		innerCorner.Parent = innerRing
		local innerStroke = Instance.new("UIStroke")
		innerStroke.Color = color
		innerStroke.Thickness = 3
		innerStroke.Transparency = 0.5
		innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		innerStroke.Parent = innerRing
		local ticks = {}
		local tickLayouts = {}
		local topTick = {
			Anchor = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.035, 0, 0.13, 0),
		}
		local bottomTick = {
			Anchor = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(0.035, 0, 0.13, 0),
		}
		local leftTick = {
			Anchor = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0.13, 0, 0.035, 0),
		}
		local rightTick = { Anchor = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.13, 0, 0.035,
			0) }
		tickLayouts[1] = topTick
		tickLayouts[2] = bottomTick
		tickLayouts[3] = leftTick
		tickLayouts[4] = rightTick
		for _, layout in tickLayouts do
			local tickFrame = Instance.new("Frame")
			tickFrame.Name = "\0"
			tickFrame.AnchorPoint = layout.Anchor
			tickFrame.Position = layout.Position
			tickFrame.Size = layout.Size
			tickFrame.BackgroundColor3 = color
			tickFrame.BackgroundTransparency = 0.1
			tickFrame.BorderSizePixel = 0
			tickFrame.Parent = ring
			local tickCorner = Instance.new("UICorner")
			tickCorner.CornerRadius = UDim.new(1, 0)
			tickCorner.Parent = tickFrame
			table.insert(ticks, tickFrame)
		end
		local slotLabel = Instance.new("TextLabel")
		slotLabel.Name = "\0"
		slotLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		slotLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		slotLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
		slotLabel.BackgroundTransparency = 1
		slotLabel.BorderSizePixel = 0
		slotLabel.Text = tostring(slot)
		slotLabel.TextColor3 = color
		slotLabel.TextScaled = true
		slotLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		slotLabel.TextStrokeTransparency = 0.35
		slotLabel.FontFace = Library.Font
		slotLabel.Parent = ring
		local beamPart = nil
		if mapPicker.AreaBeam then
			beamPart = Instance.new("Part")
			beamPart.Name = "\0"
			beamPart.Anchored = true
			beamPart.CanCollide = false
			beamPart.CanQuery = false
			beamPart.CanTouch = false
			beamPart.CastShadow = false
			beamPart.Locked = true
			beamPart.Material = Enum.Material.Neon
			beamPart.Color = color
			beamPart.Transparency = 0.78
			beamPart.Size = Vector3.new(0.6, 100, 0.6)
			beamPart.Parent = folder
			Instance.new("CylinderMesh").Parent = beamPart
		end
		return {
			Part = ringPart,
			Ring = ring,
			RingStroke = ringStroke,
			InnerStroke = innerStroke,
			Ticks = ticks,
			Number = slotLabel,
			Beam = beamPart,
			Color = color,
		}
	end
	function mapPicker:RefreshWorldRing(slot)
		local ring = worldRings[slot]
		local slotValue = mapPicker.Value[slot]
		if not ring or not slotValue then
			return
		end
		local groundY = mapPicker:GroundY(slotValue.X, slotValue.Z)
		ring.Part.CFrame = CFrame.new(slotValue.X, groundY + 0.12, slotValue.Z)
		if ring.Beam then
			ring.Beam.CFrame = CFrame.new(slotValue.X, groundY + ring.Beam.Size.Y / 2, slotValue.Z)
		end
		local locked = slotValue.Locked
		ring.RingStroke.Transparency = locked and 0.55 or 0.05
		ring.InnerStroke.Transparency = locked and 0.8 or 0.5
		ring.Ring.BackgroundTransparency = locked and 0.94 or 0.86
		ring.Number.TextTransparency = locked and 0.5 or 0
		if ring.Beam then
			ring.Beam.Transparency = locked and 0.92 or 0.78
		end
		for _, tickFrame in ring.Ticks do
			tickFrame.BackgroundTransparency = locked and 0.6 or 0.1
		end
	end
	function mapPicker.ShouldShowWorld()
		return mapPicker.WorldPreview and (mapPicker.IsOpen or mapPicker.KeepWorldPreview)
	end
	function mapPicker.ApplyWorldVisibility()
		if mapPicker:ShouldShowWorld() then
			getPreviewFolder().Parent = currentCamera
			for i = 1, mapPicker.SlotCount do
				mapPicker:RefreshWorldRing(i)
			end
		elseif previewFolder then
			previewFolder.Parent = nil
		end
	end
	function mapPicker:SetWorldPreview(enabled)
		mapPicker.WorldPreview = enabled and true or false
		mapPicker:ApplyWorldVisibility()
	end
	function mapPicker:SetAreaRadius(radius)
		mapPicker.AreaRadius = math.max(0.5, radius or 5)
		local diameter = mapPicker.AreaRadius * 2
		for i = 1, mapPicker.SlotCount do
			local ring = worldRings[i]
			if ring then
				ring.Part.Size = Vector3.new(diameter, 0.2, diameter)
				mapPicker:RefreshWorldRing(i)
			end
		end
	end
	Library:Connect(Library.Holder.Instance.Destroying, function()
		if previewFolder then
			previewFolder:Destroy()
			previewFolder = nil
		end
	end)
	local function createToolbarButton(text, width, order)
		local button = UIObject:Create("TextButton", {
			Parent = mapUi.Actions.Instance,
			FontFace = Library.Font,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Size = UDim2.new(0, width, 1, 0),
			ZIndex = 63,
			TextSize = 13,
			BackgroundColor3 = Color3.fromRGB(38, 36, 42),
		})
		button:AddToTheme({ BackgroundColor3 = "Outline" })
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 4) })
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ZIndex = 63,
		})
		UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(0, 4) })
		UIObject:Create("UIGradient", {
			Parent = frame.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(143, 143, 143)) }),
		}):AddToTheme({
			Color = function()
				local accentGradient = Library.Theme.AccentGradient
				return ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(
				1, accentGradient) })
			end
		})
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.2,
			Text = text,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 64,
			TextSize = 13,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		button:OnHover(function()
			frame:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 })
			label:Tween(nil, { TextColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 0 })
		end)
		button:OnHoverLeave(function()
			frame:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
			label:Tween(nil, { TextColor3 = Library.Theme.Text, TextTransparency = 0.2 })
		end)
		return button, label
	end
	local function createMarker(slot, color)
		local button = UIObject:Create("TextButton", {
			Parent = mapUi.MapCanvas.Instance,
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 38, 0, 38),
			BackgroundTransparency = 1,
			ZIndex = 66,
		})
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 12, 1, 12),
			BackgroundTransparency = 0.9,
			ZIndex = 64,
			BackgroundColor3 = color,
		})
		UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(1, 0) })
		local ping = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -16, 1, -16),
			BackgroundTransparency = 1,
			ZIndex = 65,
		})
		UIObject:Create("UICorner", { Parent = ping.Instance, CornerRadius = UDim.new(1, 0) })
		local stroke = UIObject:Create("UIStroke", {
			Parent = ping.Instance, Color = color, Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum
		.ApplyStrokeMode.Border,
		})
		local ticks = {}
		local tickLayouts = {}
		local topTick = {
			Anchor = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0, 2, 0, 5),
		}
		local bottomTick = { Anchor = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(0, 2, 0, 5) }
		local leftTick = { Anchor = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 5, 0, 2) }
		local rightTick = {
			Anchor = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 5, 0, 2),
		}
		tickLayouts[1] = topTick
		tickLayouts[2] = bottomTick
		tickLayouts[3] = leftTick
		tickLayouts[4] = rightTick
		for _, layout in tickLayouts do
			local frame = UIObject:Create("Frame", {
				Parent = button.Instance,
				AnchorPoint = layout.Anchor,
				Position = layout.Position,
				Size = layout.Size,
				BackgroundTransparency = 0.15,
				ZIndex = 67,
				BackgroundColor3 = color,
			})
			UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(1, 0) })
			table.insert(ticks, frame)
		end
		local tickFrame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -16, 1, -16),
			BackgroundTransparency = 0.2,
			ZIndex = 67,
			BackgroundColor3 = Color3.fromRGB(12, 12, 14),
		})
		tickFrame:AddToTheme({ BackgroundColor3 = "Background" })
		UIObject:Create("UICorner", { Parent = tickFrame.Instance, CornerRadius = UDim.new(1, 0) })
		local markerStroke = UIObject:Create("UIStroke", {
			Parent = tickFrame.Instance, Color = color, Thickness = 2, Transparency = 0, ApplyStrokeMode = Enum
		.ApplyStrokeMode.Border,
		})
		UIObject:Create("UIGradient", {
			Parent = tickFrame.Instance,
			Rotation = -115,
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)) }),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) }),
		})
		return {
			Marker = button,
			Halo = frame,
			Ping = ping,
			PingStroke = stroke,
			Ticks = ticks,
			Ring = tickFrame,
			Stroke = markerStroke,
			Number = UIObject:Create("TextLabel", {
				Parent = tickFrame.Instance,
				FontFace = Library.Font,
				TextColor3 = color,
				Text = tostring(slot),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextStrokeTransparency = 0.55,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				ZIndex = 68,
				TextSize = 14,
			}),
			Color = color,
		}
	end
	local function createRow(slot, color)
		local button = UIObject:Create("TextButton", {
			Parent = mapUi.SlotList.Instance,
			FontFace = Library.Font,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = slot,
			Size = UDim2.new(1, 0, 0, 58),
			ZIndex = 63,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(27, 26, 29),
		})
		button:AddToTheme({ BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = button.Instance, CornerRadius = UDim.new(0, 6) })
		local frame = UIObject:Create("Frame", {
			Parent = button.Instance,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 4, 0.5, 0),
			Size = UDim2.new(0, 2, 1, -16),
			BackgroundTransparency = 1,
			ZIndex = 64,
			BackgroundColor3 = color,
		})
		UIObject:Create("UICorner", { Parent = frame.Instance, CornerRadius = UDim.new(1, 0) })
		local slotBadge = UIObject:Create("Frame", {
			Parent = button.Instance,
			Position = UDim2.new(0, 12, 0, 8),
			Size = UDim2.new(0, 28, 0, 28),
			ZIndex = 64,
			BackgroundColor3 = Color3.fromRGB(38, 36, 42),
		})
		slotBadge:AddToTheme({ BackgroundColor3 = "Outline" })
		UIObject:Create("UICorner", { Parent = slotBadge.Instance, CornerRadius = UDim.new(0, 6) })
		UIObject:Create("TextLabel", {
			Parent = slotBadge.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			Text = tostring(slot),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 65,
			TextSize = 15,
		}):AddToTheme({ TextColor3 = "Text" })
		local label = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 0.1,
			Text = "Slot " .. slot,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 16),
			Position = UDim2.new(0, 48, 0, 10),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 64,
			TextSize = 15,
		})
		label:AddToTheme({ TextColor3 = "Text" })
		local coordsLabel = UIObject:Create("TextLabel", {
			Parent = button.Instance,
			FontFace = Library.Font,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			RichText = true,
			Text = "",
			Size = UDim2.new(1, -60, 0, 15),
			Position = UDim2.new(0, 48, 0, 32),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 64,
			TextSize = 14,
		})
		local lockButton = UIObject:Create("TextButton", {
			Parent = button.Instance,
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, -1),
			Size = UDim2.new(0, 28, 0, 28),
			BackgroundTransparency = 1,
			ZIndex = 65,
			BackgroundColor3 = Color3.fromRGB(38, 36, 42),
		})
		lockButton:AddToTheme({ BackgroundColor3 = "Outline" })
		UIObject:Create("UICorner", { Parent = lockButton.Instance, CornerRadius = UDim.new(0, 7) })
		local shackleClip = UIObject:Create("Frame", {
			Parent = lockButton.Instance,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -14),
			Size = UDim2.new(0, 17, 0, 10.5),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 66,
		})
		local shackle = UIObject:Create("Frame", {
			Parent = shackleClip.Instance,
			Position = UDim2.new(0, 2, 0, 2),
			Size = UDim2.new(0, 13, 0, 13),
			BackgroundTransparency = 1,
			ZIndex = 66,
		})
		UIObject:Create("UICorner", { Parent = shackle.Instance, CornerRadius = UDim.new(1, 0) })
		local stroke = UIObject:Create("UIStroke", {
			Parent = shackle.Instance, Thickness = 2, Color = color, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
		local lockBody = UIObject:Create("Frame", {
			Parent = lockButton.Instance,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -4),
			Size = UDim2.new(0, 15, 0, 11),
			ZIndex = 67,
			BackgroundColor3 = color,
		})
		UIObject:Create("UICorner", { Parent = lockBody.Instance, CornerRadius = UDim.new(0, 3) })
		local lockHole = UIObject:Create("Frame", {
			Parent = lockBody.Instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 5),
			ZIndex = 68,
			BackgroundColor3 = Color3.fromRGB(26, 26, 29),
		})
		lockHole:AddToTheme({ BackgroundColor3 = "Element" })
		UIObject:Create("UICorner", { Parent = lockHole.Instance, CornerRadius = UDim.new(1, 0) })
		lockButton:OnHover(function()
			lockButton:Tween(nil, { BackgroundTransparency = 0.3 })
		end)
		lockButton:OnHoverLeave(function()
			lockButton:Tween(nil, { BackgroundTransparency = 1 })
		end)
		return {
			Row = button,
			SelectBar = frame,
			Badge = slotBadge,
			Title = label,
			Coords = coordsLabel,
			LockButton = lockButton,
			LockBody = lockBody,
			LockHole = lockHole,
			ShackleClip = shackleClip,
			ShackleStroke = stroke,
			Color = color,
		}
	end
	local xColor = Color3.fromRGB(100, 165, 255)
	local zColor = Color3.fromRGB(255, 95, 95)
	function mapPicker:RefreshRow(slot)
		local row = mapPicker.Rows[slot]
		local slotValue = mapPicker.Value[slot]
		if not row or not slotValue then
			return
		end
		row.Coords.Instance.Text = string.format("%s %s, %s %s", Library:ToRich("X", xColor),
			Library:ToRich(tostring(round(slotValue.X)), xColor), Library:ToRich("Z", zColor), Library:ToRich(tostring(round(slotValue.Z)), zColor))
		local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		if slotValue.Locked then
			row.ShackleClip:Tween(tweenInfo, { Position = UDim2.new(0.5, 0, 1, -14) })
			row.LockBody:Tween(nil, { BackgroundTransparency = 0 })
			row.LockHole:Tween(nil, { BackgroundTransparency = 0 })
			row.ShackleStroke:Tween(nil, { Transparency = 0 })
		else
			row.ShackleClip:Tween(tweenInfo, { Position = UDim2.new(0.5, 5, 1, -14) })
			row.LockBody:Tween(nil, { BackgroundTransparency = 0.5 })
			row.LockHole:Tween(nil, { BackgroundTransparency = 0.5 })
			row.ShackleStroke:Tween(nil, { Transparency = 0.5 })
		end
		if mapPicker.ShouldShowWorld and mapPicker:ShouldShowWorld() then
			mapPicker:RefreshWorldRing(slot)
		end
		local marker = mapPicker.Markers[slot]
		if marker then
			for _, tickFrame in marker.Ticks do
				tickFrame:Tween(nil, { BackgroundTransparency = slotValue.Locked and 0.7 or 0.15 })
			end
			marker.Stroke:Tween(nil, { Transparency = slotValue.Locked and 0.5 or 0 })
			marker.Ring:Tween(nil, { BackgroundTransparency = slotValue.Locked and 0.55 or 0.2 })
			marker.Number:Tween(nil, { TextTransparency = slotValue.Locked and 0.5 or 0 })
		end
	end
	function mapPicker.RefreshReadout()
		local slotValue = mapPicker.Value[mapPicker.Selected]
		if not slotValue then
			return
		end
		mapUi.Readout.Instance.Text = string.format("%s  •  %s %s   %s %s%s",
			Library:ToRich("Slot " .. mapPicker.Selected, slotColors[(mapPicker.Selected - 1) % #slotColors + 1]), Library:ToRich("X", xColor),
			tostring(round(slotValue.X)), Library:ToRich("Z", zColor), tostring(round(slotValue.Z)), slotValue.Locked and "   (locked)" or "")
	end
	function mapPicker:PingMarker(slot)
		local marker = mapPicker.Markers[slot]
		if not marker then
			if not b2 then
				return
			end
			return
		end
		marker.Ping.Instance.Size = UDim2.new(1, -16, 1, -16)
		marker.PingStroke.Instance.Transparency = 0.1
		marker.Ping:Tween(TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 24, 1, 24) })
		marker.PingStroke:Tween(TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Transparency = 1 })
	end
	function mapPicker:Select(selected)
		if not mapPicker.Value[selected] then
			return
		end
		mapPicker.Selected = selected
		for slot, row in mapPicker.Rows do
			local isSelected = slot == selected
			row.SelectBar:Tween(nil, { BackgroundTransparency = isSelected and 0 or 1 })
			row.Row:Tween(nil, { BackgroundTransparency = isSelected and 0 or 0.35 })
			local marker = mapPicker.Markers[slot]
			if marker then
				local size = isSelected and 44 or 38
				marker.Halo:Tween(nil, { BackgroundTransparency = isSelected and 0.72 or 0.9 })
				marker.Stroke:Tween(nil, { Thickness = isSelected and 2.6 or 2 })
				marker.Marker:Tween(TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, size, 0, size) })
				marker.Marker.Instance.ZIndex = isSelected and 70 or 66
				if isSelected then
					mapPicker:PingMarker(slot)
				end
			end
		end
		mapPicker:RefreshReadout()
	end
	function mapPicker.PushFlag()
		Library.Flags[mapPicker.Flag] = mapPicker.Value
	end
	function mapPicker:Fire(slot)
		mapPicker:PushFlag()
		if mapPicker.Callback then
			Library:SafeCall(mapPicker.Callback, mapPicker.Value, slot)
		end
	end
	function mapPicker:SetSlotUV(slot, u, v, silent)
		local slotValue = mapPicker.Value[slot]
		if not slotValue then
			return
		end
		local clampedU = math.clamp(u, 0, 1)
		local clampedV = math.clamp(v, 0, 1)
		local worldX, worldZ = mapPicker:UVToWorld(clampedU, clampedV)
		slotValue.X = round(worldX)
		slotValue.Z = round(worldZ)
		local marker = mapPicker.Markers[slot]
		if marker then
			marker.Marker.Instance.Position = UDim2.new(clampedU, 0, clampedV, 0)
		end
		mapPicker:RefreshRow(slot)
		if slot == mapPicker.Selected then
			mapPicker:RefreshReadout()
		end
		mapPicker:PushFlag()
		if not silent then
			mapPicker:Fire(slot)
		end
	end
	function mapPicker:SetSlotWorld(slot, x, z, silent)
		local slotValue = mapPicker.Value[slot]
		if not slotValue then
			return
		end
		slotValue.X = round(x)
		slotValue.Z = round(z)
		local u, v = mapPicker:WorldToUV(slotValue.X, slotValue.Z)
		local marker = mapPicker.Markers[slot]
		if marker then
			marker.Marker.Instance.Position = UDim2.new(u, 0, v, 0)
		end
		mapPicker:RefreshRow(slot)
		if slot == mapPicker.Selected then
			mapPicker:RefreshReadout()
		end
		mapPicker:PushFlag()
		if not silent then
			mapPicker:Fire(slot)
		end
	end
	function mapPicker:PlaceFromScreen(slot, screenPosition)
		local instance = mapUi.MapCanvas.Instance
		local absoluteSize = instance.AbsoluteSize
		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end
		mapPicker:SetSlotUV(slot, (screenPosition.X - instance.AbsolutePosition.X) / absoluteSize.X,
			(screenPosition.Y - instance.AbsolutePosition.Y) / absoluteSize.Y, true)
	end
	function mapPicker.RefreshFromWorld()
		for slot, slotValue in mapPicker.Value do
			local u, v = mapPicker:WorldToUV(slotValue.X, slotValue.Z)
			local marker = mapPicker.Markers[slot]
			if marker then
				marker.Marker.Instance.Position = UDim2.new(u, 0, v, 0)
			end
			mapPicker:RefreshRow(slot)
		end
		mapPicker:RefreshReadout()
	end
	function mapPicker.Get()
		return mapPicker.Value
	end
	function mapPicker:GetSlot(slot)
		local slotValue = mapPicker.Value[slot]
		if not slotValue then
			return nil
		end
		return Vector3.new(slotValue.X, mapPicker.Height, slotValue.Z)
	end
	function mapPicker.GetAll()
		local positions = {}
		for i = 1, mapPicker.SlotCount do
			positions[i] = mapPicker:GetSlot(i)
		end
		return positions
	end
	function mapPicker:Set(data)
		if type(data) ~= "table" then
			return
		end
		for i = 1, mapPicker.SlotCount do
			local entry = data[i] or data[tostring(i)]
			if type(entry) == "table" then
				local x = tonumber(entry.X or entry.x)
				local z = tonumber(entry.Z or entry.z)
				if x and z then
					mapPicker.Value[i].Locked = entry.Locked and true or false
					mapPicker:SetSlotWorld(i, x, z, true)
				end
			end
		end
		mapPicker:RefreshReadout()
		mapPicker:Fire(nil)
	end
	function mapPicker:SetLocked(slot, locked)
		local slotValue = mapPicker.Value[slot]
		if not slotValue then
			return
		end
		slotValue.Locked = locked and true or false
		mapPicker:RefreshRow(slot)
		mapPicker:RefreshReadout()
		mapPicker:PushFlag()
	end
	function mapPicker:SetMap(mapImage, corners, mapAspect)
		if mapImage then
			mapPicker.MapImage = mapImage
			mapUi.MapImage.Instance.Image = mapImage
		end
		if mapAspect then
			mapPicker.MapAspect = mapAspect
			mapUi.Aspect.Instance.AspectRatio = mapAspect
		end
		if corners then
			mapPicker:SetCorners(corners)
		end
		mapPicker:ResetView()
	end
	function mapPicker:SetVisibility(visible)
		ui.Block.Instance.Visible = visible
	end
	function mapPicker:RefreshPosition(show)
		if show then
			ui.Text:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 14, 0.5, 0) })
			ui.OpenButton:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -6, 0.5, 0) })
			ui.AccentBar:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 4, 0.5, 0) })
		else
			ui.Text.Instance.Position = UDim2.new(0, 74, 0.5, 0)
			ui.OpenButton.Instance.Position = UDim2.new(1, 54, 0.5, 0)
			ui.AccentBar.Instance.Position = UDim2.new(0, -20, 0.5, 0)
		end
	end
	function mapPicker.Open()
		if mapPicker.IsOpen then
			return
		end
		mapPicker.IsOpen = true
		mapUi.Overlay.Instance.Parent = mapPicker.Window.Items.MainFrame.Instance
		mapUi.Overlay.Instance.Visible = true
		mapUi.Overlay.Instance.BackgroundTransparency = 1
		mapUi.Overlay:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.25 })
		mapUi.Panel.Instance.Position = UDim2.new(0.5, 0, 0.5, 18)
		mapUi.Panel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0.5, 0) })
		mapPicker:ApplyView(true)
		mapPicker:RefreshFromWorld()
		mapPicker:Select(mapPicker.Selected)
		mapPicker:ApplyWorldVisibility()
	end
	function mapPicker.Close()
		if not mapPicker.IsOpen then
			return
		end
		mapPicker.IsOpen = false
		mapPicker.Dragging = nil
		mapPicker.Panning = nil
		mapPicker.PinchActive = false
		mapUi.Overlay:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 })
		mapUi.Panel:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0.5, 18) })
		task.delay(0.22, function()
			if not mapPicker.IsOpen then
				mapUi.Overlay.Instance.Visible = false
				mapUi.Overlay.Instance.Parent = Library.UnusedHolder.Instance
			end
		end)
		mapPicker:Fire(nil)
		mapPicker:ApplyWorldVisibility()
	end
	function mapPicker.Toggle()
		if mapPicker.IsOpen then
			mapPicker:Close()
		else
			mapPicker:Open()
		end
	end
	for i = 1, mapPicker.SlotCount do
		local color = slotColors[(i - 1) % #slotColors + 1]
		mapPicker.Markers[i] = createMarker(i, color)
		mapPicker.Rows[i] = createRow(i, color)
		worldRings[i] = createWorldRing(i, color)
		local marker = mapPicker.Markers[i]
		local row = mapPicker.Rows[i]
		local angle = i / mapPicker.SlotCount * math.pi * 2
		mapPicker:SetSlotUV(i, 0.5 + math.cos(angle) * 0.06, 0.5 + math.sin(angle) * 0.06, true)
		local connection = nil
		marker.Marker:Connect("InputBegan", function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			mapPicker:Select(i)
			if mapPicker.Value[i].Locked then
				return
			end
			mapPicker.Dragging = i
			marker.Halo:Tween(nil, { BackgroundTransparency = 0.58 })
			if connection then
				return
			end
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					mapPicker.Dragging = nil
					marker.Halo:Tween(nil, { BackgroundTransparency = 0.72 })
					mapPicker:Fire(i)
					connection:Disconnect()
					connection = nil
				end
			end)
		end)
		row.Row:Connect("InputBegan", function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if Library:IsMouseOverFrame(row.LockButton) then
					return
				end
				mapPicker:Select(i)
			end
		end)
		row.LockButton:Connect("InputBegan", function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mapPicker:SetLocked(i, not mapPicker.Value[i].Locked)
			end
		end)
		row.Row:OnHover(function()
			if mapPicker.Selected ~= i then
				row.Row:Tween(nil, { BackgroundTransparency = 0.12 })
			end
		end)
		row.Row:OnHoverLeave(function()
			if mapPicker.Selected ~= i then
				row.Row:Tween(nil, { BackgroundTransparency = 0.35 })
			end
		end)
	end
	local areaButton, areaLabel = createToolbarButton("Area", 66, 0)
	local doneButton = createToolbarButton("Done", 56, 4)
	local function refreshAreaButton()
		areaLabel.Instance.Text = mapPicker.WorldPreview and "Area on" or "Area off"
		areaLabel:Tween(nil, { TextTransparency = mapPicker.WorldPreview and 0 or 0.5 })
	end
	areaButton:Connect("MouseButton1Down", function()
		mapPicker:SetWorldPreview(not mapPicker.WorldPreview)
		refreshAreaButton()
	end)
	refreshAreaButton()
	doneButton:Connect("MouseButton1Down", function()
		mapPicker:Close()
	end)
	ui.OpenButton:Connect("MouseButton1Down", function()
		mapPicker:Toggle()
	end)
	mapUi.Close:Connect("MouseButton1Down", function()
		mapPicker:Close()
	end)
	mapUi.MapImage:Connect("InputBegan", function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if mapPicker.PinchActive then
			return
		end
		local panning = {
			StartX = input.Position.X, StartY = input.Position.Y, StartPanU = mapPicker.PanU, StartPanV = mapPicker.PanV, Moved = false,
		}
		mapPicker.Panning = panning
		local connection = nil
		connection = input.Changed:Connect(function()
			if input.UserInputState ~= Enum.UserInputState.End then
				return
			end
			if not panning.Moved then
				local slotValue = mapPicker.Value[mapPicker.Selected]
				if slotValue and not slotValue.Locked then
					mapPicker:PlaceFromScreen(mapPicker.Selected, input.Position)
					mapPicker:Fire(mapPicker.Selected)
				end
			end
			if mapPicker.Panning == panning then
				mapPicker.Panning = nil
			end
			connection:Disconnect()
			connection = nil
		end)
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if not mapPicker.IsOpen then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		if not Library:IsMouseOverFrame(mapUi.Viewport) then
			return
		end
		local z = input.Position.Z
		if z == 0 then
			return
		end
		mapPicker:ZoomAt(mapPicker.Zoom * (z > 0 and 1.2 or 0.83333333333333337), Vector2.new(mouse.X, mouse.Y))
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		local panning = mapPicker.Panning
		if not panning or mapPicker.PinchActive then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local absoluteSize = mapUi.Viewport.Instance.AbsoluteSize
		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end
		local deltaX = input.Position.X - panning.StartX
		local deltaY = input.Position.Y - panning.StartY
		local wasStill = not panning.Moved
		local moved
		if wasStill then
			moved = math.abs(deltaX) > 5 or math.abs(deltaY) > 5
		else
			moved = wasStill
		end
		if moved then
			panning.Moved = true
		end
		if not panning.Moved then
			return
		end
		mapPicker.PanU = panning.StartPanU + deltaX / absoluteSize.X
		mapPicker.PanV = panning.StartPanV + deltaY / absoluteSize.Y
		mapPicker:ApplyView(true)
	end)
	Library:Connect(UserInputService.TouchPinch, function(touchPositions, scale, velocity, state)
		if not mapPicker.IsOpen then
			return
		end
		if state == Enum.UserInputState.Begin then
			mapPicker.PinchActive = true
			mapPicker.PinchStart = mapPicker.Zoom
			mapPicker.Panning = nil
			return
		end
		if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
			mapPicker.PinchActive = false
			mapPicker.PinchStart = nil
			return
		end
		if not mapPicker.PinchStart then
			return
		end
		local center = touchPositions[1]
		if touchPositions[2] then
			center = (touchPositions[1] + touchPositions[2]) / 2
		end
		if center then
			mapPicker:ZoomAt(mapPicker.PinchStart * scale, center, true)
			return
		end
	end)
	mapUi.ZoomIn:Connect("MouseButton1Down", function()
		mapPicker:ZoomBy(1.44)
	end)
	mapUi.ZoomOut:Connect("MouseButton1Down", function()
		mapPicker:ZoomBy(0.69444444444444442)
	end)
	mapUi.ZoomReset:Connect("MouseButton1Down", function()
		mapPicker:ResetView()
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if not mapPicker.Dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		mapPicker:PlaceFromScreen(mapPicker.Dragging, input.Position)
	end)
	Library:Connect(UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if mapPicker.IsOpen and input.KeyCode == Enum.KeyCode.Escape then
			mapPicker:Close()
		end
	end)
	if options.Default or options.default then
		mapPicker:Set(options.Default or options.default)
	end
	mapPicker:Select(1)
	mapPicker:PushFlag()
	mapPicker:ApplyWorldVisibility()
	Library.SetFlags[mapPicker.Flag] = function(value)
		mapPicker:Set(value)
	end
	mapPicker.Section.Elements[#mapPicker.Section.Elements + 1] = mapPicker
	return mapPicker
end

function Library:GetFlag(flag)
	return self.Flags[flag]
end

function Library:CreateSettingsPage(window)
	local page = window:Page({ Name = "Settings", Icon = "122669828593160" })
	local section = page:Section({
		Name = "Configs", Side = 1, Icon = "10723433935", Description = "Configuration management system.",
	})
	local newConfigName = nil
	local selectedConfig = nil
	local configList = section:Listbox({
		Flag = "ConfigsList",
		Items = {},
		Multi = false,
		Callback = function(selected)
			selectedConfig = selected
		end,
	})
	section:Textbox({
		Flag = "ConfigsName",
		Placeholder = "Input Name.",
		Numeric = false,
		Finished = true,
		Callback = function(text)
			newConfigName = text
		end,
	})
	section:Button({
		Name = "Create",
		Callback = function()
			if newConfigName and newConfigName ~= "" then
				if not isfile(Library.Folders.Configs .. "/" .. newConfigName .. ".json") then
					writefile(Library.Folders.Configs .. "/" .. newConfigName .. ".json", Library:GetConfig())
					Library:RefreshConfigsList(configList)
				end
			end
		end,
	})
	section:Button({
		Name = "Delete",
		Callback = function()
			if selectedConfig then
				Library:DeleteConfig(selectedConfig)
				Library:RefreshConfigsList(configList)
			end
		end,
	})
	section:Button({
		Name = "Load",
		Callback = function()
			if selectedConfig then
				Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. selectedConfig), selectedConfig)
			end
		end,
	})
	section:Button({
		Name = "Save",
		Callback = function()
			if selectedConfig then
				writefile(Library.Folders.Configs .. "/" .. selectedConfig, Library:GetConfig(selectedConfig))
			end
		end,
	})
	section:Button({
		Name = "Refresh",
		Callback = function()
			Library:RefreshConfigsList(configList)
		end,
	})
	Library:RefreshConfigsList(configList)
	return page
end

if not isfile(Library.Folders.Configs .. "/" .. configFileName) then
	writefile(Library.Folders.Configs .. "/" .. configFileName, Library:GetConfig())
end

if sharedEnv then
	sharedEnv[SHARED_KEY] = Library
end

return Library
