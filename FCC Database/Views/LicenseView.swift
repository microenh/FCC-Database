//
//  LicenseView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/6/21.
//

import SwiftUI
import MapKit

fileprivate struct Settings {
    static var delta = 10_000.0
}

struct LicenseView: View {
    @EnvironmentObject var data: FCCDataViewModel
    @Binding var selection: String?
    
    @AppStorage("FCCDatabase.baseLatitude")
    private var baseLatitude = 39.8539841
    
    @AppStorage("FCCDatabase.baseLongitude")
    private var baseLongitude = -83.3939624

    private func textData(data: CallData) -> String {
        var lines = [String]()
        let r = data.callRecord
        if r.radioServiceCode.isVanity {
            lines.append("VANITY")
        }
        if r.applicantTypeCode == .individual {
            var names = [String]()
            for i in [r.firstName, r.mi, r.lastName, r.suffix] {
                let t = i.trim()
                if !t.isEmpty {
                    names.append(t.uppercased())
                }
            }
            if names.count > 0 {
                lines.append(names.joined(separator: " "))
            }
            if r.operatorClass != .na {
                lines.append("CLASS: \(r.operatorClass)")
            }
            let pc = r.previousCallsign.trim()
            if !pc.isEmpty {
                lines.append("PREVIOUS CALL: \(pc.uppercased())")
            }
        } else {
            let e = r.entityName.trim()
            if !e.isEmpty {
                lines.append(e.uppercased())
            }
            var trusteeInfo = [String]()
            let t = r.trusteeName.trim()
            if !t.isEmpty {
                trusteeInfo.append(t.uppercased())
            }
            let c = r.trusteeCallsign.trim()
            if !c.isEmpty {
                trusteeInfo.append(c.uppercased())
            }
            if trusteeInfo.count > 0 {
                let tj = trusteeInfo.joined(separator: " - ")
                lines.append("TRUSTEE: \(tj)")
            }
        }
        let poBox = r.poBox.trim()
        if !poBox.isEmpty {
            lines.append("PO BOX \(poBox.uppercased())")
        }
        let street = r.streetAddress.trim()
        if !street.isEmpty {
            lines.append(street.uppercased())
        }
        var cs = [String]()
        var sz = [String]()
        let city = r.city.trim()
        if !city.isEmpty {
            cs.append(city.uppercased())
        }
        let state = r.state.trim()
        if !state.isEmpty {
            cs.append(state.uppercased())
        }
        if cs.count > 0 {
            sz.append(cs.joined(separator: ", "))
        }
        let zip = r.zipCode.trim()
        if !zip.isEmpty {
            sz.append(zip.uppercased())
        }
        if sz.count > 0 {
            lines.append(sz.joined(separator: "  "))
        }
        
        for (d, title) in [(r.grantDate, "GRANT"), (r.expiredDate, "EXPIRATION"), (r.cancellationDate, "CANCELLED")] {
            let i = d.trim()
            if !i.isEmpty {
                lines.append("\(title): \(i.uppercased())")
            }
        }
        let frn = r.frn.trim()
        if !frn.isEmpty {
            lines.append("FRN: \(frn.uppercased())")
        }
        

        let coordinates = data.coordinates
        lines.append("LATITUDE: \(coordinates.latitudeString) (\(coordinates.latitude)°)")
        lines.append("LONGITUDE: \(coordinates.longitudeString) (\(coordinates.longitude)°)")
        
        lines.append("GRID: \(coordinates.gridSquare())")
        
        let base = CLLocationCoordinate2D(latitude: baseLatitude, longitude: baseLongitude)
        
        let distance = Int(coordinates.distanceTo(base) * 0.000621371 + 0.5)
        lines.append("DISTANCE: \(distance) miles")
        
        let heading = Int(coordinates.bearing(from: base) + 0.5)
        lines.append ("HEADING: \(heading)°")
        
        return lines.joined(separator: "\r")
    }
  
    var body: some View {
        VStack(alignment: .leading) {
            if let selection = selection, let center = data.places[selection]?.coordinates {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: center,
                                                                   latitudinalMeters: Settings.delta,
                                                                   longitudinalMeters: Settings.delta)),
                    interactionModes: .all,
                    annotationItems: [data.places[selection]!]) { place in
                    MapAnnotation(coordinate: place.coordinates) {
                        Text(place.id)
                            .padding(.horizontal, 5)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                }
                    .cornerRadius(10)
            }
            if let selection = selection, let cr = data.places[selection]  {
                Text(textData(data: cr))
            }
        }
    }
}

struct LicenseView_Previews: PreviewProvider {
    
    static var previews: some View {
        let fccData = FCCDataViewModel(preview: true)
        return LicenseView(selection: .constant(nil))
            .environmentObject(fccData)
    }
}

