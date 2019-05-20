--
-- Author: Tang
-- Date: 2016-08-08 14:27:52
--

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd  = {}

cmd.VERSION     =   appdf.VersionValue(6,7,0,1)     -- 游戏版本
cmd.KIND_ID     =   2012                            -- 游戏标识
cmd.GAME_PLAYER =   4                               -- 游戏人数
cmd.SERVER_LEN  =   32                              -- 房间名长度
cmd.INT_MAX     =   2147483647

cmd.Event_LoadingFish  = "Event_LoadingFinish"
cmd.Event_FishCreate   = "Event_FishCreate"

--音效
cmd.Bgm                 = "sound_res/fishdntg_bgm.wav"
cmd.ChangeScene         = "fishdntg_change_scene.mp3"
cmd.Coinfly             = "fishdntg_coinfly.wav"
cmd.Combo               = "fishdntg_combo.wav"
cmd.Shell_8             = "fishdntg_shell_8.wav"
cmd.BigCoin             = "fishdntg_coin.mp3"
cmd.BtnSound            = "fishdntg_click.mp3"
cmd.CatchBigFishSound   = "fishdntg_catch_bigfish.mp3"
cmd.BigFishComing       = "fishdntg_bigfish_coming.mp3"
cmd.FallNetSound        = "fishdntg_fall_net.wav"
cmd.HitBaGuaLu          = "fishdntg_catch_fish_hitbagualu.wav"
cmd.SunWuKong           = "fishdntg_catch_fish_sunwukong.wav"
cmd.YuHuangDaDi         = "fishdntg_catch_fish_yuhuangdadi.wav"
cmd.FengHuoLun          = "fishdntg_catch_fish_fhlzi.wav"
cmd.JinGangTa           = "fishdntg_catch_fish_jgtzi.wav"
cmd.RuYiJGB             = "fishdntg_catch_fish_ryjgbzi.wav"



cmd.FPoint = 
{
	{ k = "x", t = "float"},
	{ k = "y", t = "float"}
}

cmd.kMaxCatchFishCount = 2 
cmd.kMaxChainFishCount = 6

-- 相对窗口
cmd.DEFAULE_WIDTH				= 1280      -- 客户端相对宽
cmd.DEFAULE_HEIGHT				= 800       -- 客户端相对高	
cmd.FISHSERVER_WIDTH			= 1336      -- 客户端相对宽
cmd.FISHSERVER_HEIGHT			= 768       -- 客户端相对高
cmd.OBLIGATE_LENGTH				= 300       -- 预留宽度

--游戏玩家
cmd.PlayChair_Max           = 6
cmd.PlayChair_Invalid       = 0xffff
cmd.PlayName_Len            = 32
cmd.QianPao_Bullet     		= 1
cmd.Multiple_Max            = 6
cmd.Tag_Fish                = 10
cmd.Tag_Bullet              = 11
cmd.Fish_MOVE_TYPE_NUM      = 27
cmd.Fish_DEAD_TYPE_NUM      = 21
cmd.TAG_START               = 1

