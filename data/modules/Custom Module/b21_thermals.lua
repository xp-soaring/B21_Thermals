-- b21_thermals

components = {}

-- ----------------------------------------------
-- DATAREFS

-- the datarefs we will READ to get time, altitude and speed from the sim
local DATAREF_TIME_S = globalPropertyf("sim/network/misc/network_time_sec")
local DATAREF_ALT_FT = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
local DATAREF_ELEVATION = globalPropertyf("sim/flightmodel/position/elevation")
local DATAREF_AIRSPEED_MPS = globalPropertyf("sim/flightmodel/position/true_airspeed")

-- create global DataRefs we will WRITE (name, default, isNotPublished, isShared, isReadOnly)
local DATAREF_LIFT_MPS = createGlobalPropertyf("b21_thermals/lift_mps", 0.0, false, true, true)
local DATAREF_DRAG_N = globalPropertyf("sim/flightmodel/forces/faxil_plug_acf") -- force along fuselage
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

local init_completed = false

function init()
	current_lift_mps = 2.0
	set(DATAREF_LIFT_MPS, current_lift_mps)
	print("b21_thermals initialized at", get(DATAREF_LIFT_MPS))
end

function update()

	if not init_completed
	then
		init()
		init_completed = true
	end

	-- calculate time (float seconds) since previous update
	local time_delta_s = get(DATAREF_TIME_S) - prev_time_s
	
	-- only update max 1 times per second (i.e. time delta > 1 seconds)
	if time_delta_s > 1.0
	then
		--current_lift = 2.0

		--set(DATAREF_LIFT_MPS, current_lift)
		prev_time_s = get(DATAREF_TIME_S)
	end

	local current_drag_n = get(DATAREF_DRAG_N)

	--set(DATAREF_DEBUG, current_drag_n)

	-- add negative force to DATAREF_DRAG_N
	set(DATAREF_DRAG_N, current_drag_n - get(DATAREF_DEBUG) )
		
end -- function
