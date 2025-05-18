//
//  ContentView.swift
//  lockin
//
//  Created by Savina Jabbo on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ConceptListView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
            StudyTabView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Study")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}
