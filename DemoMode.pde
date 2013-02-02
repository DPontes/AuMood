void demoMode()
{
  int hueValTemp = hueVal;
  int behaviourTemp = behaviour;
  int stepD = 0;
  long currentStepDemo = 0;
  int TimeUP = 50000;
  int TimeDOWN = 10000;
  currentMillisActBehav = millis() + noBehaviourTime + 1;
  
  
  Serial.println("DEMO Start");
  
  if(AuMoodState == 0)
    fade(0, 1);
    
  currentStepDemo = millis();
  hueVal++;
  
  do
  {
    if(millis() - currentStepDemo > 196)
    {
      currentStepDemo = millis();
//      Serial.print(hueVal);
//      Serial.print(" ");
//      Serial.print(stepD);
//      Serial.print(" ");
//      Serial.print(behavStep);
//      Serial.print(" ");
//      Serial.println(behaviour);
      
      stepD++;
      if(stepD % 50 == 0)
         behaviour = (stepD / 50); 
      hueVal++;
      if(hueVal > 255)
        hueVal = 0;
    }
    
    actBehaviour();
    hue2RGB();
    currentMillisActBehav = millis() + noBehaviourTime + 1;
  }while(hueVal != hueValTemp);
  
  hueVal--;
  
  do
  {
    if(millis() - currentStepDemo > 40)
    {
      Serial.println(hueVal);
      currentStepDemo = millis();
      hue2RGB();
      hueVal--;
      if(hueVal < 0)
        hueVal += 256;
    }
  }while(hueVal != hueValTemp);
  
  if(AuMoodState == 0)
    fade(1, 0);
    
  hueVal = hueValTemp;
  behaviour = behaviourTemp;
  
  Serial.println("DEMO Over");
}
