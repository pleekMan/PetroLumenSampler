// ALL Picker's coordinates are normalized. Remember to map them when using them.  //<>//

import processing.serial.*;

Serial serialPort;
PixelPicker pixelPicker;
PerlinWaves perlinWaves;
ComputerVisionManager CVManager;

int serialPortNumber = 3;
int inMessage;

boolean clearScreen;
boolean placePickersMode;
boolean enableConstantSendOut;
boolean enableManualDrawing;
boolean setContrastMode;

float faderIntensity = 1;
float faderVelocity = -0.02;

//int previousPeopleCount;

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

  // ARDUINO/SERIAL SETUP
  println(Serial.list());
  try {
    String portName = Serial.list()[serialPortNumber];
    println("--------------------");
    serialPort = new Serial(this, portName, 115200);
  } 
  catch (Exception e) {
    println("-|| ALGO ANDA MAL CON LA ELECTRONICA..!!!");
    println("---------------------------");
  }
  inMessage = 0;



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

  if (enableManualDrawing) {
    drawSurface.fill(255);
    drawSurface.ellipse(mouseX, mouseY, 40, 40);
  }

  drawSurface.fill(0, faderIntensity * 255);
  drawSurface.rect(0, 0, drawSurface.width, drawSurface.height);


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
    }

    //println("-|| Barrier => " + i + " | X: " + barriers.get(i).center.x +  " --- Y: " + barriers.get(i).center.y);
  }



  pixelPicker.pick();
  if (enableConstantSendOut) {
    if (frameCount % 2 == 0) {
      pixelPicker.sendOut();
    }
  }

  faderProcedures();


  if (placePickersMode) {
    pixelPicker.drawPickers();
    fill(255, 255, 0);
    text("-| DRAWING PICKER SETUP", 10, 490);
  } else {
    pixelPicker.renderDrawSurface();
    fill(255, 255, 0);
    text("-| DRAWING drawSurface", 10, 490);
  }

  // ---------------- COMPUTER VISION PEOPLE : DEBUG DRAWING
  /*
  for (int i=0; i< detectedPeople.length; i++) {
   ellipse(detectedPeople[i].x * width, detectedPeople[i].y * height, 50, 50);
   }
   */

  fill(255);
  text("FR: " + floor(frameRate), 10, 20);
  text("Constant SendOut Enabled  ->  " + enableConstantSendOut, 10, 40);
  text("SendOut Enabled  ->  " + pixelPicker.enableSendOut, 10, 60);

  if (setContrastMode) {
    perlinWaves.contrastStrength = (float)mouseX / width;
    drawContrastCurve();
  }
}

void faderProcedures() {

  if (serialPort != null) {
    if ( serialPort.available() > 0) { 
      inMessage = serialPort.read();
      println(inMessage);
    }
  }

  if (inMessage == 201) {
    faderVelocity = -0.02;
  } else if (inMessage == 202) {
    faderVelocity = 0.02;
  }

  // FADER ANIM

  faderIntensity += faderVelocity;
  faderIntensity = constrain(faderIntensity, 0, 1);

  //println("Picker 0 - blue: " + blue(pixelPicker.pickers.get(0).c));

  if (faderIntensity < 0.97) { // REMEMBER THAT faderIntensity MEANS BLACK AT 1
    pixelPicker.setEnableSendOut(true);
  } else {
    pixelPicker.setEnableSendOut(false);
    fill(255);
    text("Picker 0 - blue: " + blue(pixelPicker.pickers.get(0).c), 10, 100);
  }
}

