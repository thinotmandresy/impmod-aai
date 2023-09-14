// Returns the center of the main base.
vector getMainBaseLocation(void)
{
    return(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
}

// Returns true if P is inside the triangle ABC.
bool isPointInsideTriangle(vector P = cInvalidVector, vector A = cInvalidVector, vector B = cInvalidVector, vector C = cInvalidVector)
{
    vector v0 = C - A;
    vector v1 = B - A;
    vector v2 = P - A;

    float dot00 = xsVectorGetX(v0) * xsVectorGetX(v0) + xsVectorGetZ(v0) * xsVectorGetZ(v0);
    float dot01 = xsVectorGetX(v0) * xsVectorGetX(v1) + xsVectorGetZ(v0) * xsVectorGetZ(v1);
    float dot02 = xsVectorGetX(v0) * xsVectorGetX(v2) + xsVectorGetZ(v0) * xsVectorGetZ(v2);
    float dot11 = xsVectorGetX(v1) * xsVectorGetX(v1) + xsVectorGetZ(v1) * xsVectorGetZ(v1);
    float dot12 = xsVectorGetX(v1) * xsVectorGetX(v2) + xsVectorGetZ(v1) * xsVectorGetZ(v2);

    float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return((u >= 0) && (v >= 0) && (u + v < 1));
}

// Returns a random point inside the triangle ABC.
vector getRandomPointInsideTriangle(vector A = cInvalidVector, vector B = cInvalidVector, vector C = cInvalidVector)
{
    float r1 = aiRandInt(100);
    float r2 = aiRandInt(100);
    r1 = r1 / 100.0;
    r2 = r2 / 100.0;
    if (r1 + r2 > 1.0)
    {
        r1 = 1.0 - r1;
        r2 = 1.0 - r2;
    }
    vector P = A + (B - A) * r1 + (C - A) * r2;
    return(P);
}

vector rotate(vector start = cInvalidVector, vector center = cInvalidVector, float degrees = 0.0)
{
    vector end = xsVectorSetX(start, xsVectorGetX(center) + (xsVectorGetX(start) - xsVectorGetX(center)) * xsCos(degrees * cDegToRad) - (xsVectorGetZ(start) - xsVectorGetZ(center)) * xsSin(degrees * cDegToRad));
    end = xsVectorSetZ(end, xsVectorGetZ(center) + (xsVectorGetX(start) - xsVectorGetX(center)) * xsSin(degrees * cDegToRad) + (xsVectorGetZ(start) - xsVectorGetZ(center)) * xsCos(degrees * cDegToRad));
    return(end);
}

// Returns true if the specified unit has the specified flag.
bool isFlagged(int unit = -1, string flag = "")
{
    return(aiQVGet(flag + unit) > .1);
}

// Sets the specified flag to the specified unit.
void setFlag(int unit = -1, string flag = "")
{
    aiQVSet(flag + unit, 1);
}

// Removes the specified flag from the specified unit.
void unsetFlag(int unit = -1, string flag = "")
{
    aiQVSet(flag + unit);
}

// Returns true if the player is a simple spectator.
bool isObserver(int player = cMyID)
{
    return(kbGetCivName(kbGetCivForPlayer(player)) == "Observer");
}

// Returns true if the player is Asian.
bool isAsian(int player = cMyID)
{
    int culture = kbGetCultureForPlayer(player);
    return(culture == cCultureChinese || culture == cCultureIndian || culture == cCultureJapanese);
}

// Returns true if the player is Native.
bool isNative(int player = cMyID)
{
    int culture = kbGetCultureForPlayer(player);
    return(culture == cCultureAztec || culture == cCultureIroquois || culture == cCultureSioux);
}

// Returns true if the player is European.
bool isEuropean(int player = cMyID)
{
    int culture = kbGetCultureForPlayer(player);
    return(culture == cCultureEasternEurope || culture == cCultureMediterranean || culture == cCultureWesternEurope);
}

// Returns true if an AgeUp is currently in progress.
bool ageingUp(void)
{
    if (kbUnitCount(cMyID, cUnitTypeAbstractWonder, cUnitStateBuilding) >= 1)
        return(true);
    
    if (isAsian())
        return(false);
    
    if (kbTechGetStatus(aiGetPoliticianChoice(kbGetAge() + 1)) == cTechStatusActive)
        return(false);
    
    return(kbGetTechPercentComplete(aiGetPoliticianChoice(kbGetAge() + 1)) > 0.01);
}

// Returns the position of the closest ally Town Center
vector findClosestAllyTCPos(vector query_center = cInvalidVector)
{
    for(i = 0; < getUnitCountByLocation(cUnitTypeTownCenter, cPlayerRelationAlly, query_center, 5000.0))
    {
        int i_ally_town_center = getUnitByLocation1(cUnitTypeTownCenter, cPlayerRelationAlly, query_center, 5000.0, i);
        if (kbUnitGetPlayerID(i_ally_town_center) != cMyID)
            return(kbUnitGetPosition(i_ally_town_center));
    }

    return(cInvalidVector);
}

// Returns the first unassigned wagon that can build the specified protounit.
int findWagonToBuildProtoUnit(int protounit_to_build = -1)
{
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeAbstractWagon, cUnitStateAlive))
    {
        int i_wagon = getUnit1(cUnitTypeAbstractWagon, cMyID, i);
        if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildUnitID, i_wagon, true) >= 0)
            continue;
        
        int i_wagon_protounit = kbUnitGetProtoUnitID(i_wagon);
        if (kbProtoUnitCanSpawn(i_wagon_protounit, protounit_to_build) == false)
            continue;
        
        return(i_wagon);
    }

    return(-1);
}

