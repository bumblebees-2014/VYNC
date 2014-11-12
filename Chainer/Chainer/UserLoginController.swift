import Foundation
import UIKit


let userSaveFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
let userFileName = "/userexists.txt"
let pathToUserFile = userSaveFolder + userFileName as NSString


class UserLoginController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var usernameTxt: UITextField!
    let theFileManager = NSFileManager.defaultManager()

    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        var deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
        var devicetoken = currentUser.deviceToken
        if usernameTxt.text == "" {
            displayAlert("Error In Form", error: "Please enter a username")
        } else {
            var request = HTTPTask()
            let params: Dictionary<String,AnyObject!> = ["deviceId": deviceId, "username": usernameTxt.text, "devicetoken": devicetoken]
            request.POST("http://chainer.herokupapp.com/newuser", parameters: params, success: {(response: HTTPResponse) in
                if response.responseObject != nil {
                    println("success")
                    self.theFileManager.createFileAtPath(pathToUserFile, contents: NSData(), attributes: nil )
                }
                } ,failure: {(error: NSError, response: HTTPResponse?) in
                    println("failure")
            })
            activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            theFileManager.createFileAtPath(pathToUserFile, contents: NSData(), attributes: nil )
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Home") as ViewController
        self.presentViewController(vc, animated:false, completion:{})
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        if  theFileManager.fileExistsAtPath(pathToUserFile) {
            self.performSegueWithIdentifier("jumpToNewChains", sender: self)
        }
    println(theFileManager.fileExistsAtPath(pathToUserFile))
    }
}