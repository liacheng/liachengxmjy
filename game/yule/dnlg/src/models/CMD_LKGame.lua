--
-- Author: Tang
-- Date: 2016-08-08 14:27:52
--

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd  = {}

cmd.VERSION     =   appdf.VersionValue(6,7,0,1)     -- 游戏版本
cmd.KIND_ID     =   2022                            -- 游戏标识
cmd.GAME_PLAYER =   6                               -- 游戏人数
cmd.SERVER_LEN  =   32                              -- 房间名长度
cmd.INT_MAX     =   2147483647

cmd.Event_LoadingFish  = "Event_LoadingFinish"
cmd.Event_FishCreate   = "Event_FishCreate"

--音效
cmd.Small_0         = "sound_res/small_0.wav"
cmd.Small_1         = "sound_res/small_1.wav"
cmd.Small_2         = "sound_res/small_2.wav"
cmd.Small_3         = "sound_res/small_3.wav"
cmd.Small_4         = "sound_res/small_4.wav"
cmd.Small_5         = "sound_res/small_5.wav"
cmd.Big_7           = "sound_res/big_7.wav"
cmd.Big_8           = "sound_res/big_8.wav"
cmd.Big_9           = "sound_res/big_9.wav"
cmd.Big_10          = "sound_res/big_10.wav"
cmd.Big_11          = "sound_res/big_11.wav"
cmd.Big_12          = "sound_res/big_12.wav"
cmd.Big_13          = "sound_res/big_13.wav"
cmd.Big_14          = "sound_res/big_14.wav"
cmd.Big_15          = "sound_res/big_15.wav"
cmd.Big_16          = "sound_res/big_16.wav"
cmd.Beauty_0        = "sound_res/beauty_0.wav"
cmd.Beauty_1        = "sound_res/beauty_1.wav"
cmd.Beauty_2        = "sound_res/beauty_2.wav"
cmd.Beauty_3        = "sound_res/beauty_3.wav"
cmd.Load_Back       = "sound_res/LOAD_BACK.mp3"
cmd.Music_Back_1    = "sound_res/MUSIC_BACK_01.mp3"
cmd.Music_Back_2    = "sound_res/MUSIC_BACK_02.mp3"
cmd.Music_Back_3    = "sound_res/MUSIC_BACK_03.mp3"
cmd.Change_Scene    = "sound_res/CHANGE_SCENE.wav"
cmd.CoinAnimation   = "sound_res/CoinAnimation.wav"
cmd.Coinfly         = "sound_res/coinfly.wav"
cmd.Fish_Special    = "sound_res/fish_special.wav"
cmd.Special_Shoot   = "sound_res/special_shoot.wav"
cmd.Combo           = "sound_res/combo.wav"
cmd.Shell_8         = "sound_res/SHELL_8.wav"
cmd.Small_Begin     = "sound_res/SMALL_BEGIN.wav"
cmd.SmashFail       = "sound_res/SmashFail.wav"
cmd.bigCoins        = "sound_res/coin.wav"
cmd.CoinLightMove   = "sound_res/CoinLightMove.wav"
cmd.Prop_armour_piercing = "sound_res/PROP_ARMOUR_PIERCING.wav"

--鱼索引
cmd.FISH_XIAO_HUANG_YU			= 0         -- 小黄鱼
cmd.FISH_XIAO_LAN_YU			= 1         -- 小蓝鱼
cmd.FISH_XIAO_CHOU_YU			= 2         -- 小丑鱼
cmd.FISH_SI_LU_YU				= 3         -- 丝鲈鱼
cmd.FISH_SHENG_XIAN_YU			= 4         -- 神仙鱼
cmd.FISH_HE_TUN_YU				= 5         -- 河豚鱼
cmd.FISH_DENG_LONG_YU			= 6         -- 灯笼鱼
cmd.FISH_BA_ZHUA_YU				= 7         -- 八爪鱼
cmd.FISH_HAI_GUI				= 8         -- 海龟
cmd.FISH_SHUI_MU				= 9         -- 水母
cmd.FISH_JIAN_YU				= 10        -- 剑鱼
cmd.FISH_MO_GUI_YU				= 11        -- 魔鬼鱼
cmd.FISH_HAI_TUN				= 12        -- 海豚
cmd.FISH_SHA_YU					= 13        -- 鲨鱼
cmd.FISH_LAN_JING				= 14        -- 蓝鲸
cmd.FISH_YIN_JING				= 15        -- 银鲸
cmd.FISH_JIN_JING				= 16        -- 金鲸
cmd.FISH_MEI_REN_YU				= 17        -- 美人鱼
cmd.FISH_ZHA_DAN				= 18        -- 炸弹        -- 特殊鱼
cmd.FISH_XIANG_ZI				= 19        -- 补给箱      -- 特殊鱼

