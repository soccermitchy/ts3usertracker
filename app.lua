local lapis = require("lapis")
local Model = require("lapis.db.model").Model
local app = lapis.Application()

local Track = Model:extend("track",{primary_key='track_num'})
local Clients = Model:extend("clients",{primary_key='id'})
app:enable('etlua')
app.layout = require'views.layout'
app:get("/", function()
	return {render="list"}
end)

app:get("/cron", function()
	f=io.open('data.mp')
	if not f then return 'Nothing to import' end
	data=require'MessagePack'.unpack(f:read'*a')
	f:close()
	os.remove('data.mp')
	for _,user in pairs(data) do
		local userinstance = Clients:find({clientid = user.id}) 
		if userinstance then
			userinstance.clientname = user.name
			userinstance:update("clientname")
		else
			Clients:create({
				clientid = user.id,
				clientname = user.name
			})
		end
		Track:create({
			clientid = user.id
		})
	end
	return'done'
end)
return app
