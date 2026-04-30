import SwiftData
import Foundation

@Model
final class AppSettings {

    // MARK: Identity
    @Attribute(.unique) var id: String = "singleton"

    // MARK: Startup
    var launchAtLogin: Bool = false
    var showInDock: Bool = false
    var reopenLastViewOnLaunch: Bool = true

    // MARK: Behavior
    /// "browser" | "github-desktop" | "safari" | "chrome" | "firefox"
    var openLinksIn: String = "browser"
    var markAsReadOnOpen: Bool = true
    var closePopoverAfterOpeningLink: Bool = false
    var groupByRepo: Bool = true
    /// "activity" | "prs" | "issues" | "cicd"
    var defaultTab: String = "activity"

    // MARK: Data retention
    var retentionDaysRead: Int = 30
    var retentionDaysDismissed: Int = 7
    var demoMode: Bool = false

    // MARK: Appearance
    /// "system" | "light" | "dark"
    var appearanceMode: String = "system"
    /// "system" | "blue" | "green" | "orange" | "red" | "purple" | "monochrome"
    var accentColor: String = "system"
    var popoverVibrancy: Bool = true
    /// "sf-mono" | "menlo" | "fira-code" | "jetbrains-mono" | "cascadia-code"
    var fontName: String = "sf-mono"
    var fontSize: Int = 13
    var denseLayout: Bool = false

    // MARK: Appearance — popover
    var popoverWidth: Int = 360
    /// 10 | 20 | 30 | 0 (unlimited)
    var maxVisibleItems: Int = 20
    var showRelativeTimestamps: Bool = true
    var showAuthorAvatars: Bool = true
    var showCIBranchName: Bool = true
    var showCommitSHA: Bool = false

    // MARK: Notifications — global
    var notificationsEnabled: Bool = true
    var respectFocusMode: Bool = true
    /// "default" | "ping" | "tink" | "pop" | "none"
    var notificationSound: String = "default"
    var groupNotificationsByRepo: Bool = true

    // MARK: Notifications — quiet hours
    var quietHoursEnabled: Bool = false
    /// 24h format hour: 0–23
    var quietHoursFrom: Int = 21
    var quietHoursTo: Int = 8

    // MARK: Repos — org watching
    var autoWatchNewRepos: Bool = false
    var autoWatchOrg: String = ""
    var includeForks: Bool = false
    var includeArchivedRepos: Bool = false
    var watchReposImAssignedTo: Bool = true
    var showOnlyReposWithActivity: Bool = true
    /// Glob pattern — repos matching this are hidden
    var repoHidePattern: String = ""

    // MARK: Polling
    /// Seconds. 0 = manual only.
    var pollIntervalSeconds: Int = 60
    var pausePollingOnBattery: Bool = false
    var pausePollingWhenOffline: Bool = true
    var backoffOnRateLimit: Bool = true

    // MARK: Webhooks
    var webhookEnabled: Bool = false
    var webhookPort: Int = 9876
    var verifyWebhookSignatures: Bool = true

    // MARK: Menu bar — icon
    /// "branch" | "octocat" | "text-gp" | "dot"
    var menuBarIconStyle: String = "branch"
    var colorCodeIconOnCIStatus: Bool = true
    var animateIconWhenCIRunning: Bool = true

    // MARK: Menu bar — badge
    var showCountInMenuBar: Bool = true
    /// "unread" | "prs-review" | "ci-failures" | "all-open"
    var menuBarCountType: String = "unread"
    var hideCountWhenZero: Bool = true
    /// 0 = no cap
    var menuBarCountCap: Int = 99

    // MARK: Menu bar — tabs
    var tabPRsEnabled: Bool = true
    var tabIssuesEnabled: Bool = true
    var tabCICDEnabled: Bool = true
    var tabProjectsEnabled: Bool = false
    var tabMentionsEnabled: Bool = false

    // MARK: Shortcuts
    var shortcutOpenPopover: String = "⌥ Space"
    var shortcutRefresh: String = "⌥ R"
    var shortcutMarkAllRead: String = "⌥ M"
    var shortcutOpenSettings: String = "⌥ ,"

    // MARK: Advanced — logging
    /// "errors" | "warnings" | "info" | "debug" | "verbose"
    var logLevel: String = "errors"
    var writeLogsToFile: Bool = false

    // MARK: Advanced — developer
    var showAPIRequestLog: Bool = false
    var simulateSlowNetwork: Bool = false
    var forceCIFailureState: Bool = false

    // MARK: Updates
    var autoUpdate: Bool = true

    // MARK: Init
    init() {}

    // MARK: Helpers

