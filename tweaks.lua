--[[

        /ᐠ. ｡.ᐟ\ᵐᵉᵒʷˎˊ˗ 
        Made by NeDIAD a.k.a NotDIAD
        https://github.com/NeDIAD/tweaks \ https://github.com/NeDIAD

]]

tweaks = tweaks or {}

local fps = 0
local frameTime = 0

client.set_event_callback('paint', function()
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
    }
}

local ffi = require('ffi')
--local http = require('gamesense/http')

table.clear = require('table.clear')
table.find = function(a, b) for i,v in ipairs(a) do if v == b then return i end end end
table.count = function(a) local r = 0 for i, v in ipairs(a) do r = r + 1 end for i, v in pairs(a) do r = r + 1 end return r end
math.clamp = function(a, b, c) return math.max(b, math.min(c, a)) end

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
    
	return h + ( t - h ) * d 
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
tweaks.start = globals.realtime()
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

        assert('x1, x2, y1, y2, resX, resY: '..' '.. x1..' '.. x2..' '.. y1..' '.. y2..' '.. newX..' '.. newY)
        assert('mX, mY, scrW, scrH: '.. mX ..' '.. mY..' '.. scrW..' '.. scrH)

        if newX < 0 then assert('x < 0') newX = 0 end
        if newY < 0 then assert('y < 0') newY = 0 end
        if newX + w > scrW then assert('x > scr') newX = scrW - w end
        if newY + h > scrH then assert('y > scr') newY = scrH - h end

        return newX, newY
    end

    process_end('Mouse library')
end

