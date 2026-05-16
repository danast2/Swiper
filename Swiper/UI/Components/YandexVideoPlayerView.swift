//
//  YandexVideoPlayerView.swift
//  Swiper
//
//  Created by Codex on 26.04.2026.
//

import SwiftUI
import WebKit

@MainActor
struct YandexVideoPlayerView: UIViewRepresentable {
    let url: URL

    final class Coordinator {
        var requestedURL: URL?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        dispatchPrecondition(condition: .onQueue(.main))

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.userContentController.addUserScript(hdrLimitScript)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = true
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .black
        if #available(iOS 15.0, *) {
            webView.underPageBackgroundColor = .black
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        dispatchPrecondition(condition: .onQueue(.main))

        guard context.coordinator.requestedURL != url else { return }
        context.coordinator.requestedURL = url
        webView.load(URLRequest(url: url))
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        dispatchPrecondition(condition: .onQueue(.main))

        webView.stopLoading()
        coordinator.requestedURL = nil
    }

    private var hdrLimitScript: WKUserScript {
        let source = """
        const style = document.createElement('style');
        style.textContent = `
            @supports (dynamic-range-limit: standard) {
                *, html, body, video, img, canvas, picture {
                    dynamic-range-limit: standard !important;
                }
            }
        `;
        document.documentElement.appendChild(style);
        """

        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}

@MainActor
struct DeferredYandexVideoPlayerView: View {
    let url: URL

    @State private var shouldLoad = false

    var body: some View {
        ZStack {
            Color.black
            if shouldLoad {
                YandexVideoPlayerView(url: url)
            }
        }
        .task(id: url) {
            shouldLoad = false
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            shouldLoad = true
        }
    }
}
