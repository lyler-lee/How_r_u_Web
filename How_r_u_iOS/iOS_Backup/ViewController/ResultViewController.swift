//
//  ResultViewController.swift
//  How_r_u_iOS
//
//  Created by 김경훈 on 6/6/25.
//

import UIKit

class ResultViewController: UIViewController {
    
    let result: FaceAnalyzeResponseModel
    
    init(result: FaceAnalyzeResponseModel) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var resultStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "표정 분석 결과(정확도 : 0%)"
        label.textColor = .black
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()

    private lazy var emotionLabel1 = UILabel()
    private lazy var emotionLabel2 = UILabel()
    private lazy var emotionLabel3 = UILabel()
    private lazy var emotionLabel4 = UILabel()
    private lazy var emotionLabel5 = UILabel()
    private lazy var emotionLabel6 = UILabel()
    private lazy var emotionLabel7 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setResponseData(result)
    }
    
    private func setupView(){
        [resultImageView, resultLabel, resultStackView].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [emotionLabel1, emotionLabel2, emotionLabel3, emotionLabel4, emotionLabel5, emotionLabel6, emotionLabel7].forEach{
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
            $0.textColor = .black
            resultStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            resultImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resultImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultImageView.heightAnchor.constraint(equalToConstant: 300),
            
            resultLabel.topAnchor.constraint(equalTo: resultImageView.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            resultStackView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            resultStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    func setResponseData(_ response: FaceAnalyzeResponseModel){
        if let base64ImageData = Data(base64Encoded: response.annotated_image),
            let image = UIImage(data: base64ImageData) {
            resultImageView.image = image
        }
        
        let emotion = response.emotion
        let currentEmotion = EmotionType(rawValue: response.emotion.label)
        let resultDescription = (currentEmotion ?? .unknown).descrption
        
        let confidence = emotion.confidence
        let detail = response.emotion.probabilities
        let sortedEmotionPairs = detail.sortedEmotion
        
        resultLabel.text = "표정 분석 결과 : \(resultDescription), 정확도 : \(String(format: "%.1f", confidence))%"
        
        let labels = [emotionLabel1, emotionLabel2, emotionLabel3, emotionLabel4, emotionLabel5, emotionLabel6, emotionLabel7]
        
        for (index, label) in labels.enumerated() {
            if index < sortedEmotionPairs.count {
                let (emotionName, value) = sortedEmotionPairs[index]
                label.text = "\(emotionName): \(String(format: "%.1f", value))%"
            } else {
                label.text = ""
            }
        }
    }
}
