class Picker {

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
    return x;
  }

  float getY() {
    return y;
  }

  color getColor() {
    return c;
  }
}
