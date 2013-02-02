  void stateChange()
  {
    if(AuMoodState != AuMoodPrevState)          // if there is a state change 
    {
      // Fades the lights from OFF to ON or viceversa, depending on the situation
      fade(AuMoodPrevState, AuMoodState);    
     
      // Changes the state of the Fan from OFF to ON or viceversa, depending on the situation
      if(AuMoodState == 0)
      {
        digitalWrite(fanPin, LOW);
        disable();
      }
      else
      {
        digitalWrite(fanPin, HIGH);
        enableSensor();
      }
      
      AuMoodPrevState = AuMoodState;
      EEPROM.write(8, AuMoodState);
    }
  }
