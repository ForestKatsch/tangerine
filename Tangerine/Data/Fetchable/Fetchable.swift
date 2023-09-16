//
//  Fetchable.swift
//  Tangerine
//
//  Created by Forest Katsch on 8/22/23.
//

import Foundation

protocol Fetchable: Hashable {
    associatedtype T

    func fetch() async throws -> T

    static var placeholder: T? { get }
}
