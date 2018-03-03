class Picker {

  // VALUES ARE NORMALIZED
  float x, y;
  color c;

  Picker(float _x, float _y) {

    x = _x;
    y = _y;

    c = color(0);
  }


  void setX(float _x) {
    x = _x;
  }

  void setY(float _y) {
    y = _y;
  }

  void setColor(color _c) {
    c = _c;
  }

  float getX() {
    // VALUES ARE NORMALIZED
    return x;
  }

  float getY() {
    // VALUES ARE NORMALIZED
    return y;
  }

  color getColor() {
    return c;
  }
}
