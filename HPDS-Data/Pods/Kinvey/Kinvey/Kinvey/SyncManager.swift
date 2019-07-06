//
//  SyncManager.swift
//  Kinvey
//
//  Created by Victor Barros on 2016-01-20.
//  Copyright © 2016 Kinvey. All rights reserved.
//

import Foundation

internal class SyncManager: NSObject {
    
    fileprivate let persistenceId: String
    fileprivate let encryptionKey: Data?
    fileprivate let schemaVersion: UInt64
    
    init(persistenceId: String, encryptionKey: Data? = nil, schemaVersion: UInt64) {
        self.persistenceId = persistenceId
        self.encryptionKey = encryptionKey
        self.schemaVersion = schemaVersion
    }
    
    func sync<T: Persistable>(fileURL: URL? = nil, type: T.Type) throws -> AnySync where T: NSObject {
        let realmSync = try RealmSync<T>(persistenceId: persistenceId, fileURL: fileURL, encryptionKey: encryptionKey, schemaVersion: schemaVersion)
        let anySync = AnySync(realmSync)
        return anySync
    }
    
}
