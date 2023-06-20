import SwiftUI

struct ContentView: View {
    @GestureState private var deltaRotation = Angle.zero
    @GestureState private var deltaScale = 1.0

    @State private var currentScale = 1.0
    @State private var currentRotation = Angle.zero

    private var magnification: some Gesture {
        return MagnificationGesture()
            .updating($deltaScale) { value, state, _ in
                state = value
            }
            .onEnded { currentScale *= $0 }
    }

    private var rotation: some Gesture {
        return RotationGesture()
            .updating($deltaRotation) { value, state, _ in
                state = value
            }
            .onEnded { currentRotation += $0 }
    }

    var body: some View {
        VStack {
            Text("currentScale = \(currentScale)")
            Text("deltaScale = \(deltaScale)")
            Text("currentRotation = \(currentRotation.degrees)")
            Text("deltaRotation = \(deltaRotation.degrees)")
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(currentRotation + deltaRotation)
                .scaleEffect(currentScale * deltaScale)
                // Note use of `.simultaneously` to support multiple gestures.
                .gesture(magnification.simultaneously(with: rotation))
                .foregroundStyle(.tint)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
