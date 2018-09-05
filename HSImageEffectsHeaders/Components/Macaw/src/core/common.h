/********************************************************************
 * (C) Copyright 2013 by Autodesk, Inc. All Rights Reserved. By using
 * this code,  you  are  agreeing  to the terms and conditions of the
 * License  Agreement  included  in  the documentation for this code.
 * AUTODESK  MAKES  NO  WARRANTIES,  EXPRESS  OR  IMPLIED,  AS TO THE
 * CORRECTNESS OF THIS CODE OR ANY DERIVATIVE WORKS WHICH INCORPORATE
 * IT.  AUTODESK PROVIDES THE CODE ON AN 'AS-IS' BASIS AND EXPLICITLY
 * DISCLAIMS  ANY  LIABILITY,  INCLUDING CONSEQUENTIAL AND INCIDENTAL
 * DAMAGES  FOR ERRORS, OMISSIONS, AND  OTHER  PROBLEMS IN THE  CODE.
 *
 * Use, duplication,  or disclosure by the U.S. Government is subject
 * to  restrictions  set forth  in FAR 52.227-19 (Commercial Computer
 * Software Restricted Rights) as well as DFAR 252.227-7013(c)(1)(ii)
 * (Rights  in Technical Data and Computer Software),  as applicable.
 *******************************************************************/

#ifndef _COMMON_H_
#define _COMMON_H_

#include <string>
#include <vector>
#include <map>

//#include <android/log.h>

using namespace std;

#define NODEBUG
#define TAG "Macaw"
//#define log(...) __android_log_print(ANDROID_LOG_VERBOSE, TAG, __VA_ARGS__)
//#define printf(...) __android_log_print(ANDROID_LOG_VERBOSE, TAG, __VA_ARGS__)

#ifdef NODEBUG
#define printf(...)
#endif

namespace macaw {
    
struct Renderbuffer {
    Renderbuffer(int i = 0, int w = 1, int h = 1) {
        id = i;
        width = w;
        height = h;
    };
    void setDefaults() {
        id = 0;
        width = 1;
        height = 1;
    }
    void set(int i, int w, int h) {
        id = i;
        width = w;
        height = h;
    }
    
    int id;
    int width;
    int height;
};


struct Texture {
	Texture(int i = 0, int w = 1, int h = 1) {
		id = i;
		width = w;
		height = h;
	};
	void setDefaults() {
		id = 0;
		width = 1;
		height = 1;
	}
	void set(int i, int w, int h) {
		id = i;
		width = w;
		height = h;
	}

	int id;
	int width;
	int height;
};

struct Color {
	Color(int r = 0, int g = 0, int b = 0) {
		red = r;
		green = g;
		blue = b;
	};
	void setDefaults() {
		red = 0;
		green = 0;
		blue = 0;
	}
	void set(int r, int g, int b) {
		red = r;
		green = g;
		blue = b;
	}
	int red;
	int green;
	int blue;
};

class Effect {
public:
    Effect(std::string script = "", int id = 0) {
        mScript = script;
        mId = id;
        mFloats.clear();
    }
    
    void setParameter(std::string name, float v) {
        mFloats[name] = v;
    }
    
    void clearParameters() {
        mFloats.clear();
    }
    
    const std::string& getScript() const {
        return mScript;
    }
    
    int getId() const {
        return mId;
    }
    
    const std::map<std::string, float>& getFloats() const {
        return mFloats;
    }
    
private:
    std::map<std::string, float> mFloats;
    std::string mScript;
    int mId;
};

}

#endif