--鱼ID
cmd.FishKind =
{
  FISH_WONIUYU = 0,           -- 蜗牛鱼
  FISH_LVCAOYU = 1,           -- 绿草鱼
  FISH_HUANGCAOYU = 2,        -- 黄草鱼
  FISH_DAYANYU = 3,           -- 大眼鱼
  FISH_HUANGBIANYU = 4,       -- 黄边鱼
  FISH_XIAOCHOUYU = 5,        -- 小丑鱼
  FISH_XIAOCIYU = 6,          -- 小刺鱼
  FISH_LANYU = 7,             -- 蓝鱼
  FISH_DENGLONGYU = 8,        -- 灯笼鱼
  FISH_HAIGUI = 9,            -- 海龟
  FISH_HUABANYU = 10,         -- 花斑鱼
  FISH_HUDIEYU = 11,          -- 蝴蝶鱼
  FISH_KONGQUEYU = 12,        -- 孔雀鱼    
  FISH_JIANYU = 13,           -- 剑鱼
  FISH_BIANFUYU = 14,         -- 蝙蝠鱼
  FISH_YINSHA = 15,           -- 银鲨
  FISH_JINSHA = 16,           -- 金鲨    
  FISH_BAWANGJING = 17,       -- 霸王鲸，17<= kind <28 或者 等于31为大鱼，其它为小鱼      
  FISH_JINCHAN = 18,          -- 金蝉
  FISH_SHENXIANCHUAN = 19,    -- 神仙船
  FISH_MEIRENYU = 20,         -- 美人鱼 
  FISH_XIAOQINGLONG = 21,     -- 小青龙 
  FISH_XIAOYINLONG = 22,      -- 小银龙 
  FISH_XIAOJINLONG = 23,      -- 小金龙 
  FISH_SWK = 24,              -- 孙悟空 
  FISH_YUWANGDADI = 25,       -- 玉皇大帝 
  FISH_FOSHOU = 26,           -- 佛手 
  FISH_BGLU = 27,             -- 炼丹炉 
  FISH_DNTG = 28,             -- 大闹天宫 (FISH_WONIUYU-FISH_HAIGUI) 
  FISH_YJSD = 29,             -- 一箭双雕 
  FISH_YSSN = 30,             -- 一石三鸟 
  FISH_QJF = 31,              -- 全家福 
  FISH_YUQUN = 32,            -- 鱼群 (FISH_WONIUYU-FISH_HAIGUI)
  FISH_CHAIN = 33,            -- 闪电鱼 (FISH_WONIUYU-FISH_LANYU) 连 (FISH_WONIUYU-FISH_DENGLONGYU)
  FISH_YELLOWBRICK = 34,      -- 血条-黄砖鱼
  FISH_REDBRICK = 35,         -- 血条-红砖鱼
  FISH_BLUEBRICK = 36,        -- 血条-蓝砖鱼
  FISH_VIPBRICK = 37,         -- 血条-VIP鱼
  FISH_REDPACKET = 38,        -- 红包鱼

  FISH_KIND_COUNT = 39        
}

cmd.kYjsdSubFish = {{cmd.FishKind.FISH_HUANGBIANYU, cmd.FishKind.FISH_LANYU},                                   -- 一箭双雕
                    {cmd.FishKind.FISH_XIAOCHOUYU,  cmd.FishKind.FISH_XIAOCIYU}, 
                    {cmd.FishKind.FISH_HUANGBIANYU, cmd.FishKind.FISH_XIAOCIYU}, 
                    {cmd.FishKind.FISH_XIAOCHOUYU,  cmd.FishKind.FISH_LANYU}, 
                    {cmd.FishKind.FISH_HUANGCAOYU,  cmd.FishKind.FISH_XIAOCIYU}};

cmd.kYjsdMulriple = {13, 13, 12, 14, 10}

cmd.kYssnSubFish = {{cmd.FishKind.FISH_LVCAOYU, cmd.FishKind.FISH_HUANGCAOYU,  cmd.FishKind.FISH_XIAOCHOUYU},   -- 一石三鸟
                    {cmd.FishKind.FISH_WONIUYU, cmd.FishKind.FISH_DAYANYU,     cmd.FishKind.FISH_XIAOCHOUYU}, 
                    {cmd.FishKind.FISH_WONIUYU, cmd.FishKind.FISH_XIAOCHOUYU,  cmd.FishKind.FISH_XIAOCIYU}, 
                    {cmd.FishKind.FISH_DAYANYU, cmd.FishKind.FISH_HUANGBIANYU, cmd.FishKind.FISH_LANYU}, 
                    {cmd.FishKind.FISH_DAYANYU, cmd.FishKind.FISH_HUANGBIANYU, cmd.FishKind.FISH_HAIGUI}, 
                    {cmd.FishKind.FISH_DAYANYU, cmd.FishKind.FISH_XIAOCHOUYU,  cmd.FishKind.FISH_XIAOCIYU}}

cmd.kYssnMulriple = {11, 12, 15, 17, 18, 17}

cmd.kQuanJiaFu = {cmd.FishKind.FISH_HAIGUI,                                                                     -- 全家福
                  cmd.FishKind.FISH_WONIUYU, 
                  cmd.FishKind.FISH_DENGLONGYU, 
                  cmd.FishKind.FISH_LVCAOYU, 
                  cmd.FishKind.FISH_XIAOCIYU, 
                  cmd.FishKind.FISH_LANYU, 
                  cmd.FishKind.FISH_HUANGCAOYU, 
                  cmd.FishKind.FISH_DAYANYU, 
                  cmd.FishKind.FISH_XIAOCHOUYU, 
                  cmd.FishKind.FISH_HUANGBIANYU}

