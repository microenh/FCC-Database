//
//  CreateCacheDatabase.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/14/21.
//

import Foundation
import SQLite

enum GetCoordinates {
    case found (latitude: Double, longitude: Double)
    case notFound (key: String)
}

struct CacheDatabase {
    private var cacheDatabase: Connection?
    
    init() {
        let dbLocation = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents")
            .appendingPathComponent("cache.sqlite")
        
        cacheDatabase = try? Connection(dbLocation.path)
    }
    
    private func coordinateCacheKey(callRecord: CallRecord) -> String {
        var s = [String]()
        for i in [callRecord.streetAddress, callRecord.city, callRecord.state] {
            let t = i.trim().uppercased()
            if !t.isEmpty {
                s.append(t)
            }
         }
        return s.joined(separator: ",")
    }
    
    func getCoordinates(for callRecord: CallRecord) -> GetCoordinates { //  -> GetCoordinates {
        let key = coordinateCacheKey(callRecord: callRecord)
        let coordinates = CacheDatabase.lookup.filter(CacheDatabase.key == key)
        if let db = cacheDatabase {
            do {
                if let row = try db.pluck(coordinates) {
                    //print ("\(row)")
                    return GetCoordinates.found(latitude: row[CacheDatabase.latitude], longitude: row[CacheDatabase.longitude])
                }
            } catch SQLite.Result.error {
                // assume table missing, create it
                _ = try? db.run(CacheDatabase.lookup.create { t in
                    t.column(CacheDatabase.key, primaryKey: true)
                    t.column(CacheDatabase.latitude)
                    t.column(CacheDatabase.longitude)
                })
            } catch {
                // print ("\(error.self)")
            }
        }
        return GetCoordinates.notFound(key: key)
     }
    
    func saveCoordinates(for key: String, latitude: Double, longitude: Double) {
        if let cacheDatabase = cacheDatabase {
            let insert = CacheDatabase.lookup.insert(CacheDatabase.key <- key,
                                                     CacheDatabase.latitude <- latitude,
                                                     CacheDatabase.longitude <- longitude)
            _ = try? cacheDatabase.run(insert)
        }
    }
        
    private static let lookup = Table("lookup")
    
    private static let key = Expression<String>("key")
    private static let latitude = Expression<Double>("latitude")
    private static let longitude = Expression<Double>("longitude")
}
