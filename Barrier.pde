class Barrier {

  float radius;
  float radiusAnim;
  PVector inputPosition;
  float rotation;
  float rotationTarget;
  float easing;
  int levels;
  float shadowSize;

  color[] coreColors;
  float colorOsc;
  float colorOscIncrement;

  boolean active; // not really being used

  PGraphics drawSurface;

  Barrier() {

    radius = width * 0.4;
    levels = 5;
    shadowSize = 500;

    coreColors = new color[2];
    coreColors[0] = color(255);
    coreColors[1] = color(0, 0, 255);

    colorOsc = 0;
    colorOscIncrement = 0.03;

    inputPosition = new PVector();
    rotationTarget = 0;
    rotation = rotationTarget;
    easing = 0.05;
    radiusAnim = 0;

    active = false;
  }

  void render() {
    drawSurface.beginDraw();
    drawSurface.noStroke();

    /*
    for (int i=levels - 1; i >= 0; i--) {
     //color c = color(255,0,0, map(i, levels - 1, 0, 50, 255));
     color c = color(0, map(i, levels - 1, 0, 100, 255));
     
     float ringSize = ((float(i) / levels) * shadowSize);
     
     drawSurface.fill(c);
     drawSurface.ellipse(center.x, center.y, ringSize, ringSize);
     }
     */

    //    radius += radiusAnim;
    //    radius = constrain(radius, 0, 1);


    /*
    if (inputPosition.y < height * 0.5) {
     rotationTarget = map(inputPosition.x, 0, width, PI, TWO_PI);
     } else {
     rotationTarget = map(inputPosition.x, 0, width, PI, 0);
     }
     */

    rotationTarget = map(inputPosition.x, 0, width, PI, TWO_PI);

    float targetDistance = rotationTarget - rotation;
    rotation += targetDistance * easing;

    drawSurface.pushMatrix();
    drawSurface.translate(drawSurface.width * 0.5, drawSurface.height * 0.5);
    drawSurface.rotate(rotation);

    float colorIntensity =  map(sin(colorOsc), 0, 1, 0.5, 1);
    drawSurface.fill(0, colorIntensity * 255);
    drawSurface.ellipse(radius, 0, 300, 300);

    drawSurface.fill(colorIntensity * 255);
    drawSurface.ellipse(radius, 0, 100, 100);
    //drawSurface.ellipse(radius * (width * 0.4), 0, 100, 100);
    drawSurface.popMatrix();
    /*
    // DRAW THE COLORED CORE
     drawSurface.fill(lerpColor(coreColors[0], coreColors[1], (sin(colorOsc) + 1) * 0.5)  );
     float coreX = center.x + random(-25,25);
     float coreY = center.y + random(-25,25);
     
     drawSurface.ellipse(coreX, coreY, 100, 100);
     
     //DRAW THE CORE STROBE
     float alpha = random(1) > 0.7 ? 255 : 0;
     drawSurface.fill(0,alpha);
     drawSurface.ellipse(coreX, coreY, 100, 100);
     */

    drawSurface.endDraw();

    colorOsc += colorOscIncrement;
  }

  void setRotation(float rot) {
    rotationTarget = rot;
  }

  void setInputPosition(float inX, float inY) {
    inputPosition.set(inX, inY);
  }
  void bindToDrawSurface(PGraphics surface) {
    drawSurface = surface;
  }

  boolean isActive() {
    return active;
  }

  void fadeIn() {
    radius = 0;
    radiusAnim = 0.02;
  }

  void fadeOut() {
    radiusAnim = -0.02;
  }
}

