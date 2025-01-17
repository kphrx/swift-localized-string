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

import struct Foundation.Decimal
import struct Foundation.Locale

@testable import SwiftLocalizedString

struct StringExtensionTests {
  @Suite(
    .disabled(if: Locale.current.identifier == "en_GB", "If current locale en_GB, always failed"))
  struct StringLocalizedLocalizationValue {
    @Test func testLocalizedStringLiteral() throws {
      #expect(String(localized: "color", bundle: .module) == "Color")
    }

    @Test func testLocalizedStringInterpolation() throws {
      let nbsp: (normal: String, narrow: String) = ("\u{a0}", "\u{202f}")
      #if swift(>=6.1) || canImport(Darwin)
      if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
        #expect(
          String(
            localized:
              "%@ decimal: \(Decimal(0.6), format: .percent), string: \("text"), 64bit unsigned integer: \(UInt64.max), 64bit integer: \(Int64.min), double: \(Double(42.195)), 32bit unsigned integer: \(UInt32.max), 32bit integer: \(Int32.min), float: \(Float(3.14))",
            bundle: .module, locale: Locale(identifier: "fr_FR"))
            == "64bit unsigned integer: 18\(nbsp.narrow)446\(nbsp.narrow)744\(nbsp.narrow)073\(nbsp.narrow)709\(nbsp.narrow)551\(nbsp.narrow)615, 32bit unsigned integer: 4\(nbsp.narrow)294\(nbsp.narrow)967\(nbsp.narrow)295, 64bit integer: -9\(nbsp.narrow)223\(nbsp.narrow)372\(nbsp.narrow)036\(nbsp.narrow)854\(nbsp.narrow)775\(nbsp.narrow)808, 32bit integer: -2\(nbsp.narrow)147\(nbsp.narrow)483\(nbsp.narrow)648, double: 42,195000, float: 3,140000, decimal: 60\(nbsp.normal)%, text"
        )
      } else {
        #expect(
          String(
            localized:
              "%@ decimal: \(Decimal(0.6), format: .percent), string: \("text"), 64bit unsigned integer: \(UInt64.max), 64bit integer: \(Int64.min), double: \(Double(42.195)), 32bit unsigned integer: \(UInt32.max), 32bit integer: \(Int32.min), float: \(Float(3.14))",
            bundle: .module, locale: Locale(identifier: "fr_FR"))
            == "64bit unsigned integer: -1, 32bit unsigned integer: -1, 64bit integer: -9\(nbsp.narrow)223\(nbsp.narrow)372\(nbsp.narrow)036\(nbsp.narrow)854\(nbsp.narrow)775\(nbsp.narrow)808, 32bit integer: -2\(nbsp.narrow)147\(nbsp.narrow)483\(nbsp.narrow)648, double: 42,195000, float: 3,140000, decimal: 60\(nbsp.normal)%, text"
        )
      }
      #else
      #expect(
        String(
          localized:
            "%@ decimal: \(Decimal(0.6), format: .percent), string: \("text"), 64bit unsigned integer: \(UInt64.max), 64bit integer: \(Int64.min), double: \(Double(42.195)), 32bit unsigned integer: \(UInt32.max), 32bit integer: \(Int32.min), float: \(Float(3.14))",
          bundle: .module, locale: Locale(identifier: "fr_FR"))
          == "64bit unsigned integer: -1, 32bit unsigned integer: -1, 64bit integer: -9\(nbsp.narrow)223\(nbsp.narrow)372\(nbsp.narrow)036\(nbsp.narrow)854\(nbsp.narrow)775\(nbsp.narrow)808, 32bit integer: -2\(nbsp.narrow)147\(nbsp.narrow)483\(nbsp.narrow)648, double: 42,195000, float: 3,140000, decimal: 60\(nbsp.normal)%, text"
      )
      #endif
    }
  }
}
