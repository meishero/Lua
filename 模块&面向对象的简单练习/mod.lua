mod ={};

local _a;  -- private
local _b;

local function construct()
	_a = 1;
	_b = -2;
end

local function a()
	print("gogogo !!!!")
end
local function b()
	print("oh shit !!!!")
end

local function show()
	print(_a .. _b);
end

mod =  --不注册进就是私有变量
{
	a = a;
	b = b;
	show = show;
	construct = construct;
}
return mod
