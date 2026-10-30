import Foundation
import AppKit
import CoreGraphics
import ApplicationServices
import Darwin

// SpaceWatch
// Captures window frames and macOS Space UUIDs, then restores them after a display reconnect.
// Space moves use dynamically loaded private SkyLight symbols. Frame restoration uses public AX APIs.

struct Rect: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct DisplayFingerprint: Codable, Hashable {
    let uuid: String
    let vendor: UInt32
    let model: UInt32
    let serial: UInt32
    let width: Int
    let height: Int
}

struct SavedWindow: Codable {
    let windowID: UInt32
    let bundleID: String
    let appName: String
    let title: String
    let role: String
    let subrole: String
    let frame: Rect
    let spaceUUID: String?
    let displayUUID: String?
    let ordinal: Int
}

struct Profile: Codable {
    var name: String
    let createdAt: Date
    let displays: [DisplayFingerprint]
    let windows: [SavedWindow]
}

struct LiveWindow {
    let ax: AXUIElement
    let id: UInt32
    let bundleID: String
    let appName: String
    let title: String
    let role: String
    let subrole: String
    let frame: Rect
}

struct SpaceState {
    var windowToSpaceUUID: [UInt32: String] = [:]
    var uuidToManagedID: [String: UInt64] = [:]
    var uuidToDisplayUUID: [String: String] = [:]
}

let fileManager = FileManager.default
let dataDirectory = fileManager.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Application Support/SpaceWatch", isDirectory: true)
let profilesDirectory = dataDirectory.appendingPathComponent("Profiles", isDirectory: true)

try? fileManager.createDirectory(
    at: profilesDirectory,
    withIntermediateDirectories: true,
    attributes: nil
)

func die(_ text: String, code: Int32 = 1) -> Never {
    fputs("spacewatch: \(text)\n", stderr)
    exit(code)
}

func log(_ text: String) {
    print("spacewatch: \(text)")
    fflush(stdout)
}

func profileURL(_ name: String) -> URL {
    let safeName = name.replacingOccurrences(of: "/", with: "_")
    return profilesDirectory
        .appendingPathComponent(safeName)
        .appendingPathExtension("json")
}
func validatedProfileName(_ name: String) -> String {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty,
          trimmed != ".",
          trimmed != "..",
          !trimmed.contains("/"),
          !trimmed.contains(":") else {
        die("invalid profile name '\(name)'")
    }
    return trimmed
}

func stableHash(_ text: String) -> String {
    var hash: UInt64 = 14695981039346656037
    for byte in text.utf8 {
        hash ^= UInt64(byte)
        hash &*= 1099511628211
    }
    return String(format: "%016llx", hash)
}

func automaticProfileName(for displays: [DisplayFingerprint]) -> String {
    let suffix = String(stableHash(displaySignature(displays)).prefix(8))
    return "auto-\(displays.count)d-\(suffix)"
}

func displayUUID(_ displayID: CGDirectDisplayID) -> String {
    guard let uuid = CGDisplayCreateUUIDFromDisplayID(displayID)?.takeRetainedValue() else {
        return "display-\(displayID)"
    }
    return CFUUIDCreateString(nil, uuid) as String
}

func currentDisplays() -> [DisplayFingerprint] {
    var count: UInt32 = 0
    let countResult = CGGetOnlineDisplayList(0, nil, &count)
    guard countResult == .success, count > 0 else {
        return []
    }

    var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(count))
    let listResult = CGGetOnlineDisplayList(count, &displayIDs, &count)
    guard listResult == .success else {
        return []
    }

    return displayIDs.prefix(Int(count)).map { displayID in
        let mode = CGDisplayCopyDisplayMode(displayID)
        let bounds = CGDisplayBounds(displayID)

        return DisplayFingerprint(
            uuid: displayUUID(displayID),
            vendor: CGDisplayVendorNumber(displayID),
            model: CGDisplayModelNumber(displayID),
            serial: CGDisplaySerialNumber(displayID),
            width: mode?.pixelWidth ?? Int(bounds.width),
            height: mode?.pixelHeight ?? Int(bounds.height)
        )
    }
    .sorted { $0.uuid < $1.uuid }
}

