//
// Copyright 2016 William Pearse (w.pearse@gmail.com)
// Copyright 2017 Sergey Kruzhkov (s.kruzhkov@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class DevicesViewController: UITableViewController {
    
    var devices: [Device]?
    var delegate: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update the list when we're told that a Position has been updated (this is the "Updated ... ago" message)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DevicesViewController.reloadDevices),
                                               name: NSNotification.Name(rawValue: Definitions.PositionUpdateNotificationName),
                                               object: nil)
        
        // update the list when a Device has been updated (maybe the name has changed, or an addition/removal of a device)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DevicesViewController.reloadDevices),
                                               name: NSNotification.Name(rawValue: Definitions.DeviceUpdateNotificationName),
                                               object: nil)
        
        if Definitions.isRunningOniPad {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                     target: self,
                                                                     action: #selector(DevicesViewController.close))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadDevices()
    }
    
    @objc func reloadDevices() {
        devices = WebService.sharedInstance.devices
        tableView.reloadData()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = devices {
            return d.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let d = devices {
            let device = d[(indexPath as NSIndexPath).row]
            
            cell.textLabel!.text = device.name!
            
            var lu = device.mostRecentPositionTimeString
            if lu.characters.count > 0 {
                lu = lu.lowercased()
                cell.detailTextLabel!.text = "Updated \(lu) ago"
            } else {
                cell.detailTextLabel!.text = ""
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let d = devices {
            delegate?.selectedDevice = d[(indexPath).row]
            delegate?.zoomDevice()
        }
        _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: true) {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDeviceInfo", sender: indexPath)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DeviceInfoViewController {
            let idxp = sender as? IndexPath
            if let d = devices {
                if idxp != nil {
                    dvc.device = d[(idxp! as NSIndexPath).row]
                }
            }
        }
    }
}
