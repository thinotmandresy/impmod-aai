void AutoGatherMilitary(void)
{
    if (gMainBase == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 10000)
        return;
    last_call = xsGetTime();

    vector map_center = kbGetMapCenter();
    vector main_base_center = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector direction = xsVectorNormalize(map_center - main_base_center);
    vector middle = main_base_center + direction * 60.0;
    vector left = rotate(middle, main_base_center, 35.0 * cDegToRad);
    vector right = rotate(middle, main_base_center, -35.0 * cDegToRad);

    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive))
    {
        int i_military_unit = getUnit1(cUnitTypeLogicalTypeLandMilitary, cMyID, i);
        vector i_military_unit_position = kbUnitGetPosition(i_military_unit);

        if (kbUnitGetPlanID(i_military_unit) >= 0)
            continue;
        // if (xsVectorLength(i_military_unit_position - main_base_center) < 50.0)
            // continue;
        if (kbCanPath2(i_military_unit_position, main_base_center, kbUnitGetProtoUnitID(i_military_unit)) == false)
            continue;

        // Make them scattered to avoid getting stuck
        aiTaskUnitMove(i_military_unit, getRandomPointInsideTriangle(main_base_center, left, right));
    }
}


void DefendMainBase(void)
{
    if (gMainBase == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 10000)
        return;
    last_call = xsGetTime();

    static int main_base_defend_plan = -1;

    int number_attackers = getUnitCountByLocation(cUnitTypeCountsTowardMilitaryScore, cPlayerRelationEnemyNotGaia, getMainBaseLocation(), 70.0);
    if (number_attackers <= 2)
    {
        aiPlanDestroy(main_base_defend_plan);
        main_base_defend_plan = -1;
        return;
    }
    
    if (kbGetAge() == cAge2)
        gStrategy = cStrategyRush;
    
    int number_defenders = xsMax(10, number_attackers + 10);

    if (main_base_defend_plan == -1)
    {
        main_base_defend_plan = aiPlanCreate("Defend Main Base", cPlanDefend);
        aiPlanAddUnitType(main_base_defend_plan, cUnitTypeLogicalTypeLandMilitary , 0, 0, 1);
        aiPlanSetVariableVector(main_base_defend_plan, cDefendPlanDefendPoint, 0, getMainBaseLocation());
        aiPlanSetVariableFloat(main_base_defend_plan, cDefendPlanEngageRange, 0, 120.0);
        aiPlanSetVariableFloat(main_base_defend_plan, cDefendPlanGatherDistance, 0, 8.0);
        aiPlanSetVariableBool(main_base_defend_plan, cDefendPlanPatrol, 0, false);
        aiPlanSetInitialPosition(main_base_defend_plan, getMainBaseLocation());
        aiPlanSetUnitStance(main_base_defend_plan, cUnitStanceDefensive);
        aiPlanSetVariableInt(main_base_defend_plan, cDefendPlanRefreshFrequency, 0, 1);
        aiPlanSetVariableInt(main_base_defend_plan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
        aiPlanSetDesiredPriority(main_base_defend_plan, 100);
        aiPlanSetActive(main_base_defend_plan, true);
    }

    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive))
    {
        int i_military_unit = getUnit1(cUnitTypeLogicalTypeLandMilitary, cMyID, i);
        if (aiPlanGetType(kbUnitGetPlanID(i_military_unit)) == cPlanBuild)
            continue;
        if (aiPlanGetType(kbUnitGetPlanID(i_military_unit)) == cPlanDefend)
            continue;
        
        vector i_military_unit_position = kbUnitGetPosition(i_military_unit);
        if (kbCanPath2(i_military_unit_position, getMainBaseLocation(), kbUnitGetProtoUnitID(i_military_unit)) == false)
            continue;
        
        aiPlanDestroy(kbUnitGetPlanID(i_military_unit));
        aiPlanAddUnit(main_base_defend_plan, i_military_unit);
        number_defenders--;
        if (number_defenders <= 0)
            break;
    }
}


void RingTheBell(void)
{
    if (gMainBase == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 1000)
        return;
    last_call = xsGetTime();

    xsEnableRule("ReturnToWork");
    
    bool military_exists = false;
    for(player = 1 ; < cNumberPlayers)
    {
        if (kbGetPlayerTeam(player) != cMyID)
            continue;
        military_exists = military_exists || kbGetAgeForPlayer(player) >= cAge2;
        if (military_exists)
            break;
    }
    
    if (military_exists == false)
        return;
    
    for(i = 0 ; < kbUnitCount(cMyID, cUnitTypeLogicalTypeAffectedByTownBell, cUnitStateAlive))
    {
        int i_villager = getUnit1(cUnitTypeLogicalTypeAffectedByTownBell, cMyID, i);
        vector i_villager_position = kbUnitGetPosition(i_villager);
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_villager)) != cMovementTypeLand)
            continue;
        if (kbUnitGetNumberTargeters(i_villager) + kbUnitGetNumberWorkersIfSeeable(i_villager) >= 1)
        {
            setFlag(i_villager, cFlagTownBell);
            aiQVSet(cFlagLastUnderAttackTime + i_villager, xsGetTime());
        }

        if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, i_villager_position, 30.0) >= 3)
        {
            setFlag(i_villager, cFlagTownBell);
            aiQVSet(cFlagLastSpookedTime + i_villager, xsGetTime());
        }
        
        if (isFlagged(i_villager, cFlagTownBell) == false)
            continue;
        
        bool fail = true;
        for(j = 0 ; < kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive))
        {
            int j_town_center = getUnitByLocation1(cUnitTypeTownCenter, cMyID, i_villager_position, 2000.0, j);
            vector j_town_center_position = kbUnitGetPosition(j_town_center);
            if (kbCanPath2(i_villager_position, j_town_center_position, kbUnitGetProtoUnitID(i_villager)) == false)
                continue;
            if (kbUnitGetNumberContained(j_town_center) >= 50)
                continue;
            aiTaskUnitWork(i_villager, j_town_center);
            fail = false;
            break;
        }
        if (fail) unsetFlag(i_villager, cFlagTownBell);
    }
}


rule ReturnToWork
inactive
minInterval 1
{
    for(i = 0 ; < kbUnitCount(cMyID, cUnitTypeLogicalTypeAffectedByTownBell, cUnitStateAlive))
    {
        int i_villager = getUnit1(cUnitTypeLogicalTypeAffectedByTownBell, cMyID, i);

        if (isFlagged(i_villager, cFlagTownBell) == false)
            continue;

        vector i_villager_position = kbUnitGetPosition(i_villager);

        if (kbUnitIsContainedInType(i_villager, "TownCenter") == false)
        {
            if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, i_villager_position, 30.0) >= 3)
                continue;
            if (kbUnitGetNumberTargeters(i_villager) + kbUnitGetNumberWorkersIfSeeable(i_villager) >= 1)
                continue;
            if (xsGetTime() < aiQVGet(cFlagLastUnderAttackTime + i_villager) + cVillagerRetreatTimeout)
                continue;
            if (xsGetTime() < aiQVGet(cFlagLastSpookedTime + i_villager) + cVillagerSpookedTimeout)
                continue;
            
            unsetFlag(i_villager, cFlagTownBell);
            aiTaskUnitMove(i_villager, i_villager_position);
        }
        else
        {
            if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, i_villager_position, cMainBaseRadius) <= 2)
            {
                unsetFlag(i_villager, cFlagTownBell);
                aiTaskUnitEject(getUnitByLocation1(cUnitTypeTownCenter, cMyID, i_villager_position, 10.0, 0));
            }
        }
    }
}
