--[[

        /ᐠ. ｡.ᐟ\ᵐᵉᵒʷˎˊ˗ 
        Made by NeDIAD a.k.a NotDIAD
        https://github.com/NeDIAD/tweaks \ https://github.com/NeDIAD

]]

tweaks = tweaks or {}

local fps = 0
local frameTime = 0

client.set_event_callback('paint_ui', function()
    frameTime = globals.absoluteframetime()

    if frameTime > 0 then
        fps = 1 / frameTime
    else
        fps = 0
    end
end)

local hg = {'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear'}

tweaks.presets = {
    trashtalk = {
        Tweaks = {
            kill = {'Kill phrase 1, %s', 'Kill phrase 2, %s', 'Kill phrase 3, %s'},
            death = {'Death phrase 1, %s', 'Death phrase 2, %s', 'Death phrase 3, %s'},
        },
        --[[
        
            %s = Nickname who killed / who was killed

        ]]
    },
    clantag = {
        Tweaks = {
            '>> tweaks.lua', '<<', '',
        },

        --[[

            '>> 123' = '1', '12', '123'
            '<<' = '123', '12', '1',
            'string' = 'string' 

        ]]
    },
    hitsounds = {
        -- csgo/sound/ ...
        -- Disable skeet hs = ESP -> Player Esp -> Hitmarker sound,
        -- Need to restart if you added new sound
        -- Only .mp3 & .wav sounds

        'hitsound/hitsound.mp3',
        'resource/warning.wav',
    }
}

local ffi = require('ffi')
--local http = require('gamesense/http')

table.clear = require('table.clear')
table.find = function(a, b) for i,v in ipairs(a) do if v == b then return i end end end
table.count = function(a) local r = 0 for i, v in ipairs(a) do r = r + 1 end for i, v in pairs(a) do r = r + 1 end return r end
math.clamp = function(a, b, c) return math.max(b, math.min(c, a)) end

--[[

    FFI

    Hitsound by heydanlag

]]

local function vmt_entry(instance, index, type)
	return ffi.cast(type, (ffi.cast('void***', instance)[0])[index])
end

local function vmt_bind(module, interface, index, typestring)
	local instance = client.create_interface(module, interface) or error('invalid interface')
	local success, typeof = pcall(ffi.typeof, typestring)
	if not success then
		error(typeof, 2)
	end
	local fnptr = vmt_entry(instance, index, typeof) or error('invalid vtable')
	return function(...)
		return fnptr(instance, ...)
	end
end

local playsound = vmt_bind("vguimatsurface.dll", "VGUI_Surface031", 82, "void(__thiscall*)(void*, const char*)")

local function normal_sound(name)
	if name:find('_') then
		name = name:gsub('_', ' ')
	end
	if name:find('.mp3') then
		name = name:gsub('.mp3', '')
	end
	if name:find('.wav') then
		name = name:gsub('.wav', '')
	end
	return name
end

local color do
    local hex_rgb = function (hex)
        hex = string.gsub(hex, "^#", "")
        return tonumber(string.sub(hex, 1, 2), 16), tonumber(string.sub(hex, 3, 4), 16), tonumber(string.sub(hex, 5, 6), 16), tonumber(string.sub(hex, 7, 8), 16) or 255
    end

    
    local mt = {
        __eq = function (a, b)
            return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
        end,
        lerp = function (h, t, w)
            return create(h.r + (t.r - h.r) * w, h.g + (t.g - h.g) * w, h.b + (t.b - h.b) * w, h.a + (t.a - h.a) * w)
        end,
        to_hex = hex_rgb,
        alphen = function (self, a, r)
            return create(self.r, self.g, self.b, r and a * self.a or a)
        end,
    }	mt.__index = mt
    
    local create = ffi.metatype(ffi.typeof("struct { uint8_t r; uint8_t g; uint8_t b; uint8_t a; }"), mt)
    
    color = {}
    
    color.rgb = function (r,g,b,a)
        r = math.min(r or 255, 255)
        return create(r, g and math.min(g, 255) or r, b and math.min(b, 255) or r, a and math.min(a, 255) or 255)
    end
    color.hex = function (hex)
        local r,g,b,a = hex_rgb(hex)
        return create(r,g,b,a)
    end
end

local print_ do
	local native_print = vtable_bind("vstdlib.dll", "VEngineCvar007", 25, "void(__cdecl*)(void*, const void*, const char*, ...)")
    
	print_ = function (...)
		for i, v in ipairs{...} do
			local r = "\aD9D9D9" .. string.gsub(tostring(v), "[\r\v]", {["\r"] = "\aD9D9D9", ["\v"] = "\a".. (('\a74A6A9FF'):sub(1, 7))})
			for col, text in r:gmatch("\a(%x%x%x%x%x%x)([^\a]*)") do
				native_print(color.hex(col), text)
			end
		end
		native_print(color.rgb(217, 217, 217), "\n")
	end
end

function table.Reverse(tbl)
    local reverse = {}
    for i, v in ipairs(tbl) do
        table.insert(reverse, 1, v)
    end

    return reverse
end


local function Lerp(d, h, t)
    if not d or not h or not t then return 0 end

	if d > 1 then return to end
    if d < 0 then return from end
    
	return (h + ( t - h ) * d or 0) 