cmd.kChainFishRadius = {33.0, 27.0, 36.0, 45.5, 58.0, 52.0, 57.0, 61.5, 101.5}-- 闪电鱼的包围盒半径

--枚举
local enumBulletKind =
{
    "BULLET_2_NORMAL",         
    "BULLET_3_NORMAL",      
	"BULLET_4_NORMAL",        
	"BULLET_2_DOUBLE",       
	"BULLET_3_DOUBLE",        
	"BULLET_4_DOUBLE",
    "BULLET_KIND_COUNT"
}
cmd.BulletKind =  ExternalFun.declarEnumWithTable(0,enumBulletKind)


--枚举
local enumSceneKind =
{
    "SCENE_1",         
    "SCENE_2",      
	"SCENE_3",        
	"SCENE_4",       
	"SCENE_5",        
	"SCENE_6",
    "SCENE_7",
    "SCENE_COUNT"
}
cmd.SceneKind =  ExternalFun.declarEnumWithTable(0,enumSceneKind)


----------------------------------------------------------------------------------------------
--枚举
local enumScoreType =
{
    "EST_Cold",         --金币
    "EST_YuanBao",      --元宝
	"EST_Laser",        --激光
	"EST_Speed",        --加速
	"EST_Gift",         --赠送
	"EST_NULL"
}
cmd.SupplyType =  ExternalFun.declarEnumWithTable(0,enumScoreType)

--房间类型
local enumRoomType = 
{
	"ERT_Unknown",      --无效
	"ERT_QianPao",      --千炮
	"ERT_Moni"          --模拟
}
cmd.RoomType = ExternalFun.declarEnumWithTable(0,enumRoomType)

local enumCannonType = 
{
  "Normal_Cannon",      --正常炮
  "Bignet_Cannon",      --网变大
  "Special_Cannon",     --加速炮
  "Laser_Cannon",       --激光炮
  "Laser_Shooting",      --激光发射中
  "Bullet_Special_Cannon"     --加速炮
}
cmd.CannonType = ExternalFun.declarEnumWithTable(0,enumCannonType)

--道具类型
local enumPropObjectType =
{
	"POT_NULL",         -- 无效
	"POT_ATTACK",       -- 攻击
	"POT_DEFENSE",      -- 防御
	"POT_BULLET",       -- 子弹
}
cmd.PropObjectType = ExternalFun.declarEnumWithTable(0,enumPropObjectType)

cmd.TraceType =
{
  TRACE_LINEAR = 0,
  TRACE_BEZIER = 1
}

    
-----------------------------------------------------------------------------------------------
--大闹服务器结构
  cmd.SUB_S_DISTRIBUTE_FISH           =  100
  cmd.SUB_S_EXCHANGE_FISHSCORE        =  101
  cmd.SUB_S_USER_FIRE                 =  102
  cmd.SUB_S_CATCH_FISH_GROUP          =  103
  cmd.SUB_S_BULLET_DOUBLE_TIMEOUT     =  104
  cmd.SUB_S_SWITCH_SCENE              =  105
  cmd.SUB_S_CATCH_CHAIN               =  106
  cmd.SUB_S_SCENE_FISH                =  107
  cmd.SUB_S_SCENE_BULLETS             =  108
  cmd.SUB_S_FORCE_TIMER_SYNC          =  109
  cmd.SUB_S_TIMER_SYNC                =  110
  cmd.SUB_S_STOCK_OPERATE_RESULT      =  111
  cmd.SUB_S_ADMIN_CONTROL             =  112
  cmd.SUB_S_ADMIN_LOOKON			  =  113
  cmd.SUB_S_ADMIN_UPDATEUSER		  =	 114
  cmd.SUB_S_MATCH_PAUSE				  =	 115
  cmd.SUB_S_MATCH_RESULT			  =	 116
  cmd.SUB_S_MATCH_AWARD				  =	 117
  cmd.SUB_S_CATCH_BLOOD_FISH          =  118
  cmd.SUB_S_CATCH_BLOOD_BRICK         =  119
  cmd.SUB_S_CATCH_MEDAL_COUNT         =  120
  cmd.SUB_S_USER_LOCKFISH             =  121
  cmd.SUB_S_SCENE_END                 =  122
-----------------------------------------------------------------------------------------------



