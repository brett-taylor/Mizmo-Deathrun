GM.Name 	= "Deathrun"
GM.Author 	= "Arizard"
GM.Email 	= ""
GM.Website 	= "http://vhs7.tv"

DR.TimeStamp = 1462083778

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE

TEAM_GHOST = 5
TEAM_RUNNER = 3
TEAM_DEATH = 2

function GM:CreateTeams()
	team.SetUp(TEAM_GHOST, "Ghosts", DR.Colors.GhostTeam, false)
	team.SetUp(TEAM_RUNNER, "Runners", DR.Colors.RunnerTeam, false)
	team.SetUp(TEAM_DEATH, "Deaths", DR.Colors.DeathTeam, false)

	team.SetSpawnPoint( TEAM_GHOST, "info_player_counterterrorist" )
	team.SetSpawnPoint( TEAM_DEATH, "info_player_terrorist" )
	team.SetSpawnPoint( TEAM_RUNNER, "info_player_counterterrorist" )

	team.SetColor( TEAM_SPECTATOR, DR.Colors.Silver )
end

function player.GetAllPlaying()
	local pool = {}
	for k,ply in ipairs(player.GetAll()) do
		if ply then
			if ( ply:ShouldStaySpectating() == false ) then
				table.insert(pool, ply)
			end
		end
	end
	return pool
end

hook.Add("SetupMove", "DeathrunDisableSpectatorSpacebar", function( ply, mv, cmd )
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
	end

	if ply:Alive() then
		if ROUND:GetCurrent() == ROUND_PREP then
			--mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )

			local block = hook.Call("DeathrunPreventPreptimeMovement") or true

			if block == true and ply:Team() == TEAM_RUNNER then -- block movement for runners
				mv:SetSideSpeed( 0 )
				mv:SetUpSpeed( 0 )
				mv:SetForwardSpeed( 0 )
			end
		end
	end
end)

function QuadLerp( frac, p1, p2 )

    local y = (p1-p2) * (frac -1)^2 + p2
    return y

end

function InverseLerp( pos, p1, p2 )

	local range = 0
	range = p2-p1

	if range == 0 then return 1 end

	return ((pos - p1)/range)

end

function intToBool( i )
	if tonumber(i) == 0 then
		return false
	else
		return true
	end
end

CreateConVar("deathrun_infinite_ammo", "1", defaultFlags, "Should ammo automatically replenish.")
CreateConVar("deathrun_autojump_velocity_cap", 0, defaultFlags, "The amount to limit players speed to when they use autojump. For game balance. 0 = unlimited")
CreateConVar("deathrun_allow_autojump", 1, defaultFlags, "Allows players to use autojump.")
CreateConVar("deathrun_help_url", "https://github.com/Arizard/deathrun/blob/master/help.md", defaultFlags, "The URL to open when the player types !help.")

-- motd convars
CreateConVar("deathrun_motd_enabled", "1", defaultFlags, "Enable the MOTD to display on all players when they join?")
CreateConVar("deathrun_motd_title", "Deathrun Information", defaultFlags, "The title of the MOTD (i.e. Deathrun Information, !info)")
CreateConVar("deathrun_motd_url", "http://arizard.github.io/deathruninfo.html", defaultFlags, "Sets the MOTD url (i.e. Deathrun Information, !info)")

-- unstuck convar
CreateConVar("deathrun_unstuck_cooldown", "30", defaultFlags, "Set the cooldown timer for when a player uses !stuck or takes damage, forcing them to wait that time until their next !stuck command.")


if SERVER then
	concommand.Add("deathrun_internal_set_autojump", function(ply, cmd, args)
		if args[1] then
			ply.AutoJumpEnabled = intToBool( args[1] )
			--print("Player "..ply:Nick().." set their autojump convar to "..tostring(ply.AutoJumpEnabled))
		end
	end)
end

if CLIENT then
	CreateClientConVar("deathrun_autojump", 1, true, false)
	cvars.AddChangeCallback("deathrun_autojump", function( name, old, new )
		RunConsoleCommand("deathrun_internal_set_autojump", tonumber(new))
		LocalPlayer().AutoJumpEnabled = intToBool( new )
	end, "DeathrunAutoJumpConVarChange")
	
	RunConsoleCommand("deathrun_internal_set_autojump", GetConVar("deathrun_autojump"):GetInt())
	timer.Create("DeathrunAutojumpSendToServer", 5, 0, function()
		RunConsoleCommand("deathrun_internal_set_autojump", GetConVar("deathrun_autojump"):GetInt()) -- in case some trickery happens on the client we'll sync this right up. They can probably destroy the timer but whatever
	end)

	CreateClientConVar("deathrun_spectate_only", 0, true, false)
	cvars.AddChangeCallback( "deathrun_spectate_only", function( name, old, new )
		RunConsoleCommand( "deathrun_set_spectate", new )
	end)

	hook.Add("HUDPaint", "SendSpectateConVarInfo", function()
		RunConsoleCommand( "deathrun_set_spectate", GetConVarNumber( "deathrun_spectate_only" ) )
		if GetConVarNumber( "deathrun_spectate_only" ) == 1 then
			DR:OpenForcedSpectatorMenu( [[You are currently in spectator mode. 
				To play, click on one of the buttons below, 
				or visit the spectator section of the settings menu by pressing F2.
				\n\nWould you like to move back into the game?]] )
		end
		hook.Remove( "HUDPaint", "SendSpectateConVarInfo" )
	end)
