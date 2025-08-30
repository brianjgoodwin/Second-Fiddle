//
//  AboutView.swift
//  Second Fiddle
//
//  Created by Brian on 6/27/25.
//


import SwiftUI

struct AboutView: View {
	var body: some View {
		VStack(spacing: 12) {
			Image(nsImage: NSApp.applicationIconImage)
				.resizable()
				.frame(width: 64, height: 64)
				.cornerRadius(12)
			
			Text("Second Fiddle")
				.font(.title2.bold())
			
			Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
				.font(.subheadline)
				.foregroundColor(.secondary)
			
			Divider()
			
			Spacer()
			
			Text("Second Fiddle is a personal SQL-building tool for internal use.\n\n© 2025 Brian Goodwin")
				.multilineTextAlignment(.center)
				.font(.footnote)
				.foregroundColor(.secondary)
			
			Spacer()
		}
		.frame(width: 250, height: 250)
		.padding()
	}
}

#Preview {
	AboutView()
}
