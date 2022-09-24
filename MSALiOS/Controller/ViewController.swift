import UIKit
import MSAL
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate {
    
    let msgraphManager = MSGraphManager()
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    var currentDeviceMode: MSALDeviceMode?
    
//    var loggingText: UITextView!
    var titleLabel: UILabel!
    var signOutButton: UIButton!
    var signInButton: UIButton!
    var usernameLabel: UILabel!
    var naviBar: UINavigationBar!
    var mailButton: UIButton!

    override func viewDidLoad() {
        print("viewDidLoad")
        
        super.viewDidLoad()
        
        self.initUI()
        
        do {
            try self.initMSAL()
        } catch let error {
            self.updateLogging(text: "Unable to create Application Context \(error)")
        }
        
        self.loadCurrentAccount()
        self.refreshDeviceMode()
        self.platformViewDidLoadSetup()
        
    }
    
    func platformViewDidLoadSetup() {
        
        print("platformViewDidLoadSetup")
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appCameToForeGround(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        self.loadCurrentAccount()
    }
    
    @objc func appCameToForeGround(notification: Notification) {
        print("appCameToForeGround")
        self.loadCurrentAccount()
    }
}


// MARK: Initialization

extension ViewController {
    
    func initMSAL() throws {
        print("initMSAL")
        
        guard let authorityURL = URL(string: K.kAuthority) else {
            self.updateLogging(text: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: K.kClientID,
                                                                  redirectUri: K.kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)

        
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        print("initWebViewParams")
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }
}

// MARK: Shared device

extension ViewController {
    
    @objc func getDeviceMode(_ sender: UIButton) {
        
        print("getDeviceMode")
        
        if #available(iOS 13.0, *) {
            self.applicationContext?.getDeviceInformation(with: nil, completionBlock: { (deviceInformation, error) in
                
                guard let deviceInfo = deviceInformation else {
                    self.updateLogging(text: "Device info not returned. Error: \(String(describing: error))")
                    return
                }
                
                let isSharedDevice = deviceInfo.deviceMode == .shared
                let modeString = isSharedDevice ? "shared" : "private"
                self.updateLogging(text: "Received device info. Device is in the \(modeString) mode.")
            })
        } else {
            self.updateLogging(text: "Running on older iOS. GetDeviceInformation API is unavailable.")
        }
    }
}


// MARK: Acquiring and using token

extension ViewController {
    
    @objc func callGraphAPI(_ sender: UIButton) {
        print("callGraphAPI")
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively()
                return
            }
            
            self.acquireTokenSilently(currentAccount)
        }
        
    }
    
    func acquireTokenInteractively() {
        print("acquireTokenInteractively")
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: K.kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            K.accessToken = result.accessToken
            self.updateLogging(text: "Access token is \(K.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        print("acquireTokenSilently")
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: K.kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            K.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Access token is \(K.accessToken)")
            self.updateSignOutButton(enabled: true)
            self.getContentWithToken()
        }
    }
    
    func getGraphEndpoint() -> String {
        return K.kGraphEndpoint.hasSuffix("/") ? (K.kGraphEndpoint + "v1.0/me/") : (K.kGraphEndpoint + "/v1.0/me/");
    }
    
    // ProfilePhoto取得エンドポイント
    func getProfilePhotoEndpoint() -> String {
        return K.kProfilePhotoEndpoint.hasSuffix("/") ? (K.kProfilePhotoEndpoint) : (K.kProfilePhotoEndpoint);
    }
    
    func getContentWithToken() {
        
        print("getContentWithToken")
        
        // Specify the Graph API endpoint
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(K.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            
            Account.accountData = try! JSON(data: data!)
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                self.updateLogging(text: "Couldn't deserialize result JSON")
                return
            }
            
            self.updateLogging(text: "Result from Graph: \(result))")
            
            self.getProfilePhoto()
            
            }.resume()
    }
    
    // プロフィール写真取得
    func getProfilePhoto() {
        print("getProfilePhoto")
        
        // Specify the Graph API endpoint
        let graphURI = getProfilePhotoEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(K.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }

            Account.accountImage = data!
            
            if Thread.isMainThread {
                let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()! as ProfileViewController
                vc.currentAccountData = Account.accountData
                vc.currentAccountImage = Account.accountImage
                // ③画面遷移（Navigation Controller管理下の場合）
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                DispatchQueue.main.async {
                    let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()! as ProfileViewController
                    vc.currentAccountData = Account.accountData
                    vc.currentAccountImage = Account.accountImage
                    // ③画面遷移（Navigation Controller管理下の場合）
                    self.navigationController?.pushViewController(vc, animated: true)
                    // モーダル表示
                    // self.navigationController?.showDetailViewController(vc, sender: nil)
                }
            }
        }.resume()
    }
    
       
    func updateLogging(text : String) {
        print("updateLogging")
        print(text)
        
//        if Thread.isMainThread {
//            self.loggingText.text = text
//        } else {
//            DispatchQueue.main.async {
//                self.loggingText.text = text
//            }
//        }
    }

}


// MARK: Get account and removing cache

extension ViewController {
    
    typealias AccountCompletion = (MSALAccount?) -> Void

    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        print("loadCurrentAccount")
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
                
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                
                self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                
                // サインインしている場合はサインアウト
//                self.signOut()
                
