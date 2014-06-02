-- http://industriousone.com/scripting-reference --
-- https://bitbucket.org/premake/premake-dev/wiki --


solution"feidi"
	
	configurations { "debug", "release" }

	flags { 
		--"FatalWarnings", 
		--"Unicode" 
	}
	location("builds/" .. os.get() .. "-" .. _ACTION)
	
	warnings "Extra"
	floatingpoint "Fast"
	vectorextensions "SSE2"

	targetdir "bin"
	
	project "feidi"
		kind "ConsoleApp"
		language "C++"
		buildoptions { "-std=gnu++0x -fpermissive -Wno-unused-parameter" }
		linkoptions { "-rdynamic" }
		
		files { "src/**.cpp", "src/**.hpp", "src/**.c", "src/**.h" }
		includedirs { 
			"src",
			"../luajit-2.0/src/",
			"../libuv/include/",
			"../SteamPP/",
			"luastate/include",
		}
		libdirs { 
			"../luajit-2.0/src/",
			"../libuv/out/Release/",
			"../SteamPP/",
			}

		links {
			"luajit",

			"uv",
			"steam++",
			
			"protobuf", 
			"archive", 
			"cryptopp",
			
				
			"rt",
			"m",
			"dl",
			}

		configuration "debug"
			defines { "DEBUG" }
			flags { "Symbols" }
			optimize "Off"

		configuration "release"
			defines { "NDEBUG" }
			optimize "On"
			
