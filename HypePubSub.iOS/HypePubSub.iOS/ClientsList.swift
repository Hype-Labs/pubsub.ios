//
//  ClientsList.swift
//  HypePubSub.iOS
//
//  Created by Xavier Araújo on 04/12/2017.
//  Copyright © 2017 Xavier Araújo. All rights reserved.
//

import Foundation

class ClientsList
{
    var clients = [Client]()
    /*
    public synchronized int add(Instance instance) throws NoSuchAlgorithmException
{
    if(find(instance) != null) // do not add the client if it is already present
    return -1;
    
    clients.add(new Client(instance));
    return 0;
    }
    
    public synchronized int remove(Instance instance)
{
    Client client = find(instance);
    if(client == null)
    return -1;
    
    clients.remove(client);
    return 0;
    }
    
    
    public synchronized Client find(Instance instance)
{
    ListIterator<Client> it = listIterator();
    while(it.hasNext())
    {
    Client currentClient = it.next();
    if(HpsGenericUtils.areInstancesEqual(currentClient.instance, instance)) {
    return currentClient;
    }
    }
    return null;
    }
    
    // Methods from LinkedList that we want to enable.
    public synchronized ListIterator<Client> listIterator()
{
    return clients.listIterator();
    }
    
    public synchronized int size()
{
    return clients.size();
    }
    
    public synchronized Client get(int index)
{
    return clients.get(index);
    }
    
    public synchronized ClientsAdapter getClientsAdapter(Context context)
{
    if(clientsAdapter == null){
    clientsAdapter = new ClientsAdapter(context, clients);
    }
    return clientsAdapter;
    }
}
 */
}
