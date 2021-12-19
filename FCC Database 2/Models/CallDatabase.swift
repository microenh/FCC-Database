//
//  Lookup.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/5/21.
//

import Foundation
import SQLite

/*
 create table lookup (
   grant_date          char(10)     null,
   expired_date        char(10)     null,
   cancellation_date   char(10)     null,
   callsign            char(10)     null,
   operator_class      char(1)      null, -- A - Advanced, E - Amateur Extra, G - General,
                                          -- N - Novice, P - Technician Plus, T - Technician
   previous_callsign   char(10)     null,
   trustee_callsign    char(10)     null,
   trustee_name        varchar(50)  null,
   applicant_type_code char(1)      null, -- B - Amateur Club, G - Governement Enttiy,
                                          -- I - Individual, M - Military Recreaction, R - Races
                                          -- C - Corporation, D - General Partnership,
                                          -- E - Limited Partnership, F - Limited Liability Partnership,
                                          -- H - Other, J - Joint Venture, L - Limited Liability Company,
                                          -- O - Consortium, P - Partnership,
                                          -- T - Trust, U - Unincorporated Association
   entity_name         varchar(200) null,
   first_name          varchar(20)  null,
   mi                  char(1)      null,
   last_name           varchar(20)  null,
   suffix              char(3)      null,
   street_address      varchar(60)  null,
   city                varchar(20)  null,
   state               char(2)      null,
   zip_code            char(9)      null,
   po_box              varchar(20)  null,
   attention_line      varchar(35)  null,
   frn                 char(10)     null
 )
 
 create table db_date {  // only one row
   date text
 )
*/

// MARK: - RadioServiceCode

enum RadioServiceCode: String {
    case amateur = "HA"
    case vanity = "HV"
    
    var isVanity: Bool {
        self == .vanity
    }
}

// MARK: - OperatorClass

enum OperatorClass: String, CustomStringConvertible {
    case advanced = "A"
    case amateurExtra = "E"
    case general = "G"
    case novice = "N"
    case technicianPlus = "P"
    case technician = "T"
    case na = ""

    var description: String {
        switch self {
        case .advanced:
            return "ADVANCED"
        case .amateurExtra:
            return "AMATEUR EXTRA"
        case .general:
            return "GENERAL"
        case .novice:
            return "NOVICE"
        case .technicianPlus:
            return "TECHNICIAN +"
        case .technician:
            return "TECHNICIAN"
        default:
            return ""
        }
    }
}

// MARK: - ApplicantTypeCode

enum ApplicantTypeCode: String {
    case amateurClub = "B"
    case governmentEntity = "G"
    case individual = "I"
    case militaryRecreation = "M"
    // below not seen in amateur records
    case corporation = "C"
    case generalPartnership = "D"
    case limitedPartnership = "E"
    case limitedLiabilityPartnership = "F"
    case other = "H"
    case jointVenture = "J"
    case limitedLiabilityCompany = "L"
    case consortium = "O"
    case partnership = "P"
    case trust = "T"
    case unincorporatedAssociation = "U"
}

// MARK: - LookupRow

struct CallRecord {
    let radioServiceCode: RadioServiceCode
    let grantDate: String
    let expiredDate: String
    let cancellationDate: String
    let callsign: String
    let operatorClass: OperatorClass
    let previousCallsign: String
    let trusteeCallsign: String
    let trusteeName: String
    let applicantTypeCode: ApplicantTypeCode
    let entityName: String
    let firstName: String
    let mi: String
    let lastName: String
    let suffix: String
    let streetAddress: String
    let city: String
    let state: String
    let zipCode: String
    let poBox: String
    let attentionLine: String
    let frn: String
    
