public class RiverWave {
  // RiverWaves, FOR PetroLumen "ring", ARE ROTATING ARCS

  float arcLength;
  float diameter;
  float rotation;
  float velocity;
  float thickness;
  color c;
  float opacity;

  float radiusMotion;
  float radiusMotionIncrement;

  RiverWave() {

    arcLength = random(PI);
    diameter = random(0.55 * width, width);
    rotation = random(TWO_PI);
    velocity = random(TWO_PI * 0.002);
    thickness = random(10, 50);
    opacity = random(0.01, 0.5);
    c = color (0, 0, 255, opacity * 255);

    radiusMotion = random(-1, 1);
    radiusMotionIncrement = random(0.02);
  }

  void update() {
    rotation += velocity;
    
    radiusMotion += radiusMotionIncrement;
    diameter = map(sin(radiusMotion), -1,1,0.55 * width, width);
  }

  void render() {
    pushStyle();

    noFill();
    strokeWeight(thickness);
    stroke(c);

    arc(int(width * 0.5), int(height * 0.5), diameter, diameter, rotation, rotation + arcLength);

    popStyle();
  }
}
