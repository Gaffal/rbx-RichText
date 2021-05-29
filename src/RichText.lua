local RichText = {}
RichText.__index = RichText


local function createTag(tag: string)
	return ('<%s>'):format(tag), ('</%s>'):format(tag)
end


function RichText.new(startText: string)
	return setmetatable({
		Text = startText or ''
	}, RichText)
end

function RichText:Bold(target: string, range: integer)
	assert(not target or (type(target) == 'string' and target ~= '') and not range or type(range) == 'number')
	local open, close = createTag('b')

	if (target) then
		return self:Wrap(target, open, close)
	end

	return self:Wrap(self.Text, open, close)
end

function RichText:Underline(target: string, range: integer)
	assert(not target or (type(target) == 'string' and target ~= '') and not range or type(range) == 'number')
	local open, close = createTag('u')

	if (target) then
		return self:Wrap(target, open, close)
	end

	return self:Wrap(self.Text, open, close)
end

function RichText:Strike(target: string, range: integer)
	assert(not target or (type(target) == 'string' and target ~= '') and not range or type(range) == 'number')
	local open, close = createTag('s')

	if (target) then
		return self:Wrap(target, open, close)
	end

	return self:Wrap(self.Text, open, close)
end

function RichText:Italic(target: string, range: integer)
	assert(not target or (type(target) == 'string' and target ~= '') and not range or type(range) == 'number')
	local open, close = createTag('i')

	if (target) then
		return self:Wrap(target, open, close)
	end

	return self:Wrap(self.Text, open, close)
end

function RichText:Break(target: string)
	assert(not target or type(target) == 'string')

	if (target) then
		self:InsertAfter('<br />', target)
	else
		self.Text ..= '<br />'
	end

	return self
end

function RichText:Format(props: Dictionary)
	assert(type(props) == 'table')
	local pattern = '${%s}'

	for name, value in pairs(props) do
		value = tostring(value)

		if value then
			self.Text = self.Text:gsub(pattern:format(name), value)
		end
	end

	return self
end

function RichText:Wrap(target: string, before: string, after: string)
	assert(type(target) == 'string' and type(before) == 'string' and type(after) == 'string')

	local start, finish = self.Text:find(target, 1, true)

	if (start and finish) then
		self.Text = self.Text:sub(1, start - 1) .. before .. target .. after .. self.Text:sub(finish + 1)
	end

	return self
end

function RichText:Size(size: number, target: string)
	assert((not target or type(target) == 'string') and type(size) == 'number')

	if (target) then
		return self:Wrap(target, ('<font size="%s">'):format(size), '</font>')
	end

	return self:Wrap(self.Text, ('<font size="%s">'):format(size), '</font>')
end

function RichText:Font(font: EnumItem | string, target: string)
	assert((not target or type(target) == 'string') and (type(font) == 'string' or typeof(font) == 'EnumItem'))

	if typeof(font) == 'EnumItem' then
		font = font.Name
	end

	if (target) then
		return self:Wrap(target, ('<font face="%s">'):format(font), '</font>')
	end

	return self:Wrap(self.Text, ('<font face="%s">'):format(font), '</font>')
end

function RichText:Join(join: string | table)
	assert(type(join) == 'string' or (type(join) == 'table' and getmetatable(join) == RichText))

	if type(join) == 'table' and join.Text then
		join = join.Text
	end

	self.Text ..= join
	return self

end

function RichText:InsertAfter(text: string, after: string)
	assert(type(text) == 'string' and type(after) == 'string')

	local _, finish = self.Text:find(after)

	if (finish) then
		self.Text = self.Text:sub(1, finish) .. text .. self.Text:sub(finish + 1)
	end

	return self
end

function RichText:ColorRGB(...)
	local props = table.pack(...)

	local target
	local colorText

	if (typeof( props[1] ) == 'Color3') then
		local function format(color)
			return math.round(color * 255)
		end

		local color = props[1]
		target = props[2]

		colorText = format(color.R) .. ',' .. format(color.G) .. ',' .. format(color.B)
	else
		local r, g, b = ...
		target = props[4]

		colorText = r .. ',' .. g .. ',' .. b
	end

	if (target and type(target) == 'string' and target ~= '') then
		self.Text = self.Text:gsub(
			target,
			('<font color="rgb(%s)">%s</font>'):format(colorText, target)
		)
		return self
	end

	self.Text = ('<font color="rgb(%s)">%s</font>'):format(colorText, self.Text)
	return self
end

function RichText:Get()
	return self.Text
end


return RichText