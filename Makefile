.PHONY: build clean

build:
	xcodebuild build -scheme MediaComposer -destination 'generic/platform=iOS' -skipPackagePluginValidation 2>&1 | tail -20

clean:
	swift package clean