func displaySignature(_ displays: [DisplayFingerprint]) -> String {
    displays
        .map { "\($0.vendor):\($0.model):\($0.serial):\($0.width)x\($0.height)" }
        .sorted()
        .joined(separator: "|")
}

func trusted(prompt: Bool) -> Bool {
    let options = [
        kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt
    ] as CFDictionary

    return AXIsProcessTrustedWithOptions(options)
}

@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(
    _ element: AXUIElement,
    _ identifier: UnsafeMutablePointer<CGWindowID>
) -> AXError

func attribute<T>(_ element: AXUIElement, _ key: CFString, as type: T.Type) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, key, &value) == .success else {
        return nil
    }
    return value as? T
}

func stringAttribute(_ element: AXUIElement, _ key: CFString) -> String {
    attribute(element, key, as: String.self) ?? ""
}

func pointAttribute(_ element: AXUIElement, _ key: CFString) -> CGPoint? {
    guard let value = attribute(element, key, as: AXValue.self) else {
        return nil
    }

    var point = CGPoint.zero
    return AXValueGetValue(value, .cgPoint, &point) ? point : nil
}

func sizeAttribute(_ element: AXUIElement, _ key: CFString) -> CGSize? {
    guard let value = attribute(element, key, as: AXValue.self) else {
        return nil
    }

    var size = CGSize.zero
    return AXValueGetValue(value, .cgSize, &size) ? size : nil
}

@discardableResult
func setPoint(_ element: AXUIElement, _ key: CFString, _ point: CGPoint) -> Bool {
    var mutablePoint = point
    guard let value = AXValueCreate(.cgPoint, &mutablePoint) else {
        return false
    }
    return AXUIElementSetAttributeValue(element, key, value) == .success
}

@discardableResult
func setSize(_ element: AXUIElement, _ key: CFString, _ size: CGSize) -> Bool {
    var mutableSize = size
    guard let value = AXValueCreate(.cgSize, &mutableSize) else {
        return false
    }
    return AXUIElementSetAttributeValue(element, key, value) == .success
}

func liveWindows() -> [LiveWindow] {
    var result: [LiveWindow] = []

    for application in NSWorkspace.shared.runningApplications
    where application.activationPolicy == .regular {
        guard let bundleID = application.bundleIdentifier else {
            continue
        }

        let applicationElement = AXUIElementCreateApplication(application.processIdentifier)
        guard let windows = attribute(
            applicationElement,
            kAXWindowsAttribute as CFString,
            as: [AXUIElement].self
        ) else {
            continue
        }

        for window in windows {
            var windowID: CGWindowID = 0

            guard _AXUIElementGetWindow(window, &windowID) == .success,
                  windowID != 0,
                  let position = pointAttribute(window, kAXPositionAttribute as CFString),
                  let size = sizeAttribute(window, kAXSizeAttribute as CFString),
                  size.width > 40,
                  size.height > 30 else {
                continue
            }

            result.append(
                LiveWindow(
                    ax: window,
                    id: windowID,
                    bundleID: bundleID,
                    appName: application.localizedName ?? bundleID,
                    title: stringAttribute(window, kAXTitleAttribute as CFString),
                    role: stringAttribute(window, kAXRoleAttribute as CFString),
                    subrole: stringAttribute(window, kAXSubroleAttribute as CFString),
                    frame: Rect(
                        x: position.x,
                        y: position.y,
                        width: size.width,
                        height: size.height
                    )
                )
            )
        }
    }

    return result
}

