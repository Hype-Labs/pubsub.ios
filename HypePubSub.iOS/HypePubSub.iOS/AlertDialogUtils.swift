
import Foundation
import UIKit

class AlertDialogUtils
{
    
    static func showOkDialog(viewController: UIViewController,title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
        }
        
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showSingleInputDialog(viewController: UIViewController,title: String, msg: String, hint: String, onSingleInputDialog: SingleInputDialog) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0]
            {
                onSingleInputDialog.onOk(input: field.text!)
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            onSingleInputDialog.onCancel()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = hint
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showDoubleInputDialog(viewController: UIViewController,title:String,
                                      msg: String, hint1: String, hint2: String,
                                      onDoubleInputDialog: DoubleInputDialog) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field1 = alertController.textFields?[0], let field2 = alertController.textFields?[1]{
                onDoubleInputDialog.onOk(input1: field1.text!, input2: field2.text!)
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            onDoubleInputDialog.onCancel()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = hint1
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = hint2
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

protocol SingleInputDialog
{
    func onOk(input:String)
    func onCancel()
}

protocol DoubleInputDialog
{
    func onOk(input1:String, input2:String)
    func onCancel()
}
