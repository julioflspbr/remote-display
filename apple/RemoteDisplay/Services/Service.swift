//
//  Service.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 11/09/2026.
//

enum Services {
	@ServiceActor
	protocol Service: Sendable, AnyObject {
		var status: Status { get }
		func search() async throws
		func connect() async throws
		func disconnect() async throws
	}

	@ServiceActor
	protocol ServiceDelegate: AnyObject {
		func serviceDidUpdateStatus(_ service: Service)
	}
}
