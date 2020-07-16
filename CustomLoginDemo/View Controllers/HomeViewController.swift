//
//  HomeViewController.swift
//  CustomLoginDemo
//
//  Created by ２１３ on 2020/7/6.
//  Copyright © 2020 ２１３. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


class HomeViewController: UIViewController {
    //alert_event
    @IBOutlet var btn_event: UIButton!
    let customAlert = MyAlert()
    var event_count = 6
    //personal_setting
    @IBOutlet var btn_psetting: UIButton!
    //btn_hbell
    @IBOutlet var btn_hbell: UIButton!
    //登入登出
    @IBOutlet weak var nicknameText: UILabel!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    func loadUserNickname(){
        
        let db = Firestore.firestore()
        
        let useID = Auth.auth().currentUser!.uid
        
        db.collection("users").document(useID).getDocument {(document,error) in
            
            if error == nil{
                
                if document != nil && document!.exists{
                    
                    self.nicknameText.text = document!.data()?["nickname"] as? String
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loadUserNickname()
        //alert
        btn_event.setImage(UIImage(named: "btn_event"), for: .normal)
        //背景
        self.view.addBackground(bg: UIImage(named: "home_bg")!)
        customAlert.showAlert_Q(with: "請問要新增事件嗎？",
        message: String(event_count),
        on: self)
        event_count-=1
    }
    //alert自動跳出
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func logOutTapped(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            
            let ViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.ViewController) as? UINavigationController
            
            self.view.window?.rootViewController = ViewController
            self.view.window?.makeKeyAndVisible()
            
        }catch{
            print(error)
        }
    }
    //alert按按鈕跳出
    @IBAction func didTapButton(){
        customAlert.showAlert_Q(with: "請問要新增事件嗎？",
        message: String(event_count),
        on: self)
        event_count-=1
    }
    @objc func dismissAlert(){
        customAlert.dismissAlert()
    }
}

//alerts，其他的swift檔案也可以呼叫
class MyAlert{
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    //背景黑色
    private let backgroundView: UIView = {
       let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    //視窗
    private let alertView: UIView = {
        let alert = UIView()
        alert.layer.masksToBounds = true
        alert.backgroundColor = .white
        alert.layer.cornerRadius = 13
        return alert
        
    }()
    private var mytargetView: UIView?
    //新增事件視窗
    func showAlert_Q(with title: String,
                   message: String,
                   on ViewController: UIViewController){
        guard let targetView = ViewController.view else{
            return
        }
        
        mytargetView = targetView
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: 302,
                                 height: 282)
        alertView.backgroundColor = UIColor(patternImage: UIImage(named: "alert_bg")!)
        //標題
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 21))
        titleLabel.center.y = 106
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(18)
        titleLabel.addCharacterSpacing(kernValue: 5.2)
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        //資訊 (還沒寫到數量用完時)
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: alertView.frame.size.width,
                                                 height: 19))
            messageLabel.numberOfLines = 0
            messageLabel.text = "今日事件量"+message+"/6"
            messageLabel.center.y = 149
        messageLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 108/255, alpha: 1)
            messageLabel.font = messageLabel.font.withSize(16)
            messageLabel.textAlignment = .center
        messageLabel.addCharacterSpacing(kernValue: 5.2)
            alertView.addSubview(messageLabel)
        //關閉按鈕
        let button = UIButton(frame: CGRect(x:alertView.frame.size.width-(alertView.frame.size.width/2)-30,
                                            y: 0,
                                            width:alertView.frame.size.width,
                                            height: 50))
        button.setImage(UIImage(named: "x"), for: .normal)
        button.addTarget(self, action: #selector(dismissAlert),
                         for: .touchUpInside)
        alertView.addSubview(button)
        //新增按鈕
        let add_event = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 170,
                                            height: 37))
        add_event.setTitle("新增", for: .normal)
        add_event.center = CGPoint(
        x: alertView.frame.size.width * 0.5,
        y: alertView.frame.size.height-55)
        add_event.layer.cornerRadius = 7
        add_event.addTextSpacing(spacing: 5.2)
        add_event.setTitleColor(.white, for: .normal)
        add_event.backgroundColor = UIColor(red: 56/255, green: 83/255, blue: 143/255, alpha: 1)
