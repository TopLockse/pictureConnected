//
//  CameraViewController.swift
//  ExternalApp
//
//  Created by Niels Marsman on 07-10-2017.
//  Copyright © 2017 NielsMarsman. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

import FontAwesome_swift

class CameraViewController: UIViewController
{
    @IBOutlet weak var takePictureContainer: UIView!
    @IBOutlet weak var takePictureButton: UIButton!
    
    @IBOutlet weak var cameraPreview: UIView!
    
    @IBOutlet weak var incomingFilesButton: UIButton!
    @IBOutlet weak var browseGalleryButton: UIButton!
    
    private let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var photoData: Data? = nil
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupTakePictureButton()
        self.setupCameraControlButtons()
        self.setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
        navigationController?.isNavigationBarHidden = true
        
        previewLayer?.connection?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func takePictureTouchDown(_ sender: UIButton)
    {
        animateButtonBorder(sender, width: 5.0)
    }
    
    @IBAction func takePictureTouchUp(_ sender: UIButton)
    {
        animateButtonBorder(sender, width: 3.0)
    }
    
    @IBAction func takePictureButtonTapped(_ sender: UIButton)
    {
        guard let captureOutput = self.photoOutput
            else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = true
        settings.flashMode = .auto
        
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func browseButtonTapped(_ sender: UIButton)
    {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.content", "public.data"], in: .import)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        
        self.present(picker, animated: true)
    }
    
    private func setupTakePictureButton()
    {
        takePictureContainer.layer.cornerRadius = takePictureContainer.frame.size.width / 2
        takePictureButton.layer.cornerRadius = takePictureButton.frame.size.width / 2
        takePictureButton.layer.borderWidth = 3.0
        takePictureButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupCameraControlButtons()
    {
        incomingFilesButton.titleLabel?.font = UIFont.fontAwesome(ofSize: CameraConfiguration.defaultIconSize)
        incomingFilesButton.setTitle(String.fontAwesomeIcon(name: .download), for: .normal)
        
        browseGalleryButton.titleLabel?.font = UIFont.fontAwesome(ofSize: CameraConfiguration.defaultIconSize)
        browseGalleryButton.setTitle(String.fontAwesomeIcon(name: .pictureO), for: .normal)
    }
    
    private func setupCamera()
    {
        setupCaptureSession()
        setupPreviewLayer()
        
        captureSession.startRunning()
    }
    
    private func animateButtonBorder(_ sender: UIButton, width: Float)
    {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.toValue = width
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        sender.layer.add(animation, forKey: "basic")
    }
}

// MARK: Camera methods
extension CameraViewController: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?)
    {
        guard error == nil else
        {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        guard let data = photoData else
        {
            print("No photo data resource")
            return
        }
        
        //previewLayer?.connection?.isEnabled = false
        
        PHPhotoLibrary.requestAuthorization(
        {
            [unowned self] status in
            
            if status == .authorized
            {
                //self.save(data)
            }
        })
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        guard error == nil else
        {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        if let data = photo.fileDataRepresentation()
        {
            photoData = data
        }
    }
    
    private func save(_ data: Data)
    {
        PHPhotoLibrary.shared().performChanges(
        {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
            
        }, completionHandler:
        {
            [unowned self] success, error in
            
            if let error = error
            {
                print("Error saving the image: \(error)")
                return
            }
            
            self.share(.data(String(format: "%@.png", arguments: [UIDevice.current.name]), data))
        })
    }
    
    private func share(_ file: TransferFile)
    {
        let shareTableViewController = UIStoryboard.init(name: "Main", bundle: Bundle(for: self.classForCoder))
            .instantiateViewController(withIdentifier: "ShareTableViewController") as! ShareTableViewController
        shareTableViewController.file = file
        
        let alertController = UIAlertController(title: .localized("share.file.title"), message: .localized("share.file.message"), preferredStyle: .actionSheet)
        
        if let navigationController = (navigationController as? AppNavigationController),
            let services = navigationController.serviceManager?.services
        {
            for service in services
            {
                alertController.addAction(UIAlertAction(title: service.service.rawValue, style: .default, handler:
                {
                    [weak self] action in
                    
                    shareTableViewController.service = service
                    shareTableViewController.service.delegate = shareTableViewController
                    shareTableViewController.service.scan()
                    self?.navigationController!.pushViewController(shareTableViewController, animated: true)
                }))
            }
        }
        
        alertController.addAction(UIAlertAction(title: .localized("button.cancel"), style: .destructive, handler:
        {
            [weak self] action in
            
            self?.previewLayer?.connection?.isEnabled = true
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setupCaptureSession()
    {
        captureSession.sessionPreset = .photo
        
        guard let input = setupCameraInput()
            else { return }
        
        captureSession.addInput(input)
        captureSession.addOutput(setupCameraOutput())
    }
    
    private func setupCameraInput() -> AVCaptureInput?
    {
        guard let cameraDevice = AVCaptureDevice.default(for: .video)
            else { return nil }
        return try? AVCaptureDeviceInput(device: cameraDevice)
    }
    
    private func setupCameraOutput() -> AVCapturePhotoOutput
    {
        photoOutput = AVCapturePhotoOutput()
        photoOutput!.isHighResolutionCaptureEnabled = true
        
        return photoOutput!
    }
    
    private func setupPreviewLayer()
    {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        cameraPreview.layer.addSublayer(previewLayer!)
    }
}

extension CameraViewController: UIDocumentPickerDelegate
{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
    {
        for url in urls
        {
            share(.url(url.lastPathComponent, url))
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController)
    {
        print("Document picker was cancelled")
    }
}
