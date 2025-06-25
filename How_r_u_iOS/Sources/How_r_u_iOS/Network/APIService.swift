//
//  APIService.swift
//  How_r_u_iOS
//
//  Created by 김경훈 on 6/6/25.
//

import UIKit
import Foundation

enum UploadError: Error {
    case noResponse
    case invalidResponse
    case decodingFailed
}

class APIService{
    static let shared = APIService()
    private init() { }
    
    func sendRequest(_ image: UIImage, _ completion: @escaping (Result<FaceAnalyzeResponseModel, Error>) -> Void){
        guard let url = URL(string: "http://192.168.0.16:5001/analyze") else { return }

        let image = image
        
         var request = URLRequest(url: url)
         request.httpMethod = "POST"

         let boundary = UUID().uuidString
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

         let imageData = image.jpegData(compressionQuality: 0.8)!

         var body = Data()
         body.append("--\(boundary)\r\n".data(using: .utf8)!)
         body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
         body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
         body.append(imageData)
         body.append("\r\n".data(using: .utf8)!)
         body.append("--\(boundary)--\r\n".data(using: .utf8)!)

         let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
             
             guard let httpResponse = response as? HTTPURLResponse else {
                 completion(.failure(NSError(domain: "UploadErrorDomain", code: 1001, userInfo: nil)))
                 return
             }
             
             if let error = error {
                 completion(.failure(error))
             }
             
             if(200..<300 ~= httpResponse.statusCode){
                 if let data = data{
                     do{
                         let json = try JSONDecoder().decode(FaceAnalyzeResponseModel.self, from: data)
                         completion(.success(json))
                     }
                     catch{
                         completion(.failure(UploadError.decodingFailed))
                     }
                 }
             }
             else{
                 completion(.failure(UploadError.invalidResponse))
             }
         }

         task.resume()
    }
}

