using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

# ______ ______  ____________________
# ___  //_/_  / / /__  ____/__  ____/
# __  ,<  _  / / /__  /_   __  /_    
# _  /| | / /_/ / _  __/   _  __/    
# /_/ |_| \____/  /_/      /_/       

    @editable VFXRemoteSignal : signal_remote_manager_device = signal_remote_manager_device{}
    @editable EnableByTrigger : trigger_device = trigger_device{}
    @editable EnableByButton : button_device = button_device{}
    
    @editable WallHacksVFXs : []vfx_spawner_device = array{} 
    @editable SpawnPads : []player_spawner_device = array{}
    
    @editable VFXInfiniteDuration : logic = true   
    @editable VFXDuration : float = 10.0

stack<public>(t:type) := class:
    Elements<internal>:[]t = array{}

    Push<public>(NewElement:t):stack(t)=
        stack(t){Elements := Elements + array{NewElement}}

    Pop<public>()<decides><transacts>:tuple(stack(t),t)=
        FirstElement := Peek[]
        (stack(t){Elements := Elements.RemoveElement[Elements.Length - 1]}, FirstElement)

    Size<public>()<transacts>:int=
        Elements.Length

    IsEmpty<public>()<decides><transacts>:void=
        Size() = 0

    Peek<public>()<decides><transacts>:t=
        Elements[Elements.Length - 1]                    

CreateStack<public><constructor>(InitialElements:[]t where t:type) := stack(t):
    Elements := InitialElements

Kuff_wallhack := class(creative_device):

    var VFXStack : stack(vfx_spawner_device) = stack(vfx_spawner_device){}
    var VFXAgentMap : [agent]vfx_spawner_device = map{}

    OnBegin<override>()<suspends>:void=
        SpawnPadInit()
        set VFXStack = CreateStack( WallHacksVFXs )
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        spawn{ RemoteSignal() }
        spawn{ Trigger() }
        spawn{ButtonDetect() }

    SpawnPadInit():void=
        for(SpawnPad : SpawnPads):
            SpawnPad.SpawnedEvent.Subscribe( AgentInit )

    AgentInit(Agent : agent):void=
        if(Exists := VFXAgentMap[Agent]):
        else:
            if(NewTuple := VFXStack.Pop[]):
                set VFXStack = NewTuple(0)                
                VFX : vfx_spawner_device = NewTuple(1)
                if(set VFXAgentMap[Agent] = VFX):
                spawn{ VFXAttatch(Agent, VFX) }
            else:

    OnPlayerRemoved(Agent : agent):void=
        if(RemovedPlayerVFX : vfx_spawner_device = VFXAgentMap[Agent]):
            set VFXStack = VFXStack.Push( RemovedPlayerVFX )
            var NewVFXMap : [agent]vfx_spawner_device = map{}            
            for(CurrentAgent -> VFX : VFXAgentMap, CurrentAgent <> Agent):
                set NewVFXMap = ConcatenateMaps(NewVFXMap, map{CurrentAgent => VFX})
            set VFXAgentMap = NewVFXMap
            RemovedPlayerVFX.Disable()

    RemoteSignal()<suspends>:void=
        loop:
            ButtonPresser := VFXRemoteSignal.PrimarySignalEvent.Await()
            spawn{ WallHackPlayer(ButtonPresser) }

    Trigger()<suspends>:void=
        loop:
            TriggerPusher := EnableByTrigger.TriggeredEvent.Await()
            if(Agent := TriggerPusher?):
                spawn{ WallHackPlayer(Agent) }  
                
    ButtonDetect()<suspends>:void=
        loop:
            ButtonPresser := EnableByButton.InteractedWithEvent.Await()
            spawn{ WallHackPlayer(ButtonPresser) }

    WallHackPlayer(Agent:agent) <suspends> : void=
        if(MainPlayer := player[Agent], MainFC:= MainPlayer.GetFortCharacter[]):
            for(MappedAgent -> VFX : VFXAgentMap):
                if(FortChar := MappedAgent.GetFortCharacter[]):
                    if(FortChar = MainFC):
                    else:
                        CheckSameTeam := IsOnSameTeam(Agent, MappedAgent)
                        if(CheckSameTeam = false):
                            EnableVFX(VFX)

    VFXAttatch(Agent : agent, VFX : vfx_spawner_device)<suspends>:void=
        if(FortChar := Agent.GetFortCharacter[]):
            loop:
                Sleep(0.0)
                if(VFX.TeleportTo[FortChar.GetTransform().Translation,IdentityRotation()]){}

    EnableVFX(VFX : vfx_spawner_device): void=
        VFX.Enable()
        if(VFXInfiniteDuration = false):
            spawn{ ClearVFX(VFX)}        

    ClearVFX(VFX : vfx_spawner_device)<suspends>:void=
        Sleep(VFXDuration)
        VFX.Disable()

    IsOnSameTeam(InitiatingAgent : agent, ComparingAgent : agent):logic=
        TeamCollection := GetPlayspace().GetTeamCollection()
        if(InitiatingTeam := TeamCollection.GetTeam[InitiatingAgent]):
            if(TeamCollection.IsOnTeam[ComparingAgent, InitiatingTeam]):
                return true
        return false
