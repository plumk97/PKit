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
        
        PKWebServer.GET("/") { ctx in
            ctx.responseJson(["aaa": 11])
        }
        
        try PKWebServer.run()
        print("web server started, port: 8080")
        
        RunLoop.main.run()
    }
}
