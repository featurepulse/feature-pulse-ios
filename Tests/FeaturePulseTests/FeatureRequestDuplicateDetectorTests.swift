@testable import FeaturePulse
import Testing

@Suite(.serialized)
struct FeatureRequestDuplicateDetectorTests {
    @Test
    func `does not suggest duplicates when feature is disabled`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = false

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Export reports as PDF",
            description: "Please let me download report data as a PDF file.",
            existingRequests: existingRequests(including: exportPDFRequest)
        )

        #expect(suggestion == nil)
    }

    @Test
    func `does not call semantic reranker when local match is strong`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        final class CallState: @unchecked Sendable {
            var count = 0
        }

        let callState = CallState()

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Export reports as PDF",
            description: "Please let me download report data as a PDF file.",
            existingRequests: existingRequests(including: exportPDFRequest),
            semanticReranker: { _, _, _ in
                callState.count += 1
                return nil
            }
        )

        #expect(suggestion?.request.id == exportPDFRequest.id)
        #expect(callState.count == 0)
    }

    @Test
    func `uses semantic reranker for weak local candidates`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        final class Capture: @unchecked Sendable {
            var candidateIDs: [String] = []
        }

        let capture = Capture()

        let target = FeatureRequest(
            id: "calendar-sync",
            title: "Calendar sync",
            description: "Connect planned roadmap items to an external calendar.",
            status: .planned,
            voteCount: 34
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Schedule integration",
            description: "Connect planning items with my calendar.",
            existingRequests: existingRequests(including: target),
            semanticReranker: { _, _, candidates in
                capture.candidateIDs = candidates.map(\.request.id)
                return candidates
                    .first { $0.request.id == "calendar-sync" }
                    .map { DuplicateSuggestion(request: $0.request) }
            }
        )

        #expect(suggestion?.request.id == "calendar-sync")
        #expect(capture.candidateIDs.contains("calendar-sync"))
    }

    @Test
    func `semantic reranker can match french request to english existing request`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        final class Capture: @unchecked Sendable {
            var candidateIDs: [String] = []
        }

        let capture = Capture()
        let englishRequest = FeatureRequest(
            id: "english-dark-dashboard",
            title: "Dark mode for dashboard",
            description: "Let users switch the full dashboard into a darker theme for late-night planning.",
            status: .planned,
            voteCount: 124
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Mode sombre",
            description: "Permettre un affichage sombre pour le tableau de bord.",
            existingRequests: existingRequests(including: englishRequest),
            semanticReranker: { _, _, candidates in
                capture.candidateIDs = candidates.map(\.request.id)
                return candidates
                    .first { $0.request.id == "english-dark-dashboard" }
                    .map { DuplicateSuggestion(request: $0.request) }
            }
        )

        #expect(suggestion?.request.id == "english-dark-dashboard")
        #expect(capture.candidateIDs.contains("english-dark-dashboard"))
    }

    @Test
    func `semantic reranker can reject french request with weak english lexical overlap`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        final class Capture: @unchecked Sendable {
            var wasCalled = false
        }

        let capture = Capture()
        let englishRequest = FeatureRequest(
            id: "english-dark-dashboard",
            title: "Dark mode for dashboard",
            description: "Let users switch the full dashboard into a darker theme for late-night planning.",
            status: .planned,
            voteCount: 124
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Mode sombre",
            description: "Permettre un affichage sombre pour le tableau de bord.",
            existingRequests: existingRequests(including: englishRequest),
            semanticReranker: { _, _, _ in
                capture.wasCalled = true
                return nil
            }
        )

        #expect(suggestion == nil)
        #expect(capture.wasCalled)
    }

    @Test
    func `semantic reranker can match sdk languages to english existing request`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let englishRequest = FeatureRequest(
            id: "english-csv-export",
            title: "CSV export",
            description: "Export feature requests, votes, and MRR impact to CSV for internal reporting.",
            status: .planned,
            voteCount: 141
        )

        let localizedRequests = [
            ("es", "Exportar CSV", "Exportar solicitudes de funciones y votos en CSV."),
            ("it", "Esportare CSV", "Esportare richieste di funzionalita e voti in CSV."),
            ("pt-PT", "Exportar CSV", "Exportar pedidos de funcionalidades e votos em CSV."),
            ("zh-Hans", "CSV 导出", "将功能请求和投票导出为 CSV。")
        ]

        for localizedRequest in localizedRequests {
            final class Capture: @unchecked Sendable {
                var candidateIDs: [String] = []
            }

            let capture = Capture()

            let suggestion = await FeatureRequestDuplicateDetector.suggestion(
                title: localizedRequest.1,
                description: localizedRequest.2,
                existingRequests: existingRequests(including: englishRequest),
                semanticReranker: { _, _, candidates in
                    capture.candidateIDs = candidates.map(\.request.id)
                    return candidates
                        .first { $0.request.id == "english-csv-export" }
                        .map { DuplicateSuggestion(request: $0.request) }
                }
            )

            #expect(suggestion?.request.id == "english-csv-export", "Failed for \(localizedRequest.0)")
            #expect(capture.candidateIDs.contains("english-csv-export"), "Missing candidate for \(localizedRequest.0)")
        }
    }

    @Test
    func `semantic reranker receives at most twenty candidates`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        final class Capture: @unchecked Sendable {
            var candidateCount = 0
        }

        let capture = Capture()

        let candidates = (0 ..< 30).map { index in
            FeatureRequest(
                id: "calendar-candidate-\(index)",
                title: "Calendar feature \(index)",
                description: "Planning request for roadmap visibility \(index).",
                status: .planned,
                voteCount: index
            )
        }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Calendar coordination",
            description: "Coordinate planning schedules with calendar views.",
            existingRequests: candidates,
            semanticReranker: { _, _, candidates in
                capture.candidateCount = candidates.count
                return nil
            }
        )

        #expect(suggestion == nil)
        #expect(capture.candidateCount == 20)
    }

    @Test
    func `suggests obvious local duplicate when enabled`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Export reports as PDF",
            description: "Please let me download report data as a PDF file.",
            existingRequests: existingRequests(including: exportPDFRequest)
        )

        #expect(suggestion?.request.id == exportPDFRequest.id)
    }

    @Test
    func `suggests same feature with shorter wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let existingRequest = FeatureRequest(
            id: "dark-dashboard",
            title: "Dark mode for dashboard",
            description: "Let users switch the full dashboard into a darker theme for late-night planning.",
            status: .planned,
            voteCount: 124
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Add Dark mode",
            description: "Dark mode for the dashboard",
            existingRequests: existingRequests(including: existingRequest)
        )

        #expect(suggestion?.request.id == existingRequest.id)
    }

    @Test
    func `passes semantically similar voice task request to reranker`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        final class Capture: @unchecked Sendable {
            var candidateIDs: [String] = []
        }

        let capture = Capture()
        let existingRequest = FeatureRequest(
            id: "speak-to-create-tasks",
            title: "Speak to create tasks",
            description: """
            Speak te create tasks instead of writing as an input. It should than create x tasks depending and
            determine the date. User can still update task after
            """,
            status: .inProgress,
            voteCount: 6
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Voice to create",
            description: "Use voice to create tasks",
            existingRequests: existingRequests(including: existingRequest),
            semanticReranker: { _, _, candidates in
                capture.candidateIDs = candidates.map(\.request.id)
                return candidates
                    .first { $0.request.id == "speak-to-create-tasks" }
                    .map { DuplicateSuggestion(request: $0.request) }
            }
        )

        #expect(suggestion?.request.id == "speak-to-create-tasks")
        #expect(capture.candidateIDs.contains("speak-to-create-tasks"))
    }

    @Test
    func `suggests duplicate for voice to create screenshot wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let existingRequest = FeatureRequest(
            id: "voice-t-create-tasks",
            title: "Voice t create tasks",
            description: "I want to speak to create tasks",
            status: .pending,
            voteCount: 1
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Voice to create",
            description: "Use voice to create tasks",
            existingRequests: existingRequests(including: existingRequest),
            semanticReranker: { _, _, _ in nil }
        )

        #expect(suggestion?.request.id == "voice-t-create-tasks")
    }

    @Test
    func `does not locally suggest semantic-only voice request without reranker`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let existingRequest = FeatureRequest(
            id: "speak-to-create-tasks",
            title: "Speak to create tasks",
            description: """
            Speak te create tasks instead of writing as an input. It should than create x tasks depending and
            determine the date. User can still update task after
            """,
            status: .inProgress,
            voteCount: 6
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Voice to create",
            description: "Use voice to create tasks",
            existingRequests: existingRequests(including: existingRequest),
            semanticReranker: { _, _, _ in nil }
        )

        #expect(suggestion == nil)
    }

    @Test
    func `does not suggest different short actions with shared object only`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Archive dashboard cards",
            description: "Move dashboard cards into an archive so they are hidden from the active view.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "share-dashboard-cards",
                    title: "Share dashboard cards",
                    description: "Send dashboard cards to teammates with a public link.",
                    status: .planned,
                    voteCount: 22
                )
            ),
            semanticReranker: { _, _, _ in nil }
        )

        #expect(suggestion == nil)
    }

    @Test
    func `finds duplicate in large request list`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let topics = [
            ("Push notification rules", "Configure notification timing, reminders, and quiet hours."),
            ("Dashboard widgets", "Reorder dashboard cards and pin important metrics."),
            ("Revenue chart filters", "Filter revenue charts by country, plan, and date range."),
            ("Roadmap status labels", "Customize status names, colors, and visibility."),
            ("Screenshot uploads", "Attach screenshots and images to new feedback."),
            ("User segmentation", "Group voters by subscription plan and activity."),
            ("Admin comments", "Let product teams reply to customer feedback."),
            ("Localization workflow", "Translate request titles and descriptions."),
            ("CSV import", "Import backlog items from CSV files."),
            ("PDF invoices", "Download invoices and receipts as PDF files.")
        ]

        let distractors = (0 ..< 300).map { index in
            let topic = topics[index % topics.count]
            return FeatureRequest(
                id: "distractor-\(index)",
                title: "\(topic.0) \(index)",
                description: "\(topic.1) Request number \(index).",
                status: index % 17 == 0 ? .completed : .planned,
                voteCount: index
            )
        }

        let nearMisses = [
            FeatureRequest(
                id: "csv-import",
                title: "CSV import",
                description: "Import feature requests from CSV into the dashboard.",
                status: .planned,
                voteCount: 120
            ),
            FeatureRequest(
                id: "pdf-export",
                title: "PDF export",
                description: "Export invoices and billing reports as PDF.",
                status: .planned,
                voteCount: 110
            ),
            FeatureRequest(
                id: "revenue-export",
                title: "Revenue export",
                description: "Export revenue metrics and subscription data for finance.",
                status: .planned,
                voteCount: 105
            ),
            FeatureRequest(
                id: "vote-analytics",
                title: "Vote analytics",
                description: "Analyze votes, MRR impact, and customer activity in charts.",
                status: .planned,
                voteCount: 95
            )
        ]

        let target = FeatureRequest(
            id: "csv-export",
            title: "CSV export",
            description: "Export feature requests, votes, and MRR impact to CSV for internal reporting.",
            status: .inProgress,
            voteCount: 83
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "CSV export report",
            description: "Export votes and feature request data as CSV.",
            existingRequests: distractors + nearMisses + [target]
        )

        #expect(suggestion?.request.id == target.id)
    }

    @Test
    func `finds duplicate in thousand request list`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let actions = [
            "Pin", "Archive", "Preview", "Schedule", "Compare", "Group", "Hide", "Rename", "Clone", "Share",
            "Lock", "Unlock", "Search", "Sort", "Merge", "Split", "Assign", "Mention", "Bookmark", "Restore",
            "Approve", "Reject", "Prioritize", "Estimate", "Tag", "Filter", "Translate", "Notify", "Inspect", "Sync"
        ]
        let objects = [
            "dashboard cards", "roadmap lanes", "billing receipts", "webhook retries", "admin notes",
            "customer segments", "team invitations", "release notes", "feedback sources", "workspace roles",
            "status labels", "public boards", "private comments", "integration logs", "account limits",
            "subscription plans", "feature owners", "priority scores", "email digests", "mobile banners",
            "Slack channels", "API tokens", "audit events", "survey answers", "translation jobs",
            "onboarding steps", "changelog entries", "beta cohorts", "usage alerts", "saved views",
            "domain settings", "SSO providers", "timezone rules", "moderation queues"
        ]
        let contexts = [
            "for enterprise teams", "inside the owner dashboard", "before public launch", "per workspace",
            "from mobile devices", "for trial customers", "after status changes", "during roadmap planning",
            "with permission checks", "for weekly reviews", "across multiple products", "from archived boards",
            "without exposing private data", "for product managers", "with custom branding", "during onboarding",
            "for billing admins", "from notification settings", "with localized labels", "for agency clients",
            "while importing feedback", "after user sync", "for security audits", "inside saved filters",
            "with compact layout", "for high-volume boards", "during release planning", "from workspace settings",
            "with keyboard navigation", "for customer success"
        ]

        let distractors = (0 ..< 1000).map { index in
            let action = actions[index % actions.count]
            let object = objects[(index / actions.count) % objects.count]
            let context = contexts[(index / (actions.count * objects.count)) % contexts.count]
            return FeatureRequest(
                id: "thousand-distractor-\(index)",
                title: "\(action) \(object) \(context)",
                description: "Let users \(action.lowercased()) \(object) \(context) with clear ownership and reliable updates.",
                status: index % 29 == 0 ? .completed : .planned,
                voteCount: index % 200
            )
        }

        let nearMisses = [
            FeatureRequest(
                id: "thousand-csv-import",
                title: "CSV import",
                description: "Import feature requests and customer feedback from CSV files.",
                status: .planned,
                voteCount: 210
            ),
            FeatureRequest(
                id: "thousand-data-export",
                title: "Data export",
                description: "Export workspace configuration and account metadata.",
                status: .planned,
                voteCount: 205
            ),
            FeatureRequest(
                id: "thousand-vote-report",
                title: "Vote report",
                description: "Create charts for vote counts and customer impact.",
                status: .planned,
                voteCount: 198
            )
        ]

        let target = FeatureRequest(
            id: "thousand-csv-export",
            title: "CSV export for feature requests",
            description: "Export feature requests, votes, and MRR impact to CSV for internal reporting.",
            status: .inProgress,
            voteCount: 188
        )

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Export request votes as CSV",
            description: "Download feature request voting data and MRR impact in a CSV report.",
            existingRequests: distractors + nearMisses + [target]
        )

        #expect(suggestion?.request.id == target.id)
    }

    @Test
    func `uses fuzzy token matching for small typos`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Export dashbord reports",
            description: "Download dashboard reports for the team.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "dashboard-export",
                    title: "Export dashboard reports",
                    description: "Let teams export dashboard analytics and reports.",
                    status: .planned,
                    voteCount: 39
                )
            )
        )

        #expect(suggestion?.request.id == "dashboard-export")
    }

    @Test
    func `suggests duplicate with french wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Ajouter le mode sombre",
            description: "Mode sombre pour le tableau de bord.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "dark-dashboard-fr",
                    title: "Mode sombre pour le tableau de bord",
                    description: "Permettre aux utilisateurs de passer le tableau de bord en theme sombre.",
                    status: .planned,
                    voteCount: 58
                )
            )
        )

        #expect(suggestion?.request.id == "dark-dashboard-fr")
    }

    @Test
    func `suggests duplicate with german wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Dunkelmodus hinzufugen",
            description: "Dunkler Modus fur das Dashboard.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "dark-dashboard-de",
                    title: "Dunkelmodus fur Dashboard",
                    description: "Benutzer konnen das Dashboard auf ein dunkles Thema umstellen.",
                    status: .planned,
                    voteCount: 64
                )
            )
        )

        #expect(suggestion?.request.id == "dark-dashboard-de")
    }

    @Test
    func `suggests duplicate with spanish wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Exportar CSV",
            description: "Exportar solicitudes de funciones, votos y MRR en CSV.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "csv-export-es",
                    title: "Exportar CSV",
                    description: "Exportar solicitudes de funciones y votos como CSV para informes.",
                    status: .planned,
                    voteCount: 52
                )
            )
        )

        #expect(suggestion?.request.id == "csv-export-es")
    }

    @Test
    func `suggests duplicate with italian wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Esportare CSV",
            description: "Esportare richieste di funzionalita, voti e MRR in CSV.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "csv-export-it",
                    title: "Esportazione CSV",
                    description: "Esportare richieste di funzionalita e voti come CSV per i report.",
                    status: .planned,
                    voteCount: 48
                )
            )
        )

        #expect(suggestion?.request.id == "csv-export-it")
    }

    @Test
    func `suggests duplicate with portuguese wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Exportar CSV",
            description: "Exportar pedidos de funcionalidades, votos e MRR em CSV.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "csv-export-pt",
                    title: "Exportar CSV",
                    description: "Exportar pedidos de funcionalidades e votos como CSV para relatorios.",
                    status: .planned,
                    voteCount: 45
                )
            )
        )

        #expect(suggestion?.request.id == "csv-export-pt")
    }

    @Test
    func `suggests duplicate with simplified chinese wording`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "CSV 导出",
            description: "将功能请求、投票和 MRR 导出为 CSV。",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "csv-export-zh-hans",
                    title: "CSV 导出",
                    description: "将功能请求和投票导出为 CSV，用于内部报告。",
                    status: .planned,
                    voteCount: 50
                )
            )
        )

        #expect(suggestion?.request.id == "csv-export-zh-hans")
    }

    @Test
    func `suggests duplicate with french export wording without synonyms`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Export CSV",
            description: "Exporter les demandes et les votes en CSV.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "csv-export-fr",
                    title: "Export CSV",
                    description: "Exporter les demandes de fonctionnalite, les votes et le MRR en CSV.",
                    status: .inProgress,
                    voteCount: 33
                )
            )
        )

        #expect(suggestion?.request.id == "csv-export-fr")
    }

    @Test
    func `suggests duplicate with german export wording without synonyms`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "CSV Export",
            description: "Votes und Feature Requests als CSV exportieren.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "csv-export-de",
                    title: "CSV Export",
                    description: "Feature Requests, Stimmen und MRR als CSV exportieren.",
                    status: .inProgress,
                    voteCount: 41
                )
            )
        )

        #expect(suggestion?.request.id == "csv-export-de")
    }

    @Test
    func `suggests french duplicate with unmapped domain words`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Calendrier editorial",
            description: "Afficher un calendrier editorial pour planifier les publications.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "calendrier-editorial",
                    title: "Calendrier editorial",
                    description: "Planifier les publications dans un calendrier editorial.",
                    status: .planned,
                    voteCount: 27
                )
            )
        )

        #expect(suggestion?.request.id == "calendrier-editorial")
    }

    @Test
    func `suggests german duplicate with unmapped domain words`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Kanban Spalten anpassen",
            description: "Eigene Kanban Spalten fur den Workflow konfigurieren.",
            existingRequests: existingRequests(
                including: FeatureRequest(
                    id: "kanban-spalten",
                    title: "Kanban Spalten konfigurieren",
                    description: "Teams konnen eigene Kanban Spalten fur ihren Workflow erstellen.",
                    status: .planned,
                    voteCount: 31
                )
            )
        )

        #expect(suggestion?.request.id == "kanban-spalten")
    }

    @Test
    func `does not match synonym only wording without shared terms`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Telecharger un tableur",
            description: "Sauvegarder les donnees dans un fichier.",
            existingRequests: existingRequests(additional: [
                FeatureRequest(
                    id: "csv-export-synonym-only",
                    title: "CSV export",
                    description: "Export feature requests and votes to CSV.",
                    status: .planned,
                    voteCount: 44
                )
            ])
        )

        #expect(suggestion == nil)
    }

    @Test
    func `does not suggest related but different feature`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "Dark mode",
            description: "Add a dark visual theme.",
            existingRequests: existingRequests(additional: [
                FeatureRequest(
                    id: "theme-colors",
                    title: "Custom status colors",
                    description: "Configure roadmap status labels and colors from the dashboard.",
                    status: .planned,
                    voteCount: 46
                )
            ])
        )

        #expect(suggestion == nil)
    }

    @Test
    func `ignores completed and rejected requests`() async {
        FeaturePulse.shared.duplicateSuggestionsEnabled = true
        defer { resetDetectorState() }

        let suggestion = await FeatureRequestDuplicateDetector.suggestion(
            title: "CSV export",
            description: "Export feature requests and votes to CSV.",
            existingRequests: existingRequests(additional: [
                FeatureRequest(
                    id: "completed-csv-export",
                    title: "CSV export",
                    description: "Export feature requests, votes, and MRR impact to CSV.",
                    status: .completed,
                    voteCount: 100
                ),
                FeatureRequest(
                    id: "rejected-csv-export",
                    title: "CSV export",
                    description: "Export feature requests, votes, and MRR impact to CSV.",
                    status: .rejected,
                    voteCount: 50
                )
            ])
        )

        #expect(suggestion == nil)
    }

    private var exportPDFRequest: FeatureRequest {
        FeatureRequest(
            id: "export-pdf",
            title: "Export reports as PDF",
            description: "Download reports and analytics in PDF format.",
            status: .planned,
            voteCount: 42
        )
    }

    private func resetDetectorState() {
        FeaturePulse.shared.duplicateSuggestionsEnabled = false
    }

    private func existingRequests(including target: FeatureRequest) -> [FeatureRequest] {
        [
            commonDistractors[0],
            commonDistractors[1],
            target,
            commonDistractors[2],
            commonDistractors[3],
            commonDistractors[4]
        ]
    }

    private func existingRequests(additional requests: [FeatureRequest] = []) -> [FeatureRequest] {
        [
            commonDistractors[0],
            commonDistractors[1]
        ] + requests + [
            commonDistractors[2],
            commonDistractors[3],
            commonDistractors[4]
        ]
    }

    private var commonDistractors: [FeatureRequest] {
        [
            FeatureRequest(
                id: "push-notifications",
                title: "Push notifications for updates",
                description: "Notify users when a feature they voted for changes status or gets shipped.",
                status: .planned,
                voteCount: 71
            ),
            FeatureRequest(
                id: "admin-replies",
                title: "Admin replies on requests",
                description: "Let product teams add short responses to feature requests.",
                status: .pending,
                voteCount: 23
            ),
            FeatureRequest(
                id: "screenshot-attachments",
                title: "In-app screenshot attachments",
                description: "Allow users to include screenshots when they submit feature requests.",
                status: .planned,
                voteCount: 59
            ),
            FeatureRequest(
                id: "my-votes-filter",
                title: "Filter by my votes",
                description: "Add a quick way for users to see requests they already supported.",
                status: .pending,
                voteCount: 18
            ),
            FeatureRequest(
                id: "localized-request-list",
                title: "Localized request list",
                description: "Translate request titles and descriptions into the user's device language.",
                status: .planned,
                voteCount: 12
            )
        ]
    }
}
