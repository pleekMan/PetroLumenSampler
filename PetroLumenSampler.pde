// WHEN RUNNING, THE APP SENDS SOME SERIAL DATA THAT FUCKS UP THE
// BYTE ORDERING CONSTANTLY SENT THROUGHT THE PIXEL PICKER.
// TO RE-ORDER IT, PixelPicker.reset() CLEARS THE SERIAL BUFFER AND WAITS 5 SECONDS (APP COMPLETELY PAUSES, WITH NO SENDING)

// ALL Picker's coordinates are normalized. Remember to map them when using them. 

import processing.serial.*;

Serial serialPort;
PixelPicker pixelPicker;
PerlinWaves perlinWaves;

boolean clearScreen;
boolean placePickersMode;

String pixelDataFileName = "rockyData.csv";

//ArrayList<RiverWave> waves;

Barrier barrier;

void setup() {
  size(500, 500, P2D);
  frameRate(30);
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

  perlinWaves = new PerlinWaves();

  clearScreen = true;
  placePickersMode = false;

  /*
  waves = new ArrayList<RiverWave>();
   for (int i=0; i < 50; i++) {
   RiverWave newWave = new RiverWave();
   //println("-|| Wave Alpha: " + newWave.opacity);
   waves.add(newWave);
   }
   */

  barrier = new Barrier(0, 0);
  barrier.bindToDrawSurface(pixelPicker.getDrawSurface());
}

void draw() {
  if (clearScreen) {
    background(0);
    //clearScreen = false;
  }

  /*
  for (RiverWave wave : waves) {
   wave.update();
   wave.render();
   }
   */

  // GENERATE WAVES WITH PERLIN NOISE
  perlinWaves.mapToPickers(pixelPicker.getAllPickers(), pixelPicker.getDrawSurface().width, pixelPicker.getDrawSurface().height);

  // ---------------- PixelPICKERS


  //if (frameCount % 1 == 0) {

  // DRAW ON PIXEL PICKER SURFACE
  PGraphics drawSurface = pixelPicker.getDrawSurface();
  drawSurface.beginDraw();
  drawSurface.background(0);
  drawSurface.noStroke();
  for (int i=0; i < pixelPicker.getAllPickers ().size(); i++) {
    float x = pixelPicker.getPicker(i).x * pixelPicker.getDrawSurface().width;
    float y = pixelPicker.getPicker(i).y * pixelPicker.getDrawSurface().height;

    drawSurface.fill(pixelPicker.getPicker(i).getColor());
    drawSurface.ellipse(x, y, 20, 20);
  }
  drawSurface.endDraw();

  barrier.render();

  pixelPicker.pick();
  //pixelPicker.sendOut();

  if (placePickersMode) {
    pixelPicker.drawPickers();
  } else {
    pixelPicker.renderDrawSurface();
  }




  fill(255);
  text("FR: " + frameRate, 10, 10);
}

void mousePressed() {
  if (placePickersMode) {
    //pixelPicker.addPicker(mouseX, mouseY);
  }
}

void mouseDragged() {
  barrier.setPosition(mouseX, mouseY);
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
