local ref = gui.Reference( 'VISUALS', 'Filter' )
local mult = gui.Multibox( ref, 'ESPs' )

local ammo_color = gui.ColorEntry( 'clr_esp_box_ammo', 'Box Ammo', 255, 255, 255, 200 )
local health_color = gui.ColorEntry( 'clr_esp_box_health', 'Box Health', 100, 255, 100, 200 )
local sentry_color = gui.ColorEntry( 'clr_esp_box_sentry', 'Box Sentry', 255, 100, 100, 200 )
local sticky_color = gui.ColorEntry( 'clr_esp_circle_sticky', 'Circle Sticky', 255, 255, 255, 255 )

local enemy_enable = gui.Checkbox( mult, 'esp_enemy_box', 'Enemy Box ESP', 0 )
local enemy_name = gui.Checkbox( mult, 'esp_enemy_name', 'Enemy Name ESP', 0 )
local enemy_health = gui.Checkbox( mult, 'esp_enemy_health', 'Enemy Health ESP', 0 )
local enemy_weapon = gui.Checkbox( mult, 'esp_enemy_weapon', 'Enemy Weapon ESP', 0 )

local ammo_enable = gui.Checkbox( mult, 'esp_ammo', 'Ammo ESP', 0 )
local health_enable = gui.Checkbox( mult, 'esp_health', 'Health ESP', 0 )
local sentry_enable = gui.Checkbox( mult, 'esp_sentry', 'Sentry ESP', 0 )
local sticky_enable = gui.Checkbox( mult, 'esp_sticky', 'Sticky ESP', 0 )

callbacks.Register( 'DrawESP', function(b)
	local local_player = entities.GetLocalPlayer()
	local ent = b:GetEntity()
	local X, Y, W, H = b:GetRect()
	local name = ent:GetName()

	if health_enable:GetValue() then
		if name:find( 'Medkit' ) then
			b:Color( health_color:GetValue() )
			draw.OutlinedRect( X, Y, W, H )
		end
	end

	if ammo_enable:GetValue() then
		if name:find( 'Ammopack' ) then
			b:Color( ammo_color:GetValue() )
			draw.OutlinedRect( X, Y, W, H )
		end
	end

	if sticky_enable:GetValue() then
		if name:find( 'Sticky' ) then
			local x, y, z = ent:GetAbsOrigin()
			local X, Y = client.WorldToScreen( x, y, z )
			local _,Y1 = client.WorldToScreen( x, y, z - 2.3 )
			local _,Y2 = client.WorldToScreen( x, y, z + 2.3 )
			local r = math.abs( Y2 - Y1 ) * 0.5

			b:Color( sticky_color:GetValue() )
			draw.OutlinedCircle( X, Y, r )
		end
	end

	if ent:GetTeamNumber() ~= local_player:GetTeamNumber() then
		local health = ent:GetHealth()
		local health_percent = math.min( 1, health / ent:GetMaxHealth() )
		local c = 255 * health_percent

		if sentry_enable:GetValue() then
			if name:find( 'Sentrygun' ) then
				b:AddTextTop( name )

				b:Color( -c, c, 0, 250 )
				b:AddBarBottom( health_percent )

				b:Color( sentry_color:GetValue() )
				draw.OutlinedRect(X, Y, W, H)
			end
		end

		if ent:GetClass() == 'CTFPlayer' then
			if enemy_enable:GetValue() then
				b:Color( 255, 100, 100, 255 )
				draw.RoundedRect( X, Y, W, H )
			end

			if enemy_name:GetValue() then
				b:Color( 255, 255, 255, 255 )
				b:AddTextTop( name )
			end

			if enemy_weapon:GetValue() then
				local weapon = ent:GetPropEntity( 'm_hActiveWeapon' )

				if weapon then
					b:Color( 255, 255, 255, 255 )
					b:AddTextBottom( weapon:GetName() )
				end
			end

			if enemy_health:GetValue() then
				draw.Text( X - 28, Y - 3, health )
				b:Color( -c, c, 0, 250 )
				b:AddBarLeft( health_percent )
			end
		end
	end
end)