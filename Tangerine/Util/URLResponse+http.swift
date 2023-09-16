//
//  URLResponse.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/19/23.
//

import Foundation

extension URLResponse {
    var http: HTTPURLResponse? {
        return self as? HTTPURLResponse
    }
}

extension HTTPURLResponse {
    var isSuccessful: Bool {
        return 200 ... 299 ~= statusCode
    }
}
