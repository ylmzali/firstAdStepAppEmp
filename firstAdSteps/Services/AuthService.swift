//
//  AuthService.swift
//  firstAdSteps
//
//  Created by Ali YILMAZ on 28.05.2025.
//

import Foundation

class AuthService {
    static func sendOTP(email: String, phone: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // API isteği burada yapılacak
        // Örnek: URLSession.shared.dataTask(with: request) { data, response, error in ... }
    }

    static func verifyOTP(otp: String, completion: @escaping (Result<String, Error>) -> Void) {
        // API isteği burada yapılacak
        // Örnek: URLSession.shared.dataTask(with: request) { data, response, error in ... }
    }
}
