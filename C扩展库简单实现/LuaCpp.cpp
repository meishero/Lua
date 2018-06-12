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

static const struct luaL_Reg abc[] = {  //abc是和你注册的函数模块要相符的
	{ "add", add },
	{ NULL, NULL },
}; 

extern "C" __declspec(dllexport) int  luaopen_LuaCpp_c(lua_State* lua)  //这里和生成的库名必须一致  //这里LuaCpp_c  lua require会调用loadlib( XXX.XXX) .在lua是这里面 _  就是目录的意思 
{
	luaL_register(lua, "LuaCpp", abc); //参数1 LuaCpp默认生成的模块名，可以随便名字 lua中用LuaCpp.xxx()调用即可   //abc是和你注册的函数模块要相符的
	return 1;
}

