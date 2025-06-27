//
//  Second_FiddleApp.swift
//  Second Fiddle
//
//  Created by Brian on 6/26/25.
//

import SwiftUI

@main
struct Second_FiddleApp: App {
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
        }
    }
}