// Returns the first unassigned building that can research the specified tech.
int findBuildingToResearchTech(int tech_to_research = -1)
{
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive))
    {
        int i_building = getUnit1(cUnitTypeLogicalTypeBuildingsNotWalls, cMyID, i);
        if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanBuildingID, i_building, true) >= 0)
            continue;
        
        int i_building_protounit = kbUnitGetProtoUnitID(i_building);
        if (i_building_protounit == cUnitTypeTownCenter)
            continue;
        if (i_building_protounit == gUnitTypeHouse)
            continue;
        if (kbProtoUnitCanResearch(i_building_protounit, tech_to_research) == false)
            continue;
        
        return(i_building);
    }

    return(-1);
}

// Returns true if the specified resource is safe and still gatherable.
bool isResourceGoodToGather(int resource_id = -1)
{
    if (kbUnitGetCurrentInventory(resource_id, cResourceGold) < 0.1 && 
        kbUnitGetCurrentInventory(resource_id, cResourceWood) < 0.1 && 
        kbUnitGetCurrentInventory(resource_id, cResourceFood) < 0.1)
    {
        return(false);
    }

    if (kbUnitGetPlayerID(resource_id) != 0 && kbUnitGetPlayerID(resource_id) != cMyID)
        return(false);
    
    vector resource_position = kbUnitGetPosition(resource_id);
    
    if (kbUnitIsType(resource_id, cUnitTypeHerdable) && kbUnitIsInventoryFull(resource_id) == false)
        return(false);
    
    bool shrined = false;
    if (kbUnitIsType(resource_id, cUnitTypeHuntable) == true)
    {
        xsSetContextPlayer(0);
        shrined = kbProtoUnitIsType(cMyID, 
        kbUnitGetProtoUnitID(kbUnitGetTargetUnitID(resource_id)), cUnitTypeAbstractShrine);
        xsSetContextPlayer(cMyID);
        return(shrined == false);
    }
    
    if (kbUnitIsType(resource_id, cUnitTypeHerdable) == true)
    {
        xsSetContextPlayer(0);
        shrined = kbProtoUnitIsType(cMyID, 
        kbUnitGetProtoUnitID(kbUnitGetTargetUnitID(resource_id)), cUnitTypeAbstractShrine);
        xsSetContextPlayer(cMyID);
        return(shrined == false);
    }
    
    if (getUnitCountByLocation(cUnitTypeMilitaryBuilding, cPlayerRelationEnemyNotGaia, resource_position, cResourceAvoidBuildings) >= 1)
        return(false);
                
    if (getUnitCountByLocation(cUnitTypeLogicalTypeNavalMilitary, cPlayerRelationEnemyNotGaia, resource_position, cResourceAvoidBuildings) >= 1)
        return(false);
                
    if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, resource_position, cResourceAvoidLandUnits) >= 3)
        return(false);
    
    return(true);
}

// Sends a notification as the first AI player.
void notifyAsFirstAI(string message = "") {
    static int valid_players = -1;
    int num_valid_players = 0;
    if (valid_players == -1)
        valid_players = xsArrayCreateInt(12, -1, "List of valid players to send notifications");
    
    for(i = 0; < cNumberPlayers) {
        if (kbIsPlayerResigned(i) == true ||
            kbHasPlayerLost(i) == true ||
            kbIsPlayerValid(i) == false ||
            kbIsPlayerHuman(i) == true)
        {
            continue;
        }
        xsArraySetInt(valid_players, num_valid_players, i);
        num_valid_players++;
    }

    if (num_valid_players == 0)
        return;
    
    int notifier = xsArrayGetInt(valid_players, 0);
    if (cMyID != notifier)
        return;
    
    xsNotify(message);
}

// Returns the number of allies that are not dead.
int getNumAllies(void)
{
    int num_allies = 0;
    for (i = 1; < cNumberPlayers)
    {
        if (kbIsPlayerAlly(i) == true
            && kbHasPlayerLost(i) == false)
        {
            num_allies++;
        }
    }

    return(num_allies);
}
