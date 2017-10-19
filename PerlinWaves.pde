class PerlinWaves {

  float noiseFarLimits;
  float z;
  float zIncrement;

  PVector center;
  float noiseRotation;
  float noiseRotationIncrement;

  boolean drawDebug;

  PerlinWaves() {

    noiseFarLimits = 5.0;
    z = random(10);
    zIncrement = 0.01;

    noiseRotation = 0;
    noiseRotationIncrement = -0.01;

    center = new PVector(width * 0.5, height * 0.5);
    
    drawDebug = false;
  }


  public void update() {
  }

  public void mapToPickers(ArrayList<Picker> pickers, int surfaceWidth, int surfaceHeight) {

    //noiseFarLimits = (float)mouseX / width * 20;


    for (int i=0; i < pickers.size (); i++) {

      // THE virtualPicker WILL ROTATE AROUND CENTER, OVER THE PERLIN NOISE TEXTURE, AND
      // AND WILL PASS IT'S COLOR TO THE STATIC picker (the rock)
      // THIS SIMULATES A CIRCULAR FLOW
      PVector virtualPicker = new PVector (pickers.get(i).getX() * surfaceWidth, pickers.get(i).getY() * surfaceHeight);
      virtualPicker.sub(center);
      virtualPicker.rotate(noiseRotation);
      virtualPicker.add(center);

      // DRAW THE VIRTUAL PICKERS
      if (drawDebug) {
        fill(255, 0, 0);
        ellipse(virtualPicker.x, virtualPicker.y, 5, 5);
        if (i==0) {
          stroke(255, 0, 0);
          pushMatrix();
          translate(center.x, center.y);
          rotate(noiseRotation);
          line(0, 0, surfaceWidth * 0.5, 0);
          popMatrix();
          noStroke();
        }
      }


      float noiseX = map(virtualPicker.x, 0, width, 0, noiseFarLimits);
      float noiseY = map(virtualPicker.y, 0, height, 0, noiseFarLimits);
      float noiseZ = z;

      float pickerValue = noise(noiseX, noiseY, noiseZ);
      pickerValue = contrastSigmoid(pickerValue, (float)mouseX / width);

      pickers.get(i).setColor(color(0, 0, pickerValue * 255));
    }



    //z += zIncrement;
    noiseRotation += noiseRotationIncrement;
  }

  float contrastSigmoid(float t, float strength) {
    float y = 0;
    if (t <= 0.5) {
      y = (strength * t) / (strength + 0.5 - t);
    } else {
      float t2 = 1-t;
      y = (strength * t2) / (strength + 0.5 - t2);
      y = 1-y;
    }
    return y;
  }
  
  void drawDebug(boolean state){
   drawDebug = state; 
  }
}
