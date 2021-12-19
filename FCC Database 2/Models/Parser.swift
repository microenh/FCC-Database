//
//  Parser.swift
//  UDPGUI
//
//  Created by Mark Erbaugh on 12/12/21.
//

import Foundation

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

func findCall(data: Data?) -> String? {
    if let data = data,
       let xml = String(data: data, encoding: .ascii),
       let startIndex = xml.endIndex(of: "<ShownStation>"),
       let endIndex = xml.index(of: "</ShownStation>"),
       let call = xml[startIndex..<endIndex].split(separator: "/").first
    {
//        let p = Parser()
//        p.parse(xml: data)
        return String(call)
    }
    return nil
}


class Parser: NSObject, XMLParserDelegate {
    
    var textBuffer = ""
    var result: [String: String] = [:]
    
    func parserDidStartDocument(_ parser: XMLParser) {
        result = [:]
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        let keys = result.keys.sorted()
        for key in keys {
            print ("\(key): \(result[key]!)")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        textBuffer += string
//        print ("foundCharacters: \(string)")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        textBuffer = ""
//        print ("Start: \(elementName)")
//        if let namespaceURI = namespaceURI {
//            print ("namespaceURI = \(namespaceURI)")
//        }
//        if let qualifiedName = qName {
//            print ("qualifiedName = \(qualifiedName)")
//        }
//        print ("attributes = \(attributeDict)")
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        result[elementName] = textBuffer
//        print ("End: \(elementName)")
//        if let namespaceURI = namespaceURI {
//            print ("namespaceURI = \(namespaceURI)")
//        }
//        if let qualifiedName = qName {
//            print ("qualifiedName = \(qualifiedName)")
//        }
    }
    
    func parse(xml: Data) {
        let parser = XMLParser(data: xml)
        parser.delegate = self
        parser.parse()
    }
    
}
