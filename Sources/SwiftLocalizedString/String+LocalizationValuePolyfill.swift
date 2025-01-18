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

enum _FormatSpecifiableValue: Codable, Equatable {
  case string(String)
  case uint64(UInt64)
  case uint32(UInt32)
  case int64(Int64)
  case int32(Int32)
  case double(Double)
  case float(Float)

  func toFormat() -> _FormatSpecifiable {
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

protocol _FormatSpecifiable: Sendable, CVarArg {
  var formatValue: _FormatSpecifiableValue { get }
  var formatSpecifier: String { get }
}

extension _FormatSpecifiable {
  var formatSpecifier: String {
    switch self.formatValue {
    case .string: "%@"
    case .uint64: "%llu"
    case .uint32: "%u"
    case .int64: "%lld"
    case .int32: "%d"
    case .double: "%lf"
    case .float: "%f"
    }
  }
}

extension String: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .string(self)
  }
}

extension UInt64: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .uint64(self)
  }
}

extension UInt32: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .uint32(self)
  }
}

extension Int64: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .int64(self)
  }
}

extension Int32: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .int32(self)
  }
}

extension Double: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .double(self)
  }
}

extension Float: _FormatSpecifiable {
  var formatValue: _FormatSpecifiableValue {
    .float(self)
  }
}

extension String {
  @available(macOS, deprecated: 12.0, renamed: "LocalizationValue")
  @available(iOS, deprecated: 15.0, renamed: "LocalizationValue")
  @available(watchOS, deprecated: 8.0, renamed: "LocalizationValue")
  @available(tvOS, deprecated: 15.0, renamed: "LocalizationValue")
  public struct LocalizationValuePolyfill: Sendable {
    struct FormatArgument: Sendable {
      enum Storage: Sendable {
        struct StringFormatWrapper: Sendable {
          @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
          enum FormattedValue: Codable {
            struct FormattedDateStyle: Codable {
              enum Format: Codable {
                case dateTime(Date.FormatStyle)
                case iso8601(Date.ISO8601FormatStyle)
              }
              let format: Format

              init(format: Date.FormatStyle) {
                self.format = .dateTime(format)
              }
              init(format: Date.ISO8601FormatStyle) {
                self.format = .iso8601(format)
              }
            }

            struct FormattedDecimalStyle: Codable {
              typealias FormatStyle = Decimal.FormatStyle

              enum Format: Codable {
                case number(FormatStyle)
                case currency(FormatStyle.Currency)
                case percent(FormatStyle.Percent)
              }
              let format: Format

              init(format: FormatStyle) {
                self.format = .number(format)
              }
              init(format: FormatStyle.Currency) {
                self.format = .currency(format)
              }
              init(format: FormatStyle.Percent) {
                self.format = .percent(format)
              }
            }

            struct FormattedFloatStyle: Codable {
              typealias FormatStyle = FloatingPointFormatStyle<Double>

              enum Format: Codable {
                case number(FormatStyle)
                case currency(FormatStyle.Currency)
                case percent(FormatStyle.Percent)
              }
              let format: Format

              init(format: FormatStyle) {
                self.format = .number(format)
              }
              init(format: FormatStyle.Currency) {
                self.format = .currency(format)
              }
              init(format: FormatStyle.Percent) {
                self.format = .percent(format)
              }
            }

            struct FormattedIntStyle: Codable {
              typealias FormatStyle = IntegerFormatStyle<Int>

              enum Format: Codable {
                case number(FormatStyle)
                case currency(FormatStyle.Currency)
                case percent(FormatStyle.Percent)
              }
              let format: Format

              init(format: FormatStyle) {
                self.format = .number(format)
              }
              init(format: FormatStyle.Currency) {
                self.format = .currency(format)
              }
              init(format: FormatStyle.Percent) {
                self.format = .percent(format)
              }
            }

            case formattedDate(Date, FormattedDateStyle)
            case formattedDecimal(Decimal, FormattedDecimalStyle)
            case formattedFloat(Double, FormattedFloatStyle)
            case formattedInt(Int, FormattedIntStyle)

            case string(String)
            case attributedString(AttributedString)

            init(_ value: Date, format: Date.FormatStyle) {
              self = .formattedDate(value, .init(format: format))
            }
            init(_ value: Date, format: Date.ISO8601FormatStyle) {
              self = .formattedDate(value, .init(format: format))
            }

