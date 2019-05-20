local cmd = cmd or {}

cmd.VERSION                 =       appdf.VersionValue(6,7,0,1)     -- 游戏版本
cmd.KIND_ID                 =       308                             -- 游戏标识
cmd.GAME_PLAYER             =       1                               -- 游戏人数
cmd.ITEM_COUNT              =       14                              -- 图标数量
cmd.ITEM_X_COUNT            =       5                               -- 图标横坐标数量
cmd.ITEM_Y_COUNT            =       3                               -- 图标纵坐标数量
cmd.LINE_COUNT              =       9                               -- 压线数字
cmd.POINT_COUNT             =       40                              -- 跑马灯数量
cmd.GAME_STATUS_FREE        =       0                               -- 等待开始
cmd.GAME_STATUS_PLAY        =       100                             -- 叫分状态
cmd.MAX_MULTIPLE            =       5

-- 空闲状态
cmd.CMD_S_GameScene = 
{
	{ k = "lCellScore",          t = "score"             },      -- 基础积分
	{ k = "lUserScore",          t = "score"             },      -- 当前分数
	{ k = "lTableScore",         t = "score"             },      -- 单线分数
	{ k = "lLotteryScore",       t = "score"             },      -- 彩金总额
}                           

-- 命令定义
cmd.SUB_S_GameEnd           =       106             -- 游戏结束

-- 开始游戏
cmd.CMD_S_GameEnd = 
{
	{ k = "cbCardType",         t = "byte",     l = {cmd.ITEM_X_COUNT, cmd.ITEM_X_COUNT, cmd.ITEM_X_COUNT}  },      -- 卡片类型
    { k = "cbResultType",       t = "byte",     l = {cmd.LINE_COUNT}                                        },      -- 中奖类型
    { k = "cbResultMultiple",   t = "int",      l = {cmd.LINE_COUNT}                                        },      -- 中奖倍率
	{ k = "lUserScore",         t = "score"                                                                 },      -- 当前分数
	{ k = "lWinScore",          t = "score"                                                                 },      -- 输赢分数
	{ k = "nFreeCount",         t = "int"                                                                   },      -- 免费次数
	{ k = "lGetLottery",        t = "int"                                                                   },      -- 获取彩金
	{ k = "lLotteryScore",      t = "score"                                                                 }       -- 彩金总额
}

-- 命令定义
cmd.SUB_C_GameStart         =       6               -- 用户加注

-- 开始游戏
cmd.CMD_C_GameStart =
{
	{ k = "lTableScore",        t = "score"},       -- 单线分数
    { k = "nLineCount",         t = "int"}          -- 线数
}


return cmd