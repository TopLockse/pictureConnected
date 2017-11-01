//
//  ViewController.swift
//  pictureConnected
//
//  Created by MacTop on 08-10-17.
//  Copyright © 2017 MacTop. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate{

    var picker: UIImagePickerController? = UIImagePickerController()
    var compressedImage : Data?
    let PC_MC_Conn_service = PCServiceManager()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PC_MC_Conn_service.delegate = self
          statusDisplayText = "hello world"
        picker?.delegate = self
        compressedImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBOutlet weak var statusDisplay: UILabel!
   
    @IBOutlet weak var connectionsLabel: UILabel!
    
    @IBAction func scan(_ sender: UIButton) {
        self.setDisplayUpdated(color: .green)
        PC_MC_Conn_service.send(colorName: "green")
       // PC_MC_Conn_service.myServicesBrowser.startBrowsingForPeers()
    }
    
    
    @IBAction func takePic(_ sender: UIButton) {
        openCamera()
    }

    
    @IBAction func share(_ sender: UIButton) {
        self.setDisplayUpdated(color: .yellow)
        if compressedImage != nil{
            PC_MC_Conn_service.send(picture: compressedImage!)
                  self.setDisplayUpdated(color: .blue)
        }
        else{
            PC_MC_Conn_service.send(colorName: "yellow")
        }
    }
    
    func setDisplayUpdated(color : UIColor){
        UIView.animate(withDuration: 0.2){
            self.view.backgroundColor = color
        }
    }
    
    var statusDisplayText: String{
        get{
            return statusDisplay.text!
        }
        set{
            statusDisplay.text = PC_MC_Conn_service.statusMessage
        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //picker!.cameraCaptureMode = .photo
        present(picker!,animated: true, completion: nil)
        
    }else{
        let alert = UIAlertController(title: "camera niet gevonden", message: "geen camera gevonden", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert,animated: true, completion: nil)
        }
        
        /*
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!,animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "camera niet gevonden", message: "geen camera gevonden", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert,animated: true, completion: nil)
        }*/
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
        compressedImage = UIImageJPEGRepresentation(chosenImage,10)
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated: true,completion: nil)
    }
}

//later want to preview received files ?
/*
switch self.file!
{
case let .data(_, data):
    filePreview.image = UIImage(data: data, scale: 1.0)
    
case let .url(_, url):
    if let data = try? Data(contentsOf: url),
        let image = UIImage(data: data, scale: 1.0)
    {
        filePreview.image = image
    }
    else
    {
        filePreview.isHidden = true
    }
}
*/
//need an extension to make things async
extension ViewController: PCServiceManagerDelegate{
    func receivedPica(manager: PCServiceManager, message: Data) {
        OperationQueue.main.addOperation {
            //let pica = message as! UIImage
            if let pica = UIImage(data: message){
                //let pica = UIImage(data: picaData)!
            
                UIImageWriteToSavedPhotosAlbum(pica, nil, nil, nil);
                //compressedImage = UIImageJPEGRepresentation(pica,10)
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.image = pica
                self.dismiss(animated: true,completion: nil)
                // self.dismiss(animated: true,completion: nil)
            }
        }
    }

    func receivedMessages( manager : PCServiceManager, message: String){
        OperationQueue.main.addOperation {
            
          //  self.statusDisplayText = "received message: \(message)"
            switch message {
                case "green":
                    self.setDisplayUpdated(color: .green)
                case "yellow":
                    self.setDisplayUpdated(color: .yellow)
                default:
                    break;
            }
            
        }
        
    }
    
    func connectedDeviceChanged(manger : PCServiceManager, connectedDevices: [String]) {
        
        OperationQueue.main.addOperation {
           
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    //some func updating UI with incoming messages
}



/*
extension data{
    init(reading input: InputStream){
        self.init()
        input.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable{
            let read = input.read(buffer,maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        buffer.deallocate(capacity: bufferSize)
        
        input.close()
    }
}*/
