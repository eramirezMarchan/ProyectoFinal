//
//  DetalleQRViewController.swift
//  Proyecto Final
//
//  Created by Faktos on 08/10/16.
//  Copyright © 2016 ERM. All rights reserved.
//

import UIKit

class DetalleQRViewController: UIViewController {

    @IBOutlet weak var lbl_url: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var urls : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lbl_url?.text = urls!
        let url = NSURL(string: urls!)
        let peticion = NSURLRequest(URL: url!)
        webView.loadRequest(peticion)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
