//
//  DetailViewController.swift
//  MSALiOS
//
//  Created by 花堂　瑠聖 on 2022/08/26.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController {
    
    var currentAccountData: JSON = []
    var currentAccountImage: Data? = nil
    
    var userNameLabel: UILabel!
    var userImage: UIImageView!
    var officeLocationLabel: UILabel!
    var jobTitleLabel: UILabel!
    var mailLabel: UILabel!
    var idLabel: UILabel!
    var signOutButton: UIButton!
    var mailButton: UIButton!
    
    var userName: String = ""
    var officeLocation: String = ""
    var jobTitle: String = ""
    var mail: String = ""
    var id: String = ""
    var businessPhones: [String] = []
    
    let msgraphManager = MSGraphManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("currentAccountData \(currentAccountData)")
        
        initUI()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: UI Helpers
extension ProfileViewController {
    
    func initUI() {
        
        print("initUI!!")
        
        self.navigationItem.title = "Profile"
        self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = .green
                
//        leftBarButton = UIBarButtonItem(title: "< Top Page", style: .plain, target: self, action: #selector(NextViewController.tappedLeftBarButton))
//
//        rightBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(NextViewController.NoAction))
//
//        self.navigationItem.leftBarButtonItem = leftBarButton
//        self.navigationItem.rightBarButtonItem = rightBarButton
 
        self.view.backgroundColor = UIColor.white
        
//        userNameLabel = UILabel()
//        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        userNameLabel.text = ""
//        userNameLabel.textColor = .darkGray
//        userNameLabel.textAlignment = .right
//
//        self.view.addSubview(userNameLabel)
//
//        userNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
//        userNameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
//        userNameLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
//        userNameLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // userImage
        userImage = UIImageView()
        userImage.image = UIImage(data: currentAccountImage!)
        userImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(userImage)
        userImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        userImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        // userNameLabel
        userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = currentAccountData["displayName"].stringValue
        userNameLabel.textColor = .darkGray
        userNameLabel.textAlignment = .center
        userNameLabel.font = UIFont.systemFont(ofSize: 28.0)
        userNameLabel.textColor = .black
        self.view.addSubview(userNameLabel)
        userNameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 30).isActive = true
        userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userNameLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // officeLocationLabel
        officeLocationLabel = UILabel()
        officeLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        officeLocationLabel.text = currentAccountData["officeLocation"].stringValue
        officeLocationLabel.textColor = .darkGray
        officeLocationLabel.textAlignment = .left
        officeLocationLabel.textColor = .black
        self.view.addSubview(officeLocationLabel)
        officeLocationLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10).isActive = true
        officeLocationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        officeLocationLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        officeLocationLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // jobTitleLabel
        jobTitleLabel = UILabel()
        jobTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        jobTitleLabel.text = currentAccountData["jobTitle"].stringValue
        jobTitleLabel.textColor = .darkGray
        jobTitleLabel.textAlignment = .left
        jobTitleLabel.textColor = .black
        self.view.addSubview(jobTitleLabel)
        jobTitleLabel.topAnchor.constraint(equalTo: officeLocationLabel.bottomAnchor, constant: 10).isActive = true
        jobTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        jobTitleLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        jobTitleLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // mailLabel
        mailLabel = UILabel()
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
        mailLabel.text = currentAccountData["mail"].stringValue
        mailLabel.textColor = .darkGray
        mailLabel.textAlignment = .left
        mailLabel.textColor = .black
        self.view.addSubview(mailLabel)
        mailLabel.topAnchor.constraint(equalTo: jobTitleLabel.bottomAnchor, constant: 10).isActive = true
        mailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mailLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        mailLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    
        
        // mail button
        mailButton = UIButton()
        mailButton.translatesAutoresizingMaskIntoConstraints = false
        mailButton.backgroundColor = UIColor.tintColor
        mailButton.layer.cornerRadius = 8
        mailButton.setTitle("メール確認", for: .normal)
        mailButton.setTitleColor(.white, for: .normal)
        mailButton.setTitleColor(.gray, for: .disabled)
        mailButton.addTarget(self, action: #selector(mailButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(mailButton)

        mailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mailButton.topAnchor.constraint(equalTo: mailLabel.bottomAnchor, constant: 50).isActive = true
        mailButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        mailButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        // close button
        signOutButton = UIButton()
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.backgroundColor = UIColor.tintColor
        signOutButton.layer.cornerRadius = 8
        signOutButton.setTitle("戻る", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.setTitleColor(.gray, for: .disabled)
        signOutButton.addTarget(self, action: #selector(signOutButtonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(signOutButton)
        
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.topAnchor.constraint(equalTo: mailButton.bottomAnchor, constant: 20).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        // 現在のビューコントローラを閉じる
        // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mailButtonPressed(_ sender: UIButton) {
        print("mailButtonPressed!!")
        
//        msgraphManager.getMailList()
        
        if Thread.isMainThread {
            let vc = UIStoryboard(name: "MailList", bundle: nil).instantiateInitialViewController()! as MailListTableViewController
            // ③画面遷移（Navigation Controller管理下の場合）
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            DispatchQueue.main.async {
                let vc = UIStoryboard(name: "MailList", bundle: nil).instantiateInitialViewController()! as MailListTableViewController
                // ③画面遷移（Navigation Controller管理下の場合）
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