-- 游戏配置
cmd.ClientGameConfig =
{
   { k = "exchange_ratio_userscore",        t = "int"       },
   { k = "exchange_ratio_fishscore",        t = "int"       }, 
   { k = "exchange_count",                  t = "int"       },
   { k = "min_bullet_multiple",             t = "int"       },
   { k = "max_bullet_multiple",             t = "int"       },
   { k = "fish_layer",                      t = "int",      l = {39}},
   { k = "fish_bounding_count",             t = "int",      l = {39}},
   { k = "fish_bounding_radius",            t = "float" ,   l = {39}},
   { k = "fish_speed",                      t = "float",    l = {39}},
   { k = "bullet_speed",                    t = "float",    l = {6}},
   { k = "bullet_bounding_radius",          t = "float",    l = {6}}
};


-- 场景信息
cmd.CMD_S_GameStatus = 
{
    { k = "game_version",               t = "dword"                       },
    { k = "tick_count",                 t = "dword"                       }, 
    { k = "special_sceene_waited_time", t = "float"                       },
    { k = "is_special_scene",           t = "bool"                        },
    --结构体大小不确定
    { k = "game_config",                t = "table", d = cmd.ClientGameConfig },
    { k = "fish_score",                 t = "score", l = {4}},
    { k = "exchange_fish_score",        t = "score", l = {4}},
    { k = "scene_kind",                 t = "int"           }
}


cmd.CMD_S_DistributeFish =
{
    --结构体大小不确定
    { k = "position",                   t = "table", d = cmd.FPoint, l = {7} },
    { k = "fish_kind",                  t = "int"                                  },
    { k = "position_count",             t = "int"                                  },
    { k = "fish_id",                    t = "int"                                  }, 
    { k = "tag",                        t = "int"                                  },
    { k = "blood_fish",                 t = "int"                                  },
    { k = "offset_X",                   t = "int"                                  },
    { k = "offset_Y",                   t = "int"                                  },
    { k = "scaling",                    t = "float"                                },
    { k = "tick_count",                 t = "dword"                                }
};

--上分
cmd.CMD_S_ExchangeFishScore =
{
    { k = "chair_id",                   t = "word"                                  }, 
    { k = "swap_fish_score",            t = "score"                                 },
    { k = "exchange_fish_score",        t = "score"                                 }
};

-- 用户锁鱼
cmd.CMD_S_UserLockFish=
{
    { k = "lock_fishid",     t = "int"  },          -- 鱼ID
    { k = "chair_id",       t = "word"  },          -- 椅子号
}

--开火
cmd.CMD_S_UserFire =
{
    { k = "bullet_id",                  t = "int"                                   },
    { k = "chair_id",                   t = "word"                                  },
    { k = "bullet_double",              t = "bool"                                  },
    { k = "bullet_mulriple",            t = "int"                                   }, 
    { k = "lock_fish_id",               t = "int"                                   },
    { k = "tick_count",                 t = "dword"                                 },
    { k = "angle",                      t = "float"                                 },
    { k = "bullet_kind",                t = "int"                                   },
    { k = "android_chairid",            t = "word"                                  },
    { k = "fish_score",                 t = "score"                                 },
    { k = "is_android_scene",           t = "bool"                                  }
};

--打到鱼数据包
cmd.CatchFish =
{
    { k = "fish_kind",                  t = "int"                                   },
    { k = "bullet_double",              t = "bool"                                  },
    { k = "fish_id",                    t = "int"                                   },
    { k = "blood",                      t = "int"                                   },
    { k = "fish_score",                 t = "score"                                 }, 
    { k = "link_fish_id",               t = "int"                                   },
    { k = "current_bullet_mul",         t = "int"                                   }
};


cmd.CMD_S_MedalCount =
{
    { k = "medal_count",                t = "int"                                   },
    { k = "chair_id",                   t = "dword"                                 }
};

cmd.CMD_S_CatchFishGroup =  
{
    { k = "chair_id",                   t = "word"                                   },
    { k = "tick_count",                 t = "dword"                                  },
    { k = "bullet_id",                  t = "int"                                    },
    { k = "fish_count",                 t = "int"                                    },
    -- 有问题
    { k = "catch_fish",                 t = "table", d = cmd.CatchFish,      l = {2} }
};


cmd.CMD_S_CatchBloodFish = 
{
    { k = "chair_id",                   t = "word"                                   },
    { k = "bullet_id",                  t = "int"                                    },
    --结构体大小不确定
    { k = "catch_fish",                 t = "table", d = cmd.CatchFish, l = {96969}  }
};


