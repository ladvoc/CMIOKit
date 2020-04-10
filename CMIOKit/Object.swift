//
//  Object.swift
//  CMIOKit
//
//  Created by Tamas Lustyik on 2020. 04. 01..
//  Copyright © 2020. Tamas Lustyik. All rights reserved.
//

import Foundation
import CoreMediaIO

public protocol CMIOPropertySource {
    static func properties(for objectID: CMIOObjectID) -> Self
}

public struct CMIONode<P: CMIOPropertySource> {
    public enum Hierarchy {
        case ownedObjects
        case custom((CMIOObjectID) -> [CMIOObjectID])
    }

    public let objectID: CMIOObjectID
    public let properties: P
    private let hierarchy: Hierarchy

    public init(objectID: CMIOObjectID, properties: P, hierarchy: Hierarchy = .ownedObjects) {
        self.objectID = objectID
        self.properties = properties
        self.hierarchy = hierarchy
    }

    public var children: [CMIONode] {
        let children: [CMIOObjectID]
        switch hierarchy {
        case .ownedObjects: children = ObjectProperty.ownedObjects.arrayValue(in: objectID) ?? []
        case .custom(let provider): children = provider(objectID)
        }
        return children.map { CMIONode(objectID: $0, properties: P.properties(for: $0), hierarchy: hierarchy) }
    }
}

public extension CMIOObjectID {
    static let systemObject = CMIOObjectID(kCMIOObjectSystemObject)
}
