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

#ifndef _MACAW_FILTER_H_
#define _MACAW_FILTER_H_

#include "common.h"
#include "opengl.h"

namespace macaw {


class MacawFilter {
public:
	MacawFilter(){}
	virtual ~MacawFilter(){}
	virtual void setParameter(const std::string& name, float v){}
	virtual void setParameter(const std::string& name, const Color& v){}
	virtual void setParameter(const std::string& name, const Texture& v){}
	virtual void apply(const Texture& src, const Texture& dest) = 0;
    virtual void apply(const Texture& src, const Renderbuffer& dest) = 0;
	virtual void setDefaults() = 0;
	virtual void release() = 0;

protected:
	virtual int getProgram() = 0;
	void setUniform1i(const std::string& name, int v);
	void setUniform1f(const std::string& name, float v);
	void setUniform2f(const std::string& name, float v1, float v2);
	void setUniform3f(const std::string& name, float v1, float v2, float v3);
    void setUpViewport(int viewportWidth, int viewportHeight, int textureWidth, int textureHeight) const;

	//convenience function for dealing with int RGB colors
	inline float norm(int c){ return ((float)c)/255.0f; }
};

}

#endif


