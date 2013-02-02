void timeFunction()
{
  if(now() > dayEnd)
    setTime(0,0,0,31,7,2010);
    
  if(Start > End)
  {
    if(now() >= dayStart && now() <= End || now() >= Start && now() <= dayEnd)
    {
      forceON = 0;
      AuMoodState = 1;
    }
    else
    {
      forceOFF = 0;
      AuMoodState = 0;
    }
    
    if(forceON == 1)
      AuMoodState = 1;
      else if(forceOFF == 1)
        AuMoodState = 0;
  }
  
  else if(Start < End)
  {
    if(now() >= Start && now() <= End)
    {
      forceON = 0;
      AuMoodState = 1;
    }
    else
    {
      forceOFF = 0;
      AuMoodState = 0;
    }
    if(forceON == 1)
      AuMoodState = 1;
      else if(forceOFF == 1)
        AuMoodState = 0;
  }
  
  
}
