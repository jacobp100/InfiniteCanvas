import SwiftUI
import UIKit

class InfiniteCanvas: UIView, UIGestureRecognizerDelegate {
    @Invalidating(.display) var contentOffset: CGPoint = .zero
    @Invalidating(.display) var zoom: CGFloat = 1

    var minZoom: CGFloat = 0.1
    var maxZoom: CGFloat = 10.0

    private class ContentOffsetItem: NSObject, UIDynamicItem {
        weak var parent: InfiniteCanvas?

        var center: CGPoint {
            get { parent?.contentOffset ?? .zero }
            set { parent?.contentOffset = newValue }
        }

        // Not used
        var bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        var transform = CGAffineTransform.identity
    }

    private let animator = UIDynamicAnimator()
    private let frictionDelegate = ContentOffsetItem()

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerHandlers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerHandlers()
    }

    private func registerHandlers() {
        frictionDelegate.parent = self

        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(didPan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(didPinch))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animator.removeAllBehaviors()
    }

    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self)
            contentOffset = CGPoint(x: contentOffset.x + translation.x / zoom,
                                    y: contentOffset.y + translation.y / zoom)
            gesture.setTranslation(.zero, in: self)
        case .ended:
            let velocity = gesture.velocity(in: self)
            let friction = UIDynamicItemBehavior(items: [frictionDelegate])
            friction.resistance = 2
            friction.addLinearVelocity(CGPoint(x: velocity.x / zoom, y: velocity.y / zoom),
                                       for: frictionDelegate)
            friction.isAnchored = false
            animator.addBehavior(friction)
        case .possible, .began, .cancelled, .failed:
            break
        @unknown default:
            break
        }
    }

    @objc private func didPinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let zoomBefore = zoom
            zoom = min(max(zoom * gesture.scale, minZoom), maxZoom)
            let delta = zoom / zoomBefore
            contentOffset = CGPoint(x: contentOffset.x / delta,
                                    y: contentOffset.y / delta)
            gesture.scale = 1
        case .possible, .began, .ended, .cancelled, .failed:
            break
        @unknown default:
            break
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        UIColor.systemBackground.setFill()
        UIBezierPath(rect: bounds).fill()

        let center = CGPoint(x: bounds.midX + contentOffset.x * zoom,
                             y: bounds.midY + contentOffset.y * zoom)
        let path = UIBezierPath(arcCenter: center,
                                radius: 10 * zoom,
                                startAngle: 0,
                                endAngle: 2 * .pi,
                                clockwise: false)

        UIColor.red.setFill()
        path.fill()
    }
}

struct InfiniteCanvasView: UIViewRepresentable {
    typealias UIViewType = InfiniteCanvas

    func makeUIView(context: Context) -> InfiniteCanvas {
        let canvas = InfiniteCanvas()
        return canvas
    }

    func updateUIView(_ uiView: InfiniteCanvas, context: Context) {

    }
}
