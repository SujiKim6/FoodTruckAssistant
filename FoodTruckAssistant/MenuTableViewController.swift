//
//  MenuTableViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController {
    
    var menuList:[NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    }
    
    // view가 보여질 때 자료를 DB에서 가져오도록 한다.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 자료 가져오고 보여줌
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MenuList")
        
        // 메뉴 이름으로 정렬
        let sortDescriptor = NSSortDescriptor(key: "menuName", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            menuList = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }
        
        
        self.tableView.reloadData()
        
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Menu Cell", for: indexPath)

        // Configure the cell...
        if let menuDisplay = menuList[indexPath.row].value(forKey: "menuName") as? String {
            cell.textLabel?.text = menuDisplay
        }
        if let priceDisplay = menuList[indexPath.row].value(forKey: "price") as? String {
            cell.detailTextLabel?.text = priceDisplay
        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Core Data 내의 해당 자료 삭제
            let context = getContext()
            context.delete(menuList[indexPath.row])
            do {
                try context.save()
                print("deleted!")
            } catch let error as NSError {
                print("Could not delete  \(error),  \(error.userInfo)")
            }
            // 배열에서 해당 자료 삭제
            menuList.remove(at: indexPath.row)
            
            // 화면에서 셀 지우기
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
