//
//  Biu.swift
//  Biu
//
//  Created by whoami on 2024/3/6.
//

import Foundation
import injection


public struct BiuInject{
    
    // 静态注入Dylib
    public static func staticInject(appPath: String, 
                                    dylibPath: String,
                                    finishHandle: (Bool,String) -> Void){
        
        let executablePath = findAppMainMacho(appPath: appPath)
        if executablePath == nil {
            finishHandle(false, "找不到App的执行文件")
            return
        }
        
        var injectDylibPath = dylibPath
        // 文件存在时Dylib移至到目标App执行文件目录下
        if !dylibPath.hasPrefix("@"){
            if FileManager.default.fileExists(atPath: dylibPath){
                let dylibName = dylibPath.components(separatedBy: "/").last!
                
                do {
                    try FileManager.default.moveItem(atPath: dylibPath, 
                                                     toPath: appPath.appending("/Contents/MacOS/\(dylibName)"))
                    injectDylibPath = "@executable_path/\(dylibName)"
                } catch let error {
                    finishHandle(false, "Dylib移动失败: \(error.localizedDescription)")
                    return
                }
            }
        }
        
        Inject.injectMachO(machoPath: executablePath!,
                           cmdType: LCType.loadDylib,
                           backup: false,
                           injectPath: injectDylibPath) { result in
            finishHandle(result, "")
        }
    }
    
    // App重签名
    public static func reSign(appPath: String){
        Shell.run("codesign --force --deep --sign - \(appPath)") { _, output in
            print(output)
        }
    }
    
    // 动态注入Dylib
    public static func dynamicInject(){
        
    }
    
    // 查找App主执行文件的路径
    private static func findAppMainMacho(appPath: String) -> String? {
        let infoPlistPath = appPath.appending("/Contents/Info.plist")

        guard let plist = NSDictionary(contentsOfFile: infoPlistPath),
              let executableName = plist["CFBundleExecutable"] as? String else {
            return nil
        }
        
        return appPath.appending("/Contents/MacOS/\(executableName)")
    }
}
