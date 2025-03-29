# GMod CCTV Cameras/Screens + Tripwires

## Dependencies
1. https://github.com/SuchtBunker/ben_derma
2. https://github.com/SuchtBunker/_benlib

## Settings
In `lua/entities/*/shared.lua` or `lua/entities/*.lua` there are several settings for the corresponding entities as well as the darkrp buy configuration. Even though this is intended for darkrp, it should also work for any other gamemode (as long as the entities are spawned via the spawnmenu or the server calls Setowning_ent on them)

You can add other models/configurations for the screen as well if you copy and adjust `lua/entities/screen_*.lua`
You can add other models for the camera as well if you create a new entity and set `spycam` as its base and adjust the model in there
You could also create another configuration for the tripwire by copying the tripwire_1/2.lua file and adjusting ENT.Notify or ENT.MaxRange