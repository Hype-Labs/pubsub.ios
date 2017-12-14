
import Foundation
import UIKit
import NotificationCenter

class SubscriptionsViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:HpsConstants.NOTIFICATION_SUBSCRIPTIONS_VIEW_CONTROLLER),
                       object:nil, queue:nil) {
                        notification in
                        self.refreshSubscriptions()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypePubSub.getInstance().ownSubscriptions.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionView", for: indexPath) as! SubscriptionTableViewCell
        let subscription = HypePubSub.getInstance().ownSubscriptions.get(indexPath.row)
        cell.serviceNameLabel?.text = subscription?.serviceName
        cell.keyLabel?.text = HpsGenericUtils.getKeyString(fromSubscription: subscription!)
        return cell
    }
    
    func refreshSubscriptions()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "MessagesView") as! MessagesViewController
        let subscription = HypePubSub.getInstance().ownSubscriptions.get(indexPath.row)!
        destination.title = "Messages: " + subscription.serviceName
        destination.setSubscription(subscription)
        navigationController?.pushViewController(destination, animated: true)
    }

}

