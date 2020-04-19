ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

SUBPROJECTS            += developer-cmds
DOWNLOAD               += https://opensource.apple.com/tarballs/developer_cmds/developer_cmds-$(DEVELOPER-CMDS_VERSION).tar.gz
DEVELOPER-CMDS_VERSION := 66
DEB_DEVELOPER-CMDS_V   ?= $(DEVELOPER-CMDS_VERSION)

developer-cmds-setup: setup
	$(call EXTRACT_TAR,developer_cmds-$(DEVELOPER-CMDS_VERSION).tar.gz,developer_cmds-$(DEVELOPER-CMDS_VERSION),developer-cmds)
	mkdir -p $(BUILD_STAGE)/developer-cmds/usr/bin
	mkdir -p $(BUILD_WORK)/developer-cmds/include
	cp -a $(BUILD_BASE)/usr/include/stdlib.h $(BUILD_WORK)/developer-cmds/include

ifneq ($(wildcard $(BUILD_WORK)/developer-cmds/.build_complete),)
developer-cmds:
	@echo "Using previously built developer-cmds."
else
developer-cmds: developer-cmds-setup
	cd $(BUILD_WORK)/developer-cmds; \
	for bin in ctags rpcgen unifdef; do \
    	$(CC) -arch $(ARCH) -isysroot $(SYSROOT) $($(PLATFORM)_VERSION_MIN) -isystem include -DPLATFORM_iPhoneOS -o $(BUILD_STAGE)/developer-cmds/usr/bin/$$bin $$bin/*.c -D_POSIX_C_SOURCE=200112L -DS_IREAD=S_IRUSR -DS_IWRITE=S_IWUSR; \
	done
	touch $(BUILD_WORK)/developer-cmds/.build_complete
endif

developer-cmds-package: developer-cmds-stage
	# developer-cmds.mk Package Structure
	rm -rf $(BUILD_DIST)/developer-cmds
	
	# developer-cmds.mk Prep developer-cmds
	cp -a $(BUILD_STAGE)/developer-cmds $(BUILD_DIST)

	# developer-cmds.mk Sign
	$(call SIGN,developer-cmds,general.xml)
	
	# developer-cmds.mk Make .debs
	$(call PACK,developer-cmds,DEB_DEVELOPER-CMDS_V)
	
	# developer-cmds.mk Build cleanup
	rm -rf $(BUILD_DIST)/developer-cmds

.PHONY: developer-cmds developer-cmds-package
