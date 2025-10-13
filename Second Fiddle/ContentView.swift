//
//  ContentView.swift
//  Second Fiddle
//
//  Created by Brian on 6/26/25.
//

import SwiftUI
import UniformTypeIdentifiers

let csvBookmarkKey = "csvFileBookmark"

struct Event: Identifiable, Hashable {
	let id = UUID()
	let perfNo: String
	let name: String
	let date: String
	let season: String
}

struct ContentView: View {
	@State private var events: [Event] = []
	@State private var searchText: String = ""
	@State private var selectedEvents: Set<Event> = []
	@State private var showingFileImporter = false
	@State private var csvFileURL: URL? = nil
	
	var body: some View {
		VStack {
			HStack {
				Button("Load CSV") {
					showingFileImporter = true
				}
				.fileImporter(
					isPresented: $showingFileImporter,
					allowedContentTypes: [.commaSeparatedText]
				) { result in
					switch result {
					case .success(let url):
						if url.startAccessingSecurityScopedResource() {
							defer { url.stopAccessingSecurityScopedResource() }
							
							loadCSV(from: url)
							csvFileURL = url
							
							do {
								let bookmarkData = try url.bookmarkData(
									options: .withSecurityScope,
									includingResourceValuesForKeys: nil,
									relativeTo: nil
								)
								UserDefaults.standard.set(bookmarkData, forKey: csvBookmarkKey)
							} catch {
								print("Error saving bookmark: \(error)")
							}
						} else {
							print("Failed to access security-scoped resource")
						}
						
					case .failure(let error):
						print("File load error: \(error)")
					}
				}
				
				Text(csvFileURL?.path ?? "No data source selected")
					.font(.caption)
					.foregroundColor(.secondary)
				//					.padding(.bottom, 4)
					.lineLimit(1)
					.truncationMode(.middle)
				
				Spacer()
				
				Button("Start Over") {
					selectedEvents.removeAll()
				}
				.keyboardShortcut("r", modifiers: [.command]) // ⌘R
			}
			.padding()
			
			TextField("Search events...", text: $searchText)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()
			
			ScrollView {
				LazyVStack(alignment: .leading) {
					ForEach(filteredEvents) { event in
						HStack(alignment: .top) {
							Toggle(isOn: Binding(
								get: { selectedEvents.contains(event) },
								set: { isSelected in
									if isSelected {
										selectedEvents.insert(event)
									} else {
										selectedEvents.remove(event)
									}
								}
							)) {
								VStack(alignment: .leading) {
									Text(event.name)
										.font(.headline)
									Text("perf_no: \(event.perfNo), \(event.date), \(event.season)")
										.font(.caption)
										.foregroundColor(.secondary)
								}
							}
							.toggleStyle(.checkbox)
						}
						.padding(.vertical, 2)
					}
				}
			}
			.frame(minHeight: 150)
			
			Divider()
			
			HStack {
				Text("Generated SQL:")
					.font(.headline)
					.padding(.top)
				
				Button("Copy to Clipboard") {
					NSPasteboard.general.clearContents()
					NSPasteboard.general.setString(generatedSQL, forType: .string)
				}
				.padding(.top, 8)
				.keyboardShortcut("c", modifiers: [.command]) // ⌘C
				
			}
			
			ScrollView {
				Text(generatedSQL)
					.font(.system(.body, design: .monospaced))
					.padding()
					.frame(minHeight: 100)
					.frame(maxWidth: .infinity, alignment: .leading)
					.textSelection(.enabled)
			}
			//			.background(Color(.secondarySystemBackground))
			.cornerRadius(8)
			.padding()
			.selectionDisabled(false)
			
			
		}
		.onAppear {
			restoreCSVIfAvailable()
		}
		.padding()
	}
	