-- 鱼索引
cmd.FISH_KING_MAX				= 7         -- 最大灯笼鱼
cmd.FISH_NORMAL_MAX				= 18        -- 正常鱼索引
cmd.FISH_ALL_COUNT				= 20        -- 鱼最大数

-- 特殊鱼
cmd.SPECIAL_FISH_BOMB			= 0         -- 炸弹鱼
cmd.SPECIAL_FISH_CRAB			= 1         -- 螃蟹
cmd.SPECIAL_FISH_MAX			= 2         -- 最大数量

-- 渔网 
cmd.NET_COLOR_GREEN				= 0         -- 绿色网
cmd.NET_COLOR_BLUE				= 1         -- 蓝色网
cmd.NET_COLOR_YELLOW			= 2         -- 黄色网
cmd.NET_COLOR_RED				= 3         -- 红色网
cmd.NET_COLOR_PURPLE			= 4         -- 紫色网
cmd.NET_MAX_COLOR				= 5         -- 最大颜色数(随机值)

-- 道具
cmd.PROP_ICE_NET				= 0         -- 冰网
cmd.PROP_BROKEN_ICE				= 1         -- 破冰器
cmd.PROP_CLOUDY_AGENT			= 2         -- 混浊剂
cmd.PROP_ARMOUR_PIERCING		= 3         -- 穿甲弹
cmd.PROP_EJECTION				= 4         -- 弹射弹
cmd.PROP_TRACKING				= 5         -- 追踪弹
cmd.PROP_SHOTGUN				= 6         -- 散弹
cmd.PROP_ACCELERA				= 7         -- 加速弹
cmd.PROP_COUNT_MAX				= 8         -- 总数

-- 倍数索引
cmd.MULTIPLE_MAX_INDEX			= 6	

-- 服务器位置
cmd.S_TOP_LEFT					= 0
cmd.S_TOP_CENTER				= 1
cmd.S_TOP_RIGHT					= 2
cmd.S_BOTTOM_LEFT				= 3
cmd.S_BOTTOM_CENTER				= 4
cmd.S_BOTTOM_RIGHT				= 5

-- 视图位置
cmd.C_TOP_LEFT					= 0
cmd.C_TOP_CENTER				= 1
cmd.C_TOP_RIGHT					= 2
cmd.C_BOTTOM_LEFT				= 3
cmd.C_BOTTOM_CENTER				= 4
cmd.C_BOTTOM_RIGHT				= 5

-- 相对窗口
cmd.DEFAULE_WIDTH				= 1280      -- 客户端相对宽
cmd.DEFAULE_HEIGHT				= 800       -- 客户端相对高	
cmd.FISHSERVER_WIDTH			= 1336      -- 客户端相对宽
cmd.FISHSERVER_HEIGHT			= 768       -- 客户端相对高
cmd.OBLIGATE_LENGTH				= 300       -- 预留宽度

-- 标题大小
cmd.CAPTION_TOP_SIZE			= 25
cmd.CAPTION_BOTTOM_SIZE			= 40

