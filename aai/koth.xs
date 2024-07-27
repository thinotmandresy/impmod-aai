void onKOTHStart(int team_id = -1)
{
    if (team_id == -1)
        return;
    
    gKOTHActive = true;
    gKOTHTeam = team_id;
}


void onKOTHEnd(int team_id = -1)
{
    if (team_id == -1)
        return;
    
    gKOTHActive = false;
    gKOTHTeam = -1;
}