//        add_event.addTarget(self, action: #selector(dismissAlert),
//                         for: .touchUpInside)
        alertView.addSubview(add_event)
        //小水晶圖圖片
        let alert_s = UIImageView(frame: CGRect(x: 0, y: 8, width: 60, height: 60))
        alert_s.image = UIImage(named: "alert_s")
        alert_s.center.x = alertView.frame.size.width*0.5
        alertView.addSubview(alert_s)
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.backgroundView.alpha = Constants.backgroundAlphaTo
        },completion: { done in
            if done{
                UIView.animate(withDuration: 0.25,animations: {
                    self.alertView.center = targetView.center
                })
            }
        })
    }
    //過往事件視窗
    func showeventAlert(with title: String,
                       message: String,
                       on ViewController: UIViewController){
            guard let targetView = ViewController.view else{
                return
            }
            
            mytargetView = targetView
            
            backgroundView.frame = targetView.bounds
            targetView.addSubview(backgroundView)
            targetView.addSubview(alertView)
            alertView.frame = CGRect(x: 40,
                                     y: -300,
                                     width: targetView.frame.size.width-80,
                                     height: 300)
            //標題
            let titleLabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: alertView.frame.size.width,
                                                   height: 80))
            titleLabel.text = title
            titleLabel.textAlignment = .center
            alertView.addSubview(titleLabel)
            //資訊
            let messageLabel = UILabel(frame: CGRect(x: 0,
                                                   y: 80,
                                                   width: alertView.frame.size.width,
                                                   height: 170))
            messageLabel.numberOfLines = 0
            messageLabel.text = message
            messageLabel.textAlignment = .center
            alertView.addSubview(messageLabel)
            //關閉按鈕
            let button = UIButton(frame: CGRect(x: alertView.frame.size.width-(alertView.frame.size.width/2)-30,
                                                y: 0,
                                                width:alertView.frame.size.width,
                                                height: 50))
            button.setTitle("X", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(dismissAlert),
                             for: .touchUpInside)
            alertView.addSubview(button)
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.backgroundView.alpha = Constants.backgroundAlphaTo
            },completion: { done in
                if done{
                    UIView.animate(withDuration: 0.25,animations: {
                        self.alertView.center = targetView.center
                    })
                }
            })
        }
    //關閉視窗動作
    @objc func dismissAlert() {
        guard let targetView = mytargetView else {
            return
        }
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.alertView.frame = CGRect(x: 40,
                                                      y: targetView.frame.size.height,
                                                      width: targetView.frame.size.width-80,
                                                      height: 300)
        },completion: { done in
            if done{
                UIView.animate(withDuration: 0.25,animations: {
                    self.backgroundView.alpha = 0
                }, completion: { done in
                    if done{
                        //完整清除一切subview
                        //https://blog.csdn.net/zhuiyi316/article/details/8308858
                        //https://www.itread01.com/articles/1484274841.html
                        for child : UIView in self.alertView.subviews as [UIView] {
                            child.removeFromSuperview()
                        }
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                })
            }
        })
    }
}
//按鈕的文字間距
extension UIButton {
    func addTextSpacing(spacing: CGFloat) {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern,
                                      value: spacing,
                                      range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
//label的文字間距
extension UILabel {
  func addCharacterSpacing(kernValue: Double = 1.15) {
    if let labelText = text, labelText.count > 0 {
      let attributedString = NSMutableAttributedString(string: labelText)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
      attributedText = attributedString
    }
  }
}
//背景圖片填滿
extension UIView {
    func addBackground(bg: UIImage) {
    // screen width and height:
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height

    let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    imageViewBackground.image = bg

    // you can change the content mode:
    imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

    self.addSubview(imageViewBackground)
    self.sendSubviewToBack(imageViewBackground)
}}
