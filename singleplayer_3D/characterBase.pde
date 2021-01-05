class characterBase {
  /* basic rundown of characterBase
  - the characterBase primarily interacts with planes
  and other characterBases
  - it also contains information for movement, collisions, combat (health, team)
  - moveAngle determines the direction the player will move
  - faceAngle determines the 'facing' direction, independant of movement
  - usually for basic AI, they are both the same thing.
  */
  
  //this is just so I don't have to call "things.indexOf()"
  //very often inside the quadtree
  int val = -1;
  PVector pos, vel, prevPos, spawnPos, min, max;
  float moveAngle, faceAngle;
  displayable anim = new displayable();
  boolean[] againstSurface = new boolean[3]; //floor, wall, ceiling
  float speed = 0, moveSpeed = 1.85;
  int maxHealth = 100, health = maxHealth;
  float r = 4.0, h = 32.0;
  //time between bullets
  int shootTimer = 0;
  //timer to time footstep sounds
  int walkTimer = 0;
  //timer to delay health regeneration
  int damage = 0;
  //characters on same team cannot harm each other
  int team = 0;
  //for the death animation
  int deathTimer = 10;
  float slope;
  float viewAngle;
  characterBase() {
    pos = new PVector(0, -8, 0);
    anim.pos=pos;
    anim.image_h=h;
    spawnPos = pos.copy();
    prevPos = pos.copy();
    vel = new PVector();
  }
  void reset() {
    //when resetting a character, they
    //return to their spawn location
    //with max health and 0 speed
    pos = spawnPos.copy();
    anim.pos=pos;
    prevPos=new PVector();
    vel = new PVector();
    speed=0;
    health=maxHealth;
  }
  void update() {
    vel.y=min(vel.y, 16);
    //there may be instances where we need to know
    //the difference between the player and their
    //previous position
    prevPos = pos.copy();
    pos.add(vel);
    //add gravity to velocity
    vel.y+=gravity;
    //if the player is on a floor
    //apply 'friction' and update walkTimer 
    if (againstSurface[0]) {
      vel.y=min(vel.y, 0);
      vel.mult(slope); 
      if (vel.mag()>.8)walkTimer++;
      else walkTimer = 0;
      if (walkTimer==43)walkTimer=0;
    } else {
      walkTimer=0;
    }
    if (health<=0) {
      if (deathTimer>0)deathTimer--;
    }
    againstSurface=new boolean[3];
    updateVelocity();
    if (shootTimer>0)shootTimer--;
    min = new PVector(pos.x-r+min(vel.x, 0), pos.y-h/2.0+min(vel.y, 0), pos.z-r+min(vel.z, 0));
    max = new PVector(pos.x+r+max(vel.x, 0), pos.y+h/2.0+max(vel.y, 0)+4, pos.z+r+max(vel.z, 0));
    animationHandler();
  }
  void updateVelocity() {
    vel.x=(vel.x*.5+sin(moveAngle)*speed*.5);
    vel.z=(vel.z*.5+cos(moveAngle)*speed*.5);
  }
  void collide(characterBase other) {
    //basic collision with other character
    if (other.pos.y+other.h/2.0>pos.y-h/2.0&&other.pos.y-other.h/2.0<pos.y+h/2.0) {
      float d_ = dist(other.pos.x, other.pos.z, pos.x, pos.z);
      if (d_<other.r+r) {
        d_ = ((other.r+r)-d_)*.5;
        float ang = atan2(pos.x-other.pos.x, pos.z-other.pos.z);
        pos.x+=sin(ang)*d_;
        pos.z+=cos(ang)*d_;
        other.pos.x-=sin(ang)*d_;
        other.pos.z-=cos(ang)*d_;
      }
    }
  }
  void animationHandler() {
    //for other classes
  }
}
//here I make a basic zombie class
//although a custome character class can
//be much more sophisticated
class zombie extends characterBase {
  //cooldown between 'decisions'
  int decisionTimer = 0, decisionTimer2 = 0; 
  float angleB; //angle between zombie and player
  zombie() {
    super();
    speed=1;
    moveAngle = random(TWO_PI);
    faceAngle = moveAngle;
  }
  void update() {
    //basic AI (really dumb AI)
    if (decisionTimer>0)decisionTimer--;
    if (decisionTimer2>0)decisionTimer2--;
    if (againstSurface[1]&&decisionTimer==0) {
      decisionTimer=20;
      moveAngle += random(-HALF_PI, HALF_PI);
      faceAngle = moveAngle;
    }    
    float d_ = dist(player1.pos, pos);
    if (health>0) {
      if (d_<100&&decisionTimer==0) {
        moveAngle = angleB;
        faceAngle = moveAngle;
        if (d_<20&&decisionTimer2==0) {
          decisionTimer2=20;
          player1.health = max(0,player1.health-(int)random(8, 20));
          player1.damage=100;
          playHitSound();
        }
      }
    }
    //always update the super
    super.update();
  }
  void animationHandler() {
    //this handler is specific
    //to the zombie spritesheet
    //every unique class will require
    //a different handler to change
    //the animations
    super.animationHandler();
    if (health<=0) {
      if (deathTimer>5) {
        anim.image_x=0;
        anim.image_y=34;
      } else if (deathTimer>0) {
        anim.image_x=17;
        anim.image_y=34;
      } else {
        anim.image_x=34;
        anim.image_y=34;
      }
    } else {
      angleB = atan2(cam1.x-pos.x, cam1.z-pos.z);
      viewAngle = angleB-faceAngle+QUARTER_PI;
      while (viewAngle<0)viewAngle+=TWO_PI;
      while (viewAngle>TWO_PI)viewAngle-=TWO_PI;
      if (viewAngle>0&&viewAngle<=HALF_PI) {
        anim.image_x=0;
        anim.image_y=0;
        if (walkTimer>10&&walkTimer<=21)anim.image_x=17;
        if (walkTimer>31&&walkTimer<=42)anim.image_x=34;
      } else if (viewAngle>HALF_PI&&viewAngle<=PI) {
        anim.image_x=50;
        anim.image_y=0;
        if (walkTimer>10&&walkTimer<=21)anim.image_x=68;
        if (walkTimer>31&&walkTimer<=42)anim.image_x=84;
      } else if (viewAngle>PI&&viewAngle<=PI+HALF_PI) {
        anim.image_x=0;
        anim.image_y=17;
        if (walkTimer>10&&walkTimer<=21)anim.image_x=17;
        if (walkTimer>31&&walkTimer<=42)anim.image_x=34;
      } else if (viewAngle>PI+HALF_PI&&viewAngle<=TWO_PI) {       
        anim.image_x=50;
        anim.image_y=17;
        if (walkTimer>10&&walkTimer<=21)anim.image_x=68;
        if (walkTimer>31&&walkTimer<=42)anim.image_x=84;
      }
    }
  }
}