            init(_ value: Decimal, format: FormattedDecimalStyle.FormatStyle) {
              self = .formattedDecimal(value, .init(format: format))
            }
            init(_ value: Decimal, format: FormattedDecimalStyle.FormatStyle.Currency) {
              self = .formattedDecimal(value, .init(format: format))
            }
            init(_ value: Decimal, format: FormattedDecimalStyle.FormatStyle.Percent) {
              self = .formattedDecimal(value, .init(format: format))
            }

            init(_ value: Double, format: FormattedFloatStyle.FormatStyle) {
              self = .formattedFloat(value, .init(format: format))
            }
            init(_ value: Double, format: FormattedFloatStyle.FormatStyle.Currency) {
              self = .formattedFloat(value, .init(format: format))
            }
            init(_ value: Double, format: FormattedFloatStyle.FormatStyle.Percent) {
              self = .formattedFloat(value, .init(format: format))
            }

            init(_ value: Int, format: FormattedIntStyle.FormatStyle) {
              self = .formattedInt(value, .init(format: format))
            }
            init(_ value: Int, format: FormattedIntStyle.FormatStyle.Currency) {
              self = .formattedInt(value, .init(format: format))
            }
            init(_ value: Int, format: FormattedIntStyle.FormatStyle.Percent) {
              self = .formattedInt(value, .init(format: format))
            }

            init<F>(_ value: F.FormatInput, format: F)
            where F: FormatStyle, F.FormatOutput == String {
              self = .string(format.format(value))
            }

            init<F>(_ value: F.FormatInput, format: F)
            where F: FormatStyle, F.FormatOutput == AttributedString {
              self = .attributedString(format.format(value))
            }
          }

          private var _formattedValue: (any Sendable)?

          @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
          var formattedValue: FormattedValue {
            get {
              self._formattedValue as! FormattedValue
            }
            set {
              self._formattedValue = newValue
            }
          }

          private var _stringValue: String = ""

          @available(macOS, obsoleted: 12.0, renamed: "formattedValue")
          @available(iOS, obsoleted: 15.0, renamed: "formattedValue")
          @available(watchOS, obsoleted: 8.0, renamed: "formattedValue")
          @available(tvOS, obsoleted: 15.0, renamed: "formattedValue")
          var stringValue: _FormatSpecifiableValue {
            .string(self._stringValue)
          }

          private let _format: @Sendable (Locale) -> String

          @available(macOS, obsoleted: 12.0, renamed: "init(_:format:)")
          @available(iOS, obsoleted: 15.0, renamed: "init(_:format:)")
          @available(watchOS, obsoleted: 8.0, renamed: "init(_:format:)")
          @available(tvOS, obsoleted: 15.0, renamed: "init(_:format:)")
          init<T>(_ value: T) where T: _FormatSpecifiable {
            self._stringValue = "\(value)"
            self._format = { _ in "\(value)" }
          }

          @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
          init<T, F>(_ value: T, format: F)
          where
            T: Sendable, T == F.FormatInput, F: FormatStyle, F: Sendable,
            F.FormatOutput == String
          {
            self._format = {
              format.locale($0).format(value)
            }
            self.formattedValue = .init(value, format: format)
          }

          @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
          init<T, F>(_ value: T, format: F)
          where
            T: Sendable, T == F.FormatInput, F: FormatStyle, F: Sendable,
            F.FormatOutput == AttributedString
          {
            self._format = {
              String(format.locale($0).format(value).characters)
            }
            self.formattedValue = .init(value, format: format)
          }

          func format(locale: Locale) -> String {
            self._format(locale)
          }
        }

        case value(any _FormatSpecifiable)
        case stringFormat(StringFormatWrapper)
      }

      let storage: Storage

      init(storage: Storage) {
        self.storage = storage
      }

      init(_ value: any _FormatSpecifiable) {
        self.init(storage: .value(value))
      }

      init(value: _FormatSpecifiableValue) {
        self.init(value.toFormat())
      }

      init(stringFormat: Storage.StringFormatWrapper) {
        self.init(storage: .stringFormat(stringFormat))
      }