    var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceMode) ?? .system }
        set { appearanceMode = newValue.rawValue }
    }

    var accent: AppAccentColor {
        get { AppAccentColor(rawValue: accentColor) ?? .system }
        set { accentColor = newValue.rawValue }
    }

    var defaultTabEnum: AppDefaultTab {
        get { AppDefaultTab(rawValue: defaultTab) ?? .activity }
        set { defaultTab = newValue.rawValue }
    }

    var pollInterval: PollInterval {
        get { PollInterval(seconds: pollIntervalSeconds) }
        set { pollIntervalSeconds = newValue.seconds }
    }

    var menuBarCountTypeEnum: MenuBarCountType {
        get { MenuBarCountType(rawValue: menuBarCountType) ?? .unread }
        set { menuBarCountType = newValue.rawValue }
    }

    /// Returns true when quiet hours are currently active.
    var isQuietHoursActive: Bool {
        isQuietHoursActive(atHour: Calendar.current.component(.hour, from: Date()))
    }

    func isQuietHoursActive(atHour hour: Int) -> Bool {
        guard quietHoursEnabled else { return false }
        if quietHoursFrom > quietHoursTo {
            return hour >= quietHoursFrom || hour < quietHoursTo
        } else {
            return hour >= quietHoursFrom && hour < quietHoursTo
        }
    }

    /// Single-row enforcement — call on first launch.
    static func ensureExists(in context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        if (try? context.fetch(descriptor).first) == nil {
            context.insert(AppSettings())
            try? context.save()
        }
    }

    func resetToDefaults() {
        launchAtLogin = false
        showInDock = false
        reopenLastViewOnLaunch = true
        openLinksIn = "browser"
        markAsReadOnOpen = true
        closePopoverAfterOpeningLink = false
        groupByRepo = true
        defaultTab = "activity"
        retentionDaysRead = 30
        retentionDaysDismissed = 7
        demoMode = false
        appearanceMode = "system"
        accentColor = "system"
        popoverVibrancy = true
        fontName = "sf-mono"
        fontSize = 13
        denseLayout = false
        popoverWidth = 360
        maxVisibleItems = 20
        showRelativeTimestamps = true
        showAuthorAvatars = true
        showCIBranchName = true
        showCommitSHA = false
        notificationsEnabled = true
        respectFocusMode = true
        notificationSound = "default"
        groupNotificationsByRepo = true
        quietHoursEnabled = false
        quietHoursFrom = 21
        quietHoursTo = 8
        autoWatchNewRepos = false
        autoWatchOrg = ""
        includeForks = false
        includeArchivedRepos = false
        watchReposImAssignedTo = true
        showOnlyReposWithActivity = true
        repoHidePattern = ""
        pollIntervalSeconds = 60
        pausePollingOnBattery = false
        pausePollingWhenOffline = true
        backoffOnRateLimit = true
        webhookEnabled = false
        webhookPort = 9876
        verifyWebhookSignatures = true
        menuBarIconStyle = "branch"
        colorCodeIconOnCIStatus = true
        animateIconWhenCIRunning = true
        showCountInMenuBar = true
        menuBarCountType = "unread"
        hideCountWhenZero = true
        menuBarCountCap = 99
        tabPRsEnabled = true
        tabIssuesEnabled = true
        tabCICDEnabled = true
        tabProjectsEnabled = false
        tabMentionsEnabled = false
        shortcutOpenPopover = "⌥ Space"
        shortcutRefresh = "⌥ R"
        shortcutMarkAllRead = "⌥ M"
        shortcutOpenSettings = "⌥ ,"
        logLevel = "errors"
        writeLogsToFile = false
        showAPIRequestLog = false
        simulateSlowNetwork = false
        forceCIFailureState = false
        autoUpdate = true
    }
}

// MARK: - Supporting enums

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}

enum AppAccentColor: String, CaseIterable, Identifiable {
    case system, blue, green, orange, red, purple, monochrome
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum AppDefaultTab: String, CaseIterable, Identifiable {
    case activity, prs, issues, cicd
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .activity: return "Activity"
        case .prs:      return "Pull Requests"
        case .issues:   return "Issues"
        case .cicd:     return "CI / CD"
        }
    }
}

enum PollInterval: CaseIterable, Identifiable, Equatable {
    case thirtySeconds, oneMinute, twoMinutes, fiveMinutes, fifteenMinutes, manual

    var id: Int { seconds }

    var seconds: Int {
        switch self {
        case .thirtySeconds:   return 30
        case .oneMinute:       return 60
        case .twoMinutes:      return 120
        case .fiveMinutes:     return 300
        case .fifteenMinutes:  return 900
        case .manual:          return 0
        }
    }

    init(seconds: Int) {
        self = PollInterval.allCases.first { $0.seconds == seconds } ?? .oneMinute
    }

    var displayName: String {
        switch self {
        case .thirtySeconds:  return "30 seconds"
        case .oneMinute:      return "1 minute"
        case .twoMinutes:     return "2 minutes"
        case .fiveMinutes:    return "5 minutes"
        case .fifteenMinutes: return "15 minutes"
        case .manual:         return "Manual only"
        }
    }
}

enum MenuBarCountType: String, CaseIterable, Identifiable {
    case unread      = "unread"
    case prsReview   = "prs-review"
    case ciFailures  = "ci-failures"
    case allOpen     = "all-open"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .unread:     return "Unread events"
        case .prsReview:  return "PRs needing review"
        case .ciFailures: return "CI failures"
        case .allOpen:    return "All open items"
        }
    }
}

enum MenuBarIconStyle: String, CaseIterable, Identifiable {
    case branch  = "branch"
    case octocat = "octocat"
    case textGP  = "text-gp"
    case dot     = "dot"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .branch:  return "Branch symbol"
        case .octocat: return "Octocat"
        case .textGP:  return "Text: GP"
        case .dot:     return "Dot only"
        }
    }
}

enum LogLevel: String, CaseIterable, Identifiable {
    case errors, warnings, info, debug, verbose
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum NotificationSoundOption: String, CaseIterable, Identifiable {
    case `default`, ping, tink, pop, none
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum OpenLinksIn: String, CaseIterable, Identifiable {
    case browser        = "browser"
    case githubDesktop  = "github-desktop"
    case safari         = "safari"
    case chrome         = "chrome"
    case firefox        = "firefox"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .browser:       return "Default browser"
        case .githubDesktop: return "GitHub Desktop"
        case .safari:        return "Safari"
        case .chrome:        return "Chrome"
        case .firefox:       return "Firefox"
        }
    }
}
