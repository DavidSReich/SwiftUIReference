//
//  UserDefaultsManager.swift
//  GIPHYTags
//
//  Created by David S Reich on 9/12/19.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static let userSettingsKey = "usersettings"
    private static let appDefaults = UserDefaults.standard

    class func getUserSettings(defaults: UserDefaults = UserDefaultsManager.appDefaults) -> UserSettings {
        if let userSettingsData = defaults.object(forKey: userSettingsKey) as? Data {
            return UserSettings.decodeUserSettings(data: userSettingsData)
        }

        return UserSettings.getDefaultUserSettings()
    }

    class func saveUserSettings(userSettings: UserSettings, defaults: UserDefaults = UserDefaultsManager.appDefaults) {
        defaults.set(userSettings.getUserSettingsData(), forKey: userSettingsKey)
    }
}
