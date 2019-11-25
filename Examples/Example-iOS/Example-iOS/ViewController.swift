//
//  ViewController.swift
//  Example-iOS
//
//  Created by Swapnil Nandgave on 21/11/19.
//  Copyright © 2019 Celusion. All rights reserved.
//

import UIKit
import NetworkRepository

class ViewController: UIViewController {
    
    @IBOutlet weak var labelResult: UILabel!
    
    private var tokenHeaders: [String: String]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NetworkRepository.shared.setOAuth2Delegate(delegate: self)
        self.login()
        
    }
    
    private func login() {
        
        var loginParams = [String: String]()
        loginParams["client_id"] = "<CLIENT_ID>"
        loginParams["client_secret"] = "<CLIENT_SECRET>"
        loginParams["scope"] = "<SCOPE>"
        loginParams["grant_type"] = "<PASSWORD>"
        loginParams["username"] = "<USERNAME>"
        loginParams["password"] = "<PASSWORD>"
        let loginRequest = SessionRequest(identifier: "login_request", url: URL(string: "<TOKEN_URL>")!, method: .POST, headers: SessionRequest.HEADER_X_WWW_FORM_ENCODING)
        loginRequest.setHttpBody(item: loginParams, urlEncoding: true)
        
        loginRequest.execute { (response) in
            if response.isSuccess, let dict = response.dictValue {
                self.tokenHeaders = dict.mapValues { ($0 as? String) ?? "" }
                self.invalidateToken()
                self.userInfo()
            }
        }
        
    }
    
    private func userInfo() {
        SessionRequest(url: URL(string: "<API_URL>")!).execute { (response) in
            if response.isValid {
                if let str = response.stringValue {
                    self.labelResult.text = str
                }
            }
        }
    }
    
    private func invalidateToken() {
        if let headers = self.tokenHeaders, headers.count > 0 {
            self.tokenHeaders?["access_token"] = "XXXX"
        }
    }


}

extension ViewController: OAuth2SessionRequestDelegate {
    
    func unauthoriseOAuth2SessionRequestFor(_ oldRequest: SessionRequest, oldRequestCompletion: @escaping (DataSessionResponse) -> Void) {
        //MARK: Refresh Token
        if let headers = self.tokenHeaders {
            let refreshToken = headers["refresh_token"]
            
            var refreshTokenParams = [String: String]()
            refreshTokenParams["client_id"] = "<CLIENT_ID>"
            refreshTokenParams["client_secret"] = "<CLIENT_SECRET>"
            refreshTokenParams["scope"] = "<SCOPE>"
            refreshTokenParams["grant_type"] = "<GRANT_TYPE>"
            refreshTokenParams["refresh_token"] = refreshToken
            let refreshTokenRequest = SessionRequest(identifier: "refresh_token_request", url: URL(string: "<TOKEN_URL>")!, method: .POST, headers: SessionRequest.HEADER_X_WWW_FORM_ENCODING)
            refreshTokenRequest.setHttpBody(item: refreshTokenParams, urlEncoding: true)
            
            refreshTokenRequest.execute { (response) in
                if response.isSuccess, let dict = response.dictValue {
                    self.tokenHeaders = dict.mapValues { ($0 as? String) ?? "" }
                    oldRequest.execute(completion: oldRequestCompletion)
                }
            }
        }
    }
    
    func oAuth2SessionRequestHeaders() -> [String : String]? {
        // ["Authorization":"Bearer <AccessToken>"]
        if let headers = self.tokenHeaders {
            return ["Authorization": headers["token_type"]! + " " + headers["access_token"]!]
        } else {
            return nil
        }
    }
    
}

