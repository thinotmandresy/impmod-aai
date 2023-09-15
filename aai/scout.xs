rule GatherNuggetsLand
group rgStartup
inactive
{
    static int explore_plan = -1;

    static int age2_time = -1;
    if (age2_time == -1 && kbGetAge() >= cAge2)
        age2_time = xsGetTime();
    
    bool ok_to_gather_nuggets = (age2_time == -1) || (age2_time >= 0 && xsGetTime() < age2_time + cNuggetGatheringTimeout);
    if (age2_time >= 0 && gStrategy == cStrategyRush)
        ok_to_gather_nuggets = false;

    if (ok_to_gather_nuggets == false)
    {
        aiPlanDestroy(explore_plan);
        explore_plan = -1;
        xsEnableRuleGroup("rgLandExploration");
        gLandExploration = true;
        xsDisableSelf();
        return;
    }

    if (explore_plan == -1)
    {
        explore_plan = aiPlanCreate("Gather Nuggets", cPlanExplore);
        aiPlanSetDesiredPriority(explore_plan, 70);
        aiPlanAddUnitType(explore_plan, cUnitTypeHero, 1, 2, 5);
        aiPlanAddUnitType(explore_plan, cUnitTypeLogicalTypeScout, 4, 6, 8);
        aiPlanSetNoMoreUnits(explore_plan, false);
        aiPlanSetActive(explore_plan, true);
    }
}


rule ExploreLand
group rgLandExploration
inactive
runImmediately
{
    xsDisableSelf();

    int explore_plan = aiPlanCreate("Explore Land", cPlanExplore);
    aiPlanSetDesiredPriority(explore_plan, 70);
    aiPlanAddUnitType(explore_plan, cUnitTypeLogicalTypeValidSharpshoot, 1, 1, 1);
    aiPlanSetNoMoreUnits(explore_plan, false);
    aiPlanSetActive(explore_plan, true);
}


rule ExploreLandWithSpecialScouts
group rgLandExploration
inactive
minInterval 5
{
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeScout, cUnitStateAlive))
    {
        int i_scout = getUnit1(cUnitTypeLogicalTypeScout, cMyID, i);

        if (kbUnitGetProtoUnitID(i_scout) != cUnitTypeNativeScout && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypeypNativeScout && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypeNativeScoutF && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypeypMongolScout && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypeEnvoy && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypeHotAirBalloon && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypexpAdvancedBalloon && 
            kbUnitGetProtoUnitID(i_scout) != cUnitTypexpSpy)
        {
            continue;
        }

        if (kbUnitGetPlanID(i_scout) >= 0)
            continue;
        
        int new_explore_plan = aiPlanCreate("Special Explore Plan", cPlanExplore);
        aiPlanSetDesiredPriority(new_explore_plan, 100);
        aiPlanSetVariableFloat(new_explore_plan, cExplorePlanLOSMultiplier, (40 + aiRandInt(40)) / 10);
        aiPlanAddUnitType(new_explore_plan, kbUnitGetProtoUnitID(i_scout), 0, 0, 1);
        aiPlanAddUnit(new_explore_plan, i_scout);
        aiPlanSetNoMoreUnits(new_explore_plan, true);
        aiPlanSetActive(new_explore_plan, true);
    }
}


rule RescueKnockedOutUnits
group rgLandExploration
inactive
minInterval 1
{
    static int rescuer = -1;
    if (kbUnitGetCurrentHitpoints(rescuer) < 0.1)
        rescuer = -1;

    int knocked_out_unit = aiGetFallenExplorerID();
    if (kbUnitGetCurrentHitpoints(knocked_out_unit) < 110.0)
    {
        rescuer = -1;
        return;
    }
    vector knocked_out_unit_position = kbUnitGetPosition(knocked_out_unit);
    if (rescuer >= 0)
    {
        aiTaskUnitMove(rescuer, knocked_out_unit_position);
    }
    else
    {
        for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeScout, cUnitStateAlive))
        {
            int i_scout = getUnitByLocation1(cUnitTypeLogicalTypeScout, cMyID, knocked_out_unit_position, 5000.0, i);
            if (aiPlanGetType(kbUnitGetPlanID(i_scout)) == cPlanBuild)
                continue;
            
            vector i_scout_position = kbUnitGetPosition(i_scout);
            if (kbCanPath2(i_scout_position, knocked_out_unit_position, kbUnitGetProtoUnitID(i_scout)) == false)
                continue;
            
            rescuer = i_scout;
            aiTaskUnitMove(rescuer, knocked_out_unit_position);
            break;
        }
    }

    if (kbGetAge() == cAge1)
        return;

    static int last_ransom_attempt = 0;
    if (xsGetTime() < last_ransom_attempt + 120000)
        return;
    
    if (kbCanAffordUnit(kbUnitGetProtoUnitID(knocked_out_unit), cRootEscrowID) == false)
        return;
    
    int town_center = getUnit1(cUnitTypeTownCenter);
    if (town_center == -1)
        return;
    
    last_ransom_attempt = xsGetTime();
    aiTaskUnitTrain(town_center, kbUnitGetProtoUnitID(knocked_out_unit));
}


rule CaptureHerdables
group rgStartup
inactive
minInterval 1
{
    for(i = 0; < getUnitCountByLocation(cUnitTypeHerdable, 0, kbGetMapCenter(), 5000.0))
    {
        int i_herdable = getUnit1(cUnitTypeHerdable, 0, i);
        vector i_herdable_position = kbUnitGetPosition(i_herdable);
        for(j = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeScout, cUnitStateAlive))
        {
            int j_scout = getUnitByLocation1(cUnitTypeLogicalTypeScout, cMyID, i_herdable_position, 5000.0, j);
            if (kbUnitGetPlanID(j_scout) >= 0 && aiPlanGetState(kbUnitGetPlanID(j_scout)) != cPlanStateExplore)
                continue;
            
            vector j_scout_position = kbUnitGetPosition(j_scout);
            if (kbCanPath2(j_scout_position, i_herdable_position, kbUnitGetProtoUnitID(j_scout)) == false)
                continue;
            
            aiTaskUnitMove(j_scout, i_herdable_position);
            break;
        }
    }
}
