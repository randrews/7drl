require 'middleclass'

Clock = class('Clock')

Clock.all_clocks = {}

function Clock:initialize(delay, callback, ...)
   assert(delay > 0, "Delay must be greater than 0 seconds")
   assert(callback, "Clocks must have a callback, otherwise what's the point?")

   self.delay = delay
   self.callback = callback
   self.elapsed = 0
   self.args = {...}

   table.insert(Clock.all_clocks, self)
end

function Clock.static.oneoff(delay, callback, ...)
   assert(delay > 0, "Delay must be greater than 0 seconds")
   assert(callback, "Clocks must have a callback, otherwise what's the point?")

   local a = {...}
   local c
   c = Clock(delay, function()
                       callback(unpack(a))
                       c:stop()
                    end)

   return c
end

function Clock:update(dt)
   self.elapsed = self.elapsed + dt
   if self.elapsed >= self.delay then
      self.callback(unpack(self.args))
      self.elapsed = 0
   end
end

function Clock:stop()
   for n, c in ipairs(Clock.all_clocks) do
      if c == self then
         table.remove(Clock.all_clocks, n)
         return
      end
   end
   error("Clock not active!")
end

function Clock.static.update(dt)
   for _, c in ipairs(Clock.all_clocks) do
      c:update(dt)
   end
end

return Clock