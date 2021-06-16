untyped

global function ClMainHud_Init

global function InitChatHUD
global function UpdateChatHUDVisibility

global function MainHud_AddClient
global function SetCrosshairPriorityState
global function ClearCrosshairPriority
global function UpdateMainHudVisibility
global function ServerCallback_Announcement
global function ClientCodeCallback_ControllerModeChanged
global function UpdateMainHudFromCEFlags
global function UpdatePlayerStatusCounts
//global function ScoreBarsTitanCountThink
global function UpdateCoreFX
global function InitCrosshair

global function IsWatchingReplay

global function RodeoAlert_FriendlyGaveBattery
global function RodeoAlert_YouGaveBattery

global const MAX_ACTIVE_TRAPS_DISPLAYED = 5
global const VGUI_CLOSED = 0
global const VGUI_CLOSING = 1
global const VGUI_OPEN = 2
global const VGUI_OPENING = 3

global const USE_AUTO_TEXT = 1
global const SHIELD_R = 176
global const SHIELD_G = 227
global const SHIELD_B = 227

global const TEAM_ICON_IMC = $"ui/scoreboard_imc_logo"
global const TEAM_ICON_MILITIA = $"ui/scoreboard_mcorp_logo"

const float OFFHAND_ALERT_ICON_ANIMRATE = 0.35
const float OFFHAND_ALERT_ICON_SCALE = 4.5

const bool ALWAYS_SHOW_BOOST_MOBILITY_BAR = true


struct
{
	table      crosshairPriorityLevel
	array<int> crosshairPriorityOrder

	int iconIdx = 0

	var  rodeoRUI //Primarily because cl_rodeo_titan needs to update the rodeo rui
	bool trackingDoF = false
} file

void function ClMainHud_Init()
{
	if ( IsMenuLevel() )
		return

	PrecacheHUDMaterial( TEAM_ICON_IMC )
	PrecacheHUDMaterial( TEAM_ICON_MILITIA )

	//PrecacheHUDMaterial( $"vgui/HUD/ctf_base_freindly" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_friendly_held" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_friendly_away" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_base_enemy" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_enemy_away" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_enemy_held" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_friendly_notext" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_enemy_notext" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_friendly_missing" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_friendly_minimap" )
	//PrecacheHUDMaterial( $"vgui/HUD/ctf_flag_enemy_minimap" )
	//PrecacheHUDMaterial( $"vgui/HUD/overhead_shieldbar_burn_card_indicator" )
	//PrecacheHUDMaterial( $"ui/icon_status_burncard_friendly" )
	//PrecacheHUDMaterial( $"ui/icon_status_burncard_enemy" )
	//PrecacheHUDMaterial( $"vgui/HUD/riding_icon_enemy" )
	//PrecacheHUDMaterial( $"vgui/HUD/riding_icon_friendly" )

	//PrecacheHUDMaterial( $"vgui/hud/titan_build_bar" )
	//PrecacheHUDMaterial( $"vgui/hud/titan_build_bar_bg" )
	//PrecacheHUDMaterial( $"vgui/hud/titan_build_bar_change" )
	//PrecacheHUDMaterial( $"vgui/hud/hud_bar_small" )
	//PrecacheHUDMaterial( $"vgui/hud/shieldbar_health" )
	//PrecacheHUDMaterial( $"vgui/hud/shieldbar_health_change" )
	//PrecacheHUDMaterial( $"vgui/hud/titan_doomedbar_fill" )
	//PrecacheHUDMaterial( $"vgui/hud/hud_hex_progress_timer" )
	//PrecacheHUDMaterial( $"vgui/hud/hud_hex_progress_hollow_round" )
	//PrecacheHUDMaterial( $"vgui/hud/hud_hex_progress_hollow_round_bg" )
	//PrecacheHUDMaterial( $"vgui/hud/hud_bar" )
	//PrecacheHUDMaterial( $"vgui/hud/corebar_health" )
	//PrecacheHUDMaterial( $"vgui/hud/corebar_bg" )

	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_orange_a" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_orange_b" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_orange_c" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_blue_a" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_blue_b" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_blue_c" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_grey_a" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_grey_b" )
	//PrecacheHUDMaterial( $"vgui/HUD/capture_point_status_grey_c" )

	RegisterSignal( "UpdateTitanCounts" )
	RegisterSignal( "MainHud_TurnOn" )
	RegisterSignal( "MainHud_TurnOff" )
	RegisterSignal( "UpdateWeapons" )
	RegisterSignal( "ResetWeapons" )
	RegisterSignal( "UpdateShieldBar" )
	RegisterSignal( "PlayerUsedAbility" )
	RegisterSignal( "UpdateTitanBuildBar" )
	RegisterSignal( "ControllerModeChanged" )
	RegisterSignal( "ActivateTitanCore" )
	RegisterSignal( "AttritionPoints" )
	RegisterSignal( "AttritionPopup" )
	RegisterSignal( "UpdateLastTitanStanding" )
	RegisterSignal( "UpdateMobilityBarVisibility" )
	RegisterSignal( "UpdateFriendlyRodeoTitanShieldHealth" )
	RegisterSignal( "DisableShieldBar" )
	RegisterSignal( "MonitorGrappleMobilityBarState" )
	RegisterSignal( "StopBossIntro" )
	RegisterSignal( "ClearDoF" )

	AddCreateCallback( "titan_cockpit", CockpitHudInit )

	AddCallback_OnRodeoStarting( OnRodeoStarting )
	AddCallback_OnRodeoEnded( OnRodeoEnded )

	RegisterServerVarChangeCallback( "gameState", UpdateMainHudFromGameState )
	AddCallback_OnPlayerLifeStateChanged( UpdateMainHudFromLifeState )
	RegisterServerVarChangeCallback( "minimapState", UpdateMinimapVisibility )

	AddCinematicEventFlagChangedCallback( CE_FLAG_EMBARK, CinematicEventUpdateDoF )
	AddCinematicEventFlagChangedCallback( CE_FLAG_EXECUTION, CinematicEventUpdateDoF )

	StatusEffect_RegisterEnabledCallback( eStatusEffect.titan_damage_amp, DamageAmpEnabled )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.titan_damage_amp, DamageAmpDisabled )

	StatusEffect_RegisterEnabledCallback( eStatusEffect.damageAmpFXOnly, DamageAmpEnabled )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.damageAmpFXOnly, DamageAmpDisabled )

	StatusEffect_RegisterEnabledCallback( eStatusEffect.emp, ScreenEmpEnabled )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.emp, ScreenEmpDisabled )

	AddCallback_OnSettingsUpdated( UpdateShowButtonHintsConvarCache )
	AddCallback_OnSettingsUpdated( UpdateAccessibilityChatHintEnabledCache )
	UpdateShowButtonHintsConvarCache()
	UpdateAccessibilityChatHintEnabledCache()
}


