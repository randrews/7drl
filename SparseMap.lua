require('middleclass')
require('Point')
require('List')
require('Map')

SparseMap = class('SparseMap')

function SparseMap:initialize(width, height)
    self.width = width
    self.height = height

    self.cells = {} -- map from x+y*w to value
end

-- convert a point to a number to be used as an index to cells
function SparseMap:num(pt)
    return pt.x + pt.y * self.width
end

function SparseMap:at(pt, val)
   if self:inside(pt) then
       if val~=nil then self.cells[self:num(pt)] = val end
       return self.cells[self:num(pt)]
   else
       return nil
   end
end

SparseMap.__call = SparseMap.at

function SparseMap:delete(pt)
    self.cells[self:num(pt)] = nil
end

function SparseMap:clear()
    self.cells = {}
end

function SparseMap:each(start, w, h)
   local maxx, maxy

   if w then maxx = start.x + w-1 else maxx = self.width-1 end
   if h then maxy = start.y + h-1 else maxy = self.height-1 end

   start = start or Point(0, 0)
   local current = nil

   local function valid(n)
       local pt = Point(n%self.width, math.floor(n/self.width))
       return (pt.x >= start.x and
               pt.y >= start.y and
               pt.x <= maxx and
               pt.y <= maxy)
   end

   return function()
              repeat
                  current = next(self.cells, current)
              until not current or valid(current)

              if current then
                  return Point(current % self.width,
                               math.floor(current / self.width))
              else
                  return nil
              end
          end
end

function SparseMap:neighbors(pt, fn, diag)
   local all = {pt + Point(-1, 0),
                pt + Point(1, 0),
                pt + Point(0, -1),
                pt + Point(0, 1)}

   if diag then
       table.insert(all, pt+Point.southwest)
       table.insert(all, pt+Point.northwest)
       table.insert(all, pt+Point.northeast)
       table.insert(all, pt+Point.southeast)
   end

   if fn and type(fn) ~= 'function' then
       local val = fn
       fn = function(_, p) return self:at(p) == val end
   end

   local fit = List{}
   for _, p in ipairs(all) do
       if self:at(p) and (not fn or fn(self, p)) then fit:push(p) end
   end
   return fit
end

SparseMap.clamp = Map.clamp
SparseMap.inside = Map.inside
SparseMap.find = Map.find
SparseMap.find_value = Map.find_value
SparseMap.random = Map.random
SparseMap.empty = Map.empty
SparseMap.full = Map.full
SparseMap.connected = Map.connected
SparseMap.connected_value = Map.connected_value

----------------------------------------

function SparseMap.static.test()
   -- Constructor
   local m = SparseMap(10, 10)
   assert(m.width == 10)
   assert(m:inside(Point(3,3)))
   assert(not m:inside(Point(10,10)))

   -- clear / set
   m:clear()
   m:at(Point(3,2),1)

   -- at
   assert(m:at(Point(1,1)) == nil)
   assert(m:at(Point(3,2)) == 1)
   assert(m:at(Point(10,10)) == nil)

   -- each
   local n = 0
   for p in m:each() do n = n + 1 end
   assert(n == 1)

   -- fit
   m:clear()
   m:at(Point(1,0),1)
   m:at(Point(1,1),1)
   m:at(Point(1,2),1)
   assert(m:neighbors(Point(1,0)):length() == 1)
   assert(m:neighbors(Point(1,1)):length() == 2)
   assert(m:neighbors(Point(5,5)):length() == 0)

   local n2 = 0
   for p in m:each(Point(0, 0), 5, 2) do n2 = n2 + 1 end
   assert(n2 == 2)
end

return SparseMap