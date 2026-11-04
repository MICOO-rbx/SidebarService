--!strict

export type Button = {
	Category: Frame,
	ButtonLabel: string?,
	ButtonIcon: number,
	ButtonName: string,
	Page: GuiObject,
}

type ButtonInstance = ImageButton & {
	icon: ImageLabel,
	label: TextLabel,
	util: Folder & {
		screen_directory: ObjectValue,
	},
}

type CategoryMap = { [string]: Frame, }
type ButtonMap = { [string]: ImageButton, }
type ExeMain = { GoToScreen: (page: GuiObject) -> any, }
	
const run_service = game:GetService("RunService")
const replicated = game:GetService("ReplicatedStorage")
const players = game:GetService("Players")

assert(run_service:IsClient(), `{script.Name} available only for Client! =P`)

const function require_path(root: Instance, ...: string): Instance
	local current = root

	for _, name in { ... } do
		local child = current:WaitForChild(name, 15)
		assert(child, `{script.Name}: "{name}" not found in {current:GetFullName()}`)
		current = child
	end

	return current
end

const exe6 = require_path(players.LocalPlayer, "PlayerGui", "EXE6")
const content = require_path(exe6, "main_frame", "content")
const directory = require_path(content, "navigation", "directory")
const screen = require_path(content, "screen")

const main_module = require_path(replicated, "EXE6_STORAGE", "modules", "MainModule")
assert(main_module:IsA("ModuleScript"), `{script.Name}: MainModule is not a ModuleScript`)
const exe_main = require(main_module) :: ExeMain

const function create_badge(badge_size: number): CanvasGroup
	local container = Instance.new("CanvasGroup")
	container.Name = "badge_container"
	container.AnchorPoint = Vector2.new(1, 0.5)
	container.Position = UDim2.new(1, 0, 0.5, 0)
	container.Size = UDim2.fromOffset(20, 20)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.GroupTransparency = 1
	container.ZIndex = 20

	local badge = Instance.new("ImageLabel")
	badge.Name = "badge"
	badge.AnchorPoint = Vector2.new(0.5, 0.5)
	badge.Position = UDim2.fromScale(0.5, 0.5)
	badge.Size = UDim2.fromOffset(badge_size, badge_size)
	badge.BackgroundTransparency = 1
	badge.BorderSizePixel = 0
	badge.ScaleType = Enum.ScaleType.Fit
	badge.Image = "rbxassetid://92562308197003"
	badge.ImageColor3 = Color3.fromRGB(0, 141, 255)
	badge.ZIndex = 20
	badge.Parent = container
	badge:AddTag('Exe6PrimaryThemeImageColor3')

	return container
end

const function build_category_template(): Frame
	local category = Instance.new("Frame")
	category.Name = "Category"
	category.Size = UDim2.new(1, 0, 0, 0)
	category.AutomaticSize = Enum.AutomaticSize.Y
	category.BackgroundTransparency = 1
	category.BorderSizePixel = 0

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Padding = UDim.new(0, 5)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = category

	local util = Instance.new("Folder")
	util.Name = "util"
	util.Parent = category

	local divider = Instance.new("Frame")
	divider.Name = "divider"
	divider.AnchorPoint = Vector2.new(0.5, 0)
	divider.Position = UDim2.new(0.5, 0, 0, -11)
	divider.Size = UDim2.new(1, -40, 0, 1)
	divider.BackgroundTransparency = 0.95
	divider.BorderSizePixel = 0
	divider.LayoutOrder = -999999
	divider.Parent = util

	create_badge(8).Parent = util

	local padding = Instance.new("UIPadding")
	padding.Name = "padding"
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingRight = UDim.new(0, 1)
	padding.PaddingLeft = UDim.new(0, 1)
	padding.Parent = category

	return category
end

