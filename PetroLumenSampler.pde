// WHEN RUNNING, THE APP SENDS SOME SERIAL DATA THAT FUCKS UP THE
// BYTE ORDERING CONSTANTLY SENT THROUGHT THE PIXEL PICKER.
// TO RE-ORDER IT, PixelPicker.reset() CLEARS THE SERIAL BUFFER AND WAITS 5 SECONDS (APP COMPLETELY PAUSES, WITH NO SENDING)

import processing.serial.*;

Serial serialPort;
PixelPicker pixelPicker;

boolean clearScreen;
boolean placePickersMode;

String pixelDataFileName = "rockyData.csv";

void setup() {
  size(500, 500);
  frameRate(25);
  //colorMode(HSB, 255);
  background(0);

  println(Serial.list());
  try {
    String portName = Serial.list()[11];
    serialPort = new Serial(this, portName, 115200);
  } 
  catch (Exception e) {
    println("ALGO ANDA MAL CON LA ELECTRONICA..!!!");
  }

  pixelPicker = new PixelPicker(width, height);
  pixelPicker.setupPickersFromFile(pixelDataFileName);

  clearScreen = true;
  placePickersMode = false;
}

void draw() {
  if (clearScreen) {
    background(0);
    //clearScreen = false;
  }


  if (placePickersMode) {
    
    
    
  } else {
    //if (frameCount % 1 == 0) {
    pixelPicker.pick();
    pixelPicker.sendOut();
    //}
  }

  pixelPicker.drawPickers();
}

void mousePressed(){
 if(placePickersMode){
   pixelPicker.addPicker(mouseX,mouseY);
 } 
}



void keyPressed() {
  if (key == ' ') {
    pixelPicker.sendOut();
  }

  if (key == 'c') {
    clearScreen = !clearScreen;
  }

  if (key == 'r') {
    pixelPicker.resetSender();
  }

  if (key == 'p') {
    placePickersMode = !placePickersMode;
  }
  
  if (key == 's') {
    pixelPicker.savePickersToFile(pixelDataFileName);
  }
}
