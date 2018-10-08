# iOS-Uni-SpeechRecognition
Its Speech recognition demo developed using Apple's Speech library.


Just create object of SpeechKit class and initialize speech engine by calling initilizeSpeechEngine 
method in the class you want to implement speech-to-text.

This method will give you two parameters in callback.

    let speechKit = SpeechKit()
    
    
    speechKit.initilizeSpeechEngine { (speechText, errorMessage) in
            if let speech = speechText{
                print("Speech text >>>>>> \(speech) <<<<<<")
            }
            else if let error = errorMessage{
                print("ERRROr is \(error)")
            }
        }

1.Stop speech engine
Speech engine can be simply stop by calling endListening().
i.e., 

    speechKit.endListening()
    
    
2.Start again Speech engine 
    speechKit.startListening()
