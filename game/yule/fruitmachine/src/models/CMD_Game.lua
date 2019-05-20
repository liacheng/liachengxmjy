--此文件由[BabeLua]插件自动生成

--                            _ooOoo_  
--                           o8888888o  
--                           88" . "88  
--                           (| -_- |)  
--                            O\ = /O  
--                        ____/`---'\____  
--                      .   ' \\| |-- `.  
--                       / \\||| : |||-- \  
--                     / _||||| -:- |||||- \  
--                       | | \\\ - --/ | |  
--                     | \_| ''\---/'' | |  
--                      \ .-\__ `-` ___/-. /  
--                   ___`. .' /--.--\ `. . __  
--                ."" '< `.___\_<|>_/___.' >'"".  
--               | | : `- \`.;`\ _ /`;.`/ - ` : | |  
--                 \ \ `-. \_ __\ /__ _/ .-` / /  
--         ======`-.____`-.___\_____/___.-`____.-'======  
--                            `=---='  
--  
--         .............................................  
--                  佛祖保佑             永无BUG 

local cmd={}

--[[
******
* 结构体描述
* {k = "key", t = "type", s = len, l = {}}
* k 表示字段名,对应C++结构体变量名
* t 表示字段类型,对应C++结构体变量类型
* s 针对string变量特有,描述长度
* l 针对数组特有,描述数组长度,以table形式,一维数组表示为{N},N表示数组长度,多维数组表示为{N,N},N表示数组长度
* d 针对table类型,即该字段为一个table类型
* ptr 针对数组,此时s必须为实际长度

** egg
* 取数据的时候,针对一维数组,假如有字段描述为 {k = "a", t = "byte", l = {3}}
* 则表示为 变量a为一个byte型数组,长度为3
* 取第一个值的方式为 a[1][1],第二个值a[1][2],依此类推

* 取数据的时候,针对二维数组,假如有字段描述为 {k = "a", t = "byte", l = {3,3}}
* 则表示为 变量a为一个byte型二维数组,长度都为3
* 则取第一个数组的第一个数据的方式为 a[1][1], 取第二个数组的第一个数据的方式为 a[2][1]
******
--]]

cmd.KIND_ID = 132                                   --游戏 I D
cmd.GAME_PLAYER = 1					                --游戏人数
cmd.GAME_NAME = "水果机"			                --游戏名字

cmd.GAME_MAX_PLACE_JETTON = 99                      --最大次数

cmd.GAME_STATUS_FREE = 0
cmd.GAME_STATUS_PLAY = 100
cmd.GAME_STATUS_END = 101

--状态定义
cmd.GS_PLACE_JETTON	= cmd.GAME_STATUS_PLAY			--下注状态
cmd.GS_GAME_END = cmd.GAME_STATUS_PLAY+1			--结束状态

cmd.VERSION_SERVER	=		    "6.7.0.1"			--程序版本
cmd.VERSION_CLIENT	=			"6.7.0.1"			--程序版本


--下注按钮索引 
cmd.ID_APPLE = 1								    --苹果
cmd.ID_ORANGE = 2							        --橘子
cmd.ID_MANGO = 3							        --芒果
cmd.ID_BELL = 4									    --铃铛
cmd.ID_WATERMELON = 5				                --西瓜
cmd.ID_STAR = 6								        --星星
cmd.ID_SEVEN = 7								    --七七
cmd.ID_BAR = 8									    --bar

cmd.PATH_STEP_NUMBER		= 24					--转轴格子数
cmd.JETTON_AREA_COUNT		= 8						--下注区域数量
--------------------------------------------------------------------------
--服务器命令结构

cmd.SUB_S_GAME_START =	100						    --游戏开始
cmd.SUB_S_GAME_END =	101							--游戏结束
cmd.SUB_S_BIG_SMALL =	102							--猜大小

cmd.RES = "game/yule/fruitmachine/res/"

cmd.tabZhuanpanPos={
		cc.p(336,104),cc.p(336,198),cc.p(336,288),cc.p(336,372),cc.p(336,466),cc.p(336,550),cc.p(336,642),
		cc.p(429,642),cc.p(518,642),cc.p(610,642),cc.p(702,642),cc.p(792,642),cc.p(884,642),cc.p(884,550),
		cc.p(884,466),cc.p(884,372),cc.p(884,288),cc.p(884,198),cc.p(884,104),cc.p(794,104),cc.p(702,104),
		cc.p(612,104),cc.p(520,104),cc.p(430,104)
        }

--猜大小
cmd.CMD_S_BigSmall =
{
    {t="bool",k="bWin"},                                --猜大小成功 (0=失败，1=成功)
	{t="byte",k="cbBigSmall"},                         --大小的实际数值
	{t="score",k="lUserWinScore"},                       --玩家成绩
    {t="score",k="lUserScore"},                        --玩家分数
}

--游戏状态
cmd.CMD_S_StatusFree =
{
    {t="dword",k="dwChipRate"},                         --筹码比率
    {t="score",k="lUserScore"},                         --玩家分数
    {t="score",k="lCaiJin"},                            --彩金
}

--游戏状态
--[[cmd.CMD_S_StatusPlay =
{
    {t="dword",k="dwChipRate"},                         --筹码比率
    {t="score",k="lUserScore"},                         --玩家分数
    {t="score",k="lCaiJin"},                              --彩金
    {t="score",k="lUserAreaScore",l={cmd.JETTON_AREA_COUNT}}, --玩家下注

    --扑克信息
    {t="byte",k="cbWinArea"},                           --本次停止的位置
    {t="byte",k="cbGoodLuckType"},                      --开中GoodLuck
    {t="byte",k="cbPaoHuoCheCount"},                                   
    {t="byte",k="cbPaoHuoCheArea",l={7}},         
}

--游戏开始
cmd.CMD_S_GameStart =
{
    {t="dword",k="dwChipRate"},                          --筹码比率
    {t="score",k="lUserScore"},                          --玩家分数
    {t="score",k="lCaiJin"},                             --彩金
    {t="score",k="lUserWinScore"},                        --玩家成绩
    --{t="score",k="lUserReturnScore"},                   --返回积分
    --{t="score",k="lRevenue"},                           --游戏税收
}--]]

--游戏结束
cmd.CMD_S_GameEnd =
{
    {t="byte",k="cbWinArea"},                              --本次停止的位置
    {t="byte",k="cbGoodLuckType"},                         --开中GoodLuck
    {t="byte",k="cbPaoHuoCheCount"},                                   
    {t="byte",k="cbPaoHuoCheArea",l={7}},                                 
    --{t="score",k="lUserReturnScore"},                     --返回积分
    {t="dword",k="dwChipRate"},                          --筹码比率
    {t="score",k="lUserScore"},                             --玩家分数
    {t="score",k="lCaiJin"},                                --彩金
    {t="score",k="lUserWinScore"},                        --玩家成绩
    {t="score",k="lUserAreaScore",l={cmd.JETTON_AREA_COUNT}}, --玩家总注
}

--------------------------------------------------------------------------
--客户端命令结构
cmd.SUB_C_GAME_START = 1                        --开始游戏
cmd.SUB_C_BIG_SMALL  = 2			            --猜大小
--cmd.SUB_C_RUN_OVER   = 3                        --跑灯结束

--用户下注
cmd.CMD_C_PlaceJetton=
{
	{t="int",k="lAppleScore"},						        --苹果数目
    {t="int",k="lOrangeScore"},					            --橘子数目
    {t="int",k="lMangoScore"},					            --芒果数目
    {t="int",k="lBellScore"},						        --铃铛数目
    {t="int",k="lWatermelonScore"},			                --西瓜数目
    {t="int",k="lStarScore"},						        --星星数目
    {t="int",k="lSevenScore"},						        --七七数目
    {t="int",k="lBarScore"},						        --bar数目
}

--猜大小
cmd.CMD_C_BigSmall=
{
	{t="bool",k="cbBigSmall"},                  --猜大小（0=小、1=大）
    {t="score",k="lScore"},                             --比倍的分数
}

--跑灯结束
--[[cmd.CMD_C_RunOver=
{
	{t="byte",k="cbNothing"},						
}--]]

return cmd
--------------------------------------------------------------------------

