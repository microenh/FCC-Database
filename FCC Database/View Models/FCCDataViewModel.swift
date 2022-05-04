//
//  FCCData.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/9/21.
//

import Foundation
import MapKit

struct CallData: Identifiable {
    let id: String
    let coordinates: CLLocationCoordinate2D
    let callRecord: CallRecord
}

class FCCDataViewModel: ObservableObject {
    @Published var places = [String: CallData]()
    
    private var callDatabase = CallDatabase()
    private var cacheDatabase = CacheDatabase()
    private let geocoder = CLGeocoder()
    
    
    private var server = Server()
    
    init(preview: Bool = false) {
        if !preview {
            server.processMessage = udpDatagram
            do {
                try server.start()
            } catch {
            }
        }
    }
    
    func udpDatagram(data: Data?) {
        if let newCall = findCall(data: data) {
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    self.addCall(newCall)
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

    func addCall(_ call: String) {
        guard call > "" else { return }
        let callKey = call.uppercased()
        guard places[callKey] == nil else { return }
        guard let callRecord = callDatabase.byCallsign(call) else { return }
        let lookupResult = cacheDatabase.getCoordinates(for: callRecord)
        switch lookupResult {
        case .found (let latitude, let longitude):
            places[callKey] = CallData(id: callKey,
                                       coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                       callRecord: callRecord)
        case .notFound (let key):
            geocoder.geocodeAddressString(key) { [weak self] regions, _ in
                if let coordinates = regions?.first?.location?.coordinate, let self = self {
                    self.places[callKey] = CallData(id: callKey, coordinates: coordinates, callRecord: callRecord)
                }
            }
        }
    }
    
}
