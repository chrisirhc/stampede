#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxiPhoneVideoGrabber.h"
#include <map>
#include <list>
#include <deque>

#define NUM_FRAMES 50
#define MODE_EDIT 0
#define MODE_FULLSCREEN 1

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
		ofTexture previewTex;
		ofTexture sampTex;
		unsigned char * pix;
		unsigned char * prevPix;

		int camWidth, camHeight;
		int * videoCoordinates;

		int startCoord[2];

		std::map<int, float> firstX;
		std::map<int, float> firstY;
		std::list<int> fingerOrder;

		int brushSize;

		int currentSamplingFrame;
		std::deque<unsigned char*> frameOrder;
		unsigned char * frameTex[NUM_FRAMES];

		GLfloat timelineVertices[NUM_FRAMES * 2][2];

		int viewMode;
};
