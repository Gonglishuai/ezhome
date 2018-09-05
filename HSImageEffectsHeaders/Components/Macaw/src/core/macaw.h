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

#ifndef _MACAW_H_
#define _MACAW_H_


#include "common.h"
#include "storage.h"
#include "Filters.h"

namespace macaw {


class Macaw {
	public:
		static Macaw& instance() {
			static Macaw _instance;
			return _instance;
		}

	public:
		// To be called from the GL thread in application
		void initialize();
		void setPattern(const std::string& pattern_name, const Texture& tex);
		void render(const Effect& effect, const Texture& src, const Texture& dest);
        void render(const Effect& effect, const Texture& src, const Renderbuffer& dest);

	public:
		// To be called from Lua scripts
		bool isFilter(const std::string& filter_name);
		Texture getPattern(const std::string& pattern_name);
		Texture getTexture();
		void putTexture(const Texture& tex);

		void setParameter(const std::string& filter_name, const std::string& param_name, float val);
		void setParameter(const std::string& filter_name, const std::string& param_name, const Color& col);
		void setParameter(const std::string& filter_name, const std::string& param_name, const Texture& tex);

		void apply(const std::string& filter_name, const Texture& src);
		void apply(const std::string& filter_name, const Texture& src, const Texture& dest);
        void apply(const std::string& filter_name, const Texture& src, const Renderbuffer& dest);

	private:
		Storage mStorage;
		Filters mFilters;

	private:
		Macaw() {};
		Macaw(const Macaw &);
		void operator=(const Macaw &);

};

}
#endif


