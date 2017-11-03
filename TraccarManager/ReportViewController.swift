//
//  ReportViewController.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 30.09.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import UIKit

class ReportViewController: UITableViewController {
    
    fileprivate var devices: [Device] = []
    
    var fromDate = Date()
    var toDate = Date()
    var tableData = [Summary]()
    var nameColumns = [String]()
    var keyColumns = [String]()
    var devicesCheck = [Bool]()
    var typeReport = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    
        refreshControl?.addTarget(self, action: #selector(self.getRequestStart), for: UIControlEvents.valueChanged)
        
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Image_filter"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.getFilter))
        self.navigationItem.rightBarButtonItem = button
        
        //fromDate = Calendar.current.date(byAdding: Calendar.Component.month, value: -1, to: Date())!
        
        let c = Calendar.current.dateComponents([.year, .month], from: Date())
        fromDate = Calendar.current.date(from: c)!
        
        toDate = Calendar.current.startOfDay(for: Date())
        toDate = Calendar.current.date(byAdding: Calendar.Component.day, value: 1, to: toDate)!
        toDate = Calendar.current.date(byAdding: Calendar.Component.second, value: -1, to: toDate)!
        
        //let m = Calendar.current.component(.month, from: FDOM)
        
        nameColumns.append("Name Device")
        nameColumns.append("Distance")
        nameColumns.append("Adverage Speed")
        nameColumns.append("Maximum Speed")
        nameColumns.append("Engine Hours")
        
        keyColumns.append("distance")
        keyColumns.append("averageSpeed")
        keyColumns.append("maxSpeed")
        keyColumns.append("engineHours")
        
        setMainTitle()
        
        refreshControl?.beginRefreshing()
        refreshDevices()
        
    }
    
    func setMainTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm"
        
        if Definitions.isRunningOniPad {
            self.title = typeReport + " " + formatter.string(from: fromDate) + "-" + formatter.string(from: toDate)
        } else {
            self.title = typeReport
        }
    }
    
    @objc func getFilter() {
        self.performSegue(withIdentifier: "ShowFilter", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFilter" {
            let vc = segue.destination as? FilterViewController
            vc?.devices = devices
            vc?.fromDate = fromDate
            vc?.toDate = toDate
            vc?.devicesCheck = devicesCheck
            vc?.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var cell: UITableViewCell
        if Definitions.isRunningOniPad {
            cell = tableView.dequeueReusableCell(withIdentifier: "cellSummary")!
            for i in 0...nameColumns.count - 1 {
                (cell.viewWithTag(i + 1) as! UILabel).text = nameColumns[i]
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            (cell.viewWithTag(1) as! UILabel).text = tableData[section].deviceName
            (cell.viewWithTag(2) as! UILabel).text = ""
        }
      
        cell.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if Definitions.isRunningOniPad {
            cell = tableView.dequeueReusableCell(withIdentifier: "cellSummary", for: indexPath) as UITableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        }
        
        
        if Definitions.isRunningOniPad {
            
            let dt = tableData[indexPath.row]
            
            (cell.viewWithTag(1) as! UILabel).text = dt.deviceName
            (cell.viewWithTag(2) as! UILabel).text = formatNumber.sharedInstance.string(from: NSNumber(value: Int(dt.distance! / 1000)))!
            (cell.viewWithTag(3) as! UILabel).text = formatNumber.sharedInstance.string(from: NSNumber(value: Int(dt.averageSpeed! * 1.852)))!
            (cell.viewWithTag(4) as! UILabel).text = formatNumber.sharedInstance.string(from: NSNumber(value: Int(dt.maxSpeed! * 1.852)))!
            (cell.viewWithTag(5) as! UILabel).text = formatNumber.sharedInstance.string(from: NSNumber(value: dt.engineHours!))!
            
        } else {
            let dt = tableData[indexPath.section]
            
            (cell.viewWithTag(1) as! UILabel).text = nameColumns[indexPath.row + 1]
            if indexPath.row == 0 {
                (cell.viewWithTag(2) as! UILabel).text  = formatNumber.sharedInstance.string(from: NSNumber(value: Int(dt.distance! / 1000)))!
            } else if indexPath.row == 1 {
                (cell.viewWithTag(2) as! UILabel).text  = formatNumber.sharedInstance.string(from: NSNumber(value: Int(dt.averageSpeed! * 1.852)))!
            } else if indexPath.row == 2 {
                (cell.viewWithTag(2) as! UILabel).text  = formatNumber.sharedInstance.string(from: NSNumber(value: Int(dt.maxSpeed! * 1.852)))!
            } else if indexPath.row == 3 {
                (cell.viewWithTag(2) as! UILabel).text  = formatNumber.sharedInstance.string(from: NSNumber(value: dt.engineHours!))!
            } else {
                (cell.viewWithTag(2) as! UILabel).text  = ""
            }
            
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if Definitions.isRunningOniPad {
            return  (tableData.count == 0) ? 0 : 1
        } else {
            return tableData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Definitions.isRunningOniPad {
            return tableData.count
        } else {
            return (tableData.count == 0) ? 0 : 4
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    @objc func getRequestStart() {
        
        tableData = [Summary]()
        tableView.reloadData()
        
        refreshControl?.beginRefreshing()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let from = formatter.string(from: fromDate)
        let to = formatter.string(from: toDate)
        
        var dev = "?"
//        for d in devices {
//            dev += "deviceId=" + (d.id?.stringValue)! + "&"
//        }
        for i in  0...devicesCheck.count - 1 {
            if devicesCheck[i] {
                dev += "deviceId=" + (devices[i].id?.stringValue)! + "&"
            }
        }
        
        let strReq = dev + "from=" + from + "&to=" + to
        
        WebService.sharedInstance.getSummaryData(filter: strReq, urlPoint: "", onFailure: { errorString in
            
            DispatchQueue.main.async(execute: {
                
                let ac = UIAlertController(title: "Ошибка запроса", message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                ac.addAction(okAction)
                self.present(ac, animated: true, completion: nil)
                
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                
            })
            
        }, onSuccess: { (model) in
            
            DispatchQueue.main.async(execute: {
                
                self.tableData = model
                
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                
            })
        }
        )
    }
    
    @objc func refreshDevices() {
        
        WebService.sharedInstance.fetchDevices(onSuccess: { (newDevices) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.devices = newDevices
            
            self.devicesCheck = [Bool]()
            for _ in self.devices {
                self.devicesCheck.append(false)
            }
            
            self.performSegue(withIdentifier: "ShowFilter", sender: self)
        })
        
    }
}
