import SwiftUI

private let imgSize = 100.0
private let halfImgSize = imgSize / 2.0

struct ContentView: View {
    @GestureState private var deltaRotation = Angle.zero
    @GestureState private var deltaScale = 1.0

    @State private var currentDrag = CGSize.zero
    @State private var currentScale = 1.0
    @State private var currentRotation = Angle.zero
    @State private var deltaDrag = CGSize.zero
    @State private var imageSize = CGSize.zero
    @State private var isLongPressed = false
    @State private var isTapped = false

    private var drag: some Gesture {
        return DragGesture()
            .onChanged { deltaDrag = $0.translation }
            .onEnded {
                currentDrag.width += $0.translation.width
                currentDrag.height += $0.translation.height
                deltaDrag = .zero

                // Ensure that the dragged item remains completely in view.
                let screenSize = UIScreen.main.bounds.size
                let itemSize = imgSize * currentScale
                let maxX = screenSize.width - itemSize
                let maxY = screenSize.height - itemSize
                if currentDrag.width < 0 { currentDrag.width = 0 }
                if currentDrag.width > maxX { currentDrag.width = maxX }
                if currentDrag.height < 0 { currentDrag.height = 0 }
                if currentDrag.height > maxY { currentDrag.height = maxY }
            }
    }

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
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                Text("In a Preview or the Simulator, hold down")
                Text("the option key and drag to zoom and rotate.")
                Text("currentDrag.width = \(currentDrag.width)")
                Text("deltaDrag.width = \(deltaDrag.width)")
                // Text("currentScale = \(currentScale)")
                // Text("deltaScale = \(deltaScale)")
                // Text("currentRotation = \(currentRotation.degrees)")
                // Text("deltaRotation = \(deltaRotation.degrees)")
                Spacer()
            }
            .padding()

            VStack(alignment: .leading) {
                let x = halfImgSize + currentDrag.width + deltaDrag.width
                let y = halfImgSize + currentDrag.height + deltaDrag.height
                let _ = print("x = \(x), y = \(y)")
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: imgSize)

                    .position(x: x, y: y)
                    // .scaleEffect(isTapped ? 0.7 : 1)
                    // .animation(.easeInOut(duration: 0.5), value: isTapped)

                    // The `gesture` view modifier can be used to listen for any
                    // kind of gesture.
                    // In addition, some gestures have a dedicated view
                    // modifier,
                    // for example, `onLongPressGesture` and `onTapGesture`.

                    // `minimumDuration` to be considered a long-press is 0.5
                    // seconds.
                    // A different duration can be passed to
                    // `onLongPressGesture`.
                    // .onLongPressGesture { isLongPressed.toggle() }

                    // This is the short way to listen for tap gestures.
                    // .onTapGesture { isTapped.toggle() }

                    // This is the long way to listen for tap gestures.
                    // To require a double-tap, pass `count: 2` to `TapGesture`.
                    // .gesture(TapGesture().onEnded { isTapped.toggle() })

                    .rotationEffect(currentRotation + deltaRotation)
                    .scaleEffect(currentScale * deltaScale)
                    // Note use of `.simultaneously` to support multiple
                    // gestures.
                    .gesture(
                        drag.simultaneously(
                            with: magnification.simultaneously(
                                with: rotation
                            )
                        )
                    )

                    .foregroundStyle(isLongPressed ? .red : .blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow.opacity(0.2))
            .border(.red, width: 5)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
