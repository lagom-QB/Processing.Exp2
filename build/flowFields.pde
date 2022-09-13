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
		// 0,1,10,11,12,13 <- important myAudioData Ranges
		// println(myAudioData[0],myAudioData[1],myAudioData[2],myAudioData[3],myAudioData[4],myAudioData[5],myAudioData[6], myAudioData[7],myAudioData[8],myAudioData[9],myAudioData[10],myAudioData[11],myAudioData[12],myAudioData[13],myAudioData[14],myAudioData[15]);

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