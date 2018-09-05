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

#ifndef _STORAGE_H_
#define _STORAGE_H_

#include "common.h"
#include <map>
#include <vector>

namespace macaw {


class Storage {

public:
	Storage();
	~Storage();

public:
	void clear();
	void setModel(const Texture& model);
	Texture getTexture();
	Texture getPattern(const std::string& pattern_name);
	void putTexture(const Texture& tex);
	void putTextures();
	void setPattern(const std::string& pattern_name, const Texture& tex);

private:
	void clear_textures();
	void clear_patterns();

private:
	Texture mModel;
	std::vector<Texture> mFreeTextures;
	std::map<int, Texture> mActiveTextures;
	std::map<std::string, Texture> mPatterns;

};

}
#endif

