//
//  GridSquare.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/11/21.
//

import Foundation
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {

    static let divisors = [
        (Double(20), Double(10), Character("A")),
        (2, 1, "0"),
        (0.083333, 0.0416665, "a"),
        (0.0083333, 0.004166, "0")
    ]
    
    func gridSquare(pairs: Int = 3) -> String {
        
        var lat = self.latitude + 90
        var long = self.longitude + 180
        
        var results = [(UInt8, UInt8)]()
        for i in CLLocationCoordinate2D.divisors.indices {
            results.append((UInt8(long / CLLocationCoordinate2D.divisors[i].0), UInt8(lat / CLLocationCoordinate2D.divisors[i].1)))
            long = long.truncatingRemainder(dividingBy: CLLocationCoordinate2D.divisors[i].0)
            lat = lat.truncatingRemainder(dividingBy: CLLocationCoordinate2D.divisors[i].1)
        }
        
        var result = ""
        for i in 0..<pairs {
            let pair = [
                CLLocationCoordinate2D.divisors[i].2.asciiValue! + results[i].0,
                CLLocationCoordinate2D.divisors[i].2.asciiValue! + results[i].1
            ]
            result.append(String(bytes: pair, encoding: .ascii)!)
        }
        return result
    }
    
    private func decimalToDMS(_ degrees: Double) -> (degrees: Int, minutes: Int, seconds: Int) {
        let absDegrees = abs(degrees)
        let intDegrees = Int(absDegrees)
        let minutes = absDegrees.truncatingRemainder(dividingBy: 1) * 60
        let intMinutes = Int(minutes)
        let seconds = minutes.truncatingRemainder(dividingBy: 1) * 60
        let intSeconds = Int(seconds)
        return (intDegrees, intMinutes, intSeconds)
    }
    
    var longitudeString: String {
        let dms = decimalToDMS(self.longitude)
        let dir = self.longitude < 0 ? "W" : "E"
        return "\(dms.0)° \(dms.1)' \(dms.2)\" \(dir)"
    }
    
    var latitudeString: String {
        let dms = decimalToDMS(self.latitude)
        let dir = self.latitude < 0 ? "S" : "N"
        return "\(dms.0)° \(dms.1)' \(dms.2)\" \(dir)"
    }
    
    func distanceTo(_ destination: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(destination))
    }
    
    func bearing(from point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(point.latitude)
        let lon1 = degreesToRadians(point.longitude)
        
        let lat2 = degreesToRadians(latitude);
        let lon2 = degreesToRadians(longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        var r = radiansToDegrees(radiansBearing)
        if r < 0 {
            r += 360
        }
        return r
    }

}

