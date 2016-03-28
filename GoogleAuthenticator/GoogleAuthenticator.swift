//
//  GoogleAuthenticator.swift
//  GoogleAnalyticsReader
//
//  Created by Fabio Milano on 05/02/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation
import OAuthSwift
import Locksmith

/// The Google Authenticator is responsible to expose a convenience access to Google authentication process
///     by implementing the OAuth 2 dance for you.
public class GoogleAuthenticator: NSObject {
    
    // MARK: Properties
    private let oauthClient: OAuth2Swift
    
    private var callBackUrl: NSURL! = NSURL()
    
    private let serviceScope: GoogleServiceScope
    
    private var credential: GoogleCredential
    
    private let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    /**
     Struct constant required to handle the authentication process with Google
     
     - authorizeUrl:   The authorization URL used when requesting the authorization code (used to retrieve the oauth tokens)
     - accessTokenUrl: The access token URL used to retrieve the OAuth tokens: access_token and refresh_token
     - responseType:   The response type as specified by Google Documentation: https://developers.google.com/identity/protocols/OAuth2InstalledApp
     */
    enum AuthenticationConstants: String {
        case AuthorizeUrl = "https://accounts.google.com/o/oauth2/auth"
        case AccessTokensUrl = "https://www.googleapis.com/oauth2/v4/token"
        case ResponseType = "code"
    }
    
    // MARK: init
    public init(consumerKey: String, consumerSecret: String, scope:GoogleServiceScope,
        bundleIdentifier: String? = NSBundle.mainBundle().bundleIdentifier)
    {
        self.credential = GoogleCredential(consumerKey: consumerKey, consumerSecret: consumerSecret)
        
        if let identifier = bundleIdentifier {
            self.callBackUrl = NSURL(string: "\(identifier):/urn:ietf:wg:oauth:2.0:oob")!
        }
        
        self.serviceScope = scope
        
        
        // Initialize the OAuth2Swift client responsible to implement the proper OAuth 2 flow and support.
        oauthClient = OAuth2Swift(consumerKey: consumerKey, consumerSecret: consumerSecret, authorizeUrl: AuthenticationConstants.AuthorizeUrl.rawValue, accessTokenUrl: AuthenticationConstants.AccessTokensUrl.rawValue, responseType: AuthenticationConstants.ResponseType.rawValue)
        oauthClient.allowMissingStateCheck = true
        
        oauthClient.client.credential.processCredential(credential)
    }

    // MARK: Public methods
    
    public class func applicationHandleOpenUrl(url: NSURL){
        // Google provider is the only one with your.bundle.id url schema.
        OAuthSwift.handleOpenURL(url)
    }
    
    /**
    Every Google Authenticator needs to be authorized in order to make signed request.
    If no available tokens have been stored before, the hostViewController is used to present a standard WebView which guides the user to insert his credentials in order to kickoff the OAuth 2 dance to finally retrieve the required tokens.
    Otherwise, the authorization is skipped and available tokens are used to sign the requests.
    - parameter hostViewController: The host view controller used to present the credentials input.
    */
    public func authorize(hostViewController: UIViewController, success: () -> Void , failure: (GoogleAuthenticatorError) -> Void) {
        oauthClient.authorize_url_handler = SafariURLHandler(viewController: hostViewController)
        oauthClient.authorizeWithCallbackURL(callBackUrl, scope: serviceScope.rawValue, state: "", success: { (credential, response, parameters) in
            // Credential retrieved, let's save them
            do {
                try self.credential.storeOAuthCredential(credential)
            } catch {
                failure(GoogleAuthenticatorError.AuthorizationError(error: error as NSError))
            }
            // Success callback
            success()
            }) { (error) -> Void in
                // Error occured
                failure(GoogleAuthenticatorError.AuthorizationError(error: error))
        }
    }
    
    // MARK: client methods
    
    /**
    - returns: `true` if current authenticator is already authorized (access_token and refresh_token available). `false` otherwise.
    */
    public func isAuthorized() -> Bool {
        return (!credential.oauthToken.isEmpty)
    }
    
    
    // TODO: Authorize a NSURLRequest
//    public func authenticateRequest(urlString: String, method: Method, parameters: [String: AnyObject] = [:], headers: [String:String]? = nil, completion:RequestAuthenticationCompletionHandler) {
//
//        oauthClient.createAuthorizedRequest(urlString, method: method.toOAuthSwiftMethod(), parameters: parameters, headers: headers, onRenew: { (credentials) -> ErrorType? in
//            do {
//                try self.credential.storeOAuthCredential(credentials)
//            } catch {
//                return error
//            }
//            return nil
//            }, success: { (authorizedRequest) -> Void in
//                completion(completion:.Success(authorizedRequest))
//            }) { (error) -> Void in
//                completion(completion:.Failure(error))
//        }
//    }
    
    
    public func get(urlString: String, parameters: [String: AnyObject] = [:], headers: [String:String]? = nil, success: OAuthSwiftHTTPRequest.SuccessHandler, failure: OAuthSwiftHTTPRequest.FailureHandler) {
        
        
        oauthClient.startAuthorizedRequest(urlString, method: .GET, parameters: parameters, headers: headers, onTokenRenewal: { (credential) in
            do {
                try self.credential.storeOAuthCredential(credential)
            } catch {
                failure(error: error as NSError)
            }
        }, success: success, failure: failure)
    }
    
    // MARK: Private methods
}

/** List of all available Google scopes supported by the Google Authenticator
     When supporting a new scope, remember to update current structure.
*/
public enum GoogleServiceScope: String {
    case GoogleAnalyticsRead = "https://www.googleapis.com/auth/analytics.readonly"
    
    public func isEqualToScope(scope: GoogleServiceScope) -> Bool {
        return self.rawValue == scope.rawValue
    }
}

public enum GoogleAuthenticatorError {
    case AuthorizationError(error: NSError)
}