void function MainHud_AddClient( entity player )
{
	player.cv.burnCardAnnouncementActive <- false
	player.cv.burnCardAnnouncementQueue <- []

	clGlobal.empScreenEffect = Hud.HudElement( "EMPScreenFX" )

	thread ClientHudInit( player )
}


void function CockpitHudInit( entity cockpit )
{
	entity player = GetLocalViewPlayer()

	asset cockpitModelName = cockpit.GetModelName()
	if ( IsHumanCockpitModelName( cockpitModelName ) )
	{
		thread PilotMainHud( cockpit, player )
		cockpit.SetCaptureScreenBeforeViewmodels( true )
	}
	else if ( IsTitanCockpitModelName( cockpitModelName ) )
	{
		thread TitanMainHud( cockpit, player )
		cockpit.SetCaptureScreenBeforeViewmodels( false )
	}
	else
	{
		cockpit.SetCaptureScreenBeforeViewmodels( false )
	}
}


void function PilotMainHud( entity cockpit, entity player )
{
	entity mainVGUI = Create_Hud( "vgui_fullscreen_pilot", cockpit, player )
	cockpit.e.mainVGUI = mainVGUI
	local panel = mainVGUI.s.panel

	table warpSettings = expect table( mainVGUI.s.warpSettings )
	panel.WarpGlobalSettings( expect float( warpSettings.xWarp ), 0, expect float( warpSettings.yWarp ), 0, expect float( warpSettings.viewDist ) )
	panel.WarpEnable()
	mainVGUI.s.enabledState <- VGUI_CLOSED
	thread MainHud_TurnOff_RUI( true )

	HideFriendlyIndicatorAndCrosshairNames()

	cockpit.s.coreFXHandle <- null
	cockpit.s.pilotDamageAmpFXHandle <- null

	UpdateMainHudVisibility( player )
	//#if TITANS_CLASSIC_GAMEPLAY
		//thread TitanBuildBarThink( cockpit, player )
		//thread RodeoRideThink( cockpit, player )

		//UpdateTitanModeHUD( player )
	//#endif

	if ( player == GetLocalClientPlayer() )
	{
		delaythread( 1.0 ) AnnouncementProcessQueue( player )
	}

	foreach ( callbackFunc in clGlobal.pilotHudCallbacks )
	{
		callbackFunc( cockpit, player )
	}

	cockpit.WaitSignal( "OnDestroy" )

	mainVGUI.Destroy()
}


void function TitanMainHud( entity cockpit, entity player )
{
	//TitanBindings bindings = GetTitanBindings()
	//if ( RegisterTitanBindings( player, bindings ) )
	//{
	//	OnThreadEnd(
	//		function () : ( cockpit, bindings )
	//		{
	//			cockpit.e.mainVGUI.Destroy()
	//			DeregisterTitanBindings( bindings )
	//		}
	//	)
	//}
	//else
	{
		OnThreadEnd(
			function () : ( cockpit )
			{
				cockpit.e.mainVGUI.Destroy()
			}
		)
	}

	entity mainVGUI = Create_Hud( "vgui_fullscreen_titan", cockpit, player )
	cockpit.e.mainVGUI = mainVGUI
	var panel = mainVGUI.s.panel

	cockpit.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	table warpSettings = expect table( mainVGUI.s.warpSettings )
	panel.WarpGlobalSettings( expect float( warpSettings.xWarp ), 0.0, expect float( warpSettings.yWarp ), 0.0, expect float( warpSettings.viewDist ) )
	panel.WarpEnable()
	mainVGUI.s.enabledState <- VGUI_CLOSED
	thread MainHud_TurnOff_RUI( true )

	cockpit.s.coreFXHandle <- null
	cockpit.s.titanDamageAmpFXHandle <- null

	cockpit.s.forceFlash <- false

	//thread TitanBuildBarThink( cockpit, player )

	local settings = player.GetPlayerSettings()
	Assert( player.IsTitan() || settings == "pilot_titan_cockpit", "player has titan settings but is not a titan" )

	thread RodeoAlertThink( cockpit, player )

	UpdateCoreFX( player )
	UpdateTitanDamageAmpFX( player )

	// delay hud display until cockpit boot sequence completes
	//while ( IsValid( cockpit ) && TitanCockpit_IsBooting( cockpit ) )
	//	WaitFrame()

	if ( IsValid( cockpit ) )
	{
		level.EMP_vguis.append( mainVGUI )

		if ( player == GetLocalClientPlayer() )
		{
			delaythread( 1.0 ) AnnouncementProcessQueue( player )
		}

		UpdateMainHudVisibility( player )
		//UpdateTitanModeHUD( player )

		foreach ( callbackFunc in clGlobal.titanHudCallbacks )
		{
			callbackFunc( cockpit, player )
		}

		WaitForever()
	}
}


