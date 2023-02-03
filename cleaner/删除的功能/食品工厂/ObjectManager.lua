local AgentTypes =
    setmetatable(
    {
        _registry = {
            -- [AgentType.ship] = "ShipAgent"
            --[AgentType.food_factory] = "FoodFactoryAgent",
            [AgentType.dock] = "ShipDockAgent",
            [AgentType.resource] = "ResourceAgent",
            [AgentType.recycle] = "RecycleAgent",
            [AgentType.animal] = "MonsterAgent",
            [AgentType.ground] = "GroundAgent",
            [AgentType.init_ground] = "InitGroundAgent",
            [AgentType.decoration] = "DecorationAgent",
            [AgentType.recovery_pet] = "RecoveryPetAgent",
            [AgentType.decoration_factory] = "DecorationFactoryAgent",
            [AgentType.decoration_building] = "NormalAgent",
            [AgentType.linkHomeland_groud] = "LinkGroundAgent",
            [AgentType.onHookBuild] = "OnHookBuildAgent"
        }
    },