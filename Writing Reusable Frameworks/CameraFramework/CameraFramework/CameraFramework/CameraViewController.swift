//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by Helior Colorado on 11/28/17.
//  Copyright © 2017 Helior Colorado. All rights reserved.
//

import UIKit
import AVFoundation

public protocol CameraControllerDelegate {
    func cancelButtonTapped(controller:CameraViewController)
}

public enum CameraPosition {
    case front
    case back
}

public final class CameraViewController: UIViewController {
    fileprivate var camera:Camera?
    var previewLayer:AVCaptureVideoPreviewLayer?
    private var _cancelButton:UIButton?
    var cancelButton:UIButton {
        if let currentButton = _cancelButton {
            return currentButton
        }
        let button = UIButton(frame: CGRect(x: self.view.frame.minX + 10, y: self.view.frame.maxY - 50, width: 70, height: 30))
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        _cancelButton = button
        return button
    }
    
    open var delegate:CameraControllerDelegate?
    
    open var position:CameraPosition = .back {
        didSet {
            guard let camera = self.camera else {
                return
            }
            camera.position = position
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.camera = Camera(with: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let camera = self.camera else {
            return
        }
        createUI()
        camera.update()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI(orientation: UIApplication.shared.statusBarOrientation)
        updateButtonFrames()
    }
}

// MARK: User Interface Creation
fileprivate extension CameraViewController {
    func createUI() {
        guard let camera = self.camera else {
            return
        }
        guard let previewLayer = camera.getPreviewLayer() else {
            return
        }
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(previewLayer)
        self.view.addSubview(self.cancelButton)
    }
    
    func updateUI(orientation:UIInterfaceOrientation) {
        guard let previewLayer = self.previewLayer, let connection = previewLayer.connection else {
            return
        }
        previewLayer.frame = self.view.bounds
        switch orientation {
        case .portrait:
            connection.videoOrientation = .portrait
            break
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
            break
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
            break
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
            break
        default:
            connection.videoOrientation = .portrait
            break
        }
    }
    
    func updateButtonFrames() {
        self.cancelButton.frame = CGRect(x: self.view.frame.minX + 10, y: self.view.frame.maxY - 50, width: 70, height: 30)
    }
}

// MARK: UIButton Functions
fileprivate extension CameraViewController {
    @objc func cancelButtonTapped() {
        if let delegate = self.delegate {
            delegate.cancelButtonTapped(controller: self)
        }
    }
}