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
DATAREF_LIFT_MPS = createGlobalPropertyf("b21_thermals/lift_mps", 0.0, false, true, true)

--
-- ----------------------------------------------

-- ----------------------------------------------
-- GLOBALS used between each iteration
-- previous update time (float seconds)
local prev_time_s = 0

-- previous altitude (float meters)
local prev_alt_m = 0

local init_completed = false

function init()
	print("b21_thermals initialized")
end

function update()

	if not init_completed
	then
		init()
		init_completed = true
	end

	-- calculate time (float seconds) since previous update
	local time_delta_s = get(DATAREF_TIME_S) - prev_time_s
	
	-- only update max 20 times per second (i.e. time delta > 0.05 seconds)
	if time_delta_s > 1.05
	then
		set(DATAREF_LIFT_MPS,7.7)
		prev_time_s = get(DATAREF_TIME_S)
	end
		
end -- function
