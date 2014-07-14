
local file = assert(loadfile("config.lua"))
local CFG={}
_G.CFG=CFG
setfenv(file,CFG)
file(CFG)

ffi = require("ffi")


local C = ffi.C

--ffi.cdef(io.open('steam_language.h', 'r'):read('*all'))

local EResult={
[0]="Invalid",
"OK",
"Fail",
"NoConnection",
"WTF",
"InvalidPassword",
"LoggedInElsewhere",
"InvalidProtocolVer",
"InvalidParam",
"FileNotFound",
"Busy",
"InvalidState",
"InvalidName",
"InvalidEmail",
"DuplicateName",
"AccessDenied",
"Timeout",
"Banned",
"AccountNotFound",
"InvalidSteamID",
"ServiceUnavailable",
"NotLoggedOn",
"Pending",
"EncryptionFailure",
"InsufficientPrivilege",
"LimitExceeded",
"Revoked",
"Expired",
"AlreadyRedeemed",
"DuplicateRequest",
"AlreadyOwned",
"IPNotFound",
"PersistFailed",
"LockingFailed",
"LogonSessionReplaced",
"ConnectFailed",
"HandshakeFailed",
"IOFailure",
"RemoteDisconnect",
"ShoppingCartNotFound",
"Blocked",
"Ignored",
"NoMatch",
"AccountDisabled",
"ServiceReadOnly",
"AccountNotFeatured",
"AdministratorOK",
"ContentVersion",
"TryAnotherCM",
"PasswordRequiredToKickSession",
"AlreadyLoggedInElsewhere",
"Suspended",
"Cancelled",
"DataCorruption",
"DiskFull",
"RemoteCallFailed",
"PasswordNotSet",
"PSNAccountNotLinked",
"InvalidPSNTicket",
"PSNAccountAlreadyLinked",
"RemoteFileConflict",
"IllegalPassword",
"SameAsPreviousValue",
"AccountLogonDenied",
"CannotUseOldPassword",
"InvalidLoginAuthCode",
"AccountLogonDeniedNoMailSent",
"HardwareNotCapableOfIPT",
"IPTInitError",
"ParentalControlRestricted",
"FacebookQueryError",
"ExpiredLoginAuthCode",
"IPLoginRestrictionFailed",
"AccountLocked",
"AccountLogonDeniedVerifiedEmailRequired",
"NoMatchingURL",
"BadResponse",
"RequirePasswordReEntry",
}
_G.EResult=EResult


local mt={
	__index=function(self,what) 
		if what=="typedef" then
			local ret={
				"",
				"typedef enum {\n"
			}
			for k,v in next,self do
				local str=string.format("\tEResult_%s = %d,",v,k)
				table.insert(ret,str)
			end
			table.insert(ret,"\n} EResult;\n")
			return table.concat(ret,"\n")
		end
		for k,v in next,self do
			if what==v then return k end
		end
	end
}
setmetatable(EResult,mt)

local EMsg={}
_G.EMsg=EMsg
for line in io.lines"SteamKit/Resources/SteamLanguage/emsg.steamd" do
	local name,value = line:match[[([^%s]+) = (%d+)]]
	value=value and tonumber(value)
	if value then
		EMsg[value]=name
	end
end

local extra=[[  
	typedef enum {
		Offline = 0,
		Online = 1,
		Busy = 2,
		Away = 3,
		Snooze = 4,
		LookingToTrade = 5,
		LookingToPlay = 6,
		Max = 7,
	} EPersonaState;
	
	
	]]..EResult.typedef..[[
       

	
]]

local defs={extra}
local started
local function procline(line)
	if not started and line:find("STARTLUAEXPORTS",1,true) then
		started = true
		return
	elseif started and line:find("ENDLUAEXPORTS",1,true) then
		started = false
		return
	end
	if started or line:find("LUA_EXPORT",1,true) and not line:find("#define",1,true) then
		local def = line:gsub("LUA_EXPORT","")
		if not def:find";" then def=def..';' end
		table.insert(defs,def)
	end
end

for line in io.lines("bindings.h") do procline(line) end

local str = table.concat(defs,"\n")
local ok,err = pcall(ffi.cdef,str)
if not ok then
	print(err)
	local i=1 print(" 1 "..str:gsub("[\n]",function() i=i+1 return string.format("\n%2d ",i) end))
	error("binding failed")
end






--------------


-- http://snippets.luacode.org/snippets/String_to_Hex_String_68
function HexDumpString(str,spacer)
return (
string.gsub(str,"(.)",
function (c)
return string.format("%02X%s",string.byte(c), spacer or "")
end)
)
end
