//projectile and collision class

class projectile extends displayable {
  PVector vel, min, max;
  int damage=5;
  int lifeSpan=160;
  int team = 0;
  int val = -1;
  //each projectile has an object
  //which records the shortest collision
  //every frame (the bullet may hit multiple 
  //objects, so the shortest collision must 
  //always be the one that gets calculated)
  collision coll;
  projectile() {
    //this is an extension of the displayable class
    //so we can normally set up the variables from that class
    image_w=2;
    image_h=1;
    spriteSheet=2;
    //create new collision
    coll = new collision();
  }
  void update() {
    super.update();
    lifeSpan--;
    if (lifeSpan<=0)remove=true;   
    pos.add(vel);
    setMinMax();
  }
  void setMinMax() {
    min = new PVector(pos.x+min(vel.x, 0), pos.y+min(vel.y, 0), pos.z+min(vel.z, 0));
    max = new PVector(pos.x+max(vel.x, 0), pos.y+max(vel.y, 0), pos.z+max(vel.z, 0));
  }
  void display1() {
    super.display1();
  }
}

class collision {
  /*
  - for projectiles
   - helps to ensure that the shortest collision
   is the one which is calculated at the end of the frame
   */


  //some random large number
  //(must be greater than the projectile's velocity!)
  //although projectiles with high velocity will
  //occupy more space in the quadtree, which is inneficient!
  float dist = 500;

  int type = 0;
  //0 = character
  //1 = plane

  //point in array of target (plane or character)
  int arPoint = 0;

  //consider will be true if collision is detected
  boolean consider = false;

  collision() {
  }
}
