import Foundation
import SwiftUI

struct DemoWorkflowEvent: Identifiable {
    let id: String
    let filter: FeedFilter
    let repositoryName: String
    let title: String
    let actor: String
    let statusLabel: String
    let badgeTone: BadgeTone
    let statusColor: Color
    let updatedAt: Date
    let url: URL

    static func samples(now: Date = Date()) -> [DemoWorkflowEvent] {
        [
            DemoWorkflowEvent(
                id: "demo-pr-review",
                filter: .prs,
                repositoryName: "demo/app",
                title: "Add billing export endpoint",
                actor: "demo-reviewer",
                statusLabel: "waiting for approval",
                badgeTone: .blue,
                statusColor: GitPulseColors.blue,
                updatedAt: now.addingTimeInterval(-420),
                url: URL(string: "https://github.com/demo/app/pull/42")!
            ),
            DemoWorkflowEvent(
                id: "demo-issue-assigned",
                filter: .issues,
                repositoryName: "demo/app",
                title: "Issue assigned: reconcile webhook retry state",
                actor: "demo-triage",
                statusLabel: "assigned",
                badgeTone: .amber,
                statusColor: GitPulseColors.amber,
                updatedAt: now.addingTimeInterval(-920),
                url: URL(string: "https://github.com/demo/app/issues/118")!
            ),
            DemoWorkflowEvent(
                id: "demo-ci-failed",
                filter: .cicd,
                repositoryName: "demo/api",
                title: "CI failed on main",
                actor: "github-actions",
                statusLabel: "checks failed",
                badgeTone: .red,
                statusColor: GitPulseColors.red,
                updatedAt: now.addingTimeInterval(-1_840),
                url: URL(string: "https://github.com/demo/api/actions")!
            ),
            DemoWorkflowEvent(
                id: "demo-mention",
                filter: .mentions,
                repositoryName: "demo/design-system",
                title: "Mentioned in spacing token discussion",
                actor: "demo-designer",
                statusLabel: "mention",
                badgeTone: .gray,
                statusColor: GitPulseColors.textFaint,
                updatedAt: now.addingTimeInterval(-3_700),
                url: URL(string: "https://github.com/demo/design-system/issues/9")!
            )
        ]
    }
}
