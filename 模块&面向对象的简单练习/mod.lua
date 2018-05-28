--这种方式其实是新方式  旧的方式 往往在前面声明 module("oldmodule", package.seeall)  现在官方已经不推荐使用
--module函数等同一下几句
--local modname = “mymodule”     – 定义模块名  
--local M = {}                               -- 定义用于返回的模块表  
--_G[modname] = M                      -- 将模块表加入到全局变量中  
--package.loaded[modname] = M    -- 将模块表加入到package.loaded中，防止多次加载  
--setfenv(1,M)                      - 将模块表设置为函数的环境表，这使得模块中的所有操作是以在模块表中的，这样定义函数就直接定义在模块表中 
--1.module() 第一个参数就是模块名，如果不设置，缺省使用文件名。
--2.第二个参数package.seeall,默认在定义了一个module()之后，前面定义的全局变量就都不可用了，包括print函数等，如果要让之前的全局变量可见，必须在定义module的时候加上参数package.seeall。 具体参考云风这篇文章
--package.seeall(module)功能：为module设置一个元表，此元表的__index字段的值为全局环境_G。所以module可以访问全局环境.
--默认情况下,module不提供外部访问.必须在调用它之前,为需要访问的外部函数或模块声明适当的局部变量.也可以通过继承来实现外部访问,只需在调用module时附加一个选项package.seeall.这个选项等价于如下代码:
--setmetatable(M,{__index = _G})  
--之所以不再推荐module("...", package.seeall)这种方式，官方给出了两个原因。
--1.package.seeall这种方式破坏了模块的高内聚，原本引入oldmodule只想调用它的foo()函数，但是它却可以读写全局属性，例如oldmodule.os.
--2.第二个缺陷是module函数的side-effect引起的，它会污染全局环境变量。module("hello.world")会创建一个hello的table，并将这个table注入全局环境变量中，这样使得不想引用它的模块也能调用hello模块的方法。

local mod ={}; --加local！不然不return也能访问。。。

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

mod =  --不注册进就是私有变量 因为有local限定本文件域内使用？ 但具体原因可能只是被require时不像C++一样include进去 看一下 require 实现
{
	a = a;
	b = b;
	show = show;
	construct = construct;
}
return mod


--require 函数的实现  
function require(name)  
    if not package.loaded[name] then  
        local loader = findloader(name) //这一步演示在代码中以抽象函数findloader来表示  ---- 如果是so，就以loadlib方式加载文件，如果是lua文件，就以loadfile方式加载文件。
        if loader == nil then  
            error("unable to load module" .. name)  
        end  
        package.loaded[name] = true  ---- 将模块标记为以加载，我们有时候会看到require返回true的现象，是由于被调用的模块，没有显示的执行package.loaded[modname] = M或者给出return M这样的返回值。
        local res = loader(name)  ---- require会以name作为入参来执行该文件，如果有返回结果，就将返回结果保存在package.loaded[name]中，如果没有返回结果，就直接返回package.loaded[name]。如果我们在被调用的文件中直接写明return 1。则调用者的require的返回结果就是1。但是只要我们显示的在require文件中写明了_G[modname] = M，我们仍然可以在require之后，直接使用M作为名字来调用，是由于将M加入到了_G中。
        if res ~= nil then  
            package.loaded[name] = res  
        end  
    end  
    return package.loaded[name]  
end  

    2.require实现解析：

    传参： require会将模块名作为参数传递给模块

    返回值：如果一个模块没有返回值的话，require就会返回package.loaded[modulename]作为返回值。

------------------------example---------------------

举例：

pa.lua:

local modname = ...

local M = {}



_G[modname] = M

package.loaded[modname] = M



function M.print_mob()

print(modname)

end



mob.lua:

require "pa"

pa.print_mob()



执行结果：

lua mob.lua

pa

------------------------------------------------------------

分析：

pa.lua中的modname接收的是require传递过来的参数，将其加入到全局环境变量_G中，相当于动态创建了一个modname的表（注意：表名的赋值实际上是引用，相当于C语言中的指针，即使是传参也会有相同的效果）。我们经常local m = require "mdname",实际上是将生成的表进行了重命名，但是本质上还是mdname这个表。

pa.lua中的return M我们没有显示声明，由package.loaded[modulename]来代替，通过require实现机制可以看到，这时候返回值应该是true。

三、环境

lua用_G一张表保存了全局数据（变量，函数和表等）。

如上分析，我们定义一个module，如果不加local，则它是一个注册在全局下的表。我们通过加local避免了它在污染全局表空间，只在本文件生效。如果我们没有将其注册到_G下，在其他文件是无法直接通过他的原始名字来访问的。不便利的地方，每个函数前面都要带M，M的下的函数相互访问也要带M头。

解决方法：通过setfenv

local modname = ...

local M = {}



_G[modname] = M

package.loaded[modname] = M

setfenv(1, M)

后续的函数直接定义名字，因为他们的环境空间已经由_G改为了M。

如果要使用全局函数，则可以本地额外增加一条local _G = _G或者setmetatable(M, {__index = G})。

更好的方法是在setfenv之前将需要的函数都保存起来，local sqrt = math.sqrt



四、module函数

local M = {}

_G[modname] = M

package.loaded[modname] = M

<set for external access: eg setmetatable(M, {__index = _G})>

setfenv(1, M)

等同于module(modname)。

默认情况下，module不提供外部访问，如果要访问外部变量，两种方法：

1.在声明module之前，local 变量 = 外部变量

2.使用module(modname, package.seeall)， 等价于setmetatable(M, __index = _G)

