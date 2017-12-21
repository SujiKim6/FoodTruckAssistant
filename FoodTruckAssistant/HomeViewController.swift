//
//  HomeViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    @IBOutlet var labelDate: UILabel!
    @IBOutlet var todayOrderTableView: UITableView!
    @IBOutlet var buttonStart: UIButton!
    
    var currentOrderList:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelDate.text = "영업 시작 버튼을 누르세요"
    }
    
    /* view가 보여질 때 자료를 DB에서 가져오기, 오늘 주문 받은 것 중에서 아직 다하지 못한 주문을 나타내주기 */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 영업 시작을 한 경우 가져와서 보여주기
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.start {
            // Order List에서 자료 가져오고 보여주기
            let context = self.getContext()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OrderList")
            
            // 자료들 중에서 제조완료 되지 않은 것만 추출하기
            fetchRequest.predicate = NSPredicate(format: "done = %@", "false")
            
            // 주문번호로 정렬
            let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            
            do {
                currentOrderList = try context.fetch(fetchRequest)
                
            } catch let error as NSError {
                print("Could not fetch.  \(error),  \(error.userInfo)")
            }
            
            self.todayOrderTableView.reloadData()

        }
    }
    
    /* 영업 시작 버튼을 누르면 OrderList DB 비워주기, 주문번호 초기화, 날짜가 나오는 label 당일 날짜로 업데이트 */
    @IBAction func buttonStartSales() {
        
        // 주문번호 초기화 및 영업시작과 관련된 변수를 true로 바꾸기
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orderNum = 0
        appDelegate.start = true
        
        // 영업 시작 이후에 영업시작버튼을 잘 못 다시 누를 경우를 대비하여 사용자가 사용할 수 없게 하기
        // 영업 시작한 다음 부터는 영업종료 이전까지는 다시 누를 수 없다.
        buttonStart.isEnabled = false
        
        // OrderList Core Data내에 저장된 모든 내용 삭제
        let context = self.getContext()
    
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderList")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Success Delete")
        } catch {
            print ("Delete Fail")
        }
        
        // DaySales Core Data내에 저장된 모든 내용 삭제
        let contextDaySales = self.getContext()
        
        let deleteFetchDaySales = NSFetchRequest<NSFetchRequestResult>(entityName: "DaySales")
        let deleteRequestDaySales = NSBatchDeleteRequest(fetchRequest: deleteFetchDaySales)
        do {
            try contextDaySales.execute(deleteRequestDaySales)
            try contextDaySales.save()
            print("Success Delete")
        } catch {
            print ("Delete Fail")
        }
        

        
        // 당일 날짜로 출력하기
        let currentDate = Date()
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let displayDate = formatter.string(from: currentDate as Date)
        labelDate.text = displayDate
        
    }
    
    /* 영업이 종료 버튼을 눌렀을 때의 처리 */
    @IBAction func buttonEndSales() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.start = false
        
        // 영업종료 이후에 영업시작버튼을 언제든지 누를 수 있게 사용자가 접근 가능하게 한다.
        buttonStart.isEnabled = true
        
        
        // 주문 목록 가져오기
        var orderedList:[NSManagedObject] = []
        let contextOrder = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OrderList")
        
        // 주문번호로 정렬
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            orderedList = try contextOrder.fetch(fetchRequest)
            print("Fetching OrderList Success")
            
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }
        
        // OrderList DB에서 orderedMenu를 가져와서 나누기 / finalMenu는 메뉴이름:주문개수 형식으로 딕셔너리를 저장
        var finalMenu:[String:String] = [:]
        var count = 0
        for i in 0..<orderedList.count {
            let totalOrder = orderedList[i].value(forKey: "orderedMenu") as? String
            var sepTotalOrder = totalOrder!.components(separatedBy: "/")
            for j in 0..<sepTotalOrder.count-1 {
                var sepSepTotalOrder = sepTotalOrder[j].components(separatedBy: ":")
                if finalMenu[sepSepTotalOrder[0]] != nil {
                    count = Int(finalMenu[sepSepTotalOrder[0]]!)! + Int(sepSepTotalOrder[1])!
                    finalMenu[sepSepTotalOrder[0]] = String(count)
                }
                else {
                    finalMenu[sepSepTotalOrder[0]] = sepSepTotalOrder[1]
                }
            }
        }
        
        // MenuListDB에서 메뉴에 따른 가격을 가져온다.
        var menuInfo:[NSManagedObject] = []
        let contextMenuInfo = self.getContext()
        let fetchRequestMenuInfo = NSFetchRequest<NSManagedObject>(entityName: "MenuList")
        do {
            menuInfo = try contextMenuInfo.fetch(fetchRequestMenuInfo)
            print("Fetching MenuList Success")
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }
        
        // 가져온 데이터를 [String:String]형태(메뉴이름:가격)의 딕셔너리로 바꾼다.
        var dicMenuInfo:[String:String] = [:]
        for i in 0..<menuInfo.count {
            dicMenuInfo[(menuInfo[i].value(forKey: "menuName") as? String)!] = menuInfo[i].value(forKey: "price") as? String
        }
        
        // finalMenu의 key값을 따로 배열로 저장
        var finalMenuKeys = Array(finalMenu.keys)
        
        for i in 0..<finalMenu.count {
            // finalMenu에 있는 메뉴의 가격을 알아온다.
            let menuPrice = dicMenuInfo[finalMenuKeys[i]]
            
            // 메뉴주문개수와 가격을 곱하여 그 메뉴의 하루 매출을 가져온다
            let totalAmount = Int(menuPrice!)! * Int(finalMenu[finalMenuKeys[i]]!)!
            
            // DaySales DB에 저장한다
            let contextDaySales = self.getContext()
            let entity = NSEntityDescription.entity(forEntityName: "DaySales", in: contextDaySales)
            let object = NSManagedObject(entity: entity!, insertInto: contextDaySales)
            
            object.setValue(labelDate.text, forKey: "date")
            object.setValue(finalMenuKeys[i], forKey: "menuName")
            object.setValue(String(totalAmount), forKey: "totalSell")
            object.setValue(finalMenu[finalMenuKeys[i]], forKey: "totalCount")
            
            do {
                try contextDaySales.save()
            } catch let error as NSError {
                print("Could not fetch.  \(error),  \(error.userInfo)")
            }
        }
        
        labelDate.text = "영업 종료하셨습니다."
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    /* 현재 해야할 주문 목록들을 보여주는 테이블 구성 */
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int {
        return currentOrderList.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell {
        let cell = self.todayOrderTableView.dequeueReusableCell(withIdentifier: "OrderList Cell", for: indexPath)
        
        if currentOrderList.count != 0 {
            let getOrderNum = currentOrderList[indexPath.row].value(forKey: "number") as! String
            let getOrderDetail = currentOrderList[indexPath.row].value(forKey: "orderedMenu") as! String
            
            cell.textLabel?.text = getOrderNum
            cell.detailTextLabel?.text = getOrderDetail
        }
        
        return cell
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 메뉴에 대한 상세화면으로 넘어갈 때의 내용 전달
        if segue.identifier == "toOrderDetail" {
            if let destination = segue.destination as? ShowOrderViewController {
                if let selectedIndex = self.todayOrderTableView.indexPathsForSelectedRows?.first?.row {
                    destination.detailOrder = currentOrderList[selectedIndex]
                }
            }
        }
    }
    

}