func spaceState() -> SpaceState {
    var state = SpaceState()

    guard let domain = UserDefaults.standard.persistentDomain(forName: "com.apple.spaces"),
          let configuration = domain["SpacesDisplayConfiguration"] as? [String: Any] else {
        return state
    }

    if let properties = configuration["Space Properties"] as? [[String: Any]] {
        for property in properties {
            guard let uuid = property["name"] as? String else {
                continue
            }

            if let windows = property["windows"] as? [NSNumber] {
                for window in windows {
                    state.windowToSpaceUUID[window.uint32Value] = uuid
                }
            }
        }
    }

    guard let managementData = configuration["Management Data"] as? [String: Any],
          let monitors = managementData["Monitors"] as? [[String: Any]] else {
        return state
    }

    for monitor in monitors {
        let monitorDisplayIdentifier = monitor["Display Identifier"] as? String ?? ""
        var spaces: [[String: Any]] = []

        if let activeSpaces = monitor["Spaces"] as? [[String: Any]] {
            spaces.append(contentsOf: activeSpaces)
        }

        if let currentSpace = monitor["Current Space"] as? [String: Any] {
            spaces.append(currentSpace)
        }

        if let collapsedSpace = monitor["Collapsed Space"] as? [String: Any] {
            spaces.append(collapsedSpace)
        }

        for space in spaces {
            guard let uuid = space["uuid"] as? String else {
                continue
            }

            if let managedID = space["ManagedSpaceID"] as? NSNumber {
                state.uuidToManagedID[uuid] = managedID.uint64Value
            }

            let displayIdentifier = space["Display Identifier"] as? String
                ?? monitorDisplayIdentifier

            if !displayIdentifier.isEmpty && displayIdentifier != "Main" {
                state.uuidToDisplayUUID[uuid] = displayIdentifier
            }
        }
    }

    return state
}

func captureProfile(_ name: String, promptForTrust: Bool = true) -> Profile {
    let name = validatedProfileName(name)
    guard trusted(prompt: promptForTrust) else {
        die(
            "Accessibility permission is required. Enable SpaceWatch " +
            "in System Settings > Privacy & Security > Accessibility, then try again."
        )
    }
    let windows = liveWindows()
    let spaces = spaceState()
    var ordinals: [String: Int] = [:]
    let savedWindows = windows.map { window -> SavedWindow in
        let key = "\(window.bundleID)|\(window.title)|\(window.role)|\(window.subrole)"
        let ordinal = ordinals[key, default: 0]
        ordinals[key] = ordinal + 1
        let spaceUUID = spaces.windowToSpaceUUID[window.id]
        return SavedWindow(
            windowID: window.id,
            bundleID: window.bundleID,
            appName: window.appName,
            title: window.title,
            role: window.role,
            subrole: window.subrole,
            frame: window.frame,
            spaceUUID: spaceUUID,
            displayUUID: spaceUUID.flatMap { spaces.uuidToDisplayUUID[$0] },
            ordinal: ordinal
        )
    }
    return Profile(
        name: name,
        createdAt: Date(),
        displays: currentDisplays(),
        windows: savedWindows
    )
}

func writeProfile(_ profile: Profile, announce: Bool = true) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    do {
        let data = try encoder.encode(profile)
        try data.write(to: profileURL(profile.name), options: .atomic)
        if announce {
            log("saved profile '\(profile.name)' with \(profile.windows.count) windows")
        }
    } catch {
        die("could not save profile '\(profile.name)': \(error)")
    }
}

func saveProfile(_ name: String) {
    writeProfile(captureProfile(name))
}

func profileStateFingerprint(_ profile: Profile) -> String {
    let windowState = profile.windows.map { window in
        [
            window.bundleID, window.title, window.role, window.subrole,
            String(window.ordinal), window.spaceUUID ?? "", window.displayUUID ?? "",
            String(format: "%.1f,%.1f,%.1f,%.1f", window.frame.x, window.frame.y,
                   window.frame.width, window.frame.height)
        ].joined(separator: "|")
    }.sorted().joined(separator: "||")
    return stableHash(displaySignature(profile.displays) + "###" + windowState)
}

