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

#ifndef _LUACONNECT_H_
#define _LUACONNECT_H_

#include "lua.hpp"
#include "common.h"
#include "macaw.h"

#define MACAW_COLOR		"Macaw.Color"
#define MACAW_TEXTURE	"Macaw.Texture"
#define MACAW_FILTER	"Macaw.Filter"
#define MACAW_RENDERBUFFER "Macaw.Renderbuffer"

namespace macaw {
//////////////////////////////////////////////////////////
// HELPER FUNCTIONS NOT TO BE EXPOSED TO LUA

//static void stackDump(lua_State* ls) {
//	int i;
//	int top = lua_gettop(ls);
//	for(int i = 1; i <= top; i++) {
//		int t = lua_type(ls, i);
//		printf("(%s)", lua_typename(ls, t));
//	}
//}

static void report_error(lua_State* ls, int status) {
	if(0 != status) {
		printf("ERROR: %s ============", lua_tostring(ls, -1));
		lua_pop(ls, 1);
	}
}

static bool confirm_type(lua_State* ls, int index, const char* type) {
	bool res = false;
//	int count = 1;

	if(ls && type && lua_getmetatable(ls, index)) {
		luaL_getmetatable(ls, type);
		res = (0 != lua_rawequal(ls, -1, -2));
		lua_pop(ls, 2);
	}

	return res;
}
    
/*
 static void list_effect_parameters(lua_State* ls) {
 lua_getglobal(ls, "parameters");
 if(lua_isnil(ls, -1) || !lua_istable(ls, -1)) {
 printf("Script does not have parameters");
 } else {
 lua_pushnil(ls);
 while(0 != lua_next(ls, -2)) {
 if(lua_isstring(ls, -2)) {
 printf("====> key:%s", lua_tostring(ls, -2));
 }
 
 //printf("======>  %s - %s",
 //		lua_typename(ls, lua_type(ls, -2)),
 //		lua_typename(ls, lua_type(ls, -1)));
 
 lua_pop(ls, 1);
 }
 
 }
 
 */

static void insert_script_parameters(lua_State* ls, const Effect& effect) {
    if(0 < effect.getFloats().size()) {
        
        lua_getglobal(ls, "parameters");
        if(lua_isnil(ls, -1) || !lua_istable(ls, -1)) {
            printf("Script does not have parameters");
        } else {
            std::map<std::string, float> parms = effect.getFloats();
            std::map<std::string, float>::iterator i;
            for(i = parms.begin(); i != parms.end(); ++i) {
//                float val = i->second;
                lua_pushstring(ls, i->first.c_str());
                lua_pushnumber(ls, (double)(i->second));
                lua_settable(ls, -3);
                printf("entry:%s - %g", i->first.c_str(), i->second);
            }
            
        }
        lua_pop(ls, 1);
        
    }
    
}
    
static Renderbuffer renderbuffer_from_table(lua_State* ls, int index) {
    
    lua_pushstring(ls, "id");
    lua_gettable(ls, index);
    int id = lua_tointeger(ls, -1);
    lua_pop(ls, 1);
    
    lua_pushstring(ls, "width");
    lua_gettable(ls, index);
    int width = lua_tointeger(ls, -1);
    lua_pop(ls, 1);
    
    lua_pushstring(ls, "height");
    lua_gettable(ls, index);
    int height = lua_tointeger(ls, -1);
    lua_pop(ls, 1);
    
    return Renderbuffer(id, width, height);
    
}

static Texture texture_from_table(lua_State* ls, int index) {

	lua_pushstring(ls, "id");
	lua_gettable(ls, index);
	int id = lua_tointeger(ls, -1);
	lua_pop(ls, 1);

	lua_pushstring(ls, "width");
	lua_gettable(ls, index);
	int width = lua_tointeger(ls, -1);
	lua_pop(ls, 1);

	lua_pushstring(ls, "height");
	lua_gettable(ls, index);
	int height = lua_tointeger(ls, -1);
	lua_pop(ls, 1);

	return Texture(id, width, height);

}


//static Color color_from_table(lua_State* ls, int index) {
//
//	lua_pushstring(ls, "id");
//	lua_gettable(ls, index);
//	int id = lua_tointeger(ls, -1);
//	lua_pop(ls, 1);
//
//	lua_pushstring(ls, "width");
//	lua_gettable(ls, index);
//	int width = lua_tointeger(ls, -1);
//	lua_pop(ls, 1);
//
//	lua_pushstring(ls, "height");
//	lua_gettable(ls, index);
//	int height = lua_tointeger(ls, -1);
//	lua_pop(ls, 1);
//
//	return Color(id, width, height);
//
//}
    
static void table_from_renderbuffer(lua_State* ls, const Renderbuffer& buff) {
    
    lua_newtable(ls);
    luaL_getmetatable(ls, MACAW_RENDERBUFFER);
    lua_setmetatable(ls, -2);
    
    lua_pushstring(ls, "id");
    lua_pushnumber(ls, buff.id);
    lua_settable(ls, -3);
    
    lua_pushstring(ls, "width");
    lua_pushnumber(ls, buff.width);
    lua_settable(ls, -3);
    
    lua_pushstring(ls, "height");
    lua_pushnumber(ls, buff.height);
    lua_settable(ls, -3);
    
}

static void table_from_texture(lua_State* ls, const Texture& tex) {

	lua_newtable(ls);
	luaL_getmetatable(ls, MACAW_TEXTURE);
	lua_setmetatable(ls, -2);

	lua_pushstring(ls, "id");
	lua_pushnumber(ls, tex.id);
	lua_settable(ls, -3);

	lua_pushstring(ls, "width");
	lua_pushnumber(ls, tex.width);
	lua_settable(ls, -3);

	lua_pushstring(ls, "height");
	lua_pushnumber(ls, tex.height);
	lua_settable(ls, -3);

}


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
// MACAW FUNCTIONS TO BE CALLED FROM LUA

static int getColor(lua_State* ls) {

	bool valid = true;
	valid &= (3 == lua_gettop(ls));
	valid &= lua_isnumber(ls, 1);
	valid &= lua_isnumber(ls, 2);
	valid &= lua_isnumber(ls, 3);
	if(!valid) {
		printf("==> wrong parameter(s) for getColor(..)");
		return 0;
	}

	int red = lua_tointeger(ls, 1);
	int green = lua_tointeger(ls, 2);
	int blue = lua_tointeger(ls, 3);
	lua_pop(ls, 3);

	lua_newtable(ls);
	luaL_getmetatable(ls, MACAW_COLOR);
	lua_setmetatable(ls, -2);

	lua_pushstring(ls, "red");
	lua_pushnumber(ls, red);
	lua_settable(ls, -3);

	lua_pushstring(ls, "green");
	lua_pushnumber(ls, green);
	lua_settable(ls, -3);

	lua_pushstring(ls, "blue");
	lua_pushnumber(ls, blue);
	lua_settable(ls, -3);

	return 1;

}

static int getFilter(lua_State* ls) {

	if(lua_isstring(ls, -1)) {
		std::string name = lua_tostring(ls, -1);

		if(!Macaw::instance().isFilter(name)) {
			printf("==> There is no filter: %s", name.c_str());
			return 0;
		}

		lua_newtable(ls);
		lua_pushstring(ls, "name");
		lua_pushstring(ls, name.c_str());
		lua_settable(ls, -3);

		luaL_getmetatable(ls, MACAW_FILTER);
		lua_setmetatable(ls, 2);

	} else {
		printf("==> bad or no parameter(s) for getFilter(..)");
		return 0;
	}

	return 1;
}


static int getPattern(lua_State* ls) {

	if(lua_isstring(ls, -1)) {
		std::string pattern_name = lua_tostring(ls, -1);

		Texture tex = Macaw::instance().getPattern(pattern_name);
		if(0 != tex.id) {

			lua_newtable(ls);
			luaL_getmetatable(ls, MACAW_TEXTURE);
			lua_setmetatable(ls, -2);

			lua_pushstring(ls, "id");
			lua_pushnumber(ls, tex.id);
			lua_settable(ls, -3);

			lua_pushstring(ls, "width");
			lua_pushnumber(ls, tex.width);
			lua_settable(ls, -3);

			lua_pushstring(ls, "height");
			lua_pushnumber(ls, tex.height);
			lua_settable(ls, -3);

		} else {
			printf("==> there is no pattern with name:%s", pattern_name.c_str());
			return 0;

		}

	} else {
		printf("==> bad or no parameter(s) for getPattern(..)");
		return 0;
	}

	return 1;
}

/*
static int getClone(lua_State* ls) {

	int id = 0;
	int width = 0;
	int height = 0;

	if(!confirm_type(ls, 1, MACAW_TEXTURE)) {
		printf("==> wrong parameter for getClone(..)");
		stackDump(ls);
		return 0;
	}
	Texture t = texture_from_table(ls, 1);

	Texture s = Macaw::instance().getClone(t);

	if(0 == s.id) {
		printf("==> cannot create compatible type for getClone(..)");
		return 0;
	}

	table_from_texture(ls, s);

	return 1;
}
*/

static int getTexture(lua_State* ls) {

	Texture t = Macaw::instance().getTexture();

	if(0 == t.id) {
		printf("==> no available textures for getTexture(..)");
		return 0;
	}

	table_from_texture(ls, t);

	return 1;
}


static int putTexture(lua_State* ls) {

//	int id = 0;
//	int width = 0;
//	int height = 0;

	if(!confirm_type(ls, 1, MACAW_TEXTURE)) {
		printf("==> wrong parameter for putTexture(..)");
		return 0;
	}

	Texture t = texture_from_table(ls, 1);
	Macaw::instance().putTexture(t);
	return 0;
}


// FUNCTIONS TO BE USED AS METHODS FOR FILTER TYPE
static int setParameter(lua_State* ls) {

	bool valid = true;
	valid &= (2 < lua_gettop(ls));
	valid &= confirm_type(ls, 1, MACAW_FILTER);
	valid &= lua_isstring(ls, 2);
	if(!valid) {
		printf("==> wrong parameter(s) for setParameter(..)");
		return 0;
	}

	lua_pushstring(ls, "name");
	lua_gettable(ls, 1);
	std::string filter_name = lua_tostring(ls, -1);
	//printf("==> filter_name:%s", filter_name.c_str());
	lua_pop(ls, 1);

	std::string param_name = lua_tostring(ls, 2);
	//printf("==> param_name:%s", param_name.c_str());

	if(lua_isnumber(ls, 3)) {
		float v = (float)lua_tonumber(ls, 3);
		//printf("==> param_value:%f", v);
		Macaw::instance().setParameter(filter_name, param_name, v);

	} else if(confirm_type(ls, 3, MACAW_COLOR)) {
		lua_pushstring(ls, "red");
		lua_gettable(ls, 3);
		int red = lua_tointeger(ls, -1);
		lua_pop(ls, 1);

		lua_pushstring(ls, "green");
		lua_gettable(ls, 3);
		int green = lua_tointeger(ls, -1);
		lua_pop(ls, 1);

		lua_pushstring(ls, "blue");
		lua_gettable(ls, 3);
		int blue = lua_tointeger(ls, -1);
		lua_pop(ls, 1);

		Color color(red, green, blue);
		Macaw::instance().setParameter(filter_name, param_name, color);

	} else if(confirm_type(ls, 3, MACAW_TEXTURE)) {
		lua_pushstring(ls, "id");
		lua_gettable(ls, 3);
		int id = lua_tointeger(ls, -1);
		lua_pop(ls, 1);

		lua_pushstring(ls, "width");
		lua_gettable(ls, 3);
		int width = lua_tointeger(ls, -1);
		lua_pop(ls, 1);

		lua_pushstring(ls, "height");
		lua_gettable(ls, 3);
		int height = lua_tointeger(ls, -1);
		lua_pop(ls, 1);

		Texture tex(id, width, height);
		Macaw::instance().setParameter(filter_name, param_name, tex);

	}

	return 0;
}


static int apply(lua_State* ls) {

	if(confirm_type(ls, 1, MACAW_FILTER)) {

		lua_pushstring(ls, "name");
		lua_gettable(ls, 1);
		std::string filter_name = lua_tostring(ls, -1);
		lua_pop(ls, 1);

		if(confirm_type(ls, 2, MACAW_TEXTURE)) {
			Texture src = texture_from_table(ls, 2);
			if(confirm_type(ls, 3, MACAW_TEXTURE)) {
				Texture dest = texture_from_table(ls, 3);
				Macaw::instance().apply(filter_name, src, dest);
			} else if (confirm_type(ls, 3, MACAW_RENDERBUFFER)){
                Renderbuffer dest = renderbuffer_from_table(ls, 3);
                Macaw::instance().apply(filter_name, src, dest);
            } else {
				Macaw::instance().apply(filter_name, src);
			}
		}

	}

	return 0;
}

////////////////////////////////////////////////////
static const struct luaL_Reg macaw_filter_methods [] = {
		{"setParameter", setParameter},
		{"apply", apply},
		{NULL, NULL}
};

static void register_macaw(lua_State* ls) {

	luaL_newmetatable(ls, MACAW_TEXTURE);
	luaL_newmetatable(ls, MACAW_COLOR);
    luaL_newmetatable(ls, MACAW_RENDERBUFFER);

	luaL_newmetatable(ls, MACAW_FILTER);
	lua_pushvalue(ls, -1);
	lua_setfield(ls, -2, "__index");
	luaL_register(ls, NULL, macaw_filter_methods);


	lua_register(ls, "getFilter", getFilter);
	lua_register(ls, "getColor", getColor);
	lua_register(ls, "getPattern", getPattern);
	lua_register(ls, "getTexture", getTexture);
	lua_register(ls, "putTexture", putTexture);

}

}

#endif





