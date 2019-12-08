//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Omar Mujtaba on 7/12/19.
//  Copyright © 2019 AmmoLogic Training. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    //Class variables
    var audioRecorder: AVAudioRecorder!
    var stopRecordingSegueIdentifier = "stopRecordingSegue"
    
    // UI variables
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toggleRecordingUI(shouldRecord: false)
    }


    @IBAction func recordAudio(_ sender: Any) {
        toggleRecording(shouldRecord: true)
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        toggleRecording(shouldRecord: false)
    }
    
    private func toggleRecording(shouldRecord: Bool) {
        // Update UI
        toggleRecordingUI(shouldRecord: shouldRecord)
        
        // Handle functionality
        if shouldRecord {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    // MARK: Handle UI: Buttons and Label
    private func toggleRecordingUI(shouldRecord: Bool) {
        recordButton.isEnabled = !shouldRecord
        stopRecordingButton.isEnabled = shouldRecord
        recordingLabel.text = shouldRecord ? "Recording in Progress" : "Tap to Record"
    }
    
    // MARK: Audio Recording Functionality
    private func startRecording() {
        // Set the file directory and file name for the recoding
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recording.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // Get an instance of the audio session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        // Safely try to start the recording
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    private func stopRecording() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: Prerequisites to continue
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // All good, move to next screen
            performSegue(withIdentifier: stopRecordingSegueIdentifier, sender: audioRecorder.url)
        } else {
            // Reset Recording state to be `not recording`
            toggleRecordingUI(shouldRecord: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == stopRecordingSegueIdentifier {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

