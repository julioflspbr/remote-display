//
//  ContentView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/08/2026.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		DisplayView(text: "0123456789012345")
			.padding(20)
			.background(.displayBackground)
    }
}

#Preview {
    ContentView()
}
