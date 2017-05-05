//
//  ColorViewController.swift
//  ww_app
//
//  Created by Mae Patton on 4/26/17.
//  Copyright © 2017 hcml. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ColorViewController: UIViewController {
    
    var slideNum: Int!
    var ref: FIRDatabaseReference!

    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    var rLab = CGFloat()
    var gLab = CGFloat()
    var bLab = CGFloat()
    
    var red = 130
    var green = 130
    var blue = 130
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Do any additional setup after loading the view.
    }
    //when the save button is tapped
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        //set color values to what the label says
        red = Int(redLabel.text!)!
        green = Int(greenLabel.text!)!
        blue = Int(blueLabel.text!)!
        dismiss(animated: true, completion: nil) //dismisses the view
        //send this to firebase
        ref = FIRDatabase.database().reference()
        let post : [String: Any] = ["red": red]
        let post2 : [String: Any] = ["green": green]
        let post3 : [String: Any] = ["blue": blue]
        let post4 : [String: String] = ["pi_command": "training point"]
        ref.child("color").updateChildValues(post)
        ref.child("color").updateChildValues(post2)
        ref.child("color").updateChildValues(post3)
        ref.child("info").updateChildValues(post4)
    }
    //runs when cancel button is tapped
    @IBAction func cancelButton(_ sender: Any) {
        ///change back to not updated in firebase
        dismiss(animated: true, completion: nil)
        ref = FIRDatabase.database().reference()
        let post : [String: String] = ["status": "updated"]
        self.ref.child("current_conditions").updateChildValues(post)
        
    }
    
    //function for when the red slider is changed
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
    //function for when the green slider is changed
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
    //function for when the blue slider is changed
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
    
    //this function is probably not necessary...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