void function DamageAmpEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent.IsTitan() )
		UpdateTitanDamageAmpFX( GetLocalPlayerFromSoul( ent ) )
	else
		UpdatePilotDamageAmpFX( ent )
}


void function DamageAmpDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent.IsTitan() )
		UpdateTitanDamageAmpFX( GetLocalPlayerFromSoul( ent ) )
	else
		UpdatePilotDamageAmpFX( ent )
}


void function UpdatePilotDamageAmpFX( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	entity cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	if ( !("pilotDamageAmpFXHandle" in cockpit.s) )
		return

	if ( cockpit.s.pilotDamageAmpFXHandle && EffectDoesExist( cockpit.s.pilotDamageAmpFXHandle ) )
	{
		EffectStop( cockpit.s.pilotDamageAmpFXHandle, false, true ) // stop particles, play end cap
	}

	if ( StatusEffect_GetSeverity( player, eStatusEffect.damageAmpFXOnly ) > 0 )
	{
		cockpit.s.pilotDamageAmpFXHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( $"P_core_DMG_boost_screen" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	}
}


void function UpdateTitanDamageAmpFX( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	entity cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	if ( !("titanDamageAmpFXHandle" in cockpit.s) )
		return

	if ( cockpit.s.titanDamageAmpFXHandle && EffectDoesExist( cockpit.s.titanDamageAmpFXHandle ) )
	{
		EffectStop( cockpit.s.titanDamageAmpFXHandle, false, true ) // stop particles, play end cap
	}

	entity soul = player.GetTitanSoul()
	if ( IsValid( soul ) && (StatusEffect_GetSeverity( soul, eStatusEffect.damageAmpFXOnly ) + StatusEffect_GetSeverity( soul, eStatusEffect.titan_damage_amp )) > 0 )
	{
		cockpit.s.titanDamageAmpFXHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( $"P_core_DMG_boost_screen" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	}
}


void function ScreenEmpEnabled( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread EmpStatusEffectThink( player )
}


void function ScreenEmpDisabled( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	clGlobal.empScreenEffect.Hide()
}


void function EmpStatusEffectThink( entity player )
{
	clGlobal.empScreenEffect.Show()
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ()
		{
			clGlobal.empScreenEffect.Hide()
		}
	)

	while ( true )
	{
		float effectFrac = StatusEffect_GetSeverity( player, eStatusEffect.emp )

		clGlobal.empScreenEffect.SetAlpha( effectFrac * 255 )

		WaitFrame()
	}
}


void function UpdateCoreFX( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	entity cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	if ( cockpit.s.coreFXHandle && EffectDoesExist( cockpit.s.coreFXHandle ) )
	{
		EffectStop( cockpit.s.coreFXHandle, false, true ) // stop particles, play end cap
	}

	if ( PlayerShouldHaveCoreScreenFX( player ) )
	{
		cockpit.s.coreFXHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( $"P_core_DMG_boost_screen" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	}
}


bool function PlayerShouldHaveCoreScreenFX( entity player )
{
	return false
}


void function OnRodeoStarting( entity rider, entity vehicle )
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( rider == localViewPlayer || vehicle == localViewPlayer )
	{
		localViewPlayer.Signal( "UpdateRodeoAlert" )
	}
}


void function OnRodeoEnded( entity rider, entity vehicle )
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( rider == localViewPlayer || vehicle == localViewPlayer )
	{
		localViewPlayer.Signal( "UpdateRodeoAlert" )
	}
}


void function RodeoAlertThink( entity cockpit, entity player )
{
	cockpit.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	var rui = CreateCockpitRui( $"ui/rodeo_display.rpak" )
	file.rodeoRUI = rui
	RuiSetVisible( rui, false )
	RuiSetBool( rui, "isCockpit", true )
	RuiSetBool( rui, "isUsingLargeMinimap", Minimap_IsUsingLargeMinimap() )

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroy( rui )
			file.rodeoRUI = null
		}
	)

	bool currentlyVisible = false
	for ( ; ; )
	{
		entity soul = player.GetTitanSoul()
		if ( !IsValid( soul ) )
		{
			//HidePlayerHint( "#HUD_TITAN_DISEMBARK" ) // this shouldn't be here?
			RuiSetVisible( rui, false )
			WaitFrame()
			continue
		}

		array<entity> riderList = RodeoState_GetPlayersRodeingVehicle( soul.GetTitan() )
		if ( riderList.len() > 0 )
		{
			if ( !currentlyVisible )
			{
				//RuiTrackFloat( rui, "healthFrac", titan, RUI_TRACK_HEALTH )
				RuiSetFloat( rui, "healthFrac", 0.0 )
				RuiSetGameTime( rui, "startTime", Time() )

				string allNamesStr = ""
				foreach ( int riderIndex, entity rider in riderList )
				{
					// todo(dw): fix rodeo alert UI
					string riderLabel = rider.IsPlayer() ? rider.GetPlayerName() : rider.GetTitleForUI()
					allNamesStr += (riderIndex == 0 ? "" : ", ") + riderLabel
				}
				RuiSetImage( rui, "statusIcon", $"rui/hud/common/rodeo_icon_friendly" )
				RuiSetString( rui, "playerName", allNamesStr )
				RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_PASSENGER" ) )
				RuiSetBool( rui, "isEnemy", false )

				//HidePlayerHint( "#RODEO_ANTI_RODEO_SMOKE_HINT" )
				//RuiSetImage( rui, "statusIcon", $"rui/hud/common/rodeo_icon_enemy" )
				//RuiSetString( rui, "playerName", rider.GetPlayerName() )
				//RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_ALERT" ) )
				//RuiSetBool( rui, "isEnemy", true )
				//
				//if ( player.GetOffhandWeapon( OFFHAND_INVENTORY ) )
				//	AddPlayerHint( 2.0, 0.25, $"", "#RODEO_ANTI_RODEO_SMOKE_HINT" )

				RuiSetVisible( rui, true )
			}
		}
		else if ( currentlyVisible )
		{
			RuiSetVisible( rui, false )
			//HidePlayerHint( "#RODEO_ANTI_RODEO_SMOKE_HINT" )
		}

		player.WaitSignal( "UpdateRodeoAlert" )
	}
}