--[[local logo = readfile('tweaks_logo.png')

if not logo then
    http.get('https://raw.githubusercontent.com/NeDIAD/tweaks/main/logo.png', function (success, raw)
        if success and string.sub(raw.body, 2, 4) == 'PNG' then
            render.textures.png.logo = renderer.load_png(raw.body, 64, 64)
            writefile('tweaks_logo.png', raw.body)
        end
    end)
else
    render.textures.png.logo = renderer.load_png(readfile('tweaks_logo.png'), 64, 64)
end]]

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
    local active = {}
    local slide = ui.new_slider(t, 'B', 'notification:y_locked', 0, scrW, 700)
    local offsetY = ui.get(slide)
    ui.set_visible(slide, false)

    ui.set_callback(slide, function()
        local slide = ui.get(slide)
        offsetY = slide
    end)

    notifications = {}
    notifications.__index = notifications

    function notifications.new(str, timeout)
        if #active >= 5 then for i,v in ipairs(active) do if not v.disabled then v.disabled = true break end end end

        local self = setmetatable({
            start = globals.realtime(),
            lerp = 0,
            disabled = false,
            tlerp = 0,
            ttarg = 1,
            y = scrH,

        }, notifications)
        timeout = type(timeout) == 'number' and timeout or 5
        str = tostring(str)

        local push = function()

            if globals.realtime() - self.start >= timeout and timeout >= 0 then self.ttarg = 0.01 end
            if self.ttarg == 0.01 and self.tlerp <= .05 then self.disabled = true end

            local w, h = renderer.measure_text('', str)
            w = w + 50 * self.lerp
            h = h + 10
            self.lerp = Lerp(globals.frametime() * 10, self.lerp, self.disabled and 0 or 1)
            self.y = Lerp(globals.frametime() * 10, self.y, self.disabled and scrH or offsetY + ((h + 10) * table.find(active, self)))
            self.tlerp = Lerp(globals.frametime() * 20, self.tlerp, self.ttarg)

            if self.lerp <= .05 and self.disabled then self:destroy() end
            if self.lerp >= .95 and not self.disabled then self.lerp = 1 end

            render.rectangle(scrW / 2 - w / 2, self.y, w, h, 24, 24, 24, 100 * self.lerp, 5)
            renderer.blur(scrW / 2 - w / 2, self.y, w, h)
            render.edge_v(scrW / 2 - w / 2, self.y, h, 255 * self.lerp)

            renderer.text(scrW / 2, self.y + h / 2, 255, 255, 255, 255 * self.tlerp, 'c', w * self.tlerp, str)
        end

        self.push = push

        table.insert(active, self)

        return self
    end

    function notifications:destroy()
        local found = table.find(active, self)
        assert('Remove-notify: '.. found)
        table.remove(active, found)
    end

    local ui_data = {}

    client.set_event_callback('paint', function()
        if fps < 30 then assert('Low framerate! Paint event canceled') return false end
        ui_data.lerp = ui_data.lerp or 0
        ui_data.extra = ui_data.extra or false
        ui_data.lerp = Lerp(globals.frametime() * 15, ui_data.lerp, ui.is_menu_open() and (ui_data.extra and 1 or .1) or 0)


        if (ui_data.lerp or 0) >= .05 then
            local x, y, w, h = scrW / 2 - 300 / 2, offsetY + 22, 300, 32 * 5 + 10
            render.rectangle(x, y, w, h, 200, 200, 200, 100 * ui_data.lerp, 5)


            if #active <= 0 and not ui_data.notify then 
                data = {
                    result = (client.random_int(1, 2) == 1 and true or false),
                    hitgroup = client.random_int(1, #hg - 1),
                    damage = client.random_int(1, 100)
                }

                data.reason = data.result and nil or 'spread'
                ui_data.notify = notifications.new(tweaks.colors[data.result and 'green' or 'red'] .. 'FF• ' .. tweaks.colors.gray .. (data.result and 'FFHit ' or 'FFMissed ') .. tweaks.colors.white .. 'FF' .. 'ekzoterik' .. tweaks.colors.gray .. 'FF\'s ' .. tweaks.colors.white .. 'FF' .. hg[data.hitgroup + 1] .. tweaks.colors.gray .. 'FF ~ ' .. tweaks.colors.white .. 'FF' .. (data.result and data.damage or data.reason), -1) 
            elseif #active > 1 and ui_data.notify then ui_data.notify.ttarg = 0.01 ui_data.notify = nil end

            ui_data.extra = mouse.inbounds(x, y, w, h)

            if mouse.held() and (ui_data.extra or ui_data.allow) then
                if not ui_data.start then ui_data.start = {}; ui_data.start.X, ui_data.start.Y = ui.mouse_position() ui_data.start.Y2 = offsetY end
                local nX, nY = mouse.calc(x, ui_data.start.Y2, ui_data.start.X, ui_data.start.Y, w, h)
                ui_data.allow = true

                assert('nX: '.. nX ..' nY: ' .. nY)
                    
                if nY then
                    ui.set(slide, nY)
                end
            else
                ui_data.allow = false
                ui_data.start = nil
            end
        elseif ui_data.notify then
            ui_data.notify.ttarg = 0.01
            ui_data.notify = nil
        end

        for i,v in ipairs(active) do
            v.push()
        end
    end)

    process_end('Notifications')
end

local function unpack_event(data)
    local victim, attacker = data.userid, data.attacker
    if not victim or not attacker then assert('Event error: Failed to resolve data!') return nil, nil end

    victim, attacker = client.userid_to_entindex(victim), client.userid_to_entindex(attacker)
    return victim, attacker
end

local function label(str) ui.new_label(t, l, tweaks.colors.white .. 'FF • »'.. tweaks.colors.base ..'FF '.. str) end

local function contain(element, needle) return table.find(ui.get(element), needle) end

local misc = tabs.new('Misc')

local filter = ui.new_checkbox(t, l, 'Filter console')
misc:add(filter)

ui.set_callback(filter, function()
    local _ = ui.get(filter)

    cvar.con_filter_enable:set_int(_ and 1 or 0)
	cvar.con_filter_text:set_string(_ and 'tweaks.lua' or '')
end)

local trashtalk do
    process('Trash-talk')
    label('Trash-Talk')

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

            client.exec('say ', string.format(get_phrase('kill'), entity.get_player_name(victim)))
        elseif entity.is_enemy(attacker) and victim == entity.get_local_player() and contain(events, 'Death') then
            assert('Info: Trash talk (death)')

            client.exec('say ', string.format(get_phrase('death'), entity.get_player_name(attacker)))
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
    label('Logger')

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

    client.set_event_callback('aim_fire', function(shot) aim_log[shot.id] = shot end)

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
    label('Clan-tag')

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
    end)
    
    process_end('Clan-tag')
end

local autobuy do
    process('Auto-buy')
    label('Auto-buy')

    local checkbox = ui.new_checkbox(t, l, 'Enable auto-buy')

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

    local push = function()
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

    ui.set_callback(checkbox, function()
        local _ = ui.get(checkbox)

        client[(_ and 'set' or 'unset') .. '_event_callback']('round_freeze_end', push)
    end)

    process_end('Auto-buy')
end

tweaks.print('Processed! '.. tweaks.colors.white ..'(' .. globals.realtime() - tweaks.start .. 's)')
notifications.new(tweaks.colors.green ..'FF• '.. tweaks.colors.gray ..'FFProcessed! '.. tweaks.colors.white ..'FF' .. globals.realtime() - tweaks.start .. 's')