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

#ifndef _MFQUANTIZERGB6_H_
#define _MFQUNATIZERGB6_H_

#include "MacawFilter1.h"

namespace macaw {

class MFQuantizeRGB6 : public MacawFilter1 {
public:
	MFQuantizeRGB6();
	virtual ~MFQuantizeRGB6();

public:
	void setParameter(const std::string& name, float v);
	void setParameter(const std::string& name, const Color& v);
	void setUniforms();
	void setDefaults();

private:
	float dot(const Color& c1, const Color& c2);

private:
	float mScale;
	Color mColor1;
	Color mColor2;
	Color mColor3;
	Color mColor4;
	Color mColor5;

};

}

#endif