void function RodeoAlert_FriendlyGaveBattery()
{
	if ( file.rodeoRUI == null )
		return

	RuiSetGameTime( file.rodeoRUI, "batteryGivenStartTime", Time() )
	RuiSetString( file.rodeoRUI, "pilotGaveBattery", Localize( "#RODEO_PILOT_APPLIED_BATTERY_TO_YOU_RUI_TEXT" ) )
}


void function RodeoAlert_YouGaveBattery()
{
	if ( file.rodeoRUI == null )
		return

	printt( "file.rodeoRui != null, setting stuff" )

	RuiSetGameTime( file.rodeoRUI, "batteryGivenStartTime", Time() )
	RuiSetString( file.rodeoRUI, "youGaveBattery", Localize( "#RODEO_PILOT_APPLIED_BATTERY_TO_YOU_RUI_TEXT" ) )

	Signal( GetLocalViewPlayer(), "UpdateRodeoAlert" )
}


//bool function ShouldHideAntiRodeoHint( entity player )
//{
//	if ( GetDoomedState( player ) )
//		return true
//
//	if ( IsDisplayingEjectInterface( player ) )
//		return true
//
//	return false
//}


//void function RodeoRideThink( entity cockpit, entity player )
//{
//	cockpit.EndSignal( "OnDestroy" )
//	player.EndSignal( "OnDestroy" )
//
//	var rui = CreateCockpitRui( $"ui/rodeo_display.rpak" )
//	RuiSetBool( rui, "isUsingLargeMinimap", Minimap_IsUsingLargeMinimap() )
//	file.rodeoRUI = rui
//	RuiSetVisible( rui, false )
//
//	OnThreadEnd(
//		function() : ( rui )
//		{
//			RuiDestroy( rui )
//			file.rodeoRUI = null
//		}
//	)
//
//	for ( ; ; )
//	{
//		table results = WaitSignal( player, "UpdateRodeoAlert" )
//
//		if ( !DidUpdateRodeoRideNameAndIcon( cockpit, player, rui ) )
//		{
//			RuiSetVisible( rui, false )
//		}
//	}
//}


bool function DidUpdateRodeoRideNameAndIcon( entity cockpit, entity player, var rui )
{
	if ( !RodeoState_GetIsPlayerRodeoing( player ) )
		return false

	entity titan = RodeoState_GetPlayerCurrentRodeoVehicle( player )
	if ( !titan.IsTitan() )
		return false

	string name = GetTitanName( titan )
	string text

	RuiSetBool( rui, "isDoomed", titan.IsTitan() ? titan.GetTitanSoul().IsDoomed() : false )
	RuiSetInt( rui, "maxHealth", titan.GetMaxHealth() )
	RuiSetInt( rui, "healthPerSection", HEALTH_PER_HEALTH_BAR_SEGMENT )

	if ( titan.GetMaxHealth() > 25000 )
	{
		RuiSetInt( rui, "healthPerSection", int( titan.GetMaxHealth() / 10.0 ) )
	}

	if ( IsFriendlyTeam( titan.GetTeam(), player.GetTeam() ) )
	{
		RuiSetImage( rui, "statusIcon", $"rui/hud/common/rodeo_icon_friendly" )
		string playerName
		if ( titan.IsPlayer() )
			playerName = titan.GetPlayerName()
		else
			playerName = titan.GetBossPlayerName()

		RuiSetString( rui, "playerName", playerName )
		RuiSetBool( rui, "isEnemy", false )

		if ( !titan.IsPlayer() )
			RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_RIDER_FRIENDLY_AUTO_TITAN" ) )
		else
			RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_RIDER_FRIENDLY" ) )
	}
	else
	{
		RuiSetImage( rui, "statusIcon", $"rui/hud/common/rodeo_icon_enemy" )
		string playerName
		if ( titan.IsPlayer() )
			playerName = titan.GetPlayerName()
		else
			playerName = titan.GetBossPlayerName()

		RuiSetString( rui, "playerName", playerName )
		RuiSetBool( rui, "isEnemy", true )

		if ( !titan.IsPlayer() )
		{
			if ( IsPetTitan( titan ) )
			{
				RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_RIDER_ENEMY_AUTO_TITAN" ) )
			}
			else
			{
				if ( titan.GetTitleForUI() == "" )
				{
					RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_RIDER_ENEMY" ) )
				}
				else
				{
					RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_RIDER_ENEMY_TITLE", titan.GetTitleForUI() ) )
				}
			}
		}
		else
		{
			RuiSetString( rui, "statusText", Localize( "#HUD_RODEO_RIDER_ENEMY" ) )
		}
	}

	RuiTrackFloat( rui, "healthFrac", titan, RUI_TRACK_HEALTH )
	RuiTrackFloat( rui, "shieldFrac", titan, RUI_TRACK_SHIELD_FRACTION )
	RuiSetVisible( rui, true )

	return true
}


string function GetTitanName( entity titan )
{
	if ( titan.IsPlayer() )
		return titan.GetPlayerName()

	if ( IsValid( titan.GetBossPlayer() ) )
		return titan.GetBossPlayerName()

	return titan.GetTitleForUI()
}