end

tweaks.settings = {}
tweaks.colors = {
    base = '\af5c242',
    gray = '\aaaaaaa',
    green = '\a34eb6b',
    red = '\aeb344f',
    purple = '\ab434eb',
    white = '\affffff',
    rgb = {
        base = {r = 245, g = 194, b = 66}
    }
}

tweaks.settings = {
    prefix = '   ' .. tweaks.colors.base .. 'tweaks.lua \a'.. tweaks.colors.white ..'» ',
    dev = false,
    version = 'alpha 0.2'
}

function tweaks.print(...) 
    local args = {...}
    local send = {}
    for i,v in ipairs(args) do
        local txt = tostring(v)
        table.insert(send, tweaks.colors.gray .. txt)
    end
    print_(tweaks.settings.prefix, unpack(send))
end

local function assert(str) if tweaks.settings.dev then tweaks.print(str) end end

local function process(str) tweaks.print('Processing ' .. tweaks.colors.white .. str) end
local function process_end(str) tweaks.print('Processed ' .. tweaks.colors.white .. str) end

tweaks.print('Processing started ')
tweaks.start = client.timestamp()
tweaks.print('Init version: ' .. tweaks.colors.white .. tweaks.settings.version)

if tweaks.settings.dev then tweaks.print('Loaded in ' .. tweaks.colors.white .. 'dev-mode' .. tweaks.colors.gray ..'!') end

local render do
    process('Render library')
    render = {}
    render.textures = {
        svg = {
            edge = renderer.load_svg('<svg width="5.87" height="4" viewBox="0 0 6 4"><path fill="#fff" d="M2 0H0c0 2 2 4 4 4h2C4 4 2 2 2 0Z"/></svg>', 12, 8),
        },
        png = {
            
        },
    }

    function render.rectangle(x, y, w, h, r, g, b, a, radius)
        x = type(x) == 'number' and x or 0; y = type(y) == 'number' and y or 0; w = type(w) == 'number' and w or 0; h = type(h) == 'number' and h or 0; r = r or 255 g = g or 255 b = b or 255 a = a or 255 radius = radius or 8
        x = math.floor(x); y = math.floor(y); w = math.floor(w); h = math.floor(h)

        if w < 20 then w = 20 end

        renderer.rectangle(x + radius, y, w - 2 * radius, h, r, g, b, a)
        renderer.rectangle(x, y + radius, radius, h - 2 * radius, r, g, b, a)
        renderer.rectangle(x + w - radius, y + radius, radius, h - 2 * radius, r, g, b, a)

        renderer.circle(x + radius, y + h - radius, r, g, b, a, radius, -90, 0.25) -- l b
        renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25) -- l t
        renderer.circle(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25) -- r b
        renderer.circle(x + w - radius, y + radius, r, g, b, a, radius, 90, 0.25) -- r t
    end

    function render.edge_v(x, y, length, alpha)
        renderer.texture(render.textures.svg.edge, x, y + 4, 6, -4, tweaks.colors.rgb.base.r, tweaks.colors.rgb.base.g, tweaks.colors.rgb.base.b, alpha, "f")
        renderer.rectangle(x, y + 4, 2, length - 8, tweaks.colors.rgb.base.r, tweaks.colors.rgb.base.g, tweaks.colors.rgb.base.b, alpha)
        renderer.texture(render.textures.svg.edge, x, y + length - 4, 6, 4, tweaks.colors.rgb.base.r, tweaks.colors.rgb.base.g, tweaks.colors.rgb.base.b, alpha, "f")
    end
   
    process_end('Render library')
end

local mouse do
    process('Mouse library')

    mouse = {}
    
    function mouse.held() return client.key_state(0x01) end
    function mouse.inbounds(x, y, w, h) 
        if not x or not y or not w or not h then assert('Memory leak? Nil values defined!') end

        x = x or 0 y = y or 0 w = w or 0 h = h or 0

        local endX, endY = x + w, y + h
        local mX, mY = ui.mouse_position()

        return mX >= x and mY >= y and mX <= endX and mY <= endY
    end
    function mouse.calc(x1, y1, x2, y2, w, h)
        local scrW, scrH = client.screen_size()
        local mX, mY = ui.mouse_position()
    
        local offsetX = x2 - x1
        local offsetY = y2 - y1

        local newX = mX - offsetX
        local newY = mY - offsetY

        --assert('x1, x2, y1, y2, resX, resY: '..' '.. x1..' '.. x2..' '.. y1..' '.. y2..' '.. newX..' '.. newY)
        --assert('mX, mY, scrW, scrH: '.. mX ..' '.. mY..' '.. scrW..' '.. scrH)

        if newX < 0 then assert('x < 0') newX = 0 end
        if newY < 0 then assert('y < 0') newY = 0 end
        if newX + w > scrW then assert('x > scr') newX = scrW - w end
        if newY + h > scrH then assert('y > scr') newY = scrH - h end

        return newX, newY
    end

    process_end('Mouse library')
end

