require "scripts.custom_items.wrapper"
ArrowItem = class(ItemWrapper)

function ArrowItem:init(name)
	self:createItem(name)
	self.code = name:lower()
	print("images/items/" .. self.code .. ".png")
	self.image = ImageReference:FromPackRelativePath("images/items/" .. self.code .. ".png")	
	self.ItemInstance.Icon = self.image
	self.ItemInstance.IconMods = ""
	self.ItemInstance.PotentialIcon = self.image
end

function ArrowItem:getState()
end

function ArrowItem:setState(state)
end

function ArrowItem:setActive(active)
end

function ArrowItem:getActive()
	return true
end

function ArrowItem:updateIcon()
end

function ArrowItem:onLeftClick()
	input(self.code)
end

function ArrowItem:onRightClick()
	input(self.code)
end

function ArrowItem:onMiddleClick()
	input(self.code)
end

function ArrowItem:canProvideCode(code)
	return code == self.code
end

function ArrowItem:providesCode(code)
	if code == self.code then
		return 1
	end
	return 0
end

function ArrowItem:advanceToCode(code)
end

function ArrowItem:save()
	--intentionally do not save
	return {}
end

function ArrowItem:load(data)
	--intentionally do not load
	return true
end

function ArrowItem:propertyChanged(key, value)
end
