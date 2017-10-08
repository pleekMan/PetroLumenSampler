import tsps.*;

// CLASS TO INTERACT WITH "TSPS Computer Vision Tool" or "Community Core Vision" or Other..

class ComputerVisionManager {

  TSPS CVReceiver;
  TSPSPerson[] people;

  ComputerVisionManager(PApplet _p5) {
    CVReceiver = new TSPS(_p5, 12000);
    people = new TSPSPerson[0];
  }

  void update() {
    people = CVReceiver.getPeopleArray();
  }

  PVector getCentroidFrom(int person) {
    if (detectsSomething()) {
      if (person < CVReceiver.getNumPeople()) {
        return people[person].centroid;
      }
    }
    println("-|| BLOB " + person + " DOES NO EXIST");
    return new PVector();
  }
  
  PVector[] getAllCentroids(){
   PVector[] centroids = new PVector[CVReceiver.getNumPeople()];    
    for(int i=0; i < centroids.length; i++){
      centroids[i] = people[i].centroid;
    }
    return centroids;
  }

  boolean detectsSomething() {
    return CVReceiver.getNumPeople() > 0;
  }
}
