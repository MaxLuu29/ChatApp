import UIKit
import Firebase
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var messageArray = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        messageTableView.separatorStyle = .none
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "DaenerysTargaryen")
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
        cell.avatarImageView.layer.masksToBounds = false
        cell.avatarImageView.clipsToBounds = true
        
        if cell.senderUsername.text! == Auth.auth().currentUser?.email! as String? {
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.02352941176, green: 0.4588235294, blue: 1, alpha: 1)
            cell.avatarImageView.image = UIImage(named: "JonSnow")
        } else {
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.8470588235, alpha: 1)
            cell.messageBody.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.senderUsername.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }

    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    ///////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    ///////////////////////////////////////////
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
    
        if messageTextfield.text == "" {
            messageTextfield.isEnabled = true
            sendButton.isEnabled = true
            messageTextfield.text = ""
            return
        } else {
            let messagesDB = Database.database().reference().child("Messages")
            let messageDictionary = ["Sender" : Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text!]
            messagesDB.childByAutoId().setValue(messageDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                } else {
                    print("Message Saved Successfully!")
                    self.messageTextfield.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextfield.text = ""
                }
            }
        }
    }
    
    func retrieveMessages() {
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            print(text, sender)
            let message = Message()
            message.sender = sender
            message.messageBody = text
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("There was a problem with signing out")
        }
        guard let _ = (navigationController?.popToRootViewController(animated: true)) else {
            print("No view controller to pop off")
            return
        }
    }
}