func loadAllProfiles() -> [Profile] {
    let files = (try? fileManager.contentsOfDirectory(
        at: profilesDirectory,
        includingPropertiesForKeys: nil
    )) ?? []
    return files.filter { $0.pathExtension == "json" }.compactMap { url in
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Profile.self, from: data)
        } catch {
            log("ignored unreadable profile '\(url.lastPathComponent)': \(error)")
            return nil
        }
    }
}

func matchingProfile(for displays: [DisplayFingerprint]) -> Profile? {
    let signature = displaySignature(displays)
    return loadAllProfiles()
        .filter { displaySignature($0.displays) == signature }
        .sorted { $0.createdAt > $1.createdAt }
        .first
}

func renameProfile(from oldName: String, to newName: String) {
    let oldName = validatedProfileName(oldName)
    let newName = validatedProfileName(newName)
    let oldURL = profileURL(oldName)
    let newURL = profileURL(newName)
    guard fileManager.fileExists(atPath: oldURL.path) else {
        die("profile '\(oldName)' does not exist")
    }
    guard !fileManager.fileExists(atPath: newURL.path) else {
        die("profile '\(newName)' already exists")
    }
    var profile = loadProfile(oldName)
    profile.name = newName
    writeProfile(profile, announce: false)
    do {
        try fileManager.removeItem(at: oldURL)
        log("renamed profile '\(oldName)' to '\(newName)'")
    } catch {
        try? fileManager.removeItem(at: newURL)
        die("could not remove old profile after rename: \(error)")
    }
}

final class SkyLight {
    typealias MainConnectionFunction = @convention(c) () -> UInt32
    typealias MoveWindowsFunction = @convention(c) (UInt32, CFArray, UInt64) -> CGError

    private let handle: UnsafeMutableRawPointer?
    private let mainConnection: MainConnectionFunction?
    private let moveWindows: MoveWindowsFunction?

    init() {
        handle = dlopen(
            "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight",
            RTLD_LAZY
        )

        if let handle,
           let connectionSymbol = dlsym(handle, "CGSMainConnectionID"),
           let moveSymbol = dlsym(handle, "CGSMoveWindowsToManagedSpace") {
            mainConnection = unsafeBitCast(
                connectionSymbol,
                to: MainConnectionFunction.self
            )
            moveWindows = unsafeBitCast(
                moveSymbol,
                to: MoveWindowsFunction.self
            )
        } else {
            mainConnection = nil
            moveWindows = nil
        }
    }

    deinit {
        if let handle {
            dlclose(handle)
        }
    }

    func moveWindow(_ windowID: UInt32, to managedSpaceID: UInt64) -> Bool {
        guard let mainConnection, let moveWindows else {
            return false
        }

        let windowIDs = [NSNumber(value: windowID)] as CFArray
        return moveWindows(mainConnection(), windowIDs, managedSpaceID) == .success
    }
}

func score(_ saved: SavedWindow, _ live: LiveWindow) -> Int {
    guard saved.bundleID == live.bundleID else {
        return Int.min / 2
    }

    var result = 1_000

    if saved.windowID == live.id {
        result += 2_000
    }

    if saved.title == live.title {
        result += 800
    } else if !saved.title.isEmpty,
              !live.title.isEmpty,
              (saved.title.contains(live.title) || live.title.contains(saved.title)) {
        result += 300
    }

    if saved.role == live.role {
        result += 80
    }

    if saved.subrole == live.subrole {
        result += 80
    }

    if saved.ordinal == 0 {
        result += 1
    }

    result -= Int(abs(saved.frame.width - live.frame.width) / 10)
    result -= Int(abs(saved.frame.height - live.frame.height) / 10)

    return result
}

