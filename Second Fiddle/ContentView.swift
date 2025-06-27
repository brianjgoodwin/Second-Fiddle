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
						do {
							loadCSV(from: url)
							csvFileURL = url

							// Save bookmark for persistence
							let bookmarkData = try url.bookmarkData(
								options: .withSecurityScope,
								includingResourceValuesForKeys: nil,
								relativeTo: nil
							)
							UserDefaults.standard.set(bookmarkData, forKey: csvBookmarkKey)
						} catch {
							print("Error saving bookmark: \(error)")
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
									Text("perf_no: \(event.perfNo), \(event.date)")
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
			.frame(minHeight: 300)
			
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
					.frame(maxWidth: .infinity, alignment: .leading)
			}
//			.background(Color(.secondarySystemBackground))
			.cornerRadius(8)
			.padding()
			
			
		}
		.onAppear {
				restoreCSVIfAvailable()
			}
		.padding()
	}
	
	var filteredEvents: [Event] {
		if searchText.isEmpty {
			return events
		} else {
			return events.filter {
				$0.name.localizedCaseInsensitiveContains(searchText)
			}
		}
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
				csvFileURL = resolvedURL // ✅ move this inside the same scope
			} else {
				print("Failed to access security-scoped resource")
			}

			if isStale {
				print("Bookmark is stale — consider re-saving it.")
			}
		} catch {
			print("Failed to resolve bookmark: \(error)")
		}
	}
	
	func loadCSV(from url: URL) {
		do {
			let contents = try String(contentsOf: url)
			let rows = contents.components(separatedBy: .newlines).dropFirst()
			events = rows.compactMap { line in
				let columns = line.components(separatedBy: ",")
				guard columns.count >= 3 else { return nil }
				return Event(perfNo: columns[0], name: columns[1], date: columns[2])
			}
		} catch {
			print("Failed to load CSV: \(error)")
		}
	}
}

#Preview {
	ContentView()
}