end

-- hull sizes

DR.Hulls = {
	HullMin = Vector( -16, -16, 0 ),
	HullDuck = Vector( 16, 16, 43 ),
	HullStand = Vector( 16, 16, 66 ),
	ViewDuck = Vector( 0, 0, 41 ),
	ViewStand = Vector( 0, 0, 64 )
}

if CLIENT then
	concommand.Add("deathrun_reload_hull_client", function()
		DR:SetClientHullSizes()
	end)
	function DR:SetClientHullSizes()
		LocalPlayer():SetHull( DR.Hulls.HullMin, DR.Hulls.HullStand )
		LocalPlayer():SetHullDuck( DR.Hulls.HullMin, DR.Hulls.HullDuck ) -- quack quack
		LocalPlayer():SetViewOffset( DR.Hulls.ViewStand )
		LocalPlayer():SetViewOffsetDucked( DR.Hulls.ViewDuck ) -- quack
	end
end

hook.Add("PlayerSpawn", "HullSizes", function( ply )
	ply:SetHull( DR.Hulls.HullMin, DR.Hulls.HullStand )
	ply:SetHullDuck( DR.Hulls.HullMin, DR.Hulls.HullDuck ) -- quack quack
	ply:SetViewOffset( DR.Hulls.ViewStand )
	ply:SetViewOffsetDucked( DR.Hulls.ViewDuck ) -- quack

	ply:ConCommand( "deathrun_reload_hull_client" )
end)


-- I uh... "borrowed" this from Gravious. I need it but I don't know why.

local lp, ft, ct, cap = LocalPlayer, FrameTime, CurTime
local mc, mr, bn, ba, bo, gf = math.Clamp, math.Round, bit.bnot, bit.band, bit.bor, {}
function GM:Move( ply, data )
	local og = ply:IsFlagSet( FL_ONGROUND )
	if og and not gf[ ply ] then
		gf[ ply ] = 0
	elseif og and gf[ ply ] then
		gf[ ply ] = gf[ ply ] + 1
		if gf[ ply ] > 4 then
			ply:SetDuckSpeed( 0.4 )
			ply:SetUnDuckSpeed( 0.2 )
		end
	end

	if og or not ply:Alive() then return end
	
	gf[ ply ] = 0
	ply:SetDuckSpeed(0)
	ply:SetUnDuckSpeed(0)

	if not IsValid( ply ) then return end
	if lp and ply ~= lp() then return end
	
	if ply:IsOnGround() or not ply:Alive() then return end
	
	local aim = data:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = data:GetForwardSpeed()
	local smove = data:GetSideSpeed()
	
	if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 500 end
	if data:KeyDown( IN_MOVELEFT ) then smove = smove - 500 end
	
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	local wishspeed = wishvel:Length()
	if wishspeed > data:GetMaxSpeed() then
		wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
		wishspeed = data:GetMaxSpeed()
	end

	local wishspd = wishspeed
	wishspd = mc( wishspd, 0, 30 )

	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot( wishdir )

	local addspeed = wishspd - current
	if addspeed <= 0 then return end

	local accelspeed = 1000 * ft() * wishspeed
	if accelspeed > addspeed then
		accelspeed = addspeed
	end
	
	local vel = data:GetVelocity()
	vel = vel + (wishdir * accelspeed)

	ply.SpeedCap = 99999
	
	if ply.SpeedCap and vel:Length2D() > ply.SpeedCap and SERVER then
		local diff = vel:Length2D() - ply.SpeedCap
		vel:Sub( Vector( vel.x > 0 and diff or -diff, vel.y > 0 and diff or -diff, 0 ) )
	end
	
	data:SetVelocity( vel )
	return false
end

-- get rid of some default hooks
hook.Remove("PlayerTick", "TickWidgets")

function DR:GetAccessLevel( ply )
	if not ply or not IsValid( ply ) then
		return 100
	end
	local access = DR.Ranks[ ply:GetUserGroup() ] or 1

	local id64 = ply:SteamID64()
	local id = ply:SteamID()

	if DR.PlayerAccess[id] then
		access = DR.PlayerAccess[id]
	end

	if DR.PlayerAccess[id64] then
		access = DR.PlayerAccess[id64]
	end
	
	return access or 1
end

function DR:CanAccessCommand( ply, cmd )
	local access = DR:GetAccessLevel( ply )
	local perm = DR.Permissions[ cmd ] or 99
	if access >= perm then
		return true
	else
		return false
	end
end
