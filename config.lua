-- OSBUNK configuration
-- CC:Tweaked for Minecraft 1.21.1

return {
    name = "OSBUNK",
    version = "2.0.0",
    pin = "2580",
    start_locked = true,
    boot_sound = true,
    default_theme = "bunker",
    monitor_scale = 0.5,
    rednet_channel = 7310,
    remote_password = "1234",
    allow_remote = true,
    bunker = {
        door = "front",
        lights = "back",
        ventilation = "left",
        alarm = "bottom"
    },
    backup_dir = "/osbunk_backups"
}
