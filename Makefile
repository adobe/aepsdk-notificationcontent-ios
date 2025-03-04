export EXTENSION_NAME = AEPNotificationContent
export APP_NAME = DemoApp
CURRENT_DIRECTORY := ${CURDIR}
PROJECT_NAME = $(EXTENSION_NAME)
TARGET_NAME_XCFRAMEWORK = $(EXTENSION_NAME).xcframework
SCHEME_NAME_XCFRAMEWORK = AEPNotificationContentXCF

SIMULATOR_ARCHIVE_PATH = $(CURRENT_DIRECTORY)/build/ios_simulator.xcarchive/Products/Library/Frameworks/
SIMULATOR_ARCHIVE_DSYM_PATH = $(CURRENT_DIRECTORY)/build/ios_simulator.xcarchive/dSYMs/
IOS_ARCHIVE_PATH = $(CURRENT_DIRECTORY)/build/ios.xcarchive/Products/Library/Frameworks/
IOS_ARCHIVE_DSYM_PATH = $(CURRENT_DIRECTORY)/build/ios.xcarchive/dSYMs/

# CI variables with defaults. Update the defaults for local development as needed.
IOS_DEVICE_NAME ?= iPhone 15
# If OS version is not specified, uses the first device name match in the list of available simulators
IOS_VERSION ?= 
ifeq ($(strip $(IOS_VERSION)),)
    IOS_DESTINATION = "platform=iOS Simulator,name=$(IOS_DEVICE_NAME)"
else
    IOS_DESTINATION = "platform=iOS Simulator,name=$(IOS_DEVICE_NAME),OS=$(IOS_VERSION)"
endif

setup:
	(pod install)
	(cd TestApps/$(APP_NAME) && pod install)

setup-tools: install-githook

clean:
	(rm -rf build)

build:
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination="iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios_simulator.xcarchive" -sdk iphonesimulator -destination="iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

zip:
	cd build && zip -r -X $(PROJECT_NAME).xcframework.zip $(PROJECT_NAME).xcframework/
	swift package compute-checksum build/$(PROJECT_NAME).xcframework.zip

test: clean unit-test

# CI alias for unit-test
unit-test-ios: clean unit-test

unit-test: 
	@echo "######################################################################"
	@echo "### Unit Testing"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme "UnitTests" -destination $(IOS_DESTINATION) -derivedDataPath build/out -resultBundlePath build/$(PROJECT_NAME).xcresult -enableCodeCoverage YES

pod-install:
	(pod install --repo-update)
	(cd TestApps/$(APP_NAME) && pod install --repo-update)

ci-pod-install:
	(bundle exec pod install --repo-update)
	(cd TestApps/$(APP_NAME) && bundle exec pod install --repo-update)

archive: pod-install _archive

ci-archive: ci-pod-install _archive

_archive: clean build
	xcodebuild -create-xcframework \
		-framework $(SIMULATOR_ARCHIVE_PATH)$(EXTENSION_NAME).framework -debug-symbols $(SIMULATOR_ARCHIVE_DSYM_PATH)$(EXTENSION_NAME).framework.dSYM \
		-framework $(IOS_ARCHIVE_PATH)$(EXTENSION_NAME).framework -debug-symbols $(IOS_ARCHIVE_DSYM_PATH)$(EXTENSION_NAME).framework.dSYM \
		-output ./build/$(TARGET_NAME_XCFRAMEWORK)

format: lint-autocorrect swift-format

check-format:
	(swiftformat --lint $(PROJECT_NAME)/Sources --swiftversion 5.1)

install-swiftformat:
	(brew install swiftformat)

swift-format:
	(swiftformat $(PROJECT_NAME)/Sources --swiftversion 5.1)

lint-autocorrect:
	($(CURRENT_DIRECTORY)/Pods/SwiftLint/swiftlint --fix)

lint: swift-lint check-format

swift-lint:
	(./Pods/SwiftLint/swiftlint lint $(PROJECT_NAME)/Sources)

test-SPM-integration:
	(sh ./Script/test-SPM.sh)

test-podspec:
	(sh ./Script/test-podspec.sh)