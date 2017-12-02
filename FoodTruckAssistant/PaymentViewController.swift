//
//  PaymentViewController.swift
//  FoodTruckAssistant
//
//  Created by 김은지 on 2017. 12. 2..
//  Copyright © 2017년 Suji. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    
    @IBOutlet var segCashCard: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 선택된 세그먼트 글자 색깔 검은색으로 바꾸기
        self.segCashCard.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: UIControlState.selected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
