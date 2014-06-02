--print"helper"
dofile "lua/helper.lua"

function steam_handshake()
	
end

local C=require'ffi'.C
function onLogOff(result)
	print("onLogOff",result)
end

function onChatEnter(room,response,name,count,members)
	print("onChatEnter",room,response,name,count,members)
end

function onTyping(user)
	print("user",user)
end

function onPrivateMsg(user,message)
	print("onPrivateMsg",user,message)
end
function onChatMsg(room,chatter,message)
	print("onChatMsg",room,chatter,message)
	if room=="110338190873400656" and message=="ping" then
		print"sending pong"
		C.steam_SendChatMessage(room,"pong, "..tostring(chatter))
	end
end
function onLogOn(result,mysid)
	print("onLogOn",result,mysid) 
	if (result==tonumber(ffi.C.EResult_OK)) then
		C.steam_SetPersonaState(ffi.C.LookingToPlay)
		C.steam_JoinChat("103582791432344912")
	else
		error("Logon Failed: "..tostring(EResult[result]))
	end
end
function onUserInfo(user,
	                source,
	                name,
	                state,
	                avatar_hash,
	                game_name)
	print(	"onUserInfo",
			user,
			source,
			name,
			state,
			avatar_hash,
			game_name)
end
	

local SENTRY_HASH	
local f = io.open("sentry.bin",'rb')
if f then
	local hash = f:read"*all"
	f:close()
	SENTRY_HASH = hash
	print"Loaded sentry.bin"
else
	print"sentry.bin missing, steamguard incoming"
end

function onSentry(hash,len)
	print("Saving sentry hash",hash:len(),len,"'"..HexDumpString(hash, " ").."'") 
	SENTRY_HASH=hash
	local f = io.open("sentry.bin",'wb')
	f:write(hash)
	f:close()
end



function onHandshake(...) 
	print("onHandshake",...) 
	C.steam_LogOn(CFG.username,CFG.password,SENTRY_HASH,CFG.key)
end
