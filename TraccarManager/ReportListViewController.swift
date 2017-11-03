//
//  ReportListViewController.swift
//  TraccarManager
//
//  Created by Sergey Kruzhkov on 30.09.2017.
//  Copyright © 2017 Sergey Kruzhkov. All rights reserved.
//

import Foundation
import LGAlertView
import UIKit

struct list {
    var image: String
    var name: String
    var ind: Int
}

class ReportListViewController: UITableViewController, LGAlertViewDelegate {
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
        lists.append(list.init(image: "", name: "Summary", ind: 0))
        
        return lists
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if listItemsOther[indexPath.row].ind == 0 {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ReportViewControllerStoryboard")  as! ReportViewController
            vc.typeReport = "Summary"
            navigationController!.pushViewController(vc, animated: true)
        }
        
    }
}
