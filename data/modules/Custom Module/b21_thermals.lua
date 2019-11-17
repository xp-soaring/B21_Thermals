-- b21_thermals

components = {}

-- ----------------------------------------------
-- DATAREFS

-- the datarefs we will READ to get time, altitude and speed from the sim
local DATAREF_TIME_S = globalPropertyf("sim/network/misc/network_time_sec")
local DATAREF_ALT_FT = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
local DATAREF_ELEVATION = globalPropertyf("sim/flightmodel/position/elevation")
local DATAREF_AIRSPEED_MPS = globalPropertyf("sim/flightmodel/position/true_airspeed")
local DATAREF_PAUSED = globalPropertyi("sim/time/paused") -- =1 if paused

-- create global DataRefs we will WRITE (name, default, isNotPublished, isShared, isReadOnly)
local DATAREF_LIFT_MPS = createGlobalPropertyf("b21_thermals/lift_mps", 0.0, false, true, true)
local DATAREF_BACK_N = globalPropertyf("sim/flightmodel/forces/faxil_plug_acf") -- force back along fuselage
local DATAREF_UP_N = globalPropertyf("sim/flightmodel/forces/fnrml_plug_acf") -- force up from fuselage
local DATAREF_DEBUG = createGlobalPropertyf("b21_thermals/debug", 0.0, false, true, true)

--
-- ----------------------------------------------

-- ----------------------------------------------
-- GLOBALS used between each iteration
-- previous update time (float seconds)
local prev_time_s = 0

-- previous altitude (float meters)
local prev_alt_m = 0

local current_lift_mps = 0.0

local current_force_forwards_n = 0.0

local current_force_up_n = 0.0

local start_time_s = 0

local init_completed = false

function init()
	current_lift_mps = 0.0

	start_time_s = get(DATAREF_TIME_S)

	set(DATAREF_LIFT_MPS, current_lift_mps)

	print("b21_thermals initialized at", get(DATAREF_LIFT_MPS))
end

-- given a lift value in m/s, return force in newtons
function lift_to_force(lift_ms)
	return lift_ms * 200
end

function update()

	local now_s = get(DATAREF_TIME_S)

	if not init_completed
	then
		init()
		init_completed = true
	end

	-- do NOTHING if sim is paused
	if get(DATAREF_PAUSED) > 0
	then
		return
	end

	-- calculate time (float seconds) since previous update
	local time_delta_s = now_s - prev_time_s
	
	-- only update every second
	if time_delta_s > 1.0
	then

		if (now_s - start_time_s) > 120
		then
			current_lift = 0.0
		elseif (now_s - start_time_s) > 20
		then
			current_lift = 2.0
		end

		-- force will be +ve for lift
		local current_force_n = lift_to_force(current_lift)

		print("current_force_n", current_force_n)

		current_force_up_n = current_force_n * 0.2

		current_force_forwards_n = current_force_n * 0.8

		set(DATAREF_LIFT_MPS, current_lift)


		--set(DATAREF_LIFT_MPS, current_lift)
		prev_time_s = get(DATAREF_TIME_S)
	end

	local current_back_n = get(DATAREF_BACK_N)
	local current_up_n = get(DATAREF_UP_N)

	--set(DATAREF_DEBUG, current_drag_n)

	-- add negative force to DATAREF_BACK_N
	set(DATAREF_BACK_N, current_back_n - current_force_forwards_n )

	-- add positive force to DATAREF_UP_N
	set(DATAREF_UP_N, current_up_n + current_force_up_n )
		
end -- function