local widgets do
    process('Widgets library')

    local paint_queue = {}
    local lerp = 0
    local a = false

    widgets = {}
    widgets.__index = widgets

    function widgets.new(x, y, w, h, id, draggable, paint_ui, corner, shutdown)
        if not id then assert('No id!') id = table.count(paint_queue) end
        tostring(id)

        x = type(x) == 'number' and x or 0
        y = type(y) == 'number' and y or 0
        w = type(w) == 'number' and w or 100
        h = type(h) == 'number' and h or 100
        corner = type(corner) == 'number' and corner or 8

        draggable = type(draggable) == 'table' and draggable or {x = true, y = true}

        local self = setmetatable({}, widgets)

        local scrW, scrH = client.screen_size()

        local sliderX, sliderY = ui.new_slider('MISC', 'Settings', id .. ':x' , 0, scrW, x), ui.new_slider('MISC', 'Settings', id .. ':y', 0, scrH, y)
        ui.set_visible(sliderX, false); ui.set_visible(sliderY, false)

        self.shutdown = shutdown or function() end

        self.ui = {x = sliderX, y = sliderY}
        self.cord = {x = x, y = y, w = w, h = h}
        self.cord_lerp = {x = x, y = y, w = w, h = h}
        self.paint = true

        ui.set_callback(sliderX, function() self.cord.x = ui.get(sliderX) end)
        ui.set_callback(sliderY, function() self.cord.y = ui.get(sliderY) end)
        local extra_lerp = .6
        local toggle = false
        local start = {}
        
        local rX, rY = x, y

        self.push = function()
            
            if not self then assert('Memory leak! Failed to define self!') return false end
            if not self.cord then assert('Memory leak! Faield to define cord!') self.cord = {} return false end
            if not self.cord.x or not self.cord.y or not self.cord.w or not self.cord.h then assert('Memory leak! Failed to define cord!') self.cord = {x = ui.get(sliderX), y = ui.get(sliderY), w = w, h = h} return false end
            if not self.ui or not self.ui.x or not self.ui.y then assert('Memory leak! Failed to define ui!') self.ui = {x = sliderX, y = sliderY} end
            if not self.paint and self.cord_lerp.x + 5 >= (scrW + self.cord.w) then return false end

            if (lerp or 0) < .05 then return false end

            local statement = toggle or mouse.inbounds(self.cord.x, self.cord.y, self.cord.w, self.cord.h)
            
            extra_lerp = Lerp(globals.frametime() * 10, extra_lerp, statement and 0 or .6)
            if not draggable.x and self.cord.x ~= rX then assert('X Coord!') self.cord.x = rX end
            if not draggable.y and self.cord.y ~= rY then assert('Y Coord!') self.cord.y = rY end
            self.cord_lerp.x = Lerp(globals.frametime() * 10, x, (self.paint and self.cord.x or scrW + self.cord.w))
            self.cord_lerp.y = Lerp(globals.frametime() * 10, y, self.cord.y)

            x = self.cord_lerp.x
            y = self.cord_lerp.y

            render.rectangle(x, y, self.cord.w, self.cord.h, 255, 255, 255, 100 * math.clamp((lerp - extra_lerp), 0, 1), corner)
            --renderer.blur(self.cord.x, self.cord.y, self.cord.w, self.cord.h, math.clamp((lerp - extra_lerp), 0, 1), math.clamp((lerp - extra_lerp), 0, 1))

            if mouse.held() and (statement) and (draggable.x or draggable.y) and (a == id or not a) then
                if table.count(start) <= 0 or not start.x or not start.y or not start.mX or not start.mY then 
                    local mX, mY = ui.mouse_position()

                    start = {
                        mX = mX,
                        mY = mY,
                        x = self.cord.x,
                        y = self.cord.y,
                    }
                end
                toggle = true
                a = id

                local nX, nY = mouse.calc(start.x, start.y, start.mX, start.mY, self.cord.w, self.cord.h)

                if nX and nY then
                    if draggable.x then ui.set(self.ui.x, nX) end
                    if draggable.y then ui.set(self.ui.y, nY) end
                end
            else
                if a == id then a = nil end
                toggle = false
                start = {}
            end

            self.cord_lerp.w = w
            self.cord_lerp.h = h

            if paint_ui then paint_ui() end
        end

        paint_queue[id] = self

        self.id = id

        return self
    end

    client.set_event_callback('paint_ui', function()
        --if fps < 25 then assert('Low framerate! Render cancelled to avoid memory leaks.') return false end

        lerp = lerp or 0

        lerp = Lerp(globals.frametime() * 10, lerp, ui.is_menu_open() and 1 or 0)

        for i,v in pairs(paint_queue) do
            if type(v) ~= 'table' or not v.push then goto continue end

            local state, err = pcall(v.push)
            if not state then assert(err) end

            ::continue::
        end
    end)

    client.set_event_callback('shutdown', function()
        for i,v in pairs(paint_queue) do
            v.shutdown()
        end
    end)

    process_end('Widgets library')
end

--widgets.new(nil, nil, nil, nil, nil)
--widgets.new(nil, nil, nil, nil, nil)
--widgets.new(nil, nil, nil, nil, nil)

local t, l = 'Lua', 'A'

ui.new_label(t, l, tweaks.colors.white .. 'FF•' .. tweaks.colors.base .. 'FF Tweaks | '.. tweaks.colors.gray ..'FF' .. tweaks.settings.version)

