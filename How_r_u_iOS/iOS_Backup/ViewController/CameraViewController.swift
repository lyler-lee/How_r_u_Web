//
//  CameraViewController.swift
//  How_r_u_iOS
//
//  Created by 김경훈 on 6/6/25.
//

import UIKit
import AVFoundation

/// 사진 촬영 완료 후 결과를 전달하기 위한 델리게이트 프로토콜
protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewController(_ controller: CameraViewController, didCapture image: UIImage)
    func cameraViewControllerDidCancel(_ controller: CameraViewController)
}

class CameraViewController: UIViewController {
    
    // MARK: - Public Properties
    
    /// 촬영된 이미지를 전달할 델리게이트
    weak var delegate: CameraViewControllerDelegate?
    
    // MARK: - Private Properties
    
    /// 카메라 세션
    private let captureSession = AVCaptureSession()
    
    /// 현재 사용하는 카메라 입력 (Front)
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    /// 사진 출력
    private let photoOutput = AVCapturePhotoOutput()
    
    /// 미리보기 레이어
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    /// 미리보기를 띄울 컨테이너 뷰
    private let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    /// 촬영 버튼 (가운데 하단)
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        let config: UIImage.SymbolConfiguration
        config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        let cameraIcon = UIImage(systemName: "circle.fill", withConfiguration: config)
        button.setImage(cameraIcon, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 닫기 버튼 (좌측 상단)
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config: UIImage.SymbolConfiguration
        config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let closeIcon = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(closeIcon, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupUI()
        checkCameraAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 세션이 준비되면 시작
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 뷰가 사라질 때 세션 중지
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - 카메라 권한 확인
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                } else {
                    self.showCameraAccessDeniedAlert()
                }
            }
        case .denied, .restricted:
            showCameraAccessDeniedAlert()
        @unknown default:
            showCameraAccessDeniedAlert()
        }
    }
    
    private func showCameraAccessDeniedAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "카메라 접근 권한 필요",
                message: "사진 촬영을 위해 카메라 권한을 허용해 주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
                self.delegate?.cameraViewControllerDidCancel(self)
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - 세션 구성 (Front 카메라 사용)
    
    private func setupCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // 1) Front 카메라 장치 가져오기
        do {
            guard let frontDevice = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .front
            ) else {
                throw NSError(domain: "Camera", code: -1, userInfo: [NSLocalizedDescriptionKey: "전면 카메라를 찾을 수 없습니다."])
            }
            
            let frontInput = try AVCaptureDeviceInput(device: frontDevice)
            if captureSession.canAddInput(frontInput) {
                captureSession.addInput(frontInput)
                self.videoDeviceInput = frontInput
            } else {
                throw NSError(domain: "Camera", code: -1, userInfo: [NSLocalizedDescriptionKey: "세션에 전면 카메라 입력을 추가할 수 없습니다."])
            }
        } catch {
            print("Camera Input Error: \(error.localizedDescription)")
            captureSession.commitConfiguration()
            return
        }
        
        // 2) Photo Output 설정
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.setPreparedPhotoSettingsArray(
                [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
                completionHandler: nil
            )
        } else {
            print("세션에 Photo Output을 추가할 수 없습니다.")
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.commitConfiguration()
        
        // 3) Preview Layer 설정 (Portrait 고정)
        DispatchQueue.main.async {
            self.configurePreviewLayer()
        }
    }
    
    private func configurePreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        // ** Portrait 모드로 고정 **
        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        
        previewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(previewLayer, at: 0)
    }
    
    // MARK: - 세로(Portrait) 모드 고정
    
    /// 이 뷰 컨트롤러는 세로 모드만 지원하도록 설정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    /// 기본화면(프레젠테이션)시 세로 모드로 시작
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: - UI 설정
    
    private func setupUI() {
        // previewView 추가
        view.addSubview(previewView)
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 촬영 버튼 추가 (하단 중앙)
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalTo: captureButton.widthAnchor)
        ])
        captureButton.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        
        // 닫기 버튼 추가 (좌측 상단)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    // MARK: - 버튼 액션
    
    @objc private func didTapCapture() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        if let previewPixelType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType
            ]
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func didTapClose() {
        self.dismiss(animated: true){
            self.delegate?.cameraViewControllerDidCancel(self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Photo Capture Error: \(error.localizedDescription)")
            return
        }
        // 이미지 회전
        guard let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData)?.rotate(radians: Float.pi * 2) else {
            print("이미지 데이터 변환 실패")
            return
        }
        
        self.dismiss(animated: true){
            self.delegate?.cameraViewController(self, didCapture: capturedImage)
        }
    }
}
