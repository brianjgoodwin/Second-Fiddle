//
//  Second_FiddleApp.swift
//  Second Fiddle
//
//  Created by Brian on 6/26/25.
//

import SwiftUI

@main
struct Second_FiddleApp: App {
	@State private var aboutWindow: NSWindow?
	@State private var helpWindow: NSWindow?
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onAppear {
					// restore CSV file on launch
					// this assumes your ContentView struct has this method available
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
						NotificationCenter.default.post(name: .init("RestoreCSV"), object: nil)
					}
				}
				.frame(minWidth: 600, minHeight: 500)
			
		}
		.commands {
			CommandGroup(replacing: .appInfo) {
				Button("About Second Fiddle") {
					showAboutWindow()
				}
			}
			
			CommandGroup(replacing: .help) {
				Button("Second Fiddle Help") {
					showHelpWindow()
				}
			}
		}
	}
	
	func showAboutWindow() {
		if aboutWindow == nil {
			let hostingView = NSHostingView(rootView: AboutView())
			let window = NSWindow(
				contentRect: NSRect(x: 0, y: 0, width: 320, height: 240),
				styleMask: [.titled, .closable],
				backing: .buffered,
				defer: false
			)
			window.center()
			window.title = "About Second Fiddle"
			window.isReleasedWhenClosed = false
			window.contentView = hostingView
			aboutWindow = window
		}
		
		aboutWindow?.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}
	
	func showHelpWindow() {
		if helpWindow == nil {
			let hostingView = NSHostingView(rootView: HelpView())
			let window = NSWindow(
				contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
				styleMask: [.titled, .closable, .resizable],
				backing: .buffered,
				defer: false
			)
			window.center()
			window.title = "Second Fiddle Help"
			window.isReleasedWhenClosed = false
			window.contentView = hostingView
			helpWindow = window
		}
		
		helpWindow?.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}
}
