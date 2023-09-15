/* ========================================================================================================================================
    Age of Empires III - Improvement Mod - AI LOADER
    Alternative ImpMod AI v1.10d by AlistairJah - Released on May 3rd, 2023
======================================================================================================================================== */

include "aai/main.xs";


rule DelayCentralAIActivation
active
minInterval 1
{
    static int player = 1;
    if (kbIsPlayerValid(player) == false)
    {
        xsDisableSelf();
        return;
    }
    if (kbIsPlayerHuman(player) == true)
    {
        player++;
        xsEnableRule("RunImmediatelyDelayCentralAIActivation");
        return;
    }
    if (player != cMyID)
    {
        player++;
        return;
    }
    
    xsDisableSelf();
    int numCPAIs = 0;
    for (i = 1; < cNumberPlayers)
    {
        if (kbIsPlayerHuman(i) == true)
        {
            continue;
        }
        numCPAIs++;
    }
    xsEnableRule("CentralAI");
    xsSetRuleMinInterval("CentralAI", numCPAIs);
    xsSetRuleMaxInterval("CentralAI", numCPAIs);
}


rule RunImmediatelyDelayCentralAIActivation
inactive
runImmediately
priority 100
{
    xsDisableSelf();
    DelayCentralAIActivation();
}


rule CentralAI
inactive
minInterval 10
maxInterval 10
priority 100
runImmediately
{
    if (kbHasPlayerLost(cMyID) == true)
    {
        return;
    }

    // Initialization
    static bool init = true;
    if (init)
    {
        init = false;
        setCivUnitTypes();

        if (aiRandInt(100) < 25)
            gStrategy = cStrategyRush;
        else
            gStrategy = cStrategyBoom;

        gStartup = true;
        xsEnableRuleGroup("rgStartup");

        // Use unique inventory
        kbEscrowSetPercentage(cMilitaryEscrowID, cAllResources, 0.0);
        kbEscrowSetPercentage(cEconomyEscrowID, cAllResources, 0.0);
        kbEscrowSetPercentage(cRootEscrowID, cAllResources, 1.0);
        aiSetAutoGatherEscrowID(cRootEscrowID);
        aiSetAutoFarmEscrowID(cRootEscrowID);
        kbEscrowAllocateCurrentResources();
    }

    GatherResourcesFailsafe();
    ResearchEconomicTechs();
    ResearchUnitUpgrades();
    AutoGatherMilitary();
    DefendMainBase();
    ManageAttackWaves();
    RingTheBell();
    GatherCrates();
}
