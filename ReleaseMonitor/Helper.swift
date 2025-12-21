//
//  Helper.swift
//  JavaUpdater
//
//  Created by Gerrit Grunwald on 04.02.24.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications


public struct Helper {
    @Environment(NetworkMonitor.self) var networkMonitor : NetworkMonitor
    private static                    let dateFormatter  : DateFormatter  = DateFormatter()
    
    public static func findDefaultJVMs() -> [JVM] {
        var jvmsFound : [JVM]   = []
        let shell     : CmdExec = Shell()
       
        // Find default JVM defined by libexec/java_home
        var maintainerLibExec : Constants.Maintainer?
        var javaFileLibExec   : String?
        if let output : String = try? shell.run(cmd: "/usr/libexec/java_home", args: []) {
            javaFileLibExec = output.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if javaFileLibExec!.contains(Constants.Maintainer.sdkman.folders[0]) {
                maintainerLibExec = .sdkman
            } else if javaFileLibExec!.contains(Constants.Maintainer.jbang.folders[0]) {
                maintainerLibExec = .jbang
            } else if javaFileLibExec!.contains(Constants.Maintainer.homebrew.folders[0]) || javaFileLibExec!.contains(Constants.Maintainer.homebrew.folders[1]) {
                maintainerLibExec = .homebrew
            } else if javaFileLibExec!.contains(Constants.Maintainer.user.folders[0]) || javaFileLibExec!.contains(Constants.Maintainer.user.folders[1]) {
                maintainerLibExec = .user
            } else {
                maintainerLibExec = .custom
            }
            if javaFileLibExec!.starts(with: "/") {
                javaFileLibExec! += "/bin/java"
                if Helper.folderExists(path: javaFileLibExec!) {
                    jvmsFound.append(getJVM(javaFile: javaFileLibExec!, maintainer: maintainerLibExec!))
                }
            }
        }
        
        // Find default JVM defined by /usr/bin/java -version
        if Helper.fileExists(path: "/usr/bin/java") {
            jvmsFound.append(getJVM(javaFile: "/usr/bin/java", maintainer: Constants.Maintainer.user))
        }
        return jvmsFound
    }
    
    public static func findJVMs(maintainer: Constants.Maintainer) async -> Set<JVM> {
        var jvms      : Set<JVM>    = []
        var javaFiles : Set<String> = Set<String>()
        for folder in maintainer.folders {
            if Helper.folderExists(path: folder) {
                //javaFiles = javaFiles.union(await Helper.findJava(path: folder))
                javaFiles = javaFiles.union(Helper.findJava(at: folder))
            }
        }
        //debugPrint("Find java files \(maintainer.text): \((Double(DispatchTime.now().uptimeNanoseconds) - startTime) / 1_000_000.0)ms")
        //startTime = Double(DispatchTime.now().uptimeNanoseconds)
        for javaFile in javaFiles {
            if !Helper.fileIsSymlink(path: javaFile) {
                let jvmFound : JVM = Helper.getJVM(javaFile: javaFile, maintainer: maintainer)
                if !jvmFound.bundledJRE && !jvmFound.name.isEmpty {
                    jvms.insert(jvmFound)
                }
            }
        }
        //debugPrint("Get JVMs \(maintainer.text): \((Double(DispatchTime.now().uptimeNanoseconds) - startTime) / 1_000_000.0)ms")
        return jvms
    }
    
    private static func findJava(at path: String) -> Set<String> {
        var files : Set<String> = Set<String>()
        if let enumerator = FileManager.default.enumerator(at: URL(string: path)!, includingPropertiesForKeys: [.isRegularFileKey, .isReadableKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                if fileURL.lastPathComponent == "java" {
                    files.insert(fileURL.absoluteString.replacingOccurrences(of: "file://", with: ""))
                }
            }
        }
        return files
    }
    
