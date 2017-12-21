//
//  PaymentViewController.swift
//  FoodTruckAssistant
//
//  Created by 김수지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit
import CoreData

class PaymentViewController: UIViewController {
    
    
    @IBOutlet var segCashCard: UISegmentedControl!
    @IBOutlet var totalAmountOfOrder: UILabel!
    @IBOutlet var showOrderTableView: UITableView!
    
    @IBOutlet var add100: UIButton!
    @IBOutlet var add500: UIButton!
    @IBOutlet var add1000: UIButton!
    @IBOutlet var add5000: UIButton!
    @IBOutlet var add10000: UIButton!
    @IBOutlet var add50000: UIButton!
    
    @IBOutlet var labelPaid: UILabel!
    @IBOutlet var labelChange: UILabel!
    
    @IBOutlet var viewForCard: UIView!

    typealias MenuDetail = (Count:String, Price:String)
    var newOrders:[String:MenuDetail] = [:] // 메뉴이름과 (메뉴주문개수와 메뉴가격)의 정보를 담고 있는 튜플을 가지는 딕셔너리
    
    /* 주문 내역들에 대한 총 금액 전 화면에서 가져오기 */
    var totalPrice:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 선택된 세그먼트 글자 색깔 검은색으로 바꾸기
        self.segCashCard.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: UIControlState.selected)
        
        // 총 금액 보여주기
        totalAmountOfOrder.text = totalPrice
        
        // 처음에 시작되었을 때, 현금을 아예 안받은 상태이므로 "-총금액"으로 표시해준다.
        labelChange.text = "-" + totalPrice
    }

    /* 계산까지 완료했을 경우 OrderList DB에 저장하고 제일 첫화면으로 돌아가기 */
    @IBAction func buttonEnd(_ sender: Any) {
        // 영업이 시작된 경우에만 작동
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.start {
            // 돈을 제대로 받지 못했을 경우 화면전환하지 않고 경고창 띄우기
            let checkChange = Int(labelChange.text!)
            if checkChange! < 0 {
                let dialog = UIAlertController(title: "오류", message: "현금이 부족합니다", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
                dialog.addAction(action)
                
                self.present(dialog, animated: true, completion: nil)
            }
            // 계산까지 완료했을 경우 OrderList DB에 저장하고 제일 첫화면으로 돌아가기
            else {
                // OrderListDB에 저장할 수 있도록 주문 목록들 한 줄로 저장 (OrderList DB의 orderedMenu 애트리뷰트에 들어갈 값)
                var willOrderMenu:String = ""

                for addOrder in newOrders {
                    let menuName = addOrder.key
                    let menuDetail = addOrder.value
                    willOrderMenu += menuName + ":" + menuDetail.Count + "/"
                }
                
                // 주문번호 가져오기
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.orderNum += 1
                
                // OrderListDB에 저장하기
                let context = getContext()
                let entity = NSEntityDescription.entity(forEntityName: "OrderList", in: context)
                
                let object = NSManagedObject(entity: entity!, insertInto: context)
                
                object.setValue(String(appDelegate.orderNum), forKey: "number")
                object.setValue(willOrderMenu, forKey: "orderedMenu")
                object.setValue(totalPrice, forKey: "totalPrice")
                object.setValue(false, forKey: "done")
                
                do {
                    try context.save()
                    print("saved Success in OrderList")
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        // 영업시작을 안눌렀을 경우 그냥 첫화면으로 돌아가기
        else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    /* 앞서 주문한 내역들을 Table view에 보여주기 */
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int {
        return newOrders.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell {
        let cell = self.showOrderTableView.dequeueReusableCell(withIdentifier: "Calculate Cell", for: indexPath)
        
        if newOrders.count != 0 {
            let menuNames = Array(newOrders.keys)
            let menuDetails = Array(newOrders.values)
            cell.textLabel?.text = menuNames[indexPath.row] + " * " + menuDetails[indexPath.row].Count
            let menuTotal = Int(menuDetails[indexPath.row].Count)! * Int(menuDetails[indexPath.row].Price)!
            cell.detailTextLabel?.text = String(menuTotal)
        }
        
        return cell
    }
    
    /* 현금 계산할 때 금액 눌렀을 때의 처리 -> 잔돈 계산 */
    @IBAction func buttonBanknotes(_ sender: UIButton) {
        // 영업이 시작된 경우에만 작동
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.start {
            //소비자로부터 받은 금액에 따라 받은 금액과 잔돈 계산
            let amount = Int(labelPaid.text!)
            var value = amount!
            switch sender {
            case add100:
                value += 100
            case add500:
                value += 500
            case add1000:
                value += 1000
            case add5000:
                value += 5000
            case add10000:
                value += 10000
            case add50000:
                value += 50000
            default:
                break
            }
            labelPaid.text = String(value)
            let checkChange = value - Int(totalPrice)!
            labelChange.text = String(checkChange)
        }
    }

    /* 카드 또는 현금 둘중에 하나의 세그먼트를 선택했을 때의 처리 */
    @IBAction func selectCashOrCard(_ sender: UISegmentedControl) {
        // 영업이 시작된 경우에만 작동
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.start {
            // 현금 결제 선택시, 서브뷰를 숨기고 받은 현금을 0에서 부터 시작하도록 입력, 잔돈은 "-총금액"으로 설정해준다.
            if sender.selectedSegmentIndex == 0 {
                viewForCard.isHidden = true
                labelPaid.text = "0"
                labelChange.text = "-"+totalPrice
            }
            // 카드 결제 선택시, 서브뷰를 보여주고 카드 결제의 경우 잔돈이 0원이므로 0을 입력
            else {
                viewForCard.isHidden = false
                labelChange.text = "0"
            }
        }
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
