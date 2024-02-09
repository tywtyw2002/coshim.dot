local M = { max_key = 1, exit_on_key = true, show_enter = true, show_exit = false }

--local function callback_enter(self)

--end

function M:init(conf)
	conf = conf or {}
	setmetatable(conf, self)
	self.__index = self

	return conf
end

function M:new(mods, key, message, exit_message)
	if self.k then
		print("Key Modal already inited.")
	end
	self.message = message
	self.exit_message = exit_message
	local k = hs.hotkey.modal.new(mods, key)
	self.k = k

	k.km = self
	function k:entered()
		self.km:callback_enter()
	end

	function k:exited()
		self.km:callback_exit()
	end

	-- reset init value
	self.count = 0

	-- default key bind
	if self.exit_on_key then
		self.k:bind("", "escape", self:callback_bind())
		self.k:bind("", "space", self:callback_bind())
	end
end

function M:bind(mod, key, msg, fn)
	self.k:bind(mod, key, self:callback_bind(fn))
end

function M:callback_enter()
	self.count = 0

	if self.show_enter and self.message then
		hs.alert.show(self.message)
	end
end

function M:callback_exit()
	if self.show_exit and self.exit_message then
		hs.alert.show(self.exit_message)
	end
end

function M:callback_bind(fn)
	if fn == nil then
		fn = function()
			self.k:exit()
			self.count = 0
		end
	end
	return function()
		fn()
		self.count = self.count + 1
		if self.count == self.max_key then
			self.k:exit()
		end
	end
end

return M
