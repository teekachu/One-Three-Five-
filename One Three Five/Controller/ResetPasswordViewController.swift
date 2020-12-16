//
//  ResetPasswordViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/13/20.
//

import UIKit

protocol ResetPasswordViewControllerDelegate: class {
    func controllerDidResetPassword()
}

class ResetPasswordViewController: UIViewController, Animatable {
    
    //  MARK: - Properties
    private var viewmodel = ResetPasswordViewModel()
    var email: String?
    weak var delegate: ResetPasswordViewControllerDelegate?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var emailTFUnderline: UIImageView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBAction func resetButtonTapped(_ sender: Any) {
        handleResetPassword()}
    
    @IBAction func goBackToLoginTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)}
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadEmail()
        notificationObserver()
        addTapGestureToDismiss()
        
    }
    
    
    //  MARK: - Selectors
    @objc public func dismissKeyboard(){
        view.endEditing(true)}
    
    @objc func didBeginEditing(_ sender: UITextField){
        if sender == emailTextfield{
            emailTextfield.placeholder = nil
        }
    }
    
    @objc func didEndEditing(_ sender: UITextField) {
        emailTextfield.placeholder = "Email"}
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextfield{
            viewmodel.email = emailTextfield.text
        }
        /// enables button and changes color based on criteria above
        updateForm()
    }
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        
        /// TODO: Update
        emailTFUnderline.image = #imageLiteral(resourceName: "lines3").withRenderingMode(.alwaysOriginal)
        
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        resetButton.tintColor = Constants.mediumBlack3f3f3f
        resetButton.isEnabled = false
    }
    
    private func addTapGestureToDismiss(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    private func notificationObserver(){
        emailTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        emailTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        emailTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func loadEmail(){
        guard let email = email else {return}
        emailTextfield.text = email
        viewmodel.email = email
        updateForm()
    }
    
    // MARK: - Auth
    private func handleResetPassword(){
        
        email = emailTextfield.text
        guard let email = email else {return}
        showLoaderAnimation(true)
        
        AuthManager.resetPassword(for: email) {[weak self](error) in
            self?.showLoaderAnimation(false)
            
            if let error = error {
                self?.showToast(state: .error, message: error.localizedDescription)
                print("DEBUG: error in handleResetPassword = \(error.localizedDescription)")
                return
            }
            
            print("did reset password")
            self?.delegate?.controllerDidResetPassword()
        }
    }
}


//  MARK: - FormViewModel
extension ResetPasswordViewController: FormViewModel {
    
    func updateForm() {
        resetButton.isEnabled = viewmodel.shouldEnableButton
        resetButton.tintColor = viewmodel.buttonTitleColor
    }
}
