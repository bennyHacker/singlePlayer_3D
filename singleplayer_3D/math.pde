PVector lineCircle(float x1, float y1, float x2, float y2, float cx, float cy, float r) {
  //for purely 2D instances, the 'z' value is
  //used as a boolean (0 = no collision, 1 = collision)
  PVector ret = new PVector();
  if (pointCircle(x1, y1, cx, cy, r))ret = new PVector(x1, y1, 1);
  else if (pointCircle(x2, y2, cx, cy, r))ret = new PVector(x2, y2, 1);
  float distX = x1 - x2;
  float distY = y1 - y2;
  float len = sqrt( (distX*distX) + (distY*distY) );
  float dot = ( ((cx-x1)*(x2-x1)) + ((cy-y1)*(y2-y1)) ) / pow(len, 2);
  float closestX = x1 + (dot * (x2-x1));
  float closestY = y1 + (dot * (y2-y1));
  distX = closestX - cx;
  distY = closestY - cy;
  float distance = sqrt( (distX*distX) + (distY*distY) );
  if (distance <= r && linePoint(x1, y1, x2, y2, closestX, closestY)) ret = new PVector(closestX, closestY, 1);
  return ret;
}
boolean pointCircle(float px, float py, float cx, float cy, float r) {
  float distX = px - cx;
  float distY = py - cy;
  if (sqrt( (distX*distX) + (distY*distY) ) <= r) return true;
  return false;
}
boolean linePoint(float x1, float y1, float x2, float y2, float px, float py) {
  float d1 = dist(px, py, x1, y1);
  float d2 = dist(px, py, x2, y2);
  float lineLen = dist(x1, y1, x2, y2);
  float buffer = 0.1;
  if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) return true;
  return false;
}
PVector lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  PVector ret = new PVector();
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) ret = new PVector(x1 + (uA * (x2-x1)), y1 + (uA * (y2-y1)), 1);
  return ret;
}
// POLYGON/CIRCLE
boolean polyCircle(int[] vertices, float cx, float cy, float r) {
  int next = 0;
  for (int current=0; current<vertices.length; current++) {
    next = current+1;
    if (next == vertices.length) next = 0;
    PVector vc = geometryVectors.get(vertices[current]);    // c for "current"
    PVector vn = geometryVectors.get(vertices[next]);       // n for "next"
    boolean collision = lineCircle2(vc.x, vc.y, vn.x, vn.y, cx, cy, r);
    if (collision) return true;
  }
  return false;
}
boolean polyCircle2(PVector[] vertices, float cx, float cy, float r) {
  int next = 0;
  for (int current=0; current<vertices.length; current++) {
    next = current+1;
    if (next == vertices.length) next = 0;
    PVector vc = (vertices[current]);    // c for "current"
    PVector vn = (vertices[next]);       // n for "next"
    boolean collision = lineCircle2(vc.x, vc.y, vn.x, vn.y, cx, cy, r);
    if (collision) return true;
  }
  return false;
}

// LINE/CIRCLE
boolean lineCircle2(float x1, float y1, float x2, float y2, float cx, float cy, float r) {
  boolean inside1 = pointCircle(x1, y1, cx, cy, r);
  boolean inside2 = pointCircle(x2, y2, cx, cy, r);
  if (inside1 || inside2) return true;
  float distX = x1 - x2;
  float distY = y1 - y2;
  float len = sqrt( (distX*distX) + (distY*distY) );
  float dot = ( ((cx-x1)*(x2-x1)) + ((cy-y1)*(y2-y1)) ) / pow(len, 2);
  float closestX = x1 + (dot * (x2-x1));
  float closestY = y1 + (dot * (y2-y1));
  boolean onSegment = linePoint(x1, y1, x2, y2, closestX, closestY);
  if (!onSegment) return false;
  distX = closestX - cx;
  distY = closestY - cy;
  float distance = sqrt( (distX*distX) + (distY*distY) );
  if (distance <= r)  return true;
  return false;
}
boolean polygonPoint(int[] vertices, float px, float py) {
  boolean collision = false;
  int next = 0;
  for (int current=0; current<vertices.length; current++) {
    next = current+1;
    if (next == vertices.length) next = 0;
    PVector vc = geometryVectors.get(vertices[current]);    // c for "current"
    PVector vn = geometryVectors.get(vertices[next]);       // n for "next"
    if (((vc.z > py && vn.z < py) || (vc.z < py && vn.z > py)) &&
      (px < (vn.x-vc.x)*(py-vc.z) / (vn.z-vc.z)+vc.x)) {
      collision = !collision;
    }
  }
  return collision;
}
boolean polygonPoint2(PVector[] vertices, float px, float py) {
  boolean collision = false;
  int next = 0;
  for (int current=0; current<vertices.length; current++) {
    next = current+1;
    if (next == vertices.length) next = 0;
    PVector vc = (vertices[current]);    // c for "current"
    PVector vn = (vertices[next]);       // n for "next"
    if (((vc.z > py && vn.z < py) || (vc.z < py && vn.z > py)) &&
      px < ((vn.x-vc.x)*(py-vc.z) / (vn.z-vc.z)+vc.x)) {
      collision = !collision;
    }
  }
  return collision;
}
boolean minMax(PVector min1, PVector min2, PVector max1, PVector max2) {
  if ((min2.x<=max1.x&&min1.x<=max2.x)
    &&(min2.y<=max1.y&&min1.y<=max2.y)
    &&(min2.z<=max1.z&&min1.z<=max2.z)) return true;
  return false;
}
float dist(PVector p1, PVector p2) {
  return dist(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
}
PVector intersectPoint(PVector rayVector, PVector rayPoint, PVector planeNormal, PVector planePoint) {
  //this will return a projected point on an infinite plane
  PVector diff = rayPoint.copy().sub(planePoint);
  float prod3 = (diff.x*planeNormal.x+diff.y*planeNormal.y+diff.z*planeNormal.z) / (rayVector.x*planeNormal.x+rayVector.y*planeNormal.y+rayVector.z*planeNormal.z);
  return rayPoint.copy().sub(rayVector.copy().mult((float)prod3));
}
PVector intersectPoint2(Vector3D rayVector, Vector3D rayPoint, Vector3D planeNormal, Vector3D planePoint) {
  //source : https://rosettacode.org/wiki/Find_the_intersection_of_a_line_with_a_plane#
  Vector3D diff = rayPoint.minus(planePoint);
  double prod3 = diff.dot(planeNormal) / rayVector.dot(planeNormal);
  Vector3D r = rayPoint.minus(rayVector.times(prod3));
  return new PVector((float)r.x, (float)r.y, (float)r.z);
}
class Vector3D {
  private double x, y, z;

  Vector3D(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  Vector3D plus(Vector3D v) {
    return new Vector3D(x + v.x, y + v.y, z + v.z);
  }

  Vector3D minus(Vector3D v) {
    return new Vector3D(x - v.x, y - v.y, z - v.z);
  }

  Vector3D times(double s) {
    return new Vector3D(s * x, s * y, s * z);
  }

  double dot(Vector3D v) {
    return x * v.x + y * v.y + z * v.z;
  }

  @Override
    public String toString() {
    return String.format("(%f, %f, %f)", x, y, z);
  }
}
float area3D(PVector a, PVector b, PVector c) {
  //source : https://www.youtube.com/watch?v=PMLWa5JjH70
  //gives us the area of the square
  //formed by AB and AC
  //half of that is the area of the triangle
  return .5*PVector.sub(b, a).cross(PVector.sub(c, a)).mag();
}
