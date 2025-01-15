//
// This source file part of https://github.com/kphrx/swift-localized-string.git
//
// String+LocalizationValue.swift
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

extension String {
  @available(macOS, deprecated: 12.0, renamed: "LocalizationValue")
  @available(iOS, deprecated: 15.0, renamed: "LocalizationValue")
  @available(watchOS, deprecated: 8.0, renamed: "LocalizationValue")
  @available(tvOS, deprecated: 15.0, renamed: "LocalizationValue")
  public struct LocalizationValuePolyfill: Codable {
    enum FormatArgument: Codable {
      enum Value: Codable {
        case string(String)
        case uint64(UInt64)
        case uint32(UInt32)
        case int64(Int64)
        case int32(Int32)
        case double(Double)
        case float(Float)

        func toFormatArg() -> any CVarArg {
          switch self {
          case .string(let value): value
          case .uint64(let value): value
          case .uint32(let value): value
          case .int64(let value): value
          case .int32(let value): value
          case .double(let value): value
          case .float(let value): value
          }
        }
      }

      enum StringFormat: Codable {
        case unknown
      }

      case value(Value)
      case stringFormat(StringFormat)

      static func string(_ value: String) -> Self {
        .value(.string(String(value)))
      }

      static func uint64(_ value: UInt64) -> Self {
        .value(.uint64(value))
      }

      static func uint32(_ value: UInt32) -> Self {
        .value(.uint32(value))
      }

      static func uint16(_ value: UInt16) -> Self {
        .value(.uint32(UInt32(value)))
      }

      static func uint8(_ value: UInt8) -> Self {
        .value(.uint32(UInt32(value)))
      }

      static func int64(_ value: Int64) -> Self {
        .value(.int64(value))
      }

      static func int32(_ value: Int32) -> Self {
        .value(.int32(value))
      }

      static func int16(_ value: Int16) -> Self {
        .value(.int32(Int32(value)))
      }

      static func int8(_ value: Int8) -> Self {
        .value(.int32(Int32(value)))
      }

      static func double(_ value: Double) -> Self {
        .value(.double(value))
      }

      static func float(_ value: Float) -> Self {
        .value(.float(value))
      }

      init(from decoder: any Decoder) throws {
        do {
          let value = try Value(from: decoder)
          self = .value(value)
        } catch DecodingError.dataCorrupted {
          self = .stringFormat(.unknown)
        }
      }

      func encode(to encoder: Encoder) throws {
        switch self {
        case .value(let value): try value.encode(to: encoder)
        case .stringFormat:
          throw EncodingError.invalidValue(
            self, .init(codingPath: encoder.codingPath, debugDescription: "unknown arguments"))
        }
      }

      func toFormatArg() -> any CVarArg {
        switch self {
        case .value(let value): value.toFormatArg()
        case .stringFormat: Int(0)
        }
      }
    }

    enum CodingKeys: String, CodingKey {
      case key, arguments
    }

    var key: String
    var arguments: [FormatArgument]

    public init(_ value: String) {
      self.key = value
      self.arguments = []
    }
  }

  @available(
    macOS, obsoleted: 12.0, message: "Use type `LocalizationValue` for parameter `localized`"
  )
  @available(
    iOS, obsoleted: 15.0, message: "Use type `LocalizationValue` for parameter `localized`"
  )
  @available(
    watchOS, obsoleted: 8.0, message: "Use type `LocalizationValue` for parameter `localized`"
  )
  @available(
    tvOS, obsoleted: 15.0, message: "Use type `LocalizationValue` for parameter `localized`"
  )
  public init(
    localized keyAndValue: LocalizationValuePolyfill, table: String? = nil, bundle: Bundle? = nil,
    locale: Locale = .current, comment: StaticString? = nil
  ) {
    let table: String? =
      if let table {
        "\(table).strings"
      } else {
        nil
      }

    let bundle =
      if let bundle {
        bundle
      } else {
        Bundle.main
      }

    self.init(
      format: bundle.localizedString(forKey: keyAndValue.key, value: nil, table: table),
      locale: locale, arguments: keyAndValue.arguments.map { $0.toFormatArg() })
  }

  @available(
    macOS, obsoleted: 12.0, message: "Use type `LocalizationValue` for parameter `defaultValue`"
  )
  @available(
    iOS, obsoleted: 15.0, message: "Use type `LocalizationValue` for parameter `defaultValue`"
  )
  @available(
    watchOS, obsoleted: 8.0, message: "Use type `LocalizationValue` for parameter `defaultValue`"
  )
  @available(
    tvOS, obsoleted: 15.0, message: "Use type `LocalizationValue` for parameter `defaultValue`"
  )
  public init(
    localized key: StaticString, defaultValue: LocalizationValuePolyfill, table: String? = nil,
    bundle: Bundle? = nil, locale: Locale = .current, comment: StaticString? = nil
  ) {
    let table: String? =
      if let table {
        "\(table).strings"
      } else {
        nil
      }

    let bundle =
      if let bundle {
        bundle
      } else {
        Bundle.main
      }

    let key = key.withUTF8Buffer { String(bytes: $0, encoding: .utf8)! }

    var format = bundle.localizedString(forKey: key, value: nil, table: table)
    if format == key, let devLocale = bundle.developmentLocalization {
      format = bundle.localizedString(
        forKey: defaultValue.key, value: nil, table: table, locale: Locale(identifier: devLocale))
    }

    self.init(
      format: format, locale: locale, arguments: defaultValue.arguments.map { $0.toFormatArg() })
  }
}

extension String.LocalizationValuePolyfill: ExpressibleByStringInterpolation {
  public struct StringInterpolation: StringInterpolationProtocol, Sendable {
    var value: String = ""
    var interpolations: [FormatArgument] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.value.reserveCapacity(literalCapacity)
      self.interpolations.reserveCapacity(interpolationCount)
    }

    public mutating func appendLiteral(_ literal: String) {
      self.value += literal.replacingOccurrences(of: "%", with: "%%")
    }

    public mutating func appendInterpolation<Subject>(_ subject: Subject) where Subject: NSObject {
      self.value += "%@"
      self.interpolations.append(.string(subject.description))
    }
  }

  public init(stringInterpolation: StringInterpolation) {
    self.key = stringInterpolation.value
    self.arguments = stringInterpolation.interpolations
  }

  public init(stringLiteral: StringLiteralType) {
    self.init(stringLiteral)
  }
}