cmd.CMD_S_BulletDoubleTimeout =
{
    { k = "chair_id",                   t = "word"                                   }
};

cmd.CMD_S_SwitchScene =
{
    { k = "next_scene",                 t = "int"                                    },
    { k = "tick_count",                 t = "dword"                                  }
};

cmd.CMD_S_CatchChain =
{
    { k = "cbAnroid",                   t = "byte"                                   },
    { k = "chair_id",                   t = "word"                                   },
    { k = "bullet_id",                  t = "int"                                    },
    { k = "fish_count",                 t = "int"                                    },
    -- 有问题
    { k = "catch_fish",                 t = "table", d = cmd.CatchFish, l = {cmd.kMaxChainFishCount}  }
};


cmd.CMD_S_SceneFish =
{
    { k = "fish_kind",                  t = "int"                                   },
    { k = "fish_id",                    t = "int"                                   },
    { k = "current_blood",              t = "int"                                   },
    { k = "total_blood",                t = "int"                                   },
    { k = "scale",                      t = "float"                                 }, 
    { k = "offset_x",                   t = "int"                                   },
    { k = "offset_y",                   t = "int"                                   },
    { k = "tag",                        t = "int"                                   },
    { k = "position_count",             t = "int"                                 }, 
    { k = "elapsed",                    t = "float"                                 },
    { k = "tick_count",                 t = "dword"                                 }, 
    --结构体大小不确定
    { k = "position",                   t = "table", d = cmd.FPoint, l = {7}  }
};


cmd.CMD_S_SceneBullet =
{
     --结构体大小不确定
    { k = "position",                   t = "table", d = cmd.FPoint, l = {96969}  },
    { k = "bullet_id",                  t = "int"                                   },
    { k = "bullet_mulriple",            t = "int"                                   },
    { k = "lock_fish_id",               t = "int"                                   },
    { k = "is_double",                  t = "bool"                                  },
    { k = "angle",                      t = "float"                                 }, 
    { k = "chair_id",                   t = "word"                                  },
    { k = "tick_count",                 t = "dword"                                 }
};


cmd.CMD_S_ForceTimerSync =
{
    { k = "chair_id",                   t = "word"                                  }
};

cmd.CMD_S_TimerSync =
{
    { k = "chair_id",                   t = "word"                                  },
    { k = "client_tick",                t = "dword"                                 },
    { k = "server_tick",                t = "dword"                                 }
};


cmd.CMD_S_StockOperateResult =
{
    { k = "operate_code",               t = "byte"                                  },
    { k = "stock_score",                t = "score"                                 }
};

cmd.CMD_S_MatchPause =
{
    { k = "pause",                      t = "bool"                                  },
};

cmd.CMD_S_Match_Wait_Tip =
{
    { k = "GameID",                     t = "dword"},
    { k = "lScore",                     t = "score"                                 },
    { k = "wRank",                      t = "word"                                  },
    { k = "wCurTableRank",              t = "word"                                  },
    { k = "wUserCount",                 t = "word"                                  },
    { k = "wPlayingTable",              t = "word"                                  }, 
    { k = "szMatchName",                t = "tchar",   l = {32}                     },
    { k = "bGameMatchOver",             t = "bool"                                  }
};

cmd.CMD_S_Match_Award = 
{
    { k = "szDescribe",                 t = "tchar",   l = {256}                    },
    { k = "dwGold",                     t = "dword"                                 },
    { k = "dwMedal",                    t = "dword"                                 },
    { k = "dwExperience",               t = "dword"                                 }
};

cmd.CMD_S_AdminControl =
{
    { k = "szDescribe",                 t = "byte"                                  },  --0 黑名单 1 白名单
    { k = "game_id",                    t = "dword",   l = {30}                     },
    { k = "score",                      t = "score",   l = {30}                     },
    { k = "catch_probability",          t = "double",  l = {30}                     },
    { k = "fish_probability",           t = "double",  l = {30}                     },
    { k = "fish_kind",                  t = "int",     l = {30}                     }, 
    { k = "id_count",                   t = "word"                                  }
};

