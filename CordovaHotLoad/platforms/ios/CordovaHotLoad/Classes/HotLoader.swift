//
//  Config.swift
//  CordovaHotLoad
//
//  Created by plter on 8/25/16.
//
//

import UIKit

@objc class HotLoader: NSObject {
    
    static let remoteAppPath = "http://localhost/cordovapp"
    static let remoteManifestPath = HotLoader.remoteAppPath.stringByAppendingString("/manifest.plist");
    static let homePath = NSHomeDirectory()
    static let docPath = HotLoader.homePath.stringByAppendingString("/Documents")
    static let localAppPath = HotLoader.docPath.stringByAppendingString("/cordova");
    static let localManifestPath = HotLoader.localAppPath.stringByAppendingString("/manifest.plist");
    static let fileManager = NSFileManager.defaultManager()
    
    static func getAppPath()->String?{
        if let manifest = HotLoader.readLocalManifest(){
            let app = manifest["app"]
            return localAppPath.stringByAppendingString("/\(app!)")
        }else{
            return nil;
        }
    }
    
    static func localManifestExists()->Bool{
        return HotLoader.fileManager.fileExistsAtPath(HotLoader.localManifestPath)
    }
    
    static func readLocalManifest()-> NSDictionary?{
        return NSDictionary(contentsOfFile: HotLoader.localManifestPath)
    }
    
    static func readRemoteManifest()->NSDictionary?{
        return NSDictionary(contentsOfURL: NSURL(string: HotLoader.remoteManifestPath)!)
    }
    
    static func loadRemoteApp(){
        
        let files = HotLoader.readRemoteManifest()!["files"];
        
        for item in (files?.objectEnumerator())!{
            let file:String = item as! String
            let dist = localAppPath.stringByAppendingString("/\(file)")
            let data = NSData(contentsOfURL: NSURL(string: remoteAppPath.stringByAppendingString("/\(file)"))!)
            
            print("write to \(dist)");
            
            var index = dist.endIndex
            var found = false
            
            while true {
                index = index.predecessor()
                let c = dist.characters[index]
                
                if c == "/" {
                    found = true
                    break
                }
                
                if index == dist.startIndex {
                    break
                }
            }
            if found{
                let dir = dist.substringToIndex(index)
                
                let _ = try? HotLoader.fileManager.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
            }
            
            HotLoader.fileManager.createFileAtPath(dist, contents: data, attributes: nil)
        }
    }
    
    static func checkToSync(){
        if !HotLoader.localManifestExists() {
            HotLoader.loadRemoteApp()
        }else{
            let remoteDic = HotLoader.readRemoteManifest();
            let localDic = HotLoader.readLocalManifest();
            
            if remoteDic!["version"] as! Int > localDic!["version"] as! Int {
                HotLoader.loadRemoteApp();
            }
        }
    }
}