-- 炮弹
cmd.BULLET_ONE				= 0         -- 一号炮
cmd.BULLET_TWO				= 1         -- 二号炮
cmd.BULLET_THREE			= 2         -- 三号炮
cmd.BULLET_FOUR				= 3         -- 四号炮
cmd.BULLET_FIVE				= 4         -- 五号炮
cmd.BULLET_SIX				= 5         -- 六号炮
cmd.BULLET_SEVEN			= 6         -- 七号炮
cmd.BULLET_EIGHT			= 7         -- 八号炮
cmd.BULLET_MAX				= 8         -- 最大炮种类

--千炮消耗
cmd.QIAN_PAO_BULLET         = 1

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
  "Laser_Shooting"      --激光发射中
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

--鱼类型
cmd.FishType = 
{
    FishType_XiaoHuangCiYu      = 0,            -- 小黄刺鱼
    FishType_XiaoCaoYu          = 1,            -- 小草鱼
    FishType_ReDaiHuangYu       = 2,            -- 热带黄鱼
    FishType_DaYanJinYu         = 3,            -- 大眼金鱼
    FishType_ReDaiZiYu          = 4,            -- 热带紫鱼
    FishType_XiaoChouYu         = 5,            -- 小丑鱼
    FishType_HeTun              = 6,            -- 河豚
    FishType_ShiTouYu           = 7,            -- 狮头鱼
    FishType_DengLongYu         = 8,            -- 灯笼鱼
    FishType_WuGui              = 9,            -- 乌龟
    FishType_ShengXianYu        = 10,           -- 神仙鱼
    FishType_HuDieYu            = 11,           -- 蝴蝶鱼
    FishType_LingDangYu         = 12,           -- 铃铛鱼
    FishType_JianYu             = 13,           -- 剑鱼
    FishType_MoGuiYu            = 14,           -- 魔鬼鱼
    FishType_DaBaiSha           = 15,           -- 大白鲨
    FishType_DaJinSha           = 16,           -- 大金鲨
    FishType_ShuangTouQiEn      = 17,           -- 双头企鹅
    FishType_JuXingHuangJinSha  = 18,           -- 巨型黄金鲨
    FishType_JinLong            = 19,           -- 金龙
    FishType_LiKui              = 20,           -- 李逵
    FishType_ShuiHuZhuan        = 21,           -- 水浒传
    FishType_ZhongYiTang        = 22,           -- 忠义堂
    FishType_BaoZhaFeiBiao      = 23,           -- 爆炸飞镖
    FishType_BaoXiang           = 24,           -- 宝箱
    FishType_YuanBao            = 25,           -- 元宝鱼
    FishType_General_Max        = 21,           -- 普通鱼最大
    FishType_Normal_Max         = 24,           -- 正常鱼最大
    FishType_Max                = 26,           -- 最大数量
    FishType_Small_Max          = 9,            -- 小鱼最大索引
    FishType_Moderate_Max       = 15,           -- 中鱼索
    FishType_Moderate_Big_Max   = 18,           -- 中大鱼索
    FishType_Big_Max            = 24,           -- 大鱼索引
    FishType_Invalid            = -1            -- 无效鱼
}

cmd.TraceType =
{
  TRACE_LINEAR = 0,
  TRACE_BEZIER = 1
}

