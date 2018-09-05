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

#ifndef _MFETF_AVGN_H_
#define _MFETF_AVGN_H_

#include "macawfilter2.h"

namespace macaw {

class MFETF_AvgN : public MacawFilter2 {
public:
	MFETF_AvgN();
	virtual ~MFETF_AvgN();

public:
	void setParameter(const std::string& name, float v);
	void setParameter(const std::string& name, const Texture& v);
	void setUniforms();
	void setDefaults();
	Texture& getSampler2(){return mFlow;}

private:
	Texture mFlow;
	int mTimes;
	float mThreshold;
	float mSpread;

};

}

#endif
