// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import CoreData

extension NSManagedObject {
    /// Converts model object to NSManagedObject
    func modelObject<T: DatabaseModelObject>(transformers: [String: DatabaseTransformable.Type]) throws -> T {
        let encoded = self.encoded(transformers: transformers)
        let decoder = DatabaseDecoder(dictionary: encoded)

        return try decoder.decode(as: T.self)
    }

    // MARK: - Private helpers

    private func encoded(transformers: [String: DatabaseTransformable.Type]) -> [String: Any] {
        let entity = self.entity
        var dictionary = [String: Any]()

        entity.attributesByName.forEach { attribute in
            let key = attribute.key

            guard let value = self.value(forKey: key) else { return}

            if let attrClassName = attribute.value.attributeValueClassName,
                let transformer = transformers[attrClassName] {
                dictionary[key] = transformer.fromDatabase(value: value)
                return
            }

            if attribute.value.attributeType == .booleanAttributeType, let value = value as? NSNumber {
                dictionary[key] = value.boolValue
                return
            }

            dictionary[key] = value
        }

        return dictionary
    }
}