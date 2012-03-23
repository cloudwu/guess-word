--[[
-- gen word list from wordlist.src to wordlist.txt

wordlist = {}
f = io.open "wordlist.src"
for v in f:lines() do
	local w,_
	_,_,w = string.find(v,"(%w+)")
	w = string.lower(w)
	if #w > 2 and #w < 9  then
		wordlist[w] = true
	end
end
f:close()

wl = {}
for k in pairs(wordlist) do
	table.insert(wl,k)
end

table.sort(wl)

f = io.open("wordlist.txt","w")

for _,v in ipairs(wl) do
	f:write(v .. "\n")
end

f:close()
]]


local function sortstring(str)
	local c = { string.byte(str,1,#str) }
	table.sort(c)
	return string.char(unpack(c))
end

local wordlist = {}
f = assert(io.open "wordlist.txt")
for v in f:lines() do
	local s = sortstring(v)
	local wl = wordlist[s]
	if wl == nil then
		wl = {}
		wordlist[s] = wl
	end
	table.insert(wl , v)
end

local set = { string.byte(string.lower(arg[1]),1,#arg[1]) }
table.sort(set)
local count = tonumber(arg[2])

local function genword( result , charset , tail , count )
	if count == 0 then
		coroutine.yield()
		return
	end
	if tail == count then
		for i = #charset - tail + 1 , #charset do
			table.insert(result, charset[i])
		end
		coroutine.yield()
		for i = #result - count + 1 , #result do
			result[i] = nil
		end
		return
	end
	genword(result , charset , tail-1 , count)
	table.insert(result, charset[#charset - tail + 1])
	genword(result , charset , tail-1 , count - 1)
	result[#result] = nil
end

local word = {}

local function allword( charset , count)
	local result = {}
	local routine = coroutine.create(function()
		genword(result , charset , #charset , count)
	end)
	while coroutine.resume(routine) do
		local temp = string.char(unpack(result))
		local list = wordlist[temp]
		if list then
			for _,v in ipairs(list) do
				if word[v] == nil then
					print(v)
					word[v] = true
				end
			end
		end
	end
end

allword(set,count)
