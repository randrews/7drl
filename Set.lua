require('middleclass')

Set = class('Set')

function Set:initialize(...)
   self.items = {}
   for _, i in ipairs{...} do self.items[i] = true end
end

function Set:add(item)
   if item then self.items[item] = true end
end

function Set:remove(item)
   self.items[item] = nil
end

----------------------------------------

function Set:length()
   local n = 0
   for k, _ in pairs(self.items) do n = n + 1 end
   return n
end

function Set:clear()
   self.items = {}
end

function Set:empty()
   return next(self.items) == nil
end

----------------------------------------

function Set:map(fn, ...)
   local result = Set()

   for item, _ in pairs(self.items) do
      result:add( fn(item, ...) )
   end

   return result
end

function Set:method_map(fn_name, ...)
   local result = Set()

   for item, _ in pairs(self.items) do
      local fn = item[fn_name]
      result:add( fn(item, ...) )
   end

   return result
end
