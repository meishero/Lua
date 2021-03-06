// LuaCpp.cpp: 定义控制台应用程序的入口点。
//
//DLL中的抛出函数原型必须是: [extern "C"] __declspec(dllexport) int luaopen_XXX(LuaState* L), 而且XXX是DLL的文件名。[]是可选符号，而package.loadlib使用方式是不需要这些规则的，但是为了兼容性好，即：DLL可以同时使用以上两种方式使用，还是按规则命名抛出函数。
#include "LuaCpp.h"
#include "lua.hpp"
#pragma comment(lib , "lua5.1.lib")
//#pragma comment(lib , "lua51.lib")
//int main()
//{
//	lua_State
//	luaL_openlibs()
//    return 0;
//}
static int add(lua_State* L)
{
	
	double a = luaL_checknumber(L, -1);
	double b = luaL_checknumber(L, -2);
	lua_pushnumber(L, a + b);
	return 1;
}

static const struct luaL_Reg abc[] = {
	{ "add", add },
	{ NULL, NULL },
}; 

extern "C" __declspec(dllexport) int  luaopen_LuaCpp_c(lua_State* lua)
{
	luaL_register(lua, "LuaCpp", abc);
	return 1;
}

