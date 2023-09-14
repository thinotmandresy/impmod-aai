rule ManageHerdables
group rgStartup
inactive
minInterval 1
{
    static int full_herd_plan = -1;
    static int default_herd_plan = -1;
    if (full_herd_plan == -1)
    {
        full_herd_plan = aiPlanCreate("Full Herdable Herd Plan", cPlanHerd);
        aiPlanSetDesiredPriority(full_herd_plan, 100);
        aiPlanSetVariableInt(full_herd_plan, cHerdPlanBuildingID, 0, getUnit1(cUnitTypeTownCenter, cMyID, 0));
        aiPlanSetVariableFloat(full_herd_plan, cHerdPlanDistance, 0, 8.0);
        aiPlanAddUnitType(full_herd_plan, cUnitTypeHerdable, 0, 0, 0);

        // Prevent this plan from 'stealing' units. We need to assign fattened herdables ourselves.
        aiPlanSetNoMoreUnits(full_herd_plan, true);

        aiPlanSetActive(full_herd_plan, true);

        default_herd_plan = aiPlanCreate("Default Herd Plan", cPlanHerd);
        aiPlanSetDesiredPriority(default_herd_plan, 5);
        aiPlanSetVariableInt(default_herd_plan, cHerdPlanBuildingTypeID, 0, cUnitTypeTownCenter);
        aiPlanSetVariableFloat(default_herd_plan, cHerdPlanDistance, 0, 6.0);
        aiPlanAddUnitType(default_herd_plan, cUnitTypeHerdable, 200, 200, 200);
        aiPlanSetNoMoreUnits(default_herd_plan, false);
        aiPlanSetActive(default_herd_plan, true);
    }
    
    int full_herd_building = getUnitByLocation1(cUnitTypeTownCenter, cMyID, getMainBaseLocation(), cMainBaseRadius, 0);
    if (full_herd_building == -1)
        full_herd_building = getUnitByLocation1(cUnitTypeLogicalTypeBuildingsNotWalls, cMyID, getMainBaseLocation(), cMainBaseRadius, 0);
    
    if (getMainBaseLocation() == cInvalidVector || full_herd_building == -1)
    {
        aiPlanSetVariableInt(full_herd_plan, cHerdPlanBuildingID, 0, -1);
        aiPlanSetVariableInt(full_herd_plan, cHerdPlanBuildingTypeID, 0, cUnitTypeTownCenter);
    }
    else
    {
        aiPlanSetVariableInt(full_herd_plan, cHerdPlanBuildingID, 0, full_herd_building);
        aiPlanSetVariableInt(full_herd_plan, cHerdPlanBuildingTypeID, 0, cUnitTypeTownCenter);
    }
    
    // Since the game doesn't automatically destroy herd plans for some reason...
    for(i = 0; < aiPlanGetNumber(cPlanHerd))
    {
        int i_herd_plan = aiPlanGetIDByIndex(cPlanHerd, -1, true, i);
        if (i_herd_plan == full_herd_plan || i_herd_plan == default_herd_plan)
            continue;
        if (kbUnitGetCurrentHitpoints(aiPlanGetVariableInt(i_herd_plan, cHerdPlanBuildingID, 0)) < 0.1)
            aiPlanDestroy(i_herd_plan);
    }

    for(i = 0; < kbUnitCount(cMyID, gUnitTypeLivestockPen, cUnitStateAlive))
    {
        int i_livestock_pen = getUnit1(gUnitTypeLivestockPen, cMyID, i);
        if (aiPlanGetIDByTypeAndVariableType(cPlanHerd, cHerdPlanBuildingID, i_livestock_pen, true) >= 0)
            continue;
        
        int i_livestock_pen_herd_plan = aiPlanCreate("Livestock Pen Herd Plan", cPlanHerd);
        aiPlanSetDesiredPriority(i_livestock_pen_herd_plan, 10);
        aiPlanSetVariableInt(i_livestock_pen_herd_plan, cHerdPlanBuildingID, 0, i_livestock_pen);
        aiPlanSetVariableFloat(i_livestock_pen_herd_plan, cHerdPlanDistance, 0, 0.0);
        aiPlanAddUnitType(i_livestock_pen_herd_plan, cUnitTypeHerdable, 2, 2, 2);
        aiPlanSetNoMoreUnits(i_livestock_pen_herd_plan, false);
        aiPlanSetActive(i_livestock_pen_herd_plan, true);
    }

    for(i = 0; < kbUnitCount(cMyID, cUnitTypeHerdable, cUnitStateAlive))
    {
        int i_herdable = getUnit1(cUnitTypeHerdable, cMyID, i);
        int i_herdable_plan = kbUnitGetPlanID(i_herdable);
        if (kbUnitIsInventoryFull(i_herdable) == true && i_herdable_plan >= 0 && i_herdable_plan != full_herd_plan)
        {
            aiPlanDestroy(kbUnitGetPlanID(i_herdable));
            aiPlanAddUnit(full_herd_plan, i_herdable);
            continue;
        }
    }
}


