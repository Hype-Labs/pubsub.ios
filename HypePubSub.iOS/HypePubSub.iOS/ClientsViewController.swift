
import Foundation
import UIKit
import NotificationCenter

class ClientsViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:"refreshClientsViewController"),
                       object:nil, queue:nil) {
                        notification in
                        self.refreshClients()
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Network.getInstance().networkClients.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let client = Network.getInstance().networkClients.get(indexPath.row)
        cell.textLabel?.text = HpsGenericUtils.getAnnouncementStr(fromHYPInstance: (client!.instance))
                                + "\nID: " + BinaryUtils.toHexString(data: client!.instance.identifier)
                                + "\nKey: " + BinaryUtils.toHexString(data: client!.key)
        return cell
    }
    
    func refreshClients()
    {
        self.tableView.reloadData()
    }
}
