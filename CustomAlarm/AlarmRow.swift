//
//  AlarmRow.swift
//  CustomAlarm
//
//  Created by パソコンさん on 2022/06/27.
//

import SwiftUI
import CoreData

struct AlarmRow: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AlarmData.alarmTime, ascending: true)],
        animation: .default)
    private var items: FetchedResults<AlarmData>
    
    // CoreData番号
    var offsets: Int
    
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack{
                VStack(alignment: .leading){
                    HStack(alignment: .bottom){
                        // 12時間表記ならtrue、24時間表記ならfalseを返すTimejudge関数で判別
                        if(Timejudge()) {
                            Text(timeText(dt:items[offsets].alarmTime!,AmPm: true))
                                .font(.system(size: 35))
                                .fontWeight(.light)
                                .brightness(items[offsets].onOff ? 0.0 : -0.5) // valueの真偽で文字の明るさを変更
                                .padding(.bottom,5)
                            Text(timeText(dt:items[offsets].alarmTime!,AmPm: false))
                                .font(.system(size: 50))
                                .fontWeight(.light)
                                .brightness(items[offsets].onOff ? 0.0 : -0.5) // valueの真偽で文字の明るさを変更
                        } else {
                            Text(items[offsets].alarmTime!.formatted(.dateTime.hour().minute()))
                                .font(.system(size: 50))
                                .fontWeight(.light)
                                .brightness(items[offsets].onOff ? 0.0 : -0.5) // valueの真偽で文字の明るさを変更
                        }
                    }
                    Text(items[offsets].label ?? "アラーム")
                        .font(.body)
                        .fontWeight(.light)
                        .brightness(items[offsets].onOff ? 0.0 : -0.5) // valueの真偽で文字の明るさを変更
                } // VStack ここまで
                Spacer()
            } // HStack ここまで
            Toggle(isOn: Binding<Bool>(
                get: { items[offsets].onOff },
                set: {
                    items[offsets].onOff = $0
                    try? self.viewContext.save()
                })) {
                
            } // Toggle ここまで
//                .onChange(of: items[offsets].onOff) { OnOff in
//                    let spanTime = alarmValue.alarmTime.timeIntervalSince(Date())
//                    if(OnOff) {
//                        alarmValue.startCountUp(willTime: alarmValue.alarmTime, url: URL(string: alarmValue.sound),moreDay: spanTime <= 0)
//                    } else {
//                        alarmValue.stop()
//                    }
//                }
                
                if(items[offsets].tagColor == "white") {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .offset(x: -60, y: 0) // toggleに隣接する位置に表示
                        .opacity(items[offsets].onOff ? 1.0 : 0.5) // 透明度調整（0.0~1.0)
                    
                } else if(items[offsets].tagColor == "red") {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                        .offset(x: -60, y: 0) // toggleに隣接する位置に表示
                        .opacity(items[offsets].onOff ? 1.0 : 0.5) // 透明度調整（0.0~1.0)
                } else if(items[offsets].tagColor == "blue") {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .offset(x: -60, y: 0) // toggleに隣接する位置に表示
                        .opacity(items[offsets].onOff ? 1.0 : 0.5) // 透明度調整（0.0~1.0)
                } else if(items[offsets].tagColor == "yellow") {
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 30, height: 30)
                        .offset(x: -60, y: 0) // toggleに隣接する位置に表示
                        .opacity(items[offsets].onOff ? 1.0 : 0.5) // 透明度調整（0.0~1.0)
                }
            } // ZStackここまで
        } // body ここまで
    }

// 12時間表示かどうかを判定 12時間表示:true,24時間表示:false
func Timejudge() -> Bool {
    let dateFormmater = DateFormatter()
    dateFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss"

    // 12時間表記の際に date == nil となる.
    guard dateFormmater.date(from: "2000-01-01 10:00:00") != nil else { return true }
    
    return false
}

// 午前午後だけ、時間だけを返す関数
func timeText(dt: Date, AmPm:Bool) -> String{
    let formatter = DateFormatter()
    if(AmPm) {
        formatter.dateFormat = "a"
    } else {
        formatter.dateFormat = "h:mm"
    }
    return formatter.string(from: dt)

    
}

struct AlarmRow_Previews: PreviewProvider {
    static var previews: some View {
        AlarmRow(offsets: 0).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.fixed(width: 400, height: 81))
    }
}
