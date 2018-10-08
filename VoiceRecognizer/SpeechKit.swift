//
//  SpeechKit.swift
//  VoiceRecognizer
//
//  Created by Ravi kumar on 27/09/18.
//  Copyright © 2018 LTD. All rights reserved.
//

import UIKit
import Speech
class SpeechKit: NSObject,SFSpeechRecognizerDelegate {
    
    /// Closure to give response back
    /// - Parameters:
    ///   - speechText: Speech text as string
    ///   - errorMessage: Error message if for any reason it fails
    var speechResponse:((_ speechText:String?, _ errorMessage:String?)-> Void)?
    
    /// A request to recognize speech provided in audio buffers
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// A speech recognition task that lets you monitor recognition progress
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// Audio Engine
    private let audioEngine = AVAudioEngine()
    
    ///Speech recognizer
    private let speechRecognizer = SFSpeechRecognizer()
    
    
    /// Closure to give response back
    func initilizeSpeechEngine(speechResponse:@escaping (_ speechText:String?, _ errorMessage:String?)-> Void) {
        speechRecognizer?.delegate = self
        self.speechResponse = speechResponse
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            switch authStatus {  //5
            case .authorized:
                self.toggleMicrophone()
                print("User authorized access to speech recognition")
                
            case .denied:
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
            
        }
    }
    
    /// End voice recognition
    func endListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
    
    /// Start voice recognition
    func startListening() {
        if audioEngine.isRunning {
            startRecording()
        }
    }
    /// Toggle listening
    func toggleMicrophone() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            startRecording()
        }
    }
    
    /// Start recording/listening
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
         let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                if let transcript = result?.bestTranscription.formattedString{
                    self.speechResponse!(transcript,nil)
                }
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.startRecording()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    // MARK:- SFSpeechRecognizerDelegate method
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            self.speechResponse!(nil,"Speech service not available")
        }
    }
}
