//
//  GoogleCredential.swift
//  GoogleAnalyticsReader
//
//  Created by Fabio Milano on 26/02/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation
import Locksmith
import OAuthSwift

/**
 The Google Credential is a convenience structure used to store credential retrieved and used by the Google Authenticator
*/
public struct GoogleCredential: CreateableSecureStorable, GenericPasswordSecureStorable, ReadableSecureStorable {
    public let consumerKey: String
    public let consumerSecret: String
    public private(set) var oauthToken = String()
    public private(set) var oauthRefreshToken = String()
    public private(set) var oauthTokenExpiresAt = NSDate()
    
    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        if let fromKeychain = self.readFromSecureStore() {
            self.oauthToken = fromKeychain.data?["oauthToken"] as? String ?? String()
            self.oauthTokenExpiresAt = fromKeychain.data?["oauthTokenExpiresAt"] as? NSDate ?? NSDate()
            self.oauthRefreshToken = fromKeychain.data?["oauthRefreshToken"] as? String ?? String()
        }
    }
    
    // Required by CreateableSecureStorable
    public var data: [String: AnyObject] {
        get {
            return [ "consumerKey": consumerKey, "consumerSecret": consumerSecret, "oauthToken": oauthToken, "oauthTokenExpiresAt": oauthTokenExpiresAt, "oauthRefreshToken": oauthRefreshToken]
        }
    }
    
    public func isExpired() -> Bool {
        return NSDate() >= oauthTokenExpiresAt
    }
    
    // Required by GenericPasswordSecureStorable
    public let service = "com.touchwonders.GoogleAuthenticator"
    public var account: String { return consumerKey }
}

public extension GoogleCredential {
    public mutating func storeOAuthCredential(oauthSwiftCredential: OAuthSwiftCredential) throws {
        oauthToken = oauthSwiftCredential.oauth_token
        
        if let expiresAt = oauthSwiftCredential.oauth_token_expires_at {
            self.oauthTokenExpiresAt = expiresAt
        }
        
        try self.updateInSecureStore()
    }
}

extension OAuthSwiftCredential {
    
    public func processCredential(googleCredential: GoogleCredential) {
        oauth_token = googleCredential.oauthToken
        oauth_token_secret = String()
        oauth_refresh_token = googleCredential.oauthRefreshToken
        oauth_token_expires_at = googleCredential.oauthTokenExpiresAt
    }

}