//void function TitanBuildBarThink( entity cockpit, entity player )
//{
//	cockpit.EndSignal( "OnDestroy" )
//	player.EndSignal( "OnDestroy" )
//	player.EndSignal( "SettingsChanged" )
//
//	bool isTitanCockpit = IsTitanCockpitModelName( cockpit.GetModelName() )
//	if ( !isTitanCockpit )
//		return
//
//	if ( isTitanCockpit )
//	{
//		// bail out if we're getting ripped out of the cockpit
//		if ( !player.IsTitan() )
//			return
//
//		if ( !IsAlive( player ) )
//			return
//
//		entity soul = player.GetTitanSoul()
//		LinkCoreHint( soul )
//	}
//
//	float previousCharge            = 0.0
//	float previousDisplayedDelta    = 0.0
//	float previousDisplayTime       = 0.0
//	float previousChargeDelta       = 0.0
//	float previousCoreAvailableFrac = 0.0
//	float displayDelta              = 0.0
//
//	player.s.lastCoreReadyMessageTime <- -9999
//	float lastCoreAvailableFrac = 0.0
//
//	for ( ; ; )
//	{
//		entity soul = player.GetTitanSoul()
//
//		if ( IsAlive( player.GetPetTitan() ) || IsWatchingReplay() || !IsValid( soul ) )
//		{
//			player.WaitSignal( "UpdateTitanBuildBar" )
//			continue
//		}
//
//		float coreAvailableFrac = soul.GetTitanSoulNetFloat( "coreAvailableFrac" )
//
//		if ( coreAvailableFrac >= 1.0 )
//		{
//			DoCoreHint( player, lastCoreAvailableFrac < 1.0 )
//		}
//
//		lastCoreAvailableFrac = coreAvailableFrac
//
//		player.WaitSignal( "UpdateTitanBuildBar" )
//	}
//}


entity function Create_Hud( string cockpitType, entity cockpit, entity player )
{
	string attachment = "CAMERA_BASE"
	int attachId      = cockpit.LookupAttachment( attachment )

	vector origin = <0, 0, 0>
	vector angles = <0, 0, 0>

	origin += AnglesToForward( angles ) * COCKPIT_UI_XOFFSET
	table warpSettings = {
		xWarp = 42.0
		xScale = 1.22
		yWarp = 30.0
		yScale = 0.96
		viewDist = 1.0
	}

	origin += AnglesToRight( angles ) * (-COCKPIT_UI_WIDTH / 2)
	origin += AnglesToUp( angles ) * (-COCKPIT_UI_HEIGHT / 2)

	angles = AnglesCompose( angles, <0, -90, 90> )

	entity vgui = CreateClientsideVGuiScreen( cockpitType, VGUI_SCREEN_PASS_COCKPIT, origin, angles, COCKPIT_UI_WIDTH, COCKPIT_UI_HEIGHT )
	vgui.s.panel <- vgui.GetPanel()
	vgui.s.baseOrigin <- origin
	vgui.s.warpSettings <- warpSettings

	vgui.SetParent( cockpit, attachment )
	vgui.SetAttachOffsetOrigin( origin )
	vgui.SetAttachOffsetAngles( angles )

	return vgui
}


void function UpdateMinimapVisibility()
{
	entity player = GetLocalClientPlayer()

	if ( IsWatchingReplay() )
	{
		return
	}
	Minimap_UpdateMinimapVisibility( GetLocalViewPlayer() )
}


void function UpdatePlayerStatusCounts()
{
	if ( !GetCurrentPlaylistVarInt( "hud_score_enabled", 1 ) )
		return

	clGlobal.levelEnt.Signal( "UpdatePlayerStatusCounts" ) //For Pilot Elimination based modes
	clGlobal.levelEnt.Signal( "UpdateTitanCounts" ) //For all modes
}


void function UpdateMainHudFromCEFlags( entity player )
{
	UpdateMainHudVisibility( player )
}


void function UpdateMainHudFromGameState()
{
	entity player = GetLocalViewPlayer()
	UpdateMainHudVisibility( player, 1.0 )
}


void function UpdateMainHudFromLifeState( entity player, int oldLifeState, int newLifeState )
{
	if ( player != GetLocalClientPlayer() && player != GetLocalViewPlayer() )
		return

	UpdateMainHudVisibility( player, 1.0 )
}


void function UpdateMainHudVisibility( entity player, float duration = 0.0 )
{
	int ceFlags                   = player.GetCinematicEventFlags()
	bool shouldBeVisible          = ShouldMainHudBeVisible( player )
	bool shouldBeVisiblePermanent = ShouldPermanentHudBeVisible( player )

	if ( shouldBeVisible )
		ShowFriendlyIndicatorAndCrosshairNames()
	else
		HideFriendlyIndicatorAndCrosshairNames()

	entity cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	entity mainVGUI = cockpit.e.mainVGUI
	if ( !mainVGUI )
		return

	local isVisible = (mainVGUI.s.enabledState == VGUI_OPEN) || (mainVGUI.s.enabledState == VGUI_OPENING)

	if ( !shouldBeVisible )
		thread MainHud_TurnOff_RUI( !isVisible )
	else
		thread MainHud_TurnOn_RUI()

	if ( isVisible && !shouldBeVisible )
	{
		table warpSettings = expect table( mainVGUI.s.warpSettings )
		if ( duration <= 0 )
		{
			duration = 0.0
			if ( ceFlags & CE_FLAG_EMBARK )
				duration = 1.0
			else if ( ceFlags & CE_FLAG_DISEMBARK )
				duration = 0.0
		}

		thread MainHud_TurnOff( mainVGUI, duration, expect float( warpSettings.xWarp ), expect float( warpSettings.xScale ), expect float( warpSettings.yWarp ), expect float( warpSettings.yScale ), expect float( warpSettings.viewDist ) )
	}
	else if ( !isVisible && shouldBeVisible )
	{
		//printt( "turn on" )
		table warpSettings = expect table( mainVGUI.s.warpSettings )

		if ( duration <= 0 )
			duration = 1.0

		thread MainHud_TurnOn( mainVGUI, duration, expect float( warpSettings.xWarp ), expect float( warpSettings.xScale ), expect float( warpSettings.yWarp ), expect float( warpSettings.yScale ), expect float( warpSettings.viewDist ) )
	}

	if ( shouldBeVisiblePermanent )
		ShowPermanentHudTopo()
	else
		HidePermanentHudTopo()
}


