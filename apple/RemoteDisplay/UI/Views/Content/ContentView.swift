//
//  ContentView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/08/2026.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack {
			HStack(alignment: .top) {
				ServicesView()
					.padding(.horizontal)
				DisplayView(text: "0123456789012345")
				ServicesView()
					.padding(.horizontal)
			}
			Spacer()
		}
		.padding()
		.shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.Display.displayBackground)
    }
}

#Preview {
	ContentView()
		.previewBackground()
		.environment(\.keyboardController, KeyboardController())
		.environment(\.serviceController, ServiceController.preview([
			(.Service.bluetooth, .unavailable),
			(.Service.cloud, .available),
			(.Service.wifi, .connecting)
		]))
}
