//
//  ESRoomType.swift
//  EZHome
//
//  Created by Admin on 2018/8/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation

class ESRoomType: NSObject {
    @objc let roomTypesDict = [
    "Outdoors": "户外",
    "KidsRoom": "儿童房",
    "Kitchen": "厨房",
    "StorageRoom": "储藏间",
    "Basement" : "地下室",
    "FloorPlan": "平面图",
    "Den": "小房间",
    "DiningRoom": "餐厅",
    "MasterBathroom": "主卫",
    "Bedroom": "卧室",
    "Lounge": "休闲厅",
    "PublicExterior": "商用/公用室外区域",
    "PorchBalcony": "玄关和阳台",
    "Bathroom": "卫生间",
    "Aisle": "过道",
    "NannyRoom": "保姆间",
    "Sketch": "草图",
    "ElderlyRoom": "老人房",
    "PublicInterior": "商用/公用室内区域",
    "SecondBedroom": "次卧",
    "LaundryRoom": "洗衣间",
    "MasterBedroom": "主卧",
    "Library": "书房",
    "CloakRoom": "衣帽间",
    "ProductShowcase": "产品展示柜",
    "Corridor": "走廊",
    "Balcony": "阳台",
    "EntranceHallway": "入口和过厅",
    "Auditorium": "影视厅",
    "Studio": "工作室",
    "Office": "办公室",
    "Hallway": "门厅",
    "ResidentialExterior": "住宅室外区域",
    "OtherRoom": "其他房间",
    "SecondBathroom": "次卫",
    "LivingRoom": "客厅",
    "HomeCinema": "家庭影院",
    "Stairwell": "楼梯间",
    "LivingDiningRoom": "客厅及餐厅",
    "EquipmentRoom": "设备间",
    "Courtyard": "庭院",
    "Garage": "车库",
    "Terrace": "露台",
    "other": "其它"
    ]
    @objc let colorStyleDict =  [
        "Hallway": 0x88D4FF,
        "LivingRoom": 0xFFC200,
        "DiningRoom": 0xFFC200,
        "LivingDiningRoom": 0xFFC200,
        "Balcony": 0xFF3E61,
        "Kitchen": 0x36B6E4,
        "Bathroom": 0xDB4F44,
        "MasterBathroom": 0xDB4F44,
        "SecondBathroom": 0xDB4F44,
        "Bedroom": 0xB3DC00,
        "MasterBedroom": 0xB3DC00,
        "SecondBedroom": 0xB3DC00,
        "KidsRoom": 0xB3DC00,
        "ElderlyRoom": 0xB3DC00,
        "Library": 0x88D4FF,
        "CloakRoom": 0x88D4FF,
        "StorageRoom": 0x88D4FF,
        "NannyRoom": 0x88D4FF,
        "LaundryRoom": 0x88D4FF,
        "Lounge": 0x88D4FF,
        "Auditorium": 0x88D4FF,
        "Stairwell": 0x88D4FF,
        "Aisle": 0x88D4FF,
        "Corridor": 0x88D4FF,
        "EquipmentRoom": 0x88D4FF,
        "Courtyard": 0x88D4FF,
        "Garage": 0x88D4FF,
        "Terrace": 0x88D4FF,
        "none": 0xF69D88,
        "other": 0xF69D88
    ]
    @objc let roomStyleDict = [
    "Japan": "日式",
    "Korea": "韩式",
    "Mashup": "混搭",
    "european": "欧式",
    "chinese": "中式",
    "neoclassical": "新古典",
    "ASAN": "东南亚",
    "US": "美式",
    "country": "田园",
    "modern": "现代",
    "mediterranean": "地中海",
    "Nordic": "北欧",
    "other": "其他"
    ]
}
