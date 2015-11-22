//
//  TreeView.swift
//  Family Viewer
//
//  Created by Ezekiel Elin on 11/22/15.
//  Copyright © 2015 Ezekiel Elin. All rights reserved.
//

import Cocoa

class TreeViewController: NSViewController {

    @IBOutlet weak var treeView: TreeView!

    var tree: Tree = Tree()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        treeView.tree = self.tree;
    }
}
