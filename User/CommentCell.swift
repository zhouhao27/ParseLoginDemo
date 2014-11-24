//
//  CommentCell.swift
//  User
//
//  Created by Zhou Hao on 24/11/14.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
        
    // Need to implement layoutSubiews and set the preferred max layout width of the multi-line label or
    // the cell height does not get correctly calculated when the device changes orientation.
    //
    // Credit to this GitHub example project and StackOverflow answer for providing the missing details:
    //
    // https://github.com/smileyborg/TableViewCellWithAutoLayout
    // http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights
    
    override func layoutSubviews() {

        super.layoutSubviews()
    
        self.contentView.layoutIfNeeded()
        self.lblComment.preferredMaxLayoutWidth = CGRectGetWidth(self.lblComment.frame);
    }

}