cmd.FishKind =
{
  FISH_KIND_1 = 0,
  FISH_KIND_2 = 1,
  FISH_KIND_3 = 2,
  FISH_KIND_4 = 3,
  FISH_KIND_5 = 4,
  FISH_KIND_6 = 5,
  FISH_KIND_7 = 6,
  FISH_KIND_8 = 7,
  FISH_KIND_9 = 8,
  FISH_KIND_10 = 9,
  FISH_KIND_11 = 10,
  FISH_KIND_12 = 11,
  FISH_KIND_13 = 12,
  FISH_KIND_14 = 13,
  FISH_KIND_15 = 14,
  FISH_KIND_16 = 15,
  FISH_KIND_17 = 16,
  FISH_KIND_18 = 17,
  FISH_KIND_19 = 18,
  FISH_KIND_20 = 19, -- 企鹅
  FISH_KIND_21 = 20, -- 李逵
  FISH_KIND_22 = 21, -- 定屏炸弹
  FISH_KIND_23 = 22, -- 局部炸弹
  FISH_KIND_24 = 23, -- 超级炸弹
  FISH_KIND_25 = 24, -- 大三元1
  FISH_KIND_26 = 25, -- 大三元2
  FISH_KIND_27 = 26, -- 大三元3
  FISH_KIND_28 = 27, -- 大四喜1
  FISH_KIND_29 = 28, -- 大四喜2
  FISH_KIND_30 = 29, -- 大四喜3
  FISH_KIND_31 = 30, -- 鱼王1
  FISH_KIND_32 = 31, -- 鱼王2
  FISH_KIND_33 = 32, -- 鱼王3
  FISH_KIND_34 = 33, -- 鱼王4
  FISH_KIND_35 = 34, -- 鱼王5
  FISH_KIND_36 = 35, -- 鱼王6
  FISH_KIND_37 = 36, -- 鱼王7
  FISH_KIND_38 = 37, -- 鱼王8
  FISH_KIND_39 = 38, -- 鱼王9
  FISH_KIND_40 = 39, -- 鱼王10
  FISH_UNKNOWN = 40, -- will新增
  FISH_KIND_COUNT = 41
}
    
local enumFishState = 
{
    "FishState_Normal",     -- 普通鱼
    "FishState_King",		-- 鱼王
    "FishState_Killer",		-- 杀手鱼
    "FishState_Aquatic",	-- 水草鱼
}
cmd.FishState = ExternalFun.declarEnumWithTable(0,enumFishState)
-----------------------------------------------------------------------------------------------
--服务器命令结构

cmd.SUB_S_GAME_CONFIG			    =  7000     -- 游戏配置
cmd.SUB_S_FISH_TRACE			    =  7101     -- 鱼阵
cmd.SUB_S_EXCHANGE_FISHSCORE        =  7102	    -- 上下分
cmd.SUB_S_USER_FIRE                 =  7103	    -- 开炮
cmd.SUB_S_CATCH_FISH			    =  7104	    -- 捕获鱼
cmd.SUB_S_BULLET_ION_TIMEOUT        =  7105	    -- 无效
cmd.SUB_S_LOCK_TIMEOUT              =  7106	    -- 无效
cmd.SUB_S_CATCH_SWEEP_FISH          =  7707	    -- 捕获超级炸弹
cmd.SUB_S_CATCH_SWEEP_FISH_RESULT   =  7708	    -- 捕获超级炸弹的结果
cmd.SUB_S_HIT_FISH_LK               =  7709	    -- 无效
cmd.SUB_S_SWITCH_SCENE              =  7810     -- 场景切换
cmd.SUB_S_STOCK_OPERATE_RESULT      =  7811	    -- 无效
cmd.SUB_S_SCENE_END                 =  7812     -- 场景结束
cmd.SUB_S_STOCK_BALCK               =  7813     -- will新增   黑名单
cmd.SUB_S_TREASURE_BOX_RESULT       =  7815
cmd.SUB_S_FISH_OUT					=  7814
--cmd.SUB_S_CIRCLE_FIRSH              =  113    -- 小鱼群圆形
--cmd.SUB_S_BULLETSPEED_INDEX         =  114    -- 子弹档位速度

-----------------------------------------------------------------------------------------------
cmd.FISH_KIND_COUNT = 42
cmd.BULLET_MAX = 8

cmd.FPoint = 
{
	{ k = "x", t = "float"},
	{ k = "y", t = "float"}
}

-- 场景信息
cmd.CMD_S_GameStatus = 
{
    { k = "game_version",           t = "dword"                       },
    { k = "scene_time",             t = "int"                         },
    { k = "fish_score",             t = "score", l = {cmd.GAME_PLAYER}},
    { k = "exchange_fish_score",    t = "score", l = {cmd.GAME_PLAYER}},
    { k = "bullet_id_",             t = "int",   l = {cmd.GAME_PLAYER}},
    --{ k = "lMinTableScore",         t = "score"                       },
    --{ k = "playergrade",            t = "int"                         }
}

