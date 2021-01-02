class quadTree {
  //quadTree takes all objects and
  //tries to reduce unnessicary collisions 
  //(it really works!)
  
  //the position, and dimentions
  //should encompass the whole map
  //(the position is the center)
  PVector pos, dim, min, max;
  int order = 0;
  ArrayList<characterBase> myThings;
  ArrayList<projectile> myProj;
  ArrayList<plane> myPlanes;
  ArrayList<PVector> alreadys;
  quadTree(PVector P, PVector D, int O) {
    pos = P;
    dim = D;
    order = O;
    myThings = new ArrayList<characterBase>();
    myProj = new ArrayList<projectile>();
    myPlanes = new ArrayList<plane>();
    min = new PVector(pos.x-dim.x/2.0, pos.y-dim.y/2.0, pos.z-dim.z/2.0);
    max = new PVector(pos.x+dim.x/2.0, pos.y+dim.y/2.0, pos.z+dim.z/2.0);
    alreadys = new ArrayList<PVector>();
  }
  quadTree(PVector P, PVector D, int O, ArrayList<PVector> a) {
    pos = P;
    dim = D;
    order = O;
    myThings = new ArrayList<characterBase>();
    myProj = new ArrayList<projectile>();
    myPlanes = new ArrayList<plane>();
    min = new PVector(pos.x-dim.x/2.0, pos.y-dim.y/2.0, pos.z-dim.z/2.0);
    max = new PVector(pos.x+dim.x/2.0, pos.y+dim.y/2.0, pos.z+dim.z/2.0);
    alreadys = a;
  }
  void update() {
    //here I make the # of iterations 8
    //but you should test other numbers
    //and use the most efficient amount
    if (order<8) {
      //create four new nodes, each 1/4 the size of this node
      PVector newDim = dim.copy().div(2.0);
      newDim.y=dim.y;
      PVector p1 = new PVector(pos.x-newDim.x/2.0, pos.y, pos.z-newDim.z/2.0);
      PVector p2 = new PVector(pos.x+newDim.x/2.0, pos.y, pos.z-newDim.z/2.0);
      PVector p3 = new PVector(pos.x+newDim.x/2.0, pos.y, pos.z+newDim.z/2.0);
      PVector p4 = new PVector(pos.x-newDim.x/2.0, pos.y, pos.z+newDim.z/2.0);
      quadTree t1 = new quadTree(p1, newDim, order+1, alreadys);
      quadTree t2 = new quadTree(p2, newDim, order+1, alreadys);
      quadTree t3 = new quadTree(p3, newDim, order+1, alreadys);
      quadTree t4 = new quadTree(p4, newDim, order+1, alreadys);
      //check for minmax collisions
      for (int i = 0; i < myPlanes.size(); i++) {
        if (minMax(myPlanes.get(i).min, t1.min, myPlanes.get(i).max, t1.max))t1.myPlanes.add(myPlanes.get(i));
        if (minMax(myPlanes.get(i).min, t2.min, myPlanes.get(i).max, t2.max))t2.myPlanes.add(myPlanes.get(i));
        if (minMax(myPlanes.get(i).min, t3.min, myPlanes.get(i).max, t3.max))t3.myPlanes.add(myPlanes.get(i));
        if (minMax(myPlanes.get(i).min, t4.min, myPlanes.get(i).max, t4.max))t4.myPlanes.add(myPlanes.get(i));
      }
      for (int i = 0; i < myThings.size(); i++) {
        if (minMax(myThings.get(i).min, t1.min, myThings.get(i).max, t1.max))t1.myThings.add(myThings.get(i));
        if (minMax(myThings.get(i).min, t2.min, myThings.get(i).max, t2.max))t2.myThings.add(myThings.get(i));
        if (minMax(myThings.get(i).min, t3.min, myThings.get(i).max, t3.max))t3.myThings.add(myThings.get(i));
        if (minMax(myThings.get(i).min, t4.min, myThings.get(i).max, t4.max))t4.myThings.add(myThings.get(i));
      }
      for (int i = 0; i < myProj.size(); i++) {
        if (minMax(myProj.get(i).min, t1.min, myProj.get(i).max, t1.max))t1.myProj.add(myProj.get(i));
        if (minMax(myProj.get(i).min, t2.min, myProj.get(i).max, t2.max))t2.myProj.add(myProj.get(i));
        if (minMax(myProj.get(i).min, t3.min, myProj.get(i).max, t3.max))t3.myProj.add(myProj.get(i));
        if (minMax(myProj.get(i).min, t4.min, myProj.get(i).max, t4.max))t4.myProj.add(myProj.get(i));
      }
      //check if each node has enough data to be updated
      byte b1 = 0;
      byte b2 = 0;
      byte b3 = 0;
      byte b4 = 0;
      b1+=t1.myThings.size();
      if (t1.myPlanes.size()>0)b1++;
      if (t1.myProj.size()>0)b1++;
      b2+=t2.myThings.size();
      if (t2.myPlanes.size()>0)b2++;
      if (t2.myProj.size()>0)b2++;
      b3+=t3.myThings.size();
      if (t3.myPlanes.size()>0)b3++;
      if (t3.myProj.size()>0)b3++;
      b4+=t4.myThings.size();
      if (t4.myPlanes.size()>0)b4++;
      if (t4.myProj.size()>0)b4++;
      if (b1>1)t1.update();
      if (b2>1)t2.update();
      if (b3>1)t3.update();
      if (b4>1)t4.update();
    } else {
      //once maximim nodes have been made
      //check for actual collisions
      for (int i = 0; i < myThings.size(); i++) {
        for (int j = 0; j < myThings.size(); j++) {
          //collide characters agianst other characters
          if (myThings.get(i).val!=myThings.get(j).val) {
            myThings.get(i).collide(myThings.get(j));
          }
        }
        for (int j = 0; j < myProj.size(); j++) {
          PVector a_ = new PVector(myThings.get(i).val, -1, myProj.get(j).val);
          if (!hasVector(alreadys, a_)) {
            alreadys.add(a_);
            if (myThings.get(i).team!=myProj.get(j).team&&myThings.get(i).health>0) {
              if (minMax(myProj.get(j).min, myThings.get(i).min, myProj.get(j).max, myThings.get(i).max)) {
                PVector collision = lineCircle(myProj.get(j).pos.x, myProj.get(j).pos.z, myProj.get(j).pos.x+myProj.get(j).vel.x, myProj.get(j).pos.z+myProj.get(j).vel.z, myThings.get(i).pos.x, myThings.get(i).pos.z, myThings.get(i).r);
                collision = new PVector(collision.x, collision.z, collision.y);
                if (collision.y==1) {
                  if (myProj.get(j).pos.y>myThings.get(i).pos.y-myThings.get(i).h/2&&myProj.get(j).pos.y<myThings.get(i).pos.y+myThings.get(i).h/2) {        
                    float dist = dist(collision, new PVector(myProj.get(j).pos.x, 0, myProj.get(j).pos.z));
                    if (dist<myProj.get(j).coll.dist) {
                      myProj.get(j).coll.dist = dist;
                      myProj.get(j).coll.type = 0;
                      myProj.get(j).coll.arPoint = myThings.get(i).val;
                      myProj.get(j).coll.consider = true;
                    }
                  }
                }
              }
            }
          }
        }
      }
      for (int i = 0; i < myPlanes.size(); i++) {
        for (int j = 0; j < myThings.size(); j++) {
          PVector a_ = new PVector(myThings.get(j).val, myPlanes.get(i).val, -1);
          if (!hasVector(alreadys, a_)) {
            alreadys.add(a_);
            if (minMax(myThings.get(j).min, myPlanes.get(i).min, myThings.get(j).max, myPlanes.get(i).max)) myPlanes.get(i).collision(myThings.get(j));
          }
        }
        for (int j = 0; j < myProj.size(); j++) {
          PVector a_ = new PVector(-1, myPlanes.get(i).val, myProj.get(j).val);
          if (!hasVector(alreadys, a_)) {
            alreadys.add(a_);
            if (minMax(myProj.get(j).min, myPlanes.get(i).min, myProj.get(j).max, myPlanes.get(i).max)) {
              PVector collision = intersectPoint(myProj.get(j).vel.copy(), myProj.get(j).pos, myPlanes.get(i).norm, geometryVectors.get(myPlanes.get(i).vecList[0]));
              float dist = dist(collision, myProj.get(j).pos);
              if (dist(collision, myProj.get(j).pos.copy().add(myProj.get(j).vel))+dist<=myProj.get(j).vel.mag()+.01) {
                collision = new PVector(area3D(collision, geometryVectors.get(myPlanes.get(i).vecList[0]), geometryVectors.get(myPlanes.get(i).vecList[1]))
                  , area3D(collision, geometryVectors.get(myPlanes.get(i).vecList[1]), geometryVectors.get(myPlanes.get(i).vecList[2]))
                  , area3D(collision, geometryVectors.get(myPlanes.get(i).vecList[2]), geometryVectors.get(myPlanes.get(i).vecList[0])));
                float area1 = collision.x+collision.y+collision.z;
                if (area1/myPlanes.get(i).area>.99&&area1/myPlanes.get(i).area<=1.01) {
                  if (dist<myProj.get(j).vel.mag()) {
                    if (dist<myProj.get(j).coll.dist) {
                      myProj.get(j).coll.dist = dist;
                      myProj.get(j).coll.type = 1;
                      myProj.get(j).coll.arPoint = i;
                      myProj.get(j).coll.consider = true;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
