import tsps.*;

// CLASS TO INTERACT WITH "TSPS Computer Vision Tool" or "Community Core Vision" or Other..
// VALUES ARE RECIEVED NORMALIZED

class ComputerVisionManager {

  TSPS CVReceiver;
  ArrayList<TSPSPerson> people;
  int maxPeopleCount;

  ComputerVisionManager(PApplet _p5) {
    println("-|| STARTING COMPUTER VISION MANAGER");

    CVReceiver = new TSPS(_p5, 12000);
    people = new ArrayList<TSPSPerson>();
    maxPeopleCount = 5;
    println("---------------------------");
  }

  void update() {
    TSPSPerson[] peopleArray = CVReceiver.getPeopleArray();

    people.clear();

    for (int i=0; i<peopleArray.length; i++) {
      if (i<maxPeopleCount) {
        people.add(peopleArray[i]);
      } else {
        break;
      }
    }
  }

  PVector getCentroidFrom(int person) {
    if (person < people.size()) {
      return people.get(person).centroid;
    }
    return new PVector();
  }

  PVector[] getAllCentroids() {
    PVector[] centroids = new PVector[people.size()];    
    for (int i=0; i < centroids.length; i++) {
      centroids[i] = people.get(i).centroid;
    }
    return centroids;
  }

  boolean detectsSomething() {
    return CVReceiver.getNumPeople() > 0;
  }

  int getPeopleCount() {
    return people.size();
  }
}
