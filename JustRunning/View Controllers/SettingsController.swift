//
//  SettingsController.swift
//  Just Running
//
//  Created by Ben Porter on 11/17/17.
//  Copyright © 2017 Ben Porter. All rights reserved.
//





//
//  FeedController.swift
//  Just Running
//
//  Created by Ben Porter on 11/14/17.
//  Copyright © 2017 Ben Porter. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SettingsController: UITableViewController {
    
    
//    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
        
        super.viewDidLoad()
        
//        tableView.delegate = self
//        tableView.dataSource = self
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
//        getData()
        tableView.reloadData()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return runs.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "runCell") as! RunCell
//
//        let run = runs[indexPath.row]
//
//        let distance = Measurement(value: run.distance, unit: UnitLength.meters)
//        let seconds = Int(run.duration)
//        let formattedDistance = FormatDisplay.distance(distance)
//        let formattedDate = FormatDisplay.date(run.timestamp)
//        let formattedTime = FormatDisplay.time(seconds)
//        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
//
//        cell.lblDate.text = formattedDate
//        cell.lblPace.text = formattedPace
//        cell.lblTime.text = formattedTime
//        cell.lblDistance.text = formattedDistance
////        cell.btnDelete.addTarget(self, action: #selector(FeedController.actionDelete(_:)), for: .touchUpInside)
////        cell.btnDelete.tag = indexPath.row
//
//
//
//        return cell
//    }
    

    
    
    
    

    
    
}






