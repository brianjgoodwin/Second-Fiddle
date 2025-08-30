//
//  HelpView.swift
//  Second Fiddle
//
//  Created by Brian on 6/27/25.
//


import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Second Fiddle Help")
                    .font(.title)
                    .padding(.bottom, 8)

                Group {
                    Text("🗂 Loading Event Data")
                        .font(.headline)
                    Text("Click the 'Load CSV' button and select a file containing your event data. The app will remember this file the next time you launch it.")

                    Text("🔍 Searching")
                        .font(.headline)
                    Text("Use the search bar to filter events by title.")

                    Text("☑️ Selecting Events")
                        .font(.headline)
                    Text("Use the checkboxes to select events to include in your SQL query.")

                    Text("📝 SQL Output")
                        .font(.headline)
                    Text("As you select events, a SQL query is automatically generated. Use the 'Copy to Clipboard' button to copy it the results.")
                }

                Divider().padding(.vertical)

                Text("Made with ❤️ by Brian Goodwin")
					.font(.footnote)
					.foregroundColor(.secondary)
				 Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
	HelpView()
}
