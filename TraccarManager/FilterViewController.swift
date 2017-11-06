//
//  FilterViewController.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 01.10.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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

        let alert = UIAlertController(title: "From", message: "", preferredStyle: .alert)
        
        let datePicker = UIDatePicker(frame: CGRect.init(x: 10, y: 50, width: 250, height: 120))
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.date = fromDate
        
        alert.view.addSubview(datePicker)
        
        let consh = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: datePicker, attribute: NSLayoutAttribute.height, multiplier: 1.00, constant: 130)
        alert.view.addConstraint(consh)
        
        let consw = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: datePicker, attribute: NSLayoutAttribute.width, multiplier: 1.00, constant: 20)
        alert.view.addConstraint(consw)
        
        let btnOK = UIAlertAction(title: "OK", style: .default, handler: {action in
            self.fromDate = datePicker.date
            self.setButtonTitle()
        })
        alert.addAction(btnOK)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func pressButtonToPeriod(_ sender: Any) {
        
        let alert = UIAlertController(title: "To", message: "", preferredStyle: .alert)
        
        let datePicker = UIDatePicker(frame: CGRect.init(x: 10, y: 50, width: 250, height: 120))
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.date = toDate
        
        alert.view.addSubview(datePicker)
        
        let consh = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: datePicker, attribute: NSLayoutAttribute.height, multiplier: 1.00, constant: 130)
        alert.view.addConstraint(consh)
        
        let consw = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: datePicker, attribute: NSLayoutAttribute.width, multiplier: 1.00, constant: 20)
        alert.view.addConstraint(consw)
        
        let btnOK = UIAlertAction(title: "OK", style: .default, handler: {action in
            self.toDate = datePicker.date
            self.setButtonTitle()
        })
        alert.addAction(btnOK)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
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