	var filteredEvents: [Event] {
		let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard !trimmed.isEmpty else {
			return events
		}
		
		// Scoped season search
		if trimmed.lowercased().hasPrefix("season:") {
			let targetSeason = trimmed.dropFirst("season:".count).trimmingCharacters(in: .whitespaces)
			return events.filter {
				$0.season.localizedCaseInsensitiveContains(targetSeason)
			}
		}
		
		// Determine if wildcards are used
		if trimmed.contains("*") || trimmed.contains("?") {
			let pattern = wildcardToRegex(trimmed)
			return events.filter {
				$0.name.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil ||
				$0.season.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
			}
		} else {
			// Plain substring match (faster, friendlier)
			return events.filter {
				$0.name.localizedCaseInsensitiveContains(trimmed) ||
				$0.season.localizedCaseInsensitiveContains(trimmed)
			}
		}
	}
	
	func wildcardToRegex(_ pattern: String) -> String {
		// Escape all regex characters, then convert wildcards
		let escaped = NSRegularExpression.escapedPattern(for: pattern)
		let regexPattern = escaped
			.replacingOccurrences(of: "\\*", with: ".*")   // * → match any characters
			.replacingOccurrences(of: "\\?", with: ".")    // ? → match single character
		return "^" + regexPattern + "$"                    // anchor to full match
	}
	
	var generatedSQL: String {
		let perfNos = selectedEvents.map { $0.perfNo }.joined(separator: ", ")
		guard !perfNos.isEmpty else { return "-- Select events to generate SQL" }
		
		return """
  SELECT DISTINCT a.customer_no 
  FROM V_CUSTOMER_WITH_PRIMARY_GROUP a WITH(NOLOCK) 
  JOIN(
   SELECT a1.customer_no 
   FROM vs_ticket_history a1 WITH (NOLOCK) 
   WHERE a1.perf_no IN(\(perfNos))) AS e ON e.customer_no = a.customer_no 
  WHERE 1 = 1
  """
	}
	
	func restoreCSVIfAvailable() {
		guard let bookmarkData = UserDefaults.standard.data(forKey: csvBookmarkKey) else {
			print("No saved bookmark.")
			return
		}
		
		var isStale = false
		
		do {
			let resolvedURL = try URL(
				resolvingBookmarkData: bookmarkData,
				options: [.withSecurityScope],
				bookmarkDataIsStale: &isStale
			)
			
			if resolvedURL.startAccessingSecurityScopedResource() {
				defer { resolvedURL.stopAccessingSecurityScopedResource() }
				loadCSV(from: resolvedURL)
				csvFileURL = resolvedURL
			} else {
				print("Failed to access security-scoped resource")
			}
			
			if isStale {
				print("Bookmark is stale — re-saving.")
				// 🔁 Re-save fresh bookmark
				let newBookmark = try resolvedURL.bookmarkData(
					options: .withSecurityScope,
					includingResourceValuesForKeys: nil,
					relativeTo: nil
				)
				UserDefaults.standard.set(newBookmark, forKey: csvBookmarkKey)
			}
			
		} catch {
			print("Failed to resolve bookmark: \(error)")
		}
	}
	
	func parseCSVLine(_ line: String) -> [String] {
		var result: [String] = []
		var currentField = ""
		var insideQuotes = false

		for char in line {
			if char == "\"" {
				insideQuotes.toggle()
			} else if char == "," && !insideQuotes {
				result.append(currentField)
				currentField = ""
			} else {
				currentField.append(char)
			}
		}
		result.append(currentField)
		return result
	}

	func loadCSV(from url: URL) {
		do {
			print("✅ Attempting to read file at \(url.path)")
			let contents = try String(contentsOf: url)
			print("✅ File read succeeded")

			let rows = contents.components(separatedBy: .newlines).dropFirst()
			events = rows.compactMap { (line) -> Event? in
				guard !line.isEmpty else { return nil }
				let columns = parseCSVLine(line)
				guard columns.count >= 4 else {
					print("❌ Skipped malformed row: \(line)")
					return nil
				}

				return Event(
					perfNo: columns[0].trimmingCharacters(in: .whitespaces),
					name: columns[1].trimmingCharacters(in: .whitespaces),
					date: columns[2].trimmingCharacters(in: .whitespaces),
					season: columns[3].trimmingCharacters(in: .whitespaces)
				)
			}
			print("✅ Loaded \(events.count) events")
		} catch {
			print("❌ Failed to load CSV: \(error)")
		}
	}
}

#Preview {
	ContentView()
}
