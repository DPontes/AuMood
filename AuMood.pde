  #include <string.h>
  #include <SoftwareSerial.h>
  #include <avr/pgmspace.h>
  #include <Time.h>
  #include <EEPROM.h>
  
  // Adaptable variables
  int countThreshold = 4;
  int noBehaviourTime = 5000;
  const int countTime = 199;        // Time to renew sensor counter - Adapted to get actual 200ms
  
  // SC16IS750 Register Definitions
  #define THR        0x00 << 3
  #define RHR        0x00 << 3
  #define IER        0x01 << 3
  #define FCR        0x02 << 3
  #define IIR        0x02 << 3
  #define LCR        0x03 << 3
  #define MCR        0x04 << 3
  #define LSR        0x05 << 3
  #define MSR        0x06 << 3
  #define SPR        0x07 << 3
  #define TXFIFO     0x08 << 3
  #define RXFIFO     0x09 << 3
  #define DLAB       0x80 << 3
  #define IODIR      0x0A << 3
  #define IOSTATE    0x0B << 3
  #define IOINTMSK   0x0C << 3
  #define IOCTRL     0x0E << 3
  #define EFCR       0x0F << 3
  
  #define DLL        0x00 << 3
  #define DLM        0x01 << 3
  #define EFR        0x02 << 3
  #define XON1       0x04 << 3  
  #define XON2       0x05 << 3
  #define XOFF1      0x06 << 3
  #define XOFF2      0x07 << 3
  
  
  
  // SPI port definitions
  #define CS         10
  #define MOSI       11
  #define MISO       12
  #define SCK        13
  
  
  
  //Other definitions
  #define ASSOCIATE_TIMEOUT 5000
  
  
  
  //PROGMEM String Chars
  PROGMEM prog_char string_0[] = "teste2010";
  PROGMEM prog_char string_1[] = "8080";
  PROGMEM prog_char string_2[] = "Teste";
  PROGMEM prog_char string_3[] = "Wifly Start";
  PROGMEM prog_char string_4[] = "Bridge OK";
  PROGMEM prog_char string_5[] = "Bridge not OK";
  PROGMEM prog_char string_6[] = "Client request";
  PROGMEM prog_char string_7[] = "Rebooting";
  PROGMEM prog_char string_8[] = "CMD Mode";
  PROGMEM prog_char string_9[] = "Protocol UDP";
  PROGMEM prog_char string_10[] = "Set Auth Level";
  PROGMEM prog_char string_11[] = "Set Host IP";
  PROGMEM prog_char string_12[] = "Set Host Port";
  PROGMEM prog_char string_13[] = "Set IP localport to";
  PROGMEM prog_char string_14[] = "Set Time";
  PROGMEM prog_char string_15[] = "Joining '";
  PROGMEM prog_char string_16[] = "Failed to associate with '";
  PROGMEM prog_char string_17[] = "Retrying";
  PROGMEM prog_char string_18[] = "Associated";
  PROGMEM prog_char string_19[] = "Connection Lost... Rebooting and reconnecting";
  
  PROGMEM const char *string[] = 
  {
    string_0,
    string_1,
    string_2,
    string_3,
    string_4,
    string_5,
    string_6,
    string_7,
    string_8,
    string_9,
    string_10,
    string_11,
    string_12,
    string_13,
    string_14,
    string_15,
    string_16,
    string_17,
    string_18,
    string_19, };
  
  char buffer[45];
  
  
  //PROGMEM Setup Chars
  PROGMEM prog_char setupString_0[] = "";
  PROGMEM prog_char setupString_1[] = "exit";
  PROGMEM prog_char setupString_2[] = "$$$";
  PROGMEM prog_char setupString_3[] = "reboot";
  PROGMEM prog_char setupString_4[] = "$$$";
  PROGMEM prog_char setupString_5[] = "set i p 1";
  PROGMEM prog_char setupString_6[] = "set w a 4";
  PROGMEM prog_char setupString_7[] = "set w p your_password";
  PROGMEM prog_char setupString_8[] = "set i h 192.168.1.64";
  PROGMEM prog_char setupString_9[] = "set i r 8080";
  PROGMEM prog_char setupString_10[] = "set i l 8080";
  PROGMEM prog_char setupString_11[] = "set t z 23";
  PROGMEM prog_char setupString_12[] = "set t a 194.117.9.136";
  PROGMEM prog_char setupString_13[] = "set t p 123";
  PROGMEM prog_char setupString_14[] = "set t e 2";
  PROGMEM prog_char setupString_15[] = "set comm r 0";
  PROGMEM prog_char setupString_16[] = "set comm o 0";
  PROGMEM prog_char setupString_17[] = "set comm c 0";
  PROGMEM prog_char setupString_18[] = "join YOUR_NETWORK";
  PROGMEM prog_char setupString_19[] = "show c";
  PROGMEM prog_char setupString_20[] = "exit";
  PROGMEM prog_char setupString_21[] = "show t";
  
  PROGMEM const char *setupString[] = 
  {
    setupString_0,
    setupString_1,
    setupString_2,
    setupString_3,
    setupString_4,
    setupString_5,
    setupString_6,
    setupString_7,
    setupString_8,
    setupString_9,
    setupString_10,
    setupString_11,
    setupString_12,
    setupString_13,
    setupString_14,
    setupString_15,
    setupString_16,
    setupString_17,
    setupString_18,
    setupString_19,
    setupString_20,
    setupString_21 };
  
  char setupBuffer[25];
  
  
  
  //PROGMEM Vectors
  PROGMEM prog_uint16_t v_behaviour1[63] = 
                        {66, 83, 100, 100, 83, 66, 50,
                         66, 83, 100, 100, 83, 66, 50, 
                         66, 83, 100, 100, 83, 66, 50, 
                         66, 83, 100, 100, 83, 66, 50,
                         66, 83, 100, 100, 83, 66, 50,
                         66, 83, 100, 100, 83, 66, 50,
                         66, 83, 100, 100, 83, 66, 50,
                         66, 83, 100, 100, 83, 66, 50,
                         66, 83, 100, 100, 83, 66, 50};
                         
  PROGMEM prog_uint16_t v_behaviour2[52] = 
                           {75, 100, 75, 25, 10, 25, 
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 25, 10, 25,
                            75, 100, 75, 50};
  
  
  
  
  // RGB Pins Variables
  const int ledPinB = 6;            // B Pin
  const int ledPinR = 5;            // R Pin 
  const int ledPinG = 3;            // G Pin
  
  // Inferior Piece White LED
  const int wLedPin = 9;
  
  // Fan Pin
  const int fanPin = 8;
  
  // X-Band Pins
  const int PinEN = 4;              // X-Band EN Pin
  const int PinOUT = 2;             // X-Band OUT Pin
  
  
  
  //EEPROM Variables - these values need to be saved in EEPROM in case there is a power outage
  float hueValGamma =   (float)EEPROM.read(0);
  int gamma =           EEPROM.read(1);
  int TIME_RGB_UPDATE = EEPROM.read(2) * 1000;
  int behaviour =       EEPROM.read(3);
  int hourStart =       EEPROM.read(4);
  int minuteStart =     EEPROM.read(5);
  int hourEnd =         EEPROM.read(6);
  int minuteEnd =       EEPROM.read(7);
  int AuMoodState =     EEPROM.read(8);                   // 0 - Lights and detection are Off / 1 - Detections are On
  
