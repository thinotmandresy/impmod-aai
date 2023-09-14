// ============================================================================
// Queries from Mother Nature's point of view
// ============================================================================

int kbGaiaUnitQueryCreate(string query_name = "")
{
    xsSetContextPlayer(0);
    int query_id = kbUnitQueryCreate(query_name);
    xsSetContextPlayer(cMyID);
    
    return(query_id);
}

bool kbGaiaUnitQueryResetData(int query_id = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQueryResetData(query_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQueryResetResults(int query_id = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQueryResetResults(query_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQueryDestroy(int query_id = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQueryDestroy(query_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

int kbGaiaUnitQueryNumberResults(int query_id = -1)
{
    xsSetContextPlayer(0);
    int ret_val = kbUnitQueryNumberResults(query_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

int kbGaiaUnitQueryGetResult(int query_id = -1, int index = -1)
{
    xsSetContextPlayer(0);
    int ret_val = kbUnitQueryGetResult(query_id, index);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetPlayerID(int query_id = -1, int player_id = -1, bool reset_query_data = true)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetPlayerID(query_id, player_id, reset_query_data);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetPlayerRelation(int query_id = -1, int player_relation = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetPlayerRelation(query_id, player_relation);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetUnitType(int query_id = -1, int unit_type = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetUnitType(query_id, unit_type);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetActionType(int query_id = -1, int action_type = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetActionType(query_id, action_type);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetState(int query_id = -1, int state = cUnitStateAny)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetState(query_id, state);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetPosition(int query_id = -1, vector position = cOriginVector)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetPosition(query_id, position);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetMaximumDistance(int query_id = -1, float distance = 0.0)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetMaximumDistance(query_id, distance);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetIgnoreKnockedOutUnits(int query_id = -1, bool ignore = true)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetIgnoreKnockedOutUnits(query_id, ignore);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetAscendingSort(int query_id = -1, bool sort = true)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetAscendingSort(query_id, sort);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetBaseID(int query_id = -1, int base_id = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetBaseID(query_id, base_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetAreaID(int query_id = -1, int area_id = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetAreaID(query_id, area_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetAreaGroupID(int query_id = -1, int area_group_id = -1)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetAreaGroupID(query_id, area_group_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

bool kbGaiaUnitQuerySetSeeableOnly(int query_id = -1, bool seeable_only = true)
{
    xsSetContextPlayer(0);
    bool ret_val = kbUnitQuerySetSeeableOnly(query_id, seeable_only);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

int kbGaiaUnitQueryExecute(int query_id = -1)
{
    xsSetContextPlayer(0);
    int ret_val = kbUnitQueryExecute(query_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

int kbGaiaUnitQueryExecuteOnQuery(int current_query_id = -1, int previous_query_id = -1)
{
    xsSetContextPlayer(0);
    int ret_val = kbUnitQueryExecuteOnQuery(current_query_id, previous_query_id);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

int kbGaiaUnitQueryExecuteOnQueryByName(int current_query_id = -1, string previous_query_name = "")
{
    xsSetContextPlayer(0);
    int ret_val = kbUnitQueryExecuteOnQueryByName(current_query_id, previous_query_name);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

float kbGaiaUnitQueryGetUnitCost(int query_id = -1, bool consider_health = false)
{
    xsSetContextPlayer(0);
    float ret_val = kbUnitQueryGetUnitCost(query_id, consider_health);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}

float kbGaiaUnitQueryGetUnitHitpoints(int query_id = -1, bool consider_health = false)
{
    xsSetContextPlayer(0);
    float ret_val = kbUnitQueryGetUnitHitpoints(query_id, consider_health);
    xsSetContextPlayer(cMyID);

    return(ret_val);
}


// ============================================================================
// Quick Queries
// ============================================================================

// Returns the index-th unit matching the criteria. Use at the outmost layer of nested loops.
int getUnit1(int unit_type = -1, int owner = cMyID, int index = -1, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Quick Query 1");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
    }

    if (index <= 0)
    {
        kbUnitQueryResetResults(query);
        kbUnitQuerySetUnitType(query, unit_type);
        kbUnitQuerySetState(query, state);
        if (owner >= 1000)
        {
            kbUnitQuerySetPlayerID(query, -1, false);
            kbUnitQuerySetPlayerRelation(query, owner);
        }
        else
        {
            kbUnitQuerySetPlayerRelation(query, -1);
            kbUnitQuerySetPlayerID(query, owner, false);
        }
        
        int unit_count = kbUnitQueryExecute(query);
        if (index <= -1)
            return(kbUnitQueryGetResult(query, aiRandInt(unit_count)));
    }

    return(kbUnitQueryGetResult(query, index));
}

// Returns the index-th unit matching the criteria. Use at the middle layer of nested loops.
int getUnit2(int unit_type = -1, int owner = cMyID, int index = -1, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Quick Query 2");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
    }

    if (index <= 0)
    {
        kbUnitQueryResetResults(query);
        kbUnitQuerySetUnitType(query, unit_type);
        kbUnitQuerySetState(query, state);
        if (owner >= 1000)
        {
            kbUnitQuerySetPlayerID(query, -1, false);
            kbUnitQuerySetPlayerRelation(query, owner);
        }
        else
        {
            kbUnitQuerySetPlayerRelation(query, -1);
            kbUnitQuerySetPlayerID(query, owner, false);
        }
        
        int unit_count = kbUnitQueryExecute(query);
        if (index <= -1)
            return(kbUnitQueryGetResult(query, aiRandInt(unit_count)));
    }

    return(kbUnitQueryGetResult(query, index));
}

// Returns the index-th unit matching the criteria. Use at the innermost layer of nested loops.
int getUnit3(int unit_type = -1, int owner = cMyID, int index = -1, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Quick Query 3");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
    }

    if (index <= 0)
    {
        kbUnitQueryResetResults(query);
        kbUnitQuerySetUnitType(query, unit_type);
        kbUnitQuerySetState(query, state);
        if (owner >= 1000)
        {
            kbUnitQuerySetPlayerID(query, -1, false);
            kbUnitQuerySetPlayerRelation(query, owner);
        }
        else
        {
            kbUnitQuerySetPlayerRelation(query, -1);
            kbUnitQuerySetPlayerID(query, owner, false);
        }
        
        int unit_count = kbUnitQueryExecute(query);
        if (index <= -1)
            return(kbUnitQueryGetResult(query, aiRandInt(unit_count)));
    }

    return(kbUnitQueryGetResult(query, index));
}


// ============================================================================
// Queries by Locations
// ============================================================================

// Returns the index-th unit matching the criteria. Use at the outmost layer of nested loops.
int getUnitByLocation1(int unit_type = -1, int owner = cMyID, vector position = cInvalidVector, float distance = 4.0, int index = -1, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Query by Location 1");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
        kbUnitQuerySetAscendingSort(query, true);
    }

    if (index <= 0)
    {
        kbUnitQueryResetResults(query);
        kbUnitQuerySetUnitType(query, unit_type);
        kbUnitQuerySetPosition(query, position);
        kbUnitQuerySetMaximumDistance(query, distance);
        kbUnitQuerySetState(query, state);
        if (owner >= 1000)
        {
            kbUnitQuerySetPlayerID(query, -1, false);
            kbUnitQuerySetPlayerRelation(query, owner);
        }
        else
        {
            kbUnitQuerySetPlayerRelation(query, -1);
            kbUnitQuerySetPlayerID(query, owner, false);
        }
        
        int unit_count = kbUnitQueryExecute(query);
        if (index <= -1)
            return(kbUnitQueryGetResult(query, aiRandInt(unit_count)));
    }

    return(kbUnitQueryGetResult(query, index));
}

// Returns the index-th unit matching the criteria. Use at the middle layer of nested loops.
int getUnitByLocation2(int unit_type = -1, int owner = cMyID, vector position = cInvalidVector, float distance = 4.0, int index = -1, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Query by Location 2");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
        kbUnitQuerySetAscendingSort(query, true);
    }

    if (index <= 0)
    {
        kbUnitQueryResetResults(query);
        kbUnitQuerySetUnitType(query, unit_type);
        kbUnitQuerySetPosition(query, position);
        kbUnitQuerySetMaximumDistance(query, distance);
        kbUnitQuerySetState(query, state);
        if (owner >= 1000)
        {
            kbUnitQuerySetPlayerID(query, -1, false);
            kbUnitQuerySetPlayerRelation(query, owner);
        }
        else
        {
            kbUnitQuerySetPlayerRelation(query, -1);
            kbUnitQuerySetPlayerID(query, owner, false);
        }
        
        int unit_count = kbUnitQueryExecute(query);
        if (index <= -1)
            return(kbUnitQueryGetResult(query, aiRandInt(unit_count)));
    }

    return(kbUnitQueryGetResult(query, index));
}

// Returns the index-th unit matching the criteria. Use at the innermost layer of nested loops.
int getUnitByLocation3(int unit_type = -1, int owner = cMyID, vector position = cInvalidVector, float distance = 4.0, int index = -1, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Query by Location 3");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
        kbUnitQuerySetAscendingSort(query, true);
    }

    if (index <= 0)
    {
        kbUnitQueryResetResults(query);
        kbUnitQuerySetUnitType(query, unit_type);
        kbUnitQuerySetPosition(query, position);
        kbUnitQuerySetMaximumDistance(query, distance);
        kbUnitQuerySetState(query, state);
        if (owner >= 1000)
        {
            kbUnitQuerySetPlayerID(query, -1, false);
            kbUnitQuerySetPlayerRelation(query, owner);
        }
        else
        {
            kbUnitQuerySetPlayerRelation(query, -1);
            kbUnitQuerySetPlayerID(query, owner, false);
        }
        
        int unit_count = kbUnitQueryExecute(query);
        if (index <= -1)
            return(kbUnitQueryGetResult(query, aiRandInt(unit_count)));
    }

    return(kbUnitQueryGetResult(query, index));
}

// Returns the number of units matching the criteria.
int getUnitCountByLocation(int unit_type = -1, int owner = cMyID, vector position = cInvalidVector, float distance = 4.0, int state = cUnitStateAlive)
{
    static int query = -1;
    if (query == -1)
    {
        query = kbUnitQueryCreate("Count by Location");
        kbUnitQuerySetIgnoreKnockedOutUnits(query, true);
    }

    kbUnitQueryResetResults(query);
    kbUnitQuerySetUnitType(query, unit_type);
    kbUnitQuerySetPosition(query, position);
    kbUnitQuerySetMaximumDistance(query, distance);
    kbUnitQuerySetState(query, state);
    if (owner >= 1000)
    {
        kbUnitQuerySetPlayerID(query, -1, false);
        kbUnitQuerySetPlayerRelation(query, owner);
    }
    else
    {
        kbUnitQuerySetPlayerRelation(query, -1);
        kbUnitQuerySetPlayerID(query, owner, false);
    }

    return(kbUnitQueryExecute(query));
}