rule HerdHuntables
group rgStartup
inactive
minInterval 1
{
    if (kbGetAge() >= cAge3 || cMyCulture == cCultureJapanese || 
        kbTechGetStatus(cTechFrontierTraining) == cTechStatusActive || 
        kbTechGetStatus(cTechypMarketSpiritMedicine) == cTechStatusActive || 
        kbTechGetStatus(cTechSpiritMedicine) == cTechStatusActive)
    {
        gShepherd = -1;
        xsDisableSelf();
        return;
    }

    static int town_center = -1;
    vector town_center_position = kbUnitGetPosition(town_center);
    vector shepherd_position = kbUnitGetPosition(gShepherd);
    static int last_shot = 0;
    static int huntable = -1;
    vector huntable_position = kbUnitGetPosition(huntable);
    vector shooting_spot = huntable_position + xsVectorNormalize(huntable_position - town_center_position) * 8.0;
    float distance_to_shooting_spot = xsVectorLength(shepherd_position - shooting_spot);

    // TODO -- Avoid hardcoded values. Write a syscall in UHC Plugin to get the base MaximumVelocity of a unit.
    const float cVillagerVelocity = 5.0;

    int i_villager = -1;
    vector i_villager_position = cInvalidVector;
    int i_huntable = -1;
    vector i_huntable_position = cInvalidVector;
    int i_huntable_hitpoints = 0;
    int strongest_huntable = -1;
    int highest_hitpoints = 0.0;

    if (kbUnitGetCurrentHitpoints(town_center) < 0.1)
    {
        town_center = getUnit1(cUnitTypeTownCenter, cMyID, 0);
        return;
    }

    if (kbUnitGetCurrentHitpoints(gShepherd) < 0.1 ||
        kbUnitGetPlanID(gShepherd) >= 0)
    {
        gShepherd = -1;

        for(i = 0; < kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive))
        {
            i_villager = getUnitByLocation1(cUnitTypeAbstractVillager, cMyID, town_center_position, 5000.0, i);
            i_villager_position = kbUnitGetPosition(i_villager);
            
            if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_villager)) != cMovementTypeLand)
                continue;
            
            if (kbUnitIsType(i_villager, cUnitTypeAbstractWagon))
                continue;
            
            if (kbUnitGetProtoUnitID(i_villager) == cUnitTypeSettlerWagon)
                continue;
            
            if (kbUnitGetPlanID(i_villager) >= 0)
                continue;
            
            if (kbUnitGetActionType(i_villager) == cActionBuild)
                continue;
            
            if (isFlagged(i_villager, cFlagTownBell))
                continue;
            
            if (kbCanPath2(i_villager_position, town_center_position, kbUnitGetProtoUnitID(i_villager)) == false)
                continue;
            
            gShepherd = i_villager;
            return;
        }
    }

    xsSetContextPlayer(0);
    float huntable_health = kbUnitGetHealth(huntable);
    xsSetContextPlayer(cMyID);

    if (huntable_health < 1.0)
    {
        int temp = getUnitByLocation1(cUnitTypeAnimalPrey, 0, shepherd_position, 5000.0, 0, cUnitStateDead);
        if (temp == -1)
        {
            temp = getUnitByLocation1(cUnitTypeTree, 0, shepherd_position, 5000.0, 0);
        }
        if (temp == -1)
        {
            temp = getUnitByLocation1(cUnitTypeMinedResource, 0, shepherd_position, 5000.0, 0);
        }
        aiTaskUnitWork(gShepherd, temp);
        // Reset the query by using index 0
        getUnitByLocation1(cUnitTypeHuntable, 0, shepherd_position, 5000.0, 0);

        for(i = getUnitCountByLocation(cUnitTypeHuntable, 0, shepherd_position, 5000.0) - 1; >= 0)
        {
            i_huntable = getUnitByLocation1(cUnitTypeHuntable, 0, shepherd_position, 5000.0, i);
            i_huntable_position = kbUnitGetPosition(i_huntable);

            // Do not steal ally huntables.
            int closest_town_center = getUnitByLocation2(cUnitTypeTownCenter, cPlayerRelationAlly, i_huntable_position, 60.0, 0);
            if (closest_town_center >= 0 && kbUnitGetPlayerID(closest_town_center) != cMyID)
                continue;

            if (kbCanPath2(i_huntable_position, town_center_position, kbUnitGetProtoUnitID(i_huntable)) == false)
                continue;
            
            if (kbCanPath2(shepherd_position, i_huntable_position, kbUnitGetProtoUnitID(gShepherd)) == false)
                continue;

            if (xsVectorLength(town_center_position - i_huntable_position) < cHuntHerdingMinDistance)
                continue;
            
            if (xsVectorLength(town_center_position - i_huntable_position) > cHuntHerdingMaxDistance)
                continue;
            
            xsSetContextPlayer(0);
            float i_huntable_health = kbUnitGetHealth(i_huntable);
            xsSetContextPlayer(cMyID);
            
            if (i_huntable_health < 1.0)
                continue;
            
            i_huntable_hitpoints = kbUnitGetCurrentHitpoints(i_huntable);
            
            if (i_huntable_hitpoints >= highest_hitpoints)
            {
                highest_hitpoints = i_huntable_hitpoints;
                strongest_huntable = i_huntable;
            }
        }

        huntable = strongest_huntable;
        return;
    }

    if (xsGetTime() < last_shot + cFleeingHuntableTimeout - (1000 * distance_to_shooting_spot) / cVillagerVelocity)
        return;

    if (xsVectorLength(shepherd_position - town_center_position) > xsVectorLength(huntable_position - town_center_position) && 
        xsVectorLength(shepherd_position - shooting_spot) < xsVectorLength(huntable_position - shooting_spot) && 
        xsVectorLength(shepherd_position - huntable_position) < 12.0 && xsVectorLength(shepherd_position - huntable_position) > 6.0)
    {
        aiTaskUnitWork(gShepherd, huntable);
        huntable = -1;
        last_shot = xsGetTime();
        return;
    }

    aiTaskUnitMove(gShepherd, shooting_spot);
}
