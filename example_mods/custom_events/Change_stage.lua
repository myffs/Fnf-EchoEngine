function onEvent(name, value1, value2)
	if name == 'Change stage' then
		stage1 = value1;
        doTweenAlpha('stage1', stage1, 1, 0.0001, 'linear');
		stage2 = value2;
		doTweenAlpha('stage2', stage2, 0, 0.0001, 'linear');
	end
end