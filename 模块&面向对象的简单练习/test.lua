package.path = package.path .. '.\\?.lua;'
test1 = require 'mod'

function a()
	print("fuck you mother")
end

a();
test1.b();

print(_a)

test1.construct();
print(test1.show())