    init (
        radioServiceCode: String = "HA",
        grantDate: String = "",
        expiredDate: String = "",
        cancellationDate: String = "",
        callsign: String = "",
        operatorClass: String = "",
        previousCallsign: String = "",
        trusteeCallsign: String = "",
        trusteeName: String = "",
        applicantTypeCode: String = "I",
        entityName: String = "",
        firstName: String = "",
        mi: String = "",
        lastName: String = "",
        suffix: String = "",
        streetAddress: String = "",
        city: String = "",
        state: String = "",
        zipCode: String = "",
        poBox: String = "",
        attentionLine: String = "",
        frn: String = ""
    ) {
        self.radioServiceCode = RadioServiceCode(rawValue: radioServiceCode)!
        self.grantDate = grantDate
        self.expiredDate = expiredDate
        self.cancellationDate = cancellationDate
        self.callsign = callsign
        self.operatorClass = OperatorClass(rawValue: operatorClass)!
        self.previousCallsign = previousCallsign
        self.trusteeCallsign = trusteeCallsign
        self.trusteeName = trusteeName
        self.applicantTypeCode = ApplicantTypeCode(rawValue: applicantTypeCode)!
        self.entityName = entityName
        self.firstName = firstName
        self.mi = mi
        self.lastName = lastName
        self.suffix = suffix
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.poBox = poBox
        self.attentionLine = attentionLine
        self.frn = frn
    }
}

// MARK: - CallDatabase

struct CallDatabase {
    private var callsignDatabase: Connection?
    
    init() {
        openCallsignDatabase()
    }
    
    mutating func closeCallsignDatabase() {
        callsignDatabase = nil
    }
    
    mutating func openCallsignDatabase() {
        let dbLocation = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents")
            .appendingPathComponent("fcc3.sqlite")

        callsignDatabase = try? Connection(dbLocation.path, readonly: true)
    }
    
    func byCallsign(_ call: String) -> CallRecord? {
        do {
            let call = CallDatabase.lookup.filter(CallDatabase.callsign == call.uppercased())
            if let db = callsignDatabase, let row = try db.pluck(call) {
                return CallRecord(
                    radioServiceCode: row[CallDatabase.radioServiceCode],
                    grantDate: row[CallDatabase.grantDate],
                    expiredDate: row[CallDatabase.expiredDate],
                    cancellationDate: row[CallDatabase.cancellationDate],
                    callsign: row[CallDatabase.callsign],
                    operatorClass: row[CallDatabase.operatorClass],
                    previousCallsign: row[CallDatabase.previousCallsign],
                    trusteeCallsign: row[CallDatabase.trusteeCallsign],
                    trusteeName: row[CallDatabase.trusteeName],
                    applicantTypeCode: row[CallDatabase.applicantTypeCode],
                    entityName: row[CallDatabase.entityName],
                    firstName: row[CallDatabase.firstName],
                    mi: row[CallDatabase.mi],
                    lastName: row[CallDatabase.lastName],
                    suffix: row[CallDatabase.suffix],
                    streetAddress: row[CallDatabase.streetAddress],
                    city: row[CallDatabase.city],
                    state: row[CallDatabase.state],
                    zipCode: row[CallDatabase.zipCode],
                    poBox: row[CallDatabase.poBox],
                    attentionLine: row[CallDatabase.attentionLine],
                    frn: row[CallDatabase.frn]
                )
            }
        } catch {
        }
        return nil
    }
    
    var databaseDate: String {
        do {
            if let db = callsignDatabase, let row = try db.pluck(CallDatabase.dbDate) {
                return row[CallDatabase.dateCreated]
            }
        } catch {
        }
        return ""
    }
    
    private static let lookup = Table("lookup")
    
    private static let radioServiceCode = Expression<String>("radio_service_code")
    private static let grantDate = Expression<String>("grant_date")
    private static let expiredDate = Expression<String>("expired_date")
    private static let cancellationDate = Expression<String>("cancellation_date")
    private static let callsign = Expression<String>("callsign")
    private static let operatorClass = Expression<String>("operator_class")
    private static let previousCallsign = Expression<String>("previous_callsign")
    private static let trusteeCallsign = Expression<String>("trustee_callsign")
    private static let trusteeName = Expression<String>("trustee_name")
    private static let applicantTypeCode = Expression<String>("applicant_type_code")
    private static let entityName = Expression<String>("entity_name")
    private static let firstName = Expression<String>("first_name")
    private static let mi = Expression<String>("mi")
    private static let lastName = Expression<String>("last_name")
    private static let suffix = Expression<String>("suffix")
    private static let streetAddress = Expression<String>("street_address")
    private static let city = Expression<String>("city")
    private static let state = Expression<String>("state")
    private static let zipCode = Expression<String>("zip_code")
    private static let poBox = Expression<String>("po_box")
    private static let attentionLine = Expression<String>("attention_line")
    private static let frn = Expression<String>("frn")
    
    private static let dbDate = Table("db_date")
    private static let dateCreated = Expression<String>("date")
}
