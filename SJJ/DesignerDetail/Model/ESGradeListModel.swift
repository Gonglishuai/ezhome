//
//  ESGradeListModel.swift
//  EZHome
//
//  Created by shiyawei on 3/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESGradeModel:Codable {
    var data:ESGradeListModel?
    var paging:Page?
}

struct ESGradeListModel:Codable {
    var avgCommentScore:String?
    let avgProfession:Int?
    let avgAttitude:Int?
    let avgPunctuality:Int?
    let commentTags:[CommentTagCountRespBean]?
    let comments:[CommentInfoRespBean]?
}

struct CommentTagCountRespBean:Codable {
    let name:String?
    let count:Int?
}
struct CommentInfoRespBean:Codable {
    let customerName:String?
    let customerImage:String?
    let customerJMemberId:String?
    let createDate:Int?
    ///小区
    let community:String?
    let houseSize:String?
    let comment:String?
    let replay:String?
    let tags:[String]?
    let images:[String]?
}

struct Page:Codable {
    let total:Int?
}
