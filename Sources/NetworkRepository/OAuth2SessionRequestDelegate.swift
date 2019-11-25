//
//  OAuth2SessionRequestDelegate.swift
//  
//
//  Created by Swapnil Nandgave on 22/11/19.
//

import Foundation

/**
 # OAuth2 Session Request Delegate
 You can track the OAuth2 session token.
 
 ## Below are the helper methods to solve the OAuth2 Provider Implementation
 
 - unauthoriseOAuth2SessionRequestFor - It calls when you get 401 Unauthorised for OAuth2 Rest API's
 - oAuth2SessionRequestHeaders - It adds ["Authorization":"Bearer <AccessToken>"] in Request before execution
 */
public protocol OAuth2SessionRequestDelegate {
    
    /**
     This is place where you suppose to call REFRESH_TOKEN API when you get 401 Unauthorised. You can save newly resulted token in Keychain and execute old request again
     */
    func unauthoriseOAuth2SessionRequestFor(_ oldRequest: SessionRequest, oldRequestCompletion: @escaping(DataSessionResponse)->Void)
    
    func oAuth2SessionRequestHeaders()->[String: String]?
    
}
