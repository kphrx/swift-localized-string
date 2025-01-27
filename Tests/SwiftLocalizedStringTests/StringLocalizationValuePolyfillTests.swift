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

import Foundation
import Testing

@testable import SwiftLocalizedString

struct StringLocalizationValuePolyfillTests {
  private func compare(
    _ actual: String.LocalizationValuePolyfill, expected: (value: String, via: JSONEncoder)
  ) throws {
    let encodedActual = try expected.via.encode(actual)

    #expect(String(data: encodedActual, encoding: .utf8) == expected.value)
    #expect(
      try JSONDecoder().decode(String.LocalizationValuePolyfill.self, from: encodedActual) == actual
    )
  }

  @Test func testStringInterpolationWithSubject() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let nsLocale = NSLocale(localeIdentifier: "en_US")
    #if canImport(Darwin)
    let expected: String = String(
      data: try encoder.encode("\(nsLocale)" as String.LocalizationValue), encoding: .utf8)!
    #else
    let expected: String = """
      {"arguments":[{"string":{"_0":"\(nsLocale.description)"}}],"key":"%@"}
      """
    #endif

    try self.compare("\(nsLocale)", expected: (expected, encoder))
  }

  @Test func testStringInterpolationWithFormatStyle() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let nsLocale = NSLocale(localeIdentifier: "en_US")
    #if canImport(Darwin)
    let expected: String = String(
      data: try encoder.encode(
        "decimal: \(Decimal(0.6), format: .percent), date: \(Date(timeIntervalSince1970: 0), format: .iso8601)"
          as String.LocalizationValue), encoding: .utf8)!
    #else
    let expected: String = """
      {"arguments":[{"formattedDecimal":{"_0":0.6,"_1":{"format":{"percent":{"_0":\(String(data: try encoder.encode(Decimal.FormatStyle.Percent.percent), encoding: .utf8)!)}}}}},{"formattedDate":{"_0":-978307200,"_1":{"format":{"iso8601":{"_0":\(String(data: try encoder.encode(Date.ISO8601FormatStyle.iso8601), encoding: .utf8)!)}}}}}],"key":"decimal: %@, date: %@"}
      """
    #endif

    try self.compare(
      "decimal: \(Decimal(0.6), format: .percent), date: \(Date(timeIntervalSince1970: 0), format: .iso8601)",
      expected: (expected, encoder))
  }

  @Test func testStringInterpolationWithFormatSpecifiable() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    #if canImport(Darwin)
    let expected: String = String(
      data: try encoder.encode(
        "%@, string: \("text"), 64bit unsigned integer: \(UInt64.max), 64bit integer: \(Int64.min), double: \(Double(42.195)), 32bit unsigned integer: \(UInt32.max), 32bit integer: \(Int32.min), float: \(Float(3.14))"
          as String.LocalizationValue), encoding: .utf8)!
    #else
    let expected: String = """
      {"arguments":[{"string":{"_0":"text"}},{"uint64":{"_0":18446744073709551615}},{"int64":{"_0":-9223372036854775808}},{"double":{"_0":42.195}},{"uint32":{"_0":4294967295}},{"int32":{"_0":-2147483648}},{"float":{"_0":3.14}}],"key":"%%@, string: %@, 64bit unsigned integer: %llu, 64bit integer: %lld, double: %lf, 32bit unsigned integer: %u, 32bit integer: %d, float: %f"}
      """
    #endif

    try self.compare(
      "%@, string: \("text"), 64bit unsigned integer: \(UInt64.max), 64bit integer: \(Int64.min), double: \(Double(42.195)), 32bit unsigned integer: \(UInt32.max), 32bit integer: \(Int32.min), float: \(Float(3.14))",
      expected: (expected, encoder))
  }
}