func loadProfile(_ name: String) -> Profile {
    do {
        let data = try Data(contentsOf: profileURL(name))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Profile.self, from: data)
    } catch {
        die("could not load profile '\(name)': \(error)")
    }
}

func displaySetMatches(_ profile: Profile) -> Bool {
    displaySignature(profile.displays) == displaySignature(currentDisplays())
}

func requiredSpaceUUIDs(for profile: Profile) -> Set<String> {
    Set(profile.windows.compactMap(\.spaceUUID))
}

func spacesAreReady(for profile: Profile) -> Bool {
    let required = requiredSpaceUUIDs(for: profile)

    // Profiles without Space information can still restore window frames.
    guard !required.isEmpty else {
        return true
    }

    let state = spaceState()
    return required.allSatisfy { state.uuidToManagedID[$0] != nil }
}

func restoreProfile(_ name: String, requireDisplayMatch: Bool = true) {
    guard trusted(prompt: true) else {
        die(
            "Accessibility permission is required. Enable spacewatch " +
            "in System Settings > Privacy & Security > Accessibility."
        )
    }

    let profile = loadProfile(name)

    if requireDisplayMatch && !displaySetMatches(profile) {
        log("display set does not match profile '\(name)'; restore skipped")
        return
    }

    let live = liveWindows()
    var usedWindowIDs = Set<UInt32>()
    let spaces = spaceState()
    let skyLight = SkyLight()

    var restoredCount = 0
    var movedSpaceCount = 0
    var unmatchedCount = 0

    for savedWindow in profile.windows {
        let candidates = live
            .filter { !usedWindowIDs.contains($0.id) && $0.bundleID == savedWindow.bundleID }
            .sorted { score(savedWindow, $0) > score(savedWindow, $1) }

        guard let window = candidates.first,
              score(savedWindow, window) > 900 else {
            unmatchedCount += 1
            continue
        }

        usedWindowIDs.insert(window.id)

        if let spaceUUID = savedWindow.spaceUUID,
           let managedSpaceID = spaces.uuidToManagedID[spaceUUID],
           skyLight.moveWindow(window.id, to: managedSpaceID) {
            movedSpaceCount += 1
        }

        let savedPosition = CGPoint(x: savedWindow.frame.x, y: savedWindow.frame.y)
        let savedSize = CGSize(
            width: savedWindow.frame.width,
            height: savedWindow.frame.height
        )

        setPoint(window.ax, kAXPositionAttribute as CFString, savedPosition)
        setSize(window.ax, kAXSizeAttribute as CFString, savedSize)

        // A short per-window retry is intentional. Some applications initially constrain
        // the frame to the display on which the window was temporarily placed.
        usleep(25_000)

        setPoint(window.ax, kAXPositionAttribute as CFString, savedPosition)
        setSize(window.ax, kAXSizeAttribute as CFString, savedSize)

        restoredCount += 1
    }

    log(
        "restored \(restoredCount) windows; " +
        "moved \(movedSpaceCount) to saved Spaces; " +
        "\(unmatchedCount) unmatched"
    )
}

final class Watcher {
    private let profileName: String
    private let profile: Profile
    private var timer: Timer?
    private var lastSignature: String
    private var waitingForReady = false
    private var readinessGeneration = 0
    private var lastReadinessState: String?
    private var consecutiveReadyChecks = 0

    init(_ profileName: String) {
        self.profileName = profileName
        self.profile = loadProfile(profileName)
        self.lastSignature = displaySignature(currentDisplays())
    }

    private func cancelReadinessWait(reason: String) {
        if waitingForReady {
            log(reason)
        }

        waitingForReady = false
        consecutiveReadyChecks = 0
        lastReadinessState = nil
        readinessGeneration += 1
    }

