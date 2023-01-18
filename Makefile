TARGET_CODESIGN = $(shell which ldid)

KnownNetworksTMP = $(TMPDIR)/KnownNetworks
KnownNetworks_STAGE_DIR = $(KnownNetworksTMP)/stage
KnownNetworks_APP_DIR 	= $(KnownNetworksTMP)/Build/Products/Release-iphoneos/Known\ Networks.app
GIT_REV=$(shell git rev-parse --short HEAD)

package:
	@set -o pipefail; \
	xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'Known Networks.xcodeproj' -scheme Known\ Networks -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(KnownNetworksTMP) \
	#CODE_SIGNING_ALLOWED=NO DSTROOT=$(KnownNetworksTMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	@rm -rf Payload
	@rm -rf $(KnownNetworks_STAGE_DIR)/
	@mkdir -p $(KnownNetworks_STAGE_DIR)/Payload
	@mv $(KnownNetworks_APP_DIR) $(KnownNetworks_STAGE_DIR)/Payload/Known\ Networks.app
	
	@echo $(KnownNetworksTMP)
	@echo $(KnownNetworks_STAGE_DIR)
	
	@$(TARGET_CODESIGN) -Sentitlements.xml $(KnownNetworks_STAGE_DIR)/Payload/Known\ Networks.app/
	
	@rm -rf $(KnownNetworks_STAGE_DIR)/Payload/KnownNetworks.app/_CodeSignature
	
	@ln -sf $(KnownNetworks_STAGE_DIR)/Payload Payload
	
	@rm -rf packages
	@mkdir -p packages
	
	@cp RootHelper Payload/Known\ Networks.app/
	@zip -r9 packages/KnownNetworks.ipa Payload
	
	@rm -rf Payload && mv packages/KnownNetworks.ipa KnownNetworks.tipa && rm -rf packages
