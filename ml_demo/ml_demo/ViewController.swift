//
//  ViewController.swift
//  ml_demo
//
//  Created by Maggie Patton on 4/3/17.
//  Copyright © 2017 atlas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate {
    
    var slideNum: Int!
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    var rLab = CGFloat()
    var gLab = CGFloat()
    var bLab = CGFloat()
    var temperature = ""
    var wind = ""
    var weather = ""
    var city = ""
    var state = ""
    var count = 1
    
    @IBOutlet weak var onView: UIView!
    
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    
    ///THIS FUNCTION IS CONTROLLING THE LED CURRENTLY
    @IBAction func onButton(_ sender: UIButton) {
        if onView.backgroundColor == UIColor.red {
            let red = redLabel.text!
            let green = greenLabel.text!
            let blue = blueLabel.text!
            led(state: "ON", red: red, green: green, blue: blue)
            onView.backgroundColor = UIColor.green
        }else {
            led(state: "OFF", red: "0", green: "0", blue: "0")
            onView.backgroundColor = UIColor.red
        }
    }
    
    //This is the function that runs every time the app starts up
    override func viewDidLoad() {
        super.viewDidLoad()
        cityText.delegate = self //text field
        stateText.delegate = self //text field
        let red = redLabel.text!
        let green = greenLabel.text!
        let blue = blueLabel.text!
        led(state: "ON", red: red, green: green, blue: blue)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //These three functions get the information from the sliders and change the color of the box
    @IBAction func changeRed(_ sender: UISlider) {
        slideNum = Int(sender.value)
        redLabel.text = String(slideNum)
        if let n = NumberFormatter().number(from: redLabel.text!) {
            rLab = CGFloat(n)
        }
        if let m = NumberFormatter().number(from: greenLabel.text!) {
            gLab = CGFloat(m)
        }
        if let l = NumberFormatter().number(from: blueLabel.text!) {
            bLab = CGFloat(l)
        }
        colorView.backgroundColor = UIColor(red: rLab/255, green: gLab/255, blue: bLab/255, alpha: 10/10)
    }
    @IBAction func changeGreen(_ sender: UISlider) {
        slideNum = Int(sender.value)
        greenLabel.text = String(slideNum)
        if let n = NumberFormatter().number(from: redLabel.text!) {
            rLab = CGFloat(n)
        }
        if let m = NumberFormatter().number(from: greenLabel.text!) {
            gLab = CGFloat(m)
        }
        if let l = NumberFormatter().number(from: blueLabel.text!) {
            bLab = CGFloat(l)
        }
        colorView.backgroundColor = UIColor(red: rLab/255, green: gLab/255, blue: bLab/255, alpha: 10/10)
    }
    @IBAction func changeBlue(_ sender: UISlider) {
        slideNum = Int(sender.value)
        blueLabel.text = String(slideNum)
        if let n = NumberFormatter().number(from: redLabel.text!) {
            rLab = CGFloat(n)
        }
        if let m = NumberFormatter().number(from: greenLabel.text!) {
            gLab = CGFloat(m)
        }
        if let l = NumberFormatter().number(from: blueLabel.text!) {
            bLab = CGFloat(l)
        }
        colorView.backgroundColor = UIColor(red: rLab/255, green: gLab/255, blue: bLab/255, alpha: 10/10)
    }
    
    //this gets rid of the keyboard when you press done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    
    //when the user presses done after typing in the city and state
    //this information is sent to firebase under "info"
    @IBAction func doneLocation(_ sender: UIButton) {
        if cityText.text?.isEmpty ?? true {
            city = "Boulder"
            
        }else{
            city = cityText.text!
        }
        if stateText.text?.isEmpty ?? true {
            state = "CO"
            
        }else{
            state = stateText.text!
        }
        print("City: ", city, ", State: ", state)
        locationLabel.text = city + ", " + state
        
        //send city and state names to the pi
        //get back temperature data and print
        ref = FIRDatabase.database().reference()
        
       
        let post : [String: Any] = ["city": city]
        let post2 : [String: Any] = ["state": state]
        ref.child("info/city").setValue(post)
        ref.child("info/state").setValue(post2)
        
    }
    
    //this will save the three color values into the specific id location
    @IBAction func saveButton(_ sender: UIButton) {
        
        if count == 7 {
            count = 1
        }
        print(count)
        var counter = "\(count)"
        //temperature = tempControl.titleForSegment(at: tempControl.selectedSegmentIndex)!
        //humidity = humidControl.titleForSegment(at: humidControl.selectedSegmentIndex)!
        //let temp = Int(temperature)
        //let humid = Int(humidity)
        let red = Int(redLabel.text!)
        let green = Int(greenLabel.text!)
        let blue = Int(blueLabel.text!)
        ref = FIRDatabase.database().reference()
        self.ref.child("training").child("ID" + counter).child("red").setValue(red)
        self.ref.child("training").child("ID" + counter).child("green").setValue(green)
        self.ref.child("training").child("ID" + counter).child("blue").setValue(blue)
        count += 1
        counter = "\(count)"
        print(count)
        print("counter: ",counter)
        ref.child("training").child("ID"+counter).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let tempy = value?["temp"] as? String ?? ""
            let windy = value?["wind"] as? String ?? ""
            let weathery = value?["weather"] as? String ?? ""
            //self.temperature = tempy
            print("should be label: ", tempy)
            self.tempLabel.text = tempy //temperature
            self.windLabel.text = windy //temperature
            self.weatherLabel.text = weathery //temperature
            print("ID"+counter)
            //tempy = temp
            
        })
        //send rgb values to firebase ^^
    }
    
    @IBAction func trainButton(_ sender: UIButton) {
        let counter = "\(count)"
        print(counter)
        ref = FIRDatabase.database().reference()
        print("ID"+counter)
        ref.child("training").child("ID"+counter).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let temp = value?["temp"] as? String ?? ""
            let windy = value?["wind"] as? String ?? ""
            let weathery = value?["weather"] as? String ?? ""
            self.temperature = temp
            self.wind = windy
            self.weather = weathery
            
        })
        
        tempLabel.text = temperature
        self.windLabel.text = wind //temperature
        self.weatherLabel.text = weather //temperature
        /*
        ref.observe(.childAdded, with: { snapshot in
            
            //if !snapshot.exists() {return}
            
            if let snapval = snapshot.value as? [String:Any],
            let id = snapval["training"] as? [String:Any],
            let id2 = id["ID"+counter] as? [String:Any] {
                let temp = id2["temp"] as! String
                temperature = temp
                print(temp)
            }
            
            
            })
        
        tempLabel.text = temperature
        */
        //child("red").getValue("red")
    }
    
    ///THIS IS FOR FIREBASE, probably not needed...
    func led(state:String, red: String, green: String, blue: String){
        let ref = FIRDatabase.database().reference() ///
        let post : [String: Any] = ["state": state] ///
        let post2 : [String: Any] = ["red": red]
        let post3 : [String: Any] = ["green": green]
        let post4 : [String: Any] = ["blue": blue]
        ref.child("led/state").setValue(post) /// - /state
        ref.child("led/red").setValue(post2)
        ref.child("led/green").setValue(post3)
        ref.child("led/blue").setValue(post4)
       
        //Int(greenLabel.text!)
        
        //this function sets the led to a dictionary state
        //will be assigned to string value in param
    }
    

}

