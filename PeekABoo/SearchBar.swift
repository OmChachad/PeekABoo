//
//  SearchBar.swift
//  PeekABoo
//
//  Created by Om Chachad on 28/11/25.
//


import UIKit
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            InternalSearchBar(text: $text, onSearchButtonClicked: onSearchButtonClicked)
                .frame(width: min(100.0, proxy.size.width / 2.0))
//                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct InternalSearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = CircularSearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Ask about what's in front of you..."
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> SearchBarCoordinator { SearchBarCoordinator(self) }
}

class SearchBarCoordinator: NSObject, UISearchBarDelegate {
    var parent: InternalSearchBar

    init(_ searchBar: InternalSearchBar) {
        self.parent = searchBar
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        parent.text = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        parent.onSearchButtonClicked()
        searchBar.resignFirstResponder()
    }
}

class CircularSearchBar: UISearchBar {
    private var didObserveSubviews = false
    private let desiredCornerRadius = 22.0
    private var observedLayers = NSHashTable<CALayer>.weakObjects()
    
    deinit {
        // We need to manually track and remove CALayers we add observers for, the OS seemingly does not handle this properly for us, perhaps because we're adding observers for sublayers as well and there's timing issues with deinitialization?
        // (Also don't store strong references to layers or we can introduce reference cycles)
        for object in observedLayers.objectEnumerator() {
            guard let layer = object as? CALayer else { continue }
            layer.removeObserver(self, forKeyPath: "cornerRadius")
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
     
        // Adding to window
        guard !didObserveSubviews else { return }
        didObserveSubviews = true
        observeSubviews(self)
        hideImageViews(self)
    }
    
    private func hideImageViews(_ view: UIView) {
        if let imageView = view as? UIImageView {
            imageView.alpha = 0.0
        }
        
        view.subviews.forEach { hideImageViews($0) }
    }
        
    func observeSubviews(_ view: UIView) {
        if !observedLayers.contains(view.layer) {
            view.layer.addObserver(self, forKeyPath: "cornerRadius", options: [.new], context: nil)
            observedLayers.add(view.layer)
        }
        
        view.subviews.forEach { observeSubviews($0) }
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "cornerRadius" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let layer = object as? CALayer else { return }
        guard layer.cornerRadius != desiredCornerRadius else { return }
        
        layer.cornerRadius = desiredCornerRadius
    }
}
