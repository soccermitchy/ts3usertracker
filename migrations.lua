local schema = require'lapis.db.schema'
local types  = schema.types
local db = require'lapis.db'
return {
	[1] = function()
		schema.create_table("track",{})
		schema.add_column("track","track_num",types.serial{primary_key=true})
		schema.add_column("track","timestamp","bigint NOT NULL DEFAULT extract(epoch from now())::bigint")
		schema.add_column("track","clientid","smallint NOT NULL DEFAULT 0")
		schema.add_column("track","clientname","character varying(30) NOT NULL")
	end,
	[2] = function()
		db.query([[
			CREATE OR REPLACE VIEW "public"."view_track" AS SELECT DISTINCT ON (track.clientname) track.clientname,
				count(track.clientname) AS count
			   FROM track
			  GROUP BY track.clientname
		]])
	end
}