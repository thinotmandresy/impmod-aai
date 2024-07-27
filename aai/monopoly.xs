void onMonopolyStart(int team_id = -1)
{
    if (team_id == -1)
        return;
    
    gMonopolyActive = true;
    gMonopolyTeam = team_id;
    xsEnableRule("MonopolyTimer");

    if (team_id == kbGetPlayerTeam(cMyID))
    {
        for(player = 1; < cNumberPlayers)
        {
            if (player == cMyID)
                continue;
            
            if (kbIsPlayerAlly(player))
                aiCommsSendStatement(player, cAICommPromptToAllyWhenWeGetMonopoly);
            else
                aiCommsSendStatement(player, cAICommPromptToEnemyWhenWeGetMonopoly);
        }
    }
    else
    {
        for(player = 1; < cNumberPlayers)
        {
            if (player == cMyID)
                continue;
            
            if (kbIsPlayerAlly(player))
                aiCommsSendStatement(player, cAICommPromptToAllyWhenEnemiesGetMonopoly);
            else if (kbGetPlayerTeam(player) == team_id)
                aiCommsSendStatement(player, cAICommPromptToEnemyWhenTheyGetMonopoly);
        }
    }
}


void onMonopolyEnd(int team_id = -1)
{
    if (team_id == -1)
        return;
    
    gMonopolyActive = false;
    gMonopolyTeam = -1;
    xsDisableRule("MonopolyTimer");

    if (team_id == kbGetPlayerTeam(cMyID))
    {
        for(player = 1; < cNumberPlayers)
        {
            if (player == cMyID)
                continue;
            
            if (kbIsPlayerAlly(player))
                aiCommsSendStatement(player, cAICommPromptToAllyEnemyDestroyedMonopoly);
            else
                aiCommsSendStatement(player, cAICommPromptToEnemyTheyDestroyedMonopoly);
        }
    }
    else
    {
        for(player = 1; < cNumberPlayers)
        {
            if (kbGetPlayerTeam(player) == team_id)
                aiCommsSendStatement(player, cAICommPromptToEnemyIDestroyedMonopoly);
        }
    }
}


rule MonopolyTimer
inactive
minInterval 240
{
    xsDisableSelf();

    if (gMonopolyTeam == kbGetPlayerTeam(cMyID))
    {
        for(player = 1; < cNumberPlayers)
        {
            if (player == cMyID)
                continue;
            
            if (kbIsPlayerAlly(player))
                aiCommsSendStatement(player, cAICommPromptToAlly1MinuteLeftOurMonopoly);
            else
                aiCommsSendStatement(player, cAICommPromptToEnemy1MinuteLeftOurMonopoly);
        }
    }
    else
    {
        for(player = 1; < cNumberPlayers)
        {
            if (player == cMyID)
                continue;
            
            if (kbIsPlayerAlly(player))
                aiCommsSendStatement(player, cAICommPromptToAlly1MinuteLeftEnemyMonopoly);
            else if (kbGetPlayerTeam(player) == gMonopolyTeam)
                aiCommsSendStatement(player, cAICommPromptToEnemy1MinuteLeftEnemyMonopoly);
        }
    }
}
