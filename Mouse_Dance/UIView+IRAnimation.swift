//
//  UIView+IRAnimation.swift
//  irecruit
//
//  Created by Romain Cayzac on 17/01/2016.
//  Copyright © 2016 irecruit. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     Simple animation that will put a nice bounce/spring effect
     
     * duration: in sec
     * factor: you want your view size to. Put 2 if you want your view zoom x2 before comming back to normal

     - author: Romain C
     
    */
    
    func bounceZoom (_ duration : Double , factor : CGFloat, completion: (() -> Void)? = nil) {
        
        let group : CAAnimationGroup = CAAnimationGroup()
        
        let zoomOut:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomOut.fromValue = 1
        zoomOut.toValue = factor * 1.2
        zoomOut.duration = duration/3
        
        let zoomIn:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomIn.fromValue = factor * 1.2
        zoomIn.toValue = factor * 0.9
        zoomIn.duration = duration/3
        zoomIn.beginTime = duration/3
        
        let zoomOutBis:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomOutBis.fromValue = factor * 0.9
        zoomOutBis.toValue = factor
        zoomOutBis.duration = duration/3
        zoomOutBis.beginTime = 2*duration/3
        
        group.duration = duration
        group.animations = [zoomOut, zoomIn, zoomOutBis]
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(group, forKey: "bounceZoomAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            
            completion?()
            
        }
    }

    
    /**
     Simple animation that will put a nice bounce/spring effect
     
     * duration: in sec
     * factor: you want your view size to. Put 2 if you want your view zoom x2 before comming back to normal
     
     - author: Romain C
     
     */
    func bounce (_ duration : Double , factor : CGFloat, completion: (() -> Void)? = nil) {
        
        let group : CAAnimationGroup = CAAnimationGroup()
        
        let zoomOut:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomOut.fromValue = 1
        zoomOut.toValue = factor
        zoomOut.duration = duration/3
        
        let zoomIn:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomIn.fromValue = factor
        zoomIn.toValue = 0.8
        zoomIn.duration = duration/3
        zoomIn.beginTime = duration/3
        
        let zoomOutBis:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomOutBis.fromValue = 0.8
        zoomOutBis.toValue = 1
        zoomOutBis.duration = duration/3
        zoomOutBis.beginTime = 2*duration/3
        
        group.duration = duration
        group.animations = [zoomOut, zoomIn, zoomOutBis]
        group.isRemovedOnCompletion = false
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(group, forKey: "scaleSmallAnimation")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            
            completion?()
    
        }
    }
    
    /**
     Animate with a vibrate effect. Use to show user he has made an error
     
     * duration: in Float
     * factor: The size you want your view translate
     * repeatCount : if nil, the animation will loop for ever.
     
     - author: Romain C
     
     */
    func vibrateHorizontaly(_ duration : Double , factor : CGFloat ,repeatCount : Float = 0, completion: (() -> Void)? = nil) {
        
        let group : CAAnimationGroup = CAAnimationGroup()
        
        let moveRight:CABasicAnimation = CABasicAnimation(keyPath: "position")
        moveRight.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y))
        moveRight.toValue = NSValue(cgPoint: CGPoint(x: self.center.x * (1 + factor), y: self.center.y))
        moveRight.duration = duration/3
        
        let moveLeft:CABasicAnimation = CABasicAnimation(keyPath: "position")
        moveLeft.fromValue =  NSValue(cgPoint: CGPoint(x: self.center.x * (1 + factor), y: self.center.y))
        moveLeft.toValue = NSValue(cgPoint: CGPoint(x: self.center.x * (1 - factor), y: self.center.y))
        moveLeft.duration = duration/3
        moveLeft.beginTime = duration/3
        
        let moveBackToOrigin:CABasicAnimation = CABasicAnimation(keyPath: "position")
        moveBackToOrigin.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x * (1 - factor), y: self.center.y))
        moveBackToOrigin.toValue = NSValue(cgPoint: CGPoint(x: self.center.x, y: self.center.y))
        moveBackToOrigin.duration = duration/3
        moveBackToOrigin.beginTime = 2*duration/3
        
        group.duration = duration
        group.animations = [moveRight, moveLeft, moveBackToOrigin]
        group.isRemovedOnCompletion = false
        group.repeatCount = repeatCount
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(group, forKey: "vibrateHorizontaly")
    
    }
    
    /**
     Animate the view in a way that look like an heart
     
     * speed: in Int
     * factor: The size you want your view scale to when bitting
     * repeatBounce : if nil, the animation will loop for ever.
     
     - author: Romain C
     
     */
    func bounceLikeHeart (_ speed : Double , factor : CGFloat , repeatBounce : Float?) {
        
        let group : CAAnimationGroup = CAAnimationGroup()
        
        let zoomOut:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomOut.fromValue = 1.0
        zoomOut.toValue = factor
        zoomOut.duration = 1/(4 * speed)
        
        let zoomIn:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomIn.fromValue = factor
        zoomIn.toValue = 1.0
        zoomIn.duration = 1/(4 * speed)
        zoomIn.beginTime = 1/(4 * speed)
        
        let zoomOutBis:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomOutBis.fromValue = 1.0
        zoomOutBis.toValue = factor
        zoomOutBis.duration = 1/(4 * speed)
        zoomOutBis.beginTime = 2/(4 * speed)
        
        let zoomInBis:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        zoomInBis.fromValue = factor
        zoomInBis.toValue = 1.1
        zoomInBis.duration = 1/( 4 * speed)
        zoomInBis.beginTime = 3/(4 * speed)
        
        let end:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        end.fromValue = 1.1
        end.toValue = 1.0
        end.duration = 1/speed
        end.beginTime = 1/speed
        
        group.duration = 2/speed
        
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards;
        group.animations = [zoomOut,zoomIn,zoomOutBis,zoomInBis,end]
        group.repeatCount = (repeatBounce != nil ? repeatBounce! : 10000)
        self.layer.add(group, forKey: "bounceLikeHeart")
        
    }
 
    /**
     Animate the view to appear with a zoom effect
     
     * duration: in Int
     * factor: The size you want your view scale to before comming back to normal
     
     */
    func appearWithDuration(_ duration : Double, factor: CGFloat, completion: (() -> Void)? = nil){
        
        let group : CAAnimationGroup = CAAnimationGroup()
        
        let zoomOut:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        let zoomIn:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")

        zoomOut.fromValue = 0
        zoomOut.toValue = factor
        zoomOut.duration = duration/2
        zoomIn.fromValue = factor
        zoomIn.toValue = 1
        zoomIn.beginTime = duration/2
        zoomIn.duration = duration/2
        
        group.duration = duration
        group.animations = [zoomOut, zoomIn];

        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards;
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(group, forKey: "appear")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            
            completion?()
            
        }
    }
    
    /**
     Animate the view to disappear with a zoom effect
     
     * duration: in Int
     * factor: The size you want your view scale to before disapearing
     
     - author: Romain C
     
     */
    func disappearWithDuration(_ duration : Double, factor: CGFloat, completion: (() -> Void)? = nil){
    
        let group : CAAnimationGroup = CAAnimationGroup()
        
        let zoomOut:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        let zoomIn:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        zoomOut.fromValue = 1
        zoomOut.toValue = factor
        zoomOut.duration = duration/2
        zoomIn.fromValue = factor
        zoomIn.toValue = 0
        zoomIn.beginTime = duration/2
        zoomIn.duration = duration/2
        
        group.duration = duration
        group.animations = [zoomOut, zoomIn];
        
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards;
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(group, forKey: "disappear")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            
            completion?()
            
        }
        
    }
    
    /**
     Animate to move the transparancy nicely
     
     * duration: in Int
     * fromValue : starting value of transparancy
     
     - author: Romain C
     
     */
    func moveTransparency(_ duration : Double, fromValue : CGFloat, toValue : CGFloat,completion: (() -> Void)? = nil){
        
        let transparency:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        transparency.fromValue = fromValue
        transparency.toValue = toValue
        transparency.duration = duration
        
        transparency.isRemovedOnCompletion = false
        transparency.fillMode = kCAFillModeForwards;
        transparency.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(transparency, forKey: "disappear")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            completion?()
        }
    }
    
    func rotateInDegrees(_ duration: CFTimeInterval = 1.0,degreeAngle: Double ,completion: (() -> Void)? = nil) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(2*M_PI * (degreeAngle/360))
        rotateAnimation.duration = duration
   
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards;
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.add(rotateAnimation, forKey: "rotation")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            
            completion?()
        }
    }
    
}
