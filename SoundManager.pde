class SoundManager {

  Minim soundLib;

  AudioPlayer ambient;
  AudioPlayer puf;
  
  

  SoundManager(PApplet p5) {

    soundLib = new Minim(p5);

    ambient = soundLib.loadFile("ambient.mp3");
    ambient.loop();

    puf = soundLib.loadFile("puf.mp3");
  }

  void triggerAvatarSound() {
    if (!puf.isPlaying()) {
      puf.rewind();
      puf.play();
    }
  }
}
