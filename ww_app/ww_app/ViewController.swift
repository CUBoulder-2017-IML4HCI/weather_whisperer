//
//  ViewController.swift
//  ww_app
//
//  Created by Mae Patton on 4/24/17.
//  Copyright © 2017 hcml. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
//import Foundation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var locationLabel: UILabel!
    var ref: FIRDatabaseReference!
    var location = ""
    var tempy = 0
    var counter = 0
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    
    ///This function only runs the first time the view loads when you start the app
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //the following code gets and loads in the saved location
        ///change back to not updated in firebase
        let ref = FIRDatabase.database().reference()
        let post : [String: String] = ["status": "updated"]
        ref.child("current_conditions").updateChildValues(post)
        if let place = UserDefaults.standard.string(forKey: "userPlace")
        {
            locationLabel.text! = place
        }else {
            locationLabel.text = "city, state"
        }
        
        location = locationLabel.text!
        reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let place = UserDefaults.standard.string(forKey: "userPlace")
        {
            locationLabel.text! = place
        }else {
            locationLabel.text = "city, state"
        }
        location = locationLabel.text!
        print("view will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
        if let place = UserDefaults.standard.string(forKey: "userPlace")
        {
            locationLabel.text! = place
        }else {
            locationLabel.text = "city, state"
        }
        location = locationLabel.text!
        reloadData()
        //startTimer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("disappearing")
    }


    override func shouldPerformSegue(withIdentifier identifier: String!, sender: Any!) -> Bool {
        //the colorSegue goes to the color view unless there is no location data
        //in that case it shows a warning
        if(identifier == "colorSegue") {
             if (location == "city, state") {
                let alert=UIAlertController(
                    title: "No Location", message: "Please enter a city and state", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction=UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(cancelAction)//adds alert action to alert object
                let okAction=UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                    //action after pressing ok
                })
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
             
                return false
             }
             
             else {
                return true
             }
        }//the location segue brings up the change location popup
        else if(identifier == "locationSegue"){ //to change the city and state
            print("location segue")
            return true
        }
        else if(identifier == "locationSeg"){ //to change the city and state
            print("location segue 2")
            return true
        }
        //transition
        return true
        }
    
    //The on button should be disabled until there are at least 5 test points
    @IBAction func onButton(_ sender: UIButton) {
        //doesn't work without city or state data
        if(location == "city, state"){
            print("no city state data")
            let alert=UIAlertController(title: "Warning", message: "You must enter a city and state first", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction=UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancelAction) //adds the alert action to the alert object
            let okAction=UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                //after pressing ok action
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        else{
        //get count from firebase
            ref.child("info").observeSingleEvent(of: .value, with: { (snapshot) in
                let count = snapshot.value as? NSDictionary
                let status = count?["count"] as? String ?? "" //this will be ON or OFF
                self.counter = Int(status)!
         if(self.counter <= 5){
            //button = disabled
            //warnign saying need more data
            let alert=UIAlertController(title: "Not Enough Data", message: "Please enter more training data.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction=UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancelAction) //adds the alert action to the alert object
            let okAction=UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                //after pressing ok action
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
         }
         else{ //this is to turn the lamp on/off
            let ref = FIRDatabase.database().reference()
            ref.child("info").observeSingleEvent(of: .value, with: { (snapshot) in
            let state = snapshot.value as? NSDictionary
            let status = state?["led_state"] as? String ?? "" //this will be ON or OFF
            if(status == "ON" || status == "limbo"){
                let post : [String: String] = ["led_state": "OFF"]
                let post2 : [String: String] = ["pi_command": "off"]
                ref.child("info").updateChildValues(post) //update the state
                ref.child("info").updateChildValues(post2) //update the pi status
            }
            else if(status == "OFF"){
                let post : [String: String] = ["led_state": "ON"]
                let post2 : [String: String] = ["pi_command": "on"]
                ref.child("info").updateChildValues(post) //update the state
                ref.child("info").updateChildValues(post2) //update the pi status
            }
         
            })
            
         }
        })
        reloadData()
        }
    }
    
    ///This checks every so often to see if info has been updated
    
    /*weak var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.test()// do something here
        }
    }*/
    
    func test() {
        //check if on
        //check to see if status is updated
        print("checking for updates")
        ref = FIRDatabase.database().reference()
        ref.child("info").observeSingleEvent(of: .value, with: { (snapshot) in
            let status = snapshot.value as? NSDictionary
            let state = status?["led_state"] as? String ?? ""
            if(state == "limbo"){
                print("lamp is on")
                self.ref.child("current_conditions").observeSingleEvent(of: .value, with: { (snapshot) in
                    let cur = snapshot.value as? NSDictionary
                    let stat = cur?["status"] as? String ?? ""
                    if(stat == "updated"){
                        print("current info has been updated")
                        self.reloadData()
                    }
                    else{print("current info not updated")}
                })
            }
            else{print("lamp is not on")}
        })
    }
    
    func reloadData() {
        print("trying to reload")
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)//getting the hour to adjust based on time
        //getting the location for when the saved location is changed
        ///Firebase info begins here
        ref = FIRDatabase.database().reference()
        //when there is no city or state, we don't want to add data
        if(locationLabel.text == "city, state"){
            print("no weather info to update becuase no location")
            return
        }
        else{
            //we are searching firebase for the current conditions
            ref.child("current_conditions").observeSingleEvent(of: .value, with: { (snapshot) in
                let cur = snapshot.value as? NSDictionary
                var stat = cur?["status"] as? String ?? ""
                if(stat != "updated"){self.reloadData()}
                self.ref.child("current_conditions").observeSingleEvent(of: .value, with: { (snapshot) in
                    let new = snapshot.value as? NSDictionary
                    stat = new?["status"] as? String ?? ""
                print("got the updated info")
                let temp = new?["temp"] as? String ?? ""
                let weatherS = new?["weather"] as? String ?? ""
                let wind = new?["wind"] as? String ?? ""
                let data = new?["learn"] as? String ?? ""
                
                self.tempLabel.text = temp+"º"
                self.weatherLabel.text = weatherS
                self.windLabel.text = wind+" mph"
                self.dataLabel.text = data
                self.tempy = Int(temp)!
                
                //i'm not doing anything with the temperature switch right now...
                switch (self.tempy)
                {
                case -50...32:
                    print("cold")
                    //self.view.backgroundColor = UIColor(red: 156/255, green: 171/255, blue: 158/255, alpha: 10/10)
                //blue?
                case 33...56:
                    print("okay")
                    //self.view.backgroundColor = UIColor(red: 119/255, green: 134/255, blue: 145/255, alpha: 10/10)
                    
                case 57...70:
                    print("warm")
                //self.view.backgroundColor = UIColor(red: 169/255, green: 189/255, blue: 139/255, alpha: 10/10)
                case 71...150:
                    print("hot")
                //self.view.backgroundColor = UIColor(red: 227/255, green: 187/255, blue: 136/255, alpha: 10/10)
                default:
                    print("unknown")
                }
                
                ///this is how the image and background color get changed
                if let weather = self.weatherLabel.text{
                    switch (weather)
                    {
                    case "Clear":
                        print("clear")
                        if(7 ... 21 ~= hour){ //daytime
                            self.weatherImage.image = UIImage(named:"sun")
                            self.view.backgroundColor = UIColor(red: 227/255, green: 187/255, blue: 136/255, alpha: 10/10)
                        }
                        else{ //nighttime (it doesn't make sense to have a sun at night)
                            self.weatherImage.image = UIImage(named:"moon")
                            self.view.backgroundColor = UIColor(red: 35/255, green: 48/255, blue: 34/255, alpha: 10/10)
                        }
                    case "Cloudy":
                        print("cloudy")
                        self.weatherImage.image = UIImage(named:"cloudy")
                        self.view.backgroundColor = UIColor(red: 138/255, green: 132/255, blue: 140/255, alpha: 10/10)
                    case "Partly Cloudy":
                        print("partial clouds")
                        self.weatherImage.image = UIImage(named:"partial")
                        self.view.backgroundColor = UIColor(red: 217/255, green: 197/255, blue: 176/255, alpha: 10/10)
                    case "Rain":
                        print("rain")
                        self.view.backgroundColor = UIColor(red: 145/255, green: 170/255, blue: 157/255, alpha: 10/10)
                        self.weatherImage.image = UIImage(named:"rain")
                    case "Snow":
                        print("snow")
                        self.weatherImage.image = UIImage(named:"snow")
                        self.view.backgroundColor = UIColor(red: 184/255, green: 186/255, blue: 188/255, alpha: 10/10)
                    case "Fog":
                        print("fog")
                        self.weatherImage.image = UIImage(named:"fog")
                        self.view.backgroundColor = UIColor(red: 138/255, green: 132/255, blue: 140/255, alpha: 10/10)
                    case "Thunderstorm":
                        print("storm")
                        self.weatherImage.image = UIImage(named:"storm")
                        self.view.backgroundColor = UIColor(red: 62/255, green: 96/255, blue: 111/255, alpha: 10/10)
                    default:
                        print("unknown")
                        self.weatherImage.image = UIImage(named:"mntn")
                    }
                }
                if(7 ... 21 ~= hour){
                    print("background color okay")
                }
                else{ //change background color when it is night
                    self.view.backgroundColor = UIColor(red: 35/255, green: 48/255, blue: 34/255, alpha: 10/10)
                    print("it is night time")
                }
                
                ///change back to not updated in firebase
                let post : [String: String] = ["status": "not updated"]
                self.ref.child("current_conditions").updateChildValues(post)
            })
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 


}




