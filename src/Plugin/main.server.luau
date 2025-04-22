--|T| TopLevel
_G["ysp"] = plugin --plugin context workaround
local toolbar = plugin:CreateToolbar("YSBundler")
local Packages = script.Parent.Packages
local Modules = script.Parent.Modules
local Helpers = require(Modules.Helpers)
local Buttons = require(script.Parent.Buttons)
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local StudioComponents = require(Packages.StudioComponents)

--|G| Global Variables

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false)

--|F| Functions

local function run(btn)
	local selection = Helpers.getSelectedInstances()
	if btn.RequiresSelection == false then
		btn:onClick(selection)
	elseif selection == nil or #selection == 0 then
	else
		btn:onClick(selection)
	end
end

--|S| Signal

--|B| Buttons

-- for _, button in pairs(Buttons) do
--     toolbar:CreateButton(button.Name, button.Description, "rbxassetid://76542926883536").Click:Connect(function()
--         run(button)
--     end)
-- end

--|M| Main

local mainWidget = plugin:CreateDockWidgetPluginGui("YSBundler", widgetInfo)
mainWidget.Title = "YSBundler | Main"
local toggle = toolbar:CreateButton("YSBundler (toggle)", "Toggles the main widget", "rbxassetid://76542926883536")
toggle.Click:Connect(function()
	mainWidget.Enabled = not mainWidget.Enabled
end)
local function app()
	local mainRender = {}
	local buttons = {}
	table.insert(
		mainRender,
		React.createElement("ImageLabel", {
			Image = "rbxassetid://76542926883536",
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 0, 0),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
		})
	)
	table.insert(
		mainRender,
		React.createElement(StudioComponents.Label, {
			Text = "Made by yami",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 50),
			ZIndex = 2,
			TextColorStyle = Enum.StudioStyleGuideColor.MainText,
		})
	)
	table.insert(
		mainRender,
		React.createElement(StudioComponents.Label, {
			Text = "Remember to read the docs!",
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 0, 50),
			TextColorStyle = Enum.StudioStyleGuideColor.ErrorText,
		})
	)
	for index, button in pairs(Buttons) do
		index = index + 1
		table.insert(
			buttons,
			React.createElement(StudioComponents.Button, {
				Text = button.Name,
				Size = UDim2.new(1, 0, 0, 50),
				LayoutOrder = index,
				OnActivated = function()
					run(button)
				end,
			})
		)
	end
	local mDex = {}
	table.insert(mDex, buttons)
	table.insert(
		mainRender,
		React.createElement(StudioComponents.ScrollFrame, {
			AnchorPoint = Vector2.new(0, -1),
			Position = UDim2.new(0, 0, 0, 100),
			Size = UDim2.new(1, 0, 0.9, -100),
			CanvasSize = UDim2.new(0, 0, 0, 50 * #buttons),
			Layout = {
				ClassName = "UIListLayout",
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
		}, mDex)
	)
	table.insert(
		mainRender,
		React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		})
	)
	return mainRender
end
local root = ReactRoblox.createRoot(mainWidget)
root:render(React.createElement(app))
