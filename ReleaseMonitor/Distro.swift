//
//  Distro.swift
//  JavaUpdater
//
//  Created by Gerrit Grunwald on 06.02.24.
//

import Foundation


public enum Distro : String, Equatable, CaseIterable, Sendable, Codable {
    case aoj
    case aoj_openj9
    case bisheng
    case corretto
    case debian
    case dragonwell
    case gluon_graalvm
    case graalvm_ce8
    case graalvm_ce11
    case graalvm_ce16
    case graalvm_ce17
    case graalvm_ce19
    case graalvm_ce20
    case graalvm_community
    case graalvm
    case homebrew
    case jetbrains
    case kona
    case liberica
    case liberica_nik
    case mandrel
    case microsoft
    case ojdk_build
    case open_logic
    case oracle_openjdk
    case oracle
    case red_hat
    case sap_machine
    case semeru
    case semeru_certified
    case temurin
    case trava
    case zulu
    case prime
    case none
    case not_found
    
    
    var uiString: String {
        switch self {
            case .aoj               : return "AOJ"
            case .aoj_openj9        : return "AOJ OpenJ9"
            case .bisheng           : return "Bi Sheng"
            case .corretto          : return "Corretto"
            case .debian            : return "Debian"
            case .dragonwell        : return "Dragonwell"
            case .gluon_graalvm     : return "Gluon GraalVM"
            case .graalvm_ce8       : return "GraalVM CE 8"
            case .graalvm_ce11      : return "GraalVM CE 11"
            case .graalvm_ce16      : return "GraalVM CE 16"
            case .graalvm_ce17      : return "GraalVM CE 17"
            case .graalvm_ce19      : return "GraalVM CE 19"
            case .graalvm_ce20      : return "GraalVM CE 20"
            case .graalvm_community : return "GraalVM Community"
            case .graalvm           : return "GraalVM"
            case .homebrew          : return "Homebrew"
            case .jetbrains         : return "JetBrains"
            case .kona              : return "Kona"
            case .liberica          : return "Liberica"
            case .liberica_nik      : return "Liberica NIK"
            case .mandrel           : return "Mandrel"
            case .microsoft         : return "Microsoft"
            case .ojdk_build        : return "OJDK Build"
            case .open_logic        : return "OpenLogic"
            case .oracle_openjdk    : return "Oracle OpenJDK"
            case .oracle            : return "Oracle"
            case .red_hat           : return "Red Hat"
            case .sap_machine       : return "SAP Machine"
            case .semeru            : return "Semeru"
            case .semeru_certified  : return "Semeru certified"
            case .temurin           : return "Temurin"
            case .trava             : return "Trava"
            case .zulu              : return "Zulu"
            case .prime             : return "Zing"
            case .none              : return "-"
            case .not_found         : return ""
        }
    }
    
    var apiString: String {
        switch self {
            case .aoj               : return "aoj"
            case .aoj_openj9        : return "aoj_openj9"
            case .bisheng           : return "bisheng"
            case .corretto          : return "corretto"
            case .debian            : return "debian"
            case .dragonwell        : return "dragonwell"
            case .gluon_graalvm     : return "gluon_graalvm"
            case .graalvm_ce8       : return "graalvm_ce8"
            case .graalvm_ce11      : return "graalvm_ce11"
            case .graalvm_ce16      : return "graalvm_ce16"
            case .graalvm_ce17      : return "graalvm_ce17"
            case .graalvm_ce19      : return "graalvm_ce19"
            case .graalvm_ce20      : return "graalvm_ce20"
            case .graalvm_community : return "graalvm_community"
            case .graalvm           : return "graalvm"
            case .homebrew          : return "homebrew"
            case .jetbrains         : return "jetbrains"
            case .kona              : return "kona"
            case .liberica          : return "liberica"
            case .liberica_nik      : return "liberica_native"
            case .mandrel           : return "mandrel"
            case .microsoft         : return "microsoft"
            case .ojdk_build        : return "ojdk_build"
            case .open_logic        : return "openlogic"
            case .oracle_openjdk    : return "oracle_open_jdk"
            case .oracle            : return "oracle"
            case .red_hat           : return "redhat"
            case .sap_machine       : return "sap_machine"
            case .semeru            : return "semeru"
            case .semeru_certified  : return "semeru_certified"
            case .temurin           : return "temurin"
            case .trava             : return "trava"
            case .zulu              : return "zulu"
            case .prime             : return "zulu_prime"
            case .none              : return "-"
            case .not_found         : return ""
        }
    }
    