    public static func getJVM(javaFile: String, maintainer: Constants.Maintainer) -> JVM {
        let parentPath      : String                    = javaFile.replacingOccurrences(of: "/bin/java", with: "")
        let releaseFile     : String                    = "\(parentPath)/release"
        var name            : String                    = Constants.UNKNOWN_BUILD_OF_OPENJDK
        var apiString       : String                    = ""
        var version         : VersionNumber?
        var graalvmVersion  : VersionNumber?
        var jdkVersion      : VersionNumber?
        var buildScope      : Constants.BuildScope      = Constants.BuildScope.build_of_openjdk
        var operatingSystem : Constants.OperatingSystem = Constants.OperatingSystem.macos
        var architecture    : Constants.Architecture    = getArchitecture()
        var packageType     : Constants.PackageType     = Constants.PackageType.jdk
        var termOfSupport   : Constants.TermOfSupport   = Constants.TermOfSupport.not_found
        var bundledJRE      : Bool                      = false
        var fx              : Bool                      = false
        var modules         : [String]                  = []
        var feature         : Constants.Feature         = Constants.Feature.none
        let shell           : CmdExec                   = Shell()
        var javaVersionText : String                    = ""
        var implementor     : String                    = ""
        var vendor          : String                    = ""
        var javaModulesText : String                    = ""
        
        // Get java -version
        if let output : String = try? shell.run(cmd: javaFile, args: ["-version"]) {
            javaVersionText.append(output)
        }
        
        // Get java --list-modules
        if let output : String = try? shell.run(cmd: javaFile, args: ["--list-modules"]) {
            javaModulesText.append(output)
        }
        if !javaModulesText.starts(with: "Unrecognized option") {
            modules = javaModulesText.components(separatedBy: "\n")
            modules.removeLast()
        }
        if let output : String = try? shell.run(cmd: "file", args: [javaFile]) {
            let archTxt : String = (output.components(separatedBy: " ").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            architecture = Constants.Architecture.fromText(text: archTxt)
        }
        
        let lines         : [String] = javaVersionText.components(separatedBy: "\n")
        let line1         : String   = lines[0]
        let line2         : String
        let line3         : String
        
        if lines.count > 1 {
            line2 = lines[1]
        } else {
            line2 = ""
        }
                
        if lines.count > 2 {
            line3 = lines[2]
        } else {
            line3 = ""
        }
        
        var withoutPrefix : String   = line1
        
        if line1.starts(with: "openjdk") {
            withoutPrefix = line1.replacingOccurrences(of: "openjdk version", with: "")
        } else if line1.starts(with: "java") {
            withoutPrefix = line1.replacingOccurrences(of: "java version", with: "")
            
            if line2.contains("GraalVM") {
                name       = "GraalVM"
                apiString  = "graalvm"
                buildScope = Constants.BuildScope.build_of_graalvm
            } else {
                name       = "Oracle"
                apiString  = "oracle"
            }
        }
        
        if apiString != "graalvm" && line2.contains("jvmci") {
            Helper.dateFormatter.dateFormat = "yyyy-MM-dd"
            let buildDate : Date = Helper.dateFormatter.date(from: line1.components(separatedBy: " ").last!) ?? Date.init(timeIntervalSince1970: 1697328001)
            //let index = line2.range(of: "jvmci")!.lowerBound
            //let versionText : String = String(line2[index..<line2.endIndex]).replacingOccurrences(of: "jvmci", with: "")
            if buildDate > Constants.UNIFIED_VERSION_GRAAL_DATE {
                name       = "GraalVM Community"
                apiString  = "graalvm_community"
                buildScope = Constants.BuildScope.build_of_graalvm
            }
        }
        
        if line2.contains("Zulu") {
            name      = "Zulu"
            apiString = "zulu"
            for match in line2.matches(of: Constants.ZULU_BUILD_PATTERN) {
                let result : String = String(match.output.2)
                version = VersionNumber.fromText(text: result)
            }
        } else if line2.contains("Zing") || line2.contains("Prime") {
            name      = "Prime"
            apiString = "zulu_prime"
            for match in line2.matches(of: Constants.ZULU_BUILD_PATTERN) {
                let result : String = String(match.output.2)
                version = VersionNumber.fromText(text: result)
            }
        } else if line2.contains("Semeru") {
            if line2.contains("Certified") {
                name      = "Semeru certified"
                apiString = "semeru_certified"
            } else {
                name      = "Semeru"
                apiString = "semeru"
            }
        } else if line2.contains("Homebrew") {
            name      = "Homebrew"
            apiString = "homebrew"
        } else if line2.contains("Tencent") {
            name      = "Kona"
            apiString = "kona"
        } else if line2.contains("Bisheng") {
            name      = "Bishenq"
            apiString = "bisheng"
        } else if line2.contains("Homebrew") {
            name      = "Homebrew"
            apiString = "homebrew"
        } else if line2.starts(with:"Java(TM) SE") {
            if line3.contains("GraalVM") {
                name       = "GraalVM"
                apiString  = "graalvm"
                buildScope = Constants.BuildScope.build_of_graalvm
            } else {
                name      = "Oracle"
                apiString = "oracle"
            }
        }
        
        if nil == version {
            let start : Int = withoutPrefix.indexOf(with: "\"") + 1
            let end   : Int = withoutPrefix.lastIndexOf(with: "\"")
            
            if end > 0 {
                let versionNumberText : String = withoutPrefix.substring(with: start..<end)
                version = VersionNumber.fromText(text: versionNumberText)
            } else {
                debugPrint("Problems with: \(javaFile)")
                return JVM()
            }
        }
        let graalVersion : VersionNumber = version ?? VersionNumber(feature: 0)
        
        
        if fileExists(path: releaseFile) {
            let releasePropertiesText : String          = getFile(filename: releaseFile)
            let releaseProperties     : [String:String] = getProperties(text: releasePropertiesText)
            if !releaseProperties.isEmpty {
                if releaseProperties.keys.contains(Constants.KEY_VENDOR) {
                    vendor = releaseProperties[Constants.KEY_VENDOR]!.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\n", with: "")
                }
                
                if releaseProperties.keys.contains(Constants.KEY_IMPLEMENTOR) {
                    implementor = releaseProperties[Constants.KEY_IMPLEMENTOR]!.replacingOccurrences(of: "\"", with: "")
                }
                
                if releaseProperties.keys.contains(Constants.KEY_IMPLEMENTOR) && name == Constants.UNKNOWN_BUILD_OF_OPENJDK {
                    switch implementor {
                    case "AdoptOpenJDK":
                        name      = "Adopt OpenJDK"
                        apiString = "aoj"
                    case "Alibaba":
                        name = "Dragonwell"
                        apiString = "dragonwell"
                    case "Amazon.com Inc.":
                        name      = "Corretto"
                        apiString = "corretto"
                    case "Azul Systems, Inc.":
                        if releaseProperties.keys.contains(Constants.KEY_IMPLEMENTOR_VERSION) {
                            let implementorVersion : String = releaseProperties[Constants.KEY_IMPLEMENTOR_VERSION]!
                            if implementorVersion.starts(with: "Zulu") {
                                name      = "Zulu"
                                apiString = "zulu"
                            } else if implementorVersion.starts(with: "Zing") || implementorVersion.starts(with: "Prime") {
                                name      = "ZuluPrime"
                                apiString = "zulu_prime"
                            }
                        }
                    case "mandrel":
                        name       = "Mandrel"
                        apiString  = "mandrel"
                        buildScope = Constants.BuildScope.build_of_graalvm
                    case "Microsoft":
                        name      = "Microsoft"
                        apiString = "microsoft"
                    case "ojdkbuild":
                        name      = "OJDK Build"
                        apiString = "ojdk_build"
                    case "Oracle Corporation":
                        name      = "Oracle OpenJDK"
                        apiString = "oracle_open_jdk"
                    case "Red Hat, Inc.":
                        name      = "Red Hat"
                        apiString = "redhat"
                    case "SAP SE":
                        name      = "SAP Machine"
                        apiString = "sap_machine"
                    case "OpenLogic":
                        name      = "OpenLogic"
                        apiString = "openlogic"
                    case "JetBrains s.r.o.":
                        name      = "JetBrains"
                        apiString = "jetbrains"
                    case "Eclipse Foundation":
                        name      = "Temurin"
                        apiString = "temurin"
                    case "Tencent":
                        name      = "Kona"
                        apiString = "kona"
                    case "Bisheng":
                        name      = "Bisheng"
                        apiString = "bisheng"
                    case "Debian":
                        name      = "Debian"
                        apiString = "debian"
                    case "Ubuntu":
                        name      = "Ubuntu"
                        apiString = "ubuntu"
                    case "Homebrew":
                        name      = "Homebrew"
                        apiString = "homebrew"
                    case "N/A":
                        break
                    default:
                        break
                    }
                }
                
                if architecture == Constants.Architecture.not_found && releaseProperties.keys.contains(Constants.KEY_OS_ARCH) {
                    architecture = Constants.Architecture.fromText(text: releaseProperties[Constants.KEY_OS_ARCH]!.lowercased().replacingOccurrences(of: "\"", with: ""))
                }
                
                if releaseProperties.keys.contains(Constants.KEY_GRAALVM_VERSION) {
                    let graalVersionText : String = releaseProperties[Constants.KEY_GRAALVM_VERSION]!
                    graalvmVersion = VersionNumber.fromText(text: graalVersionText)
                }
                
                if releaseProperties.keys.contains(Constants.KEY_BUILD_TYPE) {
                    switch releaseProperties[Constants.KEY_BUILD_TYPE]!.replacingOccurrences(of: "\"", with: "") {
                    case "commercial":
                        name      = "Oracle"
                        apiString = "oracle"
                    default:
                        break;
                    }
                }
                
                if releaseProperties.keys.contains(Constants.KEY_JVM_VARIANT) {
                    let jvmVariant : String = releaseProperties[Constants.KEY_JVM_VARIANT]!.lowercased().replacingOccurrences(of: "\"", with: "")
                    if jvmVariant == "dcevm" {
                        name      = "Trava OpenJDK"
                        apiString = "trava"
                    } else if jvmVariant == "openj9" {
                        name      = "Adopt OpenJDK J9"
                        apiString = "aoj_openj9"
                    }
                }
                
                if releaseProperties.keys.contains(Constants.KEY_OS_NAME) {
                    switch releaseProperties[Constants.KEY_OS_NAME]!.lowercased().replacingOccurrences(of: "\"", with: "") {
                    case "darwin":
                        operatingSystem = Constants.OperatingSystem.macos
                    case "linux":
                        operatingSystem = Constants.OperatingSystem.linux
                    case "windows":
                        operatingSystem = Constants.OperatingSystem.windows
                    default:
                        break;
                    }
                }
                
                if modules.isEmpty && releaseProperties.keys.contains(Constants.KEY_MODULES) && !fx {
                    fx = releaseProperties[Constants.KEY_MODULES]!.contains("javafx")
                    let modulesArray : [String] = releaseProperties[Constants.KEY_MODULES]!.replacingOccurrences(of: "\"", with: "").components(separatedBy: " ")
                    for module in modulesArray {
                        modules.append(module)
                    }
                }
                
                /*
                 if name.lowercased() == "mandrel" {
                 if graalvmVersion != nil { version = graalvmVersion! }
                 }
                 */
                
                if releaseProperties.keys.contains(Constants.KEY_JAVA_VERSION) {
                    let javaVersion : String = releaseProperties[Constants.KEY_JAVA_VERSION]!
                    if jdkVersion == nil {
                        jdkVersion = VersionNumber.fromText(text: javaVersion)
                    }
                }
            }
        }
        
        if lines.count > 2 {
            let line3 = lines[2].lowercased()
            for feat in Constants.FEATURES {
                if line3.contains(feat) {
                    feature = Constants.Feature.fromText(text: feat)
                }
            }
        }
        
        if name == Constants.UNKNOWN_BUILD_OF_OPENJDK && lines.count > 2 {
            let line3  : String = lines[2].lowercased()
            let readme : String = "\(parentPath)/readme.txt"
            if fileExists(path: readme) {
                let readmeLines : [String] = getFile(filename: readme).components(separatedBy: "\n")
                for line in readmeLines {
                    if line.contains("Liberica Native Image Kit") {
                        name       = "Liberica Native"
                        apiString  = "liberica_native"
                        if graalvmVersion != nil { version = graalvmVersion! }
                        buildScope = Constants.BuildScope.build_of_graalvm
                    } else if line.contains("BellSoft Liberica is a") {
                        name       = "Liberica"
                        apiString  = "liberica"
                    }
                }
            } else {
                if line3.contains("graalvm") && apiString != "graalvm_community" && apiString != "graalvm" {
                    buildScope = Constants.BuildScope.build_of_graalvm
                    name       = "GraalVM CE"
                    var distroPreFix = "graalvm_ce"
                    switch implementor {
                    case "GraalVM Community":
                        name         = "GraalVM CE"
                        distroPreFix = "graalvm_ce"
                    case "GraalVM Enterprise":
                        name         = "GraalVM"
                        distroPreFix = "graalvm"
                    default:
                        break
                    }
                    apiString = graalVersion.feature! >= 8 ? "\(distroPreFix)\(graalVersion.feature!)" : ""
                    if vendor.caseInsensitiveCompare("gluon") == .orderedSame {
                        name       = "Gluon GraalVM"
                        apiString  = "gluon_graalvm"
                        if graalvmVersion != nil { version = graalvmVersion! }
                    }
                } else if line3.contains("microsoft") {
                    name      = "Microsoft"
                    apiString = "microsoft"
                } else if line3.contains("corretto") {
                    name      = "Corretto"
                    apiString = "corretto"
                } else if line3.contains("temurin") {
                    name      = "Temurin"
                    apiString = "temurin"
                }
            }
        }
        
        // Detect bundled JRE before JDK 9
        let jreSuffix = "jre"
        if !parentPath.hasSuffix(".\(jreSuffix)") && parentPath.hasSuffix(jreSuffix) {
            packageType = Constants.PackageType.jre
            bundledJRE  = true
        }
        
        // Detect JavaFX before JDK 9
        if !fx {
            let jreLibFolder : String = "\(parentPath)/jre/lib/ext"
            if folderExists(path: jreLibFolder) {
                packageType = Constants.PackageType.jdk
                bundledJRE  = false
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: jreLibFolder)
                    fx = files.contains("jfxrt.jar")
                } catch {
                    
                }
            }
        }
        
