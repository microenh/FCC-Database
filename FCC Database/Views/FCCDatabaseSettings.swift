//
//  FCCDatabaseSettings.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/12/21.
//

import SwiftUI
import MapKit

struct Preferences: View {
    var body: some View {
        FCCDatabaseSettings()
    }
}

struct FCCDatabaseSettings: View {
    @EnvironmentObject var fccData: FCCData
     
    private var nf: NumberFormatter
    private var df: NumberFormatter
    
    init() {
        // print ("Settings")
        nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 6
        df = NumberFormatter()
    }
    
    // geographic center of the lower 48 states (Lebanon, KS)
    @AppStorage("FCCDatabase.baseLatitude")
    private var referenceLatitude = 39.833333
    @AppStorage("FCCDatabase.baseLongitude")
    private var referenceLongitude = -98.583333
    
    @AppStorage("FCCDatabase.udpPort")
    private var udpPort = 0
    
    
    @State private var progress: Double = 0
    @State private var buttonDisabled = false
    @State private var processingStatus = ""
    
    @State private var showNoPermission = false
    @State private var showWebError = false
    @State private var statusCode = 0

    
    // testing: points to sandbox's Documents folder
//    let folder = "file://" + FileManager.default.homeDirectoryForCurrentUser
//        .appendingPathComponent("Documents").path + "/"
    
    let folder = "https://data.fcc.gov/download/pub/uls/complete"
    let file = "l_amat.zip"
    
    var body: some View {

        return VStack {
            Text("Database Date:")
                .fixedSize()
            Text(fccData.databaseDate)
                .fixedSize()
            
            ZStack {
                VStack {
                    // Text("Processing")
                    Text(processingStatus)
                }
                .opacity(processingStatus == "" ? 0 : 1)
                ProgressView("Downloading \(file)", value: progress, total: 1)
                    .opacity(progress == 0 ? 0 : 1)
            }
            .frame(maxWidth: 300)

            Button("Update from FCC") {
                buttonDisabled = true
                downloadTask?.cancel()
                progress = 0
                downloadFCCAsync()
            }
            .disabled(buttonDisabled)
            HStack {
                Text("Reference Latitude")
                TextField (
                    "Latitude",
                    value: $referenceLatitude,
                    formatter: nf
                )
                    .fixedSize()
                Text("°")
            }
            HStack {
                Text("Reference Longitude")
                TextField (
                    "Longitude",
                    value: $referenceLongitude,
                    formatter: nf
                )
                    .fixedSize()
                Text("°")
            }
            HStack {
                Button ("Use " + (fccData.callRecord?.callsign ?? "Current")) {
                    if let coordinates = fccData.coordinates {
                        referenceLatitude = coordinates.latitude
                        referenceLongitude = coordinates.longitude
                    }
                }
                .disabled(fccData.coordinates == nil)
                Button ("Use GPS") {
                    let locationViewModel = LocationViewModel()

                    switch locationViewModel.authorizationStatus {
                    case .authorizedAlways, .authorizedWhenInUse:
                        let coordinates = locationViewModel.lastSeenLocation ?? CLLocation()
                        referenceLatitude = coordinates.coordinate.latitude
                        referenceLongitude = coordinates.coordinate.longitude
                    default: showNoPermission = true
                    }
                }

                .alert(isPresented: $showNoPermission) {
                    Alert(
                        title: Text("Not Allowed"),
                        message: Text("Please enable Location Services for \(Bundle.main.displayName!).")
                    )
                }
                .alert(isPresented: $showWebError) {
                    Alert(
                        title: Text("Web Error"),
                        message: Text("HTTP Error \(statusCode) downloading FCC file.")
                    )
                }
            }
            HStack {
                Text("UDP Port")
                TextField (
                    "UDP Port",
                    value: $udpPort,
                    formatter: df
                )
                    .fixedSize()
                Text("(requires restart)")
            }
        }
        .padding()
    }
    
    private func statusCallback(status: String) {
        processingStatus = status
    }

    @State private var downloadTask: URLSessionDownloadTask?
    @State private var observation: NSKeyValueObservation?
    

    private func downloadFCCAsync() {
//        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//        print (cacheURL)


        guard let urlBase = URL(string: folder) else { return }
        let url = urlBase.appendingPathComponent(file)
//        URLCache.shared.removeAllCachedResponses()
//        print (url)

        downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
            observation?.invalidate()
            if let response = response, let hresponse = response as? HTTPURLResponse {
                statusCode = hresponse.statusCode
            }

            if statusCode == 200, let location = location {
                let newName = location.deletingLastPathComponent().appendingPathComponent(file)
                try? FileManager.default.removeItem(at: newName)
                try? FileManager.default.moveItem(at: location, to: newName)
                DispatchQueue.main.async {
                    progress = 0
                    fccData.closeDatabase()
                    processZip(downloadedFile: newName, statusCallback: statusCallback(status:))
                    fccData.openDatabase()
                    buttonDisabled = false
                }
            } else {
                DispatchQueue.main.async {
                    progress = 0
                    showWebError = true
                    buttonDisabled = false
                }
            }
        }
        observation = downloadTask?.progress.observe(\.fractionCompleted) {observationProgress, _ in
            DispatchQueue.main.async {
                progress = observationProgress.fractionCompleted
            }
        }
        downloadTask?.resume()
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        let fccData = FCCData(preview: true)
        fccData.byCallsignWithAddress("W8CR")
        return FCCDatabaseSettings()
            .environmentObject(fccData)
    }
}
