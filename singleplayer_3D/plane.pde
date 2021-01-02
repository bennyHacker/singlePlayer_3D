class plane {
  int[] vecList;
  PVector norm, min, max;
  byte type = 0;
  int texture = 0;
  float area, u1, v1, u2, v2, u3, v3;
  boolean organic = true;
  PShape s;
  int val = -1;
  plane() {
  }
  plane(int[] l) {
    vecList = l;
    calcNorm();
  }
  void calcArea() {
    area = area3D(geometryVectors.get(vecList[0]), geometryVectors.get(vecList[1]), geometryVectors.get(vecList[2]));
  }
  void reset() {
    calcNorm();
    if (organic)makeUV();
    calcArea();
    if (norm.y<-.1)type=0;
    else if (norm.y>.1)type=2;
    else type=1;
  }
  void reset2() {
    //without resetting the UVs
    calcNorm();
    calcArea();
    //calculate the AABB
    min = new PVector(
      min(geometryVectors.get(vecList[2]).x, min(geometryVectors.get(vecList[0]).x, geometryVectors.get(vecList[1]).x))-1.0, 
      min(geometryVectors.get(vecList[2]).y, min(geometryVectors.get(vecList[0]).y, geometryVectors.get(vecList[1]).y))-1.0, 
      min(geometryVectors.get(vecList[2]).z, min(geometryVectors.get(vecList[0]).z, geometryVectors.get(vecList[1]).z))-1.0);
    max = new PVector(
      max(geometryVectors.get(vecList[2]).x, max(geometryVectors.get(vecList[0]).x, geometryVectors.get(vecList[1]).x))+1.0, 
      max(geometryVectors.get(vecList[2]).y, max(geometryVectors.get(vecList[0]).y, geometryVectors.get(vecList[1]).y))+1.0, 
      max(geometryVectors.get(vecList[2]).z, max(geometryVectors.get(vecList[0]).z, geometryVectors.get(vecList[1]).z))+1.0);
  }
  void makeUV() {
    /*this is generally how the UVs are made
    corresponding to allignment with XYZ axis
    for instance, a plane predominantly facing
    the 'Y' axis will be textured according to
    it's X and Z variables (ignoring the 'Y' axis)*/
    PVector n = norm.copy();
    n.x/=1.75;
    n.y*=1.25;
    n.normalize();
    float h_ = abs(n.y);
    float w_ = abs(n.x);
    float d_ = abs(n.z);
    if (h_>d_&&h_>w_) {
      u1 = geometryVectors.get(vecList[0]).x;
      v1 = geometryVectors.get(vecList[0]).z;
      u2 = geometryVectors.get(vecList[1]).x;
      v2 = geometryVectors.get(vecList[1]).z;
      u3 = geometryVectors.get(vecList[2]).x;
      v3 = geometryVectors.get(vecList[2]).z;
    } else if (d_>w_&&d_>h_) {
      if (n.z>0) {
        u1 = geometryVectors.get(vecList[0]).x; 
        v1 = geometryVectors.get(vecList[0]).y;
        u2 = geometryVectors.get(vecList[1]).x; 
        v2 = geometryVectors.get(vecList[1]).y;
        u3 = geometryVectors.get(vecList[2]).x; 
        v3 = geometryVectors.get(vecList[2]).y;
      } else {
        u1 = (levelTextures[texture].width-geometryVectors.get(vecList[0]).x-1); 
        v1 = geometryVectors.get(vecList[0]).y;
        u2 = (levelTextures[texture].width-geometryVectors.get(vecList[1]).x-1); 
        v2 = geometryVectors.get(vecList[1]).y;
        u3 = (levelTextures[texture].width-geometryVectors.get(vecList[2]).x-1); 
        v3 = geometryVectors.get(vecList[2]).y;
      }
    } else {
      if (n.x>0) {
        u1 = (levelTextures[texture].width-geometryVectors.get(vecList[0]).z-1); 
        v1 = geometryVectors.get(vecList[0]).y;
        u2 = (levelTextures[texture].width-geometryVectors.get(vecList[1]).z-1); 
        v2 = geometryVectors.get(vecList[1]).y;
        u3 = (levelTextures[texture].width-geometryVectors.get(vecList[2]).z-1); 
        v3 = geometryVectors.get(vecList[2]).y;
      } else {
        u1 = (geometryVectors.get(vecList[0]).z); 
        v1 = geometryVectors.get(vecList[0]).y;
        u2 = (geometryVectors.get(vecList[1]).z); 
        v2 = geometryVectors.get(vecList[1]).y;
        u3 = (geometryVectors.get(vecList[2]).z); 
        v3 = geometryVectors.get(vecList[2]).y;
      }
    }
  }
  void addShape() {
    //PShape groups are efficient
    //we need 1 PShape group for every texture
    //therefore, the shape list will be the same length as texture list
    //and we addChild based on texture
    PVector n_ = new PVector(abs(norm.x), abs(norm.y), abs(norm.z)).normalize();
    float col = max(0, n_.dot(lightNorm))*255;
    textureMode(IMAGE);
    textureWrap(REPEAT);
    s = createShape();

    s.beginShape();
    s.noStroke();
    s.texture(levelTextures[texture]);
    //s.setTint(color(255,0,0));
    s.vertex(geometryVectors.get(vecList[0]).x, 
      geometryVectors.get(vecList[0]).y, 
      geometryVectors.get(vecList[0]).z, 
      u1, 
      v1);
    s.vertex(geometryVectors.get(vecList[1]).x, 
      geometryVectors.get(vecList[1]).y, 
      geometryVectors.get(vecList[1]).z, 
      u2, 
      v2);
    s.vertex(geometryVectors.get(vecList[2]).x, 
      geometryVectors.get(vecList[2]).y, 
      geometryVectors.get(vecList[2]).z, 
      u3, 
      v3);
    s.endShape(CLOSE);
    s.setTint(color(col));
    levelShapes[texture].addChild(s);
  }
  void calcNorm() {
    //calculate the normal of the plane
    //depending on the value, it will be a wall floor or ceiling
    PVector v1 = geometryVectors.get(vecList[0]).copy().sub(geometryVectors.get(vecList[1]));
    PVector v2 = geometryVectors.get(vecList[0]).copy().sub(geometryVectors.get(vecList[2]));
    norm = v1.cross(v2);
    norm.normalize();
    if (norm.y<-.15)type=0;
    else if (norm.y>.15)type=1;
    else type=2;
  }
  void collision(characterBase thing) {
    //the type is determined by normal

    if (type==2)  wallCollision(thing);
    else topDownCollision(thing);
  }
  void wallCollision(characterBase thing) {
    //project players position on to the wall
    PVector p = intersectPoint2(new Vector3D(-norm.x, -norm.y, -norm.z), new Vector3D(thing.pos.x, thing.pos.y, thing.pos.z), new Vector3D(norm.x, norm.y, norm.z), new Vector3D(geometryVectors.get(vecList[0]).x, geometryVectors.get(vecList[0]).y, geometryVectors.get(vecList[0]).z));
    float area1 = area3D(p, geometryVectors.get(vecList[0]), geometryVectors.get(vecList[1]))+area3D(p, geometryVectors.get(vecList[1]), geometryVectors.get(vecList[2]))+area3D(p, geometryVectors.get(vecList[2]), geometryVectors.get(vecList[0]));
    float r = thing.r+(new PVector(thing.vel.x, thing.vel.z).mag())*max(0, -(new PVector(thing.vel.x, thing.vel.z)).copy().normalize().dot(norm));
    //test if projection rests inside plane triangle
    if (area1/area>.99&&area1/area<1.01) {
      //if so check if player is close enough to collide & do collision
      float d1 = dist(p.x, p.y, p.z, thing.pos.x, thing.pos.y, thing.pos.z);
      float cA = max(0, r-d1);
      float an = atan2(thing.pos.x-p.x, thing.pos.z-p.z);
      thing.pos.x+=sin(an)*cA;
      thing.pos.z+=cos(an)*cA;
      thing.againstSurface[1]=true;
    }
  }
  void topDownCollision(characterBase thing) {
    //check if player's XZ position collides with plane (thus 'top down', or 'birds eye view')
    if (polygonPoint(vecList, thing.pos.x+.001, thing.pos.z+.001)) {
      //the floor may not always be perfectly alligned so we still have to project down in 3D
      PVector intersection = intersectPoint(new PVector(0, 1, 0), thing.pos, norm, geometryVectors.get(vecList[0]));     
      //looks kinda complex but its basically just checking if the y axis collides
      if (thing.pos.y+thing.h/2+max(0, thing.vel.y)+4>intersection.y&&thing.pos.y<intersection.y) {
        //(for the floor)
        //if so we have ourselves a collision and can fix the player's position
        thing.pos.y=(intersection.y-thing.h/2);
        //if player is falling hard, play a landing sound
        if (thing.vel.y>.4&&!step[2].isPlaying()) {
          step[2].rewind();
          step[2].play();
        }
        thing.vel.y=min(0, thing.vel.y);
        //player will move slower on a slope
        thing.slope = abs(norm.y);
        thing.againstSurface[0]=true;
      } else  if (thing.pos.y>intersection.y&&thing.pos.y+min(0, thing.vel.y)-4<intersection.y) {
        //ceiling
        thing.pos.y=intersection.y+thing.h/2;               
        thing.againstSurface[2]=true;
        thing.vel.y=max(0, thing.vel.y);
      }
    }
  }
}
