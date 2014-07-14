all:
	./premake5 --os=linux gmake
	make -C builds/linux-gmake
clean:
	make -C builds/linux-gmake clean
release:
	make -C builds/linux-gmake release

run:
	cd bin; ./feidi
