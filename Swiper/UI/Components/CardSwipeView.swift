//
//  CardSwipeView.swift
//  Swiper
//

import SwiftUI

public struct CardSwipeView<Item: Identifiable & Hashable, Content: View>: View {
    private enum ActiveDragAxis {
        case horizontal
        case vertical
    }

    @State private var poppedItem: Item?
    @State private var poppedOffset: CGPoint = .zero
    @State private var poppedDirection: CardSwipeDirection = .idle
    @State private var lastDirection: CardSwipeDirection = .idle
    @State private var offset: CGPoint = .zero
    @State private var thresholdPassed = false
    @State private var activeDragAxis: ActiveDragAxis?

    @Binding private var items: [Item]
    @Binding private var selectedItem: Item?
    @Binding private var popTrigger: CardSwipeDirection?

    private var configuration = CardSwipeConfiguration()
    private var callbacks = CardSwipeCallbacks<Item>()

    private let content: (Item, _ progress: CGFloat, _ direction: CardSwipeDirection) -> Content

    public init(
        items: Binding<[Item]>,
        selectedItem: Binding<Item?> = .constant(nil),
        popTrigger: Binding<CardSwipeDirection?> = .constant(nil),
        @ViewBuilder content: @escaping (Item, _ progress: CGFloat,
                                         _ direction: CardSwipeDirection) -> Content
    ) {
        self._items = items
        self._selectedItem = selectedItem
        self._popTrigger = popTrigger
        self.content = content
    }

    public var body: some View {
        ZStack {
            ForEach(
                Array(items.prefix(configuration.visibleCount).enumerated()),
                id: \.element.id
            ) { index, item in
                let progress = index == 0
                    ? min(abs(offset.x) / configuration.triggerThreshold, 1)
                    : 0

                content(item, progress, lastDirection)
                    .modifier(
                        CardSwipeEffect(
                            index: index,
                            offset: offset,
                            triggerThreshold: configuration.triggerThreshold
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay { poppedCard }
        .simultaneousGesture(swipeGesture)
        .onAppear {
            selectedItem = items.first
        }
        .onChange(of: popTrigger ?? .idle) { _, newValue in
            guard newValue != .idle else { return }
            lastDirection = newValue
            popItem(notifyCaller: false)
            popTrigger = nil
        }
    }

    @ViewBuilder
    private var poppedCard: some View {
        if let poppedItem {
            content(
                poppedItem,
                min(abs(poppedOffset.x) / configuration.triggerThreshold, 1),
                poppedDirection
            )
            .modifier(
                CardSwipeEffect(
                    index: 0,
                    offset: poppedOffset,
                    triggerThreshold: configuration.triggerThreshold
                )
            )
            .id(poppedItem.id)
            .onAppear {
                animatePoppedItem()
            }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: configuration.minimumDistance)
            .onChanged(onDragChanged)
            .onEnded { value in
                onDragEnded(value)
            }
    }

    private func onDragChanged(_ value: DragGesture.Value) {
        if activeDragAxis == nil {
            activeDragAxis = axis(for: value.translation)
        }

        guard activeDragAxis == .horizontal else {
            resetDragOffset()
            return
        }

        let translation = value.translation.width
        let correctionValue = correction(for: translation)
        let offsetX = translation + correctionValue
        let offsetY = configuration.animateOnYAxes ? value.translation.height : 0
        offset = CGPoint(x: offsetX, y: offsetY)

        let newDirection = CardSwipeDirection(offset: offsetX)
        if lastDirection != newDirection {
            lastDirection = newDirection
        }

        let thresholdReached = abs(offsetX) >= configuration.triggerThreshold
        if thresholdReached != thresholdPassed {
            thresholdPassed = thresholdReached
            if thresholdReached {
                callbacks.onThresholdPassed?()
            }
        }
    }

    private func onDragEnded(_ value: DragGesture.Value) {
        defer {
            activeDragAxis = nil
            thresholdPassed = false
        }

        guard activeDragAxis == .horizontal || axis(for: value.translation) == .horizontal else {
            withAnimation(.bouncy) { offset = .zero }
            return
        }

        if abs(offset.x) < configuration.triggerThreshold {
            withAnimation(.bouncy) { offset = .zero }
        } else if !items.isEmpty {
            popItem()
        }
    }

    private func axis(for translation: CGSize) -> ActiveDragAxis {
        abs(translation.width) >= abs(translation.height) ? .horizontal : .vertical
    }

    private func resetDragOffset() {
        guard offset != .zero || thresholdPassed else { return }
        offset = .zero
        thresholdPassed = false
    }

    private func correction(for translation: CGFloat) -> CGFloat {
        if translation >= configuration.minimumDistance {
            -configuration.minimumDistance
        } else if translation <= -configuration.minimumDistance {
            configuration.minimumDistance
        } else {
            -translation
        }
    }

    private func animatePoppedItem() {
        let multiplier: CGFloat = poppedDirection == .left ? -1 : 1
        let screenWidth = UIScreen.current?.bounds.width ?? CardSwipeLayout.cardWidth * 2

        withAnimation(.spring(duration: CardSwipeLayout.popAnimationDuration)) {
            poppedOffset.x += screenWidth * multiplier
        } completion: {
            poppedItem = nil
            poppedOffset = .zero
            if items.isEmpty {
                callbacks.onNoMoreCardsLeft?()
            }
        }
    }

    private func popItem(notifyCaller: Bool = true) {
        guard !items.isEmpty else { return }
        poppedOffset = offset
        poppedDirection = lastDirection
        poppedItem = items.removeFirst()
        selectedItem = items.first
        if let poppedItem, notifyCaller {
            callbacks.onSwipeEnd?(poppedItem, lastDirection)
        }
        offset = .zero
        thresholdPassed = false
    }
}

public extension CardSwipeView {
    func configure(
        threshold: CGFloat,
        minimumDistance: CGFloat,
        animateOnYAxes: Bool
    ) -> CardSwipeView {
        var view = self
        view.configuration.triggerThreshold = threshold
        view.configuration.minimumDistance = minimumDistance
        view.configuration.animateOnYAxes = animateOnYAxes
        return view
    }

    func onSwipeEnd(
        _ newValue: @escaping @MainActor (Item, CardSwipeDirection) -> Void
    ) -> CardSwipeView {
        var view = self
        view.callbacks.onSwipeEnd = newValue
        return view
    }

    func onNoMoreCardsLeft(_ newValue: @escaping @MainActor () -> Void) -> CardSwipeView {
        var view = self
        view.callbacks.onNoMoreCardsLeft = newValue
        return view
    }

    func onThresholdPassed(_ newValue: @escaping @MainActor () -> Void) -> CardSwipeView {
        var view = self
        view.callbacks.onThresholdPassed = newValue
        return view
    }
}
