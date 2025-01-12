//
// This source file part of https://github.com/kphrx/swift-localized-string.git
//
// Bundle+localizedStringWithLocale.swift
//
// Copyright 2025 kPherox
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import class Foundation.Bundle
import struct Foundation.Locale

extension Bundle {
  func localizedString(forKey key: String, value: String?, table tableName: String?, locale: Locale)
    -> String
  {
    let bundle: Bundle =
      if let localeCode = Bundle.preferredLocalizations(
        from: self.localizations, forPreferences: [locale.identifier, Locale.current.identifier]
      ).first, let path = self.path(forResource: localeCode.lowercased(), ofType: "lproj"),
        let bundle = Bundle(path: path)
      {
        bundle
      } else {
        self
      }

    return bundle.localizedString(forKey: key, value: value, table: tableName)
  }
}