void drawContrastCurve() {

  text("Color Contrast: " + perlinWaves.contrastStrength, 200, 190);

  noFill();
  stroke(255);

  PVector origin = new PVector(200, 200);
  PVector boxSize = new PVector(100, 100);

  rect(origin.x, origin.y, boxSize.x, boxSize.y);

  PVector linePointA = new PVector();
  linePointA.set(origin);
  PVector linePointB = new PVector();
  linePointB.set(linePointA);

  int pointCount = 20;
  for (int i=0; i<pointCount; i++) {

    linePointB.set(linePointA);

    linePointA.x = ((float(i)/pointCount) * boxSize.x) + origin.x;
    linePointA.y = perlinWaves.contrastSigmoid((float(i)/pointCount), perlinWaves.contrastStrength);
    linePointA.y = (origin.y + boxSize.y) - (linePointA.y * boxSize.y);

    line(linePointB.x, linePointB.y, linePointA.x, linePointA.y);
  }

  if (perlinWaves.contrastStrength < 0.006) {
    fill(255);
    rect(origin.x + (boxSize.x * 0.5), origin.y, boxSize.x * 0.5, boxSize.y);
  }
}

// EVENTS -----------------

void mousePressed() {
  if (placePickersMode) {
    pixelPicker.addPicker(mouseX, mouseY);
  }
}

void mouseDragged() {
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
    //pixelPicker.removeAll();
  }

  if (key == 'm') {
    enableManualDrawing = !enableManualDrawing;
    println("-|| Manual Drawing => " + enableManualDrawing);
  }

  if (key == 'l') {
    setContrastMode = !setContrastMode;
    println("-|| SET CONTRAST MODE => " + setContrastMode);
  }
}

// ========= ARDUINO CODE  ================== 

/*

 #include <PololuLedStrip.h>
 
 // Create an ledStrip object and specify the pin it will use.
 PololuLedStrip<12> ledStrip;
 
 // Create a buffer for holding the colors (3 bytes per color).
 #define LED_COUNT 98
 rgb_color colors[LED_COUNT];
 
 char rgbIn[3];
 int ledsRead;
 
 const byte pirPin = 2;
 
 volatile boolean pirState = false;
 volatile boolean pirStatePrevious = pirState;
 
 void setup()
 {
 Serial.begin(115200);
 Serial.println(" Ready to receive colors!!");
 //Serial.setTimeout(0);
 
 pinMode(pirPin, INPUT);
 attachInterrupt(digitalPinToInterrupt(pirPin), updatePirState, CHANGE);
 
 
 pinMode(13, OUTPUT);
 
 ledsRead = 0;
 
 testLights();
 }
 
 void loop()
 {
 
 // PIR SENSOR
 //readPIR();
 
 //Serial.println("Inside PIR-TRUE");
 
 if (Serial.peek() == 101) { // 101 => CODE FOR "FINISHED SENDING ALL LEDS"
 //Serial.write(101);
 Serial.read();
 ledsRead = 0;
 }
 
 while (ledsRead < LED_COUNT) {
 //readPIR();
 
 if (Serial.available()) {
 
 
 
 //for (int i = 0; i < LED_COUNT; i++) {
 
 
 Serial.readBytes(rgbIn, 3);
 
 //if(rgbIn[0] > 100)break;
 
 
 colors[ledsRead].red = map(rgbIn[0], 0, 100, 0, 255);
 colors[ledsRead].green = map(rgbIn[1], 0, 100, 0, 255);
 colors[ledsRead].blue = map(rgbIn[2], 0, 100, 0, 255);
 
 //}
 
 //Serial.flush();
 ledsRead++;
 }
 
 
 }
 
 ledStrip.write(colors, LED_COUNT);
 //readPIR();
 
 
 
 delay(10);
 }
 
 void updatePirState() {
 
 //Serial.print("Reading PIR: ");
 
 pirState = digitalRead(pirPin);
 digitalWrite(13, pirState);
 
 if ( pirState != pirStatePrevious) {
 //printPirState();
 
 //Serial.println(pirState);
 //Serial.println("------------------");
 
 if (pirState == true) {
 Serial.write(201); // SEND "PRESENCE" TO P5
 } else {
 Serial.write(202); // SEND "ABSCENSE" TO P5
 
 }
 pirStatePrevious = pirState;
 }
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
 
 delay(500);
 
 clearLights();
 
 
 }
 
 void clearLights() {
 for (int i = 0; i < LED_COUNT; i++) {
 
 colors[i].red = 0;
 colors[i].green = 0;
 colors[i].blue = 0;
 
 }
 ledStrip.write(colors, LED_COUNT);
 }
 
 */
