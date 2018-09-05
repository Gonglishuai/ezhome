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

#ifndef _MFPAINT3_H_
#define _MFPAINT3_H_

#include "macawfilter4.h"

namespace macaw {

class MFPaint3 : public MacawFilter4 {
public:
	MFPaint3();
	virtual ~MFPaint3();

public:
	void setParameter(const std::string& name, float v);
	void setParameter(const std::string& name, const Texture& v);
	void setUniforms();
	void setDefaults();
	Texture& getSampler2(){return mSource;}
	Texture& getSampler3(){return mStrokes;}
	Texture& getSampler4(){return mFlow; }

private:
	Texture mSource;
	Texture mStrokes;
	Texture mFlow;
	float mTileSize;
	float mThreshold;
	float mStrokeScaleWidth;
	float mStrokeScaleHeight;
	float mStrokeLevel;
	float mStrokeStrength;

};

}

#endif

