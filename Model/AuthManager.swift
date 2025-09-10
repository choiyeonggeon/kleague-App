//
//  AuthManager.swift
//  KleagueApp
//
//  Created by 최영건 on 9/1/25.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

class AuthManager: NSObject {
    static let shared = AuthManager()
    private var appleObserver: AnyObserver<AuthDataResult>?
    private var anchor: ASPresentationAnchor?
    
    // MARK: - Apple Login (RxSwift)
    func signInWithApple(presentationAnchor: ASPresentationAnchor) -> Observable<AuthDataResult> {
        return Observable.create { observer in
            let requst = ASAuthorizationAppleIDProvider().createRequest()
            requst.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [requst])
            controller.delegate = self
            controller.presentationContextProvider = self
            
            self.appleObserver = observer
            self.anchor = presentationAnchor
            controller.performRequests()
            
            return Disposables.create()
        }
    }
    
    // MARK: - Kakao Login (RxSwift)
    func signInWithKakao() -> Observable<AuthDataResult> {
        return Observable.create { observer in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    self.firebaseAuthWithKakao(oauthToken: oauthToken, observer: observer)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    self.firebaseAuthWithKakao(oauthToken: oauthToken, observer: observer)
                }
            }
            return Disposables.create()
        }
    }
    
    private func fetchKakaoIdToken(accessToken: String, completion: @escaping (String?) -> Void) {
        guard Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] is String else {
            completion(nil)
            return
        }
        
        let url = URL(string: "https://kauth.kakao.com/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "grant_type=urn:ietf:params:oauth:grant-type:token-exchange&client_id=KAKAO_NATIVE_APP_KEY&subject_token=\(accessToken)&subject_token_type=urn:ietf:params:oauth:token-type:access_token"
        
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let idToken = json["id_token"] as? String else {
                completion(nil)
                return
            }
            completion(idToken)
        }.resume()
    }
    
    private func firebaseAuthWithKakao(oauthToken: OAuthToken?, observer: AnyObserver<AuthDataResult>) {
        guard let accessToken = oauthToken?.accessToken else {
            observer.onError(NSError(domain: "KakaoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Access Token"]))
            return
        }
        
        fetchKakaoIdToken(accessToken: accessToken) { idToken in
            guard let idToken = idToken else {
                observer.onError(NSError(domain: "KakaoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch ID Token"]))
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "oidc.kakao",
                idToken: idToken,
                accessToken: accessToken
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    observer.onError(error)
                } else if let authResult = authResult {
                    observer.onNext(authResult)
                    observer.onCompleted()
                }
            }
        }
    }
}

// MARK: - Apple Login Delegate
extension AuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let anchor = self.anchor {
            return anchor
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        
        return UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIdCredential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {
            
            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: tokenString,
                rawNonce: ""
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.appleObserver?.onError(error)
                } else if let authResult = authResult {
                    self.appleObserver?.onNext(authResult)
                    self.appleObserver?.onCompleted()
                }
            }
            
        } else {
            self.appleObserver?.onError(NSError(domain: "AppleAuth",
                                                code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Invalid identityToken"]))
        }
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.appleObserver?.onError(error)
    }
}