-- 游戏配置
cmd.CMD_S_GameConfig = 
{
    { k = "exchange_ratio_userscore",   t = "int"},
    { k = "exchange_ratio_fishscore",   t = "int"},
    { k = "exchange_count",             t = "int"},
    { k = "max_bullet_multiple",        t = "int"},
    { k = "min_bullet_multiple",        t = "int"},
    { k = "bomb_range_width",           t = "int"},
    { k = "bomb_range_height",          t = "int"},
    { k = "fish_multiple",              t = "int", l = {cmd.FISH_KIND_COUNT}},
    { k = "fish_speed",                 t = "int", l = {cmd.FISH_KIND_COUNT}},
    { k = "fish_bounding_box_width",    t = "int", l = {cmd.FISH_KIND_COUNT}},
    { k = "fish_bounding_box_height",   t = "int", l = {cmd.FISH_KIND_COUNT}},
    { k = "fish_hit_radius",            t = "int", l = {cmd.FISH_KIND_COUNT}},
    { k = "bullet_speed",               t = "int", l = {cmd.BULLET_MAX}     },
    { k = "net_radius",                 t = "int", l = {cmd.BULLET_MAX}     },
    --{ k = "config_time_fire",           t = "int"                           },
    --{ k = "config_random_fire",         t = "int"                           }
}

-- 鱼创建
cmd.CMD_S_FishTrace = 
{
    { k = "init_pos",   t = "table",  d = cmd.FPoint, l = {5}},
    { k = "init_count", t = "int"                            },
    { k = "fish_kind",  t = "int"                            },
    { k = "fish_id",    t = "int"                            },
    { k = "trace_type", t = "int"                            }
}

-- 上下分
cmd.CMD_S_ExchangeFishScore = 
{
    { k = "chair_id"            , t = "word" },
    { k = "swap_fish_score"     , t = "score"},
    { k = "exchange_fish_score" , t = "score"},
    { k = "fish_score" ,          t = "score"}
}

-- 开火
cmd.CMD_S_Fire = 
{
    { k = "bullet_kind",     t = "int"  },          -- 子弹关键值
    { k = "bullet_id",       t = "int"  },          -- 子弹关键值
    { k = "chair_id",        t = "word" },          -- 玩家位置
    { k = "android_chairid", t = "word" },			-- 玩家位置
    { k = "angle",           t = "float"},          -- 子弹分数
    { k = "bullet_mulriple", t = "int"  },			-- 子弹分数
    { k = "lock_fishid",     t = "int"  },          -- 追踪鱼索引
    { k = "fish_score",      t = "score"},          -- 倍数索引
    --{ k = "player_grade",    t = "int"  }           -- 位置
}

-- 捕获鱼
cmd.CMD_S_CatchFish = 
{
    { k = "chair_id",     t = "word" },
	{ k = "fish_id",      t = "int"  },
	{ k = "fish_kind",    t = "int"  },
    { k = "bullet_ion",   t = "bool" },
	{ k = "fish_score",   t = "score"},
    --{ k = "player_grade", t = "int"  }
}

-- will新增
cmd.CMD_S_BulletIonTimeout =
{
    { k = "chair_id",     t = "word" }
}

-- 炸弹
cmd.CMD_S_CatchSweepFish =
{
    { k = "chair_id", t = "word"},
    { k = "fish_id",  t = "int" }
}

-- 全屏炸弹返回数据
cmd.CMD_S_CatchSweepFishResult =
{
    { k = "chair_id",         t = "word"            },
    { k = "fish_id",          t = "int"             },
    { k = "fish_score",       t = "score"           },
    { k = "catch_fish_count", t = "int"             },
    { k = "catch_fish_id",    t = "int", l = {300}  },
    --{ k = "player_grade",     t = "int"             }
}

-- will新增
cmd.CMD_S_HitFishLK =
{
    { k = "chair_id",         t = "word"            },
    { k = "fish_id",          t = "int"             },
    { k = "fish_mulriple",    t = "int"             },
}

