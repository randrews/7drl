require('middleclass')

List = class('List')

function List:initialize(items)
   self.items = items or {}
end

-- Add to end
function List:push(item)
   table.insert(self.items, item)
end

-- Remove from end
function List:pop()
   return table.remove(self.items)
end

-- Add to beginning
function List:unshift(item)
   table.insert(self.items, item, 1)
end

-- Remove from beginning
function List:shift()
   return table.remove(self.items, 1)
end

----------------------------------------

function List:push_all(items)
   if items.class == List then items = items.items end
   for _, v in ipairs(items) do table.insert(self.items, v) end
end

function List:unshift_all(items)
   if items.class == List then items = items.items end
   for _, v in ipairs(items) do table.insert(self.items, v, 1) end
end

----------------------------------------

function List:length()
   return #(self.items)
end

function List:at(i, v)
   if v then self.items[i] = v end
   return self.items[i]
end
List.__call = List.at

function List:clear()
   self.items = {}
end

function List:empty()
   return #(self.items) == 0
end

function List:random()
   if self:empty() then return nil
   else return self.items[math.random(#self.items)] end
end

----------------------------------------

function List:map(fn, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      result:push( fn(item, ...) )
   end

   return result
end

function List:method_map(fn_name, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      local fn = item[fn_name]
      result:push( fn(item, ...) )
   end

   return result
end

function List:select(fn, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      if fn(item, ...) then result:push( item ) end
   end

   return result
end

function List:method_select(fn_name, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      local fn = item[fn_name]
      if fn(item, ...) then result:push( item ) end
   end

   return result
end