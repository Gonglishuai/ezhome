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

#ifndef _MFXDOGX2_H_
#define _MFXDOGX2_H_

#include "MacawFilter1.h"
#include "MFGaussianSL13X.h"
#include "MFXDoGX2M.h"

namespace macaw {

class MFXDoGX2 : public MacawFilter1 {
public:
	MFXDoGX2();
	virtual ~MFXDoGX2();

public:
	void setParameter(const std::string& name, float v);
	void setDefaults();
	void release();
	void apply(const Texture& src, const Texture& dest);

private:
	float mSigma;
	float mK;
	float mP;
	float mE;
	float mKE;

	MFGaussianSL13X mBlur;
	MFXDoGX2M mMixer;


};

}

#endif