-- 转换场景
cmd.CMD_S_SwitchScene =
{
    { k = "scene_kind", t = "int"},
    { k = "fish_count", t = "int"},
    { k = "fish_kind",  t = "int", l = {300}},
    { k = "fish_id",    t = "int", l = {300}}
}

-- will新增
cmd.CMD_S_StockOperateResult =
{
    { k = "operate_code",       t = "byte"              },
    { k = "stock_score",        t = "score"             },
    { k = "control_score",      t = "score"             },
}

-- will新增
cmd.CMD_S_Fishout = 
{
    { k = "fish_kind",       t = "int"              },
}

-- will新增
cmd.CMD_S_TreasureBoxResult =
{
    { k = "chair_id",           t = "word"      },
    { k = "award",              t = "int"       },
    { k = "bullet_mulriple",    t = "int"       },
    { k = "fish_score",         t = "score"     },
}

-- 圆形鱼群
cmd.CMD_S_CircleFish =
{
    { k = "fish_kind",  t = "int"           },
    { k = "offsetx",    t = "int"           },
    { k = "offsety",    t = "int"           },
    { k = "fish_count", t = "int"           },
    { k = "fish_id",    t = "int", l = {300}}
}

-- 档位速度
cmd.CMD_S_BulletSpeedIndex =
{
    { k = "bulletSpeedIndex", t = "int", l = {6}}
}

-- 鱼创建完成
cmd.CMD_S_FishFinish = 
{
	{ k = "nOffSetTime", t = "dword"}
}

cmd.CMD_S_Multiple = 
{
    { k = "wChairID",       t = "word"},
    { k = "nMultipleIndex", t = "int" }
}

cmd.CMD_S_StayFish = 
{
    { k = "nFishKey",   t = "int"},
    { k = "nStayStart", t = "int"},
    { k = "nStayTime",  t = "int"}
}

cmd.CMD_S_AwardTip = 
{
    { k = "wTableID",      t = "word"          },
    { k = "wChairID",      t = "word"          },
    { k = "szPlayName",    t = "string", s = 32},
    { k = "nFishType",     t = "byte"          },
    { k = "nFishMultiple", t = "int"           },
    { k = "lFishScore",    t = "score"         },
    { k = "nScoreType",    t = "int"           }
}

cmd.CMD_S_UpdateGame = 
{
    { k = "nMultipleValue",     t = "int", l = {cmd.Multiple_Max}                                   },
    { k = "nCatchFishMultiple", t = "int", l = {cmd.FishType.FishType_Max,cmd.FishType.FishType_Max}},
    { k = "nBulletVelocity",    t = "int"                                                           },
    { k = "nBulletCoolingTime", t = "int"                                                           }
}

-----------------------------------------------------------------------------------------------
--客户端命令结构
cmd.SUB_C_EXCHANGE_FISHSCORE        =       9991            -- 购买子弹
cmd.SUB_C_USER_FIRE                 =       3512            -- 发送子弹
cmd.SUB_C_CATCH_FISH                =       7423            -- 命中消息
cmd.SUB_C_CATCH_SWEEP_FISH          =       5644            -- 炸弹消息
cmd.SUB_C_HIT_FISH_I                =       7135
cmd.SUB_C_STOCK_OPERATE             =       4136            -- 超管控制
cmd.SUB_C_USER_FILTER               =       7137            -- 加黑白名单
cmd.SUB_C_ANDROID_STAND_UP          =       7138            -- 机器人起立
cmd.SUB_C_FISH20_CONFIG             =       7139            -- 添加企鹅最多能打多少只
cmd.SUB_C_BALCK_OPERATE             =       7140            -- will新增
cmd.SUB_C_LOADBALCK_OPERATE         =       7141
cmd.SUB_C_OPEN_TREASURE_BOX         =       8655
--cmd.SUB_C_ANDROID_BULLET_MUL      =     10					-- 机器人换炮
--cmd.SUB_C_MAX_FISHSCORE           =     11					-- 最大上子弹
--cmd.SUB_C_BULLETSPEED_INDEX       =     12					-- 子弹速度档位

return cmd