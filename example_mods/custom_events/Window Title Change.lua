function onEvent(n,v1)
	if n == "Window Title Change" then
		setPropertyFromClass("openfl.Lib", "application.window.title", v1)
	end
end