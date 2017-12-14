
import Foundation
import UIKit
import NotificationCenter

class MessagesViewController: UITableViewController
{
    private var subscription:Subscription? = nil
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:HpsConstants.NOTIFICATION_MESSAGES_VIEW_CONTROLLER + (subscription?.serviceName)!),
                       object:nil, queue:nil) {
                        notification in
                        self.refreshMessages()
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (subscription?.receivedMsg.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let msg = subscription?.receivedMsg[indexPath.row]
        cell.textLabel?.text = msg
        return cell
    }
    
    func refreshMessages()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setSubscription(_ subscription: Subscription)
    {
        self.subscription = subscription
    }
    
}


