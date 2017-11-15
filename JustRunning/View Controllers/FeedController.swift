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

class FeedController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = CoreDataStack.context
    var runs: [Run] = []
    
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
        
        super.viewDidLoad()
        tableView.register(UINib(nibName: "RunCell", bundle: nil), forCellReuseIdentifier: "runCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "runCell") as! RunCell
        
        let run = runs[indexPath.row]
        
        let distance = Measurement(value: run.distance, unit: UnitLength.meters)
        let seconds = Int(run.duration)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(run.timestamp)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        
        cell.lblDate.text = formattedDate
        cell.lblPace.text = formattedPace
        cell.lblTime.text = formattedTime
        cell.lblDistance.text = formattedDistance
        cell.btnDelete.addTarget(self, action: #selector(FeedController.actionDelete(_:)), for: .touchUpInside)
        
        cell.btnDelete.tag = indexPath.row
        return cell
    }
    
    @objc func actionDelete(_ sender: UIButton) {
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) { action -> Void in
            
            let run = self.runs[sender.tag]
            self.context.delete(run)
            CoreDataStack.saveContext()
            
            do {
                self.runs = try self.context.fetch(Run.fetchRequest())
            }
            catch {
                print("Fetching Failed")
            }
            
            self.tableView.reloadData()
        }
        actionSheetController.addAction(deleteAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func getData() {
        do {
            runs = try context.fetch(Run.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    
//    private func loadMap(run: Run) {
//        guard
//            let locations = run.locations,
//            locations.count > 0,
//            let region = mapRegion(run: run)
//            else {
//                let alert = UIAlertController(title: "Error",
//                                              message: "Sorry, this run has no locations saved",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
//                present(alert, animated: true)
//                return
//        }
//
//        mapView.setRegion(region, animated: true)
//        mapView.addOverlays(polyLine())
//    }
//
//    private func mapRegion(run: Run) -> MKCoordinateRegion? {
//        guard
//            let locations = run.locations,
//            locations.count > 0
//            else {
//                return nil
//        }
//
//        let latitudes = locations.map { location -> Double in
//            let location = location as! Location
//            return location.latitude
//        }
//
//        let longitudes = locations.map { location -> Double in
//            let location = location as! Location
//            return location.longitude
//        }
//        
//        let maxLat = latitudes.max()!
//        let minLat = latitudes.min()!
//        let maxLong = longitudes.max()!
//        let minLong = longitudes.min()!
//
//        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
//                                            longitude: (minLong + maxLong) / 2)
//        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
//                                    longitudeDelta: (maxLong - minLong) * 1.3)
//        return MKCoordinateRegion(center: center, span: span)
//    }
//
//    private func polyLine() -> [MulticolorPoly] {
//        
//        // 1
//        let locations = run.locations?.array as! [Location]
//        var coordinates: [(CLLocation, CLLocation)] = []
//        var speeds: [Double] = []
//        var minSpeed = Double.greatestFiniteMagnitude
//        var maxSpeed = 0.0
//
//        // 2
//        for (first, second) in zip(locations, locations.dropFirst()) {
//            let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
//            let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
//            coordinates.append((start, end))
//
//            //3
//            let distance = end.distance(from: start)
//            let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
//            let speed = time > 0 ? distance / time : 0
//            speeds.append(speed)
//            minSpeed = min(minSpeed, speed)
//            maxSpeed = max(maxSpeed, speed)
//        }
//        
//        //4
//        let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
//
//        //5
//        var segments: [MulticolorPoly] = []
//        for ((start, end), speed) in zip(coordinates, speeds) {
//            let coords = [start.coordinate, end.coordinate]
//            let segment = MulticolorPoly(coordinates: coords, count: 2)
//            segment.color = segmentColor(speed: speed,
//                                         midSpeed: midSpeed,
//                                         slowestSpeed: minSpeed,
//                                         fastestSpeed: maxSpeed)
//            segments.append(segment)
//        }
//        return segments
//    }
}