void function MainHud_TurnOn( entity vgui, float duration, float xWarp, float xScale, float yWarp, float yScale, float viewDist )
{
	vgui.EndSignal( "OnDestroy" )

	vgui.Signal( "MainHud_TurnOn" )
	vgui.EndSignal( "MainHud_TurnOn" )
	vgui.EndSignal( "MainHud_TurnOff" )

	if ( vgui.s.enabledState == VGUI_OPEN || vgui.s.enabledState == VGUI_OPENING )
		return

	vgui.s.enabledState = VGUI_OPENING

	//vgui.s.panel.WarpGlobalSettings( xWarp, xScale, yWarp, yScale, viewDist )

	if ( !IsWatchingReplay() )
	{
		vgui.s.panel.WarpGlobalSettings( xWarp, 0, yWarp, 0, viewDist )
		//vgui.SetSize( vgui.s.baseSize[0] * 0.001, vgui.s.baseSize[1] * 0.001 )

		float xTimeScale = 0
		float yTimeScale = 0
		float startTime  = Time()

		while ( yTimeScale < 1.0 )
		{
			xTimeScale = expect float( Anim_EaseIn( GraphCapped( Time() - startTime, 0.0, duration / 2, 0.0, 1.0 ) ) )
			yTimeScale = expect float( Anim_EaseIn( GraphCapped( Time() - startTime, duration / 4, duration, 0.01, 1.0 ) ) )

			//vector scaledSize = <vgui.s.baseSize[0] * xTimeScale, vgui.s.baseSize[1] * yTimeScale, 0>
			//vgui.SetAttachOffsetOrigin( vgui.s.baseOrigin )
			//vgui.SetSize( scaledSize.x, scaleSize.y )
			vgui.s.panel.WarpGlobalSettings( xWarp, xScale * xTimeScale, yWarp, yScale * yTimeScale, viewDist )
			WaitFrame()
		}
	}

	//vgui.SetSize( vgui.s.baseSize[0], vgui.s.baseSize[1] )
	vgui.s.panel.WarpGlobalSettings( xWarp, xScale, yWarp, yScale, viewDist )
	vgui.s.enabledState = VGUI_OPEN
}


void function MainHud_TurnOn_RUI( bool instant = false )
{
	clGlobal.levelEnt.Signal( "MainHud_TurnOn" )
	clGlobal.levelEnt.EndSignal( "MainHud_TurnOn" )
	clGlobal.levelEnt.EndSignal( "MainHud_TurnOff" )

	UpdateFullscreenTopology( clGlobal.topoFullscreenHud, true )
}


void function MainHud_TurnOff( entity vgui, float duration, float xWarp, float xScale, float yWarp, float yScale, float viewDist )
{
	vgui.EndSignal( "OnDestroy" )

	vgui.Signal( "MainHud_TurnOff" )
	vgui.EndSignal( "MainHud_TurnOff" )
	vgui.EndSignal( "MainHud_TurnOn" )

	if ( vgui.s.enabledState == VGUI_CLOSED || vgui.s.enabledState == VGUI_CLOSING )
		return

	vgui.s.enabledState = VGUI_CLOSING

	vgui.s.panel.WarpGlobalSettings( xWarp, xScale, yWarp, yScale, viewDist )
	//vgui.SetSize( vgui.s.baseSize[0], vgui.s.baseSize[1] )

	float xTimeScale = 1.0
	float yTimeScale = 1.0
	float startTime  = Time()

	while ( xTimeScale > 0.0 )
	{
		xTimeScale = expect float( Anim_EaseOut( GraphCapped( Time() - startTime, duration * 0.1, duration, 1.0, 0.0 ) ) )
		yTimeScale = expect float( Anim_EaseOut( GraphCapped( Time() - startTime, 0.0, duration * 0.5, 1.0, 0.01 ) ) )

		//vgui.SetSize( vgui.s.baseSize[0] * xTimeScale, vgui.s.baseSize[1] * yTimeScale )
		vgui.s.panel.WarpGlobalSettings( xWarp, xScale * xTimeScale, yWarp, yScale * yTimeScale, viewDist )
		WaitFrame()
	}

	//vgui.SetSize( vgui.s.baseSize[0] * 0.001, vgui.s.baseSize[1] * 0.001 )
	vgui.s.panel.WarpGlobalSettings( xWarp, 0, yWarp, 0, viewDist )

	vgui.s.enabledState = VGUI_CLOSED
}


void function MainHud_TurnOff_RUI( bool instant = false )
{
	clGlobal.levelEnt.Signal( "MainHud_TurnOff" )
	clGlobal.levelEnt.EndSignal( "MainHud_TurnOff" )
	clGlobal.levelEnt.EndSignal( "MainHud_TurnOn" )

	UISize screenSize              = GetScreenSize()
	UISize scaledVirtualScreenSize = GetScaledVirtualScreenSize( GetCurrentVirtualScreenSize( true ), GetScreenSize() )

	if ( !instant )
	{
		array<float> flickerTimes = [ 0.025, 0.035, 0.035, 0.035, 0.215, 0.23 ]
		int flickerIndex          = 0
		bool visible              = true

		float startTime = Time()
		float endTime   = startTime + flickerTimes[ flickerTimes.len() - 1 ]

		while ( true )
		{
			float time = Time()

			if ( time >= endTime )
				break

			float elapsedTime = time - startTime

			if ( flickerIndex < flickerTimes.len() && elapsedTime > flickerTimes[ flickerIndex ] )
			{
				visible = !visible
				flickerIndex++
			}

			int width  = visible ? scaledVirtualScreenSize.width : 0
			int height = visible ? scaledVirtualScreenSize.height : 0
			RuiTopology_UpdatePos( clGlobal.topoFullscreenHud, <0, 0, 0>, <width, 0, 0>, <0, height, 0> )

			WaitFrame()
		}
	}

	RuiTopology_UpdatePos( clGlobal.topoFullscreenHud, <0, 0, 0>, <0, 0, 0>, <0, 0, 0> )
}


