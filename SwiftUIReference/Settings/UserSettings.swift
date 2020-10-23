//
//  UserSettings.swift
//  SwiftUIReference
//
//  Created by David S Reich on 8/1/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import Foundation

struct UserSettings: Equatable, Codable {
    var initialTags: String
    var giphyAPIKey: String
    var maxNumberOfImages: Int
    var maxNumberOfLevels: Int

    private static let urlTemplate = "https://api.giphy.com/v1/gifs/search?api_key={API_KEY}&limit={MAX_IMAGES}&q={TAGS}"

    private static let defaultInitialTags = "weather"  //plus delimited list i.e. "tag1+tag2+tag3"
    private static let defaultMaxNumberOfImages = 25
    private static let defaultMaxNumberOfLevels = 5

    func getFullUrlString(tags: String) -> String {
        return UserSettings.urlTemplate
            .replacingOccurrences(of: "{API_KEY}", with: giphyAPIKey)
            .replacingOccurrences(of: "{MAX_IMAGES}", with: "\(maxNumberOfImages)")
            .replacingOccurrences(of: "{TAGS}", with: tags)
    }

    static func getDefaultUserSettings() -> UserSettings {
        //there's no default API key
        return UserSettings(initialTags: defaultInitialTags,
                            giphyAPIKey: "",
                            maxNumberOfImages: defaultMaxNumberOfImages,
                            maxNumberOfLevels: defaultMaxNumberOfLevels)
    }

    func getUserSettingsData() -> Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }

    static func getDefaultUserSettingsData() -> Data {
        return UserSettings.getDefaultUserSettings().getUserSettingsData()
    }

    static func decodeUserSettings(data: Data) -> UserSettings {
        let result: Result<UserSettings, ReferenceError> = data.decodeData()

        if case .success(let userSettings) = result {
            return userSettings
        }

        return UserSettings.getDefaultUserSettings()
    }
}