    var vendor: Constants.Vendor {
        switch self {
            case .aoj               : return Constants.Vendor.adopt_openjdk
            case .aoj_openj9        : return Constants.Vendor.adopt_openjdk
            case .bisheng           : return Constants.Vendor.huawei
            case .corretto          : return Constants.Vendor.amazon
            case .debian            : return Constants.Vendor.debian
            case .dragonwell        : return Constants.Vendor.alibaba
            case .gluon_graalvm     : return Constants.Vendor.gluon
            case .graalvm_ce8       : return Constants.Vendor.oracle
            case .graalvm_ce11      : return Constants.Vendor.oracle
            case .graalvm_ce16      : return Constants.Vendor.oracle
            case .graalvm_ce17      : return Constants.Vendor.oracle
            case .graalvm_ce19      : return Constants.Vendor.oracle
            case .graalvm_ce20      : return Constants.Vendor.oracle
            case .graalvm_community : return Constants.Vendor.oracle
            case .graalvm           : return Constants.Vendor.oracle
            case .homebrew          : return Constants.Vendor.homebrew
            case .jetbrains         : return Constants.Vendor.jetbrains
            case .kona              : return Constants.Vendor.tencent
            case .liberica          : return Constants.Vendor.bell_soft
            case .liberica_nik      : return Constants.Vendor.bell_soft
            case .mandrel           : return Constants.Vendor.redhat
            case .microsoft         : return Constants.Vendor.microsoft
            case .ojdk_build        : return Constants.Vendor.community
            case .open_logic        : return Constants.Vendor.openlogic
            case .oracle_openjdk    : return Constants.Vendor.oracle
            case .oracle            : return Constants.Vendor.oracle
            case .red_hat           : return Constants.Vendor.redhat
            case .sap_machine       : return Constants.Vendor.sap
            case .semeru            : return Constants.Vendor.ibm
            case .semeru_certified  : return Constants.Vendor.ibm
            case .temurin           : return Constants.Vendor.eclipse_foundation
            case .trava             : return Constants.Vendor.community
            case .zulu              : return Constants.Vendor.azul
            case .prime             : return Constants.Vendor.azul
            case .none              : return Constants.Vendor.none
            case .not_found         : return Constants.Vendor.not_found
        }
    }
    
    var sdkmanShortForm: String {
        switch self {
            case .aoj               : return ""
            case .aoj_openj9        : return ""
            case .bisheng           : return "bsg"
            case .corretto          : return "amzn"
            case .debian            : return ""
            case .dragonwell        : return "albba"
            case .gluon_graalvm     : return ""
            case .graalvm_ce8       : return ""
            case .graalvm_ce11      : return ""
            case .graalvm_ce16      : return ""
            case .graalvm_ce17      : return ""
            case .graalvm_ce19      : return ""
            case .graalvm_ce20      : return ""
            case .graalvm_community : return "graalce"
            case .graalvm           : return "graal"
            case .homebrew          : return ""
            case .jetbrains         : return ""
            case .kona              : return "kona"
            case .liberica          : return "librca"
            case .liberica_nik      : return "nik"
            case .mandrel           : return "mandrel"
            case .microsoft         : return "ms"
            case .ojdk_build        : return ""
            case .open_logic        : return ""
            case .oracle_openjdk    : return "open"
            case .oracle            : return "oracle"
            case .red_hat           : return "Red Hat"
            case .sap_machine       : return "sapmchn"
            case .semeru            : return "sem"
            case .semeru_certified  : return ""
            case .temurin           : return "tem"
            case .trava             : return "trava"
            case .zulu              : return "zulu"
            case .prime             : return ""
            case .none              : return ""
            case .not_found         : return ""
        }
    }
    
