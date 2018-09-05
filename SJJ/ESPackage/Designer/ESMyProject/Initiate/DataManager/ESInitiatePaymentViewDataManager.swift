
import UIKit

class ESInitiatePaymentViewDataManager: NSObject {
    /// 获取应付金额
    static func getPayment(_ projectId: String,
                           _ type: String,
                           success: @escaping (ESPackagePayment) -> Void,
                           failure: @escaping (String) -> Void) {
        ESPackageOrderApi.getPayDetail(projectId: projectId, type: type, success: { (response) in
            if let data = response {
                let model = try? JSONDecoder().decode(ESPackagePayment.self, from: data)
                if model != nil {
                    success(model!)
                    return
                }
            }
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    /// 发起收款
    static func orderCreate(_ projectId: String,
                            _ amount: String,
                            _ orderType: String,
                            _ remark: String,
                            success: @escaping () -> Void,
                            failure: @escaping (String) -> Void) {
        let dict = ["projectNum": projectId, "orderAmount": amount, "orderType": orderType, "remark": remark]
        ESPackageOrderApi.orderCreate(dict, success: { (response) in
            success()
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
}

struct ESPackagePayment: Codable {
    /// 类型 (定金:2,装修款首款:3,主材预存款:10)
    var type: String?
    /// 填写的金额
    var amount: Double?
    /// 实付金额
    var realAmount: Double?
    /// 优惠的金额
    var discountAmount: Double?
    /// 返现的金额
    var cashBackAmount: Double?
    /// 是否可修改金额
    var editStatus: Bool?
}

enum ESPkgOrderType {
    case NONE
    /// 定金
    case EARNEST
    /// 装修款首款
    case FIRST_FEE
    /// 材料款
    case MATERIAL_FEE
    /// 主材预存款
    case MATERIAL
    /// 装修款项
    case CONSTRUCT
    /// 设计费
    case DESIGN
    /// 尾款
    case LAST_FEE
    
    var rawValue: (key: String, value: Int) {
        switch self {
        case .EARNEST:
            return ("定金", 2)
        case .FIRST_FEE:
            return ("装修款首款", 3)
        case .MATERIAL_FEE:
            return ("材料款", 4)
        case .MATERIAL:
            return ("主材预存款", 10)
        case .CONSTRUCT:
            return ("装修款项", 20)
        case .DESIGN:
            return ("设计费", 30)
        case .LAST_FEE:
            return ("尾款", 5)
        case .NONE:
            return ("", 0)
        }
    }
}
