//
//  ContentView.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                EventList()
                    .tabItem {
                        Label("Events", systemImage: "tray.full.fill")
                    }
            }
            .toolbarBackground(Color(UIColor.systemGray5), for: .tabBar)
            .toolbarBackgroundVisibility(.visible, for: .tabBar)

            Rectangle()
                .fill(Color(UIColor.systemGray3))
                .frame(height: 1)
                .edgesIgnoringSafeArea(.bottom)
                .offset(y: -49)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.modelContainer)
}
