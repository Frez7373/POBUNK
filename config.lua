-- POBUNK configuration
-- CC:Tweaked 1.16.5

return {
    title = "POBUNK CONTROL",
    version = "1.0.0",

    -- Optional monitor. Example: top / left / right / back
    monitor_side = "top",

    -- Optional modem side for remote control
    modem_side = "right",
    remote_enabled = true,
    remote_password = "1234",
    remote_channel = 7310,

    -- Redstone sides used by the bunker controller
    outputs = {
        door = "front",       -- main blast door
        lights = "back",      -- bunker lighting
        ventilation = "left",-- ventilation/fans
        alarm = "bottom"      -- siren/alarm
    },

    inputs = {
        motion = "top",          -- perimeter/motion sensor signal
        pressure = "right",      -- pressure/door sensor signal
        emergency = "bottom"     -- emergency button signal
    },

    -- Default states
    startup_lights = true,
    startup_ventilation = true,
    startup_door_locked = true,

    -- Security
    pin = "2580",
    max_attempts = 3,
    lockdown_on_emergency = true,
    auto_alarm_on_motion = false,

    -- Logging
    max_log_entries = 80
}
