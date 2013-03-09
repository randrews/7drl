require('middleclass')
require('List')

Promise = class('Promise')

function Promise:initialize()
    self.finished = false
    self.functions = List()
    self.arguments = nil
end

function Promise.static.finished(...)
    local p = Promise()
    p:finish(...)
    return p
end

function Promise:add(fn)
    self.functions:push(fn)
    if self.finished then fn(unpack(self.arguments)) end
    return self
end

function Promise:finish(...)
    self.arguments = {...}
    self.finished = true
    self.functions:map(function(fn) fn(unpack(self.arguments)) end)
    return self
end

function Promise.static.test()
    local test1, test2

    local p = Promise()
    p:add(function(a, b) test1 = a+b end)
    p:finish(2, 5)
    assert(test1 == 7)

    p:add(function(a, b) test2 = a*b end)
    assert(test2 == 10)

    p = Promise.finished(2, 3, 4)
    p:add(function(...) test1 = #{...} end)
    assert(test1 == 3)
end

return Promise