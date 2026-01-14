-- Phantasm Maid Implementation
local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid:GiveTask(task)
	if not task then return end
	local taskId = #self._tasks + 1
	self._tasks[taskId] = task
	return taskId
end

function Maid:DoCleaning()
	for index, task in pairs(self._tasks) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif type(task) == "function" then
			task()
		elseif type(task) == "table" and type(task.Destroy) == "function" then
			task:Destroy()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		end
		self._tasks[index] = nil
	end
end

function Maid:Destroy()
	self:DoCleaning()
end

return Maid
