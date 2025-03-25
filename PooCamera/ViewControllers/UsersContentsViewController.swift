//
//  UsersContentsViewController.swift
//  PooCamera
//
//  Created by Wontai Ki on 3/24/25.
//  Copyright © 2025 KiWontai. All rights reserved.
//

import UIKit

class UsersContentsViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "User Added"
        
        let tapGesuture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesuture)
    }
    
    @objc func tapAction() {
        textField.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func textFieldChanged() {
        checkText()
    }
    
    @IBAction func addAction() {
        textField.resignFirstResponder()
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        var userEmojis: String = UserDefaults.standard.string(forKey: "userEmojis") ?? ""
        if !userEmojis.isEmpty {
            userEmojis += " "
        }
        userEmojis += text.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(userEmojis, forKey: "userEmojis")
        textField.text = nil
        addButton.isEnabled = false
        ImageManager.shared.makeImageList()
    }
    
    private func checkText() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            addButton.isEnabled = false
            return
        }
        let array = text.components(separatedBy: CharacterSet(charactersIn: " "))
        array.forEach { str in
            if str.count > 2 {
                addButton.isEnabled = false
                displayError()
                return
            }
        }
        addButton.isEnabled = true
    }
    
    private func displayError() {
        let alertViewController = UIAlertController(title: "Error", message: "Length of each emoji group can't be exceed 2.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertViewController.addAction(okAction)
        
        present(alertViewController, animated: true)
    }
}