    private func readinessState() -> String? {
        guard displaySetMatches(profile) else {
            return nil
        }

        let state = spaceState()
        let required = requiredSpaceUUIDs(for: profile)

        guard required.allSatisfy({ state.uuidToManagedID[$0] != nil }) else {
            return nil
        }

        // Requiring the same Space-to-runtime-ID mapping twice avoids restoring during
        // the transient moment when WindowServer is still rebuilding its Space state.
        return required
            .sorted()
            .map { uuid in "\(uuid)=\(state.uuidToManagedID[uuid] ?? 0)" }
            .joined(separator: "|")
    }

    private func beginReadinessWait() {
        guard !waitingForReady else {
            return
        }

        waitingForReady = true
        consecutiveReadyChecks = 0
        lastReadinessState = nil
        readinessGeneration += 1
        let generation = readinessGeneration

        log("matching display set detected; waiting until WindowServer Spaces are ready")
        checkReadiness(generation: generation)
    }

    private func checkReadiness(generation: Int) {
        guard generation == readinessGeneration, waitingForReady else {
            return
        }

        guard displaySetMatches(profile) else {
            cancelReadinessWait(
                reason: "display configuration changed while waiting; restore cancelled"
            )
            return
        }

        if let state = readinessState() {
            if state == lastReadinessState {
                consecutiveReadyChecks += 1
            } else {
                lastReadinessState = state
                consecutiveReadyChecks = 1
            }

            if consecutiveReadyChecks >= 2 {
                waitingForReady = false
                log("display and Spaces are ready; restoring")
                restoreProfile(profileName)
                return
            }
        } else {
            consecutiveReadyChecks = 0
            lastReadinessState = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.checkReadiness(generation: generation)
        }
    }

    func start() {
        log("watching display changes for profile '\(profileName)' (Ctrl-C to stop)")

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else {
                return
            }

            let currentSignature = displaySignature(currentDisplays())

            guard currentSignature != self.lastSignature else {
                return
            }

            self.lastSignature = currentSignature

            if displaySetMatches(self.profile) {
                self.beginReadinessWait()
            } else {
                self.cancelReadinessWait(
                    reason: "display set no longer matches profile '\(self.profileName)'"
                )
            }
        }

        // If the watcher starts while the saved display set is already connected,
        // perform one readiness-controlled restore.
        if displaySetMatches(profile) {
            beginReadinessWait()
        }

        RunLoop.main.run()
    }
}

final class AutoProfileManager {
    private var timer: Timer?
    private var activeDisplaySignature = ""
    private var activeProfileName: String?
    private var lastSavedFingerprint: String?
    private var pendingFingerprint: String?
    private var pendingProfile: Profile?
    private var stableChecks = 0
    private var generation = 0
    private var settling = false

    private func resetChangeDetection() {
        pendingFingerprint = nil
        pendingProfile = nil
        stableChecks = 0
    }

