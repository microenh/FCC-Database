//
//  FCCData.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/9/21.
//

import Foundation
import MapKit

fileprivate struct Settings {
    static let delta = 10_000.0
}

struct IdentifiablePlace: Identifiable {
    let id: String
    let location: CLLocationCoordinate2D
    init(id: String, location: CLLocationCoordinate2D) {
        self.id = id.uppercased()
        self.location = location
    }
}


class FCCData: ObservableObject {
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var callRecord: CallRecord?
    @Published var region: MKCoordinateRegion
    
    private var callDatabase = CallDatabase()
    private var cacheDatabase = CacheDatabase()
    private let geocoder = CLGeocoder()
    
    private var call: String = ""
    
    private var server : Server
    
    init(preview: Bool = false) {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(), latitudinalMeters: Settings.delta, longitudinalMeters: Settings.delta)
        server = Server()
        if !preview {
            server.processMessage = udpDatagram
            do {
                try server.start()
            } catch {
            }
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
    
    var places: [IdentifiablePlace] {
        var result = [IdentifiablePlace]()
        if call > "", let coordinates = coordinates {
            result.append(IdentifiablePlace(id: call, location: coordinates))
        }
        return result
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
                region = MKCoordinateRegion(center: coordinates!, latitudinalMeters: Settings.delta, longitudinalMeters: Settings.delta)
            case .notFound (let key):
                geocoder.geocodeAddressString(key) { [weak self] regions, _ in
                    if let coordinates = regions?.first?.location?.coordinate, let self = self {
                        self.cacheDatabase.saveCoordinates(for: key, latitude: coordinates.latitude, longitude: coordinates.longitude)
                        self.coordinates = coordinates
                        self.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: Settings.delta, longitudinalMeters: Settings.delta)
                    }
                }
            }
        }
    }
}
