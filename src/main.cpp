#include "main.h"



SteamClient client(
	// write callback
	[](std::size_t length, std::function<void(unsigned char* buffer)> fill) {
		auto write = new uv_write_t;
		// TODO: check if previous write has finished
		write_buffer.resize(length);
		fill(reinterpret_cast<unsigned char*>(&write_buffer[0]));
		auto buf = uv_buf_init(&write_buffer[0], write_buffer.size());
		uv_write(write, (uv_stream_t*)&sock, &buf, 1, [](uv_write_t* req, int status) {
			delete req;
		});
	},
	// set_inverval callback
	[](std::function<void()> callback, int timeout) {
		auto callback_heap = new std::function<void()>(std::move(callback));
		timer.data = callback_heap;
		uv_timer_start(&timer, [](uv_timer_t* handle) {
			auto callback = reinterpret_cast<std::function<void()>*>(handle->data);
			(*callback)();
			// TODO: delete it somewhere
		}, timeout * 1000, timeout * 1000);
	}
);


void lua_error_fatal(lua_State *L, int status)
{
	if ( status!=0 ) {
		std::cerr << "ERR: " << lua_tostring(L, -1) << std::endl;
		lua_pop(L, 1);
		lua_close(L);
		exit(33);
	}
}



int main() {
	uv_tcp_init(uv_default_loop(), &sock);
	uv_timer_init(uv_default_loop(), &timer);
	state.doFile("lua/main.lua");

	
	//L = luaL_newstate();
	//luaL_openlibs(L);
	//
    //
	//int s = luaL_loadfile(L, "lua/main.lua");
	//if (s==0) {
	//	s = lua_pcall(L, 0, 0, 0);
    //}
	//lua_error_fatal(L, s);

	auto &endpoint = servers[rand() % (sizeof(servers) / sizeof(servers[0]))];
	auto connect = new uv_connect_t;
	sockaddr_in addr;
	uv_ip4_addr(endpoint.host, endpoint.port, &addr);
	
	uv_tcp_connect(connect, &sock, (sockaddr*)&addr, [](uv_connect_t* req, int status) {
		auto length = client.connected();
		read_buffer.resize(length);
		uv_read_start(req->handle, [](uv_handle_t* handle, size_t suggested_size, uv_buf_t* buf) {
			*buf = uv_buf_init(&read_buffer[read_offset], read_buffer.size() - read_offset);
		}, [](uv_stream_t* stream, ssize_t nread, const uv_buf_t* buf) {
			if (nread < 1) {
				//auto str = 
				uv_strerror(nread);
			}
			read_offset += nread;
			if (read_offset == read_buffer.size()) {
				auto next_length = client.readable(reinterpret_cast<unsigned char*>(&read_buffer[0]));
				read_offset = 0;
				read_buffer.resize(next_length);
			}
		});
		delete req;
	});
	
	client.onHandshake = [] {		
		state["onHandshake"]();
	};
	
	client.onLogOn = [](EResult result, SteamID steamID) {
		std::string str = std::to_string(steamID.steamID64);
		state["onLogOn"]((unsigned int)result,str.c_str());
	};
	
	client.onLogOff = [](EResult result) {
		state["onLogOff"]((unsigned int)result);
	};
	
	client.onUserInfo = [](			
		SteamID 			user,
		SteamID* 			source,
		const char* 		name,
		EPersonaState* 		pstate,
		const unsigned char avatar_hash[20],
		const char* 		game_name
	)
	{
		std::string str_user = std::to_string(user.steamID64);
		std::string str_source = std::to_string(source->steamID64);
		
		std::ostringstream ss;
		ss << std::hex << std::setfill('0');
		for (auto i = 0; i < 20; i++)
			ss << std::setw(2) << static_cast<unsigned>(avatar_hash[i]);
		std::string avatar_hex = ss.str();
		
		state["onUserInfo"](
			str_user.c_str(),
			str_source.c_str(),
			name?name:"",
			static_cast<unsigned int>(*pstate),
			avatar_hex.c_str(),
			game_name?game_name:""
		);
	};

	client.onTyping = [](SteamID user) {
		std::string str_user = std::to_string(user.steamID64);
		state["onTyping"](str_user.c_str());
	};
	
	client.onPrivateMsg = [](SteamID user, const char* message) {
		std::string str_user = std::to_string(user.steamID64);
		state["onPrivateMsg"](str_user.c_str(),message);
	};
	
	client.onSentry = [](const unsigned char sentryhash[20]) {
		std::string str((const char *)(&sentryhash),20);
		std::cout << "Sentry Hash ("<< str.length();
		
		std::cout << "): " << bin2hex(str) << std::endl;

		state["onSentry"](&str);
	};
	
	client.onChatMsg = [](SteamID room, SteamID chatter, std::string message) {
		std::string str_room 	= std::to_string(room.steamID64);
		std::string str_chatter = std::to_string(chatter.steamID64);
		state["onChatMsg"](str_room.c_str(),str_chatter.c_str(),message.c_str());
	};
	
	int ret = uv_run(uv_default_loop(), uv_run_mode::UV_RUN_DEFAULT);
	//lua_close(L);
	return ret;
}

			
			
extern "C" {
	LUA_EXPORT void steam_SetPersonaState(EPersonaState state)
	{
		client.SetPersonaState(state);
	}
	
	LUA_EXPORT void steam_JoinChat(const char * pchSteamID)
	{
		
		if (!pchSteamID) return;
		
		uint64_t steamid64 = _atoi64( pchSteamID );
		if (steamid64==0) return;
		
		SteamID steamID(steamid64);
		client.JoinChat(steamID);
	}
	
	LUA_EXPORT void steam_SendChatMessage(const char * room,const char * message)
	{
		if (!room || !message) return;
		
		uint64_t steamid64 = _atoi64( room );
		if (steamid64==0) return;
		
		SteamID steamID(steamid64);
		
		client.SendChatMessage(steamID,message);
		
	}
	LUA_EXPORT void steam_LogOn(const char * user,const char * pass,const unsigned char * sentry,const char * authcode)
	{
		
		client.LogOn(user,pass, sentry, authcode);
	}
}
