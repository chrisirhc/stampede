#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);

	ofSetFrameRate(30);

	camWidth = 480;
	camHeight = 360;

	brushSize = 50;

	// register touch events
	// ofRegisterTouchEvents(this);
  ofxRegisterMultitouch(this);
	
	grabber.initGrabber(camWidth, camHeight);
	// TODO not sure why this gets set of widths and heights
	tex.allocate(grabber.getWidth(), grabber.getHeight(), GL_RGB);
	previewTex.allocate(brushSize, brushSize, GL_RGB);
	
	pix = new unsigned char[ (int)( grabber.getWidth() * grabber.getHeight() * 3.0)];
	prevPix = new unsigned char[ (int)( brushSize * brushSize * 3.0)];

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
	ofBackground(0,0,0);
	
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

	/** Generate preview texture for sampling area **/
	for(int i = 0, k = 0; i < brushSize; i++) {
		for(int j = 0; j < brushSize; j++, k+=3) {
			if (((startCoord[0] + i) < camWidth) && ((startCoord[1] + j) < camHeight)) {
				currentIndex = 3*((startCoord[1]+i)*camWidth + startCoord[0]+j);
				prevPix[k]   = src[currentIndex];
				prevPix[k+1] = src[currentIndex+1];
				prevPix[k+2] = src[currentIndex+2];
			}
		}
	}

	/**  Load preview texture into the texture **/
	previewTex.loadData(prevPix, brushSize, brushSize, GL_RGB);

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
  ofScale(1.0, 1.0, 1.0);
	
	ofSetColor(0xFFFFFF);
	tex.draw(camWidth + 64, camHeight);
	grabber.draw(0, camHeight);

	previewTex.draw(camWidth / 2, 0.5 * camHeight);
	
	// If it's not in the eraser mode, then draw a nice rectangle of the sampling area
	if (startCoord[0] != -1) {
		ofEnableAlphaBlending();
		ofNoFill();
		ofSetColor(255, 255, 255, 100);
		ofRect(startCoord[0], startCoord[1] + camHeight, 50, 50);
		ofSetColor(0, 0, 0, 100);
		ofRect(startCoord[0] - 1, startCoord[1] + camHeight - 1, 52, 52);
		ofDisableAlphaBlending();
	}
}

#define WITHINSAMPLEREGION(x, y) (((x) < camWidth) && ((y) > camHeight))
#define WITHINAPPLYREGION(x, y) (((x) > camWidth + 64) && ((y) > camHeight))
// #define CONVERT_FROM_APPLY(x, y) (

//--------------------------------------------------------------
void testApp::touchDown(int x, int y, int id){
	fingerOrder.push_back(id);
	if(WITHINSAMPLEREGION(x, y)) {
		// Within the sampling region

		startCoord[0] = x;
		startCoord[1] = y - camHeight;
	} else if (WITHINAPPLYREGION(x, y)) {
		// Within the applying region

		// Convert them back
		x -= camWidth + 64;
		y -= camHeight;
		firstX[id] = x;
		firstY[id] = y;

		for(int i = 0; i < brushSize; i++) {
			for(int j = 0; j < brushSize; j++) {
				if (((j + startCoord[0]) >= 0) &&
						((i + startCoord[1]) >= 0) &&
						((x + j) < camWidth) && ((y + i) < camHeight) &&
						((j + startCoord[0]) < camWidth) &&
						((i + startCoord[1]) < camHeight)) {
					videoCoordinates[2*((y+i)*camWidth + (x+j))+1] = j + startCoord[0];
					videoCoordinates[2*((y+i)*camWidth + (x+j))]   = i + startCoord[1];
				}
			}
		}
	}
}

//--------------------------------------------------------------
void testApp::touchMoved(int x, int y, int id){
	int fx = firstX[id], fy = firstY[id];
	if(WITHINSAMPLEREGION(x, y)) {
		// Within the sampling region

		startCoord[0] = x;
		startCoord[1] = y - camHeight;
	} else if (WITHINAPPLYREGION(x, y)) {
		x -= camWidth + 64;
		y -= camHeight;

		for(int i = 0; i < brushSize; i++) {
			for(int j = 0; j < brushSize; j++) {
				if (((x - fx + j + startCoord[0]) >= 0) &&
						((y - fy + i + startCoord[1]) >= 0) &&
						((x + j) < camWidth) && ((y + i) < camHeight) &&
						((x + j - fx + startCoord[0]) < camWidth) &&
						((y + i - fy + startCoord[1]) < camHeight)) {
					videoCoordinates[2*((y+i)*camWidth + (x+j))+1] = x + j - fx + startCoord[0];
					videoCoordinates[2*((y+i)*camWidth + (x+j))]   = y + i - fy + startCoord[1];
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
