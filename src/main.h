#include <iostream>
#include <functional>
#include <algorithm>
#include <iterator>
#include <sstream>
#include <iomanip>
#include <string>
#include <uv.h>
#include "steam++.h"
#include <cstdint>

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
	#include <lualib.h>
}
#include <LuaState.h>

#include <stdlib.h>
#ifndef _WIN32
        #define _atoi64(S)  atoll(S)
#endif


  
using namespace Steam;

lua::State state;

uv_tcp_t sock;
uv_timer_t timer;

std::string read_buffer;
std::string write_buffer;

std::string::size_type read_offset = 0;

lua_State *L;


extern SteamClient client;

#define LUA_EXPORT __attribute__ ((visibility ("default")))


// --------------


std::string bin2hex(const std::string& input)
{
	std::string res;
	const char hex[] = "0123456789ABCDEF";
	bool first = true;
	for(auto sc : input)
	{
		if (first) { first = false; } else { res+=" ";};
		unsigned char c = static_cast<unsigned char>(sc);
		res += hex[c >> 4];
		res += hex[c & 0xf];
	}

    return res;
}

