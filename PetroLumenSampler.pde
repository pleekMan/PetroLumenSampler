// ALL Picker's coordinates are normalized. Remember to map them when using them.  //<>//

import processing.serial.*;

Serial serialPort;
PixelPicker pixelPicker;
PerlinWaves perlinWaves;
ComputerVisionManager CVManager;

boolean clearScreen;
boolean placePickersMode;
boolean enableConstantSendOut;

//PImage conexionadoPic;

String pixelDataFileName = "rockyData.csv";

//ArrayList<RiverWave> waves;

ArrayList<Barrier> barriers;

void setup() {
  size(500, 500, P2D);
  frameRate(30);
  //colorMode(HSB, 255);
  background(0);
  strokeCap(SQUARE);


  println(Serial.list());
  try {
    String portName = Serial.list()[9];
    println("--------------------");
    serialPort = new Serial(this, portName, 115200);
  } 
  catch (Exception e) {
    println("-|| ALGO ANDA MAL CON LA ELECTRONICA..!!!");
  }

  pixelPicker = new PixelPicker(width, height);
  pixelPicker.setupPickersFromFile(pixelDataFileName);

  perlinWaves = new PerlinWaves();

  CVManager = new ComputerVisionManager(this);

  barriers = new ArrayList<Barrier>();
  for (int i=0; i< CVManager.maxPeopleCount; i++) {
    // INITIALIZE ALL POSSIBLE BARRIERS, THEN DRAW THEM IF NECESSARY
    Barrier newBarrier = new Barrier();
    newBarrier.bindToDrawSurface(pixelPicker.getDrawSurface());
    barriers.add(newBarrier);
  }

  clearScreen = true;
  placePickersMode = false;
  enableConstantSendOut = false;

  //conexionadoPic = loadImage("conexionado.png");
}

void draw() {
  if (clearScreen) {
    background(0);
    //clearScreen = false;
  }


  // ---------------- GENERATE WAVES WITH PERLIN NOISE

  perlinWaves.mapToPickers(pixelPicker.getAllPickers(), pixelPicker.getDrawSurface().width, pixelPicker.getDrawSurface().height);

  //image(conexionadoPic,0,0);


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

  // ---------------- COMPUTER VISION PEOPLE + BARRIER DRAWING
  noFill();
  stroke(0, 255, 0);
  CVManager.update();
  PVector[] detectedPeople = new PVector[CVManager.getPeopleCount()];
  if (CVManager.detectsSomething()) { // the previous line might yield an empty array (also using it to have the array initialized)
    detectedPeople = CVManager.getAllCentroids();

    for (int i=0; i< detectedPeople.length; i++) {
      barriers.get(i).setInputPosition(detectedPeople[i].x * width, detectedPeople[i].y * height);

      barriers.get(i).render();
      //println("-|| Barrier => " + i + " | X: " + barriers.get(i).center.x +  " --- Y: " + barriers.get(i).center.y);
    }
  }


  pixelPicker.pick();
  if (enableConstantSendOut) {
    if (frameCount % 2 == 0) {
      pixelPicker.sendOut();
    }
  }

  if (placePickersMode) {
    pixelPicker.drawPickers();
    fill(255, 255, 0);
    text("-| DRAWING PICKER SETUP", 10, 30);
  } else {
    pixelPicker.renderDrawSurface();
    fill(255, 255, 0);
    text("-| DRAWING drawSurface", 10, 30);
  }

  // ---------------- COMPUTER VISION PEOPLE : DEBUG DRAWING
  /*
  for (int i=0; i< detectedPeople.length; i++) {
   ellipse(detectedPeople[i].x * width, detectedPeople[i].y * height, 50, 50);
   }
   */

  fill(255);
  text("FR: " + floor(frameRate), 10, 10);
}

void mousePressed() {
  if (placePickersMode) {
    pixelPicker.addPicker(mouseX, mouseY);
  }
}

void mouseDragged() {
  //barrier.setPosition(mouseX, mouseY);
}


void keyPressed() {

  if (key == ESC) {
    key = 0; // clear key value
    println ("-|| Stopping Serial Port");
    serialPort.stop();
    println ("-|| Exiting Program");

    exit();
  }

  if (key == ' ') {
    pixelPicker.sendOut();
  }

  if (key == 'e') {
    clearScreen = !clearScreen;
  }

  if (key == 'r') {
    pixelPicker.resetSender();
  }

  if (key == 'c') {
    enableConstantSendOut = !enableConstantSendOut;
    println("-|| Constant Sending => " + enableConstantSendOut);
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

// ========= ARDUINO CODE  ================== 

/*
#include <PololuLedStrip.h>
 
 // Create an ledStrip object and specify the pin it will use.
 PololuLedStrip<12> ledStrip;
 
 // Create a buffer for holding the colors (3 bytes per color).
 #define LED_COUNT 4
 rgb_color colors[LED_COUNT];
 
 char rgbIn[3];
 
 void setup()
 {
 // Start up the serial port, for communication with the PC.
 Serial.begin(115200);
 Serial.println(" Ready to receive colors!!");
 //Serial.setTimeout(0);
 
 testLights();
 }
 
 void loop()
 {
 
 if (Serial.available()) {
 
 for (int i = 0; i < LED_COUNT; i++) {
 Serial.readBytes(rgbIn, 3);
 
 
 colors[i].red = map(rgbIn[0], 0, 100, 0, 255);
 colors[i].green = map(rgbIn[1], 0, 100, 0, 255);
 colors[i].blue = map(rgbIn[2], 0, 100, 0, 255);
 
 
 //      Serial.print(rgbIn[0]);
 //      Serial.print(" - ");
 //      Serial.print(rgbIn[1]);
 //      Serial.print(" - ");
 //      Serial.println(rgbIn[2]);
 //      Serial.println("=============");
 
 
 }
 
 }
 
 ledStrip.write(colors, LED_COUNT);
 
 
 delay(10);
 }
 
 void testLights() {
 
 clearLights();
 
 for (int i = 0; i < LED_COUNT; i++) {
 
 colors[i].red = 255;
 colors[i].green = 255;
 colors[i].blue = 255;
 
 ledStrip.write(colors, LED_COUNT);
 
 delay(50);
 
 }
 
 delay(2000);
 
 clearLights();
 
 
 }
 
 void clearLights() {
 for (int i = 0; i < LED_COUNT; i++) {
 
 colors[i].red = 0;
 colors[i].green = 0;
 colors[i].blue = 0;
 
 ledStrip.write(colors, LED_COUNT);
 }
 }
 
 */
