/*
 -----------------------------------------------
 ! ! ! WARNING ! ! ! WARNING ! ! ! WARNING ! ! !
 -----------------------------------------------
 
 Warning: this program uses "Robot", which locks the mouse in the center of the 
 screen (this enables an 'unlimited free look effect').  If you press 'run' and 
 then click on another window/program, the mouse will be locked in the center 
 of the screen and you may be unable to exit.
 
 Make sure not to click anything after pressing 'run', and remember to use ESC
 to close the program.
 
 ------------------------------------------------
 
 simple 3D game engine by Bennett Hack
 Bennettjhack@outlook.com
 
 this program heavily utilizes qaudtrees,
 AABBs and PShape groups for maximum
 efficiency
 
 the code is meant to be adjustable
 but the mathematics and functions may
 be confusing to navigate
 
 use this code however you like :)
 
 Music by Eric Matyas
 www.soundimage.org
 */
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.awt.*;
import java.awt.event.*;

Robot robot;
Minim minim;

AudioPlayer music;
AudioPlayer[] shoot, hit, death, step;
color back_color = #0B0C1F;
PVector cam1, camNorm1, finalNorm1;
//this will be used to precalculate lighting
PVector lightNorm = new PVector(.25, .5, .45).normalize();
PImage crosshair, gun, healthBar, healthMeter;
PImage[] spriteSheets, levelTextures;
PShape[] levelShapes;
float tw1, camY, swing;
boolean[] controls;
float[] camOptions;
//precalc variables
float w_d, h_d, w_d4, h_d4;
//world gravity
float gravity = .25;
ArrayList<PVector> geometryVectors;
ArrayList<plane> planes;
ArrayList<characterBase> things;
ArrayList<displayable> obj;
ArrayList<projectile> projectiles;
characterBase player1;
int deathTimer1;
boolean canLook = true;
quadTree q;
void setup() {
  fullScreen(OPENGL);
  minim = new Minim(this);
  try { 
    robot = new Robot();
    robot.setAutoDelay(0);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  music = minim.loadFile("morefreakythingsthiswaycomes.mp3");
  shoot = new AudioPlayer[]{
    minim.loadFile("shoot.wav"), 
    minim.loadFile("shoot2.wav"), 
    minim.loadFile("shoot3.wav")
  };
  hit = new AudioPlayer[]{
    minim.loadFile("hit1.wav"), 
    minim.loadFile("hit2.wav")
  };
  death = new AudioPlayer[]{
    minim.loadFile("death.wav"), 
  };
  step = new AudioPlayer[]{
    minim.loadFile("step1.wav"), 
    minim.loadFile("step2.wav"), 
    minim.loadFile("step3.wav"), 
  };
  //precalculate some variables
  h_d=height/2.0;
  w_d=width/2.0;
  h_d4=height/4.0;
  w_d4=width/4.0;
  geometryVectors = new ArrayList<PVector>();
  things = new ArrayList<characterBase>();
  obj = new ArrayList<displayable>();
  planes = new ArrayList<plane>();
  projectiles = new ArrayList<projectile>();
  q = new quadTree(new PVector(0, 0, 0), new PVector(3200, 3200, 3200), 4);
  crosshair = loadImage("crosshair.png");
  gun = loadImage("gun.png");
  healthBar = loadImage("healthBar.png");
  healthMeter = loadImage("healthMeter.png");

  //initiat spriteSheets and textures at the start

  //shapes(planes) and characters have corresponding markers
  //for which spriteSheet/texture they utilize
  spriteSheets = new PImage[]{
    loadImage("employee.png"), loadImage("zombie.png"), 
    loadImage("bullet.png"), 
  };
  levelTextures = new PImage[]{
    loadImage("grass.png"), 
    loadImage("rocks.png"), 
    loadImage("stonefloor.png"), 
    loadImage("woodfloor.png"), 
    loadImage("checker.png"), 
    loadImage("tilefloor.png"), 
    loadImage("tilefloor2.png"), 
    loadImage("checker.png"), 
    loadImage("smoothwall.png"), 
    loadImage("smoothwall2.png"), 
    loadImage("smoothwall3.png"), 
    loadImage("smoothwall4.png"), 
    loadImage("brick.png"), 
    loadImage("fence.png"), 
    loadImage("wood.png"), 
  };
  //there will be a groupShape for each texture
  //for maximum efficiency
  levelShapes = new PShape[levelTextures.length];
  //the resetShapes() function makes a brand new group for every texture
  //running this will delete all geometry (hence 'reset')
  resetShapes();

  //set up the player
  player1 = new characterBase();
  player1.anim = new displayable();
  player1.anim.pos=player1.pos;
  player1.pos.y-=32;
  player1.anim.image_y=34;
  controls = new boolean[14];

  //add the player's animation to the 'obj' array
  //add the player's characterBase (the player itself) to the 'things' array
  things.add(player1);
  obj.add(player1.anim);

  camNorm1 = new PVector(0, 0, -1);
  finalNorm1 = new PVector(0, 0, -1);

  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  camOptions = new float[]{PI/3.0, (float)width/(float)height, cameraZ/220.0, cameraZ*10.0};
  
  //pixelated effect
  ((PGraphicsOpenGL)g).textureSampling(2);
  
  textureWrap(REPEAT);
  frameRate(50);

  //load the level
  load("positions.txt");

  //loop the music
  music.loop();

  //here I add a bunch of zombies
  for (int i = 0; i < 10; i++) {
    zombie th = new zombie();
    th.pos.y-=32;
    th.team=1;
    th.anim = new displayable();
    th.anim.spriteSheet=1;
    th.anim.pos=th.pos;
    obj.add(th.anim);
    things.add(th);
  }

  noCursor();
}
int iter = 0;
void draw() {
  background(0);
  
  //mouse control
  //comment this out to diable robot
  robot();
  
  //located in 'func'
  //runs the bulk of the program
  drawScreens();
  
  //this might be useful in the event of memory issues
  if (frameCount%2500==0) System.gc();
}
