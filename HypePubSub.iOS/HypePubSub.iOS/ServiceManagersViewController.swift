
import Foundation
import UIKit
import NotificationCenter


class ServiceManagersViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:HpsConstants.NOTIFICATION_SERVICE_MANAGERS_VIEW_CONTROLLER),
                       object:nil, queue:nil) {
                        notification in
                        self.refreshServiceManagers()
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypePubSub.getInstance().managedServices.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let serviceManager = HypePubSub.getInstance().managedServices.get(indexPath.row)
        cell.textLabel?.text = BinaryUtils.toHexString(data: (serviceManager?.serviceKey)!)
        return cell
    }
    
    func refreshServiceManagers()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


