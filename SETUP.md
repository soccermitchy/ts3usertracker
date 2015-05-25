# Setup
This is how to setup the TS3 User Tracker. This assumes you have a PostgreSQL database set up already and know the TS query info for the server

## 1. Install dependencies
`luarocks install lapis` - Lapis is the web framework used for all of the web-based stuff and database stuff.
`luarocks install lua-messagepack` - Used to transfer data between non-web stuff and the database.

## 2. Configure
`cp config.lua.example config.lua`
`$EDITOR config.lua`

## 3. Run lapis web server
It is suggested to do this in screen, tmux, or similar.
`lapis server`

## 4. Configure cron job
Add this to your crontab using `crontab -e`
`* * * * * cd USERTRACKER_DIR && lapis exec "IN_LAPIS=true dofile'cron.lua'" > error.txt`
This makes the script run once a minute.
