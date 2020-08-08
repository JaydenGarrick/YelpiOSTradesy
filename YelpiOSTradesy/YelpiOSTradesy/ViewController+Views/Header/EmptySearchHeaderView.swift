//
//  EmptySearchHeaderView.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import UIKit

class EmptySearchHeaderView: UIView {
    static func instanceFromNib() -> UIView {
        return UINib(nibName: "EmptySearchHeader", bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView ?? UIView()
    }
}
