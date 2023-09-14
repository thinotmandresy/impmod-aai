void applyDifficultySettings(void)
{
    // Enable auto-repair in all difficulties.
    aiTaskUnitResearch(getUnit1(cUnitTypeAll), cTechAIAutoRepair);
    
    // Get the handicap that was set in the pre-game menu. We will adjust it depending on the difficulty.
    float starting_handicap = kbGetPlayerHandicap(cMyID);

    switch(aiGetWorldDifficulty())
    {
        case cDifficultySandbox:
        {
            kbSetPlayerHandicap(cMyID, starting_handicap * cDifficultySandboxHandicap);
            break;
        }
        case cDifficultyEasy:
        {
            kbSetPlayerHandicap(cMyID, starting_handicap * cDifficultyEasyHandicap);
            break;
        }
        case cDifficultyModerate:
        {
            kbSetPlayerHandicap(cMyID, starting_handicap * cDifficultyHandicapModerate);
            break;
        }
        case cDifficultyHard:
        {
            kbSetPlayerHandicap(cMyID, starting_handicap * cDifficultyHardHandicap);
            xsEnableRuleGroup("rgCheats");
            break;
        }
        case cDifficultyExpert:
        {
            kbSetPlayerHandicap(cMyID, starting_handicap * cDifficultyExpertHandicap);
            xsEnableRuleGroup("rgCheats");
            break;
        }
    }
}

rule EnableEarlyCheats
group rgCheats
inactive
runImmediately
{
    if (kbTechGetStatus(cTechAICheats) == cTechStatusActive)
    {
        xsDisableSelf();
        return;
    }

    // Do not cheat in Age1, and do not cheat when we're not allowed to cheat.
    if (kbGetAge() == cAge1 || kbTechGetStatus(cTechAICheats) == cTechStatusUnobtainable)
        return;

    aiTaskUnitResearch(getUnit1(cUnitTypeAll), cTechAICheats);
}


rule EnableLateCheats
group rgCheats
inactive
runImmediately
{
    if (kbTechGetStatus(cTechAICheatsAge4) == cTechStatusActive)
    {
        xsDisableSelf();
        return;
    }

    // Do not cheat in Age1 and Age2, and do not cheat when we're not allowed to cheat.
    if (kbGetAge() <= cAge2 || kbTechGetStatus(cTechAICheatsAge4) == cTechStatusUnobtainable)
        return;

    aiTaskUnitResearch(getUnit1(cUnitTypeAll), cTechAICheatsAge4);
}
