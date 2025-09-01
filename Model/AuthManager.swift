//
//  AuthManager.swift
//  KleagueApp
//
//  Created by 최영건 on 9/1/25.
//

import Foundation
import RxSwift
import FirebaseAuth
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

class AuthManager: NSObject {
    static let shared = AuthManager()
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
    
    private var appleObserver: AnyObserver<AuthDataResult>?
    
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
    
    private func firebaseAuthWithKakao(oauthToken: OAuthToken?, observer: AnyObserver<AuthDataResult>) {
        guard let token = oauthToken?.accessToken else {
            observer.onError(NSError(domain: "KakaoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Access Token"]))
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "oidc.kakao",
            idToken: token,
            accessToken: token
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

// MARK: - Apple Login Delegate
extension AuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let anchor = self.anchor {
            return anchor
        }
        
        // Scene 기반으로 현재 활성 윈도우 가져오기
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        
        // 혹시 못 찾으면 fallback
        return UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIdCredential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {

            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
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
