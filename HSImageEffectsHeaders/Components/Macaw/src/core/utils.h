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

#ifndef _UTILS_H__
#define _UTILS_H_

#include "opengl.h"
#include "common.h"

namespace macaw {


class Utils {

public:
	static GLuint create_framebuffer();
	static void delete_framebuffer(GLuint fb);

	static Texture create_texture(int width, int height);
	static void delete_texture(const Texture& tex);

	static int create_program(const std::string& vs, const std::string& fs);

	static void init_texture_params();
	static void check_frame_buffer();
	static void check_error(const char* op);

private:
	static GLuint load_shader(GLenum type, const GLchar* shader);
	static GLuint create_program(const GLchar* vs, const GLchar* fs);

};

}
#endif