const function build_button_template(): ImageButton
	local button = Instance.new("ImageButton")
	button.Name = "Button"
	button.Size = UDim2.new(1, 0, 0, 36)
	button.LayoutOrder = 6
	button.AutoButtonColor = false
	button.BackgroundTransparency = 1
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.ImageColor3 = Color3.fromRGB(28, 28, 28)
	button.BorderSizePixel = 0
	button.ScaleType = Enum.ScaleType.Slice
	button.SliceScale = 0.05
	button.SliceCenter = Rect.new(512, 512, 512, 512)

	local util = Instance.new("Folder")
	util.Name = "util"
	util.Parent = button

	local screen_directory = Instance.new("ObjectValue")
	screen_directory.Name = "screen_directory"
	screen_directory.Parent = util

	create_badge(10).Parent = util

	local corner = Instance.new("UICorner")
	corner.Name = "corner"
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Padding = UDim.new(0, 10)
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Parent = button

	local padding = Instance.new("UIPadding")
	padding.Name = "padding"
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Name = "stroke"
	stroke.Transparency = 1
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = button
	stroke:AddTag('Exe6AerialEffect')

	local gradient = Instance.new("UIGradient")
	gradient.Name = "gradient"
	gradient.Rotation = -75
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 44, 44)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24)),
	})
	gradient.Parent = stroke
	gradient:AddTag('Exe6DynamicSpeculars')

	local icon = Instance.new("ImageLabel")
	icon.Name = "icon"
	icon.Size = UDim2.fromOffset(16, 16)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.LayoutOrder = 1
	icon.Parent = button

	local label = Instance.new("TextLabel")
	label.Name = "label"
	label.Size = UDim2.new(1, -20, 1, 0)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.AutoLocalize = false
	label.Text = ""
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	
	label.FontFace = Font.new(
		"rbxassetid://12187365364",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.LayoutOrder = 2
	label.Parent = button

	return button
end

const category_template = build_category_template()
const button_template = build_button_template()

const categories: CategoryMap = {}
const buttons: ButtonMap = {}

const function get_category(category_name: string): Frame
	local category = (category_template:Clone() :: any) :: Frame
	category.Name = category_name

	category.Destroying:Connect(function()
		if categories[category_name] == category then
			categories[category_name] = nil
		end
	end)

	return category
end

const function get_button(button_data: Button): ImageButton
	local button = (button_template:Clone() :: any) :: ButtonInstance
	local button_name = button_data.ButtonName

	button.Name = button_name
	button.icon.Image = `rbxassetid://{button_data.ButtonIcon}`
	button.label.Text = button_data.ButtonLabel or button_name
	button.util.screen_directory.Value = button_data.Page

	button.Destroying:Connect(function()
		if buttons[button_name] == button then
			buttons[button_name] = nil
		end
	end)

	return button
end

const sidebar = {
	Category = categories,
	Buttons = buttons,
}

function sidebar.CreateCategory(category_name: string): Frame
	local existing = categories[category_name]
	if existing then
		return existing
	end

	local category = get_category(category_name)
	category.Parent = directory
	categories[category_name] = category

	return category
end

function sidebar.NewButton(button_data: Button): ImageButton
	local existing = buttons[button_data.ButtonName]
	if existing then
		warn(`{script.Name}: button "{button_data.ButtonName}" already exists, replacing`)
		existing:Destroy()
	end

	local button = get_button(button_data)

	button_data.Page.Parent = screen
	button.Parent = button_data.Category
	buttons[button_data.ButtonName] = button

	return button
end

function sidebar.RemoveButton(button_name: string, destroy_page: boolean?)
	local button = buttons[button_name]
	if not button then
		return
	end

	if destroy_page then
		local screen_directory = button:FindFirstChild("screen_directory", true)
		if screen_directory and screen_directory:IsA("ObjectValue") and screen_directory.Value then
			screen_directory.Value:Destroy()
		end
	end

	button:Destroy()
end

function sidebar.RemoveCategory(category_name: string)
	local category = categories[category_name]
	if category then
		category:Destroy()
	end
end

function sidebar.OpenPage(page_name: string): any
	local page = screen:FindFirstChild(page_name)
	if not page or not page:IsA("GuiObject") then
		warn(`{script.Name}: page "{page_name}" not found`)
		return nil
	end

	return exe_main.GoToScreen(page)
end

return sidebar
