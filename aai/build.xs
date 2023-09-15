// ================================================================================
// Keep building houses until we reach the build limit.
// ================================================================================
rule MaintainHouses
group rgMainBase
inactive
minInterval 5
{
    if (cMyCulture == cCultureSioux)
        return;
    
    if (kbProtoUnitAvailable(gUnitTypeHouse) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeHouse, cUnitStateABQ) >= kbGetBuildLimit(cMyID, gUnitTypeHouse) && kbGetBuildLimit(cMyID, gUnitTypeHouse) >= 1)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    if (kbGetAge() == cAge1 && ageingUp() == false && kbUnitCount(cMyID, gUnitTypeHouse, cUnitStateABQ) >= 1)
        return;
    
    // Temporarily sacrifice 10 worth of pop cap to build a Market.
    // TBD -- This doesn't seem like a good idea. Need more extensive testing to decide what happens and what to do.
    if (gUnitTypeMarket >= 0 && kbUnitCount(cMyID, gUnitTypeMarket, cUnitStateABQ) == 0 && kbUnitCount(cMyID, gUnitTypeHouse, cUnitStateABQ) >= 1)
        return;
    
    // TBD -- Should we let the AI build more houses even if there's already enough population space?
    if (kbGetPopCap() - kbGetPop() > 5 + 10 * kbGetAge())
        return;

    int house_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeHouse, true);

    if (house_build_plan >= 0 && kbResourceGet(cResourceWood) < 800.0 && 
        kbUnitIsType(aiPlanGetVariableInt(house_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeHouse);
    
    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    house_build_plan = aiPlanCreate("Maintain Houses", cPlanBuild);
    aiPlanSetEscrowID(house_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(house_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeHouse);
    aiPlanSetVariableFloat(house_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    bool main_base_under_attack = false;
    for(i = 0; < aiPlanGetNumber(cPlanDefend))
    {
        int i_defend_plan = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
        vector defend_point = aiPlanGetVariableVector(i_defend_plan, cDefendPlanDefendPoint, 0);
        if (xsVectorLength(getMainBaseLocation() - defend_point) < 50.0)
        {
            main_base_under_attack = true;
            break;
        }
    }

    if (kbProtoUnitIsType(cMyID, gUnitTypeHouse, cUnitTypeAbstractShrine) && main_base_under_attack == false)
    {
        vector construction_location = cInvalidVector;
        for(i = 0; < getUnitCountByLocation(cUnitTypeHuntable, 0, getMainBaseLocation(), 100.0))
        {
            int i_huntable = getUnitByLocation1(cUnitTypeHuntable, 0, getMainBaseLocation(), 100.0, i);
            vector i_huntable_position = kbUnitGetPosition(i_huntable);
            int num_nearby_huntables = getUnitCountByLocation(cUnitTypeHuntable, 0, i_huntable_position, 15.0);
            int num_nearby_shrines = getUnitCountByLocation(cUnitTypeAbstractShrine, cPlayerRelationAny, i_huntable_position, 25.0);

            bool this_position_is_good = false;

            if (num_nearby_huntables > num_nearby_shrines * 4)
            {
                for(j = 0; < getUnitCountByLocation(cUnitTypeTownCenter, cPlayerRelationAlly, i_huntable_position, 50.0))
                {
                    int j_town_center = getUnitByLocation2(cUnitTypeTownCenter, cPlayerRelationAlly, i_huntable_position, 50.0, j);
                    if (kbUnitGetPlayerID(j_town_center) == cMyID)
                        continue;
                    
                    if (xsVectorLength(kbUnitGetPosition(j_town_center) - getMainBaseLocation()) < 50.0)
                        continue;
                    
                    this_position_is_good = true;
                    break;
                }
            }

            if (this_position_is_good)
            {
                construction_location = i_huntable_position;
                break;
            }
        }
        
        if (construction_location == cInvalidVector)
        {
            // We need some space for herdables
            aiPlanSetVariableInt(house_build_plan, cBuildPlanInfluenceUnitTypeID, 0, gUnitTypeHouse);
            aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluenceUnitDistance, 0, 6.0);
            aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
            aiPlanSetVariableInt(house_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

            aiPlanSetBaseID(house_build_plan, kbBaseGetMainID(cMyID));
        }
        else
        {
            aiPlanSetVariableVector(house_build_plan, cBuildPlanCenterPosition, 0, construction_location);
            aiPlanSetVariableFloat(house_build_plan, cBuildPlanCenterPositionDistance, 0, 30.0);

            aiPlanSetVariableVector(house_build_plan, cBuildPlanInfluencePosition, 0, construction_location);
            aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluencePositionDistance, 0, 100.0);
            aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluencePositionValue, 0, 200.0);
            aiPlanSetVariableInt(house_build_plan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);
        }
    }
    else
    {
        construction_location = kbUnitGetPosition(getUnit1(cUnitTypeTownCenter, cMyID, 0, cUnitStateABQ));
        aiPlanSetVariableVector(house_build_plan, cBuildPlanCenterPosition, 0, construction_location);
        aiPlanSetVariableFloat(house_build_plan, cBuildPlanCenterPositionDistance, 0, 200.0);
        aiPlanSetVariableVector(house_build_plan, cBuildPlanInfluencePosition, 0, construction_location);
        aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluencePositionDistance, 0, 100.0);
        aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluencePositionValue, 0, 200.0);
        aiPlanSetVariableInt(house_build_plan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);
        aiPlanSetVariableInt(house_build_plan, cBuildPlanInfluenceUnitTypeID, 0, gUnitTypeHouse);
        aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluenceUnitDistance, 0, 6.0);
        aiPlanSetVariableFloat(house_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
        aiPlanSetVariableInt(house_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);
    }

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(house_build_plan, 100);
        aiPlanSetVariableInt(house_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(house_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(house_build_plan, builder);
        aiPlanSetNoMoreUnits(house_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(house_build_plan, 90);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(house_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(house_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(house_build_plan, false);
    }

    aiPlanSetActive(house_build_plan, true);
}


// ================================================================================
// Try to maintain one market in the main base.
// ================================================================================
rule MaintainMarket
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeMarket) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeMarket, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() == cAge1 && ageingUp() == false && gUnitTypeHouse >= 0 && kbUnitCount(cMyID, gUnitTypeHouse, cUnitStateABQ) == 0)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int market_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeMarket, true);

    if (market_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(market_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeMarket);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    market_build_plan = aiPlanCreate("Maintain Market", cPlanBuild);
    aiPlanSetEscrowID(market_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(market_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeMarket);
    aiPlanSetVariableFloat(market_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(market_build_plan, false);
    aiPlanSetMilitary(market_build_plan, true);
    aiPlanSetBaseID(market_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(market_build_plan, 100);
        aiPlanSetVariableInt(market_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(market_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(market_build_plan, builder);
        aiPlanSetNoMoreUnits(market_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(market_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(market_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(market_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(market_build_plan, false);
    }

    aiPlanSetActive(market_build_plan, true);
}


// ================================================================================
// Keep building Command Posts until we reach the build limit.
// ================================================================================
rule MaintainCommandPosts
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeSPCFortCenter) == false)
        return;
    
    if ((kbProtoUnitAvailable(gUnitTypeInfantryBuilding) == true && kbUnitCount(cMyID, gUnitTypeInfantryBuilding, cUnitStateABQ) == 0) || 
        (kbProtoUnitAvailable(gUnitTypeCavalryBuilding) == true && kbUnitCount(cMyID, gUnitTypeCavalryBuilding, cUnitStateABQ) == 0) || 
        (kbProtoUnitAvailable(gUnitTypeArtilleryBuilding) == true && kbUnitCount(cMyID, gUnitTypeArtilleryBuilding, cUnitStateABQ) == 0))
    {
        return;
    }
    
    if (kbUnitCount(cMyID, cUnitTypeSPCFortCenter, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeSPCFortCenter))
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int command_post_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSPCFortCenter, true);

    if (command_post_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(command_post_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeSPCFortCenter);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom && builder == -1 && ageingUp() == false)
        return;
    
    command_post_build_plan = aiPlanCreate("Maintain Command Posts", cPlanBuild);
    aiPlanSetEscrowID(command_post_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(command_post_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeSPCFortCenter);
    aiPlanSetVariableFloat(command_post_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(command_post_build_plan, false);
    aiPlanSetMilitary(command_post_build_plan, true);
    aiPlanSetBaseID(command_post_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(command_post_build_plan, 100);
        aiPlanSetVariableInt(command_post_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(command_post_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(command_post_build_plan, builder);
        aiPlanSetNoMoreUnits(command_post_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(command_post_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(command_post_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(command_post_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(command_post_build_plan, false);
    }

    aiPlanSetActive(command_post_build_plan, true);
}


// ================================================================================
// Build towers in circle around the main base, and keep building towers until we 
// reach the build limit
// ================================================================================
rule MaintainTowers
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeTowerBuilding) == false)
        return;
    
    // Research Tower Upgrades
    static int tower_upgrades = -1;
    if (tower_upgrades == -1)
    {
        tower_upgrades = xsArrayCreateInt(9, -1, "List of tower upgrades");
        xsArraySetInt(tower_upgrades, 0, cTechFrontierOutpost);
        xsArraySetInt(tower_upgrades, 1, cTechFortifiedOutpost);
        xsArraySetInt(tower_upgrades, 2, cTechStrongWarHut);
        xsArraySetInt(tower_upgrades, 3, cTechMightyWarHut);
        xsArraySetInt(tower_upgrades, 4, cTechFrontierBlockhouse);
        xsArraySetInt(tower_upgrades, 5, cTechFortifiedBlockhouse);
        xsArraySetInt(tower_upgrades, 6, cTechTownGuard);
        xsArraySetInt(tower_upgrades, 7, cTechypFrontierCastle);
        xsArraySetInt(tower_upgrades, 8, cTechypFortifiedCastle);
    }

    for (i = 0; < xsArrayGetSize(tower_upgrades))
    {
        int i_upgrade = xsArrayGetInt(tower_upgrades, i);
        if (kbTechGetStatus(i_upgrade) == cTechStatusObtainable)
        {
            if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, i_upgrade, true) == -1)
            {
                int tower_upgrade_plan = aiPlanCreate("Research Tower Upgrade " + kbGetTechName(i_upgrade), cPlanResearch);
                aiPlanSetDesiredPriority(tower_upgrade_plan, 100);
                aiPlanSetEscrowID(tower_upgrade_plan, cRootEscrowID);
                aiPlanSetVariableInt(tower_upgrade_plan, cResearchPlanTechID, 0, i_upgrade);
                aiPlanSetActive(tower_upgrade_plan, true);
            }
            break;
        }
    }
    
    // Edit (AlistairJah, Jul 7th 2022) -- Temporarily capping the limit to 7 to avoid plan auto-destruction
    int tower_build_limit = kbGetBuildLimit(cMyID, gUnitTypeTowerBuilding);
    if (tower_build_limit > 7)
        tower_build_limit = 7;
    if (kbUnitCount(cMyID, gUnitTypeTowerBuilding, cUnitStateABQ) >= tower_build_limit)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int tower_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeTowerBuilding, true);

    if (tower_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(tower_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeTowerBuilding);
    if (builder == -1)
    {
        if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
            return;

        if (kbGetAge() <= cAge1)
            return;
        
        if (kbGetAge() <= cAge2 && kbUnitCount(cMyID, gUnitTypeTowerBuilding, cUnitStateABQ) >= 2)
            return;
        
        if (gUnitTypeTowerBuilding != cUnitTypeBlockhouse && gUnitTypeTowerBuilding != cUnitTypeWarHut && kbGetAge() <= cAge2)
            return;
    }

    // Full code copied entirely from Age3DE AI
    tower_build_limit = kbGetBuildLimit(cMyID, gUnitTypeTowerBuilding);
    int attempts = 3 * tower_build_limit / 2;
    vector test_vec = cInvalidVector;
    static vector starting_vec = cInvalidVector;
    vector tc_pos = kbUnitGetPosition(getUnit1(cUnitTypeTownCenter, cMyID, 0, cUnitStateABQ));
    int num_test_vecs = 5 * tower_build_limit / 4;
    float tower_angle = (2.0 * PI) / num_test_vecs;
    // Mid- and corner-spots on a square with 'radius' spacing_distance, i.e. each side is 2 * spacing_distance.
    float spacing_distance = 24 * xsSin((PI - tower_angle) / 2.0) / xsSin(tower_angle); 
    float exclusion_radius = spacing_distance / 2.0;
    
    bool success = false;
    
    if (starting_vec == cInvalidVector)
    {
        starting_vec = tc_pos;
        starting_vec = xsVectorSetX(starting_vec, xsVectorGetX(starting_vec) + spacing_distance);
        vector start_to_base = starting_vec - tc_pos;
        float random_angle = aiRandInt(360) / (180.0 / PI);

        starting_vec = xsVectorSet(xsVectorGetX(start_to_base) * xsCos(random_angle) - xsVectorGetZ(start_to_base) * xsSin(random_angle) + xsVectorGetX(getMainBaseLocation()),
                                   0.0,
                                   xsVectorGetX(start_to_base) * xsSin(random_angle) + xsVectorGetZ(start_to_base) * xsCos(random_angle) + xsVectorGetZ(getMainBaseLocation()));
    }
    
    for (attempt = 0; < attempts)
    {
        random_angle = tower_angle * aiRandInt(num_test_vecs);
        start_to_base = starting_vec - tc_pos;
        test_vec = xsVectorSet(xsVectorGetX(start_to_base) * xsCos(random_angle) - xsVectorGetZ(start_to_base) * xsSin(random_angle) + xsVectorGetX(getMainBaseLocation()),
                               0.0,
                               xsVectorGetX(start_to_base) * xsSin(random_angle) + xsVectorGetZ(start_to_base) * xsCos(random_angle) + xsVectorGetZ(getMainBaseLocation()));
        
        if (getUnitCountByLocation(gUnitTypeTowerBuilding, cPlayerRelationAny, test_vec, exclusion_radius) == 0)
        {
            if (kbAreaGroupGetIDByPosition(test_vec) == kbAreaGroupGetIDByPosition(tc_pos))
            {
                success = true;
                break;
            }
        }
    }
    
    // We have found a location (success == true) or we need to just do a brute force placement around the TC.
    if (success == false)
        test_vec = tc_pos;
    
    tower_build_plan = aiPlanCreate("Maintain Towers", cPlanBuild);
    aiPlanSetEscrowID(tower_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(tower_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeTowerBuilding);
    aiPlanSetVariableFloat(tower_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);
    
    // Instead of base ID or areas, use a center position and falloff.
    aiPlanSetVariableVector(tower_build_plan, cBuildPlanCenterPosition, 0, test_vec);
    if (success)
        aiPlanSetVariableFloat(tower_build_plan, cBuildPlanCenterPositionDistance, 0, exclusion_radius);
    else
        aiPlanSetVariableFloat(tower_build_plan, cBuildPlanCenterPositionDistance, 0, 50.0);
    
    // Add position influence for nearby towers, this doesn't work when the allied tower is a different PUID.
    aiPlanSetVariableInt(tower_build_plan, cBuildPlanInfluenceUnitTypeID, 0, gUnitTypeTowerBuilding);
    aiPlanSetVariableFloat(tower_build_plan, cBuildPlanInfluenceUnitDistance, 0, spacing_distance);
    aiPlanSetVariableFloat(tower_build_plan, cBuildPlanInfluenceUnitValue, 0, -20.0);
    aiPlanSetVariableInt(tower_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);
    
    // Weight it to stay very close to center point.
    aiPlanSetVariableVector(tower_build_plan, cBuildPlanInfluencePosition, 0, test_vec);
    aiPlanSetVariableFloat(tower_build_plan, cBuildPlanInfluencePositionDistance, 0, exclusion_radius);
    aiPlanSetVariableFloat(tower_build_plan, cBuildPlanInfluencePositionValue, 0, 10.0);
    aiPlanSetVariableInt(tower_build_plan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(tower_build_plan, 100);
        aiPlanSetVariableInt(tower_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(tower_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(tower_build_plan, builder);
        aiPlanSetNoMoreUnits(tower_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(tower_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(tower_build_plan, cUnitTypeAbstractVillager, 4, 4, 4);
        else
            aiPlanAddUnitType(tower_build_plan, gUnitTypeVillager, 4, 4, 4);
        aiPlanSetNoMoreUnits(tower_build_plan, false);
    }

    aiPlanSetActive(tower_build_plan, true);
}


// ================================================================================
// Try to maintain a certain number of infantry building in the main base depending
// on the current Age.
// ================================================================================
rule MaintainInfantryBuildings
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeInfantryBuilding) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeInfantryBuilding, cUnitStateABQ) >= kbGetAge())
        return;
    
    if ((kbGetAge() >= cAge3) && (gUnitTypeInfantryBuilding == cUnitTypeBlockhouse || gUnitTypeInfantryBuilding == cUnitTypeWarHut))
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    bool no_infantry_plan = true;
    for(i = 0; < aiPlanGetNumber(cPlanTrain))
    {
        int i_train_plan = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
        int i_unit_to_train = aiPlanGetVariableInt(i_train_plan, cTrainPlanUnitType, 0);
        if (kbProtoUnitCanSpawn(gUnitTypeInfantryBuilding, i_unit_to_train) == true)
        {
            no_infantry_plan = false;
            break;
        }
    }

    if (no_infantry_plan)
        return;
    
    int infantry_building_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeInfantryBuilding, true);

    if (infantry_building_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(infantry_building_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeInfantryBuilding);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom && builder == -1 && ageingUp() == false)
        return;
    
    infantry_building_build_plan = aiPlanCreate("Maintain Infantry Buildings", cPlanBuild);
    aiPlanSetEscrowID(infantry_building_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(infantry_building_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeInfantryBuilding);
    aiPlanSetVariableFloat(infantry_building_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(infantry_building_build_plan, false);
    aiPlanSetMilitary(infantry_building_build_plan, true);
    aiPlanSetBaseID(infantry_building_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(infantry_building_build_plan, 100);
        aiPlanSetVariableInt(infantry_building_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(infantry_building_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(infantry_building_build_plan, builder);
        aiPlanSetNoMoreUnits(infantry_building_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(infantry_building_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(infantry_building_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(infantry_building_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(infantry_building_build_plan, false);
    }

    aiPlanSetActive(infantry_building_build_plan, true);
}


// ================================================================================
// Try to maintain a certain number of cavalry building in the main base depending
// on the current Age.
// ================================================================================
rule MaintainCavalryBuildings
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeCavalryBuilding) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeCavalryBuilding, cUnitStateABQ) >= kbGetAge())
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    bool no_cavalry_plan = true;
    for(i = 0; < aiPlanGetNumber(cPlanTrain))
    {
        int i_train_plan = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
        int i_unit_to_train = aiPlanGetVariableInt(i_train_plan, cTrainPlanUnitType, 0);
        if (kbProtoUnitCanSpawn(gUnitTypeCavalryBuilding, i_unit_to_train) == true)
        {
            no_cavalry_plan = false;
            break;
        }
    }

    if (no_cavalry_plan)
        return;
    
    int cavalry_building_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeCavalryBuilding, true);

    if (cavalry_building_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(cavalry_building_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeCavalryBuilding);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom && builder == -1 && ageingUp() == false)
        return;
    
    cavalry_building_build_plan = aiPlanCreate("Maintain Cavalry Buildings", cPlanBuild);
    aiPlanSetEscrowID(cavalry_building_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(cavalry_building_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeCavalryBuilding);
    aiPlanSetVariableFloat(cavalry_building_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(cavalry_building_build_plan, false);
    aiPlanSetMilitary(cavalry_building_build_plan, true);
    aiPlanSetBaseID(cavalry_building_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(cavalry_building_build_plan, 100);
        aiPlanSetVariableInt(cavalry_building_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(cavalry_building_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(cavalry_building_build_plan, builder);
        aiPlanSetNoMoreUnits(cavalry_building_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(cavalry_building_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(cavalry_building_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(cavalry_building_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(cavalry_building_build_plan, false);
    }

    aiPlanSetActive(cavalry_building_build_plan, true);
}


// ================================================================================
// Try to maintain a certain number of artillery building in the main base
// depending on the current Age.
// ================================================================================
rule MaintainArtilleryBuildings
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeArtilleryBuilding) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeArtilleryBuilding, cUnitStateABQ) >= kbGetAge())
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    bool no_artillery_plan = true;
    for(i = 0; < aiPlanGetNumber(cPlanTrain))
    {
        int i_train_plan = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
        int i_unit_to_train = aiPlanGetVariableInt(i_train_plan, cTrainPlanUnitType, 0);
        if (kbProtoUnitCanSpawn(gUnitTypeArtilleryBuilding, i_unit_to_train) == true)
        {
            no_artillery_plan = false;
            break;
        }
    }

    if (no_artillery_plan)
        return;
    
    int artillery_building_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeArtilleryBuilding, true);

    if (artillery_building_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(artillery_building_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeArtilleryBuilding);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom && builder == -1 && ageingUp() == false)
        return;
    
    artillery_building_build_plan = aiPlanCreate("Maintain Artillery Buildings", cPlanBuild);
    aiPlanSetEscrowID(artillery_building_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(artillery_building_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeArtilleryBuilding);
    aiPlanSetVariableFloat(artillery_building_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(artillery_building_build_plan, false);
    aiPlanSetMilitary(artillery_building_build_plan, true);
    aiPlanSetBaseID(artillery_building_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(artillery_building_build_plan, 100);
        aiPlanSetVariableInt(artillery_building_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(artillery_building_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(artillery_building_build_plan, builder);
        aiPlanSetNoMoreUnits(artillery_building_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(artillery_building_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(artillery_building_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(artillery_building_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(artillery_building_build_plan, false);
    }

    aiPlanSetActive(artillery_building_build_plan, true);
}


// ================================================================================
// Try to maintain one mercenary building in the main base.
// ================================================================================
rule MaintainMercenaryBuilding
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeMercenaryBuilding) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeMercenaryBuilding, cUnitStateABQ) >= 1)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int mercenary_building_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeMercenaryBuilding, true);

    if (mercenary_building_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeMercenaryBuilding);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom && builder == -1 && ageingUp() == false)
        return;
    
    mercenary_building_build_plan = aiPlanCreate("Maintain Mercenary Buildings", cPlanBuild);
    aiPlanSetEscrowID(mercenary_building_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(mercenary_building_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeMercenaryBuilding);
    aiPlanSetVariableFloat(mercenary_building_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(mercenary_building_build_plan, false);
    aiPlanSetMilitary(mercenary_building_build_plan, true);
    aiPlanSetBaseID(mercenary_building_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(mercenary_building_build_plan, 100);
        aiPlanSetVariableInt(mercenary_building_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(mercenary_building_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(mercenary_building_build_plan, builder);
        aiPlanSetNoMoreUnits(mercenary_building_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(mercenary_building_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(mercenary_building_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(mercenary_building_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(mercenary_building_build_plan, false);
    }

    aiPlanSetActive(mercenary_building_build_plan, true);
}


// ================================================================================
// Try to maintain at least one religious building in the main base.
// ================================================================================
rule MaintainReligiousBuildings
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(gUnitTypeReligiousBuilding) == false)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeReligiousBuilding, cUnitStateABQ) >= 1)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int religious_building_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeReligiousBuilding, true);

    if (religious_building_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeReligiousBuilding);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    if (kbGetAge() <= cAge2 && builder == -1 && ageingUp() == false)
        return;
    
    religious_building_build_plan = aiPlanCreate("Maintain Religious Buildings", cPlanBuild);
    aiPlanSetEscrowID(religious_building_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(religious_building_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeReligiousBuilding);
    aiPlanSetVariableFloat(religious_building_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(religious_building_build_plan, false);
    aiPlanSetMilitary(religious_building_build_plan, true);
    aiPlanSetBaseID(religious_building_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(religious_building_build_plan, 100);
        aiPlanSetVariableInt(religious_building_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(religious_building_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(religious_building_build_plan, builder);
        aiPlanSetNoMoreUnits(religious_building_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(religious_building_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(religious_building_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(religious_building_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(religious_building_build_plan, false);
    }

    aiPlanSetActive(religious_building_build_plan, true);
}


// ================================================================================
// Build a cherry orchard for each orchard rickshaw we have.
// ================================================================================
rule MaintainCherryOrchards
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypBerryBuilding) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypBerryBuilding);
    if (builder == -1)
        return;

    int cherry_orchard_build_plan = aiPlanCreate("Maintain Cherry Orchards", cPlanBuild);
    aiPlanSetEscrowID(cherry_orchard_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(cherry_orchard_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypBerryBuilding);
    aiPlanSetVariableFloat(cherry_orchard_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetBaseID(cherry_orchard_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(cherry_orchard_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeypBerryBuilding);
    aiPlanSetVariableFloat(cherry_orchard_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(cherry_orchard_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(cherry_orchard_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    aiPlanSetDesiredPriority(cherry_orchard_build_plan, 100);
    aiPlanSetVariableInt(cherry_orchard_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(cherry_orchard_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(cherry_orchard_build_plan, builder);
    aiPlanSetNoMoreUnits(cherry_orchard_build_plan, true);

    aiPlanSetActive(cherry_orchard_build_plan, true);
}


// ================================================================================
// Build a mango grove for each grove rickshaw we have.
// ================================================================================
rule MaintainMangoGroves
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypGroveBuilding) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypGroveBuilding);
    if (builder == -1)
        return;

    int mango_grove_build_plan = aiPlanCreate("Maintain Mango Groves", cPlanBuild);
    aiPlanSetEscrowID(mango_grove_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(mango_grove_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypGroveBuilding);
    aiPlanSetVariableFloat(mango_grove_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetBaseID(mango_grove_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(mango_grove_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeypGroveBuilding);
    aiPlanSetVariableFloat(mango_grove_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(mango_grove_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(mango_grove_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    aiPlanSetDesiredPriority(mango_grove_build_plan, 100);
    aiPlanSetVariableInt(mango_grove_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(mango_grove_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(mango_grove_build_plan, builder);
    aiPlanSetNoMoreUnits(mango_grove_build_plan, true);

    aiPlanSetActive(mango_grove_build_plan, true);
}


// ================================================================================
// Build a lumber camp for each lumber camp wagon we have.
// ================================================================================
rule MaintainLumberCamps
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeLumberCamp) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeLumberCamp);
    if (builder == -1)
        return;

    int lumber_camp_build_plan = aiPlanCreate("Maintain Lumber Camps", cPlanBuild);
    aiPlanSetEscrowID(lumber_camp_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(lumber_camp_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeLumberCamp);
    aiPlanSetVariableFloat(lumber_camp_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetBaseID(lumber_camp_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(lumber_camp_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeLumberCamp);
    aiPlanSetVariableFloat(lumber_camp_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(lumber_camp_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(lumber_camp_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    aiPlanSetDesiredPriority(lumber_camp_build_plan, 100);
    aiPlanSetVariableInt(lumber_camp_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(lumber_camp_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(lumber_camp_build_plan, builder);
    aiPlanSetNoMoreUnits(lumber_camp_build_plan, true);

    aiPlanSetActive(lumber_camp_build_plan, true);
}


// ================================================================================
// Build a factory for each factory wagon we have.
// ================================================================================
rule MaintainFactories
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeFactory) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeFactory, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeFactory))
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int factory_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeFactory, true);

    if (factory_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(factory_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeFactory);
    if (builder == -1)
    {
        if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
            return;

        if (kbUnitCount(cMyID, cUnitTypeArchitect, cUnitStateAlive) == 0)
            return;
    }

    factory_build_plan = aiPlanCreate("Maintain Factories", cPlanBuild);
    aiPlanSetEscrowID(factory_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(factory_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeFactory);
    aiPlanSetVariableFloat(factory_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetEconomy(factory_build_plan, true);
    aiPlanSetMilitary(factory_build_plan, false);
    aiPlanSetBaseID(factory_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(factory_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeFactory);
    aiPlanSetVariableFloat(factory_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(factory_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(factory_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    if (builder >= 0)
    {
        aiPlanSetDesiredPriority(factory_build_plan, 100);
        aiPlanSetVariableInt(factory_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(factory_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(factory_build_plan, builder);
        aiPlanSetNoMoreUnits(factory_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(factory_build_plan, 50);
        aiPlanAddUnitType(factory_build_plan, cUnitTypeArchitect, 1, 1, 1);
        aiPlanSetNoMoreUnits(factory_build_plan, false);
    }

    aiPlanSetActive(factory_build_plan, true);
}


// ================================================================================
// Keep building banks until we reach the build limit.
// ================================================================================
rule MaintainDutchBanks
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeBank) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int dutch_bank_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeBank, true);

    if (dutch_bank_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(dutch_bank_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeBank);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    dutch_bank_build_plan = aiPlanCreate("Maintain Dutch Banks", cPlanBuild);
    aiPlanSetEscrowID(dutch_bank_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(dutch_bank_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeBank);
    aiPlanSetVariableFloat(dutch_bank_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetEconomy(dutch_bank_build_plan, true);
    aiPlanSetMilitary(dutch_bank_build_plan, false);
    aiPlanSetBaseID(dutch_bank_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(dutch_bank_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBank);
    aiPlanSetVariableFloat(dutch_bank_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(dutch_bank_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(dutch_bank_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    if (builder >= 0)
    {
        aiPlanSetDesiredPriority(dutch_bank_build_plan, 100);
        aiPlanSetVariableInt(dutch_bank_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(dutch_bank_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(dutch_bank_build_plan, builder);
        aiPlanSetNoMoreUnits(dutch_bank_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(dutch_bank_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(dutch_bank_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(dutch_bank_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(dutch_bank_build_plan, false);
    }

    aiPlanSetActive(dutch_bank_build_plan, true);
}


// ================================================================================
// Keep building banks until we reach the build limit.
// ================================================================================
rule MaintainAsianBanks
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypBankAsian) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int asian_bank_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypBankAsian, true);

    if (asian_bank_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(asian_bank_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypBankAsian);
    if (builder == -1)
        return;

    asian_bank_build_plan = aiPlanCreate("Maintain Asian Banks", cPlanBuild);
    aiPlanSetEscrowID(asian_bank_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(asian_bank_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypBankAsian);
    aiPlanSetVariableFloat(asian_bank_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetEconomy(asian_bank_build_plan, true);
    aiPlanSetMilitary(asian_bank_build_plan, false);
    aiPlanSetBaseID(asian_bank_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(asian_bank_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeypBankAsian);
    aiPlanSetVariableFloat(asian_bank_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(asian_bank_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(asian_bank_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    aiPlanSetDesiredPriority(asian_bank_build_plan, 100);
    aiPlanSetVariableInt(asian_bank_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(asian_bank_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(asian_bank_build_plan, builder);
    aiPlanSetNoMoreUnits(asian_bank_build_plan, true);

    aiPlanSetActive(asian_bank_build_plan, true);
}


// ================================================================================
// Try to maintain one consulate in the main base.
// ================================================================================
rule MaintainConsulate
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypConsulate) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeypConsulate, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() <= cAge2)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int consulate_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypConsulate, true);

    if (consulate_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypConsulate);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    consulate_build_plan = aiPlanCreate("Maintain Consulate", cPlanBuild);
    aiPlanSetEscrowID(consulate_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(consulate_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypConsulate);
    aiPlanSetVariableFloat(consulate_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(consulate_build_plan, false);
    aiPlanSetMilitary(consulate_build_plan, true);
    aiPlanSetBaseID(consulate_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(consulate_build_plan, 100);
        aiPlanSetVariableInt(consulate_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(consulate_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(consulate_build_plan, builder);
        aiPlanSetNoMoreUnits(consulate_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(consulate_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(consulate_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(consulate_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(consulate_build_plan, false);
    }

    aiPlanSetActive(consulate_build_plan, true);
}


// ================================================================================
// Try to maintain one FirePit in the main base.
// ================================================================================
rule MaintainFirePit
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeFirePit) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeFirePit, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() <= cAge1)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int firepit_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeFirePit, true);

    if (firepit_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeFirePit);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    firepit_build_plan = aiPlanCreate("Maintain FirePit", cPlanBuild);
    aiPlanSetEscrowID(firepit_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(firepit_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeFirePit);
    aiPlanSetVariableFloat(firepit_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(firepit_build_plan, true);
    aiPlanSetMilitary(firepit_build_plan, false);
    aiPlanSetBaseID(firepit_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(firepit_build_plan, 100);
        aiPlanSetVariableInt(firepit_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(firepit_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(firepit_build_plan, builder);
        aiPlanSetNoMoreUnits(firepit_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(firepit_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(firepit_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(firepit_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(firepit_build_plan, false);
    }

    aiPlanSetActive(firepit_build_plan, true);
}


// ================================================================================
// Build a dojo for each dojo wagon we have.
// ================================================================================
rule MaintainDojos
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypDojo) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypDojo);
    if (builder == -1)
        return;

    int dojo_build_plan = aiPlanCreate("Maintain Dojos", cPlanBuild);
    aiPlanSetEscrowID(dojo_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(dojo_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypDojo);
    aiPlanSetVariableFloat(dojo_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetEconomy(dojo_build_plan, true);
    aiPlanSetMilitary(dojo_build_plan, false);
    aiPlanSetBaseID(dojo_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(dojo_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeypDojo);
    aiPlanSetVariableFloat(dojo_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(dojo_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(dojo_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    aiPlanSetDesiredPriority(dojo_build_plan, 100);
    aiPlanSetVariableInt(dojo_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(dojo_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(dojo_build_plan, builder);
    aiPlanSetNoMoreUnits(dojo_build_plan, true);

    aiPlanSetActive(dojo_build_plan, true);
}


// ================================================================================
// Try to maintain one arsenal in the main base.
// ================================================================================
rule MaintainEuropeanArsenal
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeArsenal) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeArsenal, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() <= cAge2)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    if (kbUnitCount(cMyID, gUnitTypeInfantryBuilding, cUnitStateABQ)
        + kbUnitCount(cMyID, gUnitTypeCavalryBuilding, cUnitStateABQ)
        + kbUnitCount(cMyID, gUnitTypeArtilleryBuilding, cUnitStateABQ) == 0)
    {
        return;
    }
    
    int european_arsenal_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeArsenal, true);

    if (european_arsenal_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeArsenal);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    european_arsenal_build_plan = aiPlanCreate("Maintain European Arsenal", cPlanBuild);
    aiPlanSetEscrowID(european_arsenal_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(european_arsenal_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeArsenal);
    aiPlanSetVariableFloat(european_arsenal_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(european_arsenal_build_plan, false);
    aiPlanSetMilitary(european_arsenal_build_plan, true);
    aiPlanSetBaseID(european_arsenal_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(european_arsenal_build_plan, 100);
        aiPlanSetVariableInt(european_arsenal_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(european_arsenal_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(european_arsenal_build_plan, builder);
        aiPlanSetNoMoreUnits(european_arsenal_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(european_arsenal_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(european_arsenal_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(european_arsenal_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(european_arsenal_build_plan, false);
    }

    aiPlanSetActive(european_arsenal_build_plan, true);
}


// ================================================================================
// Try to maintain one arsenal in the main base.
// ================================================================================
rule MaintainOttomanArsenal
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypArsenalOttoman) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeypArsenalOttoman, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() <= cAge2)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int ottoman_arsenal_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypArsenalOttoman, true);
    if (ottoman_arsenal_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypArsenalOttoman);
    if (builder == -1)
        return;

    ottoman_arsenal_build_plan = aiPlanCreate("Maintain Ottoman Arsenal", cPlanBuild);
    aiPlanSetEscrowID(ottoman_arsenal_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(ottoman_arsenal_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypArsenalOttoman);
    aiPlanSetVariableFloat(ottoman_arsenal_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(ottoman_arsenal_build_plan, false);
    aiPlanSetMilitary(ottoman_arsenal_build_plan, true);
    aiPlanSetBaseID(ottoman_arsenal_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetDesiredPriority(ottoman_arsenal_build_plan, 100);
    aiPlanSetVariableInt(ottoman_arsenal_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(ottoman_arsenal_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(ottoman_arsenal_build_plan, builder);
    aiPlanSetNoMoreUnits(ottoman_arsenal_build_plan, true);

    aiPlanSetActive(ottoman_arsenal_build_plan, true);
}


// ================================================================================
// Try to maintain one arsenal in the main base.
// ================================================================================
rule MaintainAsianArsenal
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeypArsenalAsian) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeypArsenalAsian, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() <= cAge2)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int asian_arsenal_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypArsenalAsian, true);
    if (asian_arsenal_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeypArsenalAsian);
    if (builder == -1)
        return;

    asian_arsenal_build_plan = aiPlanCreate("Maintain Asian Arsenal", cPlanBuild);
    aiPlanSetEscrowID(asian_arsenal_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(asian_arsenal_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeypArsenalAsian);
    aiPlanSetVariableFloat(asian_arsenal_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(asian_arsenal_build_plan, false);
    aiPlanSetMilitary(asian_arsenal_build_plan, true);
    aiPlanSetBaseID(asian_arsenal_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetDesiredPriority(asian_arsenal_build_plan, 100);
    aiPlanSetVariableInt(asian_arsenal_build_plan, cBuildPlanBuildUnitID, 0, builder);
    aiPlanAddUnitType(asian_arsenal_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
    aiPlanAddUnit(asian_arsenal_build_plan, builder);
    aiPlanSetNoMoreUnits(asian_arsenal_build_plan, true);

    aiPlanSetActive(asian_arsenal_build_plan, true);
}


// ================================================================================
// Try to maintain one capitol in the main base.
// ================================================================================
rule MaintainCapitol
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeCapitol) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeCapitol, cUnitStateABQ) >= 1)
        return;
    
    if (kbGetAge() <= cAge3)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int capitol_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeCapitol, true);

    if (capitol_build_plan >= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeCapitol);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    capitol_build_plan = aiPlanCreate("Maintain Capitol", cPlanBuild);
    aiPlanSetEscrowID(capitol_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(capitol_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeCapitol);
    aiPlanSetVariableFloat(capitol_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(capitol_build_plan, false);
    aiPlanSetMilitary(capitol_build_plan, true);
    aiPlanSetBaseID(capitol_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(capitol_build_plan, 100);
        aiPlanSetVariableInt(capitol_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(capitol_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(capitol_build_plan, builder);
        aiPlanSetNoMoreUnits(capitol_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(capitol_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(capitol_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(capitol_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(capitol_build_plan, false);
    }

    aiPlanSetActive(capitol_build_plan, true);
}


// ================================================================================
// Try to maintain the appropriate number of farms.
// ================================================================================
rule MaintainFarms
group rgMainBase
inactive
minInterval 5
{
    if (gTimeToFarm == false)
        return;
    
    if (kbProtoUnitAvailable(gUnitTypeFarm) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int farm_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypeFarm, true);
    if (farm_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(farm_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int number_gatherers = 0;
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive))
    {
        int i_villager = getUnit1(cUnitTypeAbstractVillager, cMyID, i);
        if (kbUnitIsType(i_villager, cUnitTypeAbstractWagon))
            continue;
        
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_villager)) != cMovementTypeLand)
            continue;
        
        number_gatherers++;
    }

    int number_food_gatherers = number_gatherers * aiGetResourceGathererPercentage(cResourceFood);
    int number_farms = 0;

    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive))
    {
        int i_building = getUnit1(cUnitTypeLogicalTypeBuildingsNotWalls, cMyID, i, cUnitStateAlive);

        if (kbUnitIsType(i_building, cUnitTypeMill) || kbUnitIsType(i_building, cUnitTypeFarm) || 
            (kbUnitIsType(i_building, cUnitTypeypRicePaddy) && aiUnitGetTactic(i_building) == cTacticPaddyFood))
        {
            number_farms++;
        }
    }

    int number_unassigned_food_gatherers = number_food_gatherers;

    while(number_farms >= 1)
    {
        number_unassigned_food_gatherers = number_unassigned_food_gatherers - 10;
        number_farms--;
    }

    if (number_unassigned_food_gatherers <= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypeFarm);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    farm_build_plan = aiPlanCreate("Maintain Farms", cPlanBuild);
    aiPlanSetEscrowID(farm_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(farm_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypeFarm);
    aiPlanSetVariableFloat(farm_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(farm_build_plan, true);
    aiPlanSetMilitary(farm_build_plan, false);
    aiPlanSetBaseID(farm_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(farm_build_plan, 100);
        aiPlanSetVariableInt(farm_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(farm_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(farm_build_plan, builder);
        aiPlanSetNoMoreUnits(farm_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(farm_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(farm_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(farm_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(farm_build_plan, false);
    }

    aiPlanSetActive(farm_build_plan, true);
}


// ================================================================================
// Try to maintain the appropriate number of plantations.
// ================================================================================
rule MaintainPlantations
group rgMainBase
inactive
minInterval 5
{
    if (gTimeForPlantation == false)
        return;
    
    if (kbProtoUnitAvailable(gUnitTypePlantation) == false)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int plantation_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gUnitTypePlantation, true);
    if (plantation_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(plantation_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int number_gatherers = 0;
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive))
    {
        int i_villager = getUnit1(cUnitTypeAbstractVillager, cMyID, i);
        if (kbUnitIsType(i_villager, cUnitTypeAbstractWagon))
            continue;
        
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_villager)) != cMovementTypeLand)
            continue;
        
        number_gatherers++;
    }

    int number_gold_gatherers = number_gatherers * aiGetResourceGathererPercentage(cResourceGold);
    int number_plantations = 0;

    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive))
    {
        int i_building = getUnit1(cUnitTypeLogicalTypeBuildingsNotWalls, cMyID, i, cUnitStateAlive);

        if (kbUnitIsType(i_building, cUnitTypePlantation) || 
            (kbUnitIsType(i_building, cUnitTypeypRicePaddy) && aiUnitGetTactic(i_building) == cTacticPaddyCoin))
        {
            number_plantations++;
        }
    }

    int number_unassigned_gold_gatherers = number_gold_gatherers;

    while(number_plantations >= 1)
    {
        number_unassigned_gold_gatherers = number_unassigned_gold_gatherers - 10;
        number_plantations--;
    }

    if (number_unassigned_gold_gatherers <= 0)
        return;
    
    int builder = findWagonToBuildProtoUnit(gUnitTypePlantation);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;

    plantation_build_plan = aiPlanCreate("Maintain Plantations", cPlanBuild);
    aiPlanSetEscrowID(plantation_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(plantation_build_plan, cBuildPlanBuildingTypeID, 0, gUnitTypePlantation);
    aiPlanSetVariableFloat(plantation_build_plan, cBuildPlanBuildingBufferSpace, 0, 5.0);

    aiPlanSetEconomy(plantation_build_plan, true);
    aiPlanSetMilitary(plantation_build_plan, false);
    aiPlanSetBaseID(plantation_build_plan, kbBaseGetMainID(cMyID));

    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(plantation_build_plan, 100);
        aiPlanSetVariableInt(plantation_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(plantation_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(plantation_build_plan, builder);
        aiPlanSetNoMoreUnits(plantation_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(plantation_build_plan, 50);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(plantation_build_plan, cUnitTypeAbstractVillager, 1, 1, 1);
        else
            aiPlanAddUnitType(plantation_build_plan, gUnitTypeVillager, 1, 1, 1);
        aiPlanSetNoMoreUnits(plantation_build_plan, false);
    }

    aiPlanSetActive(plantation_build_plan, true);
}


// ================================================================================
// Build a fort for each fort wagon we have.
// ================================================================================
rule MaintainFortFrontiers
group rgMainBase
inactive
minInterval 5
{
    if (kbProtoUnitAvailable(cUnitTypeFortFrontier) == false)
        return;
    
    if (kbUnitCount(cMyID, cUnitTypeFortFrontier, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeFortFrontier))
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int fort_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeFortFrontier, true);

    if (fort_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(fort_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeFortFrontier);
    if (builder == -1)
    {
        if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
            return;

        if (kbUnitCount(cMyID, cUnitTypeArchitect, cUnitStateAlive) == 0)
            return;
    }

    fort_build_plan = aiPlanCreate("Maintain Forts", cPlanBuild);
    aiPlanSetEscrowID(fort_build_plan, cRootEscrowID);

    aiPlanSetVariableInt(fort_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeFortFrontier);
    aiPlanSetVariableFloat(fort_build_plan, cBuildPlanBuildingBufferSpace, 0, 6.0);

    aiPlanSetEconomy(fort_build_plan, false);
    aiPlanSetMilitary(fort_build_plan, true);
    aiPlanSetBaseID(fort_build_plan, kbBaseGetMainID(cMyID));

    aiPlanSetVariableInt(fort_build_plan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeFortFrontier);
    aiPlanSetVariableFloat(fort_build_plan, cBuildPlanInfluenceUnitDistance, 0, 12.0);
    aiPlanSetVariableFloat(fort_build_plan, cBuildPlanInfluenceUnitValue, 0, -100.0);
    aiPlanSetVariableInt(fort_build_plan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

    aiPlanSetVariableVector(fort_build_plan, cBuildPlanInfluencePosition, 0, kbGetMapCenter());
    aiPlanSetVariableFloat(fort_build_plan, cBuildPlanInfluencePositionDistance, 0, 200.0);
    aiPlanSetVariableFloat(fort_build_plan, cBuildPlanInfluencePositionValue, 0, 200.0);
    aiPlanSetVariableInt(fort_build_plan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);

    if (builder >= 0)
    {
        aiPlanSetDesiredPriority(fort_build_plan, 100);
        aiPlanSetVariableInt(fort_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(fort_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(fort_build_plan, builder);
        aiPlanSetNoMoreUnits(fort_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(fort_build_plan, 50);
        aiPlanAddUnitType(fort_build_plan, cUnitTypeArchitect, 1, 1, 1);
        aiPlanSetNoMoreUnits(fort_build_plan, false);
    }

    aiPlanSetActive(fort_build_plan, true);
}
