//
//  SettingsView.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/22/26.
//


import ServiceManagement

// helper function to handle the registration
func updateLaunchAtLogin(enabled: Bool) {
    let service = SMAppService.mainApp
    
    do {
        if enabled {
            try service.register()
        } else {
            try service.unregister()
        }
    } catch {
        print("Failed to update launch at login: \(error.localizedDescription)")
    }
}

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var launchAtLogin = false // connect this to SMAppService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Form {
                Section(header: Text("GENERAL").sectionLabel()) {
                    Toggle("Launch at Startup", isOn: $launchAtLogin)
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#0088cc")))
                        .onChange(of: launchAtLogin) { oldValue, newValue in
                            updateLaunchAtLogin(enabled: newValue)
                        }
                        .onAppear {
                            // sync toggle state with the actual system status
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                }

                Section(header: Text("DANGER ZONE").sectionLabel()) {
                    Button(role: .destructive) {
                        store.resetAllData()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash.fill")
                            Text("Reset All Data")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
        }
        .frame(width: 250, height: 320)
    }
}

/*
#Preview {
    SettingsView()
        .environmentObject(AppStore())
}
*/
