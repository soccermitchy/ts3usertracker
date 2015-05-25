if not IN_LAPIS then
	io.open'lapis exec "IN_LAPIS=true dofile\'cron.lua\'"'
	os.exit()
end
local config = require("lapis.config").get()
if not config.ts then						-- TODO: This but better.
	print("TS Server Query not configured.")
	os.exit(1)
end
if not config.ts.host then
	print("TS Query ts.host not configured.")
	os.exit(1)
end
if not config.ts.port then
	print("TS Query ts.port not configured.")
	os.exit(1)
end
if not config.ts.user then
	print("TS Query ts.user not configured.")
	os.exit(1)
end
if not config.ts.pass then
	print("TS Query ts.pass not configured.")
	os.exit(1)
end
if not config.ts.sid then
	print("TS Query ts.sid not configured.")
	os.exit(1)
end
function checkError(data)
	if not data:match('error id=0') then -- There was an error
		print('Error: '..data) -- Print out the whole line.
		os.exit(3)
	end
end
socket=require'socket'
function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
c=assert(socket.connect(config.ts.host,config.ts.port))
c:settimeout(15.0)
data=assert(c:receive'*l')
if not data=='TS3' then -- Not connected to a TeamSpeak server?
	print('Not connected to a TS server query server?')
	os.exit(2)
end
assert(c:receive'*l') -- We don't care about this line
c:send(("login %s %s\n"):format(config.ts.user,config.ts.pass))
data=assert(c:receive'*l')
checkError(data)
c:send(('use %s -virtual\n'):format(tostring(config.ts.sid)))
data=assert(c:receive'*l')
checkError(data)
c:send('clientlist\n')
data=assert(c:receive'*l')
if data:sub(1,5)=='error' then
	print('Error: '..data)
	os.exit(3)
end
local mp=require'MessagePack'
local topack={}
for _,user in pairs(split(data,'|')) do
	local userdata={}
	for k,v in user:gmatch("([^ ]+)=([^ ]+)") do
		userdata[k]=v:gsub("\\s"," "):gsub("\\p","\124"):gsub("\\a","\7")
		userdata[k]=userdata[k]:gsub("\\b","\8"):gsub("\\f","\8"):gsub("\\n","\10")
		userdata[k]=userdata[k]:gsub("\\r","\13"):gsub("\\t","\9"):gsub("\\v","\11")
	end
	if tonumber(userdata.client_type)==0 then
		table.insert(topack,{id=userdata.client_database_id,name=userdata.client_nickname})
	end
	userdata=nil
end
-- Pack the data to be read later
f=io.open("data.mp","w")
f:write(mp.pack(topack))
f:close()

local webcron=socket.connect('localhost',config.port)
webcron:send('GET /cron HTTP/1.1\nHost: localhost\nFrom: localhost\n')
webcron:send('User-Agent:cron\n')
webcron:send('\n\n')
webcron:close()
