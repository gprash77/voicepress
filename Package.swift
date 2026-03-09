// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "VoicePress",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "VoicePress", targets: ["VoicePress"]),
        .executable(name: "VoicePressCoreChecks", targets: ["VoicePressCoreChecks"]),
        .executable(name: "VoicePressCLI", targets: ["VoicePressCLI"]),
        .executable(name: "VoicePressEval", targets: ["VoicePressEval"]),
        .library(name: "VoicePressCore", targets: ["VoicePressCore"]),
    ],
    targets: [
        .target(
            name: "VoicePressCore"
        ),
        .executableTarget(
            name: "VoicePress",
            dependencies: ["VoicePressCore"],
            exclude: [
                "Resources/Info.plist",
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/VoicePress/Resources/Info.plist",
                ]),
            ]
        ),
        .executableTarget(
            name: "VoicePressCoreChecks",
            dependencies: ["VoicePressCore"]
        ),
        .executableTarget(
            name: "VoicePressCLI",
            dependencies: ["VoicePressCore"]
        ),
        .executableTarget(
            name: "VoicePressEval",
            dependencies: ["VoicePressCore"]
        ),
    ]
)
