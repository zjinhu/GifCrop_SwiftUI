import SwiftUI

public struct RangeSlider: View {
    @Environment(\.rangeSliderStyle) private var style
    @State private var dragOffset: CGFloat?
    
    private var configuration: RangeSliderStyleConfiguration
    
    public var body: some View {
        self.style.makeBody(configuration:
            self.configuration.with(dragOffset: self.$dragOffset)
        )
    }
}

extension RangeSlider {
    init(_ configuration: RangeSliderStyleConfiguration) {
        self.configuration = configuration
    }
}

extension RangeSlider {
    public init<V>(
        range: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 0.0...1.0,
        step: V.Stride = 0.001,
        distance: ClosedRange<V> = 0.0 ... .infinity,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
        self.init(
            RangeSliderStyleConfiguration(
                range: Binding(
                    get: { CGFloat(range.wrappedValue.clamped(to: bounds).lowerBound) ... CGFloat(range.wrappedValue.clamped(to: bounds).upperBound) },
                    set: { range.wrappedValue = V($0.lowerBound) ... V($0.upperBound) }
                ),
                bounds: CGFloat(bounds.lowerBound) ... CGFloat(bounds.upperBound),
                step: CGFloat(step),
                distance: CGFloat(distance.lowerBound) ... CGFloat(distance.upperBound),
                onEditingChanged: onEditingChanged,
                dragOffset: .constant(0)
            )
        )
    }
}

extension RangeSlider {
    public init<V>(
        range: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 0...1,
        step: V.Stride = 1,
        distance: ClosedRange<V> = 0 ... .max,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V : FixedWidthInteger, V.Stride : FixedWidthInteger {
        self.init(
            RangeSliderStyleConfiguration(
                range: Binding(
                    get: { CGFloat(range.wrappedValue.clamped(to: bounds).lowerBound) ... CGFloat(range.wrappedValue.clamped(to: bounds).upperBound) },
                    set: { range.wrappedValue = V($0.lowerBound) ... V($0.upperBound) }
                ),
                bounds: CGFloat(bounds.lowerBound) ... CGFloat(bounds.upperBound),
                step: CGFloat(step),
                distance: CGFloat(distance.lowerBound) ... CGFloat(distance.upperBound),
                onEditingChanged: onEditingChanged,
                dragOffset: .constant(0)
            )
        )
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {

        HorizontalRangeSlidersPreview()
            .previewDisplayName("Horizontal Range Sliders")
    
    }
}

private struct HorizontalRangeSlidersPreview: View {

    @State var range6 = 1.0...3.0
    
    var body: some View {
        VStack {

            RangeSlider(range: $range6, in: 1.0 ... 3.0)
                .cornerRadius(8)
                .frame(height: 128)
                .rangeSliderStyle(
                    HorizontalRangeSliderStyle(
                        track:
                            HorizontalRangeTrack(
                                view: LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .leading, endPoint: .trailing),
                                mask: RoundedRectangle(cornerRadius: 10)
                            )
                            .background(Color.secondary.opacity(0.25)),
                        lowerThumb: HalfCapsule()
                            .foregroundColor(.white)
                            .shadow(radius: 3),
                        upperThumb: HalfCapsule()
                            .rotation(Angle(degrees: 180))
                            .foregroundColor(.white)
                            .shadow(radius: 3),
                        lowerThumbSize: CGSize(width: 16, height: 64),
                        upperThumbSize: CGSize(width: 16, height: 64)
                    )
                )
        }
        .padding()
        .onChange(of: range6) { newValue in
            print("\(range6)")
        }
    }
}

public struct HalfCapsule: View, InsettableShape {
    private let inset: CGFloat

    public func inset(by amount: CGFloat) -> HalfCapsule {
        HalfCapsule(inset: self.inset + amount)
    }
    
    public func path(in rect: CGRect) -> Path {
        let width = rect.size.width - inset * 2
        let height = rect.size.height - inset * 2
        let heightRadius = height / 2
        let widthRadius = width / 2
        let minRadius = min(heightRadius, widthRadius)
        return Path { path in
            path.move(to: CGPoint(x: width, y: 0))
            path.addArc(center: CGPoint(x: minRadius, y: minRadius), radius: minRadius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180), clockwise: true)
            path.addArc(center: CGPoint(x: minRadius, y: height - minRadius), radius: minRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
            path.addLine(to: CGPoint(x: width, y: height))
            path.closeSubpath()
        }.offsetBy(dx: inset, dy: inset)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            self.path(in: CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height))
        }
    }
    
    public init(inset: CGFloat = 0) {
        self.inset = inset
    }
}
