//
//  SalesTableViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class SalesTableViewController: UITableViewController {
    
    // 일 매출에 대해서 저장하는 변수
    var dailySales:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DaySales DB를 가져오기
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DaySales")
        
        // 자료들 중에서 제조완료 되지 않은 것만 추출하기
        // 당일 날짜로 출력하기
        let currentDate = Date()
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let displayDate = formatter.string(from: currentDate as Date)
        
        fetchRequest.predicate = NSPredicate(format: "date = %@", displayDate)
    
        let sortDescriptor = NSSortDescriptor(key: "menuName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            dailySales = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // DaySales DB를 가져오기
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DaySales")
        
        // 자료들 중에서 제조완료 되지 않은 것만 추출하기
        // 당일 날짜로 출력하기
        let currentDate = Date()
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let displayDate = formatter.string(from: currentDate as Date)
        
        fetchRequest.predicate = NSPredicate(format: "date = %@", displayDate)
        
        let sortDescriptor = NSSortDescriptor(key: "menuName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            dailySales = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dailySales.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Sales Cell", for: indexPath)

        // Configure the cell...

        cell.textLabel?.text = dailySales[indexPath.row].value(forKey: "menuName") as? String
        cell.detailTextLabel?.text = dailySales[indexPath.row].value(forKey: "totalCount") as? String
        
        return cell
    }
    
    // 테이블의 섹션의 제목을 지정 -> 날짜를 보여준다.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dailySales.count != 0 {
            return (dailySales[section].value(forKey: "date") as? String)! + "의 매출"
        }
        else {
            return "오늘의 매출"
        }
    }
    
    // 테이블의 섹션의 푸터를 지정 -> 총 하루 매출을 보여준다
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if dailySales.count != 0 {
            var totalSales = 0
            for i in 0..<dailySales.count {
                totalSales += Int((dailySales[i].value(forKey: "totalSell") as? String)!)!
            }
            return "총 \(totalSales)원"
        }
        else {
            return "총 매출 액"
        }
    }
    
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
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
