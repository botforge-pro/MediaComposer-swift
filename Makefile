.PHONY: build clean i18n-extract i18n-apply

build:
	xcodebuild build -scheme MediaComposer -destination 'generic/platform=iOS' -skipPackagePluginValidation 2>&1 | tail -20

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
