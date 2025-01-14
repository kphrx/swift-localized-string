//
// This source file part of https://github.com/kphrx/swift-localized-string.git
//
// StringExtensionTests.swift
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

import struct Foundation.Locale

@testable import SwiftLocalizedString

struct StringExtensionTests {
  @Test(
    .disabled(if: Locale.current.identifier == "en_GB", "If current locale en_GB, always failed"))
  func testLocalizedParameter() throws {
    #expect(String(localized: .init("color"), bundle: .module) == "Color")
  }
}
