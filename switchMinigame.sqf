/*--------------------------------------------------------------------------------------------------
	SWITCH MINI GAME

	Code is used in my Arma 3 Composition located at:
	https://steamcommunity.com/sharedfiles/filedetails/?id=2961943348
--------------------------------------------------------------------------------------------------*/

[] spawn {
	scriptName "Switch Minigame - By Hypoxic";

	waitUntil { getClientStateNumber >= 8 or getClientStateNumber == 0};

	SMINI_fnc_generatePassword = {
		if !(isServer) exitWith {};

		private _pass = [];
		for "_i" from 0 to (count SMINI_switches - 1) do {
			_pass pushBack (selectRandom [0,1]);
		};

		if ({_x == 1} count _pass == 0) exitWith { _this call SMINI_fnc_generatePassword };

		_pass;
	};

	SMINI_fnc_switch_playElectricity = {
		params ["_switch"];

		if !(isServer) exitWith {};
		if !(canSuspend) exitWith {_this spawn SMINI_fnc_switch_playElectricity};

		while { (_switch getVariable ["SMINI_switch_on", false]) } do {
			playSound3D [SMINI_switch_sound_electric,_switch,false,getPosASL _switch,3,1,50,3,false];
			_switch setVariable ["SMINI_switch_sound_playing", true, true];
			sleep 2;
			_switch setVariable ["SMINI_switch_sound_playing", false, true];
		};
	};

	SMINI_fnc_switch_greenLight = {
		params ["_switch", "_state"];

		private _return = objNull;
		switch _state do {
			case "on": {
				private _light = "#lightpoint" createVehicleLocal [0,0,0];
				_light attachTo [_switch, SMINI_switch_attachPoint_green];
				_light setLightColor SMINI_switch_light_color_green;
				_light setLightAmbient SMINI_switch_light_colorAmbient_green;
				_light setLightAttenuation SMINI_switch_light_attenuation;
				_light setLightBrightness SMINI_switch_light_brightness;
				_light setLightDayLight true;
				_light setLightUseFlare true;
				_light setLightFlareSize SMINI_switch_light_flareSize;
				_light setLightFlareMaxDistance SMINI_switch_light_flareDistance;

				_switch setVariable ["SMINI_switch_light_green", _light];
				_return = _light;
			};

			case "off": {
				_light = _switch getVariable ["SMINI_switch_light_green", objNull];
				_switch setVariable ["SMINI_switch_light_green", nil];
				deleteVehicle _light;
			};
		};

		_return
	};

	SMINI_fnc_switch_redLight = {
		params ["_switch", "_state"];

		private _return = objNull;
		switch _state do {
			case "on": {
				private _light = "#lightpoint" createVehicleLocal [0,0,0];
				_light attachTo [_switch, SMINI_switch_attachPoint_red];
				_light setLightColor SMINI_switch_light_color_red;
				_light setLightAmbient SMINI_switch_light_colorAmbient_red;
				_light setLightAttenuation SMINI_switch_light_attenuation;
				_light setLightBrightness SMINI_switch_light_brightness;
				_light setLightDayLight true;
				_light setLightUseFlare true;
				_light setLightFlareSize SMINI_switch_light_flareSize;
				_light setLightFlareMaxDistance SMINI_switch_light_flareDistance;

				_switch setVariable ["SMINI_switch_light_red", _light];
				_return = _light;
			};

			case "off": {
				_light = _switch getVariable ["SMINI_switch_light_red", objNull];
				_switch setVariable ["SMINI_switch_light_red", nil];
				deleteVehicle _light;
			};
		};
	};

	SMINI_fnc_switch_password_correct = {
		if (isNil "SMINI_password") exitWith { false };
		private _states = SMINI_switches apply {
			private _state = _x getVariable ["SMINI_switch_on", false];
			parseNumber _state;
		};

		if (_states isEqualTo SMINI_password) exitWith { true };
		false;
	};

	SMINI_switches = [];
	for "_i" from 0 to 999 do {
		private _name = format ["SMINI_switch_%1", _i];
		private _var = missionNamespace getVariable [_name, objNull];
		if (isNull _var) then {continue};
		SMINI_switches pushBackUnique _var;
	};

	SMINI_pass_correct = false;
	if (isServer) then {
		SMINI_password = call SMINI_fnc_generatePassword;
		publicVariable "SMINI_password";
	};

	SMINI_switch_sound_switch = "A3\Missions_F_Oldman\Data\sound\Light_Switch\Light_Switch_01.wss";
	SMINI_switch_sound_electric = "A3\Missions_F_EPA\data\sounds\electricity_loop.wss";

	SMINI_switch_attachPoint_red = [0.102,-0.12,0.5];
	SMINI_switch_attachPoint_green = [0.102,-0.12,0.425];
	SMINI_switch_light_brightness = 0.2;
	SMINI_switch_light_attenuation = [1,0,0,2,0,0];
	SMINI_switch_light_flareSize = 0.3;
	SMINI_switch_light_color_red = [0.75,0,0];
	SMINI_switch_light_colorAmbient_red = [0,0,0];
	SMINI_switch_light_color_green = [0,0.75,0];
	SMINI_switch_light_colorAmbient_green = [0,0,0];
	SMINI_switch_light_flareDistance = 10;

	SMINI_switch_action_on = [
		"Switch On",
		{
			params ["_target", "_caller", "_actionID", "_arguments"];

			playSound3D [SMINI_switch_sound_switch,_target,false,getPosASL _target,3,1,50,0,false];

			_target setVariable ["SMINI_switch_on", true, true];
			[_target] remoteExec ["SMINI_fnc_switch_playElectricity", 2];
			[_target, "off"] remoteExec ["SMINI_fnc_switch_redLight"];
			[_target, "on"] remoteExec ["SMINI_fnc_switch_greenLight"];
		},
		nil, 1e4, true, true, "",
		toString { !(_target getVariable ["SMINI_switch_on", false]) && {!(_target getVariable ["SMINI_switch_sound_playing", false])} },
		3, false, "", ""
	];

	SMINI_switch_action_off = [
		"Switch Off",
		{
			params ["_target", "_caller", "_actionID", "_arguments"];

			playSound3D [SMINI_switch_sound_switch,_target,false,getPosASL _target,3,1,50,0,false];

			_target setVariable ["SMINI_switch_on", false, true];
			[_target, "on"] remoteExec ["SMINI_fnc_switch_redLight"];
			[_target, "off"] remoteExec ["SMINI_fnc_switch_greenLight"];
		},
		nil, 1e4, true, true, "",
		toString { (_target getVariable ["SMINI_switch_on", false]) },
		3, false, "", ""
	];

	{
		[_x, "on"] call SMINI_fnc_switch_redLight;
		_x addAction SMINI_switch_action_on;
		_x addAction SMINI_switch_action_off;
	} forEach SMINI_switches;

	waitUntil {
		call SMINI_fnc_switch_password_correct
	};

	if (isServer) then {
		missionNamespace setVariable ["SMINI_password_correct", true, true];
		{
			if !(_x getVariable ["SMINI_switch_on", false]) then {
				[_x, "off"] remoteExec ["SMINI_fnc_switch_redLight"];
				[_x, "on"] remoteExec ["SMINI_fnc_switch_greenLight"];
				_x setVariable ["SMINI_switch_on", true, true];
				[_x] remoteExec ["SMINI_fnc_switch_playElectricity", 2];
			};
			playSound3D [SMINI_switch_sound_switch,_x,false,getPosASL _x,3,1,50,0,false];
		} forEach SMINI_switches;
	};

	{
		removeAllActions _x;
	} forEach SMINI_switches
};