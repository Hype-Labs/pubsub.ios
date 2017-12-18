
import Foundation
import UIKit

class AlertControllerUtils
{
    
    static func showInfoAlertController(viewController: UIViewController,title: String, msg: String)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in}
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showSingleInputAlertController(viewController: UIViewController,title: String, msg: String, hint: String, onSingleInputAlertController: SingleInputAlertController) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0]
            {
                onSingleInputAlertController.onOk(input: field.text!)
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            onSingleInputAlertController.onCancel()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = hint
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

protocol SingleInputAlertController
{
    func onOk(input:String)
    func onCancel()
}
