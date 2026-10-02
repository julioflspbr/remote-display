//
//  ServiceButton.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 24/09/2026.
//

import SwiftUI

struct ServiceButton: View {
	let image: Image
	let color: Color
	let isTransient: Bool

	var body: some View {
		if isTransient {
			ServiceButtonContent(image: image, color: color)
				.animation(.linear.repeatForever(autoreverses: true), value: color)
		} else {
			ServiceButtonContent(image: image, color: color)
		}
	}
}

struct ServiceButtonContent: View {
	let image: Image
	let color: Color

	var body: some View {
		VStack {
			image
				.resizable()
				.scaledToFit()
				.padding(5)
				.foregroundStyle(color)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.aspectRatio(1, contentMode: .fit)
		.background {
			RoundedRectangle(cornerRadius: 2)
				.stroke(color, lineWidth: 1)
		}
	}
}

#Preview {
	struct ServiceButtonSteadyPreview: View {
		let image: Image
		let color: Color

		var body: some View {
			ServiceButton(image: image, color: color, isTransient: false)
		}
	}

	struct ServiceButtonTransientPreview: View {
		let image: Image
		let colorOne: Color
		let colorTwo: Color

		@State private var current: Color

		init(image: Image, colorOne: Color, colorTwo: Color) {
			self.image = image
			self.colorOne = colorOne
			self.colorTwo = colorTwo
			_current = State(initialValue: colorOne)
		}

		var body: some View {
			ServiceButton(image: image, color: current, isTransient: true)
				.onAppear {
					current = colorTwo
				}
		}
	}

	let size: CGFloat = 30

	return Grid {
		GridRow {
			Group {
				ServiceButtonSteadyPreview(image: .Service.smoke, color: .Service.unavailable)
				ServiceButtonTransientPreview(image: .Service.smoke, colorOne: .Service.unavailable, colorTwo: .Service.available)
			}
			.frame(width: size, height: size)
		}

		GridRow {
			Group {
				ServiceButtonSteadyPreview(image: .Service.wifi, color: .Service.failed)
				ServiceButtonTransientPreview(image: .Service.wifi, colorOne: .Service.available, colorTwo: .Service.connected)
			}
			.frame(width: size, height: size)
		}

		GridRow {
			Group {
				ServiceButtonSteadyPreview(image: .Service.bluetooth, color: .Service.connected)
				ServiceButtonSteadyPreview(image: .Service.cloud, color: .Service.failed)
			}
			.frame(width: size, height: size)
		}
	}
	.previewBackground()
}
