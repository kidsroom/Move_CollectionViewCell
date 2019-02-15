//
//  ViewController.swift
//  MoveCollectionCell
//
//  Created by Kids room on 2018/10/08.
//  Copyright © 2018年 Kids room. All rights reserved.
//

import UIKit

class MyModel {
    let id: String
    let name: String
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}

class ViewController: UIViewController {

    var moveIPath: IndexPath?
    let width = UIScreen.main.bounds.size.width
    var models: [MyModel] = [
        MyModel(name: "トロ"),
        MyModel(name: "エビ"),
        MyModel(name: "サバ"),
        MyModel(name: "ウニ"),
        MyModel(name: "イカ"),
        MyModel(name: "カニ"),
        MyModel(name: "アナゴ"),
        MyModel(name: "ホタテ"),
    ]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    /// TextField入りアラートを表示
    func showTFAlert() {
        var tf = UITextField()
        let alert = UIAlertController(title: nil, message: "新規登録", preferredStyle: .alert)
        // OKボタン
        let ok = UIAlertAction(title: "OK",
                               style: .default,
                               handler: {(action:UIAlertAction!) -> Void in
                                if  let text = tf.text,
                                    text.count > 0 {
                                    // 入力文字列でモデル生成
                                    self.models.append(MyModel(id: UUID().uuidString, name: text))
                                    // collectionView更新
                                    self.collectionView.reloadData()
                                }
        })
        // キャンセルボタン
        let cancel = UIAlertAction(title: "キャンセル",
                                   style: .cancel,
                                   handler: nil)
        // ボタンの追加
        alert.addAction(ok)
        alert.addAction(cancel)
        // TextField追加
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "テキスト入力"
            tf = textField
        })
        // 表示
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func actGesLTap(_ sender: Any) {
        // ロングタップジェスチャー
        let gesture: UILongPressGestureRecognizer = sender as! UILongPressGestureRecognizer
        // ロングタップ位置
        let location = gesture.location(in: collectionView)
        // ロングタップ位置のIndexPath
        moveIPath = collectionView.indexPathForItem(at: location)
        
        if gesture.state == .began {
            // ロングタップ開始
            if let indexPath = moveIPath {
                // 移動開始
                setEditing(true, animated: true)
                collectionView.beginInteractiveMovementForItem(at: indexPath)
                moveIPath = nil
            }
        } else if(gesture.state == .changed) {
            // 移動中
            collectionView.updateInteractiveMovementTargetPosition(location)
        } else {
            // 移動終了
            if gesture.state == .ended {
                collectionView.endInteractiveMovement()
            } else {
                collectionView.cancelInteractiveMovement()
            }
            // セルサイズを元に戻す
            if  let indexPath = moveIPath,
                let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.2) {
                    cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // プラスセル分の+1
        return models.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // モデル表示セル
        if models.count > indexPath.row {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            let lbl: UILabel = cell.viewWithTag(1) as! UILabel
            let model = models[indexPath.row]
            lbl.text = model.name
            
            return cell
        }
        // プラスセル
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlusCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        // 末尾のセル以外は拡大して移動可
        if indexPath.row < models.count {
            let cell = collectionView.cellForItem(at: indexPath)
            UIView.animate(withDuration: 0.2) {
                cell?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        // 末尾のセル位置には移動不可に
        if proposedIndexPath.row == models.count {
            return IndexPath(row: max(0, models.count - 1) , section: 0)
        }
        return proposedIndexPath
    }
    
    /// セル移動完了時に呼ばれる
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - sourceIndexPath: 移動前のIndexPath
    ///   - destinationIndexPath: 移動後のIndexPath
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        // 配列の内容をセルと合わせる
        let model = models[sourceIndexPath.row]
        models.remove(at: sourceIndexPath.row)
        models.insert(model, at: destinationIndexPath.row)
        
        print("\(sourceIndexPath.row) --> \(destinationIndexPath.row)")
        
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= models.count {
            // 新規登録アラート表示
            showTFAlert()
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 程よく横n列に並ぶサイズ / 22=左右の隙間プラスアルファ / 10=セル間の横の隙間（Storyboard参照）
        let n: CGFloat = 3
        return CGSize(width: (width - 22 - (n - 1) * 10 - 2) / n, height: 70)
    }
}