local tabs do
    process('Tabs')
    local active_tab, combo, tabslist = nil, nil, {}

    tabs = {}
    tabs.__index = tabs

    tabs.tabs = {}

    function tabs.new(name)
        if not name then return false end
        name = tostring(name)

        local prev_value

        if combo then prev_value = ui.get(combo); ui.set_visible(combo, false) end

        table.insert(tabslist, name)

        combo = ui.new_combobox(t, 'B', tweaks.colors.white .. 'FF • '.. tweaks.colors.base .. 'FFTweaks' .. tweaks.colors.white .. 'FF »'.. tweaks.colors.gray ..'FF Select tab', unpack(tabslist))
        if prev_value then ui.set(combo, prev_value) end

        tabs.tabs[name] = {}

        local self = setmetatable({tab = name, elements = tabs.tabs[name]}, tabs)
        
        return self
    end

    function tabs:add(element, requirement)
        if not element or not self or type(self) ~= 'table' then return false end
        requirement = requirement or function() return true end

        table.insert(self.elements, {element, requirement})
    end

    client.set_event_callback('paint_ui', function()
        --render.rectangle(64, 64, 256, 256, 255, 255, 255, 100, 10)

        if not ui.is_menu_open() then return false end
    
        for i,v in pairs(tabs.tabs) do
            if type(v) ~= 'table' then assert('Tab ' .. tostring(i) .. ' not table') goto continue end
    
            for _, element in ipairs(v) do
                if type(element) ~= 'table' then assert('Element ' .. tostring(_) .. ' not table!') goto continue end
                if not element[1] or type(element[2]) ~= 'function' then assert('One of elements error') goto continue end
    
                --assert('Paint_ui: ' .. tostring(_) .. ': ' .. tostring(element))
    
                local success, err = pcall(function() ui.set_visible(element[1], element[2]() and ui.get(combo) == i) end)
                if not success then assert(err) end
    
                ::continue::
            end
    
            ::continue::
        end
    end)

    process_end('Tabs')
end

