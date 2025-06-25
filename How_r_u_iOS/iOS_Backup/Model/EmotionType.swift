//
//  EmotionType.swift
//  How_r_u_iOS
//
//  Created by 김경훈 on 6/10/25.
//

import Foundation

enum EmotionType: String{
    
    case angry = "Angry"
    case disgust = "Disgust"
    case fear = "Fear"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case surprise = "Surprise"
    case unknown
    
    var descrption: String{
        switch self {
        case .angry:
            return "화남"
        case .disgust:
            return "혐오"
        case .fear:
            return "공포"
        case .happy:
            return "행복"
        case .neutral:
            return "중립"
        case .sad:
            return "슬픔"
        case .surprise:
            return "놀람"
        case .unknown:
            return "알 수 없음"
        }
    }
}
