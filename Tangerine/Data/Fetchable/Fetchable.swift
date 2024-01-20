//
//  Fetchable.swift
//  Tangerine
//
//  Created by Forest Katsch on 8/22/23.
//

import Foundation

protocol BaseFetchable: Hashable {
    associatedtype T

    static var placeholder: T? { get }
}

protocol Fetchable: BaseFetchable {
    associatedtype T

    func fetch() async throws -> T

    static var placeholder: T? { get }
}

protocol InfiniteFetchable: BaseFetchable {
    associatedtype P

    func fetch(page: P?) async throws -> (T, P)
}
