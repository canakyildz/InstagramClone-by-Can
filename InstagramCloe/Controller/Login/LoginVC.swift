//
//  LoginVCViewController.swift
//  InstagramCloe
//
//  Created by Apple on 28.02.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    let logoContainerView: UIView = {
           let view = UIView()
           let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
           logoImageView.contentMode = .scaleAspectFill
           view.addSubview(logoImageView)
           logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 200, height: 50)
           logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
           logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
           view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
      return view
       }()

   let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = ("Email")
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
           let tf = UITextField()
           tf.placeholder = ("Password")
           tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
           tf.borderStyle = .roundedRect
           tf.font = UIFont.systemFont(ofSize: 14)
           tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
           tf.isSecureTextEntry = true
        
           
           return tf
       }()
    
     let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
        
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowUpSign), for: .touchUpInside)
    return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //hide nav bar
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0 , height: 150)
        
        configureViewComponents()
        
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, widht: 0, height: 50)

        }
    @objc func formValidation() {
        //ensures email and pw text fields have text
        guard
        emailTextField.hasText,
            passwordTextField.hasText else {
        
        //handle case for aboce conditions
        loginButton.isEnabled = false
                loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        return
        }
        
        //handle case for conditions were met
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    @objc func handleLogin() {
        
        
        //properties
        guard //making sure theres email and pw entered
            let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        //sign user in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            //handling error
            if let error = error {
                print("unable to sign user in with error", error.localizedDescription)
                return
            }
            
            //handle success
            print("success")
            
             guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
                       
                       mainTabVC.configureViewControllers()
                       self.dismiss(animated: true, completion: nil)
        }
        
    }
    @objc func handleShowUpSign() {
        let signUpVC = SignUp()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, widht: 0, height: 140)
    }
    

   
}

