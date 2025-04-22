local buttons = {}
for _, button in ipairs(script:GetChildren()) do
	if button:IsA("ModuleScript") then
		local tempRequire = require(button)
		-- buttons[tempRequire.Name] = tempRequire
		table.insert(buttons, tempRequire)
	end
end
return buttons
