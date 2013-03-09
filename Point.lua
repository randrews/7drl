require 'middleclass'

Point = class('Point')

----------------------------------------
-- Constructors
----------------------------------------

function Point:initialize(x,y)
   self.x = x
   self.y = y
end

Point.north = Point(0, -1) ; Point.up = Point.north
Point.south = Point(0, 1) ; Point.down = Point.south
Point.west = Point(-1, 0) ; Point.left = Point.west
Point.east = Point(1, 0) ; Point.right = Point.east

function Point:copy()
   return Point(self.x, self.y)
end

----------------------------------------
-- Utils
----------------------------------------

function Point:ortho(pt2)
   return self.x == pt2.x or self.y == pt2.y
end

function Point:toward(pt2)
   if not self:ortho(pt2) then error(self .. ' not in a straight line with ' .. pt2)
   else
      local v = pt2 - self
      if v.x > 0 then v.x=1 end
      if v.x < 0 then v.x=-1 end
      if v.y > 0 then v.y=1 end
      if v.y < 0 then v.y=-1 end
      return v
   end
end

function Point:adjacent(pt2)
   local d = pt2-self
   return (d.x == 0 or d.y == 0) and (math.abs(d.x+d.y) == 1)
end

-- With one arg: returns the distance to pt2
-- With two args: returns whether the distance is less than or equal to the 2nd arg
function Point:dist(pt2, max)
   assert(pt2)
   local d = (self - pt2) * (self - pt2)
   if max then
      return (d.x+d.y) <= max*max
   else
      return math.sqrt(d.x + d.y)
   end
end

-- Length of a line from (0,0) to self
function Point:length()
   return math.sqrt((self.x * self.x) + (self.y * self.y))
end

Point.magnitude = Point.length

-- Return a point with the same direction as self, but length 1
function Point:normal()
   return self / self:length()
end

function Point.__add(pt1, pt2)
   return Point(pt1.x+pt2.x, pt1.y+pt2.y)
end

function Point.__sub(pt1, pt2)
   return Point(pt1.x-pt2.x, pt1.y-pt2.y)
end

function Point.__mul(pt1, pt2)
   if type(pt1) == 'number' then
      return Point(pt2.x * pt1, pt2.y * pt1)
   elseif type(pt2) == 'number' then
      return Point(pt1.x * pt2, pt1.y * pt2)
   else
      return Point(pt1.x*pt2.x, pt1.y*pt2.y)
   end
end

function Point.__div(pt1, pt2)
   if type(pt1) == 'number' then
      return Point(pt1 * pt2.x, pt1 * pt2.x)
   elseif type(pt2) == 'number' then
      return Point(pt1.x / pt2, pt1.y / pt2)
   else
      return Point(pt1.x/pt2.x, pt1.y/pt2.y)
   end
end

Point.translate = Point.__add

function Point:__tostring()
   return string.format('(%.2f, %.2f)', self.x, self.y)
end

function Point:__call()
   return self.x, self.y
end

function Point.__eq(pt1, pt2)
   return pt1.x == pt2.x and pt1.y == pt2.y
end

-- A point is "less than" a point if each
-- coord is less than the corresponding one
function Point.__lt(pt1, pt2)
   return pt1.x < pt2.x and pt1.y < pt2.y
end

function Point.__le(pt1, pt2)
   return pt1.x <= pt2.x and pt1.y <= pt2.y
end

function test()
   local p = Point(2,3)
   assert(p.x == 2 and p.y == 3)
   assert(tostring(p) == "(2.00, 3.00)")
   p = p + Point(1,1)
   assert(tostring(p) == "(3.00, 4.00)")
   local p2 = p:copy()
   p2.y = p2.y-1
   assert(tostring(p) == "(3.00, 4.00)")
   assert(tostring(p2) == "(3.00, 3.00)")
   assert(p2 + Point(1, 1) == Point(4, 4))

   local o1, o2 = Point(3, 3), Point(3, 5)
   assert(o1:ortho(o2))
   assert(o2-o1 == Point(0, 2))
   assert(o1:toward(o2) == Point(0, 1))

   local a1, a2, a3 = Point(2, 2), Point(1, 2), Point(3, 3)
   assert(a1:adjacent(a2))
   assert(a2:adjacent(a1))
   assert(not a2:adjacent(a3))
   assert(not a1:adjacent(a3))
   assert(not a1:adjacent(a1))

   assert(a2 <= a1)
   assert(a1 < a3)
   assert(a3 > a1)
   assert(not(a2 < a1))
end

test() -- Run the tests on load, error if any fail

return Point