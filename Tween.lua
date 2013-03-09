require('middleclass')
require('List')

Tween = class('Tween')

Tween.static.all = List()

function Tween.static.update(dt)
   Tween.all:method_map('update', dt)
   Tween.static.all = Tween.all:method_select('alive')
end

function Tween:initialize(from, to, duration)
    self.finished = false
    self.value = from
    self.from = from
    self.to = to
    self.diff = to - from
    self.time = 0
    self.duration = duration or 1
    Tween.all:push(self)
end

function Tween:alive() return not self.finished end

function Tween:update(dt)
    if self.finished then return end

    self.time = self.time + dt
    self.value = self.from + self.diff * self.time / self.duration

    if self.time >= self.duration then
        self.value = self.to
        self.finished = true
    end
end

function Tween.static.test()
    local t = Tween(0, 10, 5)
    assert(Tween.all:length() == 1)

    assert(t.value == 0)
    assert(t:alive())

    Tween.update(1)
    assert(t.value == 2)
    assert(t:alive())

    Tween.update(6)
    assert(t.value == 10)
    assert(not t:alive())
    assert(Tween.all:length() == 0)

    Tween.update(1)
    assert(t.value == 10)
end

return Tween