local notifications do
    process('Notifications')

    local scrW, scrH = client.screen_size()

    local notify_h, notify_off = 22, 10
    local notify_max = 5

    local w, h = 300, (notify_h + notify_off) * notify_max + notify_off
    local active = {}
    local show_notify
    local widget = widgets.new(scrW / 2 - w / 2, 700, w, h, 'notifications', {x = false, y = true}, function()
    
        if table.count(active) <= 0 and not show_notify then
            data = {
                result = (client.random_int(1, 2) == 1 and true or false),
                hitgroup = client.random_int(1, #hg - 1),
                damage = client.random_int(1, 100)
            }

            data.reason = data.result and nil or 'spread'
            show_notify = notifications.new(tweaks.colors[data.result and 'green' or 'red'] .. 'FF• ' .. tweaks.colors.gray .. (data.result and 'FFHit ' or 'FFMissed ') .. tweaks.colors.white .. 'FF' .. 'ekzoterik' .. tweaks.colors.gray .. 'FF\'s ' .. tweaks.colors.white .. 'FF' .. hg[data.hitgroup + 1] .. tweaks.colors.gray .. 'FF ~ ' .. tweaks.colors.white .. 'FF' .. (data.result and data.damage or data.reason), -1) 
        elseif show_notify and table.count(active) > 2 then
            show_notify.pre_disabled = true
            show_notify = nil
        end

    end)


    data = {
            result = (client.random_int(1, 2) == 1 and true or false),
            hitgroup = client.random_int(1, #hg - 1),
            damage = client.random_int(1, 100)
        }

        data.reason = data.result and nil or 'spread'

        local to_shownotify

    notifications = {}
    notifications.__index = notifications

    function notifications.new(str, timeout)
        if not str then return false end
        str = tostring(str)

        timeout = type(timeout) == 'number' and timeout or 5
        

        if #active >= notify_max then
            for i,v in ipairs(active) do
                if not v.disabled then v.disabled = true break end
            end
        end

        local self = setmetatable({}, notifications)

        self.start = globals.realtime()
        self.pre_disabled = false
        self.disabled = false

        self.lerp = {
            text = 0.1,
            global = 0,
            y = scrH
        }

        local push = function()
            if not globals.mapname() then if show_notify ~= self then self:destroy() return false end self.start = globals.realtime() end
            
            local state, err = pcall(function() if self.lerp.global < 0 then end end)
            if not state then assert('Memory check failure, destroying notification..') self:destroy() return false end

            if (globals.realtime() - self.start > (globals.mapname() and timeout or 10) and timeout >= 0) or self.pre_disabled then self.pre_disabled = true; self.disabled = (self.pre_disabled and self.lerp.text <= .2) end

            local tW, tH = renderer.measure_text('', str)
            local target_y = widget.cord.y + notify_off + ((notify_h + notify_off) * (table.find(active, self) - 1))

            if self.lerp.global <= .05 and self.disabled then self:destroy() end
            self.lerp.text = Lerp(globals.frametime() * 10, self.lerp.text, self.lerp.global >= .9 and (self.pre_disabled and 0.1 or 1) or 0)
            self.lerp.global = Lerp(globals.frametime() * 10, self.lerp.global, self.disabled and 0 or 1)
            self.lerp.y = Lerp(globals.frametime() * 10, self.lerp.y, self.disabled and scrH or target_y)
            if self.lerp.global >= .95 and not self.disabled then self.lerp.global = 1 end

            local w = (tW + 50) * self.lerp.global

            render.rectangle(scrW / 2 - w / 2, self.lerp.y, w, notify_h, 24, 24, 24, 100 * self.lerp.global, 8)
            renderer.blur(scrW / 2 - w / 2, self.lerp.y, w, notify_h)
            render.edge_v(scrW / 2 - w / 2, self.lerp.y, notify_h, 255 * self.lerp.global)
            if not self.disabled then
                renderer.text(scrW / 2, self.lerp.y + notify_h / 2, 255, 255, 255, 255, 'c', w * self.lerp.text, str)
            end
        end

        self.push = push

        table.insert(active, self)

        return self
    end

    function notifications:destroy()
        assert('Removed notification')
        table.remove(active, table.find(active, self))
    end

    client.set_event_callback('paint_ui', function()
        --if fps < 25 then assert('Low framerate! Render cancelled!') return false end

        for i,v in ipairs(active) do
            if type(v) ~= 'table' or not v.push then goto continue end

            local state, err = pcall(v.push)
            if not state then assert(err) end

            ::continue::
        end

        if show_notify and not ui.is_menu_open() then show_notify.pre_disabled = true show_notify = nil end
    end)

    process_end('Notifications')
end

local function unpack_event(data)
    local victim, attacker = data.userid, data.attacker
    if not victim or not attacker then assert('Event error: Failed to resolve data!') return nil, nil end

    victim, attacker = client.userid_to_entindex(victim), client.userid_to_entindex(attacker)
    return victim, attacker
end

local function label(str, tab) local lbl = ui.new_label(t, l, tweaks.colors.white .. 'FF • »'.. tweaks.colors.base ..'FF '.. str) tab:add(lbl) end

local function contain(element, needle) return table.find(ui.get(element), needle) end

--[[

    MISC

]]

local misc = tabs.new('Misc')

local filter = ui.new_checkbox(t, l, 'Filter console')
misc:add(filter)

ui.set_callback(filter, function()
    local _ = ui.get(filter)
    
    cvar.con_filter_enable:set_int(_ and 1 or 0)
	cvar.con_filter_text:set_string(_ and 'tweaks.lua' or '')
end)

local hitsound do
    process('Hit-sound')
    label('Hit-sound', misc)
    local checkbox = ui.new_checkbox(t, l, 'Enable custom hit-sound')
    misc:add(checkbox)

    local sounds = {

    }

    local unpack_ = {}

    local function new(sound)
        local norm = normal_sound(sound)
		sounds[norm] = sound
        table.insert(unpack_, norm)
    end
    
    for i,sound in ipairs(tweaks.presets.hitsounds) do
        local norm = normal_sound(sound)
		sounds[norm] = sound
        table.insert(unpack_, norm)
    end

    local sound = ui.new_combobox(t, l, 'Custom Hit-Sound', unpack(unpack_))
    misc:add(sound, function() return ui.get(checkbox) end)

    ui.set_callback(checkbox, function()
        local _ = ui.get(checkbox)

        client[(_ and 'set' or 'unset') .. '_event_callback']('aim_hit', function()
            assert('Playsound')
            playsound(sounds[ui.get(sound)])
        end)
    end)

    process_end('Hit-sound')
end

local trashtalk do
    process('Trash-talk')
    label('Trash-Talk', misc)

    local checkbox = ui.new_checkbox(t, l, 'Enable trash-talk')
    misc:add(checkbox)

    local presets do presets = {} for i,v in pairs(tweaks.presets.trashtalk) do table.insert(presets, i) end end

    local preset = ui.new_combobox(t, l, 'Trash-talk preset', unpack(presets))
    local events = ui.new_multiselect(t, l, 'TT Triggers', 'Kill', 'Death')
    misc:add(preset, function() return ui.get(checkbox) end)
    misc:add(events, function() return ui.get(checkbox) end)

    local function get_phrase(tbl)
        local _preset = tweaks.presets.trashtalk[ui.get(preset)]

        if not _preset[tbl] then assert('Phrase: Failed to find ' .. tsotring(tbl) .. ' in preset!') return '?' end
        if #_preset[tbl] <= 1 then assert('Phrase: Preset must have more than 1 phrase! ' .. tostring(tbl)) return _preset[tbl][1] end

        return _preset[tbl][client.random_int(1, #_preset[tbl])]
    end

    local push = function(data)
        if #ui.get(events) <= 0 then return false end

        assert('Event: Obsfucating player_death')

        local victim, attacker = unpack_event(data)

        if not victim or not attacker then assert('Event error: Failed to resolve data!') return false end

        if entity.is_enemy(victim) and attacker == entity.get_local_player() and contain(events, 'Kill') then
            assert('Info: Trash talk (kill)')

            client.exec('say ' .. string.format(get_phrase('kill'), entity.get_player_name(victim)))
        elseif entity.is_enemy(attacker) and victim == entity.get_local_player() and contain(events, 'Death') then
            assert('Info: Trash talk (death)')

            client.exec('say ' .. string.format(get_phrase('death'), entity.get_player_name(attacker)))
        elseif tweaks.settings.dev then
            tweaks.print('Info: skip')
        end

        assert('Event: player_death (end)')
    end

    ui.set_callback(checkbox, function()
        local value = ui.get(checkbox)

        client[(value and 'set' or 'unset') .. '_event_callback']('player_death', push)
    end)

    trashtalk = {checkbox, preset, events}
    process_end('Trash-talk')
end

local logger do
    process('Logger')
    label('Logger', misc)

    local checkbox = ui.new_checkbox(t, l, 'Enable logger')
    local outcome = ui.new_multiselect(t, l, 'Logger outcome', 'Notification', 'Console')
    misc:add(checkbox)


    local events_data = {
        ['Ragebot'] = function(data)

            local outcome_ = {
                ['Console'] = function()
                    local hp_left = entity.get_esp_data(data.target).health
                    
                    tweaks.print((data.result and 'Hit in ' or 'Missed '), tweaks.colors.white .. entity.get_player_name(data.target), '\'s ', tweaks.colors.white .. hg[data.hitgroup + 1], (data.result and ' for ' .. tweaks.colors.white .. data.damage .. tweaks.colors.gray .. 'hp (' .. (hp_left or '?') .. 'hp left) ' or ' '), '~ ', (data.reason and data.reason .. ', ' or ''), ((data.hitgroup + 1 ~= data.shot.hitgroup + 1 or data.damage ~= data.shot.damage) and 'exp: ' .. tweaks.colors.white .. hg[data.shot.hitgroup + 1] .. '-' .. data.shot.damage .. ', ' or ''), 'hc: ', tweaks.colors.white .. string.format('%.2f', data.hit_chance) .. '%%', ', ', '△ ~ ', data.shot.backtrack, 't')
                    
                    if not entity.is_alive(data.target) and data.result then tweaks.print('Killed ', tweaks.colors.white .. entity.get_player_name(data.target), tweaks.colors.gray .. ' in ', tweaks.colors.white .. hg[data.hitgroup + 1]) end
                end,
                ['Notification'] = function()

                    notifications.new(tweaks.colors[data.result and 'green' or 'red'] .. 'FF• ' .. tweaks.colors.gray .. (data.result and 'FFHit ' or 'FFMissed ') .. tweaks.colors.white .. 'FF' .. entity.get_player_name(data.target) .. tweaks.colors.gray .. 'FF\'s ' .. tweaks.colors.white .. 'FF' .. hg[data.hitgroup + 1] .. tweaks.colors.gray .. 'FF ~ ' .. tweaks.colors.white .. 'FF' .. (data.result and data.damage or data.reason))

                    if not entity.is_alive(data.target) and data.result then
                        notifications.new(tweaks.colors.purple .. 'FF• ' .. tweaks.colors.gray .. 'FFKilled ' .. tweaks.colors.white .. 'FF' .. entity.get_player_name(data.target) .. tweaks.colors.gray ..'FF in ' .. tweaks.colors.white ..'FF' .. hg[data.hitgroup + 1])
                    end
                end
            }

            for i, v in ipairs(ui.get(outcome)) do
                if outcome_[v] then
                    outcome_[v]()
                end
            end
        end,
        ['Got damage'] = function(data)
            local outcome_ = {
                ['Console'] = function()
                    if data.result then 
                        tweaks.print('You was killed by ' .. tweaks.colors.white .. entity.get_player_name(data.aen))
                    else
                        tweaks.print(tweaks.colors.white .. entity.get_player_name(data.aen) .. tweaks.colors.gray .. ' damaged you for ' .. tweaks.colors.white .. data.dmg_health .. tweaks.colors.gray .. ' ~ ' .. tweaks.colors.white .. hg[data.hitgroup + 1])
                    end 
                end,
                ['Notification'] = function()
    
                    if data.result then
                        notifications.new(tweaks.colors.red .. 'FF•'.. tweaks.colors.gray ..'FF Killed by ' .. tweaks.colors.white ..'FF'.. entity.get_player_name(data.aen))
                    else
                        notifications.new(tweaks.colors.red .. 'FF•'.. tweaks.colors.white ..'FF ' .. entity.get_player_name(data.aen) .. tweaks.colors.gray .. 'FF damaged you for ' .. tweaks.colors.white .. 'FF' .. data.dmg_health .. tweaks.colors.gray .. 'FF ~ ' .. tweaks.colors.white .. 'FF' .. hg[data.hitgroup + 1])
                    end
                end
            }
    
            for i, v in ipairs(ui.get(outcome)) do
                if outcome_[v] then
                    outcome_[v]()
                end
            end
        end,
        }

    local _events do _events = {} for i,v in pairs(events_data) do table.insert(_events, i) end end

    local events = ui.new_multiselect(t, l, 'Logger events', unpack(_events))
    misc:add(events, function() return ui.get(checkbox) end)
    misc:add(outcome, function() return ui.get(checkbox) end)

    local function event_fire(event, data)
        if not contain(events, event) or not events_data[event] or not ui.get(checkbox) then return false end
        
        assert('Events-logger: sent '.. event)

        events_data[event](data)
    end

    local aim_log = {}

    client.set_event_callback('aim_fire', function(shot) shot.backtrack = globals.tickcount() - shot.tick aim_log[shot.id] = shot end)

    client.set_event_callback('aim_hit', function(data)
        local full = aim_log[data.id]

        data.result = true
        data.shot = full

        event_fire('Ragebot', data)
    end)

    client.set_event_callback('aim_miss', function(data)
        local full = aim_log[data.id]

        data.result = false
        data.shot = full

        event_fire('Ragebot', data)
    end)

    client.set_event_callback('player_death', function(data)
        local ven, aen = unpack_event(data)

        if not ven or not aen then return false end
        if ven == entity.get_local_player() and entity.is_enemy(aen) then
            data.aen = aen
            data.result = true
            event_fire('Got damage', data)
        end
    end)

    client.set_event_callback('player_hurt', function(data)
        local ven, aen = unpack_event(data)

        if not ven or not aen then return false end
        if ven == entity.get_local_player() and entity.is_enemy(aen) then
            data.aen = aen
            data.result = false
            event_fire('Got damage', data)
        end
    end)

    process_end('Logger')
end

local clantag do
    process('Clan-tag')
    label('Clan-tag', misc)

    local checkbox = ui.new_checkbox(t, l, 'Enable clan-tag')
    misc:add(checkbox)

    process('Clan-tag presets')

    local presets = {}

    local unpack_ = {}

    for ins, preset in pairs(tweaks.presets.clantag) do
        table.insert(unpack_, ins)
        presets[ins] = {}
        local reverse_table = {}

        for _, tag in ipairs(preset) do
            if string.find(tag, '^>> ') then
                assert('Auto!')
                local _tag = string.gsub(tag, '^>> ', '', 1)

                local str = ''
                table.insert(presets[ins], str)

                for char in _tag:gmatch('.') do
                    str = str .. char
                    table.insert(presets[ins], str)
                    table.insert(reverse_table, str)
                    assert(str)
                end
            elseif tag == '<<' then
                assert('Reverse!')

                reverse_table = table.Reverse(reverse_table)

                for _, _tag in ipairs(reverse_table) do
                    table.insert(presets[ins], _tag)
                    assert(_tag)
                end

                reverse_table = {}
            else
                assert(tag)
                table.insert(presets[ins], tag)
                table.insert(reverse_table, tag)
            end
        end
    end

    local preset = ui.new_combobox(t, l, 'Clan-tag preset', unpack(unpack_))
    misc:add(preset, function() return ui.get(checkbox) end)
    local last

    local push = function()
        local tag = presets[ui.get(preset)]
    
        local time = math.floor(globals.curtime() * 4 + 0.5)
        local i = time % #tag + 1
        if i == last then return end
        last = i
        client.set_clan_tag(tag[i])
    end

    ui.set_callback(checkbox, function()
        local _ = ui.get(checkbox)

        client[(_ and 'set' or 'unset') .. '_event_callback']('net_update_end', push)

        if not _ then client.set_clan_tag('') end
    end)
    
    process_end('Clan-tag')
end

local autobuy do
    process('Auto-buy')
    label('Auto-buy', misc)

    local checkbox = ui.new_checkbox(t, l, 'Enable auto-buy')
    misc:add(checkbox)

    local sets = {
        Main = {
            ['None']= 'none',
            ['SSG 08'] = 'ssg08',
            ['AWP'] = 'awp',
            ['AUTO'] = 'scar20',
        },
        Pistols = {
            ['None'] = 'none',
            ['Deagle/R8'] = 'deagle',
        },
        Misc = {
            ['Armor'] = 'vesthelm',
            ['Smoke'] = 'smokegrenade',
            ['Flashbang'] = 'flashbang',
            ['Molotov'] = 'molotov',
            ['He grenade'] = 'hegrenade',
            ['Taser'] = 'taser',
            ['Defuse kit'] = 'defuser'
        }
    }

    local unpack_ do 
        unpack_ = {}
        for i,v in pairs(sets) do 
            unpack_[i] = {} 
            for _, weap in pairs(v) do 
                table.insert(unpack_[i], _) 
            end
        end 
    end

    local main = ui.new_combobox(t, l, 'Main weapon', unpack(unpack_['Main']))
    local pistol = ui.new_combobox(t, l, 'Pistol', unpack(unpack_['Pistols']))
    local misc_weap = ui.new_multiselect(t, l, 'Other', unpack(unpack_['Misc']))

    misc:add(main, function() return ui.get(checkbox) end)
    misc:add(pistol, function() return ui.get(checkbox) end)
    misc:add(misc_weap, function() return ui.get(checkbox) end)

    local buybot_push = function()
        local buy_queue = {
            [main] = sets.Main,
            [pistol] = sets.Pistols,
            [misc_weap] = sets.Misc,
        }
        
        local function buy(weapon, table)
            if weapon == 'none' then assert('None! Skipping.') return false end
            assert('Buy: ' .. weapon .. ' ' .. table[weapon])
            client.exec('buy '.. table[weapon])    
        end

        for i,v in pairs(buy_queue) do
            local weapons = ui.get(i)
            
            if type(weapons) == 'table' then
                for _, weap in ipairs(weapons) do
                    buy(weap, v)
                end
            else
                buy(weapons, v)
            end
        end
    end

    local push = function(data)
        assert('Spawn: '.. data.userid)
        if client.userid_to_entindex(data.userid) ~= entity.get_local_player() then return false end

        assert('Buybot')

        client.delay_call(.5, buybot_push) -- Avoiding delay between "buy" command work
    end

    ui.set_callback(checkbox, function()
        local _ = ui.get(checkbox)

        client[(_ and 'set' or 'unset') .. '_event_callback']('player_spawn', push)
    end)

    process_end('Auto-buy')
end

client.set_event_callback('shutdown', function() client.set_clan_tag('') end)

--[[

    VISUALS

]]

local visuals = tabs.new('Visuals')

local watermark do
    process('Watermark')
    label('Watermark', visuals)
    local checkbox = ui.new_checkbox(t, l, 'Watermark')
    visuals:add(checkbox)

    local content_data = {}

    local content = {
        Ping = function(x, y, w, h)
            local str = math.floor(client.latency() * 1000) .. tweaks.colors.gray .. 'FF ms'

            local tW, tH = renderer.measure_text('', str)

            local rW, rY = tW + 23, y + (h - 23) / 2 

            content_data['ping'] = content_data['ping'] or {}
            content_data.ping.w = Lerp(globals.frametime() * 10, content_data.ping.w, rW)

            render.rectangle(x, rY, content_data.ping.w, 23, 34, 34, 34, 100, 4)
            --render.edge_v(x, rY, 23, 255)
            if globals.mapname() then renderer.blur(x, rY, content_data.ping.w, 23) end
            renderer.text(x + rW / 2, rY + tH, 255, 255, 255, 255, 'c', content_data.ping.w, str)

            return rW
        end,
        Time = function(x, y, w, h, l)
            local hour, m, s, ms = client.system_time()

            hour, m = string.format('%02d', hour), string.format('%02d', m)

            local str = hour .. tweaks.colors.gray .. 'FF:' .. m

            local tW, tH = renderer.measure_text('', str)

            local rW, rY = tW + 23, y + (h - 23) / 2 

            content_data['time'] = content_data['time'] or {}
            content_data.time.w = Lerp(globals.frametime() * 10, content_data.time.w, rW)

            render.rectangle(x, rY, content_data.time.w, 23, 34, 34, 34, 100, 4)
            --render.edge_v(x, rY, 23, 255)
            if globals.mapname() then renderer.blur(x, rY, content_data.ping.w, 23) end
            renderer.text(x + rW / 2, rY + tH, 255, 255, 255, 255, 'c', content_data.time.w, str)

            return rW
        end,
    }

    
    local _content do _content = {} for i,v in pairs(content) do table.insert(_content, i) end end
    
    
    local container = ui.new_multiselect(t, l, 'Content', unpack(_content))
    visuals:add(container, function() return ui.get(checkbox) end)

    local scrW, scrH = client.screen_size()

    local w, h = 10, 29
    local x, y = scrW - w - 30, h / 2

    local start_w = w

    local widget

    local function compensate() return true end

    local push = function()

        if not widget or not widget.cord_lerp or not widget.cord_lerp.x or not widget.cord or not widget.cord.x then assert('Memory leak! Push cancelled to avoid errors!') return false end

        local x, y, w, h = widget.cord_lerp.x, widget.cord_lerp.y, widget.cord_lerp.w, widget.cord_lerp.h

        local content_ = ui.get(container)
        --if #content_ <= 0 then assert('Container empty! Skip') return false end
        
        local new_w = start_w

        for i,v in ipairs(content_) do
            if type(content[v]) == 'function' then
                local status, err = pcall(content[v], x + new_w - start_w / 2 + 2.5 * i, y, w, h) 

                if not status then 
                    assert(err) 
                else
                    new_w = new_w + err + 5
                end
            end

            ::continue::
        end

        widget.cord.x = Lerp(globals.frametime() * 10, widget.cord.x, widget.cord.x - (new_w - widget.cord.w))
        widget.cord.w = Lerp(globals.frametime() * 10, widget.cord.w, new_w)

        compensate = function()
            ui.set(widget.ui.x, widget.cord.x + widget.cord.w - start_w + (0.625 * (#content_ > 0 and 1 or 0)))
        end

        widget.shutdown = compensate
    end
    
    local push = function() local status, err = pcall(push) if not status then assert(err) end end

    widget = widgets.new(x, y, w, h, 'tweaks-watermark', {x = true, y = true}, nil, 4, compensate)

    widget.paint = false

    ui.set_callback(checkbox, function()
        --if fps < 25 then assert('Low framerate! Render cancelled to avoid memory leaks.') return false end
        local _ = ui.get(checkbox)

        widget.paint = _

        --client[(_ and 'set' or 'unset') .. '_event_callback']('paint_ui', push)
    end)

    client.set_event_callback('paint_ui', push)

    process_end('Watermark')
end


tweaks.print('Processed! '.. tweaks.colors.white ..'(' .. string.format('%.2f', client.timestamp() - tweaks.start) .. 's)')
notifications.new(tweaks.colors.green ..'FF• '.. tweaks.colors.gray ..'FFProcessed! '.. tweaks.colors.white ..'FF' .. string.format('%.2f', client.timestamp() - tweaks.start) .. 's')