//  int hourStart = 00;
//  int minuteStart = 01;
//  int hourStop = 00;
//  int minuteStop = 02;
  
  //Movement Sensor Variables
  int enabled = 0;                  // Sensor detection flag
  int pinENcurrentState = 0;        // Momentary Pin EN state value
  int sensorCount = 0;              // State change count
  
  
  //Global Flags & Variables
  
  //... for SPI communication
  char incoming_data; 
  char SPI_init_flag = 0;
  char polling = 0;
  char TX_Fifo_Address = THR;
  int i = 0;
  int j = 0;
  int k = 0;
  char clr = 0;
  
  //... 
  char getTimeV[5];                      // Vector used to grab and manipulate time in getTime function
  float recVector[10];                   // Vector of received values from the client
  float temp3[3];                        // Vector for temporary color values in hue2RGB function
  float cortemp[3];                      // Vector for temporary corrected color values in hue2RGB function
  float Color[3];                        // Vector with final hue values in hue2RGB function
  float wLedVal = 0;                     // White LED value
  float wLedMin = 0;                     // Minimum white LED value in given transition
  float wLedMax = 0;                     // Maximum white LED value in given transition
  float hueVal = 0;                      // Momentary hue value
  float hueValMin = 0;                   // Minimum Hue Value in given transition
  float hueValMax = 0;                   // Maximum Hue Value in given transition
  float hueValPercent = 0;               // Hue Value Percentage used in hue2RGB function
  float satVal = 1.0;                    // Saturation value [0.0; 1.0]
  float liteVal = 0.5;                   // Light value [0.0; 1.0]
  float temp2 = 0;                       // Temporary hue value in function hue2RGB (2)
  float temp1 = 0;                       // Temporary hue value in function hue2RGB (1)
  float v_behaviour0[120];               // Vector with light values for behaviour 0 (White Fade)
  int ch = 1;                            // Variable for imediate lights On/Off
  int getTimeDelay = 0;                  // Delay to assure that getTime function only occurs after given time
  int connectDelay = 0;                  // Delay to assure that autoConnect function only occurs after given time
  int pgmChar = 0;                       // Pointer for the char in the PROGMEM
  int RGB[3] = {0,0,0};                  // Vector with the values for each of the R, G and B leds
  int nStep = 0;                         // Current step in the interval [0; steps]
  int steps = 100;                       // Maximum number of steps during a colour transition
  int stepTime = TIME_RGB_UPDATE/steps;  // Time each step takes (ms)
  int newRecvValue = 0;                  // Flag for whether a new Hue value was recieved
  int behavStep = 0;                     // Current step in the behaviour changing
  //int AuMoodState = 0;
  int AuMoodPrevState = 0;               // Previous state to AuMoodState
  int isTimeSet = 0;                     // Flag for if system time is set
  int isConnected = 0;                   // Flag for if WiFly is connected to WiFi network
  int fanState = 0;                      // Flag for if the fan is ON (1) or OFF (0)
  int hourNow = 0;
  int minuteNow = 0;
  int isDetecting = 0;
  int forceON = 0;
  int forceOFF = 0;
  
  // Time variables to help with parallel processing
  long currentMillinStep = 0;            //
  long currentMillisChangeBehav = 0;     // 
  long currentMillisActBehav = 0;        //
  long currentMillisConnect = 0;         //
  long currentMillisGetTime = 0;         //
  long currentMilliSensor = 0;           //
    
  time_t Start;                         // Time library variable for start hour in long format
  time_t End;                           // Time library variable for stop hour in long format
  time_t dayStart;
  time_t dayEnd;
  
 
  
  
  
  //SPI_Uart Configuration, defines register values for SC16IS750
  struct SPI_UART_cfg
  {
    char DivL,DivM,DataFormat,Flow;
  };
  
  struct SPI_UART_cfg SPI_Uart_config = {
    0x60,0x00,0x03,0x10};
    
  
  
  
  void setup()
  {
    
    Serial.begin(9600);
    
    behaviour = (-1) * (behaviour + 1);
    
    // Fan Init
    pinMode(fanPin, OUTPUT);  // Pin 8
    
    //SPI Init
    pinMode(CS,OUTPUT);       // Pin 10
    pinMode(MOSI, OUTPUT);    // Pin 11
    pinMode(MISO, INPUT);     // Pin 12
    pinMode(SCK,OUTPUT);      // Pin 13
    digitalWrite(CS,HIGH);    //disable device     
    
    
    // SPI Start
    SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR1)|(1<<SPR0);
    clr=SPSR;
    clr=SPDR;
    delay(1000); 
    
    pgmTerminalPrintln(3);            //Prints "Wifly Start"
    //Initialize and test the SPI-Uart Bridge
    if(SPI_Uart_Init())
      pgmTerminalPrintln(4);          //Prints "Bridge OK"
    else{
      pgmTerminalPrintln(5);          //Prints "Bridge Not OK"
      while(1);                       //Locks Up
    }
    
    //Set initial treshold values for hueVal
    hueValMin = round(random(hueValGamma - gamma, hueValGamma + gamma));
    hueValMax = round(random(hueValGamma - gamma, hueValGamma + gamma));
    hueVal = hueValMin;
    
    fill_vbehaviour();              // Fills v_behaviour0[]
    setupConnection();              // Sets up WiFly connection variables
    setTheTime();                   // Sets up the system time (Start, Stop, Current)
    enableSensor();                 // Starts sensor use
    currentMilliSensor = millis();  // Initializes currentMillisSensor variable with current time value
    isDetecting = 1;
  }
  
  void loop()
  {

    timeFunction();
    stateChange();

    // Tries to get the time if time not set, if its connected and if its been more than 125000ms 
    // (+2 minutes) after last time it tried to get the system time (imposition of the Wifly time() function)
    if(isTimeSet == 0 && isConnected == 1 && millis() - currentMillisGetTime > getTimeDelay)  
      getTime();                                                                             
  
    // Will try to connect to the WiFi network if not connected. Has been set up so it wont interfere
    // with the normal workings of the lights and sensor, if these are being used.
    // It will only run one iteration of the autoConnect function at a time, giving the necessary 
    // delay time depending on which interation its on.
    if(isConnected == 0 && (millis() - currentMillisConnect > connectDelay))                  
      autoConnect();                                                                          
    
    if(AuMoodState == 1)
    {
      counting();          // Used to count Pin EN state changes
      timeCheck();         // Decides every 200ms if there needs to be a change in behaviour, according to the value of 'sensorCount'
      moveRGB();           // Moves the value of hueVal by one each loop, if time passed is > stepTime
      hue2RGB();           // Transforms the single value of hueVal into its corresponding RGB values
      checkUpdate();       // Used when hueVal transition is over. Updates hueValMax value
      actBehaviour();      // Used to apply the previously selected behaviour
    }
    
    // If its connected, sees if there is communication in the SPI
    if(isConnected == 1)                        
      Have_Client();
  
    
  }
  
  
  //Prints on the terminal chars that are saved in Progmem flash plus a carriage return
  void pgmTerminalPrintln(int pgmChar)
  {
    strcpy_P(buffer, (char*)pgm_read_word(&(string[pgmChar])));
    Serial.println(buffer);
  }
  
  
  //Prints to the SPI chars that are saved in Progmem flash
  void pgm_SPI_UartPrint(int pgmChar)
  {
  
    strcpy_P(setupBuffer, (char*)pgm_read_word(&(setupString[pgmChar])));
    SPI_Uart_print(setupBuffer);
  
  }
  
  
  //Prints to the SPI chars that are saved in Progmem flash plus a carriage return
  void pgm_SPI_UartPrintln(int pgmChar)
  {
  
    strcpy_P(setupBuffer, (char*)pgm_read_word(&(setupString[pgmChar])));
    SPI_Uart_println(setupBuffer);
  
  }
  
  
  // Sets up the connection by printing on the SPI the appropriate commands
  // for the setup. Runs only once at startup
  void setupConnection(void)
  {
    for(pgmChar = 0; pgmChar < 18; pgmChar++)
    {
      int d = 1;                           // Order of magnitude for the appropriate delay for each of the SPI prints
      if(pgmChar == 2 || pgmChar == 4)     // Prints 2 and 4 ('$$$') do not need a carriage return at the end
        pgm_SPI_UartPrint(pgmChar);
        else
          pgm_SPI_UartPrintln(pgmChar);    // All other prints require a carriage return at the end
      if(pgmChar == 3)                     // Prints 'reboot'
        d = 10;                            // Order of magintude d = 10 creates a 3000ms delay, necessary time for the reboot
      delay(d * 300);
    } 
  }
  
  
  // Automatically connect to configured WiFi network
  // Is accessed only if Wifly is not connected to the WiFi network.
  // Runs a different 'case' each time the function is accessed, depending on its state
  // It was implemented as such so that it wouldnt go into an endless loop in case it wasnt able 
  // to connect to the WiFi network, thus jamming the rest of the Wifly functioning
  char autoConnect(void)

  {
      switch(pgmChar)
      {
        case 18:  Serial.println("Connecting to Teste");
                  pgm_SPI_UartPrintln(pgmChar);                // Prints "join Teste" in SPI_Uart
                  pgmChar++;
                  connectDelay = 5000;                         // Garantees that the autoConnect function will
                  break;                                       // will only be accessed 5000ms from now
                  
        case 19:  Flush_RX();
                  pgm_SPI_UartPrintln(pgmChar);                // Prints "show c" in SPI_Uart
                  if(Wait_On_Response_Char(13) != '0')
                  {
                    Serial.println("Not Connected... Retrying");
                    Flush_RX();
                    pgmChar--;                                 // If a connection attempt isnt successful, next time 
                    isConnected = 0;                           // it will try the "join Teste" once more
                  }
                  else
                  {
                    Serial.println("Sucess!");                 // Connection successful!
                    pgmChar++;
                  }
                  connectDelay = 500;                          // Allows 500ms for connection stability before performing 'exit'
                  break;
                  
        case 20:  pgm_SPI_UartPrintln(pgmChar);                // Prints "exit" in SPI_Uart
                  Flush_RX();
                  isConnected = 1;
                  pgmChar = 18;
                  connectDelay = 500;
                  break;
      }
      currentMillisConnect = millis();
  }
  
  
  
  
  // Function obtains the current time by accessing a time server on the internet
  // Needs to be changed so it wont interfere with the normal functioning of AuMood
  // Should use the same technique as the autoConnect function. Delay should be removed
  void getTime(void)
  {
    char returns = 0;
    char time_index = 0;
    int readpoll = 0;
    delay(1500);
    
    Serial.println("Get Time");
    
    pgm_SPI_UartPrint(2);        // Prints "$$$" in SPI_Uart
    delay(200);
    pgm_SPI_UartPrintln(21);     // Prints "show t" in SPI_Uart
    
    // Loop will search for a '=' symbol present in the 'TIME=12:00:00' phrase
    // Reads the time after the '=' and places the time in the getTimeV vector
    // Stops after 4 carriage returns
    while(returns < 4)
    {
      if((SPI_Uart_ReadByte(LSR) & 0x01))
      {
        incoming_data = SPI_Uart_ReadByte(RHR);
        if(readpoll == 1)
        {
          getTimeV[time_index] = incoming_data;
          time_index++;        
        }
        if(incoming_data == '=')                 // if '=' is found, starts recording the coming message into getTimeV[]
          readpoll = 1;
        if(incoming_data == 0x0d)                // If incoming data is a carriage return
          returns++;
      }
    }
  
    // If a '=' symbol was found, it means that it was possible to obtain the time 
    // from the time server, and getTimeV[0] is filled with something other than an empty space
    if(getTimeV[0] != 0x00)
    {
      hourNow = (getTimeV[0]-48) * 10 + (getTimeV[1]-48);    //parses hour
      minuteNow = (getTimeV[3]-48) * 10 + (getTimeV[4]-48);  //parses minute
      isTimeSet = 1;
      Serial.print(hourNow);
      Serial.print(":");
      Serial.println(minuteNow);
      setTime(hourNow, minuteNow,0, 31, 7, 2010);
     }
    
    // If the '=' symbol was not found, getTimeV[0] is filled with something other than an empty space
    // It means that time is not set, and will be tried again in approx. 2 minutes (125000ms)
    else
    {
      isTimeSet = 0;
      Serial.println("TIME NOT SET");
      getTimeDelay = 125000;                                 // Makes sure that this function only runs again after 2 minutes
      currentMillisGetTime = millis();
    }
  
    pgm_SPI_UartPrintln(1);                                  // Prints "exit" in SPI_Uart, whether time is set or not
    delay(100);
    Flush_RX();  
    
  }
  
  
  
  // Parses received message from the SPI
  void ParseMessage(void)
  {
    int a = 0, i = 1, k = 0, l = 0, j = 0, sum = 0;
    char message[21] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    do
    {
      if((SPI_Uart_ReadByte(LSR) & 0x01))
      {
        incoming_data = SPI_Uart_ReadByte(RHR);
        Serial.print(incoming_data,BYTE);
        message[k] = incoming_data;      // Message is saved in the message[] vector
      }
      k++;
    }while(k < 30);
    
    SPI_Uart_println("1");               //confirms reception to the aUmood app on the client side
   
    if(message[0] == 'D')                //If Wifly is disconnected from WiFi Network - Received message: Disconnected
    {
      pgmTerminalPrintln(19);            // Prints "Connection Lost... Rebooting and reconnecting" in the terminal
      delay(100);
      currentMillisConnect = millis();
      connectDelay = 1000;               // Will try to connect in 1000ms
      pgm_SPI_UartPrint(2);              // Prints "$$$" in SPI_Uart
      isConnected = 0;                   // It is not connected
    }
    
    if(message[0] == 'a')                //if string received starts with 'a'
      j = 0;
    else if(message[0] == 'b')           //if string received starts with 'b'
      j = 5;
        
    // Received message is in this format (ex.): a11681030100510021010
    // Ignoring the first letter 'a': 11681030100510021010
    // Separating in groups of 4: 1168 1030 1005 1002 1010
    // You get hueValGamma = 168; Gamma = 30; RGB Update Time = 5s; Behaviour = 2; Hour Start: 10
    if(message[0] == 'a' || message[0] == 'b')    //ignores 'ghost' transmissions
    {
      
           
      // This loop ignores the first '1' from each of the groups of 4 digits, and
      // transforms the remaining string of numbers into a usable int.
      // Using 1168 (hueValGamma) as an example:
      // 1 - Ignores the first '1', 
      // 2 - Takes the second char (1 [ASCII -> 49]), subtracts 48 (this transforms the value from a char to an int, in the ASCII table)
      // 3 - Multiples it by 100 with pow(10, 2) -> 10^2
      // 4 - Adds it to sum (sum = 100)
      // 5 - takes the third char (6 [ASCII -> 54]), subtracts 48
      // 6 - Multiplies it by 10 with pow(10, 1) -> 10^1
      // 7 - Adds it to sum (sum = 160)
      // 8 - Takes the fourth char (8 [ASCII -> 56]), subtracts 48
      // 9 - Multiplies it by 1 with pow(10, 0) -> 10^0
      // 10 - Adds it to sum (sum = 168)
      // 11 - Places sum in the appropriate recVector position
      for(a = 1; a <= k; a++)
      {
        l = l + 1;                                                // Controls to what power the message value is multiplied
        sum = sum + (message[a + i] - 48) * round(pow(10, 3-l));  // (-48) turns ASCII to int 
        if(l == 3)                                                // If the 3 values are read, 'l' and 'i' are reset
        {
          l = 0;
          recVector[i-1+j] = sum;
          i++;                                                    // Allows for the overstepping of the additional '1's
          sum = 0;
        }
      }
      
      
      if(j == 0)                      //values in string 'a'
      {
         // Values are saved in the ATMega328's EEPROM, in case there is a power outage
         // This garantees that the values that the client requested are not lost
         hueValGamma = recVector[0];
         EEPROM.write(0,hueValGamma);
         gamma = recVector[1];
         EEPROM.write(1,gamma);
         TIME_RGB_UPDATE = 1000 * recVector[2];  // Time is received in seconds, used in miliseconds
         EEPROM.write(2,recVector[2]);
         EEPROM.write(3,recVector[3]);
         behaviour = (behaviour/abs(behaviour)) * (recVector[3] + 1);       // + 1 because behaviour values are received [0; 3] but used as [1; 4]
         hourStart   = recVector[4];
         EEPROM.write(4,hourStart);
         newRecvValue = 1;                       // indicates that a new values was received. Flag used in the checkUpdate function
      }
      
      else if(j == 5)                //values in string 'b'
       {
         
         minuteStart = recVector[5];
         EEPROM.write(5,minuteStart);
         hourEnd     = recVector[6];
         EEPROM.write(6,hourEnd);
         minuteEnd   = recVector[7];
         EEPROM.write(7,minuteEnd);
         hourNow     = recVector[8];
         minuteNow   = recVector[9];
                  
         setTime(hourStart,minuteStart,0,31,7,2010);
         Start = now();
         setTime(hourEnd,minuteEnd,0,31,7,2010);
         End = now();
            
         // The current time is received from the client. In case time hasnt yet been set,
         // it eliminates the necessity to pull the time server every 2 minutes
         setTime(hourNow,minuteNow,0,31,7,2010);

         isTimeSet = 1;
  
         
       }
    }
    else if(message[0] == 'c')
    {
       if(message[4] == 48)
       {
          forceON = 1;
          forceOFF = 0;
       }
       else if(message[8] == 48)
       {
            forceON = 0;
            
            forceOFF = 1;
       }
       else if(message[12] == 48)
               demoMode();      
    }
  }
  
  
  
  
  // Transforms a single hue value into three separate R, G and B values.
  // Assumes saturation and light values are constant.
  void hue2RGB()
  {
    temp2 = satVal + liteVal - (liteVal * satVal);
    temp1 = 2.0 * liteVal - temp2;
    hueValPercent = hueVal/255.0;
    temp3[0] = hueValPercent + (1.0/3.0);
    temp3[1] = hueValPercent;
    temp3[2] = hueValPercent - (1.0/3.0);
    
    for(int i = 0; i < 3; i++)
    {
      if(temp3[i] < 0.0)
        cortemp[i] = temp3[i] + 1.0;
        else if(temp3[i] > 1.0)
          cortemp[i] = temp3[i] - 1.0;
          else
            cortemp[i] = temp3[i];
            
      if(6.0 * cortemp[i] < 1.0)
        Color[i] = temp1 + (temp2 - temp1) * 6.0 * cortemp[i];
        else if(2.0 * cortemp[i] < 1.0)
          Color[i] = temp2;
          else if(3.0 * cortemp[i] < 2.0)
            Color[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - cortemp[i]) * 6.0;
            else
              Color[i] = temp1;     
              
      RGB[i] = round(Color[i] * 255.0);
      if(RGB[i] < 0)
        RGB[i] = 0;
        else if(RGB[i] > 255)
          RGB[i] = 255;
    }
    writeRGB();
  }
  
  
  
  // Moves the value of the hueVal one step between [hueValMin; hueValMax]
  // hueValMin can be higher value than hueValMax. This means that the value
  // of hue will decrease. This is ok, as the map function takes care of that.
  // In case the hueVal happens to be out of the [0; 255] interval, an adaptation
  // is done, assuring continuity and smallest route to a desired value.
  
  void moveRGB()
  {
    if(millis() - currentMillinStep > stepTime)
    {
      currentMillinStep = millis();
      nStep = nStep + 1;
      hueVal = round(map(nStep, 1, steps, hueValMin, hueValMax));
      wLedVal = round(map(nStep, 1, steps, wLedMin, wLedMax));
      if(hueVal < 0)
        hueVal = 256 + hueVal;
        else if(hueVal > 255)
          hueVal = hueVal - 255;
    }
  }
  
  
  // Used when hueVal transition is over (nStep = steps). Updates hueValMax value
  void checkUpdate()
  {
    if(nStep == steps)
    {
      hueValMin = hueValMax;                 // hueValMin gets the previous value of hueValMax
      wLedMin = wLedMax;
      
      // If a new hue value is received from the client, 
      // such value becomes the new upper limit to the 
      // [hueValMin; hueValMax] interval
      if(newRecvValue == 1)
      {
        hueValMax = hueValGamma;
        newRecvValue = 0;                    // Received value flag reset
      }
      
      // If no new value is received, the new upper limit is randomly calculated
      else
        hueValMax = round(random(hueValGamma - gamma, hueValGamma + gamma));
        
      wLedMax = round(random(100, 255));
        
      // 'nStep' is reset
      nStep = 0;
    }
  }
  
  
  
  
  
  // Updates the light value in each of the RGB Leds
  void writeRGB()
  {
    analogWrite(ledPinR,RGB[0]);
    analogWrite(ledPinG,RGB[1]);
    analogWrite(ledPinB,RGB[2]);
    analogWrite(wLedPin,wLedVal);
//    Serial.print(RGB[0]);
//    Serial.print(" ");
//    Serial.print(RGB[1]);
//    Serial.print(" ");
//    Serial.print(RGB[2]);
//    Serial.println(" ");


  }
  
  
  
  
  // Activates the appropriate behaviour
  // Behaviours are based on liteval (light) values on the corresponding
  // v_behaviour[] vector. Each time this functions is accessed, it updates 
  // the light value by jumping one position on the vector. When it reaches 
  // end of the vector, behavStep is reset, behaviour flag gets a negative value, 
  // so that it wont be activated again until timeCheck function activates it.
  // It also wont be activated if its been less than 'noBehaviourTime' since last time
  // it was activated.
  
  void actBehaviour()
  {
    if(millis() - currentMillisActBehav > noBehaviourTime)
    {
      switch(behaviour)
      {
        case 1:  // White Fade
                 if(millis() - currentMillisChangeBehav > 50)
                 {
                   liteVal = v_behaviour0[behavStep];
                   behavStep++;
                   currentMillisChangeBehav = millis();
                  // Serial.println("B - 1");
                 }
                 if(behavStep == 120)                          // End of v_behaviour0[] vector
                 {
                   behavStep = 0;
                   behaviour = (-1) * abs(behaviour);
                   currentMillisActBehav = millis();
                 }
                 
                 break;
                 
        case 2:  // Colour Strobe
                 if(millis() - currentMillisChangeBehav > 50)
                 {
                   liteVal = (pgm_read_word_near(v_behaviour1 + behavStep))/100.0;
                   behavStep++;
                   currentMillisChangeBehav = millis();
                 //  Serial.println("B - 2");
                 }
                 if(behavStep == 63)                          // End of v_behaviour1[] vector
                 {
                   behavStep = 0;
                   behaviour = (-1) * abs(behaviour);
                   currentMillisActBehav = millis();
                 }
                 break;
                 
        case 3:  // B&W Strobe
                 if(millis() - currentMillisChangeBehav > 50)
                 {
                   satVal = 0.0;
                   liteVal = (pgm_read_word_near(v_behaviour2 + behavStep))/100.0;
                   behavStep++;
                   if(behavStep > 49)
                     satVal = 1.0;
                   currentMillisChangeBehav = millis();
                 //  Serial.println("B - 3");
                 }
          
                 if(behavStep == 52)                         // End of v_behaviour2[] vector
                 {
                   satVal = 1.0;
                   liteVal = 0.5;
                   behavStep = 0;
                   behaviour = (-1) * abs(behaviour);
                   currentMillisActBehav = millis();
                 }
                 break;
                 
        case 4:  // Strobe Mix
                 // Takes the first 24 positions in v_behaviour1[] (Color Strobe),
                 // and then positions [25; 124] of v_behaviour0[] (White Fade)
                 if(millis() - currentMillisChangeBehav > 50)
                 {
                   behavStep++;
                   if(behavStep < 25)
                     liteVal = (pgm_read_word_near(v_behaviour1 + (behavStep-1)))/100.0;
                     else if(behavStep > 24 && behavStep < 125)
                       liteVal = v_behaviour0[behavStep - 5];        // (-5) as a position correction in v_behaviour0[]
                       else                                 
                       {
                         behavStep = 0;
                         behaviour = (-1) * abs(behaviour);
                         currentMillisActBehav = millis();
                       }
                   currentMillisChangeBehav = millis();
                 //  Serial.println("B - 4");
                 }
                 
                 break;
                 
        default:  isDetecting = 1;
                  break;
      }
    }
  }
  
  
  
  
  
  // Fill vector v_behaviour0[]. Runs once at startup
  void fill_vbehaviour()
  {
    for(i = 0; i < 20; i++)
    {
      v_behaviour0[i] = (map(i, 0, 19, 500, 1000))/1000.0;
    }
    for(i = 20; i < 80; i++)
    {
      v_behaviour0[i] = 1.0;
    }
    for(i = 80; i < 120; i++)
    {
      v_behaviour0[i] = (map(i, 80, 119, 1000, 500))/1000.0;
    }
  }
  
  
  // Sets up the time variables needed.
  void setTheTime()
  {
    currentMillinStep = millis();
    currentMillisChangeBehav = millis();
    currentMillisActBehav = millis();
    currentMillisConnect = millis();
    currentMillisGetTime = millis();
    
    // The 'setTime' sets the system time with the values included in its variables
    // This way its possible to adjust the tStart, tStop and tNow variables using the 
    // 'now()' function, which returns the current time in seconds since 01/01/1970.
    setTime(0, 0, 0, 31, 7, 2010);
    dayStart = now();
    setTime(0, 0, 0, 1, 8, 2010);
    dayEnd = now();
    setTime(hourStart, minuteStart, 0, 31, 7, 2010);
    Start = now();
    setTime(hourEnd, minuteEnd, 59, 31, 7, 2010);
    End = now();
    setTime(12,0,0,31,7,2010);
    
      
  }
  
  
  
  // Used whenever there is a change in the AuMood state, to turn the lights ON/OFF in
  // a smooth way. Takes one second to be completed. During this time, nothing else works,
  // but shouldnt need to, as when this is used, the system should not be interested in
  // detecting motion. Variables 'p' (current AuMood state) and 's' (next AuMood state) 
  // are either 0 or 1.
  void fade(int p, int s)
  {
    p = p * 100;
    s = s * 100;
    for(int i = 0; i < 20; i++)
    {
      satVal = (map(i, 0, 19, p, s))/100.0;        // satVal is 1.0 when lights are on
      liteVal = (map(i, 0, 19, p/2, s/2))/100.0;   // liteVal is 0.5 when lights are on
      wLedVal = (map(i, 0, 19, p*2.55, s*2.55));
      hue2RGB();                                   // Makes the appropriate changes in the RGB values and updates the LEDs
      delay(50);
    }
  }
  
  
  
  
  
  // Initializes Doppler Effect sensor
  void enableSensor()                            
  {
    
    //To start the sensor reading, enable pin EN (pin 4) with HIGH signal
    //To make sure it's a clean HIGH signal, give small LOW signal before
    
    digitalWrite(PinEN,LOW);
    delayMicroseconds(5);
    digitalWrite(PinEN, HIGH);
    currentMilliSensor = millis();
  }
  
  
  
  
  
  // Waits for the sensor to return a state = 1
