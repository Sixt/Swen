#!/bin/sh

fastlane ios tests
pod lib lint --quick
