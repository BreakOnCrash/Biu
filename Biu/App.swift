//
//  App.swift
//  Biu
//
//  Created by whoami on 2024/3/6.
//

import SwiftUI

let sourceCodeURL = URL(string: "https://github.com/BreakOnCrash/Biu")!

@main
struct BiuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizabilityContentSize()
    }
}

struct AlertMessage: Identifiable {
    var id: String {message}
    var message: String
}


struct ContentView: View {
    @State var disableReSign: Bool = false
    
    @State private var openOptions: Bool = false
    @State private var targetApp = "Select"
    @State private var injectDylib = "Select"
    @State private var alertMsg: AlertMessage?
    
    var body: some View {
        
        VStack {
            VStack {
                HStack{
                    Form {
                        HStack{
                            Label("Application", systemImage: "app")
                            Button(targetApp){
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = false
                                panel.canChooseDirectories = false
                                if panel.runModal() == .OK {
                                    self.targetApp = panel.url?.path ?? "<none>"
                                }
                            }
                        }
                        HStack{
                            Label("Dylib", systemImage: "filemenu.and.selection")
                                .padding(.trailing, 34)
                            Button(injectDylib){
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = false
                                panel.canChooseDirectories = false
                                if panel.runModal() == .OK {
                                    self.injectDylib = panel.url?.path ?? "<none>"
                                }
                            }
                        }
                        HStack{
                            Button("Biu🔫") {
                                BiuInject.staticInject(appPath: targetApp,
                                                          dylibPath: injectDylib){ ret, msg in
                                    alertMsg = AlertMessage(message: msg)
                                    if ret{
                                        if !self.disableReSign{
                                            BiuInject.reSign(appPath: targetApp)
                                        }
                                        alertMsg = AlertMessage(message: "inject dylib success")
                                    }
                                }
                            }
                            .background(.pink)
                            .cornerRadius(5)
                            .alert(item: $alertMsg) {message in
                                        Alert(
                                            title: Text(""),
                                            message: Text(message.message)
                                        )
                                    }
                        }
                    }
                }
                Divider()
                HStack {
                    QLImage("Biu").frame(width: 30,height: 30)
                    Text(
                        """
                        Made by 巴斯.zznQ
                        """
                    )
                    Spacer()
                    Image(systemName: "gear")
                        .contentShape(Rectangle())
                        .onTapGesture { openOptions = true }
                        .popover(isPresented: $openOptions) { options }
                }
                .font(.footnote)
                .tint(.green)
                
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    // From https://github.com/Lakr233/FixTim
    // 感谢佬，我是没看懂先搬过来。
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    @State var toggleIds = UUID()
    var options: some View {
        ForEach([toggleIds], id: \.self) { _ in
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Disable ReSign", isOn: $disableReSign)
                Divider()
                Text("Get Source Code & License")
                    .underline()
                    .onTapGesture { NSWorkspace.shared.open(sourceCodeURL) }
            }
            .frame(minWidth: 233)
        }
        .onReceive(timer) { _ in toggleIds = .init() }
        .font(.body)
        .padding()
    }
}

#Preview {
    ContentView()
}
