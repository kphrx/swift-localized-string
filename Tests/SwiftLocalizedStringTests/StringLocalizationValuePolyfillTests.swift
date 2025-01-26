//
// This source file part of https://github.com/kphrx/swift-localized-string.git
//
// StringLocalizationValuePolyfillTests.swift
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

import struct Foundation.Date
import struct Foundation.Decimal
import class Foundation.JSONEncoder
import class Foundation.NSLocale

@testable import SwiftLocalizedString

struct StringLocalizationValuePolyfillTests {
  @Test func testStringInterpolationWithSubject() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let nsLocale = NSLocale(localeIdentifier: "en_US")
    let expected = """
      {"arguments":[{"string":{"_0":"\(nsLocale.description)"}}],"key":"%@"}
      """

    #expect(
      String(
        data: try encoder.encode("\(nsLocale)" as String.LocalizationValuePolyfill), encoding: .utf8
      ) == expected)
  }

  @Test func testStringInterpolationWithFormatStyle() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let nsLocale = NSLocale(localeIdentifier: "en_US")
    let expected = """
      {"arguments":[{"formattedDecimal":{"_0":0.6,"_1":{"format":{"percent":{"_0":\(String(data: try encoder.encode(Decimal.FormatStyle.Percent.percent), encoding: .utf8)!)}}}}},{"formattedDate":{"_0":-978307200,"_1":{"format":{"iso8601":{"_0":\(String(data: try encoder.encode(Date.ISO8601FormatStyle.iso8601), encoding: .utf8)!)}}}}}],"key":"decimal: %@, date: %@"}
      """

    #expect(
      String(
        data: try encoder.encode(
          "decimal: \(Decimal(0.6), format: .percent), date: \(Date(timeIntervalSince1970: 0), format: .iso8601)"
            as String.LocalizationValuePolyfill), encoding: .utf8
      ) == expected)
  }

  @Test func testStringInterpolationWithFormatSpecifiable() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let expected =
      if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
        """
        {"arguments":[{"string":{"_0":"text"}},{"uint64":{"_0":18446744073709551615}},{"int64":{"_0":-9223372036854775808}},{"double":{"_0":42.195}},{"uint32":{"_0":4294967295}},{"int32":{"_0":-2147483648}},{"float":{"_0":3.14}}],"key":"%%@, string: %@, 64bit unsigned integer: %llu, 64bit integer: %lld, double: %lf, 32bit unsigned integer: %u, 32bit integer: %d, float: %f"}
        """
      } else {
        """
        {"arguments":[{"string":{"_0":"text"}},{"uint64":{"_0":18446744073709551615}},{"int64":{"_0":-9223372036854775808}},{"double":{"_0":42.195}},{"uint32":{"_0":4294967295}},{"int32":{"_0":-2147483648}},{"float":{"_0":3.1400001049041748}}],"key":"%%@, string: %@, 64bit unsigned integer: %llu, 64bit integer: %lld, double: %lf, 32bit unsigned integer: %u, 32bit integer: %d, float: %f"}
        """
      }

    #expect(
      String(
        data: try encoder.encode(
          "%@, string: \("text"), 64bit unsigned integer: \(UInt64.max), 64bit integer: \(Int64.min), double: \(Double(42.195)), 32bit unsigned integer: \(UInt32.max), 32bit integer: \(Int32.min), float: \(Float(3.14))"
            as String.LocalizationValuePolyfill), encoding: .utf8) == expected)
  }
}
