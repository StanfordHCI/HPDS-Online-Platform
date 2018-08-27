//
//  Metadata.swift
//  Kinvey
//
//  Created by Victor Barros on 2015-12-08.
//  Copyright © 2015 Kinvey. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

/// This class represents the metadata information for a record
public class Metadata: Object, Codable {
    
    /// Property names for `Metadata`
    @available(*, deprecated: 3.17.0, message: "Please use Metadata.CodingKeys instead")
    public struct Key {
        
        /// Last Modification Time Key.
        @available(*, deprecated: 3.17.0, message: "Please use Metadata.CodingKeys.lastModifiedTime instead")
        public static let lastModifiedTime = "lmt"
        
        /// Entity Creation Time Key.
        @available(*, deprecated: 3.17.0, message: "Please use Metadata.CodingKeys.entityCreationTime instead")
        public static let entityCreationTime = "ect"
        
        /// Authentication Token Key.
        @available(*, deprecated: 3.17.0, message: "Please use Metadata.CodingKeys.authtoken instead")
        public static let authtoken = "authtoken"
        
        /// Last Read Time Key.
        @available(*, deprecated: 3.17.0, message: "Please use Metadata.CodingKeys.lastReadTime instead")
        internal static let lastReadTime = "lrt"
    
    }
    
    @objc
    internal dynamic var lmt: String?
    
    @objc
    internal dynamic var ect: String?
    
    @objc
    internal dynamic var lrt: Date = Date()
    
    /// Last Read Time
    open var lastReadTime: Date {
        get {
            return self.lrt
        }
    }
    
    /// Last Modification Time.
    open var lastModifiedTime: Date? {
        get {
            return self.lmt?.toDate()
        }
        set {
            lmt = newValue?.toString()
        }
    }
    
    /// Entity Creation Time.
    open var entityCreationTime: Date? {
        get {
            return self.ect?.toDate()
        }
        set {
            ect = newValue?.toString()
        }
    }
    
    /// Authentication Token.
    @objc
    open internal(set) dynamic var authtoken: String?
    
    /// Default Constructor.
    public required init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lmt = try container.decodeIfPresent(String.self, forKey: .lastModifiedTime)
        ect = try container.decodeIfPresent(String.self, forKey: .entityCreationTime)
        authtoken = try container.decodeIfPresent(String.self, forKey: .authtoken)
        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(lmt, forKey: .lastModifiedTime)
        try container.encodeIfPresent(ect, forKey: .entityCreationTime)
        try container.encodeIfPresent(authtoken, forKey: .authtoken)
    }
    
    /**
     WARNING: This is an internal initializer not intended for public use.
     :nodoc:
     */
    open override class func ignoredProperties() -> [String] {
        return ["lastModifiedTime", "entityCreationTime", "lastReadTime"]
    }
    
    // MARK: Realm
    
    /**
     WARNING: This is an internal initializer not intended for public use.
     :nodoc:
     */
    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    /**
     WARNING: This is an internal initializer not intended for public use.
     :nodoc:
     */
    public required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    /// Constructor that validates if the map can be build a new instance of Metadata.
    @available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
    public required convenience init?(map: Map) {
        self.init()
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    @available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
    public func mapping(map: Map) {
        lmt <- (CodingKeys.lastModifiedTime.rawValue, map[CodingKeys.lastModifiedTime])
        ect <- (CodingKeys.entityCreationTime.rawValue, map[CodingKeys.entityCreationTime])
        authtoken <- (CodingKeys.authtoken.rawValue, map[CodingKeys.authtoken])
    }

}

extension Metadata: JSONDecodable {
    public class func decode<T>(from data: Data) throws -> T where T : JSONDecodable {
        return try decodeJSONDecodable(from: data)
    }
    
    public class func decodeArray<T>(from data: Data) throws -> [T] where T : JSONDecodable {
        return try decodeArrayJSONDecodable(from: data)
    }
    
    public class func decode<T>(from dictionary: [String : Any]) throws -> T where T : JSONDecodable {
        return try decodeJSONDecodable(from: dictionary)
    }
    
    public func refresh(from dictionary: [String : Any]) throws {
        var _self = self
        try _self.refreshJSONDecodable(from: dictionary)
    }
    
}

@available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
extension Metadata: Mappable {
}

extension Metadata {
    
    /// Property names for `Metadata`
    public enum CodingKeys: String, CodingKey {
        
        /// Last Modification Time Key.
        case lastModifiedTime = "lmt"
        