                // サインインを保持する場合
                self.updateCurrentAccount(account: currentAccount)
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                return
            }
            
            // If testing with Microsoft's shared device mode, see the account that has been signed out from another app. More details here:
            // https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-ios-shared-devices
            if let previousAccount = previousAccount {
                
                self.updateLogging(text: "The account with username \(String(describing: previousAccount.username)) has been signed out.")
                
            } else {
                
                self.updateLogging(text: "Account signed out. Updating UX")
            }
            
            K.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    

    @objc func signOutPressed(_ sender: UIButton) {
        
        print("signOutPressed!!")
        
        signOut()
    }
    
    func signOut() {
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount else { return }
        
        do {
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
            
            // If testing with Microsoft's shared device mode, trigger signout from browser. More details here:
            // https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-ios-shared-devices
            
            if (self.currentDeviceMode == .shared) {
                signoutParameters.signoutFromBrowser = true
            } else {
                signoutParameters.signoutFromBrowser = false
            }
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.updateLogging(text: "Couldn't sign out account with error: \(error)")
                    return
                }
                
                self.updateLogging(text: "Sign out completed successfully")
                K.accessToken = ""
                self.updateCurrentAccount(account: nil)
            })
            
        }
    }
}

// MARK: Shared Device Helpers
extension ViewController {
    
    func refreshDeviceMode() {
        print("refreshDeviceMode")
        
        if #available(iOS 13.0, *) {
            self.applicationContext?.getDeviceInformation(with: nil, completionBlock: { (deviceInformation, error) in
                
                guard let deviceInfo = deviceInformation else {
                    return
                }
                
                self.currentDeviceMode = deviceInfo.deviceMode
            })
        }
    }
}


// MARK: UI Helpers
extension ViewController {
    
    func initUI() {
        
        print("initUI")
        
        // naviBar
        self.navigationItem.title = "Microsoft Connector"
        self.navigationItem.leftBarButtonItem?.tintColor = .white
//        self.naviBar = navigationController?.navigationBar
                
//        leftBarButton = UIBarButtonItem(title: "< Previous", style: .plain, target: self, action: #selector(ViewController.tappedLeftBarButton))
//
//        rightBarButton = UIBarButtonItem(title: "Next >", style: .plain, target: self, action: #selector(ViewController.tappedRightBarButton))
//
//        self.navigationItem.leftBarButtonItem = leftBarButton
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.view.backgroundColor = UIColor.white
        
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = ""
        usernameLabel.textColor = .darkGray
        usernameLabel.textAlignment = .right

        self.view.addSubview(usernameLabel)

        usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
        usernameLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // titleLabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "MS365 接続テスト"
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 28.0)
        titleLabel.textColor = .black

        self.view.addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 180).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // Add call signInButton button
        // 中心に持ってくるのが難しい
        // AutoLayoutしてるから、ここで位置指定しなくてよさそう
        signInButton  = UIButton(frame: CGRect(x: ((Int(self.view.bounds.width)-250)/2), y: Int(view.frame.height) / 2, width: 250, height: 70))
        // 縦横中心になる
        // callGraphButton.center = self.view.center
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.backgroundColor = UIColor.tintColor
        signInButton.layer.cornerRadius = 8
        signInButton.setTitle("サインイン", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.addTarget(self, action: #selector(callGraphAPI(_:)), for: .touchUpInside)
        self.view.addSubview(signInButton)
        
        signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // Add sign out button
        signOutButton = UIButton()
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
//        signOutButton.backgroundColor = UIColor.tintColor
        signOutButton.layer.cornerRadius = 8
        signOutButton.setTitle("サインアウト", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.setTitleColor(.gray, for: .disabled)
        signOutButton.addTarget(self, action: #selector(signOutPressed(_:)), for: .touchUpInside)
        self.view.addSubview(signOutButton)
        
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

    }
    
    func updateSignInButton(enabled : Bool) {
        print("updateSignInButton")
        if Thread.isMainThread {
            self.signInButton.isEnabled = enabled
            self.signInButton.backgroundColor = enabled ?  UIColor.tintColor : UIColor.lightGray
            
        } else {
            DispatchQueue.main.async {
                self.signInButton.isEnabled = enabled
                self.signInButton.backgroundColor = enabled ?  UIColor.tintColor : UIColor.lightGray
            }
        }
    }
    
    func updateSignOutButton(enabled : Bool) {
        print("updateSignOutButton")
        if Thread.isMainThread {
            self.signOutButton.isEnabled = enabled
            self.signOutButton.backgroundColor = enabled ?  UIColor.tintColor : UIColor.lightGray
        } else {
            DispatchQueue.main.async {
                self.signOutButton.isEnabled = enabled
                self.signOutButton.backgroundColor = enabled ?  UIColor.tintColor : UIColor.lightGray
            }
        }
    }
    
    func updateAccountLabel() {
        print("updateAccountLabel")
        
        guard let currentAccount = self.currentAccount else {
            if Thread.isMainThread {
                self.usernameLabel.text = "サインインしてください"
                
            } else {
                DispatchQueue.main.async {
                    self.usernameLabel.text = "サインインしてください"
                }
            }
            return
        }
        print(currentAccount.username!)
        if Thread.isMainThread {
            self.usernameLabel.text = "サインイン中"
        } else {
            DispatchQueue.main.async {
                self.usernameLabel.text = "サインイン中"
            }
        }
        
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        print("updateCurrentAccount")
        self.currentAccount = account
        self.updateAccountLabel()
        self.updateSignOutButton(enabled: account != nil)
        self.updateSignInButton(enabled: account == nil)
    }

}