    var maintained: Bool {
        switch self {
            case .aoj               : return false
            case .aoj_openj9        : return false
            case .bisheng           : return true
            case .corretto          : return true
            case .debian            : return true
            case .dragonwell        : return true
            case .gluon_graalvm     : return true
            case .graalvm_ce8       : return false
            case .graalvm_ce11      : return false
            case .graalvm_ce16      : return false
            case .graalvm_ce17      : return false
            case .graalvm_ce19      : return false
            case .graalvm_ce20      : return false
            case .graalvm_community : return true
            case .graalvm           : return true
            case .homebrew          : return true
            case .jetbrains         : return true
            case .kona              : return true
            case .liberica          : return true
            case .liberica_nik      : return true
            case .mandrel           : return true
            case .microsoft         : return true
            case .ojdk_build        : return false
            case .open_logic        : return true
            case .oracle_openjdk    : return true
            case .oracle            : return true
            case .red_hat           : return true
            case .sap_machine       : return true
            case .semeru            : return true
            case .semeru_certified  : return true
            case .temurin           : return true
            case .trava             : return false
            case .zulu              : return true
            case .prime             : return true
            case .none              : return false
            case .not_found         : return false
        }
    }
    
    var available: Bool {
        switch self {
            case .aoj               : return true
            case .aoj_openj9        : return true
            case .bisheng           : return true
            case .corretto          : return true
            case .debian            : return false
            case .dragonwell        : return true
            case .gluon_graalvm     : return true
            case .graalvm_ce8       : return true
            case .graalvm_ce11      : return true
            case .graalvm_ce16      : return true
            case .graalvm_ce17      : return true
            case .graalvm_ce19      : return true
            case .graalvm_ce20      : return false
            case .graalvm_community : return true
            case .graalvm           : return true
            case .homebrew          : return true
            case .jetbrains         : return true
            case .kona              : return true
            case .liberica          : return true
            case .liberica_nik      : return true
            case .mandrel           : return true
            case .microsoft         : return true
            case .ojdk_build        : return true
            case .open_logic        : return true
            case .oracle_openjdk    : return true
            case .oracle            : return true
            case .red_hat           : return true
            case .sap_machine       : return true
            case .semeru            : return true
            case .semeru_certified  : return true
            case .temurin           : return true
            case .trava             : return true
            case .zulu              : return true
            case .prime             : return false
            case .none              : return false
            case .not_found         : return false
        }
    }
    
    var supportedOnMac: Bool {
        switch self {
            case .aoj               : return true
            case .aoj_openj9        : return true
            case .bisheng           : return false
            case .corretto          : return true
            case .debian            : return false
            case .dragonwell        : return false
            case .gluon_graalvm     : return true
            case .graalvm_ce8       : return true
            case .graalvm_ce11      : return true
            case .graalvm_ce16      : return true
            case .graalvm_ce17      : return true
            case .graalvm_ce19      : return true
            case .graalvm_ce20      : return true
            case .graalvm_community : return true
            case .graalvm           : return true
            case .homebrew          : return false
            case .jetbrains         : return true
            case .kona              : return true
            case .liberica          : return true
            case .liberica_nik      : return true
            case .mandrel           : return false
            case .microsoft         : return true
            case .ojdk_build        : return false
            case .open_logic        : return true
            case .oracle_openjdk    : return true
            case .oracle            : return true
            case .red_hat           : return false
            case .sap_machine       : return true
            case .semeru            : return true
            case .semeru_certified  : return false
            case .temurin           : return true
            case .trava             : return true
            case .zulu              : return true
            case .prime             : return false
            case .none              : return false
            case .not_found         : return false
        }
    }
    
