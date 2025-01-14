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
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import class Foundation.Bundle
import struct Foundation.Locale

func preferredLocalizations(from localizations: [String], forPreferences preferencesArray: [String])
  -> [String]
{
  #if canImport(Darwin)
  Bundle.preferredLocalizations(from: localizations, forPreferences: preferencesArray)
  #else
  let localizations = localizations.map { (Locale(identifier: $0), $0) }
  let preferencesArray = preferencesArray.map { Locale(identifier: $0) }
  guard
    let preferenceLanguageCode: String = preferencesArray.compactMap({
      $0.language.languageCode?.identifier
    }).first(where: { languageCode in
      localizations.contains { $0.0.language.languageCode?.identifier == languageCode }
    })
  else {
    return []
  }

  let availableLocalizations = localizations.filter {
    $0.0.language.languageCode?.identifier == preferenceLanguageCode
  }
  let availablePreferences = preferencesArray.filter {
    $0.language.languageCode?.identifier == preferenceLanguageCode
  }

  if let (_, fallbackLocalization) = availableLocalizations.first(where: {
    $0.0.language.region == nil
  }) {
    if let preferenceRegion = availablePreferences.first!.language.region?.identifier,
      let (_, input) = availableLocalizations.first(where: {
        $0.0.language.region?.identifier == preferenceRegion
      })
    {
      return [input, fallbackLocalization]
    } else {
      return [fallbackLocalization]
    }
  }

  for preference in availablePreferences {
    if let (_, input) = availableLocalizations.first(where: {
      $0.0.language.region?.identifier == preference.language.region?.identifier
    }) {
      return [input]
    }
  }

  // TODO: If `availablePreferences.first!.language.region` is `nil`, not return first (e.g. `availablePreferences.first` is `"en"` and `availableLocalizations` is `["en_gb", "en_us"]`, return `"en_us"`)
  return [availableLocalizations.first!.1]
  #endif
}

extension Bundle {
  func localizedString(forKey key: String, value: String?, table tableName: String?, locale: Locale)
    -> String
  {
    let bundle: Bundle =
      if let localeCode = SwiftLocalizedString.preferredLocalizations(
        from: self.localizations, forPreferences: [locale.identifier]
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
