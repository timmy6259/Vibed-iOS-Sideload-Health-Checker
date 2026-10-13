import Foundation
import Security

enum HealthMetricLevel {
    case pass
    case fail
}

struct HealthStatus {
    let title: String
    let value: String
    let isGood: Bool
    let detail: String
}

enum JITProbe {
    static func check() -> HealthMetric {
        let available = jit_probe_available()

        if available {
            return HealthMetric(
                title: "JIT",
                value: "Passes",
                isGood: true,
                detail: "Writable + executable memory was allowed."
            )
        } else {
            return HealthMetric(
                title: "JIT",
                value: "Unavailable",
                isGood: false,
                detail: "The process could not allocate executable memory."
            )
        }
    }
}

enum SigningInspector {
    static func check() -> HealthMetric {
        guard let selfCode = createSelfCode() else {
            return HealthMetric(
                title: "Signing",
                value: "Likely No",
                isGood: false,
                detail: "Could not read app signing information."
            )
        }

        var info: CFDictionary?
        let status = SecCodeCopySigningInformation(selfCode, [], &info)
        guard status == errSecSuccess, let info = info as NSDictionary? else {
            return HealthMetric(
                title: "Signing",
                value: "Likely No",
                isGood: false,
                detail: "App signing information was unavailable."
            )
        }

        let entitlements = info[kSecCodeInfoEntitlementsDict as String] as? [String: Any] ?? [:]
        let getTaskAllow = entitlements["get-task-allow"] as? Bool ?? false
        let appIdentifier = entitlements["application-identifier"] as? String ?? ""

        let certificateList = info[kSecCodeInfoCertificates as String] as? [Any] ?? []
        let certNames = certificateList.compactMap { value -> String? in
            guard let cert = value as? SecCertificate else { return nil }
            return SecCertificateCopySubjectSummary(cert) as String?
        }

        let developerLike = certNames.contains { name in
            let lower = name.lowercased()
            return lower.contains("iphone developer") || lower.contains("apple development") || lower.contains("developer")
        }

        let signedDeveloper = getTaskAllow || developerLike || appIdentifier.contains("developer")

        if signedDeveloper {
            return HealthMetric(
                title: "Signing",
                value: "Developer Certificate",
                isGood: true,
                detail: "Entitlements and certificate chain suggest a dev-signed app."
            )
        } else {
            return HealthMetric(
                title: "Signing",
                value: "Likely No",
                isGood: false,
                detail: "No developer-style signing info was detected."
            )
        }
    }

    private static func createSelfCode() -> SecCode? {
        var code: SecCode?
        let result = SecCodeCopySelf([], &code)
        return result == errSecSuccess ? code : nil
    }
}

enum JailbreakInspector {
    static func check() -> HealthMetric {
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/stash",
            "/var/jb",
            "/var/jb/usr/bin",
            "/var/jb/usr/lib",
            "/var/jb/bin",
            "/var/jb/private/var/stash"
        ]

        let found = suspiciousPaths.contains { path in
            FileManager.default.fileExists(atPath: path)
        }

        if found {
            return HealthMetric(
                title: "Jailbreak",
                value: "Likely Jailbroken",
                isGood: false,
                detail: "Common jailbreak or rootless paths were detected, including /var/jb/*."
            )
        }

        return HealthMetric(
            title: "Jailbreak",
            value: "Not Jailbroken",
            isGood: true,
            detail: "No common jailbreak paths were detected."
        )
    }
}
