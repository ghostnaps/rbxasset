local function getVariablesFromTaskLogs(taskLogs: { string }): { [string]: string }?
	-- If a task prints a string in the form `KEY=VALUE` we extract it as a
	-- variable with this function. This allows us to get some results from Luau
	-- tasks
	local variables: { [string]: string } = {}
	local foundVariables = false
	for _, line in taskLogs do
		local key, value = line:match("^(.+)=(.+)$")
		if key and value then
			variables[key] = value
			foundVariables = true
		end
	end

	-- This is for ergonomics. If there's no variables then returning nil means
	-- the consumer doesn't have to iterate over the dictionary to know if
	-- there's any keys in it
	return if foundVariables then variables else nil
end

return getVariablesFromTaskLogs