//  void wait()                            
//  {
//    while(digitalRead(PinOUT) != 1)
//    {
//      digitalRead(PinOUT);
//    }
//    pinENcurrentState = 1;
//  }
  
  
  
  void disable()                        
  {
    pinMode(PinEN, OUTPUT);
    digitalWrite(PinEN, LOW);
  }
  
  
  
  
  
  // Counts the numbers of pi EN state changes
  void counting()                            
  {
    if(digitalRead(PinOUT) != pinENcurrentState)
    {
      sensorCount++;
      delay(1);                                      // Allows for pin EN stabilization
      pinENcurrentState = -(pinENcurrentState - 1);  // Switches pinENcurrentState between 0 to 1
    } 
  }
  
  
  
  
  
  // Every 'countTime' miliseconds, the number of pin EN state changes are 
  // controled. If there have been more than 'countThreshold' state changes,
  // then its considered that there has been a significant movement in front 
  // of the sensor. This inverts the value of the behaviou flag, so that
  // it will activate the actBehaviour function
  void timeCheck()
  {
    if(millis() - currentMilliSensor > countTime)
    {
      currentMilliSensor = millis();
      if(sensorCount > countThreshold && isDetecting == 1)
      {
        behaviour = abs(behaviour);
        isDetecting = 0;
      }
      sensorCount = 0;
    }
  }
  
  
  
  
  
  
  //SPI Uart Functions
  void select(void) // Select SC16IS750
  {
    digitalWrite(CS, LOW);
  }
  
  void deselect(void) // Deselect SC16IS750
  {
    digitalWrite(CS, HIGH);
  }
  
  char Have_Client(void)
  {
    if(SPI_Uart_ReadByte(LSR) & 0x01) // Wait for characters from a connection
    { 
      pgmTerminalPrintln(6);
      ParseMessage(); // Check if request is a POST
      Flush_RX();
      return 1; 
    }   
    else
      return 0;  
  }
  
  char SPI_Uart_Init(void)
  // Initialize SC16IS750
  {
    char data = 0;
    SPI_Uart_WriteByte(LCR,0x80); // 0x80 to program baudrate
    SPI_Uart_WriteByte(DLL,SPI_Uart_config.DivL); //0x60 = 9600 with Xtal = 14.44MHz
    SPI_Uart_WriteByte(DLM,SPI_Uart_config.DivM); 
  
    SPI_Uart_WriteByte(LCR, 0xBF); // access EFR register
    SPI_Uart_WriteByte(EFR, SPI_Uart_config.Flow); // enable enhanced registers
    SPI_Uart_WriteByte(LCR, SPI_Uart_config.DataFormat); // 8 data bit, 1 stop bit, no parity
    SPI_Uart_WriteByte(FCR, 0x06); // reset TXFIFO, reset RXFIFO, non FIFO mode
    SPI_Uart_WriteByte(FCR, 0x01); // enable FIFO mode
  
    // Perform read/write test to check if UART is working
    SPI_Uart_WriteByte(SPR,'H');
    data = SPI_Uart_ReadByte(SPR);
  
    if(data == 'H'){ 
      return 1; 
    }
    else{ 
      return 0; 
    }
  
  }
  
  void SPI_Uart_WriteByte(char address, char data)
  // Write single byte to register at <address>
  {
    long int length;
    char senddata[2];
    senddata[0] = address;
    senddata[1] = data;
  
    select();
    length = SPI_Write(senddata, 2);
    deselect();
  }
  
  long int SPI_Write(char* srcptr, long int length)
  // Write string to SC16IS750
  {
    for(long int i = 0; i < length; i++)
    {
      spi_transfer(srcptr[i]);
    }
    return length; 
  }
  
  void SPI_Uart_WriteArray(char *data, long int NumBytes)
  // Write string to THR of SC16IS750
  {
    long int length;
    select();
    length = SPI_Write(&TX_Fifo_Address,1);
  
    while(NumBytes > 16)
    {
      length = SPI_Write(data,16);
      NumBytes -= 16;
      data += 16;
    }
    length = SPI_Write(data,NumBytes);
  
    deselect();
  }
  
  char SPI_Uart_ReadByte(char address)
  // Read SC16IS750 register at <address>
  {
    char data;
  
    address = (address | 0x80);
    select();
    spi_transfer(address);
    data = spi_transfer(0xFF);
    deselect();
    return data;  
  }
  
  void Flush_RX(void)
  // Flush characters from the SC16IS750 so we only see what we want to see on the terminal
  {
    int j = 0;
    while(j < 4000)
    {
      if((SPI_Uart_ReadByte(LSR) & 0x01))
      {
        incoming_data = SPI_Uart_ReadByte(RHR);
      }  
      else
      {
        j++;
      }
    }
  }
  
  char Wait_On_Response_Char(char num)
  // Check for character number <num> from a response string
  {
    i = 1;
    while(1)
    {
      if((SPI_Uart_ReadByte(LSR) & 0x01))
      {
        incoming_data = SPI_Uart_ReadByte(RHR);
        //Serial.print(incoming_data, BYTE); // Print data for debugging
        if(i == num){ 
          return incoming_data; 
        }
        else{ 
          i++; 
        }
      }  
    }
  }
  
  void SPI_Uart_println(char *data)
  // Write <data> to THR of SC16IS750 followed by a carriage return
  {
    SPI_Uart_WriteArray(data,strlen(data));
    SPI_Uart_WriteByte(THR, 0x0d);
  }
  
  void SPI_Uart_print(char *data)
  // Obfuscation of SPI_Uart_WriteArray that uses strlen instead of hardcoded length
  {
    SPI_Uart_WriteArray(data,strlen(data));
  }
  
  char spi_transfer(volatile char data)
  {
    SPDR = data;                    // Start the transmission
    while (!(SPSR & (1<<SPIF)))     // Wait for the end of the transmission
    {
    };
    return SPDR;                    // return the received byte
  }
  

