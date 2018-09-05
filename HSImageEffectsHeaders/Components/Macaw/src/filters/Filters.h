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

#ifndef _FILTERS_H_
#define _FILTERS_H_

#include <map>
#include "common.h"

#include "MFCopy.h"

#include "MFConvertRGB2Lab.h"
#include "MFConvertLab2RGB.h"

#include "MFSqueezeLab1.h"
#include "MFSqueezeLab2.h"
#include "MFSqueezeLab3.h"
#include "MFSqueezeLab4.h"
#include "MFSqueezeLab5.h"
#include "MFSqueezeLab6.h"

#include "MFQuantizeLab1.h"
#include "MFQuantizeLab2.h"
#include "MFQuantizeLab3.h"
#include "MFQuantizeLab4.h"

#include "MFQuantizeRGB1.h"
#include "MFQuantizeRGB2.h"
#include "MFQuantizeRGB3.h"
#include "MFQuantizeRGB4.h"
#include "MFQuantizeRGB5.h"
#include "MFQuantizeRGB6.h"
#include "MFQuantizeRGB7.h"
#include "MFQuantizeRGB8.h"

#include "MFBilateralS7.h"
#include "MFBilateralSTX.h"

#include "MFBoxS7X.h"
#include "MFBoxS7XQ1.h"
#include "MFBoxS7XQ2.h"
#include "MFBoxSL13X.h"

#include "MFBrightness.h"
#include "MFCanvas2.h"
#include "MFColor1.h"

#include "MFCrossHatch1.h"
#include "MFDoBX1.h"
#include "MFDoGX1.h"
#include "MFEngraving1.h"
#include "MFETF_Avg.h"
#include "MFETF_AvgN.h"
#include "MFETF_AvgT.h"
#include "MFETF_DoGX.h"
#include "MFETF_Edge.h"
#include "MFETF_ST.h"
#include "MFETF_STBlur.h"
#include "MFETF_STX.h"
#include "MFETF_TF.h"
#include "MFETF.h"

#include "MFGaussianS5X.h"
#include "MFGaussianS7X.h"
#include "MFGaussianSL13.h"
#include "MFGaussianSL13X.h"
#include "MFGaussianSL5X.h"

#include "MFGrayscale1.h"

#include "MFMixer1.h"
#include "MFMixer2.h"
#include "MFMixer3.h"
#include "MFMixer4.h"
#include "MFMixer5.h"
#include "MFMixer6.h"

#include "MFMixerBri1.h"
#include "MFMixerColor1.h"
#include "MFMixerColor2.h"

#include "MFOil1.h"
#include "MFOilX1.h"
#include "MFPaint1.h"
#include "MFPaint2.h"
#include "MFPaint3.h"
#include "MFPaint4.h"

#include "MFPixelate1.h"
#include "MFPixelate2.h"
#include "MFPixelate3.h"
#include "MFPixelate4.h"
#include "MFPixelate5.h"
#include "MFPixelate6.h"

#include "MFStipple1.h"
#include "MFStipple2.h"
#include "MFStrokes.h"

#include "MFXDoGX1.h"
#include "MFXDoGX2.h"
#include "MFXDoGX3.h"
#include "MFXDoGX4.h"
#include "MFXDoGX5.h"

namespace macaw {


class Filters {
public:
	Filters();
	~Filters();

public:
	void release();
	bool isFilter(const std::string& filter_name);
	void setParameter(const std::string& filter_name, const std::string& param_name, float val);
	void setParameter(const std::string& filter_name, const std::string& param_name, const Color& col);
	void setParameter(const std::string& filter_name, const std::string& param_name, const Texture& tex);
	void apply(const std::string& filter_name, const Texture& src, const Texture& dest);
    void apply(const std::string& filter_name, const Texture& src, const Renderbuffer& dest);

	void setDefaults(const std::string& filter_name);

private:
	MacawFilter* getFilter(const std::string& filter_name);

private:
	std::map<std::string, MacawFilter*> mFilters;

private:

