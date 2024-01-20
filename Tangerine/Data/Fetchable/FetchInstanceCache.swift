//
//  FetchInstanceCache.swift
//  Pensieve
//
//  Created by Forest Katsch on 8/21/23.
//

import Foundation

class FetchInstanceCache {
    static var shared = FetchInstanceCache()

    var instances = [AnyHashable: Any]()

    private init() {}

    func get<F: Fetchable>(_ fetchable: F) -> FetchInstance<F> {
        if instances[fetchable] == nil {
            instances[fetchable] = FetchInstance(fetchable)
        }

        return instances[fetchable] as! FetchInstance<F>
    }

    func get<F: InfiniteFetchable>(infinite fetchable: F) -> InfiniteFetchInstance<F> {
        if instances[fetchable] == nil {
            instances[fetchable] = InfiniteFetchInstance(fetchable)
        }

        return instances[fetchable] as! InfiniteFetchInstance<F>
    }
}
