//
//  ESDesProjectListDataManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESDesProjectListDataManager: NSObject {
    
    /// 获取/搜索 设计师项目列表
    static func getProjectList(type: ESDesProjectType,
                               keyword: String?,
                               limit: Int,
                               offset: Int,
                               success: @escaping ([ESDesProjectListItem], _ count: Int) -> Void,
                               failure: @escaping () -> Void ) {
        let keywordEncode = keyword?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        ESPackageProjectApi.getDesignerProjectList(type: type.rawValue,
                                                   keywork: keywordEncode,
                                                   limit: limit,
                                                   offset: offset,
                                                   success:
            { (response) in
                if let data = response {
                    print("responseData:\(NSString(data: response!, encoding: String.Encoding.utf8.rawValue)!)")
                    let arr = try? JSONDecoder().decode(ESDesProjectListModel.self, from: data)
                    if let list = arr {
                        success(list.data ?? [], list.count ?? 0)
                    } else {
                        failure()
                    }
                }else {
                    failure()
                }
        }) { (error) in
            failure()
        }
    }
    
    static func manageData(data: ESDesProjectListItem, vm: ESDesProjectListViewModel) {
        let project_type = ESProjectType(data.projectType)
        let package_type = ESPackageType(data.pkgType)
        let (tagText, textColor, backColor) = ESProjectUtil.getProjectTagInfo(project_type, package_type)
        var text = data.pkgName
        if project_type == .Individual {
            text = tagText
        }
        vm.tagText = text
        vm.tagTextColor = textColor
        vm.tagBgColor = backColor
        
        let status = ESProjectStatus(data.status)
        let (_, statusColor) = ESProjectUtil.getStatusInfo(status)
        vm.statusText = data.statusName
        vm.statusColor = statusColor
        vm.consumerName = data.name
        vm.phone = data.phone
        vm.address = data.address
        if let project_id = data.projectId {
            vm.projectId = String(project_id)
        } else {
            vm.projectId = nil
        }
        vm.orderTime = data.publishTime
    }
}
