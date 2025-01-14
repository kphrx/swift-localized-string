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
      case unknown

      func toFormatArg() -> any CVarArg {
        switch self {
        case .unknown: Int(0)
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
