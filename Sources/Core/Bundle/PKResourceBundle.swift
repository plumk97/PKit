//
//  PKResourceBundle.swift
//  
//
//  Created by Plumk on 2021/12/17.
//

import Foundation

/**
 获取当前App资源Bundle
 只会查找APP目录和Frameworks目录
 同名的Bundle 会覆盖
 */
public class PKResourceBundle {
    
    private static let shared = PKResourceBundle()
    
    /// 保存Bundle
    private var bundles = [String: Bundle]()
    
    /// 当前主Bundle名字
    private var mainBundleName = ""
    
    private init() {
        self.mainBundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        
        self.readResourceBundlesInFramework(Bundle.main.bundlePath)
        self.readFrameworks(Bundle.main.bundlePath + "/Frameworks")
    }
    
    
    /// 读取Frameworks
    private func readFrameworks(_ path: String) {
    
        if let subpaths = try? FileManager.default.contentsOfDirectory(atPath: path) {
            for subpath in subpaths {
                if subpath.hasSuffix(".framework") {
                    self.readResourceBundlesInFramework(path + "/" + subpath)
                }
            }
        }
    }
    
    /// 读取framework里的bundle
    /// - Parameter path:
    private func readResourceBundlesInFramework(_ path: String) {
        if let subpaths = try? FileManager.default.contentsOfDirectory(atPath: path) {
            
            /// 遍历frameowk 查找bundle目录
            for subpath in subpaths {
                if subpath.hasSuffix(".bundle") {
                    
                    if let bundle = Bundle.init(path: path + "/" + subpath),
                       bundle.infoDictionary?["CFBundlePackageType"] as? String == "BNDL",
                       let bundleName = bundle.infoDictionary?["CFBundleName"] as? String{
                        
                        /*
                         CFBundlePackageType (String - iOS, macOS) identifies the type of the bundle and is analogous to the Mac OS 9 file type code. The value for this key consists of a four-letter code. The type code for apps is APPL; for frameworks, it is FMWK; for loadable bundles, it is BNDL. For loadable bundles, you can also choose a type code that is more specific than BNDL if you want.

                         All bundles should provide this key. However, if this key is not specified, the bundle routines use the bundle extension to determine the type, falling back to the BNDL type if the bundle extension is not recognized.
                         */
                        
                        // BDNL 类型的bundle 视为资源bundle
                        self.bundles[bundleName] = bundle
                    }
                    
                }
            }
        }
    }
    
    /// 获取所有资源bundle
    /// - Returns:
    public static func allBundles() -> [String: Bundle] {
        return self.shared.bundles
    }
    
    
    /// 根据名字获取Bundle
    /// - Parameters:
    ///   - name: 如果为nil 则根据file 来推断
    ///   - file:
    /// - Returns:
    public static func current(_ bundleName: String? = nil, _ file: String = #fileID) -> Bundle? {
        
        guard let name = bundleName ?? file.components(separatedBy: "/").first else {
            return nil
        }
        
        if name == self.shared.mainBundleName {
            return Bundle.main
        }
        
        return self.shared.bundles[name]
    }
}
