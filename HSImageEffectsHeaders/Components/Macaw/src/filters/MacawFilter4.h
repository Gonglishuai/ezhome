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

#ifndef _MACAW_FILTER_4_H_
#define _MACAW_FILTER_4_H_

#include "MacawFilter.h"

namespace macaw {

class MacawFilter4 : public MacawFilter {
public:
	MacawFilter4();
	MacawFilter4(const std::string& fs);
	MacawFilter4(const std::string& fs, const std::string& vs);
	virtual ~MacawFilter4();

public:
	virtual void apply(const Texture& src, const Texture& dest);
    virtual void apply(const Texture& src, const Renderbuffer& dest);
	virtual int getProgram(){ return mProgram; }
	virtual void release();
	virtual void setUniforms(){}
	virtual void setDefaults(){}

	virtual Texture& getSampler2() = 0;
	virtual Texture& getSampler3() = 0;
	virtual Texture& getSampler4() = 0;

private:
	std::string mFragmentShader;
	std::string mVertexShader;
	int mProgram;

};

}

#endif


