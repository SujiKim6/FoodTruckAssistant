//
//  AddMenuViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class AddMenuViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var textMenuTitle: UITextField!
    @IBOutlet var textMenuPrice: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func buttonAddMenu() {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "MenuList", in: context)
        
        let object = NSManagedObject(entity: entity!, insertInto: context)
        
        object.setValue(textMenuTitle.text, forKey: "menuName")
        object.setValue(textMenuPrice.text, forKey: "price")
        
        do {
            try context.save()
            print("saved")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
