//
//  OCR.swift
//  ocrTest
//
//  Created by 刘勇博 on 16/08/2017.
//  Copyright © 2017 Magicarp. All rights reserved.
//

import Foundation
import UIKit

struct OCR {
    let token = TokenGetter().token
    var url: String {
        return "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token=" + token!
    }
    let headers: [String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
    
    func getOcrResult(from image: UIImage) -> [String]? {
        let imageData = UIImageJPEGRepresentation(image, 0.2)
        let strBase64 = imageData?.base64EncodedString()
        let data = ["image":strBase64!, "detect_direction": true] as [String : Any]
        let r = Just.post(url, data: data, headers: headers)
        if r.ok {
            do {
                let jsonDict = try JSONDecoder().decode(OcrResultObject.self, from: r.content!)
                var wordsArray = [String]()
                for obj in jsonDict.words_result {
                    wordsArray.append(obj.words)
                }
                return wordsArray
            } catch {
                print(error)
            }
        }
        return nil
    }
}

struct TokenGetter {
    let urlStr: String = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=n6OzjEGkrC5DMLuMLcDQHr6l&client_secret=urMqpBwFGlaEPET8xu4dbrtk6wtDrnz8"
    var token: String? {
        let res = Just.get(urlStr)
        if res.ok {
            do {
                let dict = try JSONDecoder().decode(TokenObject.self, from: res.content!)
                return dict.access_token
            } catch {
                print(error)
            }
        }
        return nil
    }
}

struct TokenObject: Decodable {
    var refresh_token: String?
    var expires_in: Int?
    var scope: String?
    var session_key: String?
    var access_token: String?
    var session_secret: String?
}

struct OcrResultObject: Decodable {
    var log_id: Int?
    var words_result_num: Int?
    var words_result: [WordsResultObject]
    var direction: Int?
}

struct WordsResultObject: Decodable {
    var words: String
}
