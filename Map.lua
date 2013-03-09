require('middleclass')
require('Point')
require('List')

Map = class('Map')

function Map:initialize(width, height)
   self.width = width
   self.height = height
   self.cells = List{}
   for i=1, width*height do self.cells:push(0) end
end

function Map.static.new_from_strings(strs)
   assert(type(strs) == 'table' and type(strs[1])=='string')
   local l = Map(#(strs[1]), #strs)
   for p in l:each() do
      local s = strs[p.y+1]:sub(p.x+1, p.x+1)
      l:at(p, s)
   end
   return l
end

function Map.static.new_from_string(str)
   assert(type(str) == 'string')
   local strs = {}
   local line = ''
   for n = 1, #str do
      local c = str:sub(n,n)
      if c == "\n" then
         table.insert(strs, line)
         line = ''
      else
         line = line .. c
      end
   end

   return Map.new_from_strings(strs)
end

function Map:at(pt, val)
   if self:inside(pt) then
      if val~=nil then self.cells[pt.x+pt.y*self.width] = val end
      return self.cells[pt.x+pt.y*self.width]
   else
      return nil
   end
end

Map.__call = Map.at

function Map:clamp(pt)
   pt = pt:copy()
   if pt.x < 0 then pt.x = 0 end
   if pt.x > self.width-1 then pt.x = self.width-1 end
   if pt.y < 0 then pt.y = 0 end
   if pt.y > self.height-1 then pt.y = self.height-1 end
   return pt
end

function Map:inside(pt)
   return pt >= Point(0, 0) and pt < Point(self.width, self.height)
end

function Map:clear(value)
   for p in self:each() do
      self:at(p, value)
   end
end

function Map:each(start, w, h)
   local maxx, maxy

   if w then maxx = start.x + w-1 else maxx = self.width-1 end
   if h then maxy = start.y + h-1 else maxy = self.height-1 end

   start = start or Point(0, 0)
   local p = start

   return function()
             local r = p -- return this one...

             -- Decide what the next one will be:
             p = p + Point(1, 0)
             if p.x > maxx then p = Point(start.x, p.y+1) end

             if r.y > maxy then return nil
             else return r end
          end
end

function Map:__tostring()
   local s = ''

   for y = 0, self.height-1 do
      for x = 0, self.width-1 do
         s = s .. tostring(self:at(Point(x,y))) .. ' '
      end
      s = s .. "\n"
   end

   return s
end

function Map:find(fn)
   assert(type(fn) == 'function')
   local fit = List{}
   for pt in self:each() do
      if fn(self, pt) then fit:push(pt) end
   end
   return fit
end

function Map:find_value(value)
   local fn = function(map, pt) return map(pt) == value end
   return self:find(fn)
end

function Map:random(fn)
   fn = fn or function() return true end
   local fit = self:find(fn)
   if fit:empty() then return nil
   else return fit:random() end
end

----------------------------------------

function Map:empty(pt)
   return self:at(pt) == ''
end

function Map:full(pt)
   return not self:empty(pt)
end

function Map:neighbors(pt, fn)
   local all = {pt + Point(-1, 0),
                pt + Point(1, 0),
                pt + Point(0, -1),
                pt + Point(0, 1)}

   local fit = List{}
   for _, p in ipairs(all) do
      if self:inside(p) and (not fn or fn(self, p)) then fit:push(p) end
   end
   return fit
end

----------------------------------------

function Map.static.test()
   -- Constructor
   local m = Map(10, 10)
   assert(m.width == 10)
   assert(m:inside(Point(3,3)))
   assert(not m:inside(Point(10,10)))

   -- clear / set
   m:clear(0)
   m:at(Point(3,2),1)

   -- at
   assert(m:at(Point(1,1)) == 0)
   assert(m:at(Point(3,2)) == 1)
   assert(m:at(Point(10,10)) == nil)

   -- each
   local n = 0
   for p in m:each() do n = n + 1 end
   assert(n == 100)

   -- fit
   m:clear('')
   m:at(Point(1,0),1)
   assert(m:neighbors(Point(5,5)):length() == 4)
   assert(m:neighbors(Point(0,1)):length() == 3)
   assert(m:neighbors(Point(0,0)):length() == 2)
   assert(m:neighbors(Point(0,0), m.empty):length() == 1)

   local n2 = 0
   for p in m:each(Point(2, 2), 4, 4) do n2 = n2 + 1 end
   assert(n2 == 16)
end

return Map