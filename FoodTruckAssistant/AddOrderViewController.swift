//
//  AddOrderViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class AddOrderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var menuPicker: UIPickerView!
    @IBOutlet var orderListTableView: UITableView!
    
    
    // picker에 값을 넣기 위한 변수들
    var menuList:[NSManagedObject] = []
    let number = ["1","2","3","4","5","6","7","8","9","10"]
    
    
    // 주문 목록 테이블에 띄울 때와 총 금액을 계산할 때 사용될 변수
    var totalAmount:String = "" // 총 금액 저장
    
    typealias MenuDetail = (Count:String, Price:String)
    var menuPrices:[String:MenuDetail] = [:] // 메뉴이름과 (메뉴주문개수와 메뉴가격)의 정보를 담고 있는 튜플을 가지는 딕셔너리

    /* DB에서 피커에 뿌려줄 메뉴 목록 가져오기 */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Menu List에서 자료 가져오고 보여주기
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MenuList")
        
        let sortDescriptor = NSSortDescriptor(key: "menuName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            menuList = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch.  \(error),  \(error.userInfo)")
        }

    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    
    /* Picker에 메뉴 목록들 띄워주기 */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return menuList.count
        }
        else {
            return number.count
        }
    }

    /* 각 picker에 각 데이터들 정의 및 글자크기 지정 */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13.0)
        
        // 메뉴 이름 출력
        if component == 0 {
            label.text = menuList[row].value(forKey: "menuName") as? String
        }
        else {
            label.text = number[row]
        }
        return label
    }

    
    /* 추가버튼을 누르면 내용을 newOrderList변수에 저장하기 / 선택된 메뉴이름과 개수와 가격저장 */
    @IBAction func addOrder() {
        // 영업이 시작된 경우에만 작동
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.start {
            if let selectedMenu = menuList[menuPicker.selectedRow(inComponent: 0)].value(forKey: "menuName") as? String {
                let numOfMenu = number[menuPicker.selectedRow(inComponent: 1)]
                
                // 선택된 메뉴이름과 개수와 가격저장
                if let selectedPrice = menuList[menuPicker.selectedRow(inComponent: 0)].value(forKey: "price") as? String {
                    menuPrices[selectedMenu]=(numOfMenu,selectedPrice)
                }
            }
            
            orderListTableView.reloadData()
        }
    }
    
    /* Picker에서 추가한 메뉴를 Table view에 보여주기 */
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int {
        return menuPrices.count
    }

    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell {
        let cell = self.orderListTableView.dequeueReusableCell(withIdentifier: "Order Cell", for: indexPath)
        
        if menuPrices.count != 0 {
            let menuNames = Array(menuPrices.keys)
            let menuDetails = Array(menuPrices.values)
            
            cell.textLabel?.text = menuNames[indexPath.row]
            cell.detailTextLabel?.text = menuDetails[indexPath.row].Count
        }
    
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* 계산하기 버튼을 눌렀을 떄 -> 계산 UI 로 값들 넘겨주기 */
        if segue.identifier == "toCalculate" {
            // 영업이 시작된 경우에만 작동
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.start {
                // 주문된 음식에 대한 메뉴의 총 가격 계산하기
                var calSum = 0

                for sumUp in menuPrices.values {
                    let sum = Int(sumUp.Count)! * Int(sumUp.Price)!
                    calSum += sum
                }
                
                totalAmount = String(calSum)
            }
            
            // 계산 UI 로 값들 넘겨주기
            let destination = segue.destination as! PaymentViewController
            destination.newOrders = menuPrices
            destination.totalPrice = totalAmount
        }
    }
    

}
