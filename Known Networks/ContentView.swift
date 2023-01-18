//
//  ContentView.swift
//  Known Networks
//
//  Created by Hornbeck on 1/18/23.
//

import SwiftUI

struct ContentView: View {
    @State var Log = ""
    @State var ShowKnownNetworks = GetShowKnownNetworks()
    var body: some View {
        Form {
            if !Log.isEmpty {
                Section {
                    Text(Log)
                }
            }
            Section(footer: Text("Reboot Device To Take Effect")) {
                Toggle(isOn: $ShowKnownNetworks) {
                    Text("Show Known Networks")
                }
            }
        }
        .onChange(of: ShowKnownNetworks) { newValue in
            Log = SetShowKnownNetworks(newValue)
        }
    }
}

//Run RootHelper
@discardableResult func RootHelper(_ Command: String) -> String {
    return String(spawnRoot(Bundle.main.path(forAuxiliaryExecutable: "RootHelper") ?? "", Command.split(separator: " ")).dropLast())
}

//Get current value of kWiFiShowKnownNetworks
func GetShowKnownNetworks() -> Bool {
    let Plist = NSDictionary(contentsOfFile: "/var/preferences/SystemConfiguration/com.apple.wifi.plist")!
    return (Plist.allKeys as! [String]).contains("kWiFiShowKnownNetworks") ? Plist.value(forKey: "kWiFiShowKnownNetworks") as! Bool : false
}

//Set value of kWiFiShowKnownNetworks
func SetShowKnownNetworks(_ Value: Bool) -> String {
    let PlistURL = URL(fileURLWithPath: "/var/preferences/SystemConfiguration/com.apple.wifi.plist")
    let Plist = NSMutableDictionary(contentsOf: PlistURL)!
    Plist.setValue(Value, forKey: "kWiFiShowKnownNetworks")
    Plist.write(toFile: "\(AppDataDir())/Temp.plist", atomically: true)
   return RootHelper("mv \(AppDataDir())/Temp.plist /var/preferences/SystemConfiguration/com.apple.wifi.plist")
}

func AppDataDir() -> String {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
}