        // Detect JDK/JRE after JDK 9
        let jmodsFolder : String = "\(parentPath)/jmods"
        if folderExists(path: jmodsFolder) {
            packageType = Constants.PackageType.jdk
            bundledJRE  = false
            // Detect bundled JavaFX
            if !fx {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: jmodsFolder)
                    let javafxFilesFound = files.filter { file in
                        if file.starts(with: "javafx") {
                            return true
                        } else {
                            return false
                        }
                    }
                    fx = javafxFilesFound.count > 0
                } catch {
                    
                }
            }
        } else if (version!.feature! > 8) {
            let libFolder : String = "\(parentPath)/bin"
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: libFolder)
                let javadocFound = files.filter { file in
                    if file.contains("javadoc") {
                        return true
                    } else {
                        return false
                    }
                }
                packageType = javadocFound.count > 0 ? Constants.PackageType.jdk : Constants.PackageType.jre
            } catch {
                
            }
            bundledJRE  = false
            // Detect bundled JavaFX
            if !fx {
                let libFolder : String = "\(parentPath)/lib"
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: libFolder)
                    let javafxFilesFound = files.filter { file in
                        if file.starts(with: "libjavafx") {
                            return true
                        } else {
                            return false
                        }
                    }
                    fx = javafxFilesFound.count > 0
                } catch {
                    
                }
            }
        } else {
            // Detect JDK/JRE before JDK 9
            let libFolder : String = "\(parentPath)/bin"
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: libFolder)
                let javadocFound = files.filter { file in
                    if file.contains("javadoc") {
                        return true
                    } else {
                        return false
                    }
                }
                packageType = javadocFound.count > 0 ? Constants.PackageType.jdk : Constants.PackageType.jre
            } catch {
                
            }
        }
        
        if nil == jdkVersion {
            jdkVersion = version
        }
        
        var path : String = parentPath
        do {
            let pathPattern : Regex = try  Regex("(.*\\/Library\\/Java\\/JavaVirtualMachines\\/\\b(?!\\/\\b)[\\w\\d+_\\.\\-]+)|(\\/Library\\/Java\\/\\b(?!JavaVirtualMachines\\/\\b)[\\w\\d+\\.\\-]+)|(\(Helper.getUserFolder())\\.jbang\\/cache\\/jdks\\/.*)|(\(Helper.getUserFolder())\\.sdkman\\/candidates\\/java\\/.*)")
            if let match = parentPath.firstMatch(of: pathPattern) {
                if nil != match.output[1].substring {
                    path = String(match.output[1].substring!)
                } else if nil != match.output[2].substring {
                    path = String(match.output[2].substring!)
                } else if nil != match.output[3].substring {
                    path = String(match.output[3].substring!)
                } else if nil != match.output[4].substring {
                    path = String(match.output[4].substring!)
                }
            }
        } catch {
            path = parentPath
        }
        
        if (version!.feature! > 17 || graalvmVersion == nil) { graalvmVersion = version! }
        
        switch buildScope {
        case .build_of_graalvm:
            if version!.feature! == jdkVersion!.feature! {
                termOfSupport = Helper.isLTS(featureVersion: version!.feature!) ? .lts : .sts
            } else {
                termOfSupport = Helper.isLTS(featureVersion: jdkVersion!.feature!) ? .lts : .sts
            }
        default:
            termOfSupport = Helper.isLTS(featureVersion: version!.feature!) ? .lts : .sts
        }
        
        let distro : Distro = Distro.fromText(text: apiString)
        let jvm    : JVM = JVM(name: name, distro: distro, version: version!.toString(), graalversion: graalvmVersion!.toString(), jdkVersion: jdkVersion!.toString(), operatingSystem: operatingSystem, architecture: architecture, packageType: packageType, termOfSupport: termOfSupport, bundledJRE: bundledJRE, fx: fx, feature: feature, location: parentPath, maintainer: maintainer, path: path, modules: modules)
        
        return jvm
    }
    
    public static func getArchitecture() -> Constants.Architecture {
        var sysInfo : utsname = utsname()
        let retVal  : Int32   = uname(&sysInfo)
        var result  : String? = nil
        
        if retVal == EXIT_SUCCESS {
            let bytes = Data(bytes: &sysInfo.machine, count: Int(_SYS_NAMELEN))
            result    = String(data: bytes, encoding: .utf8)
        }
        
        return nil == result ? Constants.Architecture.not_found : Constants.Architecture.fromText(text: result!.trimmingCharacters(in: CharacterSet(charactersIn: "\0")))
    }
    
    public static func getUserFolder() -> String {
        return URL.userHomePath + "/"
    }
    
    public static func getJavaHome() -> String {
        let shell : CmdExec = Shell()
        if let output = try? shell.run(cmd: "/usr/bin/env", args: []) {
            if let result = output.firstMatch(of: Constants.JAVA_HOME_PATTERN) {
                return "\(result.2)"
            }
        }
        return "-"
    }
    
    public static func getFile(filename: String) -> String {
        let contents = try? String(contentsOfFile: filename, encoding: String.Encoding.ascii)
        return contents ?? ""
    }
    
    public static func getProperties(text: String) -> [String:String] {
        var properties : [String:String] = [:]
        for match in text.matches(of: Constants.PROPERTY_PATTERN) {
            let property : String   = String(match.output.1)
            //let value    : [String] = property == Constants.KEY_MODULES ? String(match.output.2).components(separatedBy: " ") : [ String(match.output.2) ]
            let value    : String   = String(match.output.2)
            properties[property] = value
        }
        return properties
    }
    
    public static func getPropertiesSplitArrays(text: String) -> [String:[String]] {
        var properties : [String:[String]] = [:]
        for match in text.matches(of: Constants.PROPERTY_PATTERN) {
            let property : String   = String(match.output.1)
            let value    : [String] = property == Constants.KEY_MODULES ? String(match.output.2).components(separatedBy: " ") : [ String(match.output.2) ]
            properties[property] = value
        }
        return properties
    }
    
    public static func deleteFile(filename: String) -> Void {
        do {
            try FileManager.default.removeItem(atPath: filename)
            debugPrint("File deleted successfully")
        } catch {
            debugPrint("Error deleting file: \(error)")
        }
    }
    
    public static func fileExistsInDownloadFolder(filename: String) -> Bool {
        let downloadFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let file           = downloadFolder?.appendingPathComponent(filename)
        return file == nil ? false : FileManager().fileExists(atPath: file!.path)
    }
    
    public static func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    public static func fileIsSymlink(path: String) -> Bool {
        do {
            let node = try FileWrapper(url: URL(fileURLWithPath: path), options: .immediate)
            return node.isSymbolicLink
        } catch {
            return false
        }
    }
    
    public static func folderExists(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public static func createFolder(path: String) -> Bool {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                debugPrint("Error creating folder \(path): \(error)")
                return false
            }
        }
        return false
    }
    
    public static func getFileDateAttributes(at path: String) -> (created: Date?, modified: Date?) {
        do {
            let attributes:[FileAttributeKey:Any] = try FileManager.default.attributesOfItem(atPath: path)
            let modificationDate                  = attributes[FileAttributeKey.modificationDate] as? Date
            let creationDate                      = attributes[FileAttributeKey.creationDate]     as? Date
            return (creationDate, modificationDate)
        } catch {
            debugPrint("Error getting attributes of file: \(path). Check if file exists and that the system can access its attributes.")
            return (nil, nil)
        }
    }
    
    public static func parseMajorVersionJSONEntries(data: Data) -> [MajorVersion]? {
        var majorVersions: [MajorVersion]?
        do {
            let jsonDecoder        = JSONDecoder()
            let dictionaryFromJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            let jsonItem           = dictionaryFromJSON["result"] as? NSArray
            let jsonData           = try JSONSerialization.data(withJSONObject: jsonItem!, options: [])
            majorVersions          = try jsonDecoder.decode([MajorVersion].self, from: jsonData)
        } catch {
            majorVersions = []
        }
        return majorVersions
    }
    
    public static func parsePkgsJSONEntries(data: Data) -> [Pkg]? {
        var pkgs: [Pkg]?
        do {
            let jsonDecoder        : JSONDecoder = JSONDecoder()
            let dictionaryFromJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            let jsonItem           = dictionaryFromJSON["result"] as? NSArray
            if jsonItem != nil {
                let jsonData  = try JSONSerialization.data(withJSONObject: jsonItem!, options: [])
                pkgs          = try jsonDecoder.decode([Pkg].self, from: jsonData)
            }
        } catch {
            pkgs = []
        }
        return pkgs
    }
    
    public static func parseCVEJSONEntries(text: String) -> [CVE]? {
        if text.isEmpty { return [] }
        let jsonDecoder : JSONDecoder = JSONDecoder()
        let jsonData                  = text.data(using: .utf8)
        let cves        : [CVE]
        do {
            cves = try jsonDecoder.decode([CVE].self, from: jsonData!)
        } catch {
            debugPrint("Error parsing cve json: \(error)")
            debugPrint(text)
            cves = []
        }
        return cves
    }
    
    static func parseDistributionJSONEntries(data: Data) -> [VersionNumber]? {
        var versionsFound    : [VersionNumber]  = []
        let distributionData : DistributionData = try! JSONDecoder().decode(DistributionData.self, from: data)
        if let results : [Result] = distributionData.result {
            let result : Result   = results.first!
            for version in result.versions! {
                versionsFound.append(VersionNumber.fromText(text: version))
            }
        }
        return versionsFound.sorted(by: { $0 > $1 })
    }
    
    static func parseUpcomingReleasesJSONEntries(data: Data) -> [UpcomingReleases]? {
        var upcomingReleases     : [UpcomingReleases]    = []
        let upcomingReleasesData : UpcomingReleasesData = try! JSONDecoder().decode(UpcomingReleasesData.self, from: data)
        if let results : [UpcomingReleases] = upcomingReleasesData.result {
            upcomingReleases = results
        }
        return upcomingReleases
    }
    
    static func parseDistributionVersionsJSONEntries(data: Data) -> [DistributionVersions]? {
        var distributionVersions     : [DistributionVersions]    = []
        let latestVersionData : LatestVersionData = try! JSONDecoder().decode(LatestVersionData.self, from: data)
        if let results : [DistributionVersions] = latestVersionData.result {
            distributionVersions = results
        }
        return distributionVersions
    }
    
    static func parseAdvisoriesJSONEntries(data: Data) -> [Advisory]? {
        var advisories   : [Advisory]   = []
        let advisoryData : AdvisoryData = try! JSONDecoder().decode(AdvisoryData.self, from: data)
        if let results : [Advisory] = advisoryData.result {
            advisories = results
        }
        return advisories
    }
    
    public static func findFirstFolder(path: String) -> String {
        let enumerator = FileManager.default.enumerator(atPath: path)
        while let element = enumerator?.nextObject() as? String {
            if enumerator?.fileAttributes?[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory {
                return element
            }
        }
        return ""
    }
    
    public static func findBinParentFolder(path: String) -> String {
        let enumerator = FileManager.default.enumerator(atPath: path)
        while let element = enumerator?.nextObject() as? String {
            if enumerator?.fileAttributes?[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory {
                if element.lowercased().hasSuffix("bin") {
                    return "\(path)\(path.hasSuffix("/") ? "" : "/")\(element.replaceAll(of: "bin", with: ""))"
                }
            }
        }
        return ""
    }
    
    public static func index(of text: String, in source: String) -> Int? {
        for (index, _) in source.enumerated() {
            var found = true
            for (offset, char2) in text.enumerated() {
                if source[source.index(source.startIndex, offsetBy: index + offset)] != char2 {
                    found = false
                    break
                }
            }
            if found {
                return index
            }
        }
        return nil
    }
    
    public static func isPositiveInt(text: String) -> Bool {
        if Int(text) != nil {
            return Int(text)! > 0
        } else {
            return false
        }
    }
    
    public static func trimPrefix(text: String, prefix: String) -> String {
        if let range = text.range(of: prefix) {
            return text.replacingCharacters(in: range, with: "")
        } else {
            return text
        }
    }
    
    public static func writeToFile(text: String, filename: String) -> Bool {
        do {
            debugPrint("Try to write \(filename)")
            try text.write(toFile: "\(filename)", atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    public static func readFromFile(filename: String) -> String {
        do {
            let text : String = try String( contentsOf: URL(fileURLWithPath: filename), encoding: .utf8)
            return text
        }
        catch {
            return ""
        }
    }
    
    public static func getCVEs(jdkType: Constants.JDKType) async -> [CVE] {
        let cveScanner : CveScanner = CveScanner()
        let cves       : [CVE]      = await cveScanner.getCVEs(jdkType: jdkType)
        return cves
    }
    
    static func getCVEsForVersion(versionNumber: VersionNumber, cves: [CVE]) -> [CVE] {
        let cvesFound : [CVE] = cves.filter( { $0.affectedVersions.contains(where: { ($0.toString(outputFormat: Constants.OutputFormat.full, javaFormat: true, includeReleaseStatusAndBuild: false) == versionNumber.toString(outputFormat: Constants.OutputFormat.full, javaFormat: true, includeReleaseStatusAndBuild: false)) }) } )
        return cvesFound
    }
    
    static func getAffectedVersionsText(cve: CVE) -> String {
        var affectedVersions = ""
        for version in cve.affectedVersions.sorted(by: { $0 < $1 }) {
            affectedVersions += "\(version.toNormalizedVersionNumber(javaFormat: true)),"
        }
        if !affectedVersions.isEmpty { affectedVersions.removeLast() }
        return affectedVersions
    }
    
    public static func getUpdatesForJVM(jvm: JVM) async -> Void {
        let pkgs : [Pkg] = await RestController.fetchLatestBuildAvailableFor(jvm: jvm)
        jvm.eaUpdates.removeAll()
        jvm.gaUpdates.removeAll()
        for pkg in pkgs {            
            if pkg.javaVersion > jvm.versionNumber {
                if pkg.releaseStatus == Constants.ReleaseStatus.ea {
                    jvm.eaUpdates.append(pkg)
                } else {
                    jvm.gaUpdates.append(pkg)
                }
            }
        }
    }
    
    public static func isReleaseTermOfSupport(featureVersion: Int, termOfSupport: Constants.TermOfSupport) -> Bool {
        switch termOfSupport {
        case .lts : return isLTS(featureVersion: featureVersion)
        case .mts : return isMTS(featureVersion: featureVersion)
        case .sts : return isSTS(featureVersion: featureVersion)
        default  : return false
        }
    }
    
    public static func isSTS(featureVersion: Int) -> Bool {
        if featureVersion < 9 { return false }
        switch featureVersion {
        case 9, 10 : return true
        default    : return !isLTS(featureVersion: featureVersion)
        }
    }
    
    public static func isMTS(featureVersion: Int) -> Bool {
        if featureVersion < 13 { return false }
        return !isLTS(featureVersion: featureVersion) && Double(featureVersion).truncatingRemainder(dividingBy: 2) != 0
    }
    
    public static func isLTS(featureVersion: Int) -> Bool {
        if featureVersion < 1  { return false }
        if featureVersion <= 8 { return true }
        if featureVersion < 11 { return false }
        if featureVersion < 17 { return ((Double(featureVersion) - 11.0) / 6.0).truncatingRemainder(dividingBy: 1) == 0 }
        return ((Double(featureVersion) - 17.0) / 4.0).truncatingRemainder(dividingBy: 1) == 0
    }
    
    static func getTermOfSupport(versionNumber: VersionNumber, isZulu: Bool) -> Constants.TermOfSupport {
        let termOfSupport : Constants.TermOfSupport = Helper.getTermOfSupport(versionNumber: versionNumber)
        switch termOfSupport {
        case .lts, .sts : return termOfSupport
        case .mts       : return isZulu ? termOfSupport : Constants.TermOfSupport.sts
        default         : return Constants.TermOfSupport.not_found
        }
    }
    
    static func getTermOfSupport(versionNumber: VersionNumber) -> Constants.TermOfSupport {
        if versionNumber.feature == nil { return Constants.TermOfSupport.not_found }
        return Helper.getTermOfSupport(featureVersion: versionNumber.feature!)
    }
    
    public static func getTermOfSupport(featureVersion: Int) -> Constants.TermOfSupport {
        if featureVersion < 1 { return Constants.TermOfSupport.not_found }
        if Helper.isLTS(featureVersion: featureVersion) {
            return Constants.TermOfSupport.lts
        } else if Helper.isMTS(featureVersion: featureVersion) {
            return Constants.TermOfSupport.mts
        } else if Helper.isSTS(featureVersion: featureVersion) {
            return Constants.TermOfSupport.sts
        } else {
            return Constants.TermOfSupport.not_found
        }
    }
    
    public static func secondsToHHMMString(seconds: Double) -> String {
        let hhmmss : (Int, Int) = secondsToHHMM(seconds: seconds)
        return String(format:"%02d:%02d", hhmmss.0, hhmmss.1)
    }
    public static func secondsToHHMM(seconds: Double) -> (Int, Int) {
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3600.0)).truncatingRemainder(dividingBy: 24.0))
        return ( hours, minutes )
    }
    
    public static func secondsToHHMMSSString(seconds: Double) -> String {
        let hhmmss : (Int, Int, Int) = secondsToHHMMSS(seconds: seconds)
        return String(format:"%02d:%02d:%02d", hhmmss.0, hhmmss.1, hhmmss.2)
    }
    public static func secondsToHHMMSS(seconds: Double) -> (Int, Int, Int) {
        let secs    : Int = Int(seconds.truncatingRemainder(dividingBy: 60))
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3600.0)).truncatingRemainder(dividingBy: 24.0))
        return ( hours, minutes, secs )
    }
    
    public static func openTerminal(at url: URL?, text: String){
        guard let url = url, let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") else { return }
        let configuration : NSWorkspace.OpenConfiguration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [text]
        
        NSWorkspace.shared.open([url], withApplicationAt: appUrl, configuration: NSWorkspace.OpenConfiguration()) { (app, error) in
            if nil != app {
                debugPrint(configuration.arguments)
            }
        }
    }
    
    public static func getNextRelease() -> JDKUpdate {
        let now : Date                  = Date()
        let date = Calendar.current.dateComponents([.year], from: now)
        
        var components = DateComponents()
        
        components.year  = date.year
        components.month = 3
        components.day   = 1
        let updateMarch : Date = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        
        components.month = 9
        components.day   = 1
        let updateSeptember : Date = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        
        components.year  = date.year! + 1
        components.month = 3
        components.day   = 1
        let updateNextMarch : Date = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        
        
        let daysToUpdateMarch     = Calendar.current.dateComponents([.day], from: now, to: updateMarch)
        let daysToUpdateSeptember = Calendar.current.dateComponents([.day], from: now, to: updateSeptember)
        let daysToUpdateNextMarch = Calendar.current.dateComponents([.day], from: now, to: updateNextMarch)
        
        var remainingDays : [Date:Int] = [:]
        remainingDays[updateMarch]     = daysToUpdateMarch.day
        remainingDays[updateSeptember] = daysToUpdateSeptember.day
        remainingDays[updateNextMarch] = daysToUpdateNextMarch.day
        
        let sorted = remainingDays.filter { $0.value >= 0 }.sorted { $0.1 < $1.1 }
        
        return JDKUpdate(date: sorted.first!.key, remainingDays: sorted.first!.value + 1, type: Constants.UpdateType.release)
    }
    
    public static func getNextUpdate() -> JDKUpdate {
        let now : Date                  = Date()
        let date       = Calendar.current.dateComponents([.year], from: now)
        var components = DateComponents()
        
        // 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
        components.year  = date.year
        components.month = 1
        components.day   = 1
        let updateJanuary : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.month = 4
        components.day   = 1
        let updateApril : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateApril = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateApril = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.month = 7
        components.day   = 1
        let updateJuly : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateJuly = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateJuly = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.month = 10
        components.day   = 1
        let updateOctober : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateOctober = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateOctober = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        components.year  = date.year! + 1
        components.month = 1
        components.day   = 1
        let updateNextJanuary : Date
        if Calendar.current.component(.weekday, from: Calendar.current.date(from:components)!) == 3 {
            updateNextJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday))!
        } else {
            updateNextJanuary = (Calendar.current.date(from: components)?.next(.tuesday).next(.tuesday).next(.tuesday))!
        }
        
        
        let daysToUpdateJanuary     = Calendar.current.dateComponents([.day], from: now, to: updateJanuary)
        let daysToUpdateApril       = Calendar.current.dateComponents([.day], from: now, to: updateApril)
        let daysToUpdateJuly        = Calendar.current.dateComponents([.day], from: now, to: updateJuly)
        let daysToUpdateOctober     = Calendar.current.dateComponents([.day], from: now, to: updateOctober)
        let daysToUpdateNextJanuary = Calendar.current.dateComponents([.day], from: now, to: updateNextJanuary)
        
        var remainingDays : [Date:Int]   = [:]
        remainingDays[updateJanuary]     = daysToUpdateJanuary.day
        remainingDays[updateApril]       = daysToUpdateApril.day
        remainingDays[updateJuly]        = daysToUpdateJuly.day
        remainingDays[updateOctober]     = daysToUpdateOctober.day
        remainingDays[updateNextJanuary] = daysToUpdateNextJanuary.day
        
        let sorted = remainingDays.filter { $0.value >= 0 }.sorted { $0.1 < $1.1 }
        
        return JDKUpdate(date: sorted.first!.key, remainingDays: sorted.first!.value + 1, type: Constants.UpdateType.release)
    }
    
    public static func getNumberOfWeekdaysIn(weekday: Int, month: Int, year: Int) -> Int {
        let calendar       : Calendar       = Calendar.current
        var dateComponents : DateComponents = DateComponents(year: year, month: month, day: 1)
        let date           : Date           = calendar.date(from: dateComponents)!
        let daysInMonth    : Int            = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        var daysFound      : Int            = 0
        for day in 1..<daysInMonth {
            dateComponents.day = day
            let tmpDate = calendar.date(from: dateComponents)!
            if calendar.component(.weekday, from: tmpDate) == weekday {
                daysFound += 1
            }
        }
        return daysFound
    }
    
    public static func getLatestEaVersion() async -> MajorVersion? {
        let majorVersions : [MajorVersion] = await RestController.fetchLatestMajorVersions(releaseStatus: .ea)
        return majorVersions.isEmpty ? nil : majorVersions.last
    }
    public static func getLatestGaVersion() async -> MajorVersion? {
        let majorVersions : [MajorVersion] = await RestController.fetchLatestMajorVersions(releaseStatus: .ga)
        return majorVersions.isEmpty ? nil : majorVersions.last
    }
    
    public static func getJeps() async -> [JEP] {
        var jepsFound : [JEP]  = []
        let text      : String = await RestController.fetchTextFromUrl(url: Constants.JEP_BASE_URL, encoding: .ascii)
        //let text      : String = await RestController.fetchSourceFromUrl(url: Constants.JEP_BASE_URL, encoding: .ascii)
        
        for result in text.matches(of: Constants.ENHANCED_JEP_PATTERN) {
            let draft       : Bool   = result.1 != nil
            let id          : Int    = Int(result.11) ?? 0
            let description : String = "\(draft ? "(D) " : "")\(String(result.13).htmlDecoded)"
            let url         : String = "\(Constants.JEP_URL)\(id)"
            jepsFound.append(JEP(id: id, description: description, url: url, draft: draft))
        }
        /*
         for result in text.matches(of: Constants.JEP_PATTERN) {
         let id          : Int    = Int(result.2) ?? 0
         let description : String = String(result.4).htmlDecoded
         let url         : String = "\(Constants.JEP_URL)\(id)"
         jepsFound.append(JEP(id: id, description: description, url: url, draft: id > 999999))
         }
         */
        return jepsFound
    }
    
    public static func getJepSummary(for jep: JEP) async -> String {
        var summary : String = ""
        let text    : String = await RestController.fetchTextFromUrl(url: "\(Constants.JEP_URL)/\(jep.id)", encoding: .utf8)
        if let result = text.firstMatch(of: Constants.JEP_SUMMARY_PATTERN) {
            var summaryFound = String(result.1)
            if let index = summaryFound.index(of: "</p>") {
                let substring = summaryFound[..<index]
                summaryFound = String(substring)
            }
            summary = Helper.stripHtml(from: summaryFound).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return summary
    }
    
    public static func getProjects() async -> [Project] {
        var projectsFound : [Project] = []
        let text          : String    = await RestController.fetchTextFromUrl(url: Constants.OPENJDK_PROJECT_URL, encoding: .utf8)
        for result in text.matches(of: Constants.PROJECT_PATTERN) {
            let description : String = String(result.2).htmlDecoded
            let url         : String = "\(Constants.OPENJDK_PROJECT_URL)\(String(result.1))"
            if description != "archive" {
                projectsFound.append(Project(description: description, url: url))
            }
        }
        return projectsFound
    }
    
    static func checkForLatestVersion() async -> VersionNumber? {
        let latestAppInfo      : (VersionNumber?,String?) = await RestController.fetchLatestJDKUpdaterVersion()
        let latestAppVersion   : VersionNumber?           = latestAppInfo.0
        let latestAppPkg       : String?                  = latestAppInfo.1
        let bundleShortVersion : String?                  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let bundleVersion      : String?                  = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        var currentAppVersion  : VersionNumber?
        if bundleShortVersion != nil && bundleVersion != nil {
            currentAppVersion = VersionNumber.fromText(text: "\(bundleShortVersion!)+\(bundleVersion!)")
        }
        if latestAppVersion != nil && latestAppPkg != nil && currentAppVersion != nil {
            if latestAppVersion! > currentAppVersion! {
                return latestAppVersion!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public static func requestAuthorizationForLocalNotifications() -> Void {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    NSApplication.shared.registerForRemoteNotifications()
                }
            } else if error != nil {
                debugPrint("Error requesting authorization for notifications")
            }
        }
    }
    
    public static func notifyWithButtons(title: String, subtitle: String, message: String, withSound: Bool) async -> Void {
        let notificationCenter : UNUserNotificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        /*
         let downloadButton       : UNNotificationAction     = UNNotificationAction(identifier: "JDKUpdater_Download", title: "Download", options: .destructive)
         let notificationCategory : UNNotificationCategory   = UNNotificationCategory(identifier: "content_added_notification", actions: [downloadButton], intentIdentifiers: [])
         
         notificationCenter.setNotificationCategories([notificationCategory])
         */
        
        let content : UNMutableNotificationContent = UNMutableNotificationContent()
        content.title              = title
        content.subtitle           = subtitle
        content.body               = message
        content.badge              = 0
        content.sound              = withSound ? .default : .none
        content.categoryIdentifier = "notification.update_available"
        
        let trigger : UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request : UNNotificationRequest             = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
        if await notificationCenter.deliveredNotifications().filter({ $0.request.content.body == message }).count == 0 {
            do {
                try await notificationCenter.add(request)
            } catch {
                debugPrint("Error adding notification: \(error)")
            }
        }
    }
    
    public static func notify(title: String, subtitle: String, message: String, withSound: Bool) -> Void {
        let content : UNMutableNotificationContent = UNMutableNotificationContent()
        content.title    = title
        content.subtitle = subtitle
        content.body     = message
        content.badge    = 0
        content.sound    = withSound ? .default : .none
        Helper.notify(content: content)
    }
    public static func notify(content: UNMutableNotificationContent) -> Void {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    public static func stripHtml(from text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    public static func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString, let url = URL(string: urlString) {
            return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
        }
        return false
    }
    
    public static func updateJDKFeatures() async {
        let latestGA      : Int = await getLatestGaVersion()!.majorVersion
        let latestKnownGA : Int = Constants.JDK_FEATURES.map( { $0.majorVersion } ).max() ?? 0
        if latestKnownGA < latestGA {
            for majorVersion in latestKnownGA + 1...latestGA {
                let title: String = "JDK \(majorVersion)"
                let url  : String = "https://oome.org/java/java-\(majorVersion)\(isLTS(featureVersion: majorVersion) ? "-lts" : "")"
                if verifyUrl(urlString: url) {
                    Constants.JDK_FEATURES.append(JDKFeature(majorVersion: majorVersion, title: title, url: url))
                }
            }
        }
    }
    
    
    static func getZuluVersions(isConnected: Bool) async -> [VersionNumber:VersionNumber] {
        // Load from file if present and not outdated, otherwise load again and save/update file
        var zuluVersions : [VersionNumber:VersionNumber] = [:]
        if Helper.fileExists(path: Constants.ZULU_VERSION_LOOKUP_FILE) {
            debugPrint("File found: \(Constants.ZULU_VERSION_LOOKUP_FILE)")
            let lastModified : Date? = Helper.getFileDateAttributes(at: Constants.ZULU_VERSION_LOOKUP_FILE).1
            if nil != lastModified && Calendar.current.date(byAdding: .day, value: 30, to: lastModified!)! < Date.init() {
                if isConnected {
                    debugPrint("File outdated -> load zulu versions from cdn")
                    zuluVersions = await getZuluVersionsFromCDN()
                    var text : String = ""
                    for entry in zuluVersions {
                        text += "\(entry.key.toString(outputFormat: .full_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)),\(entry.value.toString(outputFormat: .full_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))\n"
                    }
                    
                    if !zuluVersions.isEmpty {
                        // Delete old file only if fetched Zulu versions are not empty
                        deleteFile(filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                        // Save fetched Zulu versions to file
                        _ = writeToFile(text: text, filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                    } else {
                        // Fetched Zulu versions have been empty, so load existing file
                        zuluVersions = getZuluVersionsFromFile()
                    }
                } else {
                    debugPrint("Offline, will keep existing file")
                    zuluVersions = getZuluVersionsFromFile()
                }
            } else {
                debugPrint("File still ok -> load from existing file: \(Constants.ZULU_VERSION_LOOKUP_FILE)")
                zuluVersions = getZuluVersionsFromFile()
            }
        } else {
            if isConnected {
                debugPrint("File not found: \(Constants.ZULU_VERSION_LOOKUP_FILE) -> load new zulu versions from cdn")
                zuluVersions = await getZuluVersionsFromCDN()
                var text : String = ""
                for entry in zuluVersions {
                    text += "\(entry.key.toString(outputFormat: .full_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)),\(entry.value.toString(outputFormat: .full_compressed, javaFormat: true, includeReleaseStatusAndBuild: false))\n"
                }
                
                if !zuluVersions.isEmpty {
                    // Delete old file only if fetched Zulu versions are not empty
                    deleteFile(filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                    // Save fetched Zulu versions to file
                    _ = writeToFile(text: text, filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                }
            } else {
                debugPrint("Offline, will update next time")
            }
        }
        return zuluVersions
    }
    
    static func getZuluVersionsFromCDN() async -> [VersionNumber:VersionNumber] {
        var zuluVersions: [VersionNumber:VersionNumber] = [:]
        
        // Get html
        let html : String = await RestController.fetchTextFromUrl(url: "\(Constants.ZULU_CDN_URL)", encoding: .utf8)
        
        // Get hrefs from html
        var hrefsFound : Set<String> = []
        for match in html.matches(of: Constants.HREF_FILE_PATTERN) {
            hrefsFound.insert(String(match.output.1))
        }
        
        // Get filenames
        for href in hrefsFound {
            let filename : String = Helper.getFileNameFromText(text: href)
            if filename.contains("noarch") { continue }
            
            let reducedToVersionFilename       : String        = filename.starts(with: "zulu1.") ? filename.replacingOccurrences(of: Constants.ZULU_PREFIX_DISTRO_VERSION_REGEX, with: "", options: .regularExpression) : filename.replacingOccurrences(of: Constants.ZULU_PREFIX_VERSION_REGEX, with: "", options: .regularExpression)
            let version                        : VersionNumber = VersionNumber.fromText(text: reducedToVersionFilename)
            
            let reducedToDistroVersionFilename : String        = filename.starts(with: "zulu1.") ? filename.replacingOccurrences(of: Constants.ZULU_PREFIX_VERSION_REGEX, with: "", options: .regularExpression) : filename.replacingOccurrences(of: Constants.ZULU_PREFIX_DISTRO_VERSION_REGEX, with: "", options: .regularExpression)
            let distroVersion                  : VersionNumber = VersionNumber.fromText(text: reducedToDistroVersionFilename)
            
            if !distroVersion.equals(other: version) {
                zuluVersions[distroVersion] = version
            }
        }
        return zuluVersions
    }
    
    static func getZuluVersionsFromFile() -> [VersionNumber:VersionNumber] {
        var zuluVersions : [VersionNumber:VersionNumber] = [:]
        let zuluVersionsText : String = readFromFile(filename: Constants.ZULU_VERSION_LOOKUP_FILE)
        zuluVersionsText.enumerateLines { (line, _) in
            let parts : [Substring] = line.split(separator: ",")
            if parts.count == 2 {
                let zuluVersion : VersionNumber = VersionNumber.fromText(text: String(parts[0]))
                let jdkVersion  : VersionNumber = VersionNumber.fromText(text: String(parts[1]))
                zuluVersions[zuluVersion] = jdkVersion
            }
        }
        return zuluVersions
    }
    
    
    static func getZuluVersionsAsStrings(isConnected: Bool) async -> [String:String] {
        // Load from file if present and not outdated, otherwise load again and save/update file
        var zuluVersions : [String:String] = [:]
        if Helper.fileExists(path: Constants.ZULU_VERSION_LOOKUP_FILE) {
            debugPrint("File found: \(Constants.ZULU_VERSION_LOOKUP_FILE)")
            let lastModified : Date? = Helper.getFileDateAttributes(at: Constants.ZULU_VERSION_LOOKUP_FILE).1
            if nil != lastModified && Calendar.current.date(byAdding: .day, value: 30, to: lastModified!)! < Date.init() {
                if isConnected {
                    debugPrint("File outdated -> load zulu versions from cdn")
                    zuluVersions = await getZuluVersionsAsStringFromCDN()
                    var text : String = ""
                    for entry in zuluVersions {
                        text += "\(entry.key),\(entry.value)\n"
                    }
                    
                    if !zuluVersions.isEmpty {
                        // Delete old file only if fetched Zulu versions are not empty
                        deleteFile(filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                        // Save fetched Zulu versions to file
                        _ = writeToFile(text: text, filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                    } else {
                        // Fetched Zulu versions have been empty, so load existing file
                        zuluVersions = getZuluVersionsAsStringFromFile()
                    }
                } else {
                    debugPrint("Offline, will keep existing file")
                    zuluVersions = getZuluVersionsAsStringFromFile()
                }
            } else {
                debugPrint("File still ok -> load from existing file: \(Constants.ZULU_VERSION_LOOKUP_FILE)")
                zuluVersions = getZuluVersionsAsStringFromFile()
            }
        } else {
            if isConnected {
                debugPrint("File not found: \(Constants.ZULU_VERSION_LOOKUP_FILE) -> load new zulu versions from cdn")
                zuluVersions = await getZuluVersionsAsStringFromCDN()
                var text : String = ""
                for entry in zuluVersions {
                    text += "\(entry.key),\(entry.value)\n"
                }
                
                if !zuluVersions.isEmpty {
                    // Delete old file only if fetched Zulu versions are not empty
                    deleteFile(filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                    // Save fetched Zulu versions to file
                    _ = writeToFile(text: text, filename: Constants.ZULU_VERSION_LOOKUP_FILE)
                }
            } else {
                debugPrint("Offline, will update next time")
            }
        }
        return zuluVersions
    }
    
    static func getZuluVersionsAsStringFromCDN() async -> [String:String] {
        var zuluVersions: [String:String] = [:]
        
        // Get html
        let html : String = await RestController.fetchTextFromUrl(url: "\(Constants.ZULU_CDN_URL)", encoding: .utf8)
        
        // Get hrefs from html
        var hrefsFound : Set<String> = []
        for match in html.matches(of: Constants.HREF_FILE_PATTERN) {
            hrefsFound.insert(String(match.output.1))
        }
        
        // Get filenames
        for href in hrefsFound {
            let filename : String = Helper.getFileNameFromText(text: href)
            if filename.contains("noarch") { continue }
            
            let reducedToVersionFilename       : String        = filename.starts(with: "zulu1.") ? filename.replacingOccurrences(of: Constants.ZULU_PREFIX_DISTRO_VERSION_REGEX, with: "", options: .regularExpression) : filename.replacingOccurrences(of: Constants.ZULU_PREFIX_VERSION_REGEX, with: "", options: .regularExpression)
            let version                        : VersionNumber = VersionNumber.fromText(text: reducedToVersionFilename)
            
            let reducedToDistroVersionFilename : String        = filename.starts(with: "zulu1.") ? filename.replacingOccurrences(of: Constants.ZULU_PREFIX_VERSION_REGEX, with: "", options: .regularExpression) : filename.replacingOccurrences(of: Constants.ZULU_PREFIX_DISTRO_VERSION_REGEX, with: "", options: .regularExpression)
            let distroVersion                  : VersionNumber = VersionNumber.fromText(text: reducedToDistroVersionFilename)
            
            if !distroVersion.equals(other: version) {
                zuluVersions[distroVersion.toString(outputFormat: .full_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)] = version.toString(outputFormat: .full_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)
            }
        }
        return zuluVersions
    }
    
    static func getZuluVersionsAsStringFromFile() -> [String:String] {
        var zuluVersions : [String:String] = [:]
        let zuluVersionsText : String = readFromFile(filename: Constants.ZULU_VERSION_LOOKUP_FILE)
        zuluVersionsText.enumerateLines { (line, _) in
            let parts : [Substring] = line.split(separator: ",")
            if parts.count == 2 {
                let zuluVersion : String = String(parts[0])
                let jdkVersion  : String = String(parts[1])
                zuluVersions[zuluVersion] = jdkVersion
            }
        }
        return zuluVersions
    }
    
    
    public static func getFileNameFromText(text : String) -> String {
        let archiveTypeFound : Constants.ArchiveType = getFileEnding(filename: text)
        if Constants.ArchiveType.not_found == archiveTypeFound { return "" }
        let lastSlash : Int    = text.lastIndexOf(with: "/") + 1
        let filename  : String = text.substring(from: lastSlash)
        return filename
    }
    
    public static func getFileEnding(filename : String) -> Constants.ArchiveType {
        if filename.isEmpty { return Constants.ArchiveType.not_found }
        var archiveTypeFound : Constants.ArchiveType = Constants.ArchiveType.not_found
        for archiveType in Constants.ArchiveType.allCases {
            if filename.contains(archiveType.fileEnding) {
                archiveTypeFound = archiveType
                break
            }
        }
        return archiveTypeFound
    }
    
    
    public static func updateReleaeAndEOLDateForJVM(jvm: JVM) async -> Void {
        if jvm.distro.buildScope == .build_of_openjdk {
            do {
                let version     : String       = jvm.versionNumber.toString(outputFormat: .reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)
                let javaRelease : JavaRelease? = try await RestController.fetchJavaReleaseInfo(version: version)
                if javaRelease != nil {
                    let releaseDateString : String = javaRelease!.releaseDate                      ?? ""
                    let eolDateString     : String = javaRelease!.jdkDetails?.endOfSupportLifeDate ?? ""
                    
                    let releaseDate       : Date?  = Helper.dateFromISOString(releaseDateString)
                    let eolDate           : Date?  = Helper.dateFromISOString(eolDateString)
                    
                    if releaseDate != nil {
                        jvm.releaseDate = releaseDate!
                        //debugdebugPrint("\(jvm.distro.apiString) \(version) -> release date \(Constants.DATE_FORMATTER.string(from: releaseDate!))")
                    }
                    if eolDate != nil {
                        jvm.endOfLifeDate = eolDate!
                        //debugdebugPrint("\(jvm.distro.apiString) \(version) -> eol date \(Constants.DATE_FORMATTER.string(from: eolDate!))")
                    }
                }
            } catch {
                debugPrint("Error fetching JavaRelease for \(jvm.versionNumber.toString(outputFormat: .reduced_compressed, javaFormat: true, includeReleaseStatusAndBuild: false)): \(error)")
            }
        }
    }
    
    
    public static func dateFromISOString(_ isoString: String) -> Date? {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withFullDate]
        return isoDateFormatter.date(from: isoString)
    }
    
        
    public static func getSysinfo() -> String {
        let shell   : CmdExec = Shell()
        var sysinfo : String?
        if let output : String = try? shell.run(cmd: "/usr/sbin/system_profiler", args: [ "SPHardwareDataType" ]) {
            sysinfo = output.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var modelName     : String = ""
            var chip          : String = ""
            var numberOfCores : String = ""
            var memory        : String = ""
            
            if let res1 = try? Constants.MODEL_NAME_PATTERN.firstMatch(in: sysinfo ?? "")      { modelName     = "\(res1.1)" }
            if let res1 = try? Constants.CHIP_PATTERN.firstMatch(in: sysinfo ?? "")            { chip          = "\(res1.1)" }
            if let res1 = try? Constants.NUMBER_OF_CORES_PATTERN.firstMatch(in: sysinfo ?? "") { numberOfCores = "\(res1.1)" }
            if let res1 = try? Constants.MEMORY_PATTERN.firstMatch(in: sysinfo ?? "")          { memory        = "\(res1.1)" }
            
            return "\(modelName)\n\(chip)\nCores \(numberOfCores)\n\(memory) RAM"
        }
        return ""
    }
    
    static func loadAdvisories() async -> [Advisory] {
        let jsonText : String = readFromFile(filename: Constants.ADVISORIES_FILE)
        if jsonText.isEmpty { return [] }
        let jsonDecoder : JSONDecoder = JSONDecoder()
        do {
            return try jsonDecoder.decode([Advisory].self, from: jsonText.data(using: .utf8)!)
        } catch {
            debugPrint("Error decoding json data from advisories file")
            return []
        }
    }
    static func storeAdvisories(advisories: [Advisory]) async -> Void {
        let jsonEncoder : JSONEncoder = JSONEncoder()
        do {
            let jsonData : Data = try jsonEncoder.encode(advisories)
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonText = String(data: jsonData, encoding: .utf8)
            if jsonText != nil {
                _ = writeToFile(text: jsonText!, filename: Constants.ADVISORIES_FILE)
            } else {
                debugPrint("Error creating json string")
            }
        } catch {
            debugPrint("Error encoding advisories to json")
        }
    }
    
    static func getAdvisoriesPerVersion(version: VersionNumber, advisories: [Advisory]) -> Set<Advisory> {
        var advisoriesFound : Set<Advisory> = []
        for advisory in advisories {
            if nil != advisory.versions {
                if advisory.versions!.contains(where: { VersionNumber.equalsExceptBuild(v1: $0.version!, v2: version)}) {
                    advisoriesFound.insert(advisory)
                }
            }
        }
        return advisoriesFound
    }
    
    static func getResolvedCVEsPerVersion(version: VersionNumber, advisories: [Advisory]) -> [AdvisoryCve] {
        var cvesFound : Set<AdvisoryCve> = []
        for advisory in advisories {
            if nil != advisory.versions {
                for ver in advisory.versions!.filter({ $0.version?.feature! == version.feature }).filter({ $0.version! <= version }) {
                    for cve in ver.cves! {
                        cvesFound.insert(cve)
                    }
                }
            }
        }
        return Array(cvesFound.sorted(by: { $0.cvssScore! > $1.cvssScore! }))
    }
    
    static func getUnresolvedCVEsPerVersion(version: VersionNumber, advisories: [Advisory]) -> [AdvisoryCve] {
        var cvesFound : Set<AdvisoryCve> = []
        for advisory in advisories {
            if nil != advisory.versions {
                for ver in advisory.versions!.filter({ $0.version?.feature! == version.feature }).filter({ $0.version! > version }) {
                    for cve in ver.cves! {
                        cvesFound.insert(cve)
                    }
                }                
            }
        }
        return Array(cvesFound.sorted(by: { $0.cvssScore! > $1.cvssScore! }))
    }
    
    static func getAffectedVersionsforCVE(adivsoryCve: AdvisoryCve, advisories: [Advisory]) -> [VersionNumber] {
        var versionsFound : Set<VersionNumber> = []
        for advisory in advisories {
            if advisory.versions != nil {
                for version in advisory.versions! {
                    if version.cves != nil {
                        for cve in version.cves! {
                            if cve.cveId == adivsoryCve.cveId {
                                versionsFound.insert(version.version!)
                            }
                        }
                    }
                }
            }            
        }
        return Array(versionsFound).sorted(by: { $0 < $1 })
    }
    
    
    static func fetchUpcomingReleaseDates() async -> [Date:[VersionNumber]] {
        let text : String = await RestController.fetchTextFromUrl(url: Constants.JAVA_RELEASE_DATES_URL, encoding: .utf8)
        let formatter : DateFormatter = DateFormatter()
        formatter.locale     = .current
        formatter.timeZone   = .current
        formatter.dateFormat = "yyyy-MM-dd"
        
        var releaseDates : [Date:[VersionNumber]] = [:]
        
        // Feature releases
        for result in text.matches(of: Constants.JAVA_FEATURE_RELEASE_DATE_PATTERN) {
            let releaseDateTxt    : String = String(result.2).htmlDecoded
            let releaseVersionTxt : String = String(result.1).htmlDecoded
            guard let releaseDate : Date = formatter.date(from: releaseDateTxt) else {
                continue
            }
            let featureVersion : Int = Int(releaseVersionTxt) ?? 0
            if featureVersion == 0 { continue; }
            var versionNumbers : [VersionNumber] = []
            versionNumbers.append(VersionNumber(feature: featureVersion))
            releaseDates[releaseDate] = versionNumbers
        }
        
        // CPU Releases
        for res1 in text.matches(of: Constants.JAVA_CPU_RELEASE_DATE_PATTERN) {
            let releaseDateTxt : String = String(res1.2).htmlDecoded
            guard let releaseDate : Date = formatter.date(from: releaseDateTxt) else {
                continue
            }
            var versionNumbers : [VersionNumber] = []
            for res2 in res1.5.matches(of: Constants.JAVA_VERSION_NO_PATTERN) {
                let versionNumber : VersionNumber = VersionNumber.fromText(text: String(res2.1).htmlDecoded)
                versionNumbers.append(versionNumber)
            }
            for res3 in res1.5.matches(of: Constants.JAVA_OLD_VERSION_NO_PATTERN) {
                let versionNumber : VersionNumber = VersionNumber.fromText(text: String(res3.1).htmlDecoded)
                versionNumbers.append(versionNumber)
            }
            releaseDates[releaseDate] = versionNumbers
        }
        return releaseDates
    }
    
    static func fetchUpcomingFeatureReleaseDates() async -> [Date:VersionNumber] {
        let text : String = await RestController.fetchTextFromUrl(url: Constants.JAVA_RELEASE_DATES_URL, encoding: .utf8)
        let formatter : DateFormatter = DateFormatter()
        formatter.locale     = .current
        formatter.timeZone   = .current
        formatter.dateFormat = "yyyy-MM-dd"
        
        var releaseDates : [Date:VersionNumber] = [:]
        for result in text.matches(of: Constants.JAVA_FEATURE_RELEASE_DATE_PATTERN) {
            let releaseDateTxt    : String = String(result.2).htmlDecoded
            let releaseVersionTxt : String = String(result.1).htmlDecoded
            guard let releaseDate  : Date = formatter.date(from: releaseDateTxt) else {
                continue
            }
            let featureVersion : Int = Int(releaseVersionTxt) ?? 0
            if featureVersion == 0 { continue; }
            releaseDates[releaseDate] = VersionNumber(feature: featureVersion)
        }
        return releaseDates
    }
    
    static func fetchUpcomingCPUReleaseDates() async -> [Date:[VersionNumber]] {
        let text : String = await RestController.fetchTextFromUrl(url: Constants.JAVA_RELEASE_DATES_URL, encoding: .utf8)
        let formatter : DateFormatter = DateFormatter()
        formatter.locale     = .current
        formatter.timeZone   = .current
        formatter.dateFormat = "yyyy-MM-dd"
        
        var releaseDates : [Date:[VersionNumber]] = [:]
        for res1 in text.matches(of: Constants.JAVA_CPU_RELEASE_DATE_PATTERN) {
            let releaseDateTxt : String = String(res1.2).htmlDecoded
            guard let releaseDate : Date = formatter.date(from: releaseDateTxt) else {
                continue
            }
            var versionNumbers : [VersionNumber] = []
            for res2 in res1.5.matches(of: Constants.JAVA_VERSION_NO_PATTERN) {
                let versionNumber : VersionNumber = VersionNumber.fromText(text: String(res2.1).htmlDecoded)
                versionNumbers.append(versionNumber)
            }
            for res3 in res1.5.matches(of: Constants.JAVA_OLD_VERSION_NO_PATTERN) {
                let versionNumber : VersionNumber = VersionNumber.fromText(text: String(res3.1).htmlDecoded)
                versionNumbers.append(versionNumber)
            }
            releaseDates[releaseDate] = versionNumbers
        }
        return releaseDates
    }
    
    public static func restartApp() {
        let bundlePath = Bundle.main.bundlePath

        let command = """
        sleep 0.1; open "\(bundlePath)"
        """

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", command]

        do {
            try task.run()
        } catch {
            print("Error restarting app:", error)
        }

        exit(0)
    }
}
