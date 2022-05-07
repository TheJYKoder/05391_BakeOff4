import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;
float light = 0; 
float last_light_value = 0;
float proxSensorThreshold = 20; //you will need to change this per your device.
int choose4target = 0;
PImage img;
private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 10; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

void setup() {
  size(720,1080); //you should change this to be fullscreen per your phones screen
  frameRate(60);
  orientation(PORTRAIT);
  
  img = loadImage("hand.png");
  println(img);
  sensor = new KetaiSensor(this);
  sensor.start();
  //println(sensor.list());
  
  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this random generation code!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    //println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

boolean hasStarted = false;
boolean stageOne = true;
boolean correctOne = false;
double lightThresh = 3;

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light);
  background(80); //background is light grey

  countDownTimerWait--;

  if (startTime == 0 && hasStarted)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 2) + " sec per target", width/2, 150);
    return;
  }
  
  int offSetSide = 150;
  int offSetUp = 150;
  int goal = targets.get(trialIndex).target;
  int recShortSide = 50;
  int recLongSide = 150;
  if(stageOne) {
    //Left Side
    fill(180, 180, 180);
    if(goal == 0) {
      fill(0,255,0);
    }
    rect(offSetSide, height/2, recShortSide, recLongSide);
    
    //Up Side
    fill(180, 180, 180);
    if(goal == 1) {
      fill(0,255,0);
    }
    rect(width/2,offSetUp, recLongSide, recShortSide);
    
    //Right Side
    fill(180, 180, 180);
    if(goal == 2) {
      fill(0,255,0);
    }
    rect(width - offSetSide, height/2, recShortSide, recLongSide);
    
    //Down Side
    fill(180, 180, 180);
    if(goal == 3) {
      fill(0,255,0);
    }
    rect(width/2, height-offSetUp, recLongSide, recShortSide);
    fill(255);//white
    text("Trial " + (index+1) + " of " +trialCount, width/2, 300);
  }
  else {
    fill(255);//white
    text("Trial " + (index+1) + " of " +trialCount, width/2, 300);
    textSize(80);
    if (targets.get(index).action==0 && light >= lightThresh)
      image(img, width/2-200, height/2-100, 500, 500);
    else if (targets.get(index).action==1 && light < lightThresh)
      text("OPEN", width/2, 500);
    else
      text("TILT", width/2, 500);
    textSize(40);  
}
}

double xThresh = 5;
double yThresh = 5;
double xFlatThresh = 3;
double yFlatThresh = 3;
boolean selectionActive = false;

void onProximityEvent(float d) {
  light = d;
}

void onAccelerometerEvent(float x, float y, float z)
{
  if(!hasStarted) {
     hasStarted = true; 
  }
  int goal = targets.get(trialIndex).target;
  if(x >= xThresh && !selectionActive && stageOne) {
    selectionActive = true;
    stageOne = false;
    if(goal == 0) {
      correctOne = true;
    }
    else {
      correctOne = false;
    }
    print("CORRECTONE: " + correctOne);
  }
  else if(x <= -xThresh && !selectionActive && stageOne) {
    selectionActive = true;
    stageOne = false;
    if(goal == 2) {
      correctOne = true;
    }
    else {
      correctOne = false;
    }
    print("CORRECTONE: " + correctOne);
  }
  else if(y >= yThresh && !selectionActive && stageOne) {
    selectionActive = true;
    stageOne = false;
    if(goal == 3) {
      correctOne = true;
    }
    else {
      correctOne = false;
    }
    print("CORRECTONE: " + correctOne);
  }
  else if(y <= -yThresh && !selectionActive && stageOne) {
    selectionActive = true;
    stageOne = false;
    if(goal == 1) {
      correctOne = true;
    }
    else {
      correctOne = false;
    }
    print("CORRECTONE: " + correctOne);
  }
  
  if((x >= xThresh || x <= -xThresh || y >= yThresh || y <= -yThresh)  && !selectionActive && !stageOne) {
    //println(light);
    if(light < lightThresh) {
      if(targets.get(trialIndex).action==0 && correctOne) {
        trialIndex++;
        println("CORRECT 2");
      }
      else {
        trialIndex--;
        if(trialIndex < 0) {
          trialIndex = 0;
        }
        println("INCORRECT 2");
      }
    }
    else {
      if(targets.get(trialIndex).action==1 && correctOne) {
        trialIndex++;
        println("CORRECT 2");
      }
      else {
        trialIndex--;
        if(trialIndex < 0) {
          trialIndex = 0;
        }
        println("INCORRECT 2");
      }
    }
    stageOne = true;
    selectionActive = true;
  }
  if((x < xFlatThresh && x > -xFlatThresh && y < yFlatThresh && y > -yFlatThresh) && selectionActive) {
   selectionActive = false; 
  }
}

/*
void onLightEvent(float v) //this just updates the global light value
{
  println(v);
  light = v;
}
*/