    var url: String {
        switch self {
            case .aoj               : return "https://adoptopenjdk.org"
            case .aoj_openj9        : return "https://adoptopenjdk.org"
            case .bisheng           : return "https://www.openeuler.org/en/other/projects/bishengjdk/"
            case .corretto          : return "https://aws.amazon.com/corretto"
            case .debian            : return "https://wiki.debian.org/Java"
            case .dragonwell        : return "https://dragonwell-jdk.io/"
            case .gluon_graalvm     : return "https://github.com/gluonhq/graal/releases"
            case .graalvm_ce8       : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm_ce11      : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm_ce16      : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm_ce17      : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm_ce19      : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm_ce20      : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm_community : return "https://github.com/graalvm/graalvm-ce-builds/releases/"
            case .graalvm           : return "https://www.graalvm.org/downloads/"
            case .homebrew          : return "https://formulae.brew.sh/formula/openjdk"
            case .jetbrains         : return "https://github.com/JetBrains/JetBrainsRuntime/releases"
            case .kona              : return "https://tencent.github.io/konajdk/"
            case .liberica          : return "https://bell-sw.com/pages/downloads"
            case .liberica_nik      : return "https://bell-sw.com/pages/downloads/native-image-kit"
            case .mandrel           : return "https://github.com/graalvm/mandrel/releases"
            case .microsoft         : return "https://learn.microsoft.com/de-de/java/openjdk/download"
            case .ojdk_build        : return "https://github.com/ojdkbuild/ojdkbuild/releases"
            case .open_logic        : return "https://www.openlogic.com/openjdk-downloads"
            case .oracle_openjdk    : return "https://jdk.java.net/"
            case .oracle            : return "https://www.oracle.com/java/technologies/downloads/"
            case .red_hat           : return "https://developers.redhat.com/products/openjdk/download"
            case .sap_machine       : return "https://sap.github.io/SapMachine/"
            case .semeru            : return "https://developer.ibm.com/languages/java/semeru-runtimes/downloads/"
            case .semeru_certified  : return "https://developer.ibm.com/languages/java/semeru-runtimes/downloads/"
            case .temurin           : return "https://projects.eclipse.org/projects/adoptium.temurin/downloads"
            case .trava             : return "https://github.com/orgs/TravaOpenJDK/repositories?q=trava-jdk"
            case .zulu              : return "https://www.azul.com/downloads/?package=jdk#zulu"
            case .prime             : return "https://www.azul.com/downloads/#prime"
            case .none              : return "-"
            case .not_found         : return ""
        }
    }
    
    var buildScope: Constants.BuildScope {
        switch self {
            case .aoj               : return Constants.BuildScope.build_of_openjdk
            case .aoj_openj9        : return Constants.BuildScope.build_of_openjdk
            case .bisheng           : return Constants.BuildScope.build_of_openjdk
            case .corretto          : return Constants.BuildScope.build_of_openjdk
            case .debian            : return Constants.BuildScope.build_of_openjdk
            case .dragonwell        : return Constants.BuildScope.build_of_openjdk
            case .gluon_graalvm     : return Constants.BuildScope.build_of_graalvm
            case .graalvm_ce8       : return Constants.BuildScope.build_of_graalvm
            case .graalvm_ce11      : return Constants.BuildScope.build_of_graalvm
            case .graalvm_ce16      : return Constants.BuildScope.build_of_graalvm
            case .graalvm_ce17      : return Constants.BuildScope.build_of_graalvm
            case .graalvm_ce19      : return Constants.BuildScope.build_of_graalvm
            case .graalvm_ce20      : return Constants.BuildScope.build_of_graalvm
            case .graalvm_community : return Constants.BuildScope.build_of_graalvm
            case .graalvm           : return Constants.BuildScope.build_of_graalvm
            case .homebrew          : return Constants.BuildScope.build_of_openjdk
            case .jetbrains         : return Constants.BuildScope.build_of_openjdk
            case .kona              : return Constants.BuildScope.build_of_openjdk
            case .liberica          : return Constants.BuildScope.build_of_openjdk
            case .liberica_nik      : return Constants.BuildScope.build_of_graalvm
            case .mandrel           : return Constants.BuildScope.build_of_graalvm
            case .microsoft         : return Constants.BuildScope.build_of_openjdk
            case .ojdk_build        : return Constants.BuildScope.build_of_openjdk
            case .open_logic        : return Constants.BuildScope.build_of_openjdk
            case .oracle_openjdk    : return Constants.BuildScope.build_of_openjdk
            case .oracle            : return Constants.BuildScope.build_of_openjdk
            case .red_hat           : return Constants.BuildScope.build_of_openjdk
            case .sap_machine       : return Constants.BuildScope.build_of_openjdk
            case .semeru            : return Constants.BuildScope.build_of_openjdk
            case .semeru_certified  : return Constants.BuildScope.build_of_openjdk
            case .temurin           : return Constants.BuildScope.build_of_openjdk
            case .trava             : return Constants.BuildScope.build_of_openjdk
            case .zulu              : return Constants.BuildScope.build_of_openjdk
            case .prime             : return Constants.BuildScope.build_of_openjdk
            case .none              : return Constants.BuildScope.none
            case .not_found         : return Constants.BuildScope.not_found
        }
    }
    
