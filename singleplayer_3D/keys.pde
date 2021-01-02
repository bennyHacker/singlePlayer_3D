void keyPressed() {
  if (key=='a'||key=='A') controls[0]=true;
  if (key=='w'||key=='W') controls[1]=true;  
  if (key=='s'||key=='S') controls[2]=true; 
  if (key=='d'||key=='D') controls[3]=true;
  if(key==' ')controls[4]=true;
}
void keyReleased() {
  if (key=='a'||key=='A') controls[0]=false;
  if (key=='w'||key=='W') controls[1]=false;  
  if (key=='s'||key=='S') controls[2]=false; 
  if (key=='d'||key=='D') controls[3]=false;
  if(key==' ')controls[4]=false;
}
