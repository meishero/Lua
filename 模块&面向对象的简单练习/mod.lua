--这种方式其实是新方式  旧的方式 往往在前面声明 module("oldmodule", package.seeall)  现在官方已经不推荐使用
--1.module() 第一个参数就是模块名，如果不设置，缺省使用文件名。
--2.第二个参数package.seeall,默认在定义了一个module()之后，前面定义的全局变量就都不可用了，包括print函数等，如果要让之前的全局变量可见，必须在定义module的时候加上参数package.seeall。 具体参考云风这篇文章
--package.seeall(module)功能：为module设置一个元表，此元表的__index字段的值为全局环境_G。所以module可以访问全局环境.
--之所以不再推荐module("...", package.seeall)这种方式，官方给出了两个原因。
--1.package.seeall这种方式破坏了模块的高内聚，原本引入oldmodule只想调用它的foo()函数，但是它却可以读写全局属性，例如oldmodule.os.
--2.第二个缺陷是module函数的side-effect引起的，它会污染全局环境变量。module("hello.world")会创建一个hello的table，并将这个table注入全局环境变量中，这样使得不想引用它的模块也能调用hello模块的方法。

mod ={};

local _a;  -- private  local只是限定局部变量 如果是全局变量 require后是可以访问到的
--Package拆开的意思，就是将所有Package中公开的名字放入_G表中。也就是让 Package.A() 变成_G.A
local _b;
--还可以用local n = {}来保存数据和定义私有变量和函数。能明确的区分出接口和私有的定义，公开接口的名称还可以随意改变，可以随意替换内部实现而不需要影响外部调用

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
