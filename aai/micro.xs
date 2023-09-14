void DanceToFirepit()
{
    if (isNative() == false)
        return;
    
    if (gStartup == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 10000)
        return;
    last_call = xsGetTime();

    int firepit = getUnit1(cUnitTypeFirePit, cMyID, 0);
    if (firepit == -1)
        return;
    if (kbUnitGetNumberWorkersIfSeeable(firepit) >= 25)
        return;
    vector firepit_position = kbUnitGetPosition(firepit);

    for(i = 0; < kbUnitCount(cMyID, cUnitTypexpMedicineMan, cUnitStateAlive))
    {
        int i_unit = getUnit1(cUnitTypexpMedicineMan, cMyID, i);
        if (kbUnitGetPlanID(i_unit) >= 0)
            continue;
        if (kbUnitGetActionType(i_unit) == cActionMove)
            continue;
        if (kbUnitGetActionType(i_unit) == cActionBuild)
            continue;
        
        vector i_unit_position = kbUnitGetPosition(i_unit);
        if (kbCanPath2(i_unit_position, firepit_position, kbUnitGetProtoUnitID(i_unit)) == false)
            continue;
        
        aiTaskUnitWork(i_unit, firepit);
    }

    for(i = 0; < kbUnitCount(cMyID, cUnitTypexpMedicineManAztec, cUnitStateAlive))
    {
        i_unit = getUnit1(cUnitTypexpMedicineManAztec, cMyID, i);
        if (kbUnitGetPlanID(i_unit) >= 0)
            continue;
        if (kbUnitGetActionType(i_unit) == cActionMove)
            continue;
        if (kbUnitGetActionType(i_unit) == cActionBuild)
            continue;
        
        i_unit_position = kbUnitGetPosition(i_unit);
        if (kbCanPath2(i_unit_position, firepit_position, kbUnitGetProtoUnitID(i_unit)) == false)
            continue;
        
        aiTaskUnitWork(i_unit, firepit);
    }
}


void HideTheRegent(void)
{
    static int last_call = -1;
    if (xsGetTime() < last_call + 500)
        return;
    last_call = xsGetTime();

    if (kbUnitCount(cMyID, cUnitTypeypCastleRegicide, cUnitStateAlive) == 0)
        return;
    
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeypDaimyoRegicide, cUnitStateAlive))
    {
        aiTaskUnitWork(
            getUnit1(cUnitTypeypDaimyoRegicide, cMyID, i),
            getUnit2(cUnitTypeypCastleRegicide, cMyID, 0)
        );
    }
}
