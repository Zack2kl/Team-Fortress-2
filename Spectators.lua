local shorten = function(s, m)local t,w,c='',0 for i=1,#s do t=t..s:sub(i,i)w=draw.GetTextSize(t)if w>m then c=1 break end end return (c and t:sub(1,#t-2)..'...'or t), w end

local window = gui.Window( 'spectate_window', 'Spectator List', 200, 200, 175, 32 )
local enabled = gui.Checkbox( gui.Reference('Misc', 'Part 3'), 'spectator_list', 'Show Spectators', false )
local hide_list = gui.Checkbox( gui.Reference('Misc', 'Part 3'), 'spectator_list_hide', 'Hide list if not spectated', false )
local fov_change = gui.Slider( gui.Reference('Misc', 'Part 3'), 'spectator_list_fov', 'Reduce FOV', -1, -1, 180 )
local players = {}
local cached = gui.GetValue( 'aim_fov' )
local set, first_person

local obsMode = {
    [4] = 'First person',
    [5] = 'Third person',
    [6] = 'Free look'
}

local getSpectators = function()
    local lpIndex = client.GetLocalPlayerIndex()
	first_person = false

    for _, v in pairs( entities.FindByClass('CTFPlayer') ) do
        local target = v:GetPropEntity('m_hObserverTarget')

        if target and target:GetIndex() == lpIndex then
            local mode = v:GetProp('m_iObserverMode')

            if mode > 0 then
                local name = shorten( v:GetName(), 70 )
                local specmode = obsMode[mode] or 'None'

                if specmode ~= 'None' then
                    players[#players + 1] = { name, specmode }

					if mode == 4 then
						first_person = true
					end
                end
            end
        end
    end
end

callbacks.Register( 'Draw', function()
    if enabled:GetValue() then
        getSpectators()
        window:SetActive( (#players == 0 and hide_list:GetValue()) and false or true )

		local val = fov_change:GetValue()
		if val ~= -1 then
			if first_person then
				gui.SetValue( 'aim_fov', val )
				set = true
			else
				if not set then
					cached = gui.GetValue( 'aim_fov' )
				else
					gui.SetValue( 'aim_fov', cached )
					set = false
				end
			end
		end
    else
        window:SetActive( 0 )
    end
end)

gui.Custom( window, 'spectate_list', 0, 0, 0, 0, function( x, y )
    if not enabled:GetValue() then
        return
    end

    draw.Color( 33, 33, 33, 240 )
    draw.RoundedRectFill( x, y, x + 175, y + 30 + (#players * 25) )

    local rows = { 
        {x=x+5, y=y+5, w=80, h=20, text='Spectator'},
        {x=x+90, y=y+5, w=80, h=20, text='OBS-Mode'}
    }

    for i=1, #rows do
        local row = rows[i]
        local tW, tH = draw.GetTextSize( row.text )

        draw.Color( 66, 66, 66, 255 )
        draw.RoundedRectFill( row.x, row.y, row.x + row.w, row.y + row.h )

        draw.Color( 255, 255, 255, 255 )
        draw.TextShadow( row.x + ( row.w / 2 ) - (tW/2), row.y + (row.h/2) - (tH/2), row.text )
    end

    for i=1, #players do
        local ent = players[i]

        for a=1, 2 do
            local item = ent[a]
            local row = rows[a]

            local tW, tH = draw.GetTextSize( item )
    
            draw.Color( 66, 66, 66, 255 )
            draw.RoundedRectFill( row.x, row.y + ( i * 25 ), row.x + row.w, row.y + row.h + ( i * 25 ) )
    
            draw.Color( 255, 255, 255, 255 )
            draw.TextShadow( row.x + ( row.w / 2 ) - (tW/2), row.y + (row.h/2) - (tH/2) + ( i * 25 ), item )
        end
    end

    players = {}
end)