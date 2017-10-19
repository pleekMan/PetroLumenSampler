class PixelPicker {

  ArrayList<Picker> pickers;
  //float surfaceWidth, surfaceHeight;
  PGraphics drawSurface;

  PixelPicker(int _pickerCount, int _surfaceWidth, int _surfaceHeight) {

    pickers = new ArrayList<Picker>();
    drawSurface = createGraphics(_surfaceWidth, _surfaceHeight, P2D);

    setupPickers(_pickerCount);
    resetSender();
  }

  PixelPicker(int _surfaceWidth, int _surfaceHeight) {

    pickers = new ArrayList<Picker>();
    drawSurface = createGraphics(_surfaceWidth, _surfaceHeight, P2D);


    setupPickers(1);
    resetSender();
  } 

  public void setupPickers(int pickerCount) {
    println("-|| SETTING UP PICKERS");

    for (int i=0; i< pickerCount; i++) {
      Picker newPicker = new Picker(0, 0);
      pickers.add(newPicker);
    }
  }

  public void setupPickersFromFile(String _fileName) {

    String[] eachPickerData = loadStrings(_fileName);

    if (eachPickerData == null) {
      println("-|| NO DATA COULD BE LOADED FROM FILE. DEFAULTING TO 1 PICKER at 0,0");
    } else {
      pickers.clear();
      for (int i=0; i < eachPickerData.length; i++) {
        //println(eachPickerData[i]);
        String[] dataSplit = split(eachPickerData[i], ','); // 0=id, 1=x, 2=y
        if (!dataSplit[0].equals("")) { // IF WE ARE IN AN EMPTY LINE (CREATED BY savePickers WAY OF SAVING)
          Picker newPicker = new Picker(float(dataSplit[1]), float(dataSplit[2]));
          pickers.add(newPicker);
        }
      }
    }
  }

  public void savePickersToFile(String _fileName) {
    String allPickersData = "";

    for (int i=0; i < pickers.size (); i++) {
      allPickersData += i + "," + pickers.get(i).getX() + "," + pickers.get(i).getY() + ":";
    }

    String[] asList = split(allPickersData, ":");
    saveStrings(dataPath("") + "/" + _fileName, asList);
  }

  public void pick() {
    drawSurface.loadPixels();
    for (int i=0; i< pickers.size (); i++) {
      Picker p = pickers.get(i);
      p.setColor(getColorAt(p.getX(), p.getY()));
    }

    //sendOut();
  }

  color getColorAt(float x, float y) {
    //println("DS.width -> " + drawSurface.width);
    int pixelSlot = int((x * drawSurface.width) + (drawSurface.width * (y * drawSurface.height)));
    return drawSurface.pixels[pixelSlot];
  }

  Picker getPicker(int pickerNum) {
    return pickers.get(pickerNum);
  }

  public void addPicker(float _x, float _y) {
    pickers.add(new Picker(_x / drawSurface.width, _y / drawSurface.height));
  }

  public void sendOut() {

    if (serialPort != null) {

      for (int i = 0; i < pickers.size (); i++) {
        color c = pickers.get(i).getColor();
        int r = (c >> 16) & 0xFF;
        int g = (c >> 8) & 0xFF;
        int b = c & 0xFF;
        byte[] toSend = {
          (byte)r, (byte)g, (byte)b
        };
        serialPort.write(toSend);
      }
      serialPort.clear();
    }
  }

  void drawPickers() {

    for (int i=0; i< pickers.size (); i++) {
      fill(255);
      noStroke();
      text(i, (pickers.get(i).getX() * drawSurface.width) + 10, (pickers.get(i).getY() * drawSurface.height));
      
      fill(pickers.get(i).getColor());
      //stroke(255);
      noStroke();
      ellipse(pickers.get(i).getX() * drawSurface.width, pickers.get(i).getY() * drawSurface.height, 10, 10);
    }
  }
  
  void renderDrawSurface(){
    image(drawSurface,0,0);
  }
  
  PGraphics getDrawSurface(){
   return drawSurface; 
  }

  void removeAll() {
    pickers.clear();
  }

  ArrayList<Picker> getAllPickers() {
    return pickers;
  }

  void resetSender() {

    if (serialPort != null) {
      println(" || RESETING PICKERS...");

      serialPort.clear();
      delay(2000);

      println(" || PICKER RESET DONE. GO..!!");
    }
  }

  int getPickerCount() {
    return pickers.size();
  }
}
