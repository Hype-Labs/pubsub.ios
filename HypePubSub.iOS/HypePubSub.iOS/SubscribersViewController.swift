
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (serviceManager?.subscribers.count())!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let subscriber = serviceManager?.subscribers.get(indexPath.row)
        cell.textLabel?.text =  HpsGenericUtils.getAnnouncementStr(fromHYPInstance: (subscriber!.instance)) + "\n"
                                                + HpsGenericUtils.getIdString(fromClient: subscriber!) + "\n"
                                                + HpsGenericUtils.getKeyString(fromClient: subscriber!)

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



