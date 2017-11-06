//
//  ReportListViewController.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 30.09.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import UIKit

enum typeReports: String {
    case Summary
    case Route
    case Events
    case Trips
    case Chart
}

struct list {
    var image: String
    var name: String
    var type: typeReports
}

class ReportListViewController: UITableViewController {
    var listItemsOther = [list]()
    
    override func viewDidLoad() {
        listItemsOther = listOther()
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        //(cell.viewWithTag(1) as! UIImageView).image = listItemsOther[indexPath.row].image
        (cell.viewWithTag(2) as! UILabel).text = listItemsOther[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItemsOther.count
    }
    
    func listOther() -> [list] {
        
        var lists = [list]()
        //lists.append(list.init(image: UIImage(named: "Image_layers")!, name: "Summary", ind: 0))
        lists.append(list.init(image: "", name: "Summary", type: typeReports.Summary))
        //lists.append(list.init(image: "", name: "Route", type: typeReports.Route))
        lists.append(list.init(image: "", name: "Events", type: typeReports.Events))
        //lists.append(list.init(image: "", name: "Trips", type: typeReports.Trips))
        //lists.append(list.init(image: "", name: "Chart", type: typeReports.Chart))
        
        return lists
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ReportViewControllerStoryboard")  as! ReportViewController
        vc.typeReport = listItemsOther[indexPath.row].type
        navigationController!.pushViewController(vc, animated: true)
    }
}
