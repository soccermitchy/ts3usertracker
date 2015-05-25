local schema = require'lapis.db.schema'
local types  = schema.types

return {
	[1] = function()
		schema.create_table("track",{})
		schema.add_column("track","track_num",types.serial{primary_key=true})
		schema.add_column("track","timestamp","bigint NOT NULL DEFAULT extract(epoch from now())::bigint")
		schema.add_column("track","clientid","smallint NOT NULL DEFAULT 0")
		schema.add_column("track","clientname","character varying(30) NOT NULL")
	end
}