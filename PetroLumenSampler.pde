// WHEN RUNNING, THE APP SENDS SOME SERIAL DATA THAT FUCKS UP THE
// BYTE ORDERING CONSTANTLY SENT THROUGHT THE PIXEL PICKER.
// TO RE-ORDER IT, PixelPicker.reset() CLEARS THE SERIAL BUFFER AND WAITS 5 SECONDS (APP COMPLETELY PAUSES, WITH NO SENDING)

import processing.serial.*;

Serial serialPort;
PixelPicker pixelPicker;

boolean clearScreen;
boolean placePickersMode;

String pixelDataFileName = "rockyData.csv";

ArrayList<RiverWave> waves;

void setup() {
  size(500, 500);
  frameRate(25);
  //colorMode(HSB, 255);
  background(0);
  strokeCap(SQUARE);


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

  waves = new ArrayList<RiverWave>();
  for (int i=0; i < 20; i++) {
    RiverWave newWave = new RiverWave();
    println("-|| Wave Alpha: " + newWave.opacity);
    waves.add(newWave);
  }
}

void draw() {
  if (clearScreen) {
    background(0);
    //clearScreen = false;
  }

  for (RiverWave wave : waves) {
    wave.update();
    wave.render();
  }



  // ---------------- PICKERS

  if (placePickersMode) {
  } else {
    //if (frameCount % 1 == 0) {
    pixelPicker.pick();
    pixelPicker.sendOut();
    //}
  }

  // TEST WITH ELLIPSES
  fill(0);
  noStroke();
  rect(0, 0, width, height);
  for (Picker picker : pixelPicker.getAllPickers ()) {
    noFill();
    fill(picker.getColor());
    ellipse(picker.getX() * width, picker.getY() * height, 50, 50);
  }

  //pixelPicker.drawPickers();
  
  text("FR: " + frameRate, 10,10);
  
}

void mousePressed() {
  if (placePickersMode) {
    pixelPicker.addPicker(mouseX, mouseY);
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

  if (key == 'r') {
    pixelPicker.removeAll();
  }
}
