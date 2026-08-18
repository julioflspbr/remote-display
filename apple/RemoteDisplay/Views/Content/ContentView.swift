//
//  ContentView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/08/2026.
//

import SwiftUI

struct ContentView: View {
	@State var text: String = "0123456789012345"

    var body: some View {
		DisplayView(text: $text)
			.padding(20)
			.background(.displayBackground)
    }
}

#Preview {
    ContentView()
}
