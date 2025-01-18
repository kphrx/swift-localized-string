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
  public struct LocalizationValuePolyfill: Sendable {
    struct FormatArgument: Sendable {
      enum Storage: Sendable {
        enum Value {
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

        #if canImport(Darwin)
        struct StringFormatWrapper {}
        #else
        struct StringFormatWrapper {
          init<T, F>(_ value: T, format: F)
          where
            T: Sendable, T == F.FormatInput, F: FormatStyle, F: Sendable,
            F.FormatOutput: StringProtocol
          {
          }
        }
        #endif

        // String.LocalizationValue.FormatArgument.Storage.value is not enum...
        case value(Value)
        case stringFormat(StringFormatWrapper)
      }

      let storage: Storage

      init(storage: Storage) {
        self.storage = storage
      }

      init(value: Storage.Value) {
        self.init(storage: .value(value))
      }

      init(stringFormat: Storage.StringFormatWrapper) {
        self.init(storage: .stringFormat(stringFormat))
      }

      init(_ value: String) {
        self.init(value: .string(value))
      }

      init(_ value: UInt64) {
        self.init(value: .uint64(value))
      }

      init(_ value: UInt32) {
        self.init(value: .uint32(value))
      }

      init(_ value: Int64) {
        self.init(value: .int64(value))
      }

      init(_ value: Int32) {
        self.init(value: .int32(value))
      }

      init(_ value: Double) {
        self.init(value: .double(value))
      }

      init(_ value: Float) {
        self.init(value: .float(value))
      }

      func toFormatArg() -> any CVarArg {
        switch self.storage {
        case .value(let value): value.toFormatArg()
        case .stringFormat: Int(0)
        }
      }
    }

    let key: String
    let arguments: [FormatArgument]

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

extension String.LocalizationValuePolyfill.FormatArgument.Storage.Value: Codable {}
extension String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper: Codable {}

extension String.LocalizationValuePolyfill: Codable {
  enum CodingKeys: String, CodingKey {
    case key, arguments
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.key = try container.decode(String.self, forKey: .key)

    var arguments: [FormatArgument] = []
    var argumentsContainer = try container.nestedUnkeyedContainer(forKey: .arguments)
    while !argumentsContainer.isAtEnd {
      let argument: FormatArgument =
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *),
          let stringFormat = try? argumentsContainer.decode(
            String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper.self)
        {
          .init(stringFormat: stringFormat)
        } else {
          .init(
            value: try argumentsContainer.decode(
              String.LocalizationValuePolyfill.FormatArgument.Storage.Value.self))
        }
      arguments.append(argument)
    }
    self.arguments = arguments
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.key, forKey: .key)

    var argumentsContainer = container.nestedUnkeyedContainer(forKey: .arguments)
    for argument in self.arguments {
      switch argument.storage {
      case .value(let value):
        try argumentsContainer.encode(value)
      case .stringFormat(let stringFormat):
        try argumentsContainer.encode(stringFormat)
      }
    }
  }
}

extension String.LocalizationValuePolyfill.FormatArgument.Storage.Value: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhsValue), .string(let rhsValue)): lhsValue == rhsValue
    case (.uint64(let lhsValue), .uint64(let rhsValue)): lhsValue == rhsValue
    case (.uint32(let lhsValue), .uint32(let rhsValue)): lhsValue == rhsValue
    case (.int64(let lhsValue), .int64(let rhsValue)): lhsValue == rhsValue
    case (.int32(let lhsValue), .int32(let rhsValue)): lhsValue == rhsValue
    case (.double(let lhsValue), .double(let rhsValue)): lhsValue == rhsValue
    case (.float(let lhsValue), .float(let rhsValue)): lhsValue == rhsValue
    default: false
    }
  }
}

extension String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    false
  }
}

extension String.LocalizationValuePolyfill.FormatArgument.Storage: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.value(let lhsValue), .value(let rhsValue)): lhsValue == rhsValue
    case (.stringFormat(let lhsFormat), .stringFormat(let rhsFormat)): lhsFormat == rhsFormat
    default: false
    }
  }
}

extension String.LocalizationValuePolyfill.FormatArgument: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.storage == rhs.storage
  }
}

extension String.LocalizationValuePolyfill: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.key == rhs.key && lhs.arguments == rhs.arguments
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
      self.interpolations.append(.init(subject.description))
    }

    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    public mutating func appendInterpolation<T, F>(_ value: T, format: F)
    where
      T: Sendable, T == F.FormatInput, F: FormatStyle, F: Sendable, F.FormatOutput == String
    {
      self.value += "%@"
      #if canImport(Darwin)
      self.interpolations.append(.init(format.format(value)))
      #else
      self.interpolations.append(.init(stringFormat: .init(value, format: format)))
      #endif
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
