# kuff_wallhack
A Wallhack script made with UEFN scripting language VERSE. Use for Creative 2.0!

# Game Setup Instructions
1. **Place Creative Devices:**
   - Assign one creative device to each team.
2. **Create VFX Spawners:**
   - For each player, create a VFX spawner, multiplied by the number of teams.
   - Configure the VFX spawners:
     - Make one set visible only to Team 1 and the designated class.
     - Make another set visible only to Team 2 and the designated class.
     - Repeat this process for all teams.
3. **Configure VFX Spawners:**
   - Check the 'Custom visual effect override' option on each VFX spawner.
   - Select the wall hack VFX for each spawner.
4. **Set Up Button/Trigger:**
   - Ensure the button or trigger is configured so that only players of the required class can see the VFX.
5. **Assigning VFX to Players:**
   - As players join the game, they will be assigned a VFX that sticks to them.
   - When a player leaves, the VFX will be returned to stock for future use.
6. **Remote Activation:**
   - When a player presses the designated remote, the VFX will be enabled for all players except the one who pressed the button.

# Devices
```
    @editable VFXRemoteSignal : signal_remote_manager_device = signal_remote_manager_device{}
    @editable EnableByTrigger : trigger_device = trigger_device{}
    @editable EnableByButton : button_device = button_device{}
    
    @editable WallHacksVFXs : []vfx_spawner_device = array{} 
    @editable SpawnPads : []player_spawner_device = array{}
    
    @editable VFXInfiniteDuration : logic = true   
    @editable VFXDuration : float = 10.0
```


  
# [How To Build A Verse File](https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse#:~:text=Open%20your%20project%20in%20UEFN,the%20Create%20Verse%20Script%20window.)
