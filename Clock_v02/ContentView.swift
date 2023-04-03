//
//  ContentView.swift
//  Clock_v02
//
//  Created by Max Franz Immelmann on 4/2/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                
                let angles = getAngels(for: timeline.date)
                let rect = CGRect(origin: .zero, size: size)
                let r = min(size.width, size.height) / 2
                
                let border = r / 25
                let hLength = r / 2.5
                let mLength = r / 1.5
                let sLength = r * 1.05
                
                ctx.stroke(Circle()
                    .inset(by: border / 2)
                    .path(in: rect),
                           with: .color(.primary),
                           lineWidth: border)
                
                ctx.translateBy(x: rect.midX, y: rect.midY)
                
                drawHours(in: ctx, radius: r)
                drawDate(in: ctx, radius: r)
                drawMarks(in: ctx, radius: r)
                
                drawHand(in: ctx,
                         radius: r,
                         length: mLength,
                         angle: angles.minute)
                
                drawHand(in: ctx,
                         radius: r,
                         length: hLength,
                         angle: angles.hour)
                
                drawSecondsHand(in: ctx,
                          radius: r,
                          length: sLength,
                          angle: angles.second)
                
                let innerRing = r / 6
                let ringWidth = r / 40
                
                let inner = CGRect(x: -innerRing / 2,
                                   y: -innerRing / 2,
                                   width: innerRing,
                                   height: innerRing)
                ctx.stroke(
                    Circle()
                        .path(in: inner),
                    with: .color(.primary),
                    lineWidth: ringWidth
                )
                
                let centerPiece = Circle()
                    .path(in: inner.insetBy(dx: ringWidth, dy: ringWidth))
                ctx.blendMode = .clear
                ctx.fill(centerPiece, with: .color(.white))
                
                ctx.blendMode = .normal
                
                ctx.stroke(centerPiece,
                           with: .color(.orange),
                           lineWidth: ringWidth)
            }
        }
    }
}


func getAngels(for date:Date) -> (hour: Angle,
                                  minute: Angle,
                                  second: Angle) {
    let parts = Calendar.current.dateComponents([.hour,
                                                 .minute,
                                                 .second,
                                                 .nanosecond],
                                                from: .now)
    let h = Double(parts.hour ?? 0)
    let m = Double(parts.minute ?? 0)
    let s = Double(parts.second ?? 0)
    let n = Double(parts.nanosecond ?? 0)
    
    var hour = Angle.degrees(30 * (h + m / 60) + 180)
    var minute = Angle.degrees(6 * (m + s / 60) + 180)
    var second = Angle.degrees(6 * (s + n / 1_000_000_000) + 180)
    
    if hour.radians == .pi { hour = .radians(3.14158) }
    if minute.radians == .pi { minute = .radians(3.14158) }
    if second.radians == .pi { second = .radians(3.14158) }
    
    return (hour, minute, second)
}

func drawHand(in context: GraphicsContext,
              radius: Double,
              length: Double,
              angle: Angle) {
    
    let width = radius / 30
    
    let stalk = Rectangle()
        .rotation(angle, anchor: .top)
        .path(in: CGRect(x: -width / 2,
                         y: 0,
                         width: width,
                         height: length))
    
    context.fill(stalk, with: .color(.primary))
    
    let hand = Capsule()
        .offset(x: 0, y: radius / 5)
        .rotation(angle, anchor: .top)
        .path(in: CGRect(x: -width,
                         y: 0,
                         width: width * 2,
                         height: length))
    
    context.fill(hand, with: .color(.primary))
}

func drawSecondsHand(in context: GraphicsContext,
              radius: Double,
              length: Double,
              angle: Angle) {
    
    
    let sWidth = radius / 25
    
    let secondLine = Capsule()
        .offset(x: 0, y: -radius / 6)
        .rotation(angle, anchor: .top)
        .path(in: CGRect(x: -sWidth / 2,
                         y: 0,
                         width: sWidth,
                         height: length))
    
    context.fill(secondLine, with: .color(.orange))
}

func drawHours(in context: GraphicsContext, radius: Double) {
    let textSize = radius * 0.25
    let textOffset = radius * 0.75
    
    
    for hour in 1...12 {
        let text = Text(String(hour)).font(.system(size: textSize)).bold()
        
        let point = CGPoint(x: 0, y: -textOffset)
            .applying(CGAffineTransform(rotationAngle: Double(hour) * .pi / 6))
        
        context.draw(text, at: point)
    }
}

func drawMarks(in context: GraphicsContext, radius: Double) {
    let minuteOffset = radius * 0.95
    let minuteWidth = radius / 20
    
    for minute in 0..<60 {
        let minuteAngle = Double(minute) * .pi / 30
        // set line width to 3 for every 5th minute mark
        let lineWidth: CGFloat = minute % 5 == 0 ? 3 : 1
        
        let minutePath = Path { path in
            path.move(to: CGPoint(
                x: cos(minuteAngle) * minuteOffset,
                y: sin(minuteAngle) * minuteOffset))
            path.addLine(to: CGPoint(
                x: cos(minuteAngle) * (minuteOffset - minuteWidth),
                y: sin(minuteAngle) * (minuteOffset - minuteWidth)))
        }
        
        context.stroke(minutePath, with: .color(Color.primary), lineWidth: lineWidth)
    }
}

func drawDate(in context: GraphicsContext, radius: Double) {
    let textSize = radius / 8
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    let dateString = formatter.string(from: Date())
    let text = Text(dateString).font(.system(size: textSize)).bold()
    
    let point = CGPoint(x: radius / 2.75,
                        y: -radius / 6
    )
    context.draw(text,
                 at: CGPoint(x: point.x,
                             y: point.y))
    
    let rectangle = Path(CGRect(
        x: radius / 10,
        y: -radius / 4,
        width: radius / 2,
        height: radius / 6))
    
    
    context.stroke(rectangle,
                   with: .color(.primary),
                   lineWidth: 2)
     
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
