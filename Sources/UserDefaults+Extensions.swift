//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//  Documentation
//  https://jessesquires.github.io/Foil
//
//  GitHub
//  https://github.com/jessesquires/Foil
//
//  Copyright © 2021-present Jesse Squires
//

import Foundation

// swiftlint:disable force_cast

extension UserDefaults {

    func save<T: UserDefaultsSerializable>(_ value: T, for key: String) {
        if T.self == URL.self {
            // Hack for URL, which is special
            // See: http://dscoder.com/defaults.html
            // Error: Attempt to insert non-property list object, NSInvalidArgumentException
            self.set(value as? URL, forKey: key)
            return
        }
        self.set(value.storedValue, forKey: key)
    }

    func delete(for key: String) {
        self.removeObject(forKey: key)
    }

    func fetch<T: UserDefaultsSerializable>(_ key: String) -> T {
        self.fetchOptional(key)!
    }

    func fetchOptional<T: UserDefaultsSerializable>(_ key: String) -> T? {
        let fetched: Any?

		// to support command line arguments, some types need explicit getter methods
		// otherwise, errors like "Could not cast value of type '__NSCFString' to 'NSNumber'." occur
		// 
		// but check first for the nil case
		if self.object(forKey: key) == nil {
			fetched = nil
		} else {
			switch T.self {
			case is Bool.Type:
				fetched = self.bool(forKey: key)
			case is Int.Type:
				fetched = self.integer(forKey: key)
			case is Float.Type:
				fetched = self.float(forKey: key)
			case is Double.Type:
				fetched = self.double(forKey: key)
			case is URL.Type:
				fetched = self.url(forKey: key)
			default:
				fetched = self.object(forKey: key)
			}
		}

        if fetched == nil {
            return nil
        }

        guard let storedValue = fetched as? T.StoredValue else {
            return nil
        }

        return T(storedValue: storedValue)
    }

    func registerDefault<T: UserDefaultsSerializable>(value: T, key: String) {
        self.register(defaults: [key: value.storedValue])
    }
}

// swiftlint:enable force_cast
