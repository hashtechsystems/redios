//
//  MimeType.swift
//  REDE
//
//  Created by Avishek on 01/08/22.
//

import Foundation

public class MultipartFormData{
    
    let boundary: String = UUID().uuidString
    
    private var httpBody = NSMutableData()
    
    public func addText(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }
    
    public func addData(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }
    
    func configure(request: inout URLRequest){
        request.setValue("multipart/form-data; boundary=\(self.boundary)", forHTTPHeaderField: "Content-Type")
        httpBody.append("--\(boundary)--")
        request.httpBody = httpBody as Data
    }
}

extension MultipartFormData{
    
    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()
        
        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")
        
        return fieldData as Data
    }
}

/*
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

extension MultipartFormData {
    // MARK: - Private - Mime Type

    private func mimeType(forPathExtension pathExtension: String) -> String {
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            return UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        } else {
            if
                let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
                let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
                return contentType as String
            }

            return "application/octet-stream"
        }
    }
}

#else

extension MultipartFormData {
    // MARK: - Private - Mime Type

    private func mimeType(forPathExtension pathExtension: String) -> String {
        #if !(os(Linux) || os(Windows))
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
            return contentType as String
        }
        #endif

        return "application/octet-stream"
    }
}

#endif
*/
