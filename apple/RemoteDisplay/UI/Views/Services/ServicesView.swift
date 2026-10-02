//
//  ServicesView.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 26/09/2026.
//

import SwiftUI

struct ServicesView: View {
	@State private var viewModel = ServicesViewModel()
	@Environment(\.serviceController) private var serviceController

	var body: some View {
		VStack {
			ForEach(viewModel.services) { service in
				ServiceButton(image: service.icon, color: service.status.color, isTransient: service.status.isTransient)
					.frame(width: 30, height: 30)
			}
		}
		.onChange(of: serviceController, initial: true) {
			Task {
				await self.viewModel.setServiceController(self.serviceController)
			}
		}
	}
}

#Preview {
	ServicesView()
		.previewBackground()
		.environment(\.serviceController, ServiceController.preview([
			(.Service.bluetooth, .unavailable),
			(.Service.cloud, .available),
			(.Service.wifi, .connecting),
			(.Service.smoke, .searching)
		]))
}
