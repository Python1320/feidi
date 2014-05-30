all:
	./premake5 --os=linux gmake
	make -C builds/linux-gmake
