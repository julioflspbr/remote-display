//
//  ServiceIcons.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 27/09/2026.
//

import SwiftUI

extension Services {
	@ServiceActor
	protocol ServiceWithIcon: Services.Service {
		var icon: Image { get }
	}
}

extension Services.Status {
	var color: Color {
		switch self {
			case .unavailable, .disconnecting, .disconnected:
				Color.Service.unavailable
			case .searching, .available:
				Color.Service.available
			case .connecting, .connected:
				Color.Service.connected
			case .failure:
				Color.Service.failed
		}
	}

	var isTransient: Bool {
		switch self {
			case .disconnecting, .searching, .connecting:
				true
			case .unavailable, .disconnected, .available, .connected, .failure:
				false
		}
	}
}

extension Services.SmokeService: Services.ServiceWithIcon {
	var icon: Image {
		.Service.smoke
	}
}

#if DEBUG

extension Services.PreviewService: Services.ServiceWithIcon {
}

#endif
