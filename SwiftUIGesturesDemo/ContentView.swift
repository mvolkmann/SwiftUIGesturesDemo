import SwiftUI

extension View {
    /// Supports conditional view modifiers.
    /// For example, .if(price > 100) { view in view.background(.orange) }
    /// The concrete type of Content can be any type
    /// that conforms to the View protocol.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        // This cannot be replaced by a ternary expression.
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ContentView: View {
    // @GestureState private var deltaRotation = Angle.zero
    @GestureState private var deltaScale = 1.0
    @State private var canDrag = false
    @State private var currentDrag = CGSize.zero
    @State private var currentRotation = Angle.zero
    @State private var currentScale = 1.0
    @State private var deltaDrag = CGSize.zero

    private var drag: some Gesture {
        return DragGesture()
            .onChanged { deltaDrag = $0.translation }
            .onEnded {
                currentDrag.width += $0.translation.width
                currentDrag.height += $0.translation.height
                deltaDrag = .zero
            }
    }

    private var rotation: some Gesture {
        /* Before iOS 17
         RotationGesture()
             .updating($deltaRotation) { value, state, _ in
                 state = value
             }
             .onEnded { currentRotation += $0 }
         */
        // After iOS 17
        RotateGesture()
            .onChanged { value in currentRotation = value.rotation }
    }

    private var scale: some Gesture {
        /* Before iOS 17
         MagnificationGesture()
             .updating($deltaScale) { value, state, _ in
                 state = value
             }
             .onEnded { currentScale *= $0 }
         */
        // After iOS 17
        MagnifyGesture()
            .updating($deltaScale) { value, state, _ in
                state = value.magnification
            }
            .onEnded { currentScale *= $0.magnification }
    }

    var body: some View {
        ZStack {
            VStack {
                Toggle("Can Drag", isOn: $canDrag)
                Spacer()
            }

            let offsetX = currentDrag.width + deltaDrag.width
            let offsetY = currentDrag.height + deltaDrag.height

            // TODO: Why doesn't it work to select a gesture like this?
            // let gesture: any Gesture =
            //    canDrag ? drag : rotation.simultaneously(with: scale)

            Rectangle()
                .fill(.red)
                .frame(width: 100, height: 100)
                .scaleEffect(currentScale * deltaScale)
                // .rotationEffect(currentRotation + deltaRotation)
                .rotationEffect(currentRotation)
                .offset(x: offsetX, y: offsetY)
                // Using position instead of offset did not help.
                // .position(x: offsetX, y: offsetY)

                // TODO: Why doesn't this work?
                // .gesture(gesture)

                // A workaround for the above is to
                // conditionally apply view modifiers.
                .if(canDrag) { view in view.gesture(drag) }
                .if(!canDrag) { view in
                    // TODO: Why does this only work if
                    // TODO: the shape has not been dragged or
                    // TODO: has been dragged back to the center?
                    view.gesture(rotation.simultaneously(with: scale))
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