void function HidePermanentHudTopo()
{
	RuiTopology_UpdatePos( clGlobal.topoFullscreenHudPermanent, <0, 0, 0>, <0, 0, 0>, <0, 0, 0> )
}


void function ShowPermanentHudTopo()
{
	UpdateFullscreenTopology( clGlobal.topoFullscreenHudPermanent, true )
}


void function InitCrosshair()
{
	// The number of priority levels should not get huge. Will depend on how many different places in script want control at the same time.
	// All menus for example should show and clear from one place to avoid unneccessary priority levels.
	file.crosshairPriorityOrder.append( crosshairPriorityLevel.ROUND_WINNING_KILL_REPLAY )
	file.crosshairPriorityOrder.append( crosshairPriorityLevel.MENU )
	file.crosshairPriorityOrder.append( crosshairPriorityLevel.PREMATCH )
	file.crosshairPriorityOrder.append( crosshairPriorityLevel.TITANHUD )
	file.crosshairPriorityOrder.append( crosshairPriorityLevel.DEFAULT )

	foreach ( priority in file.crosshairPriorityOrder )
		file.crosshairPriorityLevel[priority] <- null

	// Fallback default
	file.crosshairPriorityLevel[crosshairPriorityLevel.DEFAULT] = CROSSHAIR_STATE_SHOW_ALL
	UpdateCrosshairState()
}


void function SetCrosshairPriorityState( int priority, int state )
{
	Assert( priority != crosshairPriorityLevel.DEFAULT, "Default crosshair state priority level should never be changed." )

	file.crosshairPriorityLevel[priority] = state

	UpdateCrosshairState()
}


void function UpdateCrosshairState()
{
	foreach ( priority in file.crosshairPriorityOrder )
	{
		if ( priority in file.crosshairPriorityLevel && file.crosshairPriorityLevel[priority] != null )
		{
			Crosshair_SetState( file.crosshairPriorityLevel[priority] )
			return
		}
	}
}


void function ClearCrosshairPriority( int priority )
{
	Assert( priority != crosshairPriorityLevel.DEFAULT, "Default crosshair state priority level should never be cleared." )

	if ( priority in file.crosshairPriorityLevel )
		file.crosshairPriorityLevel[priority] = null

	UpdateCrosshairState()
}


void function ServerCallback_Announcement( int titleStringID, int subTextStringID = -1 )
{
	entity player = GetLocalViewPlayer()

	string subTextString = ""
	if ( subTextStringID != -1 )
		subTextString = GetStringFromID( subTextStringID )

	AnnouncementData announcement = Announcement_Create( GetStringFromID( titleStringID ) )
	Announcement_SetSubText( announcement, subTextString )
	Announcement_SetHideOnDeath( announcement, false )

	AnnouncementFromClass( player, announcement )
}


void function ClientCodeCallback_ControllerModeChanged( bool controllerModeEnabled )
{
	entity player = GetLocalClientPlayer()
	if ( IsValid( player ) )
		player.Signal( "ControllerModeChanged" )
}


void function DrawAttentionToTestMap( var elem )
{
	for ( ; ; )
	{
		wait 120
		Hud_SetPos( elem, -1700, -1400 )
		Hud_ReturnToBasePosOverTime( elem, 4, 2 )
	}
}


void function ClientHudInit( entity player )
{
	Assert( player == GetLocalClientPlayer() )

	#if R5DEV
		HudElement( "Dev_Info1" ).Hide()
		HudElement( "Dev_Info2" ).Hide()
		HudElement( "Dev_Info3" ).Hide()
		{
			if ( IsTestMap() )
			{
				var elem = HudElement( "Dev_Info3" )
				Hud_SetText( elem, "Test Map" )
				Hud_Show( elem )
				DrawAttentionToTestMap( elem )

				/*switch( GetMapName() )
				{
					case "sp_danger_room":
					case "sp_script_samples":
					case "sp_enemies":
					case "sp_grunt_battle":
					case "mp_rr_box":
					case "mp_box":
					case "mp_test_engagement_range":
						// blessed calm, like a smooth ocean
						break
					default:
						thread DrawAttentionToTestMap( elem )
						break
				}*/
			}
		}
	#endif // DEV
}


void function CinematicEventUpdateDoF( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	if ( ShouldHaveFarDoF( player ) )
	{
		// DoF_LerpFarDepth( 1000, 1500, 0.5 )
		if ( !file.trackingDoF )
			thread TrackDoF( player )
	}
	else
	{
		player.Signal( "ClearDoF" )
		// DoF_LerpFarDepthToDefault( 1.0 )
	}
}


