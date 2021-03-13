//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Sarawoot Khunsri on 15/7/2563 BE.
//  Copyright © 2563 Eko. All rights reserved.
//

import UIKit
import EkoChat
import UpstraUIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UpstraUIKitManager.setup("API_KEY")
        UpstraUIKitManager.set(eventHandler: CustomEventHandler())
        
        guard let preset = Preset(rawValue: UserDefaults.standard.theme ?? 0) else { return false }
        UpstraUIKitManager.set(theme: preset.theme)
        window = UIWindow()
        let registerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController")
        window?.rootViewController = registerVC
        window?.makeKeyAndVisible()
        
        UpstraUIKitManager.feedUISettings.eventHandler = CustomFeedEventHandler()
        UpstraUIKitManager.feedUISettings.setPostSharingSettings(settings: EkoPostSharingSettings())
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // Handler of opening external url from web browsing session.
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {

            let urlString = url.absoluteString //"https://upstra.co/post/124325135"
            // Parse url and be sure that it is a url of a post
            if urlString.contains("post/") {
                if let range = urlString.range(of: "post/") {
                    // Detect id of the post
                    let postId = String(urlString[range.upperBound...])
                    
                    // Open post details page
                    openPost(withId: postId)
                }
            }
        }
        
        return true
    }

}

class CustomEventHandler: EkoEventHandler {
    
    override func userDidTap(from source: EkoViewController, userId: String) {

        let settings = EkoUserProfilePageSettings()
        settings.shouldChatButtonHide = true
        
        let viewController = EkoUserProfilePageViewController.make(withUserId: userId, settings: settings)
        source.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func communityDidTap(from source: EkoViewController, communityId: String) {
        
        let settings = EkoCommunityProfilePageSettings()
        settings.shouldChatButtonHide = true
        
        let viewController = EkoCommunityProfilePageViewController.make(withCommunityId: communityId, settings: settings)
        source.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func communityChannelDidTap(from source: EkoViewController, channelId: String) {
        print("Channel id: \(channelId)")
    }
    
    override func createPostDidTap(from source: EkoViewController, postTarget: EkoPostTarget) {
        
        let settings = EkoPostEditorSettings()
        settings.shouldFileButtonHide = false
        
        if source is EkoPostTargetSelectionViewController {
            let viewController = EkoPostCreateViewController.make(postTarget: postTarget, settings: settings)
            source.navigationController?.pushViewController(viewController, animated: true)
        } else {
            let viewController = EkoPostCreateViewController.make(postTarget: postTarget, settings: settings)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .overFullScreen
            source.present(navigationController, animated: true, completion: nil)
        }
    }
}

class CustomFeedEventHandler: EkoFeedEventHandler {
    override func sharePostDidTap(from source: EkoViewController, postId: String) {
        let urlString = "https://amity.co/posts/\(postId)"
        guard let url = URL(string: urlString) else { return }
        let viewController = EkoActivityController.make(activityItems: [url])
        source.present(viewController, animated: true, completion: nil)
    }
    
    override func sharePostToGroupDidTap(from source: EkoViewController, postId: String) {
    }
    
    override func sharePostToMyTimelineDidTap(from source: EkoViewController, postId: String) {
    }
}

// MARK :- Helper methods
extension AppDelegate {
    func openPost(withId postId: String) {
        window = UIWindow()
        UpstraUIKitManager.registerDevice(withUserId: "victimIOS", displayName: "victimIOS".uppercased())
        
        let postDetailViewController = EkoPostDetailViewController.make(postId: postId)
        window?.rootViewController = postDetailViewController
        window?.makeKeyAndVisible()
    }
}
