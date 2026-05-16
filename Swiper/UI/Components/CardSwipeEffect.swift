//
//  CardSwipeEffect.swift
//  Swiper
//

import SwiftUI

struct CardSwipeEffect: ViewModifier {
    let index: Int
    let offset: CGPoint
    let triggerThreshold: CGFloat

    func body(content: Content) -> some View {
        let params = parameters()
        return content
            .opacity(params.opacity)
            .scaleEffect(params.scale)
            .offset(x: params.offsetX, y: params.offsetY)
            .rotationEffect(params.angle, anchor: .bottom)
            .zIndex(params.zIndex)
    }

    private func parameters() -> EffectParams {
        let progress = min(abs(offset.x) / triggerThreshold, 1)
        switch index {
        case 0:
            return EffectParams(
                opacity: 1,
                scale: 1,
                offsetX: offset.x,
                offsetY: offset.y,
                angle: Angle(degrees: Double(offset.x) / Double(CardSwipeLayout.rotationDivisor)),
                zIndex: 4
            )
        case 1:
            return EffectParams(
                opacity: 1,
                scale: CardSwipeLayout.card1BaseScale + progress * CardSwipeLayout.scaleStep,
                offsetX: 0,
                offsetY: (1 - progress) * CardSwipeLayout.card1YOffset,
                angle: .zero,
                zIndex: 3
            )
        case 2:
            return EffectParams(
                opacity: 1,
                scale: CardSwipeLayout.card2BaseScale + progress * CardSwipeLayout.scaleStep,
                offsetX: 0,
                offsetY: CardSwipeLayout.card2YOffset - progress * CardSwipeLayout.card2YDelta,
                angle: .zero,
                zIndex: 2
            )
        case 3:
            return EffectParams(
                opacity: Double(progress),
                scale: CardSwipeLayout.card3BaseScale + progress * CardSwipeLayout.scaleStep,
                offsetX: 0,
                offsetY: CardSwipeLayout.card3YOffset - progress * CardSwipeLayout.card3YDelta,
                angle: .zero,
                zIndex: 1
            )
        default:
            return EffectParams(
                opacity: 0,
                scale: 1,
                offsetX: 0,
                offsetY: 0,
                angle: .zero,
                zIndex: 0
            )
        }
    }
}

private struct EffectParams {
    let opacity: Double
    let scale: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let angle: Angle
    let zIndex: Double
}
