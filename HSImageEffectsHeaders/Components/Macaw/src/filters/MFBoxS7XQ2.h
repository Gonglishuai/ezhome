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

#ifndef _MFBOXS7XQ2_H_
#define _MFBOXS7XQ2_H_

#include "MacawFilter1.h"

namespace macaw {

class MFBoxS7XQ2 : public MacawFilter1 {
public:
	MFBoxS7XQ2();
	virtual ~MFBoxS7XQ2();

public:
	void setParameter(const std::string& name, float v);
	void setUniforms();
	void setDefaults();

public:
	virtual void apply(const Texture& src, const Texture& dest);

private:
	float mThreshold;
	float mSpread;
	int mTimes;
	int mPass;

};

}

#endif

