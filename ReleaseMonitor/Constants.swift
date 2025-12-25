//
//  Constants.swift
//  ReleaseMonitor
//
//  Created by Gerrit Grunwald on 21.12.25.
//

import Foundation
import SwiftUI


public struct Constants {
    
    public static let APP_GROUP_ID                : String                 = "group.eu.hansolo.ReleaseMonitor"
    
    public static let SECONDS_PER_DAY             : Double                 = 86_400
    public static let REQUEST_TIMEOUT             : Double                 = 60.0
    public static let RESOURCE_TIMEOUT            : Double                 = 120.0
    
    public static let DISCO_API_BASE_URL          : String                 = "https://api.foojay.io/disco/v3.0/"
    public static let DISCO_UPCOMING_RELEASES_URL : String                 = "\(DISCO_API_BASE_URL)upcoming_releases"
    public static let DISCO_LATEST_VERSION_URL    : String                 = "\(DISCO_API_BASE_URL)distributions/versions/latest?distribution=bisheng,corretto,dragonwell,graalvm,graalvm_community,liberica,liberica_native,microsoft,openlogic,oracle_open_jdk,oracle,sap_machine,semeru,temurin,zulu&include_ea=true"
    public static let MARKETPLACE_LATEST_API_URL  : String                 = "https://marketplace-api.adoptium.net/v1/assets/latestForVendors?vendor="
    public static let DISCO_API_STATE_URL         : String                 = "\(DISCO_API_BASE_URL)state"
    public static let AZUL_BLUE                   : Color                  = Color.init(hex: "#152241")
    public static let AZUL_LIGHTER_BLUE           : Color                  = Color.init(hex: "#3E8FBB")
    public static let AZUL_LIGHT_BLUE             : Color                  = Color.init(hex: "#A9D9EF")
    public static let AZUL_PINK                   : Color                  = Color.init(hex: "#FF2B60")
    public static let DF                          : DateFormatter          = {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.dateStyle  = .short
        formatter.timeZone   = .autoupdatingCurrent
        return formatter
    }()
    public static let DF_ISO                      : DateFormatter          = {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateStyle  = .short
        formatter.timeZone   = .autoupdatingCurrent
        return formatter
    }()
    public static let INITIAL_DATE_TIME           : Date                   = Date.now
    public static let MARKETPLACE_VENDORS         : [String:String]        = ["adoptium"  : "Temurin",
                                                                              "alibaba"   : "Dragonwell",
                                                                              "azul"      : "Zulu",
                                                                              "ibm"       : "Semeru",
                                                                              "microsoft" : "Microsoft",
                                                                              "redhat"    : "RedHat"]
    public static let VENDOR_NAMES                : [String]               = ["Dragonwell", "Microsoft", "RedHat", "Semeru", "Temurin", "Zulu"]
    public static var UPDATES                     : [String:Update]        = ["corretto"          : Update.init(distribution: Distribution(uiString: "Corretto",     apiString: "coretto",           latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "graalvm_community" : Update.init(distribution: Distribution(uiString: "GraalVM CE",   apiString: "graalvm_community", latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "liberica"          : Update.init(distribution: Distribution(uiString: "Liberica",     apiString: "liberica",          latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "liberica_native"   : Update.init(distribution: Distribution(uiString: "Liberica NIK", apiString: "liberica_native",   latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "microsoft"         : Update.init(distribution: Distribution(uiString: "Microsoft",    apiString: "microsoft",         latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "oracle_open_jdk"   : Update.init(distribution: Distribution(uiString: "OpenJDK",      apiString: "oracle_open_jdk",   latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "sap_machine"       : Update.init(distribution: Distribution(uiString: "SAP Machine",  apiString: "sap_machine",       latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "semeru"            : Update.init(distribution: Distribution(uiString: "Semeru",       apiString: "semeru",            latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "temurin"           : Update.init(distribution: Distribution(uiString: "Temurin",      apiString: "temurin",           latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME),
                                                                              "zulu"              : Update.init(distribution: Distribution(uiString: "Zulu",         apiString: "graalvm_community", latestGA: nil, latestEA: nil), lastUpdateLatestGA: INITIAL_DATE_TIME, lastUpdateLatestEA: INITIAL_DATE_TIME)]
    public static let JDK_23_RELEASE_DATE         : Date                   = Date.init(timeIntervalSince1970: 1726531200)
    public static let JDK_24_RELEASE_DATE         : Date                   = Date.init(timeIntervalSince1970: 1742256000)
    
    
    // -------------------- ENUMS --------------------
    
    public enum Vendor: String, Equatable, CaseIterable, Sendable {
        case adopt_openjdk
        case alibaba
        case amazon
        case azul
        case bell_soft
        case community
        case debian
        case eclipse_foundation
        case gluon
        case homebrew
        case huawei
        case ibm
        case jetbrains
        case microsoft
        case oracle
        case openlogic
        case redhat
        case sap
        case tencent
        case none
        case not_found
        
        var uiString: String {
            switch self {
                case .adopt_openjdk      : return "AdoptOpenJDK"
                case .alibaba            : return "Alibaba"
                case .amazon             : return "Amazon"
                case .azul               : return "Azul"
                case .bell_soft          : return "BellSoft"
                case .community          : return "Community"
                case .debian             : return "Debian"
                case .eclipse_foundation : return "Eclipse Foundation"
                case .gluon              : return "Gluon"
                case .homebrew           : return "Homebrew"
                case .huawei             : return "Huawei"
                case .ibm                : return "IBM"
                case .jetbrains          : return "JetBrains"
                case .microsoft          : return "Microsoft"
                case .oracle             : return "Oracle"
                case .openlogic          : return "OpenLogic"
                case .redhat             : return "Red Hat"
                case .sap                : return "SAP"
                case .tencent            : return "Tencent"
                case .none               : return ""
                case .not_found          : return ""
            }
        }
        
        var apiString: String {
            switch self {
                case .adopt_openjdk      : return "adopt_open_jdk"
                case .alibaba            : return "alibaba"
                case .amazon             : return "amazon"
                case .azul               : return "azul"
                case .bell_soft          : return "bell_soft"
                case .community          : return "community"
                case .debian             : return "debian"
                case .eclipse_foundation : return "eclipse_foundation"
                case .gluon              : return "gluon"
                case .homebrew           : return "homebrew"
                case .huawei             : return "huawei"
                case .ibm                : return "ibm"
                case .jetbrains          : return "jetbrains"
                case .microsoft          : return "microsoft"
                case .oracle             : return "oracle"
                case .openlogic          : return "open_logic"
                case .redhat             : return "red_hat"
                case .sap                : return "sap"
                case .tencent            : return "tencent"
                case .none               : return ""
                case .not_found          : return ""
            }
        }
        
        public static func withoutNotFound() -> [Vendor] {
            return [ adopt_openjdk, alibaba, amazon, azul, bell_soft, community, debian, eclipse_foundation, gluon, homebrew, huawei, ibm, jetbrains, microsoft, oracle, openlogic, redhat, sap, tencent ]
        }
        
        public static func fromText(text: String) -> Vendor {
            switch (text) {
            case "adopt_open_jdk", "AdoptOpenJDK", "ADOPT_OPEN_JDK", "adoptopenjdk", "ADOPT_OPENJDK" : return .adopt_openjdk
            case "alibaba", "Alibaba", "ALIBABA"                                                     : return .alibaba
            case "amazon", "Amazon", "AMAZON"                                                        : return .amazon
            case "azul", "Azul", "AZUL"                                                              : return .azul
            case "bell_soft", "BellSoft", "BELL_SOFT", "bellsoft", "BELLSOFT"                        : return .bell_soft
            case "community", "Community", "COMMUNITY"                                               : return .community
            case "debian", "Debian", "DEBIAN"                                                        : return .debian
            case "eclipse_foundation", "EclipseFoundation", "ECLIPSE_FOUNDATION"                     : return .eclipse_foundation
            case "gluon", "Gluon", "GLUON"                                                           : return .gluon
            case "homebrew", "HomeBrew", "HOMEBREW"                                                  : return .homebrew
            case "huawei", "Huawei", "HUAWEI"                                                        : return .huawei
            case "ibm", "IBM"                                                                        : return .ibm
            case "jetbrains", "JetBrains", "JETBRAINS"                                               : return .jetbrains
            case "microsoft", "Microsoft", "MICROSOFT"                                               : return .microsoft
            case "oracle", "Oracle", "ORACLE"                                                        : return .oracle
            case "open_logic", "OpenLogic", "OPEN_LOGIC", "Open Logic"                               : return .openlogic
            case "red_hat", "Red Hat", "RED_HAT", "RedHat"                                           : return .redhat
            case "sap", "SAP"                                                                        : return .sap
            case "tencent", "Tencent", "TENCENT"                                                     : return .tencent
            default                                                                                  : return not_found
            }
        }
    }
    
    public enum UpdateType: String, Equatable, CaseIterable, Sendable {
        case update
        case release
        
        var uiString: String {
            switch self {
            case .update  : return "Update"
            case .release : return "Release"
            }
        }
        
        var apiString: String {
            switch self {
            case .update  : return "update"
            case .release : return "release"
            }
        }
    }
    
    public enum Architecture: String, Equatable, CaseIterable, Sendable, Codable {
        case aarch64
        case x64
        case not_found
        
        var uiString: String {
            switch self {
            case .aarch64   : return "ARM"
            case .x64       : return "X64"
            case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
            case .aarch64   : return "aarch64"
            case .x64       : return "x64"
            case .not_found : return ""
            }
        }
        
        public static func withoutNotFound() -> [Architecture] {
            return [ aarch64, x64 ]
        }
        
        public static func fromText(text: String) -> Architecture {
            switch (text) {
            case "aarch64", "arm64"               : return aarch64
            case "x64", "x86_64", "amd64", "i386" : return x64
            default                               : return not_found
            }
        }
        
        public static func acronyms(architecture: Architecture) -> [String] {
            switch architecture {
            case .aarch64: return [ "aarch64", "AARCH64", "arm64", "ARM64" ]
            case .x64    : return [ "x64", "X64", "x86-64", "X86-64", "x86_64", "X86_64", "x86lx64", "X86LX64" ]
            default      : return []
            }
        }
    }
    
    public enum ReleaseStatus: String, Equatable, CaseIterable, Sendable, Codable {
        case ea
        case ga
        case not_found
        
        var uiString: String {
            switch self {
            case .ea        : return "ea"
            case .ga        : return "ga"
            case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
            case .ea        : return "ea"
            case .ga        : return "ga"
            case .not_found : return ""
            }
        }
        
        public static func withoutNotFound() -> [ReleaseStatus] {
            return [ ea, ga ]
        }
        
        public static func fromText(text: String) -> Constants.ReleaseStatus {
            switch (text) {
            case "-ea", "-EA", "_ea", "_EA", "ea", "EA", "ea_", "EA_": return ea
            case "-ga", "-GA", "_ga", "_GA", "ga", "GA", "ga_", "GA_": return ga
            default                                                  : return not_found
            }
        }
        
    }
    
    public enum TermOfSupport: String, Equatable, CaseIterable, Sendable, Codable {
        case lts
        case mts
        case sts
        case not_found
        
        var uiString: String {
            switch self {
            case .lts       : return "LTS"
            case .mts       : return "MTS"
            case .sts       : return "STS"
            case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
            case .lts       : return "lts"
            case .mts       : return "mts"
            case .sts       : return "sts"
            case .not_found : return ""
            }
        }
        
        public static func withoutNotFound() -> [TermOfSupport] {
            return [ lts, mts, sts ]
        }
        
        public static func fromText(text: String) -> TermOfSupport {
            switch (text) {
            case "lts", "LTS", "Lts", "long_term_stable" , "LongTermStable"  : return lts
            case "mts", "MTS", "Mts", "mid_term_stable"  , "MidTermStable"   : return mts
            case "sts", "STS", "Sts", "short_term_stable", "ShortTermStable" : return sts
            default                                                          : return not_found
            }
        }
    }
    
    public enum PackageType: String, Equatable, CaseIterable, Sendable, Codable {
        case jdk
        case jre
        case not_found
        
        var uiString: String {
            switch self {
                case .jdk       : return "JDK"
                case .jre       : return "JRE"
                case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
                case .jdk       : return "jdk"
                case .jre       : return "jre"
                case .not_found : return ""
            }
        }
        
        var descr: String {
            switch self {
                case .jdk       : return "Java Development Kit"
                case .jre       : return "Java Runtime Environment"
                case .not_found : return ""
            }
        }
        
        public static func withoutNotFound() -> [PackageType] {
            return [ jdk, jre ]
        }
        
        public static func fromText(text: String) -> PackageType {
            switch (text) {
            case "jdk", "JDK" : return jdk
            case "jre", "JRE" : return jre
            default           : return not_found
            }
        }
    }
    
    public enum OperatingSystem: String, Equatable, CaseIterable, Sendable, Codable {
        case linux
        case macos
        case windows
        case not_found
        
        var uiString: String {
            switch self {
            case .linux     : return "Linux"
            case .macos     : return "MacOS"
            case .windows   : return "Windows"
            case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
            case .linux     : return "linux"
            case .macos     : return "macos"
            case .windows   : return "windows"
            case .not_found : return ""
            }
        }
        
        var libCType: [LibCType] {
            switch self {
            case .linux     : return [ LibCType.glibc, LibCType.musl ]
            case .macos     : return [ LibCType.libc ]
            case .windows   : return [ LibCType.c_std_lib ]
            case .not_found : return [ LibCType.not_found ]
            }
        }
        
        public static func withoutNotFound() -> [OperatingSystem] {
            return [ linux, macos, windows ]
        }
        
        public static func fromText(text: String) -> OperatingSystem {
            switch text {
            case "linux", "LINUX", "Linux", "-linux", "-linux-musl", "-linux_musl", "Linux-Musl", "linux-musl", "Linux_Musl", "LINUX_MUSL", "linux_musl", "alpine", "ALPINE", "Alpine", "alpine-linux", "ALPINE-LINUX", "alpine_linux", "Alpine_Linux", "ALPINE_LINUX", "Alpine Linux", "alpine linux", "ALPINE LINUX" : return linux
            case "darwin", "-darwin", "DARWIN", "Darwin", "-macosx", "-MACOSX", "Mac OS", "mac_os", "Mac_OS", "mac-os", "Mac-OS", "mac", "MAC", "Mac", "macos", "MACOS", "MacOS", "osx", "OSX", "macosx", "MACOSX", "Mac OSX", "mac osx", "Mac OS X" : return macos
            case "windows", "WINDOWS", "Windows", "win", "WIN", "Win", "-win"      : return windows
            default                                                                : return not_found
            }
        }
        
        public static func acronyms(operatingSystem: OperatingSystem) -> [String] {
            switch operatingSystem {
                case .linux  : return ["linux", "Linux", "LINUX", "unix", "UNIX", "Unix"]
                case .macos  : return ["darwin", "macosx", "MACOSX", "MacOS", "mac_os", "Mac_OS", "mac-os", "Mac-OS", "mac", "MAC", "macos", "MACOS", "osx", "OSX"]
                case .windows: return ["win", "windows", "Windows", "WINDOWS", "Win", "WIN"]
                default      : return []
            }
        }
    }
    
    public enum LibCType: String, Equatable, CaseIterable, Sendable, Codable {
        case glibc
        case musl
        case libc
        case c_std_lib
        case not_found
        
        var uiString: String {
            switch self {
            case .glibc     : return "glibc"
            case .musl      : return "musl"
            case .libc      : return "libc"
            case .c_std_lib : return "c std. lib"
            case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
            case .glibc     : return "glibc"
            case .musl      : return "musl"
            case .libc      : return "libc"
            case .c_std_lib : return "c_std_lib"
            case .not_found : return ""
            }
        }
        
        var operatingSystem: OperatingSystem {
            switch self {
            case .glibc     : return OperatingSystem.linux
            case .musl      : return OperatingSystem.linux
            case .libc      : return OperatingSystem.macos
            case .c_std_lib : return OperatingSystem.windows
            case .not_found : return OperatingSystem.not_found
            }
        }
        
        public static func withoutNotFound() -> [LibCType] {
            return [ glibc, musl, libc, c_std_lib ]
        }
        
        public static func fromText(text: String) -> LibCType {
            switch text {
            case "glibc", "GLIBC", "GLibC"                                 : return glibc
            case "musl", "MUSL", "Musl", "alpine", "ALPINE", "Alpine"      : return musl
            case "libc", "LIBC", "LibC"                                    : return libc
            case "c_std_lib", "C_STD_LIB", "CStdLib", "CSTDLIB", "cstdlib" : return c_std_lib
            default                                                        : return not_found
            }
        }
    }
    
    public enum ArchiveType: String, Equatable, CaseIterable, Sendable, Codable {
        case deb
        case dmg
        case msi
        case pkg
        case rpm
        case tar_gz
        case zip
        case exe
        case not_found
        
        var uiString: String {
            switch self {
                case .deb       : return "deb"
                case .dmg       : return "dmg"
                case .msi       : return "msi"
                case .pkg       : return "pkg"
                case .rpm       : return "rpm"
                case .tar_gz    : return "tar.gz"
                case .zip       : return "zip"
                case .exe       : return "exe"
                case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
                case .deb       : return "deb"
                case .dmg       : return "dmg"
                case .msi       : return "msi"
                case .pkg       : return "pkg"
                case .rpm       : return "rpm"
                case .tar_gz    : return "tar.gz"
                case .zip       : return "zip"
                case .exe       : return "exe"
                case .not_found : return ""
            }
        }
        
        var fileEnding: String {
            switch self {
                case .deb       : return ".deb"
                case .dmg       : return ".dmg"
                case .msi       : return ".msi"
                case .pkg       : return ".pkg"
                case .rpm       : return ".rpm"
                case .tar_gz    : return ".tar.gz"
                case .zip       : return ".zip"
                case .exe       : return ".exe"
                case .not_found : return ""
            }
        }
        
        public static func withoutNotFound() -> [ArchiveType] {
            return [ deb, dmg, msi, pkg, rpm, tar_gz, zip, exe ]
        }
        
        public static func forOperatingSystem(operatingSystem: OperatingSystem) -> [ArchiveType] {
            switch operatingSystem {
                case .linux  : return [ deb, rpm, tar_gz ]
                case .macos  : return [ dmg, pkg, tar_gz, zip ]
                case .windows: return [ msi, zip, exe ]
                default      : return []
            }
        }
        
        public static func fromText(text: String) -> ArchiveType {
            switch text {
                case "deb", ".deb"       : return deb
                case "dmg", ".dmg"       : return dmg
                case "exe", ".exe"       : return exe
                case "msi", ".msi"       : return msi
                case "pkg", ".pkg"       : return pkg
                case "rpm", ".rpm"       : return rpm
                case "tar.gz", ".tar.gz" : return tar_gz
                case "zip", ".zip"       : return zip
                default                  : return not_found
            }
        }
    }
    
    public enum BuildScope {
        case build_of_openjdk
        case build_of_openj9
        case build_of_graalvm
        case none
        case not_found
        
        
        var uiString: String {
            switch self {
                case .build_of_openjdk: return "Build of OpenJDK"
                case .build_of_openj9 : return "Build of OpenJ9"
                case .build_of_graalvm: return "Build of GraalVM"
                case .none            : return "-"
                case .not_found       : return ""
            }
        }
        
        var apiString: String {
            switch self {
                case .build_of_openjdk: return "build_of_openjdk"
                case .build_of_openj9 : return "build_of_openj9"
                case .build_of_graalvm: return "build_of_graalvm"
                case .none            : return ""
                case .not_found       : return ""
            }
        }
        
        public static func fromText(text: String) -> BuildScope {
            switch text {
                case "openjdk", "open_jdk", "build_of_openjdk", "BuildOfOpenJDK", "buildofopenjdk", "BUILD_OF_OPENJDK": return .build_of_openjdk
                case "openj9", "open_j9", "build_of_openj9", "BuildOfOpenJ9", "buildofopenj9", "BUILD_OF_OPENJ9"      : return .build_of_openj9
                case "graalvm", "graal_vm", "build_of_graalvm", "BuildOfGraalVM", "buildofgraalvm", "BUILD_OF_GRAALVM": return .build_of_graalvm
                default                                                                                               : return .not_found
            }
        }
    }

    public enum Feature {
        case loom
        case panama
        case lanai
        case valhalla
        case kona_fiber
        case crac
        case none
        case not_found
        
        var uiString: String {
            switch self {
                case .loom      : return "Loom"
                case .panama    : return "Panama"
                case .lanai     : return "Lanai"
                case .valhalla  : return "Valhalla"
                case .kona_fiber: return "KonaFiber"
                case .crac      : return "CRaC"
                case .none      : return "-"
                case .not_found : return ""
            }
        }
        
        var apiString: String {
            switch self {
                case .loom      : return "loom"
                case .panama    : return "panama"
                case .lanai     : return "lanai"
                case .valhalla  : return "valhalla"
                case .kona_fiber: return "kona_fiber"
                case .crac      : return "crac"
                case .none      : return ""
                case .not_found : return ""
            }
        }
        
        public static func fromText(text: String) -> Feature {
            switch text {
                case "loom", "LOOM", "Loom"            : return Feature.loom
                case "panama", "PANAMA", "Panama"      : return Feature.panama
                case "lanai", "LANAI", "Lanai"         : return Feature.lanai
                case "valhalla", "VALHALLA", "Valhalla": return Feature.valhalla
                case "kona_fiber", "KONA_FIBER", "Kona Fiber", "KONA FIBER", "Kona_Fiber", "KonaFiber", "konafiber", "KONAFIBER": return Feature.kona_fiber
                case "crac", "CRAC", "CRaC"            :return Feature.crac
                default                                : return .not_found
            }
        }
    }
    
    public enum OutputFormat {
        case full
        case reduced
        case reduced_enriched
        case full_compressed
        case reduced_compressed
        case reduced_enriched_compressed
        case minimized
    }
    
    public enum Comparison: String, Equatable, CaseIterable, Sendable, Codable {
        case less_than
        case less_than_or_equal
        case equal
        case greater_than_or_equal
        case greater_than
        case range_including
        case range_excluding_to
        case range_excluding_from
        case range_excluding
        
        var oprtr: String {
            switch self {
            case .less_than             : return "<"
            case .less_than_or_equal    : return "<="
            case .equal                 : return "="
            case .greater_than_or_equal : return ">="
            case .greater_than          : return ">"
            case .range_including       : return "..."
            case .range_excluding_to    : return "..<"
            case .range_excluding_from  : return ">.."
            case .range_excluding       : return ">.<"
            }
        }
        
        public static func fromText(text: String) -> Comparison {
            switch (text) {
            case "<"   : return less_than
            case "<="  : return less_than_or_equal
            case "="   : return equal
            case ">="  : return greater_than_or_equal
            case ">"   : return greater_than
            case "..." : return range_including
            case "..<" : return range_excluding_to
            case ">.." : return range_excluding_from
            case ">.<" : return range_excluding
            default    : return equal
            }
        }
    }
    
    
    // -------------------- ENUM TYPES FOR JSON DECODING --------------------
    
    public enum ArchiveTypeType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(ArchiveTypeType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toArchiveType() -> Constants.ArchiveType {
            switch self {
                case .string(let string):
                    return Constants.ArchiveType.fromText(text: string)
            }
        }
    }
    
    public enum PackageTypeType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(PackageTypeType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toPackageType() -> Constants.PackageType {
            switch self {
                case .string(let string):
                    return Constants.PackageType.fromText(text: string)
            }
        }
    }
    
    public enum OperatingSystemType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(OperatingSystemType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toOperatingSystem() -> Constants.OperatingSystem {
            switch self {
                case .string(let string):
                    return Constants.OperatingSystem.fromText(text: string)
            }
        }
    }
    
    public enum TermOfSupportType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(TermOfSupportType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toTermOfSupport() -> Constants.TermOfSupport {
            switch self {
                case .string(let string):
                    return Constants.TermOfSupport.fromText(text: string)
                }
            }
        }
    
    public enum ReleaseStatusType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(ReleaseStatusType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toReleaseStatus() -> Constants.ReleaseStatus {
            switch self {
                case .string(let string):
                    return Constants.ReleaseStatus.fromText(text: string)
                }
            }
        }
    
    public enum ArchitectureType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(ArchitectureType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toArchitecture() -> Constants.Architecture {
            switch self {
                case .string(let string):
                    return Constants.Architecture.fromText(text: string)
                }
            }
        }
    
    public enum LibCTypeType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(LibCTypeType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toLibCType() -> Constants.LibCType {
            switch self {
                case .string(let string):
                    return Constants.LibCType.fromText(text: string)
            }
        }
    }
    
    public enum DistroType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(Distro.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toDistro() -> Distro {
            switch self {
                case .string(let string):
                    return Distro.fromText(text: string)
            }
        }
    }
    
    public enum VersionNumberType: Codable {
        case string(String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(VersionNumber.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoding payload not of an expected type"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string): try container.encode(string)
            }
        }
        
        func isString() -> Bool {
            switch self {
            case .string(_): return true
            }
        }
        
        func toVersionNumber() -> VersionNumber {
            switch self {
                case .string(let string):
                    return VersionNumber.fromText(text: string)
            }
        }
    }
}
