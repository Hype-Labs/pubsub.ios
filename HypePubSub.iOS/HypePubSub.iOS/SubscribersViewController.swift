
import Foundation
import UIKit
import NotificationCenter

class SubscribersViewController: UITableViewController
{
    private var serviceManager:ServiceManager? = nil
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:HpsConstants.NOTIFICATION_SUBSCRIBERS_VIEW_CONTROLLER + BinaryUtils.toHexString(data: (serviceManager?.serviceKey)!)),
                       object:nil, queue:nil) {
                        notification in
                        self.refreshMessages()
        }
        
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (serviceManager?.subscribers.count())!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath) as! ClientTableViewCell
        let subscriber = serviceManager?.subscribers.get(indexPath.row)
        cell.announcementLabel?.text = HpsGenericUtils.getAnnouncementStr(fromHYPInstance: (subscriber!.instance))
        cell.idLabel?.text = HpsGenericUtils.getIdString(fromClient: subscriber!)
        cell.keyLabel?.text = HpsGenericUtils.getKeyString(fromClient: subscriber!)
        return cell
    }
    
    func refreshMessages()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setServiceManager(_ serviceManager: ServiceManager)
    {
        self.serviceManager = serviceManager
    }
    
}



