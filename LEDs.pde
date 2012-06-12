/**************************************************************
 *
 ***************************************************************/
void Init_LEDs(void)
{
  pinMode(redLedPin, OUTPUT);
  pinMode(greenLedPin, OUTPUT);
  pinMode(blueLedPin, OUTPUT);

  fun_LEDs(0, ledCycles, ledDelay);


}
/**************************************************************
 *
 ***************************************************************/
void off_leds(void)//Shutdown all the LEDs.
{
  digitalWrite(redLedPin,LOW);
  digitalWrite(greenLedPin,LOW);
  digitalWrite(blueLedPin,LOW);
}
/**************************************************************
 * A function to choose and change the behavior, you can add your custom patterns
 ***************************************************************/
void fun_LEDs(byte mode, byte cycles, unsigned int t_delay)
{
  switch(mode)
  {
  case 0: // cycle rgb
    for(int x=0; x<=cycles; x++)
    {
      digitalWrite(redLedPin,LOW);
      digitalWrite(greenLedPin,LOW);
      digitalWrite(blueLedPin,HIGH);
      delay(t_delay);
      digitalWrite(redLedPin,HIGH);
      digitalWrite(greenLedPin,LOW);
      digitalWrite(blueLedPin,LOW);
      delay(t_delay);
      digitalWrite(redLedPin,LOW);
      digitalWrite(greenLedPin,HIGH);
      digitalWrite(blueLedPin,LOW);
    }
    digitalWrite(greenLedPin,LOW);
    break;
 /************************************************************/
  case 1: // blink white
    for(int x=0; x<=cycles; x++)
    {
      digitalWrite(redLedPin,HIGH);
      digitalWrite(greenLedPin,HIGH);
      digitalWrite(blueLedPin,HIGH);
      delay(t_delay);
      digitalWrite(redLedPin,LOW);
      digitalWrite(greenLedPin,LOW);
      digitalWrite(blueLedPin,LOW);
      delay(t_delay);
    }
    break;
 /************************************************************/
  case 2: // blink red
    digitalWrite(redLedPin,LOW);
    digitalWrite(greenLedPin,LOW);
    digitalWrite(blueLedPin,LOW);

    for(int x=0; x<=cycles; x++)
    {
      digitalWrite(redLedPin,HIGH);
      delay(t_delay);
      digitalWrite(redLedPin,LOW);
      delay(t_delay);
    }
    digitalWrite(redLedPin,LOW);
    break;
/************************************************************/
  case 3: // blink blue
    digitalWrite(redLedPin,LOW);
    digitalWrite(greenLedPin,LOW);
    digitalWrite(blueLedPin,LOW);

    for(int x=0; x<=cycles; x++)
    {
      digitalWrite(blueLedPin,HIGH);
      delay(t_delay);
      digitalWrite(blueLedPin,LOW);
      delay(t_delay);
    }
    digitalWrite(blueLedPin,LOW);
    break;

  case 4: // blink green
    digitalWrite(redLedPin,LOW);
    digitalWrite(greenLedPin,LOW);
    digitalWrite(blueLedPin,LOW);

    for(int x=0; x<=cycles; x++)
    {
      digitalWrite(greenLedPin,HIGH);
      delay(t_delay);
      digitalWrite(greenLedPin,LOW);
      delay(t_delay);
    }
    digitalWrite(greenLedPin,LOW);
    break;

  }
}

void blinkRed() {
  fun_LEDs(2, ledCycles, ledDelay);
}

void blinkGreen() {
  fun_LEDs(4, ledCycles, ledDelay);
}

void blinkBlue() {
  fun_LEDs(3, ledCycles, ledDelay);
}

void blinkWhite() {
  fun_LEDs(1, ledCycles, ledDelay);
}