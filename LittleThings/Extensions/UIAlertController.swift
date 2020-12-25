//
//  UIAlertController.swift
//  One Three Five
//
//  Created by Seek, David on 12/10/20.
//

import UIKit

extension UIAlertController {
    
    static func addTask(onTap: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let edit = UIAlertAction(title: "Edit", style: .default) { _ in
            onTap(true)}
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            onTap(false)}
        
        controller.addAction(cancel)
        controller.addAction(edit)
        controller.addAction(delete)
        
        controller.view.tintColor = Constants.blackWhite
        return controller
    }
    
    
    static func logUserOut(onTap: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let logOut = UIAlertAction(title: "Log out", style: .default) { _ in
            onTap(true)}
        let clearAllDone = UIAlertAction(title: "Clear Done", style: .destructive) { (_) in
            onTap(false)}
        
        controller.addAction(cancel)
        controller.addAction(logOut)
        controller.addAction(clearAllDone)
        
        controller.view.tintColor = Constants.blackWhite
        return controller
    }
}