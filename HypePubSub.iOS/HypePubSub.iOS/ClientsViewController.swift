
import Foundation
import UIKit
import NotificationCenter

class ClientsViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        // Add observer to know when the UI for the client list should be updated
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:HpsConstants.NOTIFICATION_CLIENTS_VIEW_CONTROLLER),
                       object:nil, queue:nil) {
                        notification in
                            self.refreshClients()
                        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Network.getInstance().networkClients.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let client = Network.getInstance().networkClients.get(indexPath.row)
        cell.textLabel?.text = HpsGenericUtils.getAnnouncementStr(fromHYPInstance: (client!.instance)) + "\n"
                                + HpsGenericUtils.getIdString(fromClient: client!) + "\n"
                                + HpsGenericUtils.getKeyString(fromClient: client!)
        return cell
    }
    
    func refreshClients()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
