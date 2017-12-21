//
//  ShowOrderViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class ShowOrderViewController: UIViewController {
    
    @IBOutlet var labelOrderNum: UILabel!
    @IBOutlet var labelMenuName: UILabel!
    @IBOutlet var labelMenuCount: UILabel!
    
    
    var detailOrder:NSManagedObject?

    /* 주문내역의 상세내용을 출력하기 및 제조완료버튼 눌렀을 시에 대한 처리 */
    override func viewDidLoad() {
        super.viewDidLoad()

        var seperate:[String] = []
        var seperateMenus:[String] = []
        var showMenuName:String = ""
        var showMenuCount:String = ""
        if let order = detailOrder {
            let menu = order.value(forKey: "orderedMenu") as! String
            labelOrderNum.text = order.value(forKey: "number") as! String + " 번"
            
            seperate = menu.components(separatedBy: "/")
        
            for i in 0..<seperate.count-1 {
                seperateMenus = seperate[i].components(separatedBy: ":")
                showMenuName += seperateMenus[0] + " : \n"
                showMenuCount += seperateMenus[1] + "개 \n"
            }
        }
        
        
        labelMenuName.text = showMenuName
        labelMenuCount.text = showMenuCount
        
    }

    
    /* 제조완료 버튼을 눌렀을 때, OrderListDB에 done 애트리뷰트의 값을 true로 업데이트 후 홈화면으로 돌아가기 */
    @IBAction func buttonCompleteMaking() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OrderList")
        fetchRequest.predicate = NSPredicate(format: "number = %@", detailOrder?.value(forKey: "number") as! String)
        
        do {
            var results = try context.fetch(fetchRequest)
            if results.count != 0 {
                let managedObject = results[0]
                managedObject.setValue(true, forKey: "done")
            }
            do {
                try context.save()
            } catch let err as NSError {
                print("Could not save \(err), \(err.userInfo)")
            }
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
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
