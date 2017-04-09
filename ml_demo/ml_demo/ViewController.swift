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
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    var rLab = CGFloat()
    var gLab = CGFloat()
    var bLab = CGFloat()
    var temperature = ""
    var humidity = ""
    var city = ""
    var state = ""
    @IBOutlet weak var onView: UIView!
    
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    ///THIS FUNCTION IS CONTROLLING THE LED CURRENTLY
    @IBAction func onButton(_ sender: UIButton) {
        if onView.backgroundColor == UIColor.red {
            led(state: "ON")
            onView.backgroundColor = UIColor.green
        }else {
            led(state: "OFF")
            onView.backgroundColor = UIColor.red
        }
    }
    
    //This is the function that runs every time the app starts up
    override func viewDidLoad() {
        super.viewDidLoad()
        cityText.delegate = self //text field
        stateText.delegate = self //text field
        
        led(state: "ON")
        
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
    @IBAction func doneLocation(_ sender: UIButton) {
        if cityText != nil {
            city = cityText.text!
        }else{
            city = "Boulder"
        }
        if stateText != nil {
            state = stateText.text!
        }else{
            state = "Colorado"
        }
        print("City: ", city, ", State: ", state)
        locationLabel.text = city + ", " + state
        
        //send city and state names to the pi
        //get back temperature data and print
        
    }
    
    //this will save the three color values and whatever weather information
    @IBAction func saveButton(_ sender: UIButton) {
        //temperature = tempControl.titleForSegment(at: tempControl.selectedSegmentIndex)!
        //humidity = humidControl.titleForSegment(at: humidControl.selectedSegmentIndex)!
        temperature = "20"
        humidity = "20"
        let temp = Int(temperature)
        let humid = Int(humidity)
        let red = Int(redLabel.text!)
        let green = Int(greenLabel.text!)
        let blue = Int(blueLabel.text!)
        print("temperature: ", temp, "humidity: ", humid, "red: ", red, "green: ", green, "blue: ", blue)
        
        //send rgb values to the pi...
    }
    
    ///THIS IS FOR FIREBASE
    func led(state:String){
        let ref = FIRDatabase.database().reference()
        let post : [String: Any] = ["state": state]
        ref.child("led").setValue(post)
       
        //Int(greenLabel.text!)
        
        //this function sets the led to a deictionary state
        //will be assigned to string value in param
    }
    

}

