//
//  Animations.swift
//  Ahmed Zaghloul
//
//  Created by Ahmed Zaghloul on 3/5/18.
//  Copyright © 2018 Ahmed Zaghloul. All rights reserved.
//

import UIKit

public typealias AnimatableCompletion = () -> Void
public typealias AnimatableExecution = () -> Void

public extension UIView {
    
    /**
     Plays the rotate out animation
     
     - parameter completion: when the animation completes
     */
    public func playRotateOutAnimation(WithDuration duration:TimeInterval = 0,AndDelay delay:TimeInterval = 0,_ completion: AnimatableCompletion? = nil)
    {
//        if let imageView = self.imageView{
        
            /**
             Sets the animation with duration delay and completion
             
             - returns:
             */
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: UIViewAnimationOptions(), animations: {
                
                //Sets a simple rotate
                let rotateTranform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.99))
                //Mix the rotation with the zoom out animation
                self.transform = rotateTranform.concatenating(self.getZoomOutTranform())
                //Removes the animation
                self.alpha = 0
                
            }, completion: { finished in
                
                self.removeFromSuperview()
                
                completion?()
            })
            
//        }
    }
    
    /**
     Plays a wobble animtion and then zoom out
     
     - parameter completion: completion
     */
    public func playWoobleAnimation(WithDuration duration:TimeInterval,WithDelay delay:TimeInterval,_ completion: AnimatableCompletion? = nil) {
        
//        if let imageView = self.imageView{
        
            let woobleForce = 0.5
            
            animateLayer({
                let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
                rotation.values = [0, 0.3 * woobleForce, -0.3 * woobleForce, 0.3 * woobleForce, 0]
                rotation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                rotation.isAdditive = true
                
                let positionX = CAKeyframeAnimation(keyPath: "position.x")
                positionX.values = [0, 30 * woobleForce, -30 * woobleForce, 30 * woobleForce, 0]
                positionX.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                positionX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                positionX.isAdditive = true
                
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [rotation, positionX]
                animationGroup.duration = CFTimeInterval(duration/2)
                animationGroup.beginTime = CACurrentMediaTime() + CFTimeInterval(delay/2)
                animationGroup.repeatCount = 2
                self.layer.add(animationGroup, forKey: "wobble")
            }, completion: {
                
                self.playZoomOutAnimation(WithDuration: duration, completion)
            })
            
//        }
    }
    
    /**
     Plays the swing animation and zoom out
     
     - parameter completion: completion
     */
    public func playSwingAnimation(WithDuration duration:TimeInterval,WithDelay delay:TimeInterval,_ completion: AnimatableCompletion? = nil)
    {
        let swingForce = 0.8
        
        animateLayer({
            
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
            animation.values = [0, 0.3 * swingForce, -0.3 * swingForce, 0.3 * swingForce, 0]
            animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            animation.duration = CFTimeInterval(duration/2)
            animation.isAdditive = true
            animation.repeatCount = 2
            animation.beginTime = CACurrentMediaTime() + CFTimeInterval(delay/3)
            self.layer.add(animation, forKey: "swing")
            
        }, completion: {
            self.playZoomOutAnimation(WithDuration: duration, completion)
        })
    }
    
    /**
     Plays the swing animation and zoom out
     
     - parameter completion: completion
     */
    public func playSwingAnimationWithoutZoomOut(WithDuration duration:TimeInterval,WithDelay delay:TimeInterval,_ completion: AnimatableCompletion? = nil)
    {
        let swingForce = 0.8
        
        animateLayer({
            
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
            animation.values = [0, 0.3 * swingForce, -0.3 * swingForce, 0.3 * swingForce, 0]
            animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            animation.duration = CFTimeInterval(duration/2)
            animation.isAdditive = true
            animation.repeatCount = 2
            animation.beginTime = CACurrentMediaTime() + CFTimeInterval(delay/3)
            self.layer.add(animation, forKey: "swing")
            
        }, completion: {

        })
    }

    
    /**
     Plays the pop animation with completion
     
     - parameter completion: completion
     */
    public func playPopAnimation(WithDuration duration:TimeInterval,WithDelay delay:TimeInterval,_ completion: AnimatableCompletion? = nil)
    {
//        if let imageView = self.imageView{
        
            let popForce = 0.5
            
            animateLayer({
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [0, 0.2 * popForce, -0.2 * popForce, 0.2 * popForce, 0]
                animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.duration = CFTimeInterval(duration/2)
                animation.isAdditive = true
                animation.repeatCount = 2
                animation.beginTime = CACurrentMediaTime() + CFTimeInterval(delay/2)
                self.layer.add(animation, forKey: "pop")
            }, completion: {
                self.playZoomOutAnimation(WithDuration: duration, completion)
            })
//        }
    }
    
    /**
     Plays the zoom out animation with completion
     
     - parameter completion: completion
     */
    public func playZoomOutAnimation(WithDuration duration:TimeInterval,_ completion: AnimatableCompletion? = nil)
    {
//        if let imageView =  imageView
//        {
            let growDuration: TimeInterval =  duration * 0.3
            
            UIView.animate(withDuration: growDuration, animations:{
                
                self.transform = self.getZoomOutTranform()
                self.alpha = 0
                
                //When animation completes remote self from super view
            }, completion: { finished in
                
                self.removeFromSuperview()
                
                completion?()
            })
//        }
    }
    
    
    
    /**
     Retuns the default zoom out transform to be use mixed with other transform
     
     - returns: ZoomOut fransfork
     */
    fileprivate func getZoomOutTranform() -> CGAffineTransform
    {
        let zoomOutTranform: CGAffineTransform = CGAffineTransform(scaleX: 20, y: 20)
        return zoomOutTranform
    }
    
    
    // MARK: - Private
    fileprivate func animateLayer(_ animation: AnimatableExecution, completion: AnimatableCompletion? = nil) {
        
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock { completion() }
        }
        animation()
        CATransaction.commit()
    }
    
    
    /**
     Plays the heatbeat animation with completion
     
     - parameter completion: completion
     */
    public func playHeartBeatAnimation(WithDuration duration:TimeInterval,WithDelay delay:TimeInterval,minimumBeats:Int = 1,heartAttack:Bool?,_ completion: AnimatableCompletion? = nil)
    {
//        if let imageView = self.imageView {
        
            let popForce = 0.8
            
            animateLayer({
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [0, 0.1 * popForce, 0.015 * popForce, 0.2 * popForce, 0]
                animation.keyTimes = [0, 0.25, 0.35, 0.55, 1]
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.duration = CFTimeInterval(duration/2)
                animation.isAdditive = true
                animation.repeatCount = Float(minimumBeats > 0 ? minimumBeats : 1)
                animation.beginTime = CACurrentMediaTime() + CFTimeInterval(delay/2)
                self.layer.add(animation, forKey: "pop")
            }, completion: { [weak self] in
                if heartAttack ?? true {
                    self?.playZoomOutAnimation(WithDuration: duration, completion)
                } else {
                    self?.playHeartBeatAnimation(WithDuration: duration, WithDelay: delay, heartAttack: true, completion)
                }
            })
//        }
    }
}
