rule CreateMainBase
group rgStartup
inactive
runImmediately
{
    if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
    {
        xsEnableRule("HandleNomadStart");
        return;
    }

    xsDisableSelf();

    kbBaseDestroyAll(cMyID);

    int town_center = getUnit1(cUnitTypeTownCenter, cMyID, 0, cUnitStateABQ);
    vector base_location = kbUnitGetPosition(town_center);
    vector base_front = xsVectorNormalize(kbGetMapCenter() - base_location);

    int main_base = kbBaseCreate(cMyID, "Main Base", base_location, cMainBaseRadius);
    kbBaseSetSettlement(cMyID, main_base, true);
    kbBaseAddUnit(cMyID, main_base, town_center);
    kbBaseSetEconomy(cMyID, main_base, true);
    kbBaseSetMaximumResourceDistance(cMyID, main_base, cNaturalResourceDistance);
    kbBaseSetMilitary(cMyID, main_base, true);
    kbBaseSetMilitaryGatherPoint(cMyID, main_base, base_location + base_front * 40.0);
    kbBaseSetMain(cMyID, main_base, true);
    kbBaseSetFrontVector(cMyID, main_base, base_front);
    kbBaseSetActive(cMyID, main_base, true);

    gMainBase = true;
    xsEnableRule("rgMainBase");
}


rule HandleNomadStart
inactive
runImmediately
{
    if (cRandomMapName == "ceylon")
    {
        // TODO -- Migrate to the bigger island.
        // return;
    }

    xsDisableSelf();
    
    xsEnableRule("BuildNomadTownCenter");
}


rule BuildNomadTownCenter
inactive
runImmediately
{
    static bool init = true;
    int starting_unit = findWagonToBuildProtoUnit(cUnitTypeTownCenter);
    if (starting_unit == -1 && init == true)
    {
        // We started without a covered wagon.
        static bool notified = false;
        if (notified == false)
        {
            notifyAsFirstAI(kbGetPlayerName(cMyID) + " started without a Town Center and does not have a Covered Wagon.");
            notified = true;
        }
        return;
    }

    xsDisableSelf();
    init = false;

    vector starting_position = kbUnitGetPosition(starting_unit);

    int nomad_build_plan = aiPlanCreate("Build Nomad Town Center", cPlanBuild);
    aiPlanSetDesiredPriority(nomad_build_plan, 100);
    aiPlanSetEscrowID(nomad_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(nomad_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeTownCenter);

    aiPlanSetVariableVector(nomad_build_plan, cBuildPlanCenterPosition, 0, starting_position);
    aiPlanSetVariableFloat(nomad_build_plan, cBuildPlanCenterPositionDistance, 0, 60.00);

    aiPlanSetVariableVector(nomad_build_plan, cBuildPlanInfluencePosition, 0, starting_position);
    aiPlanSetVariableFloat(nomad_build_plan, cBuildPlanInfluencePositionDistance, 0, 100.0);
    aiPlanSetVariableFloat(nomad_build_plan, cBuildPlanInfluencePositionValue, 0, 300.0);
    aiPlanSetVariableInt(nomad_build_plan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);

    aiPlanSetVariableInt(nomad_build_plan, cBuildPlanBuildUnitID, 0, starting_unit);
    aiPlanAddUnitType(nomad_build_plan, kbUnitGetProtoUnitID(starting_unit), 0, 0, 1);
    aiPlanAddUnit(nomad_build_plan, starting_unit);

    aiPlanSetActive(nomad_build_plan, true);
}


rule MaintainTownCenters
group rgMainBase
inactive
minInterval 5
{
    if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeTownCenter))
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeTownCenter);

    if (builder == -1 && kbGetAge() <= cAge2)
    {
        if (aiGetWorldDifficulty() < cDifficultyHard || gStrategy == cStrategyBoom)
            return;
        
        if (aiGetWorldDifficulty() == cDifficultyHard && gStrategy == cStrategyBoom && ageingUp() == false)
            return;
    }
    
    vector builder_position = kbUnitGetPosition(builder);
    vector construction_location = getMainBaseLocation();
    if (kbBaseGetMainID(cMyID) == -1)
        construction_location = builder_position;
    
    int town_center_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTownCenter, true);
    if (town_center_build_plan >= 0 && 
        kbUnitIsType(aiPlanGetVariableInt(town_center_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
    {
        return;
    }

    town_center_build_plan = aiPlanCreate("Maintain Town Centers", cPlanBuild);
    aiPlanSetDesiredPriority(town_center_build_plan, 100);
    aiPlanSetEscrowID(town_center_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(town_center_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeTownCenter);
    aiPlanSetVariableFloat(town_center_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);
    
    aiPlanSetVariableVector(town_center_build_plan, cBuildPlanCenterPosition, 0, construction_location);
    aiPlanSetVariableFloat(town_center_build_plan, cBuildPlanCenterPositionDistance, 0, 80.00);

    aiPlanSetVariableInt(town_center_build_plan, cBuildPlanInfluenceUnitTypeID, 3, cUnitTypeTownCenter);
    aiPlanSetVariableFloat(town_center_build_plan, cBuildPlanInfluenceUnitDistance, 3, 60.0);
    aiPlanSetVariableFloat(town_center_build_plan, cBuildPlanInfluenceUnitValue, 3, -500.0);
    aiPlanSetVariableInt(town_center_build_plan, cBuildPlanInfluenceUnitFalloff, 3, cBPIFalloffNone);

    aiPlanSetVariableVector(town_center_build_plan, cBuildPlanInfluencePosition, 0, construction_location);
    aiPlanSetVariableFloat(town_center_build_plan, cBuildPlanInfluencePositionDistance, 0, 100.0);
    aiPlanSetVariableFloat(town_center_build_plan, cBuildPlanInfluencePositionValue, 0, 300.0);
    aiPlanSetVariableInt(town_center_build_plan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);

    aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyIWillBuildTC, construction_location);

    if (builder >= 0)
    {
        aiPlanSetVariableInt(town_center_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(town_center_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(town_center_build_plan, builder);
        aiPlanSetNoMoreUnits(town_center_build_plan, true);
    }
    else
    {
        aiPlanAddUnitType(town_center_build_plan, cUnitTypeHero, 2, 3, 5);
        aiPlanAddUnitType(town_center_build_plan, gUnitTypeVillager, 2, 2, 2);
        aiPlanSetNoMoreUnits(town_center_build_plan, false);
    }

    aiPlanSetActive(town_center_build_plan, true);
}