        /// Entity Creation Time Key.
        case entityCreationTime = "ect"
        
        /// Authentication Token Key.
        case authtoken = "authtoken"
        
        /// Last Read Time Key.
        case lastReadTime = "lrt"
        
    }
    
}

/// Metadata information for each `User`
public final class UserMetadata: Metadata {
    
    /// Status of the email verification process
    open internal(set) var emailVerification: EmailVerification?
    
    /// Status of the password reset process
    open internal(set) var passwordReset: PasswordReset?
    
    /// Status of the activation process
    open internal(set) var userStatus: UserStatus?
    
    public required init() {
        super.init()
    }
    
    enum UserMetadataCodingKeys: String, CodingKey {
        
        case emailVerification
        case passwordReset
        case userStatus = "status"
        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserMetadataCodingKeys.self)
        emailVerification = try container.decodeIfPresent(EmailVerification.self, forKey: .emailVerification)
        passwordReset = try container.decodeIfPresent(PasswordReset.self, forKey: .passwordReset)
        userStatus = try container.decodeIfPresent(UserStatus.self, forKey: .userStatus)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: UserMetadataCodingKeys.self)
        try container.encodeIfPresent(emailVerification, forKey: .emailVerification)
        try container.encodeIfPresent(passwordReset, forKey: .passwordReset)
        try container.encodeIfPresent(userStatus, forKey: .userStatus)
        try super.encode(to: encoder)
    }
    
    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    public required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    @available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
    public override func mapping(map: Map) {
        super.mapping(map: map)
        
        emailVerification <- ("emailVerification", map["emailVerification"])
        passwordReset <- ("passwordReset", map["passwordReset"])
        userStatus <- ("status", map["status"])
    }

}

/// Status of the email verification process for each `User`
public final class EmailVerification: Object, Codable {
    
    /// Current Status
    open internal(set) var status: String?
    
    /// Date of the last Status change
    open internal(set) var lastStateChangeAt: Date?
    
    /// Date of the last email confirmation
    open internal(set) var lastConfirmedAt: Date?
    
    /// Email Address
    open internal(set) var emailAddress: String?
    
}

/// Allows serialization and deserialization of EmailVerification
@available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
extension EmailVerification: Mappable {
    
    /// Constructor that validates if the map can be build a new instance of Metadata.
    public convenience init?(map: Map) {
        self.init()
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    open func mapping(map: Map) {
        status <- ("status", map["status"])
        lastStateChangeAt <- ("lastStateChangeAt", map["lastStateChangeAt"], KinveyDateTransform())
        lastConfirmedAt <- ("lastConfirmedAt", map["lastConfirmedAt"], KinveyDateTransform())
        emailAddress <- ("emailAddress", map["emailAddress"])
    }
    
}

/// Status of the password reset process for each `User`
public final class PasswordReset: Object, Codable {
    
    /// Current Status
    open internal(set) var status: String?
    
    /// Date of the last Status change
    open internal(set) var lastStateChangeAt: Date?
    
}

/// Allows serialization and deserialization of PasswordReset
@available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
extension PasswordReset: Mappable {
    
    /// Constructor that validates if the map can be build a new instance of Metadata.
    public convenience init?(map: Map) {
        self.init()
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    open func mapping(map: Map) {
        status <- ("status", map["status"])
        lastStateChangeAt <- ("lastStateChangeAt", map["lastStateChangeAt"], KinveyDateTransform())
    }
    
}

/// Status of activation process for each `User`
public final class UserStatus: Object {
    
    /// Current Status
    open internal(set) var value: String?
    
    /// Date of the last Status change
    open internal(set) var lastChange: Date?
    
    enum CodingKeys: String, CodingKey {
        
        case value = "val"
        case lastChange
        
    }
    
}

extension UserStatus: Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        lastChange = try container.decodeIfPresent(Date.self, forKey: .lastChange)
    }
    
}

extension UserStatus: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(lastChange, forKey: .lastChange)
    }
    
}

/// Allows serialization and deserialization of UserStatus
@available(*, deprecated: 3.18.0, message: "Please use Swift.Codable instead")
extension UserStatus: Mappable {
    
    /// Constructor that validates if the map can be build a new instance of Metadata.
    public convenience init?(map: Map) {
        self.init()
    }
    
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    open func mapping(map: Map) {
        value <- ("value", map["val"])
        lastChange <- ("lastChange", map["lastChange"], KinveyDateTransform())
    }
    
}
