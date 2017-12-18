
import Foundation
import UIKit
import NotificationCenter

class ServiceManagersViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:HpsConstants.NOTIFICATION_SERVICE_MANAGERS_VIEW_CONTROLLER),
                       object:nil, queue:nil) {
                        notification in
                        self.refreshServiceManagers()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypePubSub.getInstance().managedServices.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let serviceManager = HypePubSub.getInstance().managedServices.get(indexPath.row)
        cell.textLabel?.text = HpsGenericUtils.getKeyString(fromServiceManager: serviceManager!)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func refreshServiceManagers()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "SubscribersView") as! SubscribersViewController
        let serviceManager = HypePubSub.getInstance().managedServices.get(indexPath.row)!
        destination.title = "Subscribers: 0x" + BinaryUtils.toHexString(data: serviceManager.serviceKey)
        destination.setServiceManager(serviceManager)
        navigationController?.pushViewController(destination, animated: true)
    }
}


