//
// This source file part of https://github.com/kphrx/swift-localized-string.git
//
// BundleExtensionTests.swift
//
// Copyright 2025 kPherox
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Testing

import class Foundation.Bundle
import struct Foundation.Locale

@testable import SwiftLocalizedString

struct PreferredLocalizationsTests {
  @Test func testHasFallbackLocalizations() throws {
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en_gb", "en"], forPreferences: ["en", "ja_jp", "en_gb"])
        == [
          "en"
        ])
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en_gb", "en"], forPreferences: ["en_001", "ja_jp", "en_gb"])
        == ["en"])
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en", "en_gb"], forPreferences: ["en_gb", "ja_jp"]) == [
          "en_gb", "en",
        ])
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en", "en_gb"], forPreferences: ["en_gb", "ja_jp", "en"])
        == [
          "en_gb", "en",
        ])
  }

  @Test func testSpecificRegionLocalizations() throws {
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en_gb"], forPreferences: ["en", "ja_jp", "en_gb"]) == [
          "en_gb"
        ])
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en_gb"], forPreferences: ["en_001", "ja_jp", "en_gb"]) == [
          "en_gb"
        ])
  }

  @Test func testFallbackRegionLocalizations() throws {
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en_gb"], forPreferences: ["en", "ja_jp"]) == ["en_us"])
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_us", "en_gb"], forPreferences: ["en_001", "ja_jp"]) == ["en_us"])
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_gb", "en_us"], forPreferences: ["en_001", "ja_jp"]) == ["en_gb"])
  }

  #if canImport(Darwin)
  @Test
  #else
  @Test(.disabled("Always failed in OSS Swift"))
  #endif
  func testFallbackPriorityRegionLocalizations() throws {
    #expect(
      preferredLocalizations(
        from: ["ja", "ja-jp", "en_gb", "en_us"], forPreferences: ["en", "ja_jp"]) == ["en_us"])
  }
}

struct BundleExtensionTests {
  @Test func testLocalizedStringWithLocale() throws {
    #expect(
      Bundle.module.localizedString(
        forKey: "color", value: "Default value of color", table: nil,
        locale: Locale(identifier: "en_GB")) == "Colour")
    #expect(
      Bundle.module.localizedString(
        forKey: "color", value: "Default value of color", table: nil,
        locale: Locale(identifier: "en_US")) == "Color")
  }
}
