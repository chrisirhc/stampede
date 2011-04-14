#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);

	ofSetFrameRate(30);

	camWidth = 480;
	camHeight = 360;

	// register touch events
	// ofRegisterTouchEvents(this);
  ofxRegisterMultitouch(this);
	
	grabber.initGrabber(camWidth, camHeight);
	// TODO not sure why this gets set of widths and heights
	tex.allocate(grabber.getWidth(), grabber.getHeight(), GL_RGB);
	
	pix = new unsigned char[ (int)( grabber.getWidth() * grabber.getHeight() * 3.0)];

	videoCoordinates = new int[camWidth*camHeight*2];
	int i = 0;
	for (int x = 0; x < camHeight; x++) {
		for (int y = 0; y < camWidth; y++) {
			videoCoordinates[i++] = x;
			videoCoordinates[i++] = y;
		}
	}

	startCoord[0] = 0;
	startCoord[1] = 0;
}

//--------------------------------------------------------------
void testApp::update(){
	ofBackground(255,255,255);		
	
	unsigned char * src = grabber.getPixels();
	
	int totalPix = grabber.getWidth() * grabber.getHeight() * 3;
	
/*
	for(int k = 0; k < totalPix; k+= 3){
		pix[k  ] = 255 - src[k];
		pix[k+1] = 255 - src[k+1];
		pix[k+2] = 255 - src[k+2];		
	}
*/

	int currentIndex;
	int totalPixels = camWidth*camHeight*3;
	int coordinates = camWidth*camHeight*2;
	for (int i = 0, j = 0; i < coordinates; i+=2, j+=3) {
		// TODO Check later and optimize
		currentIndex = 3*(videoCoordinates[i]*camWidth + videoCoordinates[i+1]);
		pix[j]   = src[currentIndex];
		pix[j+1] = src[currentIndex+1];
		pix[j+2] = src[currentIndex+2];
	}

	tex.loadData(pix, grabber.getWidth(), grabber.getHeight(), GL_RGB);
}

//--------------------------------------------------------------
void testApp::draw(){	
	
	ofSetColor(0xFFFFFF);
	tex.draw(0, 0);
	grabber.draw(camWidth, camHeight);
	
	// tex.draw(0, 0, tex.getWidth() / 4, tex.getHeight() / 4);
	ofRect(startCoord[0] + camWidth, startCoord[1] + camHeight, 50, 50);
}

//--------------------------------------------------------------
void testApp::touchDown(int x, int y, int id){
	fingerOrder.push_back(id);
	firstX[id] = x;
	firstY[id] = y;
}

//--------------------------------------------------------------
void testApp::touchMoved(int x, int y, int id){
	int brushSize = 50, fx = firstX[id], fy = firstY[id];
	if(fingerOrder.front() == id) {
		startCoord[0] = x - camWidth;
		startCoord[1] = y - camHeight;
	} else {
		for(int i = 0; i < brushSize; i++) {
			for(int j = 0; j < brushSize; j++) {
				if (((x - fx + j + startCoord[1]) > 0) && ((y - fy + i + startCoord[0]) > 0) &&
						((x + j) < camWidth) && ((y + i) < camHeight) &&
						((x + j - fx + startCoord[1]) < camWidth) && ((y + i - fy + startCoord[0]) < camHeight)) {
					videoCoordinates[2*((y+i)*camWidth + (x+j))+1] = x + j - fx + startCoord[1];
					videoCoordinates[2*((y+i)*camWidth + (x+j))]   = y + i - fy + startCoord[0];
				}
			}
		}
	}
}

//--------------------------------------------------------------
void testApp::touchUp(int x, int y, int id){
	fingerOrder.remove(id);
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(int x, int y, int id){

}
