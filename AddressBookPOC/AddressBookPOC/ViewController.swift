//
//  ViewController.swift
//  AddressBookPOC
//
//  Created by Silpa M S on 7/30/15.
//  Copyright (c) 2015 RapidValue. All rights reserved.
//

import UIKit
import AddressBook

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contactsTableView: UITableView!
    var contactsArray : NSMutableArray! = NSMutableArray()
    //contactsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    
    // MARK:View Life Cycle
       override func viewDidLoad() {
        contactsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    // MARK:Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
   // MARK:Button Action
    @IBAction func tappedContactsButton(sender: UIButton) {
        let authorisationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorisationStatus {
        case .Denied, .Restricted :
                println("Denied")
                displayDeniedContactAlert()
            
        case .Authorized :
            print("Authorised")
            fetchContactsList()
       
        case .NotDetermined :
            print("Not determined")
            promptForContactAccess()
            
        default: ()
        }
        
    }
    
    // MARK:Display Alert
    func displayDeniedContactAlert() {
        
        let displayAlert = UIAlertController(title: "Cannot fetch contact", message: "Give app permission to fetch contacts", preferredStyle: .Alert)
        displayAlert.addAction(UIAlertAction(title: "Change Settings", style: .Default, handler: {
            action in self.openSettings()
        }))
        displayAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel , handler: nil))
        presentViewController(displayAlert, animated: true, completion: nil)
    }
    
    func displayDeniedContactAlert1() {
        
        let displayAlert = UIAlertController(title: "Cannot fetch contact", message: "Give app permission to fetch contacts", preferredStyle: .Alert)
        displayAlert.addAction(UIAlertAction(title: "Change Settings", style: .Default, handler: {
            action in self.openSettings()
        }))
        displayAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel , handler: nil))
        presentViewController(displayAlert, animated: true, completion: nil)
    }

    // MARK:Fetch contacts
    func fetchContactsList() {
        
        contactsArray.removeAllObjects()
        let contactsList = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        println("records in the array \(contactsList.count)")
        
        for contactRecord :ABRecordRef in contactsList {
            var allEmailIDs: NSArray

            var emailRecord: ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            let emails: ABMultiValueRef = ABRecordCopyValue(contactRecord, kABPersonEmailProperty).takeRetainedValue()
            println("Emails \(ABMultiValueGetCount(emailRecord))")
                        for (var i = 0; i < ABMultiValueGetCount(emails); i++) {
                            let email: String = ABMultiValueCopyValueAtIndex(emails, i).takeRetainedValue() as! String
                             contactsArray.addObject(email)
                            println("email=\(email)")
                        }
//            if ABMultiValueGetCount(emailRecord) > 0 {
//                 allEmailIDs = ABMultiValueCopyArrayOfAllValues(emailRecord).takeUnretainedValue() as NSArray
//                
//           
//                for email in allEmailIDs {
//                    var emailID = email as! String
//                    contactsArray.addObject(emailID)
//                    println ("contactEmail : \(emailID) ")
//                }
//            
//            }
        }
        contactsTableView.reloadData()
        
        
    }
    
    
   
    // MARK:Tableview datasource and delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if contactsArray.count>0 {
            return contactsArray.count
        }
        else{
            return 0
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = contactsArray.objectAtIndex(indexPath.row) as? String
        
        return cell
    }
    
    // MARK:Helper Methods
    func promptForContactAccess() {
        
        var error: Unmanaged<CFError>? = nil
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    
                    println("Denied")
                    self.displayDeniedContactAlert()
                } else {
                    
                    println("Authorized")
                    self.fetchContactsList()
                }
            }
        }
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
}


