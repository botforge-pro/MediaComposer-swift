SWIFT_SOURCES = Sources Tests Package.swift
SCHEME = MediaComposer
SIMULATOR ?= $(shell xcrun simctl list devices available -j | python3 -c \
	"import json,sys; print(sorted(d['name'] for v in json.load(sys.stdin)['devices'].values() for d in v if 'iPhone' in d['name'])[-1])")
SIMULATOR_DESTINATION = platform=iOS Simulator,name=$(SIMULATOR)
VERSION = $(shell sed -n 's/^\#\# \[\([0-9.]*\)\].*/\1/p' CHANGELOG.md | head -1)

.DEFAULT_GOAL := build

.PHONY: install-tools format comments lint test-build test device-test build docs release clean i18n-extract i18n-apply

install-tools:
	brew install swiftlint pipx
	pipx install --force git+https://github.com/botforge-pro/commentcensor.git
	pipx install --force git+https://github.com/botforge-pro/ios-i18n-sync.git

format:
	xcrun swift-format format --in-place --recursive $(SWIFT_SOURCES)

comments:
	commentcensor .

lint: comments
	xcrun swift-format lint --strict --recursive $(SWIFT_SOURCES)
	swiftlint --strict

test-build:
	xcodebuild build-for-testing -quiet -scheme $(SCHEME) -destination '$(SIMULATOR_DESTINATION)'

test: test-build

device-test: test-build
	xcodebuild test-without-building -quiet -scheme $(SCHEME) -destination '$(SIMULATOR_DESTINATION)' \
		-parallel-testing-enabled NO $(if $(TEST),-only-testing:'$(TEST)',)

build:
	xcodebuild build -quiet -scheme $(SCHEME) -destination 'generic/platform=iOS' -skipPackagePluginValidation

docs:
	xcodebuild docbuild -scheme $(SCHEME) \
		-destination 'generic/platform=iOS' \
		-derivedDataPath .build/docc-derived \
		OTHER_DOCC_FLAGS='--warnings-as-errors'
	xcrun docc process-archive transform-for-static-hosting \
		.build/docc-derived/Build/Products/Debug-iphoneos/MediaComposer.doccarchive \
		--output-path .build/docc \
		--hosting-base-path MediaComposer-swift

release: lint device-test build
	@test -z "$$(git status --porcelain)" || { echo "Commit first: the release is the tag on what is in git."; exit 1; }
	@git fetch -q origin main
	@test "$$(git rev-parse HEAD)" = "$$(git rev-parse origin/main)" || { echo "Release from main as pushed."; exit 1; }
	git tag -a '$(VERSION)' -m '$(VERSION)'
	git push origin '$(VERSION)'
	awk '/^## \[$(VERSION)\]/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | gh release create '$(VERSION)' --title '$(VERSION)' --notes-file -

clean:
	swift package clean

# Localization workflow:
# 1. Add new key to Sources/MediaComposer/Resources/en.lproj/Localizable.strings (English only)
# 2. Run 'make i18n-extract' to generate translation.yaml with all language keys
# 3. Edit translations.yaml to add translations for all languages
# 4. Run 'make i18n-apply' to apply translations to all .lproj files

i18n-extract:
	@echo "Extracting translations to YAML..."
	@i18n-sync extract --resources Sources/MediaComposer/Resources

i18n-apply:
	@echo "Applying translations from YAML..."
	@i18n-sync apply --resources Sources/MediaComposer/Resources
	@rm -f translations.yaml
	@echo "Removed temporary translations.yaml"