cmd.tagAdminUpdateUser =
{
    { k = "szName",                     t = "tchar",   l = {32}                     },
    { k = "dwGameID",                   t = "dword"                                 },
    { k = "lScore",                     t = "score"                                 },
    { k = "lInsure",                    t = "score"                                 },
    { k = "lQuitListScore",             t = "score"                                 },
    { k = "dwQuitListTimer",            t = "dword"                                 },
    { k = "dwWinProbability",           t = "dword"                                 }, 
    { k = "cbControlState",             t = "byte"                                  },
    { k = "cbControltype",              t = "byte"                                  },
    { k = "lAddupWinScore",             t = "score"                                 },
    { k = "lAddupLoseScore",            t = "score"                                 },
    { k = "dwConsumeTime",              t = "dword"                                 },
    { k = "dwSmallFish",                t = "float"                                 },
    { k = "dwBigFish",                  t = "float"                                 },
    { k = "cbControlFrom",              t = "byte"                                  }
};

cmd.CMD_S_AdminUpdateUser =
{
    { k = "dwUserCount",                t = "dword"                                 },
    -- 有问题
    { k = "AdminUpdateUser",            t = "table",    d = cmd.tagAdminUpdateUser, l = {503}}
};


cmd.tagUserScoreChange =
{
    { k = "dwGameID",                   t = "dword"                                 },
    { k = "lScore",                     t = "score"                                 },
    { k = "lInsure",                    t = "score"                                 }
};


--大闹客户端命令结构
 cmd.SUB_C_EXCHANGE_FISHSCORE             =  1
 cmd.SUB_C_USER_FIRE                      =  2
 cmd.SUB_C_TIMER_SYNC                     =  3
 cmd.SUB_C_STOCK_OPERATE                  =  4
 cmd.SUB_C_ADMIN_CONTROL                  =  5
 cmd.SUB_C_ADMIN_UPDATEUSER	              =	 6
 cmd.SUB_C_SEND_SPECIAL			          =	 7
 cmd.SUB_C_ANDROID_STAND_UP               =  8
 cmd.SUB_C_MODIFICATION			          =	 9
 cmd.SUB_C_CATCH_FISH				      =  10
 cmd.SUB_C_USER_LOCKFISH                  =  11


cmd.CMD_C_ExchangeFishScore =
{
    { k = "exchange_score",             t = "score"                                 }
};


cmd.CMD_C_CatchFish = 
{
    { k = "bullet_kind",                t = "int"                                   },
    { k = "fish_kind",                  t = "int"                                   },
    { k = "chair_id",                   t = "word"                                  },
    { k = "fish_id",                    t = "int"                                   },
    { k = "bullet_id",                  t = "int"                                   }, 
    { k = "bullet_mulriple",            t = "int"                                   }
};


cmd.CMD_C_UserFire =
{
    { k = "bullet_id",                  t = "int"                                   },
    { k = "bullet_kind",                t = "int"                                   },
    { k = "bullet_mulriple",            t = "int"                                   },
    { k = "lock_fish_id",               t = "int"                                   },
    { k = "angle",                      t = "float"                                 }, 
    { k = "tick_count",                 t = "dword"                                 }
};

cmd.CMD_C_TimerSync =
{
    { k = "client_tick",                t = "dowrd"                                 }
};


cmd.CMD_C_StockOperate =
{
    { k = "operate_code",               t = "byte"                                   },
    { k = "stock_change",               t = "score"                                  }
};


cmd.CMD_C_AlterSpecial = 
{
    { k = "dwGameID",                   t = "dword"                                 },
    { k = "lQuitListScore",             t = "score"                                 },
    { k = "dwQuitListTimer",            t = "dword"                                 },
    { k = "cbWinRate",                  t = "byte"                                  },
    { k = "cbControlState",             t = "byte"                                  },
    { k = "cbControltype",              t = "byte"                                  },
    { k = "control_pro",                t = "word",     l = {2}                     }, 
    { k = "cbControlFrom",              t = "byte"                                  },
    { k = "cbDel",                      t = "byte"                                  }
};

cmd.CMD_ModificationProbability = 
{
    { k = "dwGameID",                   t = "dword"                                 },
    { k = "dwSmallFish",                t = "word"                                  },
    { k = "dwBigFish",                  t = "word"                                  }
};

cmd.CMD_C_AdminControl =
{
    { k = "operate_code",               t = "byte"                                  },
    { k = "game_id",                    t = "dword"                                 },
    { k = "limit_score",                t = "score"                                 },
    { k = "fish_kind",                  t = "int"                                   },
    { k = "catch_count",                t = "int"                                   },
    { k = "catch_probability",          t = "double", l = {2}                       }
};

return cmd