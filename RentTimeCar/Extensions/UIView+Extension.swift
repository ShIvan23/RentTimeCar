//
//  UIView+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import UIKit

extension UIView {
    static var identifier: String {
        return String(describing: self)
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}


public typealias TapGestureClosure = () -> Void

class TapGestureClosureWrapper: NSObject {
    let closure: TapGestureClosure
    init(_ closure: @escaping TapGestureClosure) {
        self.closure = closure
    }
}

extension UIView {
    
    private struct AssociatedKeys {
        static var tapGestureClosure: Void?
    }
    
    private var tapGestureClosure: TapGestureClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.tapGestureClosure) as? TapGestureClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            var tapGestureClosure: TapGestureClosureWrapper?
            if let newValue = newValue {
                tapGestureClosure = TapGestureClosureWrapper(newValue)
            }
            objc_setAssociatedObject(self, &AssociatedKeys.tapGestureClosure, tapGestureClosure, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult
    func addTapGestureClosure(_ closure: @escaping TapGestureClosure) -> UITapGestureRecognizer {
        isUserInteractionEnabled = true
        tapGestureClosure = closure
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        addGestureRecognizer(tapGestureRecognizer)
        return tapGestureRecognizer
    }
    
    func updateTapGestureClosure(_ closure: @escaping TapGestureClosure) {
        tapGestureClosure = closure
    }
    
    @discardableResult
    func removeAllTapGestureClosures() -> [UIGestureRecognizer] {
        isUserInteractionEnabled = false
        
        let removedRecognizers = gestureRecognizers?.compactMap({ recognizer -> UIGestureRecognizer in
            removeGestureRecognizer(recognizer)
            return recognizer
        }) ?? []
        
        return removedRecognizers
    }
    
    @objc
    private func tapGestureAction() {
        guard let tapGestureClosure = tapGestureClosure else { return }
        tapGestureClosure()
    }
}