void function TrackDoF( entity player )
{
	file.trackingDoF = true
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ClearDoF" )

	OnThreadEnd(
		function() : ()
		{
			file.trackingDoF = false
			DoF_LerpNearDepthToDefault( 1.0 )
			DoF_LerpFarDepthToDefault( 1.0 )
		}
	)

	float tick = 0.25

	while ( 1 )
	{
		float playerDist    = Distance2D( player.CameraPosition(), player.GetOrigin() )
		float distToCamNear = playerDist
		float distToCamFar  = distToCamNear

		entity target = GetTitanFromPlayer( player )

		if ( !IsValid( target ) && player.GetObserverMode() == OBS_MODE_CHASE )
		{
			target = player.GetObserverTarget()
		}

		if ( !IsValid( target ) && player.ContextAction_IsMeleeExecutionTarget() )
		{
			entity targetParent = player.GetParent()
			if ( IsValid( targetParent ) )
				target = targetParent
		}

		if ( IsValid( target ) && target != player )
		{
			float targetDist = Distance( player.CameraPosition(), target.EyePosition() )
			distToCamFar = max( playerDist, targetDist )
			distToCamNear = min( playerDist, targetDist )
		}

		float farDepthScalerA = 1
		float farDepthScalerB = 3

		if ( IsValid( target ) )
		{
			farDepthScalerA = 2
			farDepthScalerB = 10
		}

		float nearDepthStart = 0
		float nearDepthEnd   = clamp( min( 50, distToCamNear - 100 ), 0, 50 )
		DoF_LerpNearDepth( nearDepthStart, nearDepthEnd, tick )
		float farDepthStart = distToCamFar + distToCamFar * farDepthScalerA
		float farDepthEnd   = distToCamFar + distToCamFar * farDepthScalerB
		DoF_LerpFarDepth( farDepthStart, farDepthEnd, tick )

		wait tick
	}
}


bool function ShouldHaveFarDoF( entity player )
{
	int ceFlags = player.GetCinematicEventFlags()

	if ( ceFlags & CE_FLAG_EMBARK )
		return true

	if ( ceFlags & CE_FLAG_EXECUTION )
		return true

	return false
}


bool function ShouldMainHudBeVisible( entity player )
{
	int ceFlags = player.GetCinematicEventFlags()

	if ( ceFlags & CE_FLAG_EMBARK )
		return false

	if ( ceFlags & CE_FLAG_DISEMBARK )
		return false

	if ( ceFlags & CE_FLAG_INTRO )
		return false

	if ( ceFlags & CE_FLAG_CLASSIC_MP_SPAWNING )
		return false

	if ( ceFlags & CE_FLAG_HIDE_MAIN_HUD )
		return false

	if ( ceFlags & CE_FLAG_EOG_STAT_DISPLAY )
		return false

	if ( ceFlags & CE_FLAG_TITAN_3P_CAM )
		return false

	if ( clGlobal.isSoloDialogMenuOpen )
		return false

	entity viewEntity = GetViewEntity()
	if ( IsValid( viewEntity ) && viewEntity.IsNPC() )
		return false

	if ( (!player.IsObserver() || player.GetObserverTarget() == player || player.GetObserverTarget() == null) && !IsAlive( player ) )
		return false

	if ( IsViewingSquadSummary() )
		return false

	if ( Fullmap_IsVisible() )
		return false

	int gameState = GetGameState()
	switch( gameState )
	{
		case eGameState.WaitingForCustomStart:
		case eGameState.WaitingForPlayers:
			break

		case eGameState.PickLoadout:
		case eGameState.Prematch:
			return false

		case eGameState.Playing:
		case eGameState.SuddenDeath:
		case eGameState.SwitchingSides:
			break

		case eGameState.WinnerDetermined:
		case eGameState.Epilogue:
		case eGameState.Postmatch:
			return false
	}

	#if R5DEV
		if ( IsModelViewerActive() )
			return false
	#endif

	return true
}


bool function ShouldPermanentHudBeVisible( entity player )
{
	if ( IsViewingSquadSummary() )
		return false

	// this hud contains the minimap, unintframes and overhead names etc.
	int gameState = GetGameState()
	switch( gameState )
	{
		case eGameState.WaitingForCustomStart:
		case eGameState.WaitingForPlayers:
			break

		case eGameState.PickLoadout:
		case eGameState.Prematch:
			return false

		case eGameState.Playing:
		case eGameState.SuddenDeath:
		case eGameState.SwitchingSides:
			break

		case eGameState.WinnerDetermined:
		case eGameState.Epilogue:
		case eGameState.Postmatch:
			return false
	}

	if ( Fullmap_IsVisible() )
		return false

	{
		int ceFlags = player.GetCinematicEventFlags()

		if ( ceFlags & CE_FLAG_HIDE_PERMANENT_HUD )
			return false

		// hide during execution
		if ( ceFlags & CE_FLAG_TITAN_3P_CAM )
			return false
	}

	if ( (!player.IsObserver() || player.GetObserverTarget() == player || player.GetObserverTarget() == null) && !IsAlive( player ) )
		return false

	#if R5DEV
		if ( IsModelViewerActive() )
			return false
	#endif

	return true
}


void function InitChatHUD()
{
	UpdateChatHUDVisibility()

	if ( IsLobby() )
		return

	UISize screenSize   = GetScreenSize()
	float resMultiplier = screenSize.height / 1080.0
	int width           = 630
	int height          = 155

	HudElement( "IngameTextChat" ).SetSize( width * resMultiplier, height * resMultiplier )
}

void function UpdateChatHUDVisibility()
{
	local chat = HudElement( "IngameTextChat" )

	Hud_SetAboveBlur( chat, true )

	if ( IsLobby() || clGlobal.isMenuOpen )
		chat.Hide()
	else
		chat.Show()

	local hint = HudElement( "AccessibilityHint" )
	if ( IsLobby() || clGlobal.isMenuOpen || !IsAccessibilityChatHintEnabled() || GetPlayerArrayOfTeam( GetLocalClientPlayer().GetTeam() ).len() < 2 )
		hint.Hide()
	else
		hint.Show()
}

bool function IsWatchingReplay()
{
	if ( IsWatchingKillReplay() )
		return true

	if ( IsWatchingSpecReplay() )
		return true

	return false
}


