rule MaintainTradingPosts
group rgMainBase
inactive
minInterval 10
{
    const int attempt_cdn = 60000;
    static int last_attempt = -60000;
    if (xsGetTime() < last_attempt + attempt_cdn)
        return;
    
    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    float socket_query_radius = 5000.0;
    if (aiTreatyActive())
        socket_query_radius = 80.0;
    
    int closest_free_socket = -1;
    for(i = 0; < getUnitCountByLocation(cUnitTypeTradePostSocket, 0, getMainBaseLocation(), socket_query_radius))
    {
        int i_socket = getUnitByLocation1(cUnitTypeTradePostSocket, 0, getMainBaseLocation(), socket_query_radius, i);
        vector i_socket_position = kbUnitGetPosition(i_socket);

        if (getUnitByLocation2(cUnitTypeTradingPost, cPlayerRelationAny, i_socket_position, 8.0, 0, cUnitStateABQ) >= 0)
        {
            aiQVSet(cFlagVPLastOccupiedTime + i_socket, xsGetTime());
            continue;
        }

        if (xsGetTime() < aiQVGet(cFlagVPLastOccupiedTime + i_socket) + cVPUnoccupiedTimeout)
            continue;
        
        if (getUnitByLocation2(cUnitTypeMilitaryBuilding, cPlayerRelationEnemyNotGaia, i_socket_position, 50.0, 0, cUnitStateABQ) >= 0)
            continue;
        
        if (kbCanPath2(getMainBaseLocation(), i_socket_position, cUnitTypeSettler) == false)
            continue;

        closest_free_socket = i_socket;
        break;
    }

    if (closest_free_socket == -1)
        return;

    int trading_post_build_plan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTradingPost, true);
    
    if (trading_post_build_plan >= 0 && kbUnitIsType(aiPlanGetVariableInt(trading_post_build_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon) == false)
        return;
    
    int builder = findWagonToBuildProtoUnit(cUnitTypeTradingPost);

    if (builder == -1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        return;
    
    if (kbGetAge() <= cAge2 && kbResourceGet(cResourceWood) < 500.0 && builder == -1)
        return;

    last_attempt = xsGetTime();

    if (kbUnitIsType(closest_free_socket, cUnitTypeNativeSocket) == true)
        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyIWillClaimNativeSite);
    else
        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyIWillClaimTradeSite);

    trading_post_build_plan = aiPlanCreate("Maintain Trade Route Posts", cPlanBuild);
    aiPlanSetEscrowID(trading_post_build_plan, cRootEscrowID);
    aiPlanSetVariableInt(trading_post_build_plan, cBuildPlanBuildingTypeID, 0, cUnitTypeTradingPost);
    aiPlanSetVariableInt(trading_post_build_plan, cBuildPlanSocketID, 0, closest_free_socket);
    if (kbUnitIsType(builder, cUnitTypeAbstractWagon))
    {
        aiPlanSetDesiredPriority(trading_post_build_plan, 100);
        aiPlanSetVariableInt(trading_post_build_plan, cBuildPlanBuildUnitID, 0, builder);
        aiPlanAddUnitType(trading_post_build_plan, kbUnitGetProtoUnitID(builder), 0, 0, 1);
        aiPlanAddUnit(trading_post_build_plan, builder);
        aiPlanSetNoMoreUnits(trading_post_build_plan, true);
    }
    else
    {
        aiPlanSetDesiredPriority(trading_post_build_plan, 50);
        aiPlanAddUnitType(trading_post_build_plan, cUnitTypeHero, 1, 2, 5);
        if (gUnitTypeVillager == -1)
            aiPlanAddUnitType(trading_post_build_plan, cUnitTypeAbstractVillager, 2, 2, 2);
        else
            aiPlanAddUnitType(trading_post_build_plan, gUnitTypeVillager, 2, 2, 2);
        aiPlanSetNoMoreUnits(trading_post_build_plan, false);
    }
    aiPlanSetActive(trading_post_build_plan, true);
}
