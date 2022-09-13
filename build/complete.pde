int stageW = 400,
    stageH = 600;
int numAssets         = 25;
int branch            = int(random(4, 20));
String pathAssets     = "../../../assets/";
// String whichAudioFile = "Feel Good Inc.mp3";
String whichAudioFile = "DM2.mp3";

// -------------------------------------- Hype Props ----------------------------------
import hype.*;
import hype.extended.behavior.HOscillator;
import hype.extended.layout.HHexLayout;

// -------- Layout
PVector[]  position = new PVector[numAssets];

// -------------------------------------- Sound Props ---------------------------------
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;

AudioPlayer myAudioPlayer;

AudioInput  myAudioInput;

boolean myAudioToggle = false;                // true = soung, false = mic

FFT     myAudioFFT;

int     myAudioRange  = 16,            // number of audio bins to analyze
        myAudioMax    = 100;                   // max value of audio bins

float   myAudioAmplitude,                      // amplitude of audio bins
        myAudioIndex,                              // index of audio bins
        myAudioIndexAmplitude,
        myAudioIndexStep;

float[] myAudioData   = new float[myAudioRange];  // audio data to analyze
// -------------------------------------- Render Image --------------------------------
boolean     letsRender     = false;                    // RENDER YES OR NO
int         renderModulo   = 120,       // RENDER AN IMAGE ON WHAT TEMPO ?
renderNum      = 0,                                         // FIRST IMAGE
renderMax      = 20;                                    // HOW MANY IMAGES
String      renderPATH     = "../renders_001/";

float direction = noise(TWO_PI),
      size      = random(1,50);

// ------------------------------------------------------------------------------------

color lineColor;

void settings() {
    size(stageW, stageH, P3D);
}

void setup() {
    background(0);

    audioSetup();
    
    noiseDetail(6, 0.7);
    
    surface.setTitle("Listen to Me");
    surface.setFrameRate(100);
    
    for (int i = 0; i < numAssets; ++i) {
        position[i] = new PVector(
            random(width) , 
            random(height));
    }
}

void draw() {
    color randomRed = color(255, int(random(255)), int(random(255)));
    // background(randomRed);

    audioUpdate();    
    result();
}
void result(){
    fade();
    lineColor = color(255, random(255), random(255));
    initDraw();
}

void fade() {
    //--------- Fade
    strokeWeight(0);
    noStroke();
    fill(0, 5);
    rect(0, 0, stageW, stageH);
    //----------------------------------------------------
}
void render() {
    if (letsRender) {
        save(renderPATH + renderNum + ".png");
        renderNum++;
        if (renderNum >=  renderMax) exit();
        }
    }

void initDraw(){
    // We have random points and want to randomize their movement
    startDraw();
}

void startDraw() {
	float timeParam = millis()/100.0;

	for (int i = 0; i < numAssets; ++i) {
		PVector currPoint =  new PVector(position[i].x, position[i].y);
			    size      *= map(myAudioData[13], 0, myAudioAmplitude,0.95, 1);

		if(size < 0.5){
			size = random(10, 60);
			currPoint.x = myAudioData[10] + random(-10, 10);
			currPoint.y = myAudioData[11] + random(-10, 10);
		}

		float x     = cos((direction))/(size+2.5)*10,	
			  y     = sin((direction))/(size+2.5)*10,
			  x_    = map(myAudioData[0],0,myAudioAmplitude, -100, 100),
			  y_    = map(myAudioData[1],0,myAudioAmplitude, -100, 100),
			  angle = atan2(y_-currPoint.y, x_-currPoint.x);
			  
			  direction += (angle-direction)*.05;

		currPoint.x += x;
		currPoint.y += y;

		if (currPoint.x > width) {
			currPoint.x = 0;
		} else if (currPoint.x < 0) {
			currPoint.x = width;
		}
		if (currPoint.y > height) {
			currPoint.y = 0;
		} else if (currPoint.y < 0) {
			currPoint.y = height;
		}

		stroke(lineColor);
		strokeWeight(size);

		rotate(radians(myAudioData[12]));

		line(currPoint.x-x,currPoint.y-y, currPoint.x,currPoint.y);
		position[i] = currPoint;
	}
}
// ------------------------RECTS IN THE VISUALIZER------------------------------------
float visX = 1.0;
float visY = 1.0;
float visW = ((float(stageW)-(visX*2))-(float(myAudioRange)-1)) / float(myAudioRange);
float visH = 2.0;
float visS = (float(stageW)-(visX*2)) / float(myAudioRange);

// ------------------------------------------------------------------------------------

void audioSetup() {
	switch (myAudioRange) {
		case 16 :
			myAudioAmplitude = 40.0;
			myAudioIndex     = 0.2;
			myAudioIndexStep = 0.30;
			break;
		case 32 :
			myAudioAmplitude = 30.0;
			myAudioIndex     = 0.17;
			myAudioIndexStep = 0.225;
			break;
		case 64 :
			myAudioAmplitude = 25.0;
			myAudioIndex     = 0.125;
			myAudioIndexStep = 0.175;
			break;
		case 128 :
			myAudioAmplitude = 30.0;
			myAudioIndex     = 0.075;
			myAudioIndexStep = 0.05;
			break;
		case 256 : default :
			myAudioAmplitude = 20.0;
			myAudioIndex     = 0.05;
			myAudioIndexStep = 0.025;
			break;
	}
	myAudioIndexAmplitude  = myAudioIndex;

	minim = new Minim(this);

	if (myAudioToggle) {
		myAudioPlayer = minim.loadFile(pathAssets + whichAudioFile);
		myAudioPlayer.loop();
		// myAudioPlayer.mute();
		myAudioFFT = new FFT(myAudioPlayer.bufferSize(), myAudioPlayer.sampleRate());
		myAudioFFT.linAverages(myAudioRange);
		myAudioFFT.window(FFT.GAUSS);
	} else {
		myAudioInput = minim.getLineIn(Minim.MONO);
		myAudioFFT = new FFT(myAudioInput.bufferSize(), myAudioInput.sampleRate());
		myAudioFFT.linAverages(myAudioRange);
		myAudioFFT.window(FFT.NONE);
	}

}

// ------------------------------------------------------------------------------------

void audioUpdate() {
	hint(DISABLE_DEPTH_TEST);
	noLights();
	perspective(PI/3.0, (float)(width*2)/(height*2), 0.1, 1000000);

	if (myAudioToggle) myAudioFFT.forward(myAudioPlayer.mix);
	else               myAudioFFT.forward(myAudioInput.mix);

	for (int i = 0; i < myAudioRange; ++i) {
		strokeWeight(0);
		noStroke();

		float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmplitude) * myAudioIndexAmplitude;
		myAudioIndexAmplitude+=myAudioIndexStep;
		float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
		myAudioData[i]     = tempIndexCon; // RECODE THE NUMBERS FROM - 0 TO 100

	}
	myAudioIndexAmplitude = myAudioIndex;
	hint(ENABLE_DEPTH_TEST);
}

// ------------------------------------------------------------------------------------

void stop() {
	if (myAudioToggle) myAudioPlayer.close();
	else               myAudioInput.close();
	minim.stop();  
	super.stop();
}

// ------------------------------------------------------------------------------------