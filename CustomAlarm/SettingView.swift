//
//  SettingView.swift
//  CustomAlarm
//
//  Created by パソコンさん on 2022/06/27.
//

import SwiftUI
import CoreData

struct SettingView: View {
    // AlarmData管理用のcontext
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: AlarmData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AlarmData.alarmTime, ascending: true)],
                  predicate: nil
    )private var items: FetchedResults<AlarmData>

     //モーダル表示を閉じるdismiss()を使うための変数
    @Environment(\.presentationMode) var presentationMode

    // 
    @ObservedObject var dataModel: DataModel
    
    var body: some View {
//        Text("Hello")
        // 【解決】モーダル遷移のページ上部に謎の余白発生（NavigationLinkとList追加後に発生)
        NavigationView{
            VStack {
                // 「アラームを編集」を真ん中に描写するためのZStack
                ZStack(alignment: .center){
                    HStack{
                        // キャンセルボタンを押したらアラーム設定のデータを更新しない
                        Button("キャンセル") {
                            dataModel.isNewData = false
                            didTapDismissButton()
                        }
                        // アラーム専用の橙色に設定
                        .foregroundColor(Color("DarkOrange"))
                        .padding()

                        Spacer()

                        // 【未】完了ボタンを押したらアラーム設定のデータを変更する
                        Button("保存") {
                            if(searchIndex() >= 0) {
                                viewContext.delete(items[searchIndex()])
                            }
                            dataModel.updateItem = AlarmData(context: viewContext)
//                            dataModel.rewrite(dataModel: dataModel,context: viewContext)
                            dataModel.writeData(context: viewContext)
                            didTapDismissButton()
                        }
                        // アラーム専用の橙色に設定
                        .foregroundColor(Color("DarkOrange"))
                        .font(.headline)
                        .padding()

                    } // 画面上部のHStack ここまで

                    Text("アラームを編集")
                        .foregroundColor(Color.white)
                        .font(.headline)
                        .padding()
                } // ZStackここまで

                // 時間設定（ホイール）
                DatePicker("",
                           selection: $dataModel.alarmTime,
                           displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                List{

                    // 【移動】RepeatDaySetting.swiftへ プッシュ遷移
                    //                    NavigationLink(destination: RepeatDaySetting(alarmId: alarmId, AlarmDate: $AlarmDate)) {
                    //                    Text("繰り返し")
                    //                        .foregroundColor(Color.white)
                    //
                    //                    Spacer()
                    //
                    //                    Text(textWeekDay())
                    //                        .foregroundColor(Color.white)
                    //                        .opacity(0.5)
                    //
                    //                }

                    // 【移動】LabelSetting.swiftへ プッシュ遷移
//                    NavigationLink(destination: LabelSetting()) {
//                        Text("ラベル")
//                            .foregroundColor(Color.white)
//
//                        Spacer()
//
//                        Text(AlarmDate.label)
//                            .foregroundColor(Color.white)
//                            .opacity(0.5)
//                    }


                    // 【移動】SoundSetting.swiftへ プッシュ遷移
//                    NavigationLink(destination: SoundSetting()){
//                        Text("サウンド")
//                            .foregroundColor(Color.white)
//
//                        Spacer()
//
//                        Text("朝ココ")
//                            .foregroundColor(Color.white)
//                            .opacity(0.5)
//                    }
                    HStack{
                        // スヌーズのON/OFF切り替え
                        Text("スヌーズ")
                            .foregroundColor(Color.white)
                        Toggle(isOn: $dataModel.snooze) {

                        }
                    }

                    // 【移動】IdentifyTagSetting.swiftへ プッシュ遷移
//                    NavigationLink(destination: colorTagSetting(alarmId: alarmId, AlarmDate: $AlarmDate)){
//                        Text("タグ")
//                            .foregroundColor(Color.white)
//
//                        Spacer()
//
//                        Text(textTagColor())
//                            .foregroundColor(Color.white)
//                            .opacity(0.5)
//                    } // NavigationLinkここまで



                } // List ここまで
                .listStyle(.insetGrouped)  // listの線を左端まで伸ばす
                .navigationBarHidden(true)


                Spacer()

                // 【未】 Listのボタンと同じ角の丸い横長ボタンを上のListと少し話した場所に表示させる
                Button(action: {
                    
                    dataModel.isNewData = false
                    
                    didTapDismissButton()
                    // 既存設定の変更かどうかを判断
                    if(dataModel.updateItem != nil) {
                        viewContext.delete(items[searchIndex()])
                        try! viewContext.save()
                    }

 
                    // .actionSheetを使って確認メッセージを表示する
                    // https://www.choge-blog.com/programming/swiftuiactionsheetshow/

                }) {
                    Text("アラームを削除")
                        .frame(width: UIScreen.main.bounds.size.width / 6 * 5,
                               height: UIScreen.main.bounds.size.width / 6 * 0.5)
                }
                .foregroundColor(Color.red)
                .buttonStyle(.bordered)

                Spacer()
            } // VStack ここまで

            // NavigationBarのTitleを消すためのコードはNavigationViewの範囲内のListやVStackの{}の後ろに付ける
            .navigationBarHidden(true)
        } // NavigationView ここまで

    } // body ここまで

    // モーダル遷移を閉じるための関数
    private func didTapDismissButton() {
        presentationMode.wrappedValue.dismiss()
    }

    // 設定済み繰り返し曜日を示す文字列作成関数
    func textWeekDay() -> String {
        var returnString = "しない"    // returnする文字列 登録済みの曜日
        let start = 2                 // 2(3)番目の文字列（曜日）を取得する

        for index in 0 ..< weekArray.count {
            let stringDay = weekArray[index].rawValue
            if(dataModel.dayOfWeekRepeat.contains(weekArray[index].rawValue)) {
                if(dataModel.dayOfWeekRepeat.count == 1) {
                    returnString = weekArray[index].rawValue
                } else {
                    if(returnString == "しない") {
                        returnString = ""
                    }
                    let addInt = stringDay.index(stringDay.startIndex, offsetBy: start, limitedBy: stringDay.endIndex) ?? stringDay.endIndex
                    returnString += " "
                    returnString += String(stringDay[addInt])
                }
            }
        }
        return returnString
    } //func textWeekDayここまで

    // 設定済み識別色を示す文字列作成関数
    func textTagColor() -> String{
        var returnString = " "
        if(dataModel.tagColor != "clear") {
            returnString = dataModel.tagColor
        }

        return returnString
    }


    // 既存設定用indexサーチ関数 (uuid検索)
    private func searchIndex() -> Int {
        var returnIndex: Int?
        for index in 0 ..< items.count {
            if(items[index].uuid == dataModel.uuid){
                returnIndex = index
            }
        }
        if(returnIndex == nil) {
            return -1
        } else {
            return returnIndex!
        }
    }

} // struct ここまで

//struct SettingView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        SettingView(NewSettingBool: false, setUUID: UUID().uuidString, setAlarmTime: Date(), setDayOfWeekRepeat: [], setLabel: "アラーム", setSnooze: false, setTagColor: "clear")
//    }
//}
