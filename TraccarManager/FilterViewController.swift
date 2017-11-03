//
//  FilterViewController.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 01.10.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import UIKit
import LGAlertView

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LGAlertViewDelegate {
    
    var devices: [Device] = []
    var fromDate = Date()
    var toDate = Date()
    var delegate: ReportViewController?
    var devicesCheck = [Bool]()
    
    
    @IBOutlet var buttonFromPeriod: UIButton!
    @IBOutlet var buttonToPeriod: UIButton!
    @IBOutlet var tableView: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonTitle()
    }
    
    func setButtonTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm"
        buttonFromPeriod.setTitle(formatter.string(from: fromDate), for: UIControlState.normal)
        buttonToPeriod.setTitle(formatter.string(from: toDate), for: UIControlState.normal)
    }
    
    @IBAction func pressButtonFromPeriod(_ sender: Any) {
    
        let datePicker = UIDatePicker(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 110))
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.date = fromDate
        
        let dialog = LGAlertView.init(viewAndTitle: "From", message: nil, style: LGAlertViewStyle.alert, view:datePicker, buttonTitles: ["OK"], cancelButtonTitle: "Отмена", destructiveButtonTitle: nil)
        
        dialog.tag = 1
        dialog.delegate = self
        dialog.showAnimated()
        
    }
    
    @IBAction func pressButtonToPeriod(_ sender: Any) {
     
        //let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 140))
        let datePicker = UIDatePicker(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 110))
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.date = toDate
        
        ///v.addSubview(datePicker)
        
        //let tm = UITextView.init()
        
        let dialog = LGAlertView.init(viewAndTitle: "To", message: nil, style: LGAlertViewStyle.alert, view: datePicker, buttonTitles: ["OK"], cancelButtonTitle: "Отмена", destructiveButtonTitle: nil)
        
        dialog.tag = 2
        dialog.delegate = self
        dialog.showAnimated()
        
    }
    
    func alertView(_ alertView: LGAlertView, clickedButtonAt index: UInt, title: String?) {
        let dtv = alertView.innerView as? UIDatePicker
        if alertView.tag == 1 {
            fromDate = (dtv?.date)!
        } else {
            toDate = (dtv?.date)!
        }
        setButtonTitle()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        devicesCheck[indexPath.row] = !devicesCheck[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if devicesCheck[indexPath.row] {
            (cell.viewWithTag(1) as! UIImageView).image = UIImage(named: "Image_tick_on")!
        } else {
            (cell.viewWithTag(1) as! UIImageView).image = UIImage(named: "Image_tick_off")!
        }
        (cell.viewWithTag(2) as! UILabel).text = devices[indexPath.row].name
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    @IBAction func pressCancelButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func pressOKButton(_ sender: Any) {
        delegate?.fromDate = fromDate
        delegate?.toDate = toDate
        delegate?.devicesCheck = devicesCheck
        delegate?.setMainTitle()
        self.dismiss(animated: true) {
            self.delegate?.refreshControl?.beginRefreshing()
            self.delegate?.getRequestStart()
        }
    }
    
   
}