    private func configureForCurrentDisplays() {
        generation += 1
        let localGeneration = generation
        let displays = currentDisplays()
        activeDisplaySignature = displaySignature(displays)
        resetChangeDetection()
        settling = true

        if let profile = matchingProfile(for: displays) {
            activeProfileName = profile.name
            lastSavedFingerprint = profileStateFingerprint(profile)
            log("display set matched profile '\(profile.name)'; waiting for Spaces to stabilise")
            waitUntilReady(profile: profile, generation: localGeneration)
        } else {
            let name = automaticProfileName(for: displays)
            activeProfileName = name
            lastSavedFingerprint = nil
            log("new display set detected; preparing automatic profile '\(name)'")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self, localGeneration == self.generation else { return }
                self.settling = false
            }
        }
    }

    private func waitUntilReady(profile: Profile, generation localGeneration: Int,
                                previousState: String? = nil, stable: Int = 0) {
        guard localGeneration == generation else { return }
        guard displaySignature(currentDisplays()) == activeDisplaySignature else { return }
        let state = spaceState()
        let required = requiredSpaceUUIDs(for: profile)
        guard required.allSatisfy({ state.uuidToManagedID[$0] != nil }) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.waitUntilReady(profile: profile, generation: localGeneration)
            }
            return
        }
        let readiness = required.sorted().map {
            "\($0)=\(state.uuidToManagedID[$0] ?? 0)"
        }.joined(separator: "|")
        let nextStable = readiness == previousState ? stable + 1 : 1
        if nextStable >= 2 {
            log("display and Spaces are ready; restoring '\(profile.name)'")
            restoreProfile(profile.name)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self, localGeneration == self.generation else { return }
                let captured = captureProfile(profile.name, promptForTrust: false)
                self.lastSavedFingerprint = profileStateFingerprint(captured)
                self.settling = false
                self.resetChangeDetection()
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.waitUntilReady(profile: profile, generation: localGeneration,
                                 previousState: readiness, stable: nextStable)
        }
    }

    private func detectStateChange() {
        guard !settling, let profileName = activeProfileName else { return }
        let captured = captureProfile(profileName, promptForTrust: false)
        let fingerprint = profileStateFingerprint(captured)
        guard fingerprint != lastSavedFingerprint else {
            resetChangeDetection()
            return
        }
        if fingerprint == pendingFingerprint {
            stableChecks += 1
        } else {
            pendingFingerprint = fingerprint
            pendingProfile = captured
            stableChecks = 1
        }
        // Save only after the exact changed state is observed in two consecutive polls.
        // There is no periodic rewrite and no fixed autosave interval.
        guard stableChecks >= 2, let profile = pendingProfile else { return }
        writeProfile(profile)
        lastSavedFingerprint = fingerprint
        resetChangeDetection()
    }

    func start() {
        guard trusted(prompt: true) else {
            die("Accessibility permission is required for watch-auto")
        }
        log("automatically managing profiles and watching state changes (Ctrl-C to stop)")
        configureForCurrentDisplays()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let signature = displaySignature(currentDisplays())
            if signature != self.activeDisplaySignature {
                self.configureForCurrentDisplays()
            } else {
                self.detectStateChange()
            }
        }
        RunLoop.main.run()
    }
}

func usage() -> Never {
    print(
        """
        Usage:
          spacewatch snapshot PROFILE
          spacewatch restore PROFILE
          spacewatch watch PROFILE
          spacewatch watch-auto
          spacewatch rename OLD_NAME NEW_NAME
          spacewatch list
          spacewatch displays

        Run 'spacewatch snapshot home' while every window is on its intended
        display and Space. Run 'spacewatch watch-auto' to create/select profiles by
        display set, restore them when Spaces are ready, and save only detected changes.
        """
    )
    exit(0)
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard let command = arguments.first else {
    usage()
}

switch command {
case "snapshot":
    guard arguments.count == 2 else {
        usage()
    }
    saveProfile(arguments[1])

case "restore":
    guard arguments.count == 2 else {
        usage()
    }
    restoreProfile(arguments[1], requireDisplayMatch: false)

case "watch":
    guard arguments.count == 2 else {
        usage()
    }
    Watcher(arguments[1]).start()

case "watch-auto":
    guard arguments.count == 1 else {
        usage()
    }
    AutoProfileManager().start()
case "rename":
    guard arguments.count == 3 else {
        usage()
    }
    renameProfile(from: arguments[1], to: arguments[2])
case "list":
    let files = (try? fileManager.contentsOfDirectory(
        at: profilesDirectory,
        includingPropertiesForKeys: nil
    )) ?? []

    files
        .filter { $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        .forEach { print($0.deletingPathExtension().lastPathComponent) }

case "displays":
    for display in currentDisplays() {
        print(
            "\(display.uuid) " +
            "vendor=\(display.vendor) " +
            "model=\(display.model) " +
            "serial=\(display.serial) " +
            "\(display.width)x\(display.height)"
        )
    }

case "help", "--help", "-h":
    usage()

default:
    usage()
}
