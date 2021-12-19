//
//  MapView.swift
//  Landmarks
//
//  Created by Mark Erbaugh on 9/7/21.
//

import SwiftUI
import MapKit

struct IdentifiablePlace: Identifiable {
    var id: CLLocationDegrees   {
        location.latitude + 90 * location.longitude
    }
    let location: CLLocationCoordinate2D
}

struct MapView: View {
    @ObservedObject var fccData: FCCData

    @AppStorage("FCCDatabase.zoom")
    private var zoom = MapView.Zoom.medium

    enum Zoom: Int, RawRepresentable {
           case veryNear
           case near
           case slightlyNear
           case medium
           case slightlyFar
           case far
           case veryFar
        
        mutating func zoomOut() {
            if self != .veryFar {
                self = Zoom(rawValue: rawValue + 1)!
            }
        }
        mutating func zoomIn() {
            if self != .veryNear {
                self = Zoom(rawValue: rawValue - 1)!
            }
        }
    }
    
    var delta: CLLocationDegrees {
        switch zoom {
        case .veryNear: return 0.001
        case .near: return 0.003
        case .slightlyNear: return 0.01
        case .medium: return 0.03
        case .slightlyFar: return 0.1
        case .far: return 0.3
        case .veryFar: return 1
        }
    }
    
    var body: some View {
        VStack {
            Map(coordinateRegion: .constant(region), annotationItems: [place]) {place in
                MapMarker(coordinate: place.location, tint: .purple)
            }
            HStack {
                Spacer()
                Button {
                    zoom.zoomIn()
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                }
                .disabled(zoom == .veryNear)
                Button {
                    zoom.zoomOut()
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                }
                .disabled(zoom == .veryFar)
            }
        }
    }
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: fccData.coordinates  ??  CLLocationCoordinate2D(),
            span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        )
    }
    
    var place: IdentifiablePlace {
        IdentifiablePlace(location: fccData.coordinates  ??  CLLocationCoordinate2D())
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let fccData = FCCData()
        MapView(fccData: fccData)
    }
}
