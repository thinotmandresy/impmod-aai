void ShouldIResign()
{
    if (gStartup == false)
        return;
    
    static int retry = -1;
    if (xsGetTime() < retry)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 10000)
        return;
    last_call = xsGetTime();

    // Do not resign while the Treaty counter is not zero.
    if (aiTreatyActive() == true)
        return;
    
    // Do not resign before 10 minutes.
    if (xsGetTime() < 600000)
        return;
    
    // Do not resign if we have a Town Center.
    if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive) >= 1)
        return;
    
    int tc_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTownCenter, true);
    if (aiPlanGetState(tc_build_plan) == cPlanStateBuild)
        return;
    
    // Do not resign if we have more than 30 active (or potentially active) population.
    int military_count = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateABQ);
    int villager_count = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateABQ);
    if (military_count + villager_count > 30)
        return;
    
    // Do not resign when we have an alive human ally.
    for (player = 1; < cNumberPlayers)
    {
        if (kbIsPlayerHuman(player) == false)
            continue;
        if (kbHasPlayerLost(player) == true)
            continue;
        if (kbIsPlayerAlly(player) == false)
            continue;
        
        return;
    }

    // Force-resign if there is no chance to recover.
    bool tc_affordable = kbCanAffordUnit(cUnitTypeTownCenter, cRootEscrowID);
    int builder = findWagonToBuildProtoUnit(cUnitTypeTownCenter);
    if (builder == -1)
        builder = getUnit1(cUnitTypeAbstractMonk, cMyID, 0);
    if (kbProtoUnitCanSpawn(kbUnitGetProtoUnitID(builder), cUnitTypeTownCenter) == false)
    {
        builder = -1;
        for (i = 0; < kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive))
        {
            int i_unit = getUnit1(cUnitTypeAbstractVillager, cMyID, i);
            if (kbProtoUnitCanSpawn(kbUnitGetProtoUnitID(i_unit), cUnitTypeTownCenter) == true)
            {
                builder = i_unit;
                break;
            }
        }
    }

    if (tc_affordable == false)
    {
        if (kbUnitIsType(builder, cUnitTypeAbstractVillager) == false && kbUnitIsType(builder, cUnitTypeAbstractWagon) == false)
        {
            aiResign();
            return;
        }
    }

    if (builder == -1)
    {
        aiResign();
        return;
    }
    
    int number_enemy_units = kbBaseGetNumberUnits(cMyID, kbBaseGetMainID(cMyID), cPlayerRelationEnemyNotGaia, cUnitTypeLogicalTypeLandMilitary);
    int number_enemies = 0;
    int number_team_units = kbBaseGetNumberUnits(cMyID, kbBaseGetMainID(cMyID), cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

    for (player = 1; < cNumberPlayers)
    {
        if (kbHasPlayerLost(player) == true)
            continue;
        
        if (kbIsPlayerEnemy(player) == true)
        {
            number_enemies++;
        }
    }
    
    // Do not resign if we have no enemies.
    if (number_enemies <= 0)
        return;

    float enemy_ratio = (number_enemy_units / number_enemies) / number_team_units;
    
    // Do not resign if we have more than 4 times the number of enemy units.
    if (enemy_ratio <= 4)
        return;
    
    // Send a resign request to all enemies.
    aiAttemptResign(cAICommPromptToEnemyMayIResign);

    // Retry in 2 minutes if they decline.
    retry = xsGetTime() + 120000;
}


void eWhenOpponentRespondsToMyResignRequest(int response = -1)
{
    if (response == 0)
        return;

    int total_resources = kbResourceGet(cResourceFood) + kbResourceGet(cResourceWood) + kbResourceGet(cResourceGold);
    while(total_resources > 0)
    {
        total_resources = total_resources - 300;
        
        for(player = 0; < cNumberPlayers)
        {
            if (kbHasPlayerLost(player) == true)
                continue;
            if (kbIsPlayerAlly(player) == false)
                continue;
            if (player == cMyID)
                continue;
            
            aiTribute(player, cResourceFood, 100.0);
            aiTribute(player, cResourceWood, 100.0);
            aiTribute(player, cResourceGold, 100.0);
        }
    }
    
    aiResign();
}