    public static func fromText(text: String) -> Distro {
        switch text {
            case "zulu", "ZULU", "Zulu", "zulucore", "ZULUCORE", "ZuluCore", "zulu_core", "ZULU_CORE", "Zulu_Core", "zulu core", "ZULU CORE", "Zulu Core": return .zulu
            case "zing", "ZING", "Zing", "prime", "PRIME", "Prime", "zuluprime", "ZULUPRIME", "ZuluPrime", "zulu_prime", "ZULU_PRIME", "Zulu_Prime", "zulu prime", "ZULU PRIME", "Zulu Prime": return .prime
            case "aoj", "AOJ", "aoj_openj9", "AOJ_OpenJ9", "AOJ_OPENJ9", "AOJ OpenJ9", "AOJ OPENJ9", "aoj openj9": return .aoj_openj9
            case "corretto", "CORRETTO", "Corretto": return .corretto
            case "dragonwell", "DRAGONWELL", "Dragonwell": return .dragonwell
            case "gluon_graalvm", "GLUON_GRAALVM", "gluongraalvm", "GLUONGRAALVM", "gluon graalvm", "GLUON GRAALVM", "Gluon GraalVM", "Gluon": return .gluon_graalvm
            case "graalvm_ce8", "graalvmce8", "GraalVM CE 8", "GraalVMCE8", "GraalVM_CE8": return .graalvm_ce8
            case "graalvm_ce11", "graalvmce11", "GraalVM CE 11", "GraalVMCE11", "GraalVM_CE11": return .graalvm_ce11
            case "graalvm_ce16", "graalvmce16", "GraalVM CE 16", "GraalVMCE16", "GraalVM_CE16": return .graalvm_ce16
            case "graalvm_ce17", "graalvmce17", "GraalVM CE 17", "GraalVMCE17", "GraalVM_CE17": return .graalvm_ce17
            case "graalvm_ce19", "graalvmce19", "GraalVM CE 19", "GraalVMCE19", "GraalVM_CE19": return .graalvm_ce19
            case "graalvm_ce20", "graalvmce20", "GraalVM CE 20", "GraalVMCE20", "GraalVM_CE20": return .graalvm_ce20
            case "graalvm_community", "graalvmcommunity", "GraalVM Community", "GraalVM_Community", "GraalVMCommunity", "GraalVM-Community", "GRAALVM_COMMUNITY", "GRAALVM-COMMUNITY": return .graalvm_community
            case "graalvm", "GRAALVM", "GraalVM": return .graalvm
            case "homebrew", "HOMEBREW", "Homebrew": return .homebrew
            case "jetbrains", "JetBrains", "JETBRAINS": return .jetbrains
            case "liberica", "LIBERICA", "Liberica": return .liberica
            case "liberica_native", "LIBERICA_NATIVE", "libericaNative", "LibericaNative", "liberica native", "LIBERICA NATIVE", "Liberica Native", "Liberica NIK", "liberica nik", "LIBERICA NIK", "liberica_nik", "LIBERICA_NIK": return .liberica_nik
            case "mandrel", "MANDREL", "Mandrel": return .mandrel
            case "microsoft", "Microsoft", "MICROSOFT", "Microsoft OpenJDK", "Microsoft Build of OpenJDK": return .microsoft
            case "ojdk_build", "OJDK_BUILD", "OJDK Build", "ojdk build", "ojdkbuild", "OJDKBuild": return .ojdk_build
            case "openlogic", "OPENLOGIC", "OpenLogic", "open_logic", "OPEN_LOGIC", "Open Logic", "OPEN LOGIC", "open logic": return .open_logic
            case "oracle", "Oracle", "ORACLE": return .oracle
            case "oracle_open_jdk", "ORACLE_OPEN_JDK", "oracle_openjdk", "ORACLE_OPENJDK", "Oracle_OpenJDK", "Oracle OpenJDK", "oracle openjdk", "ORACLE OPENJDK", "open_jdk", "openjdk", "OpenJDK", "Open JDK", "OPEN_JDK", "open-jdk", "OPEN-JDK", "Oracle-OpenJDK", "oracle-openjdk", "ORACLE-OPENJDK", "oracle-open-jdk", "ORACLE-OPEN-JDK": return .oracle_openjdk
            case "RedHat", "redhat", "REDHAT", "Red Hat", "red hat", "RED HAT", "Red_Hat", "red_hat", "red-hat", "Red-Hat", "RED-HAT": return .red_hat
            case "sap_machine", "sapmachine", "SAPMACHINE", "SAP_MACHINE", "SAPMachine", "SAP Machine", "sap-machine", "SAP-Machine", "SAP-MACHINE": return .sap_machine
            case "semeru", "Semeru", "SEMERU": return .semeru
            case "semeru_certified", "SEMERU_CERTIFIED", "Semeru_Certified", "Semeru_certified", "semeru certified", "SEMERU CERTIFIED", "Semeru Certified", "Semeru certified": return .semeru_certified
            case "temurin", "Temurin", "TEMURIN": return .temurin
            case "trava", "TRAVA", "Trava", "trava_openjdk", "TRAVA_OPENJDK", "trava openjdk", "TRAVA OPENJDK": return .trava
            case "kona", "KONA", "Kona": return .kona
            case "bisheng", "BISHENG", "BiSheng", "bi_sheng", "BI_SHENG", "bi-sheng", "BI-SHENG", "bi sheng", "Bi Sheng", "BI SHENG": return .bisheng
            case "debian", "DEBIAN", "Debian": return .debian
            default: return .not_found
        }
    }
    
    public static func getAvailableDistros() -> [Distro] {
        return Distro.allCases.filter({ $0.available })
    }
    
    public static func getMaintainedDistros() -> [Distro] {
        return Distro.allCases.filter({ $0.maintained })
    }
    
    public static func getAvailableAndMaintainedDistros() -> [Distro] {
        return Distro.allCases.filter({ $0.available && $0.maintained })
    }
    
    public static func getAvailableAndSupportedOnMacDistros() -> [Distro] {
        return Distro.allCases.filter({ $0.available && $0.supportedOnMac })
    }
    
    public static func getDistros() -> [Distro] {
        return Distro.allCases.filter({ $0 != Distro.none &&
                                        $0 != Distro.not_found &&
                                        $0 != Distro.gluon_graalvm &&
                                        $0 != Distro.graalvm_ce8 &&
                                        $0 != Distro.graalvm_ce11 &&
                                        $0 != Distro.graalvm_ce16 &&
                                        $0 != Distro.graalvm_ce17 &&
                                        $0 != Distro.graalvm_ce19 &&
                                        $0 != Distro.graalvm_ce20
                                    })
    }
}
