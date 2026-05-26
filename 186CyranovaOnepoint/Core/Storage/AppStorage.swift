import Combine
import Foundation

@MainActor
final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let destinations = "destinations"
        static let travelTasks = "travelTasks"
        static let selectedChecklistType = "selectedChecklistType"
        static let worldClocks = "worldClocks"
        static let phrasesViewed = "phrasesViewed"
        static let viewedPhraseIDs = "viewedPhraseIDs"
        static let checklistsCompleted = "checklistsCompleted"
        static let completedChecklistSignatures = "completedChecklistSignatures"
        static let trips = "trips"
        static let activeTripId = "activeTripId"
        static let travelDocuments = "travelDocuments"
        static let diaryEntries = "diaryEntries"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private var sessionTimer: Timer?

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }
    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }
    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }
    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }
    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }
    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }
    @Published var destinations: [Destination] {
        didSet {
            save(destinations, key: Keys.destinations)
            destinationsAdded = destinations.count
        }
    }
    @Published var travelTasks: [TravelTask] {
        didSet { save(travelTasks, key: Keys.travelTasks) }
    }
    @Published var selectedChecklistType: String {
        didSet { defaults.set(selectedChecklistType, forKey: Keys.selectedChecklistType) }
    }
    @Published var worldClocks: [CityClock] {
        didSet { save(worldClocks, key: Keys.worldClocks) }
    }
    @Published var phrasesViewed: Int {
        didSet { defaults.set(phrasesViewed, forKey: Keys.phrasesViewed) }
    }
    @Published var viewedPhraseIDs: Set<String> {
        didSet {
            defaults.set(Array(viewedPhraseIDs), forKey: Keys.viewedPhraseIDs)
            phrasesViewed = viewedPhraseIDs.count
        }
    }
    @Published var checklistsCompleted: Int {
        didSet { defaults.set(checklistsCompleted, forKey: Keys.checklistsCompleted) }
    }
    @Published var trips: [Trip] {
        didSet { save(trips, key: Keys.trips) }
    }
    @Published var activeTripId: UUID? {
        didSet {
            if let id = activeTripId {
                defaults.set(id.uuidString, forKey: Keys.activeTripId)
            } else {
                defaults.removeObject(forKey: Keys.activeTripId)
            }
        }
    }
    @Published var travelDocuments: [TravelDocument] {
        didSet { save(travelDocuments, key: Keys.travelDocuments) }
    }
    @Published var diaryEntries: [DiaryEntry] {
        didSet { save(diaryEntries, key: Keys.diaryEntries) }
    }

    @Published var destinationsAdded: Int = 0
    @Published var pendingAchievementBanner: AchievementDefinition?
    private var achievementBannerQueue: [AchievementDefinition] = []
    private var completedChecklistSignatures: Set<String> {
        didSet { defaults.set(Array(completedChecklistSignatures), forKey: Keys.completedChecklistSignatures) }
    }

    var packingCategories: [String] {
        ["Clothes", "Toiletries", "Electronics", "Documents", "Misc"]
    }
    var itineraryCategories: [String] {
        ["Day 1 Activities", "Day 2 Activities", "Day 3 Activities", "Transport", "Dining"]
    }

    var activeTrip: Trip? {
        guard let id = activeTripId else { return nil }
        return trips.first { $0.id == id && !$0.isArchived }
    }

    var expiringDocuments: [TravelDocument] {
        travelDocuments.filter { $0.isExpiringSoon || $0.isExpired }.sorted { $0.expiryDate < $1.expiryDate }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, defaults: defaults)
        destinations = Self.load(key: Keys.destinations, defaults: defaults) ?? []
        travelTasks = Self.load(key: Keys.travelTasks, defaults: defaults) ?? []
        selectedChecklistType = defaults.string(forKey: Keys.selectedChecklistType) ?? ChecklistType.packing.rawValue
        worldClocks = Self.load(key: Keys.worldClocks, defaults: defaults) ?? []
        phrasesViewed = defaults.integer(forKey: Keys.phrasesViewed)
        viewedPhraseIDs = Set(defaults.stringArray(forKey: Keys.viewedPhraseIDs) ?? [])
        checklistsCompleted = defaults.integer(forKey: Keys.checklistsCompleted)
        completedChecklistSignatures = Set(defaults.stringArray(forKey: Keys.completedChecklistSignatures) ?? [])
        trips = Self.load(key: Keys.trips, defaults: defaults) ?? []
        if let activeString = defaults.string(forKey: Keys.activeTripId) {
            activeTripId = UUID(uuidString: activeString)
        } else {
            activeTripId = nil
        }
        travelDocuments = Self.load(key: Keys.travelDocuments, defaults: defaults) ?? []
        diaryEntries = Self.load(key: Keys.diaryEntries, defaults: defaults) ?? []
        destinationsAdded = destinations.count
        migrateLegacyDataIfNeeded()
        refreshActiveTrip()

        NotificationCenter.default.addObserver(
            forName: .dataReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadFromDefaults() }
        }
    }

    // MARK: - Trip hub helpers

    func destination(for trip: Trip) -> Destination? {
        destinations.first { $0.id == trip.destinationId }
    }

    func trip(for destination: Destination) -> Trip? {
        guard let tripId = destination.tripId else { return nil }
        return trips.first { $0.id == tripId }
    }

    func daysUntilDeparture(for trip: Trip) -> Int? {
        guard let destination = destination(for: trip), !destination.isVisited else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        let departure = Calendar.current.startOfDay(for: destination.plannedDate)
        return Calendar.current.dateComponents([.day], from: start, to: departure).day
    }

    func packingProgress(for tripId: UUID) -> Double {
        let tasks = travelTasks.filter {
            $0.tripId == tripId && $0.checklistType == ChecklistType.packing.rawValue
        }
        guard !tasks.isEmpty else { return 0 }
        let done = tasks.filter(\.isCompleted).count
        return Double(done) / Double(tasks.count)
    }

    func packingProgressPercent(for tripId: UUID) -> Int {
        Int(packingProgress(for: tripId) * 100)
    }

    func timeZoneOffsetLabel(for tripId: UUID) -> String? {
        let clocks = worldClocks.filter { $0.tripId == tripId }
        let timeZone: TimeZone?
        if let clock = clocks.first {
            timeZone = clock.timeZone
        } else if let trip = trips.first(where: { $0.id == tripId }),
                  let country = destination(for: trip)?.country,
                  let brief = CountryBriefService.brief(for: country),
                  let id = brief.timeZoneIdentifier {
            timeZone = TimeZone(identifier: id)
        } else {
            timeZone = nil
        }
        guard let tz = timeZone else { return nil }
        let offset = tz.secondsFromGMT(for: Date()) / 3600
        return String(format: "GMT%+d", offset)
    }

    func setActiveTrip(_ tripId: UUID) {
        activeTripId = tripId
        FeedbackManager.lightTap()
    }

    func refreshActiveTrip() {
        let candidates = trips.filter { !$0.isArchived }.compactMap { trip -> (Trip, Destination)? in
            guard let dest = destination(for: trip), !dest.isVisited else { return nil }
            return (trip, dest)
        }
        guard let nearest = candidates.min(by: { $0.1.plannedDate < $1.1.plannedDate }) else {
            activeTripId = trips.first(where: { !$0.isArchived })?.id
            return
        }
        activeTripId = nearest.0.id
    }

    func updateTripNotes(tripId: UUID, notes: String) {
        guard let index = trips.firstIndex(where: { $0.id == tripId }) else { return }
        trips[index].notes = notes
    }

    func archiveTrip(_ tripId: UUID) {
        guard let index = trips.firstIndex(where: { $0.id == tripId }) else { return }
        trips[index].isArchived = true
        if activeTripId == tripId { refreshActiveTrip() }
    }

    // MARK: - Destination & trip lifecycle

    func addDestination(
        _ destination: Destination,
        tripType: TripType,
        applyTemplate: Bool,
        copyFromTripId: UUID?
    ) {
        var dest = destination
        let trip = Trip(destinationId: dest.id, title: dest.name, notes: dest.notes)
        dest.tripId = trip.id
        dest.tripType = tripType.rawValue
        trips.append(trip)
        destinations.append(dest)

        if let sourceTripId = copyFromTripId {
            copyChecklist(from: sourceTripId, to: trip.id)
        } else if applyTemplate {
            applyPackingTemplate(tripType: tripType, tripId: trip.id)
        }

        linkCountryResources(country: dest.country, tripId: trip.id)
        refreshActiveTrip()
        recordMeaningfulAction()
    }

    func updateDestination(_ destination: Destination) {
        guard let index = destinations.firstIndex(where: { $0.id == destination.id }) else { return }
        destinations[index] = destination
        if let tripIndex = trips.firstIndex(where: { $0.destinationId == destination.id }) {
            trips[tripIndex].title = destination.name
        }
        refreshActiveTrip()
        recordMeaningfulAction()
    }

    func deleteDestination(id: UUID) {
        guard let dest = destinations.first(where: { $0.id == id }) else { return }
        if let tripId = dest.tripId {
            deleteTripData(tripId: tripId)
        }
        destinations.removeAll { $0.id == id }
        refreshActiveTrip()
    }

    func markDestinationVisited(id: UUID) {
        guard let index = destinations.firstIndex(where: { $0.id == id }) else { return }
        destinations[index].isVisited = true
        refreshActiveTrip()
        recordMeaningfulAction()
    }

    private func deleteTripData(tripId: UUID) {
        trips.removeAll { $0.id == tripId }
        travelTasks.removeAll { $0.tripId == tripId }
        worldClocks.removeAll { $0.tripId == tripId }
        diaryEntries.removeAll { $0.tripId == tripId }
        if activeTripId == tripId { activeTripId = nil }
    }

    func applyPackingTemplate(tripType: TripType, tripId: UUID) {
        let templateTasks = PackingTemplates.tasks(for: tripType, tripId: tripId)
        travelTasks.append(contentsOf: templateTasks)
    }

    func copyChecklist(from sourceTripId: UUID, to targetTripId: UUID) {
        let sourceTasks = travelTasks.filter { $0.tripId == sourceTripId }
        let copies = sourceTasks.map { task in
            TravelTask(
                title: task.title,
                category: task.category,
                checklistType: task.checklistType,
                sortOrder: task.sortOrder,
                tripId: targetTripId
            )
        }
        travelTasks.append(contentsOf: copies)
    }

    func pastTripsForCopy(excluding tripId: UUID?) -> [Trip] {
        trips.filter { trip in
            trip.id != tripId && travelTasks.contains { $0.tripId == trip.id }
        }.sorted { $0.createdAt > $1.createdAt }
    }

    private func linkCountryResources(country: String, tripId: UUID) {
        guard let brief = CountryBriefService.brief(for: country) else { return }
        if let tz = brief.timeZoneIdentifier,
           !worldClocks.contains(where: { $0.tripId == tripId && $0.timeZoneIdentifier == tz }) {
            let clock = CityClock(name: country, timeZoneIdentifier: tz, tripId: tripId)
            worldClocks.append(clock)
        }
        for phrase in brief.phrases.prefix(3) {
            let phraseId = "country-\(country)-\(phrase)"
            if !viewedPhraseIDs.contains(phraseId) {
                viewedPhraseIDs.insert(phraseId)
            }
        }
    }

    private func migrateLegacyDataIfNeeded() {
        var changed = false
        for index in destinations.indices {
            if destinations[index].tripId == nil {
                let dest = destinations[index]
                let trip = Trip(destinationId: dest.id, title: dest.name, notes: dest.notes)
                trips.append(trip)
                destinations[index].tripId = trip.id
                changed = true
            }
        }
        if changed { save(destinations, key: Keys.destinations) }
    }

    // MARK: - Tasks & clocks (trip-scoped)

    func tasksForActiveTrip(checklistType: String? = nil) -> [TravelTask] {
        guard let tripId = activeTripId else { return travelTasks }
        return travelTasks.filter { task in
            guard task.tripId == tripId || task.tripId == nil else { return false }
            if let type = checklistType { return task.checklistType == type }
            return true
        }
    }

    func addTravelTask(_ task: TravelTask) {
        var item = task
        if item.tripId == nil { item.tripId = activeTripId }
        travelTasks.append(item)
        recordMeaningfulAction()
    }

    func updateTravelTask(_ task: TravelTask) {
        guard let index = travelTasks.firstIndex(where: { $0.id == task.id }) else { return }
        travelTasks[index] = task
    }

    func deleteTravelTask(id: UUID) {
        travelTasks.removeAll { $0.id == id }
    }

    func toggleTaskCompletion(id: UUID) {
        guard let index = travelTasks.firstIndex(where: { $0.id == id }) else { return }
        if travelTasks[index].isCompleted {
            travelTasks[index].completedAt = nil
        } else {
            travelTasks[index].completedAt = Date()
            recordMeaningfulAction()
            if let tripId = travelTasks[index].tripId {
                checkPackingChecklistCompletion(tripId: tripId)
            } else {
                checkPackingChecklistCompletion(tripId: nil)
            }
        }
    }

    func reorderTasks(in category: String, checklistType: String, tripId: UUID?, from source: IndexSet, to destination: Int) {
        var categoryTasks = travelTasks
            .filter {
                $0.category == category && $0.checklistType == checklistType &&
                (tripId == nil || $0.tripId == tripId || $0.tripId == nil)
            }
            .sorted { $0.sortOrder < $1.sortOrder }
        var items = categoryTasks
        for sourceIndex in source.sorted(by: >) {
            guard sourceIndex < items.count else { continue }
            let item = items.remove(at: sourceIndex)
            let target = min(destination, items.count)
            items.insert(item, at: target)
        }
        for (order, task) in items.enumerated() {
            if let idx = travelTasks.firstIndex(where: { $0.id == task.id }) {
                travelTasks[idx].sortOrder = order
            }
        }
    }

    func addWorldClock(_ clock: CityClock) {
        var item = clock
        if item.tripId == nil { item.tripId = activeTripId }
        worldClocks.append(item)
        recordMeaningfulAction()
    }

    func deleteWorldClock(id: UUID) {
        worldClocks.removeAll { $0.id == id }
    }

    func clocksForMeetingPlanner() -> [CityClock] {
        if worldClocks.isEmpty { return [] }
        if let tripId = activeTripId {
            let tripClocks = worldClocks.filter { $0.tripId == tripId }
            if !tripClocks.isEmpty { return tripClocks }
        }
        return worldClocks
    }

    func convertTime(hour: Int, minute: Int, from sourceClock: CityClock, to targetClock: CityClock, on date: Date = Date()) -> Date? {
        guard let sourceTZ = sourceClock.timeZone, let targetTZ = targetClock.timeZone else { return nil }
        var calendar = Calendar.current
        calendar.timeZone = sourceTZ
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 0
        guard let sourceDate = calendar.date(from: components) else { return nil }
        let formatter = DateFormatter()
        formatter.timeZone = targetTZ
        formatter.dateFormat = "HH:mm"
        return sourceDate
    }

    func formattedTimeInTarget(hour: Int, minute: Int, from source: CityClock, to target: CityClock) -> String {
        guard let converted = convertTime(hour: hour, minute: minute, from: source, to: target) else {
            return "--:--"
        }
        let formatter = DateFormatter()
        formatter.timeZone = target.timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: converted)
    }

    // MARK: - Documents

    func addDocument(_ document: TravelDocument) {
        travelDocuments.append(document)
        recordMeaningfulAction()
    }

    func updateDocument(_ document: TravelDocument) {
        guard let index = travelDocuments.firstIndex(where: { $0.id == document.id }) else { return }
        travelDocuments[index] = document
        recordMeaningfulAction()
    }

    func deleteDocument(id: UUID) {
        travelDocuments.removeAll { $0.id == id }
    }

    // MARK: - Diary

    func diaryEntries(for tripId: UUID) -> [DiaryEntry] {
        diaryEntries.filter { $0.tripId == tripId }.sorted { $0.date > $1.date }
    }

    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.append(entry)
        recordMeaningfulAction()
    }

    func deleteDiaryEntry(id: UUID) {
        diaryEntries.removeAll { $0.id == id }
    }

    // MARK: - Compare

    func compareDestinations(ids: [UUID]) -> [Destination] {
        ids.compactMap { id in destinations.first { $0.id == id } }
    }

    // MARK: - Jet lag

    func jetLagPlan(hourDifference: Int) -> (days: Int, hoursPerDay: Int, direction: String) {
        let absHours = abs(hourDifference)
        let days = max(1, min(7, Int(ceil(Double(absHours) / 2.0))))
        let hoursPerDay = max(1, absHours / days)
        let direction = hourDifference >= 0 ? "Advance bedtime" : "Delay bedtime"
        return (days, hoursPerDay, direction)
    }

    // MARK: - General

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordMeaningfulAction()
    }

    func recordMeaningfulAction() {
        updateStreak()
        totalSessionsCompleted += 1
        evaluateAchievements()
    }

    func recordPhraseViewed(_ phraseID: String) {
        guard !viewedPhraseIDs.contains(phraseID) else { return }
        viewedPhraseIDs.insert(phraseID)
        recordMeaningfulAction()
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func startSessionTimer(isActive: Bool) {
        sessionTimer?.invalidate()
        guard isActive else { return }
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.totalMinutesUsed += 1 }
        }
    }

    func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    private func checkPackingChecklistCompletion(tripId: UUID?) {
        let packingTasks = travelTasks.filter {
            $0.checklistType == ChecklistType.packing.rawValue &&
            (tripId == nil || $0.tripId == tripId)
        }
        guard !packingTasks.isEmpty else { return }
        let allDone = packingTasks.allSatisfy(\.isCompleted)
        guard allDone else { return }
        let signature = "packing-\(tripId?.uuidString ?? "global")-\(packingTasks.count)"
        guard !completedChecklistSignatures.contains(signature) else { return }
        completedChecklistSignatures.insert(signature)
        checklistsCompleted += 1
        evaluateAchievements()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), lastDay == yesterday {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    func evaluateAchievements() {
        for achievement in AchievementCatalog.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            guard achievement.meetsCondition(store: self) else { continue }
            achievementsUnlocked[achievement.id] = Date()
            enqueueAchievementBanner(achievement)
            FeedbackManager.success()
        }
    }

    private func enqueueAchievementBanner(_ achievement: AchievementDefinition) {
        if pendingAchievementBanner == nil {
            pendingAchievementBanner = achievement
        } else {
            achievementBannerQueue.append(achievement)
        }
    }

    func dismissAchievementBanner() {
        pendingAchievementBanner = nil
        if !achievementBannerQueue.isEmpty {
            pendingAchievementBanner = achievementBannerQueue.removeFirst()
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, defaults: defaults)
        destinations = Self.load(key: Keys.destinations, defaults: defaults) ?? []
        travelTasks = Self.load(key: Keys.travelTasks, defaults: defaults) ?? []
        selectedChecklistType = defaults.string(forKey: Keys.selectedChecklistType) ?? ChecklistType.packing.rawValue
        worldClocks = Self.load(key: Keys.worldClocks, defaults: defaults) ?? []
        phrasesViewed = defaults.integer(forKey: Keys.phrasesViewed)
        viewedPhraseIDs = Set(defaults.stringArray(forKey: Keys.viewedPhraseIDs) ?? [])
        checklistsCompleted = defaults.integer(forKey: Keys.checklistsCompleted)
        completedChecklistSignatures = Set(defaults.stringArray(forKey: Keys.completedChecklistSignatures) ?? [])
        trips = Self.load(key: Keys.trips, defaults: defaults) ?? []
        activeTripId = defaults.string(forKey: Keys.activeTripId).flatMap(UUID.init)
        travelDocuments = Self.load(key: Keys.travelDocuments, defaults: defaults) ?? []
        diaryEntries = Self.load(key: Keys.diaryEntries, defaults: defaults) ?? []
        destinationsAdded = destinations.count
        pendingAchievementBanner = nil
        achievementBannerQueue = []
        migrateLegacyDataIfNeeded()
        refreshActiveTrip()
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func saveDictionary(_ dict: [String: Date], key: String) {
        let stringKeyed = dict.mapValues { $0.timeIntervalSince1970 }
        guard let data = try? encoder.encode(stringKeyed) else { return }
        defaults.set(data, forKey: key)
    }

    private static func loadDictionary(key: String, defaults: UserDefaults) -> [String: Date] {
        guard let data = defaults.data(forKey: key),
              let raw = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else {
            return [:]
        }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
