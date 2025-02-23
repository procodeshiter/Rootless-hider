ARCHS := arm64 
TARGET := iphone:clang:14.5
INSTALL_TARGET_PROCESSES := XXTAssistiveTouch
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = XXTAssistiveTouch

XXTAssistiveTouch_USE_MODULES := 0
XXTAssistiveTouch_FILES += $(wildcard *.mm)
XXTAssistiveTouch_CFLAGS += -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-module-import-in-extern-c
XXTAssistiveTouch_CFLAGS += -Iinclude
XXTAssistiveTouch_CFLAGS += -include hud-prefix.pch
XXTAssistiveTouch_CCFLAGS += -std=c++14 -fno-rtti -fno-exceptions -DNDEBUG
XXTAssistiveTouch_CCFLAGS += -DNOTIFY_LAUNCHED_HUD=\"ch.xxtou.notification.launched.hud\"
XXTAssistiveTouch_CCFLAGS += -DNOTIFY_DISMISSAL_HUD=\"ch.xxtou.notification.dismissal.hud\"
XXTAssistiveTouch_FRAMEWORKS += CoreGraphics QuartzCore UIKit
XXTAssistiveTouch_PRIVATE_FRAMEWORKS += AppSupport BackBoardServices GraphicsServices IOKit SpringBoardServices
ifeq ($(TARGET_CODESIGN),ldid)
XXTAssistiveTouch_CODESIGN_FLAGS += -Sent.plist
else
XXTAssistiveTouch_CODESIGN_FLAGS += --entitlements ent.plist $(TARGET_CODESIGN_FLAGS)
endif

# Добавление скриптов
XXTAssistiveTouch_EXTRA_FILES = DEBIAN/postinst DEBIAN/preinst

include $(THEOS_MAKE_PATH)/application.mk

after-stage::
		@echo "Running after-stage commands"
	$(ECHO_NOTHING)mkdir -p packages $(THEOS_STAGING_DIR)/Payload$(ECHO_END)
	$(ECHO_NOTHING)cp -rp $(THEOS_STAGING_DIR)/Applications/XXTAssistiveTouch.app $(THEOS_STAGING_DIR)/Payload$(ECHO_END)
	
	$(ECHO_NOTHING)cd $(THEOS_STAGING_DIR); zip -qr TrollSpeed_${GIT_TAG_SHORT}.tipa Payload; cd -;$(ECHO_END)
	$(ECHO_NOTHING)mv $(THEOS_STAGING_DIR)/TrollSpeed_${GIT_TAG_SHORT}.tipa packages/TrollSpeed_${GIT_TAG_SHORT}.tipa $(ECHO_END)