      func toFormatArg(_ locale: Locale) -> any CVarArg {
        switch self.storage {
        case .value(let value): value
        case .stringFormat(let stringFormat): String(stringFormat.format(locale: locale))
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
      locale: locale, arguments: keyAndValue.arguments.map { $0.toFormatArg(locale) })
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
      format: format, locale: locale,
      arguments: defaultValue.arguments.map { $0.toFormatArg(locale) })
  }
}

extension String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper: Codable {
  init(from decoder: any Decoder) throws {
    if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
      let formattedValue = try String.LocalizationValuePolyfill.FormatArgument.Storage
        .StringFormatWrapper.FormattedValue(from: decoder)
      switch formattedValue {
      case .formattedDate(let value, let style):
        switch style.format {
        case .dateTime(let formatStyle): self.init(value, format: formatStyle)
        case .iso8601(let formatStyle): self.init(value, format: formatStyle)
        }
      case .formattedDecimal(let value, let style):
        switch style.format {
        case .number(let formatStyle): self.init(value, format: formatStyle)
        case .currency(let formatStyle): self.init(value, format: formatStyle)
        case .percent(let formatStyle): self.init(value, format: formatStyle)
        }
      case .formattedFloat(let value, let style):
        switch style.format {
        case .number(let formatStyle): self.init(value, format: formatStyle)
        case .currency(let formatStyle): self.init(value, format: formatStyle)
        case .percent(let formatStyle): self.init(value, format: formatStyle)
        }
      case .formattedInt(let value, let style):
        switch style.format {
        case .number(let formatStyle): self.init(value, format: formatStyle)
        case .currency(let formatStyle): self.init(value, format: formatStyle)
        case .percent(let formatStyle): self.init(value, format: formatStyle)
        }
      default:
        throw DecodingError.typeMismatch(
          Self.self,
          .init(
            codingPath: decoder.codingPath,
            debugDescription: "Unsupported decoding in unsupported FormatStyle protocol platforms"))
      }
    } else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription: "Unsupported decoding in unsupported FormatStyle protocol platforms"))
    }
  }

  func encode(to encoder: Encoder) throws {
    if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
      try self.formattedValue.encode(to: encoder)
    } else {
      try self.stringValue.encode(to: encoder)
    }
  }
}

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
        if let value = try? argumentsContainer.decode(_FormatSpecifiableValue.self) {
          .init(value: value)
        } else {
          .init(
            stringFormat: try argumentsContainer.decode(
              String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper.self))
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
        try argumentsContainer.encode(value.formatValue)
      case .stringFormat(let stringFormat):
        try argumentsContainer.encode(stringFormat)
      }
    }
  }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper
  .FormattedValue: Equatable
{
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.formattedDate(let lhsDate, _), .formattedDate(let rhsDate, _)): lhsDate == rhsDate
    case (.formattedDecimal(let lhsDecimal, _), .formattedDecimal(let rhsDecimal, _)):
      lhsDecimal == rhsDecimal
    case (.formattedFloat(let lhsFloat, _), .formattedFloat(let rhsFloat, _)): lhsFloat == rhsFloat
    case (.formattedInt(let lhsInt, _), .formattedInt(let rhsInt, _)): lhsInt == rhsInt
    case (.string(let lhsString), .string(let rhsString)): lhsString == rhsString
    case (.attributedString(let lhsAttributedString), .attributedString(let rhsAttributedString)):
      lhsAttributedString == rhsAttributedString
    default: false
    }
  }
}

extension String.LocalizationValuePolyfill.FormatArgument.Storage.StringFormatWrapper: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
      lhs.formattedValue == rhs.formattedValue
    } else {
      lhs.stringValue == lhs.stringValue
    }
  }
}

extension String.LocalizationValuePolyfill.FormatArgument.Storage: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.value(let lhsValue), .value(let rhsValue)): lhsValue.formatValue == rhsValue.formatValue
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

    mutating func appendInterpolation<T>(_ value: T, specifier: String)
    where T: _FormatSpecifiable {
      self.value += specifier
      self.interpolations.append(.init(value))
    }

    public mutating func appendInterpolation<Subject>(_ subject: Subject) where Subject: NSObject {
      self.value += "%@"
      self.interpolations.append(.init(subject.description))
    }

    mutating func appendInterpolation<T>(_ value: T) where T: _FormatSpecifiable {
      self.value += value.formatSpecifier
      self.interpolations.append(.init(value))
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

    mutating func appendInterpolation(_ value: String) {
      self.value += "%@"
      self.interpolations.append(.init(value))
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
