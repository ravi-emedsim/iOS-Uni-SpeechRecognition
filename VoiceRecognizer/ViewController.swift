//
//  ViewController.swift
//  VoiceRecognizer
//
//  Created by Ravi kumar on 26/09/18.
//  Copyright © 2018 LTD. All rights reserved.
//


import UIKit
class ViewController: UIViewController {
   
    // Lable to show speech text
    @IBOutlet weak var speechTextLbl: UILabel!
    let speechKit = SpeechKit()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        speechKit.initilizeSpeechEngine { (speechText, errorMessage) in
            if let speech = speechText{
                self.speechTextLbl.text = speech
                print("Speech text >>>>>> \(speech) <<<<<<")
            }
            else if let error = errorMessage{
                print("ERRROr is \(error)")
            }
        }
    }

    
    
    
    /// Toggling voice recognition start/stop
    @IBAction func say(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if sender.isSelected {
            speechKit.startListening()
        }
        else
        {
            speechKit.endListening()

        }
        
    }
    
   


}