	MFBilateralS7  mBilateralS7;
	MFBilateralSTX mBilateralSTX;
	MFBoxS7X       mBoxS7X;
	MFBoxS7XQ1     mBoxS7XQ1;
	MFBoxS7XQ2     mBoxS7XQ2;
	MFBoxSL13X	   mBoxSL13X;
	MFBrightness	mBrightness;

	MFCanvas2	 	mCanvas2;
	MFColor1		mColor1;
	MFConvertRGB2Lab mConvertRGB2Lab;
	MFConvertLab2RGB mConvertLab2RGB;
	MFCopy 			mCopy;
	MFCrossHatch1	mCrossHatch1;

	MFDoBX1	mDoBX1;
	MFDoGX1	mDoGX1;

	MFEngraving1	mEngraving1;
	MFETF_Avg		mETF_Avg;
	MFETF_AvgN		mETF_AvgN;
	MFETF_AvgT		mETF_AvgT;
	MFETF_DoGX		mETF_DoGX;
	MFETF_Edge		mETF_Edge;
	MFETF_ST		mETF_ST;
	MFETF_STBlur	mETF_STBlur;
	MFETF_STX		mETF_STX;
	MFETF_TF		mETF_TF;
	MFETF			mETF;

	MFGaussianS5X	mGaussianS5X;
	MFGaussianS7X	mGaussianS7X;
	MFGaussianSL13	mGaussianSL13;
	MFGaussianSL13X	mGaussianSL13X;
	MFGaussianSL5X	mGaussianSL5X;

	MFGrayscale1 mGrayscale1;
	MFMixer1 mMixer1;
	MFMixer2 mMixer2;
	MFMixer3 mMixer3;
	MFMixer4 mMixer4;
	MFMixer5 mMixer5;
	MFMixer6 mMixer6;

	MFMixerBri1 mMixerBri1;
	MFMixerColor1 mMixerColor1;
	MFMixerColor2 mMixerColor2;

	MFOil1	mOil1;
	MFOilX1	mOilX1;

	MFPaint1	mPaint1;
	MFPaint2	mPaint2;
	MFPaint3	mPaint3;
	MFPaint4	mPaint4;

	MFPixelate1	mPixelate1;
	MFPixelate2	mPixelate2;
	MFPixelate3	mPixelate3;
	MFPixelate4	mPixelate4;
	MFPixelate5	mPixelate5;
	MFPixelate6	mPixelate6;

	MFQuantizeLab1 mQuantizeLab1;
	MFQuantizeLab2 mQuantizeLab2;
	MFQuantizeLab3 mQuantizeLab3;
	MFQuantizeLab4 mQuantizeLab4;

	MFQuantizeRGB1 mQuantizeRGB1;
	MFQuantizeRGB2 mQuantizeRGB2;
	MFQuantizeRGB3 mQuantizeRGB3;
	MFQuantizeRGB4 mQuantizeRGB4;
	MFQuantizeRGB5 mQuantizeRGB5;
	MFQuantizeRGB6 mQuantizeRGB6;
	MFQuantizeRGB7 mQuantizeRGB7;
	MFQuantizeRGB8 mQuantizeRGB8;

	MFSqueezeLab1 mSqueezeLab1;
	MFSqueezeLab2 mSqueezeLab2;
	MFSqueezeLab3 mSqueezeLab3;
	MFSqueezeLab4 mSqueezeLab4;
	MFSqueezeLab5 mSqueezeLab5;
	MFSqueezeLab6 mSqueezeLab6;

	MFStipple1	mStipple1;
	MFStipple2	mStipple2;
	MFStrokes   mStrokes;

	MFXDoGX1	mXDoGX1;
	MFXDoGX2	mXDoGX2;
	MFXDoGX3	mXDoGX3;
	MFXDoGX4	mXDoGX4;
	MFXDoGX5	mXDoGX5;


};

}

#endif

