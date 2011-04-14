#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxiPhoneVideoGrabber.h"
#include <map>
#include <list>

class testApp : public ofxiPhoneApp{
	
	public:
		
		void setup();
		void update();
		void draw();
		
		void touchDown(int x, int y, int id);
		void touchMoved(int x, int y, int id);
		void touchUp(int x, int y, int id);
		void touchDoubleTap(int x, int y, int id);
		
		ofxiPhoneVideoGrabber grabber;
		ofTexture tex;
		unsigned char * pix;

		int camWidth, camHeight;
		int * videoCoordinates;

		int startCoord[2];

		std::map<int, float> firstX;
		std::map<int, float> firstY;
		std::list<int> fingerOrder;
};
