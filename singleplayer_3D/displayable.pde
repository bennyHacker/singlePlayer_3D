class displayable {
  //basic class for basic objects
  //such as player/projectile sprite, could 
  //also be used for decorations
  
  //can be an indipendant position, but the
  //position is usually set to the character's position
  //(this.pos = character.pos)
  PVector pos;
  float image_x, image_y, image_w, image_h;
  //corresponding to spriteSheet array
  int spriteSheet = 0;
  //disable if you need it to stop displaying for whatever reason
  boolean display = true;
  //ensures that all arrays containing this object remove it when necessary
  boolean remove = false;
  //distance from the player
  float dist1 = 0;
  //angle from the camera
  float angle1 = 0;
  //if disabled, will not rotate to face camera
  boolean faceCamera = true;
  displayable() {
    // deafult for 16x16 images
    image_w = 16;
    image_h = 16;
    pos = new PVector(0, -8, 0);
  }
  displayable copy() {
    return new displayable();
  }
  void reset() {
  }
  void display1() {
    dist1 = dist(player1.pos.x, player1.pos.z, pos.x, pos.z);
    //render distance
    if (display&&dist1<1500) {
      fill(255);
      noStroke();
      pushMatrix();
      translate(pos.x, pos.y, pos.z);
      rotateY(angle1);
      beginShape();
      texture(spriteSheets[spriteSheet]);
      vertex(-image_w/2, -image_h/2*2.0, image_x, image_y);
      vertex(image_w/2, -image_h/2*2.0, image_x+image_w, image_y);
      vertex(image_w/2, image_h/2*2.0, image_x+image_w, image_y+image_h);
      vertex(-image_w/2, image_h/2*2.0, image_x, image_y+image_h);
      endShape(CLOSE);
      popMatrix();
    }
  }
  void update() {
    //for other classes
    if (faceCamera) {
      angle1 = atan2(-camNorm1.x, -camNorm1.z);
    }
  }
}
