//
//  locationEditorViewController.swift
//  ww_app
//
//  Created by Mae Patton on 4/30/17.
//  Copyright © 2017 hcml. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class locationEditorViewController: UIViewController, UITextFieldDelegate {
    var ref: FIRDatabaseReference!
    let stateList = ["AK","AL","AR","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MH","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR","PW","RI","SC","SD","TN","TX","UT","VA","VI","VT","WA","WI","WV","WY"]
    
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    var city = ""
    var state = ""
    var location = ""
    

    @IBAction func dismissView(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        let post : [String: String] = ["status": "updated"]
        self.ref.child("current_conditions").updateChildValues(post)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveLocation(_ sender: Any) {
        ///send this to firebase
        //this checks to see if the user entered a real state abbreviation and shows a warning if they did not
        if stateList.contains(stateField.text!) {
            if cityField.text?.isEmpty ?? true {
                city = "Boulder" //if the city is blank, set it to boulder
            }else{
                city = cityField.text!
            }
            if stateField.text?.isEmpty ?? true {
                state = "CO"
            }else{
                state = stateField.text!
            }
            location = city+", "+state //this is what i send to the main view
            UserDefaults.standard.set(location, forKey: "userPlace")
            dismiss(animated: true, completion: nil)
            
        }
        else{
            //this is the warning mesage
            let alert=UIAlertController(title: "Warning", message: "Please enter a valid state abbreviation (CO, CA, FL, etc.)", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction=UIAlertAction(title: "Cancel", style:UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancelAction) 
            let okAction=UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                self.stateField.text=""
                //code to run after okay is pressed
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        //this is sent to firebase
        ref = FIRDatabase.database().reference()
        let post : [String: Any] = ["city": city]
        let post2 : [String: Any] = ["state": state]
        let post3 : [String: String] = ["pi_command": "location update"]
        ref.child("info").updateChildValues(post)
        ref.child("info").updateChildValues(post2)
        ref.child("info").updateChildValues(post3)

        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityField.delegate = self
        self.stateField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cityField.resignFirstResponder()
        stateField.resignFirstResponder()
        return true
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
