//
//  MainViewController.swift
//  How_r_u_iOS
//
//  Created by 김경훈 on 6/6/25.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate {
    // 로고
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // 사진 선택 버튼
    private lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진 선택", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(didTapSelectButton), for: .touchUpInside)
        return button
    }()
    // 사진 촬영 버튼
    private lazy var captureButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진 촬영", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
        return button
    }()
    // 버튼(선택/촬영) StackView
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    let indicatorView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        [logoImageView, buttonStackView].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [selectButton, captureButton].forEach{
            buttonStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}

extension MainViewController: UIImagePickerControllerDelegate{
    @objc
    func didTapSelectButton(){
        print("select button tapped")
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true)
    }
    // 이미지 선택
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        LoadingIndicator.showLoading()
        picker.dismiss(animated: true){
            if let image = info[.originalImage] as? UIImage,
               let rotateImage = image.rotate(radians: Float.pi * 2){
                APIService.shared.sendRequest(rotateImage){ result in
                    LoadingIndicator.hideLoading()
                    switch(result){
                    case .success(let response):
                        DispatchQueue.main.async {
                            let data = response
                            if data.face_count > 1{
                                self.showAlert(title: "오류", message: "사진에 얼굴이 1명 이상 있습니다.\n사진을 다시 선택해주세요.")
                            }
                            else if data.face_count == 0{
                                self.showAlert(title: "오류", message: "사진에 얼굴이 없습니다.\n사진을 다시 선택해주세요.")
                            }
                            else{
                                let resultViewController = ResultViewController(result: data)
                                self.navigationController?.pushViewController(resultViewController, animated: true)
                            }
                        }
                        break
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.showAlert(title: "오류", message: "오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.")
                        }
                        break
                    }
                }
            }
        }
    }
    // 이미지 선택 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension MainViewController: CameraViewControllerDelegate{
    @objc
    func didTapCaptureButton(){
        print("capture button tapped")
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        self.present(cameraViewController, animated: true)
    }
    
    // 카메라 촬영
    func cameraViewController(_ controller: CameraViewController, didCapture image: UIImage) {
        APIService.shared.sendRequest(image){ result in
            switch(result){
            case .success(let response):
                DispatchQueue.main.async {
                    let data = response
                    if data.face_count > 1{
                        self.showAlert(title: "오류", message: "사진에 얼굴이 1명 이상 있습니다.\n사진을 다시 선택해주세요.")
                    }
                    else if data.face_count == 0{
                        self.showAlert(title: "오류", message: "사진에 얼굴이 없습니다.\n사진을 다시 선택해주세요.")
                    }
                    else{
                        let resultViewController = ResultViewController(result: data)
                        self.navigationController?.pushViewController(resultViewController, animated: true)
                    }
                }
                break
            case .failure(let error):
                self.showAlert(title: "오류", message: "오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.")
                break
            }
        }
    }
    // 카메라 촬영 취소
    func cameraViewControllerDidCancel(_ controller: CameraViewController) {
        print(#function)
    }
}

extension MainViewController{
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
