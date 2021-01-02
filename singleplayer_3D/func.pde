void drawScreens() {
  //player shoot
  if (mousePressed&&mouseButton==LEFT) {
    if (player1.shootTimer==0) {
      projectile proj = new projectile();
      proj.team = player1.team;
      proj.pos = new PVector(player1.pos.x, player1.pos.y-3, player1.pos.z);
      proj.vel = ((camNorm1.copy().add(PVector.random3D().mult(.01))).normalize()).mult(32.0);
      proj.vel.add(player1.vel);
      proj.setMinMax();
      proj.damage=10;
      player1.shootTimer=min(5, (int)(frameRate/5)); //roughly 10 per second
      playShootSound();
      obj.add(proj);
      projectiles.add(proj);
    }
  }
  //if dead, switch to different cam
  if (deathTimer1>0) cam1 = new PVector(player1.pos.x-finalNorm1.x*4.0, player1.pos.y-12.0, player1.pos.z-finalNorm1.z*4.0);
  else cam1 = new PVector(player1.pos.x, player1.pos.y-5, player1.pos.z);
  camera(cam1.x, cam1.y, cam1.z, cam1.x+finalNorm1.x, cam1.y+finalNorm1.y, cam1.z+finalNorm1.z, 0, 1, 0);
  perspective(camOptions[0], camOptions[1], camOptions[2], camOptions[3]);
  background(back_color);
  noStroke();
  //if the player is dead
  if (deathTimer1>0) {
    player1.speed=0;
    deathTimer1--;
    if (deathTimer1==0) {
      player1.health=player1.maxHealth;
      player1.pos=player1.spawnPos.copy();
      player1.anim.pos=player1.pos;
    }
  }
  //footstep sounds
  if (player1.walkTimer>0) {
    if (player1.walkTimer==1||
      player1.walkTimer==15||
      player1.walkTimer==29)playWalkSound();
  }
  //health regeneration
  if (player1.damage>0)player1.damage--;
  else if (player1.health<player1.maxHealth&&deathTimer1==0)player1.health++;
  //create new quadTree;
  q = new quadTree(new PVector(0, 0, 0), new PVector(1600, 1600, 1600), 0);
  //create new array for holding collisions
  //update characters and test projectile collisions
  for (int i = 0; i < things.size(); things.get(i++).update()) {
    things.get(i).val=i;
    q.myThings.add(things.get(i));
  }
  cameraFunc();
  //update and remove objects
  //do collision for player and world
  //update planes and test collision with projectiles
  for (int i = 0; i < projectiles.size(); i++) {
    projectiles.get(i).val=i;
    if (projectiles.get(i).remove) {
      projectiles.remove(projectiles.get(i)) ;
      i--;
    } else {
      q.myProj.add(projectiles.get(i));
    }
  }
  for (int i = 0; i < planes.size(); i++) {
    planes.get(i).val=i;
    q.myPlanes.add(planes.get(i));
  }  
  //update the quadTree
  q.update();
  //update objects (doing this before updating 
  //quadTree causes issues with projectiles)
  for (int i = 0; i < obj.size(); obj.get(i++).update()) {
    if (obj.get(i).remove) {
      obj.remove(obj.get(i)) ;
      i--;
    }
  } 
  //player jump function
  if (controls[4]&&player1.againstSurface[0]) {
    controls[4]=false;
    player1.againstSurface[0]=false;
    player1.pos.y-=4;
    player1.vel.y=-2.5;
  }
  //after all is said and done, finally handle the projectile collisions
  for (int j = 0; j < projectiles.size(); j++) {
    //"considered" projectiles are those which have collided
    if (projectiles.get(j).coll.consider) {
      if (projectiles.get(j).coll.type==0) {
        //remove target health amongst other things
        things.get(projectiles.get(j).coll.arPoint).health-=projectiles.get(j).damage;
        things.get(projectiles.get(j).coll.arPoint).vel.add(projectiles.get(j).vel.div(50.0));
        if (things.get(projectiles.get(j).coll.arPoint).health<=0) {
          if (things.get(projectiles.get(j).coll.arPoint)==player1) deathTimer1=250;
          things.get(projectiles.get(j).coll.arPoint).health=0;
          things.get(projectiles.get(j).coll.arPoint).speed=0;
          //play death sound
          death[0].rewind();
          death[0].play();
        }
        playHitSound();
      }
      //this will tell other arrays to remove this item
      projectiles.get(j).remove=true;
    }
  }
  //for physical weapons
  swing*=.825;


  //display shapes and players
  for (int i = 0; i < levelShapes.length; i++) {
    shape(levelShapes[i]);
  }
  for (int i = 0; i < obj.size(); i++) {
    if (obj.get(i)!=player1.anim)obj.get(i).display1();
    else if (deathTimer1>0)obj.get(i).display1();
  }
  //HUD
  camera();
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_DEPTH_SORT);
  pushMatrix();
  translate(width/2.0+gun.width*2.0-swing*128, height-swing*64);
  rotateY(-HALF_PI);
  rotate(-swing*.5);
  translate(-gun.width*5+player1.shootTimer*48, -gun.height*2.5+player1.shootTimer*24);
  if (deathTimer1==0)image(gun, 0, 0, gun.width*5, gun.height*5);
  popMatrix();
  image(healthBar, w_d-192, 30, 384, 96);
  float x = player1.health*3.6;
  image(healthMeter, w_d-x/2.0, 51, x, 56);
  fill(255);
  text(frameRate, 50, 50);
  if (deathTimer1==0) image(crosshair, w_d-16, h_d-8, 24, 32);
  hint(ENABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_SORT);
}
void robot() {
  //this is what enables 'unlimited' mouse freedom
  Point p = getGlobalMouseLocation();
  int x_ = (int)p.getX(); 
  int y_ = (int)p.getY();
  robot.mouseMove(width/2, height/2);
  p = getGlobalMouseLocation();
  int x2_ = (int)p.getX(); 
  int y2_ = (int)p.getY();
  tw1+=(x2_-x_)/300.0;
  camY-=(y2_-y_)/350.0;
  camY = min(.9997, max(-.9997, camY));
  tw1 = min(.45, max(-.45, tw1));
}
void mousePressed() {
  //mellee
  //shoots a projectile
  //with very short lifespan
  if (mouseButton==RIGHT) {
    swing=PI*1.1;
    projectile proj = new projectile();
    proj.team = player1.team;
    proj.pos = new PVector(player1.pos.x, player1.pos.y-3, player1.pos.z);
    proj.vel = ((camNorm1.copy().add(PVector.random3D().mult(.01))).normalize()).mult(10.0);
    proj.setMinMax();
    proj.damage=50;
    proj.lifeSpan=2;
    proj.display=false;
    obj.add(proj);
    projectiles.add(proj);
  }
}
Point getGlobalMouseLocation() {
  // java.awt.MouseInfo
  PointerInfo pointerInfo = MouseInfo.getPointerInfo();
  Point p = pointerInfo.getLocation();
  return p;
}

