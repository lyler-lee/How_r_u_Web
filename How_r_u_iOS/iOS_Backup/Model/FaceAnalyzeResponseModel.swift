//
//  FaceAnalyzeResponseModel.swift
//  How_r_u_iOS
//
//  Created by 김경훈 on 6/6/25.
//

import Foundation

struct FaceAnalyzeResponseModel: Decodable {
    let annotated_image: String
    let emotion: Emotion
    let face_count: Int
}

struct Emotion: Decodable{
    let confidence: Double
    let label: String
    let probabilities: EmotionDetail
    
    enum Codingkeys: String, CodingKey {
        case confidence
        case label
        case probabilities
    }
    
    enum CodingKeys: CodingKey {
        case confidence
        case label
        case probabilities
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.confidence = try container.decode(Double.self, forKey: .confidence)
        self.label = try container.decode(String.self, forKey: .label)
        self.probabilities = try container.decode(EmotionDetail.self, forKey: .probabilities)
    }
}

struct EmotionDetail: Decodable{
    let angry: Double       // 분노
    let disgust: Double     // 혐오
    let fear: Double        // 공포
    let happy: Double       // 행복
    let neutral: Double     // 중립
    let sad: Double         // 슬픔
    let surprise: Double    // 놀람
    
    enum CodingKeys: String, CodingKey {
        case angry = "Angry"
        case disgust = "Disgust"
        case fear = "Fear"
        case happy = "Happy"
        case neutral = "Neutral"
        case sad = "Sad"
        case surprise = "Surprise"
    }
}

extension EmotionDetail {
    /// 감정 이름과 확률을 key-value로 반환 + value 기준 정렬
    var sortedEmotion: [(String, Double)] {
        let dict: [String: Double] = [
            "화남" : angry,
            "혐오" : disgust,
            "공포" : fear,
            "행복" : happy,
            "중립" : neutral,
            "슬픔" : sad,
            "놀람" : surprise
        ]
        return dict.sorted { $0.value > $1.value }
    }
}
