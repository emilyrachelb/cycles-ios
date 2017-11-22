#!/bin/bash

# development
openssl aes-256-cbc -k "$SECURITY_PASSWORD" -in scripts/certs/development-cert.cer.enc -d -a -out scripts/certs/development-cert.certs
openssl aes-256-cbc -k "$SECURITY_PASSWORD" -in scripts/certs/development-key.p12.enc -d -a -out scripts/certs/development-key.p12
openssl aes-256-cbc -k "$SECURITY_PASSWORD" -in scripts/certs/cycles-ios.mobileprovision.enc -d -a -out scripts/certs/cycles-ios.mobileprovision

# create custom keychain
security create-keychain -p $KEYCHAIN_PASSWORD ios-build.keychain

# make ios-build.keychain default, so xcodebuild will use it
security default-keychain -s ios-build.keychain

# unlock the keychain
security unlock-keychain -p $KEYCHAIN_PASSWORD ios-build.keychain

# set keychain timeout to 1 hour for long builds
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

security import ./scripts/certs/AppleWWDRCA.cer -k ios-build.keychain -A
security import ./scripts/certs/development-key.p12 -k ios-build.keychain -A
security import ./scripts/certs/development-cert.cer -k ios-build.keychain -A

# fix for os x sierra that hangs in the codesign step
security set-key-partition-list -S apple-tool:,apple: -s -k $SECURITY_PASSWORD ios-build.keychain > /dev/null

# install provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles/

cp "./scripts/provisioning-profile/cycles-ios.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
