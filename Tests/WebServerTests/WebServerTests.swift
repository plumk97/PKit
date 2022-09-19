//
//  WebServerTests.swift
//  
//
//  Created by Plumk on 2022/6/23.
//

import XCTest
@testable import PKWebServer

final class WebServerTests: XCTestCase {
    
    
    func testReadMIMETypes() throws {
        for mimeType in PKMIMEType.mimeTypes() {
            print(mimeType)
        }
    }
    
    func testWebServer() throws {
        
        PKWebServer.numberOfThreads = 1
        PKWebServer.GET("/") { ctx in
            
            do {
                try ctx.response.responseJson(["aaa": 11])
            } catch {
                print(error)
            }
        }
        
        try PKWebServer.run()
        print("web server started, port: 8080")
        
        RunLoop.main.run()
    }
}