void cameraFunc() {
  //basic controls
  boolean moving1 = controls[1]||controls[2]||controls[0]||controls[3];
  player1.faceAngle+=tw1;
  if (moving1)player1.moveAngle=player1.faceAngle;
  if (controls[1]) {
    if (controls[0]) {
      player1.moveAngle+=QUARTER_PI;
    } else if (controls[3]) {
      player1.moveAngle-=QUARTER_PI;
    }
  } else if (controls[2]) {
    player1.moveAngle+=PI;
    if (controls[0]) {
      player1.moveAngle-=QUARTER_PI;
    } else if (controls[3]) {
      player1.moveAngle+=QUARTER_PI;
    }
  } else if (controls[0]) {
    player1.moveAngle+=HALF_PI;
  } else if (controls[3]) {
    player1.moveAngle-=HALF_PI;
  }
  if (moving1) {
    player1.speed+=(player1.moveSpeed-player1.speed)/10.0;
  } else {
    player1.speed*=.8;
  }
  tw1*=.4;
  //check if a wall/floor is blocking vision between players
  //change camera based on auto aim
  float y_ = 1-abs(camY);
  camNorm1 = new PVector(sin(player1.faceAngle)*y_, camY, cos(player1.faceAngle)*y_);
  finalNorm1 = new PVector(finalNorm1.x*.2+camNorm1.x*.8, finalNorm1.y*.5+camNorm1.y*.5, finalNorm1.z*.2+camNorm1.z*.8);
}
void resetShapes() {
  for (int i = 0; i < levelShapes.length; i++) {
    levelShapes[i]=createShape(GROUP);
  }
}
void resetVectors() {
  ArrayList<PVector> uniqueVectors = new ArrayList<PVector>();
  for (int i = 0; i < planes.size(); i++) {
    if (!uniqueVectors.contains(geometryVectors.get(planes.get(i).vecList[0]))) {
      uniqueVectors.add(geometryVectors.get(planes.get(i).vecList[0]));
      planes.get(i).vecList[0]=uniqueVectors.size()-1;
    } else {
      planes.get(i).vecList[0]=uniqueVectors.indexOf(geometryVectors.get(planes.get(i).vecList[0]));
    }
    if (!uniqueVectors.contains(geometryVectors.get(planes.get(i).vecList[1]))) {
      uniqueVectors.add(geometryVectors.get(planes.get(i).vecList[1]));
      planes.get(i).vecList[1]=uniqueVectors.size()-1;
    } else {
      planes.get(i).vecList[1]=uniqueVectors.indexOf(geometryVectors.get(planes.get(i).vecList[1]));
    }
    if (!uniqueVectors.contains(geometryVectors.get(planes.get(i).vecList[2]))) {
      uniqueVectors.add(geometryVectors.get(planes.get(i).vecList[2]));
      planes.get(i).vecList[2]=uniqueVectors.size()-1;
    } else {
      planes.get(i).vecList[2]=uniqueVectors.indexOf(geometryVectors.get(planes.get(i).vecList[2]));
    }
  }
  geometryVectors = new ArrayList<PVector>();
  for (int i = 0; i < uniqueVectors.size(); i++) {
    geometryVectors.add(new PVector(uniqueVectors.get(i).x, uniqueVectors.get(i).y, uniqueVectors.get(i).z));
  }
}
void playWalkSound() {
  int r = (int)random(2);
  if (!step[r].isPlaying()) {
    step[r].rewind();
    step[r].play();
  }
}
void playShootSound() {
  int r = (int)random(3);
  shoot[r].rewind();
  shoot[r].play();
}
void playHitSound() {
  int r = (int)random(2);
  hit[r].rewind();
  hit[r].play();
}
void load(String source) {
  //import
  String[] str = loadStrings(source);
  String[] pos = str[0].split(",");
  player1.spawnPos = new PVector(float(pos[0]), float(pos[1]), float(pos[2]));
  player1.anim.pos=player1.pos;
  for (int i = 1; i < str.length; i++) {
    String[] str2 = str[i].split(",");
    if (str2[0].equals("p")) {
      PVector p1 = new PVector(float(str2[2]), float(str2[3])*2.0, float(str2[4]));
      PVector p2 = new PVector(float(str2[5]), float(str2[6])*2.0, float(str2[7]));
      PVector p3 = new PVector(float(str2[8]), float(str2[9])*2.0, float(str2[10]));
      geometryVectors.add(p1);
      geometryVectors.add(p2);
      geometryVectors.add(p3);
      plane p = new plane(new int[]{geometryVectors.size()-3, geometryVectors.size()-2, geometryVectors.size()-1});
      p.u1 = float(str2[11]);
      p.v1 = float(str2[12]);
      p.u2 = float(str2[13]);
      p.v2 = float(str2[14]);
      p.u3 = float(str2[15]);
      p.v3 = float(str2[16]);
      p.texture = int(str2[1]);
      p.organic=false;
      planes.add(p);
    }
  }
  resetVectors();
  resetShapes();
  for (int i = 0; i < planes.size(); i++) {
    planes.get(i).reset2();
    planes.get(i).addShape();
  }
}
boolean hasVector(ArrayList<PVector> arr, PVector p) {
  //I don't trust contains() for some reason
  for (int i = 0; i < arr.size(); i++) {
    if (arr.get(i).x==p.x&&
      arr.get(i).y==p.y&&
      arr.get(i).z==p.z)return true;
  }
  return false;
}
