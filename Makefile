url_buildroot = https://buildroot.org/downloads/buildroot-2023.08.tar.gz
archive_buildroot = buildroot.tar.gz
board_defconfig = stm32f429_disco_xip_defconfig
dir_download = downloads
#dir_configs = configs
dir_output = output
dir_buildroot = buildroot

bootstrap:
	#mkdir -p $(dir_download)
	#mkdir -p $(dir_buildroot)
	#wget -O $(dir_download)/$(archive_buildroot) $(url_buildroot)
	#tar zxvf $(dir_download)/$(archive_buildroot) -C $(dir_buildroot) --strip-components=1

defconfig:
	make -C $(dir_buildroot) $(board_defconfig)

linux-clean:
	rm -f $(dir_buildroot)/dl/my-kernel.tar.gz
	rm -rf $(dir_buildroot)/dl/linux

	make -j`nproc` linux-dirclean -C $(dir_buildroot)

linux-tarball: linux-clean
	# make tarball
	tar -czf my-kernel.tar.gz -C linux/ --exclude=".git" .
	mkdir -p $(dir_buildroot)/dl/
	mv -f my-kernel.tar.gz $(dir_buildroot)/dl/

linux-build: linux-tarball
	make -j`nproc` linux-rebuild -C $(dir_buildroot) CONFIG_DEBUG_INFO=y

build: linux-tarball
	make -j`nproc` -C $(dir_buildroot)

flash:
	cd $(dir_buildroot) && board/stmicroelectronics/stm32f429-disco/flash.sh $(dir_output) stm32f429discovery

openocd:
	cd $(dir_buildroot)/output/build/host-openocd-0.12.0 && ./../../host/usr/bin/openocd -f board/stm32f429discovery.cfg -c "init" -c "reset init" 

gdb:
	cd $(dir_buildroot)/output/build/linux-custom/ && gdb-multiarch vmlinux

clean:
	#rm -rf $(dir_buildroot) $(dir_download)
