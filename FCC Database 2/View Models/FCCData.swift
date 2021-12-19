//
//  FCCData.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/9/21.
//

import Foundation
import MapKit

class FCCData: ObservableObject {
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var callRecord: CallRecord?
    
    private var callDatabase = CallDatabase()
    private var cacheDatabase = CacheDatabase()
    private let geocoder = CLGeocoder()
    
    private var call: String = ""
    
    private var server : Server
    
    init() {
        server = Server()
        server.processMessage = udpDatagram
        do {
            try server.start()
        } catch {
        }
    }
    
    func udpDatagram(data: Data?) {
        if let newCall = findCall(data: data),
           newCall != call {
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    self.byCallsignWithAddress(newCall)
                }
            }
        }
    }

    func closeDatabase() {
        callDatabase.closeCallsignDatabase()
    }
    
    func openDatabase() {
        callDatabase.openCallsignDatabase()
    }
    
    var databaseDate: String {
        callDatabase.databaseDate
    }

    func byCallsignWithAddress(_ call: String) {
        byCallsignSync(call)
        updateAddresses()
    }
    
    func byCallsignSync(_ call: String) {
        self.call = call
        coordinates = nil
        callRecord = callDatabase.byCallsign(call)
    }
    
    private func updateAddresses() {
        if let callRecord = callRecord {
            let lookupResult = cacheDatabase.getCoordinates(for: callRecord)
            switch lookupResult {
            case .found (let latitude, let longitude):
                coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            case .notFound (let key):
                do {
                    geocoder.geocodeAddressString(key) { regions, _ in
                        let coordinates = regions?.first?.location?.coordinate
                        if let coordinates = coordinates {
                            self.cacheDatabase.saveCoordinates(for: key, latitude: coordinates.latitude, longitude: coordinates.longitude)
                        }
                        DispatchQueue.main.async {
                            self.coordinates = coordinates
                        }
                    }
                }
            }
        }
    }
}
