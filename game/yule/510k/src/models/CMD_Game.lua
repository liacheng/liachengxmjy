--[[--
游戏命令
]]

local cmd = cmd or {}

--游戏标识
cmd.KIND_ID                 = 238

--游戏人数
cmd.PLAYER_COUNT            = 4
--非法视图
cmd.INVALID_VIEWID          = 0
--默认座椅号
cmd.INVALID_CHAIRID         = 65535
--左边玩家视图
cmd.LEFT_VIEWID             = 4
--自己玩家视图
cmd.MY_VIEWID               = 1
--右边玩家视图
cmd.RIGHT_VIEWID            = 2
--上面玩家视图
cmd.TOP_VIEWID            = 3


cmd.FULL_COUNT                 = 108                                  --全牌数目
cmd.DISPATCH_COUNT             = 108                                  --发牌数目
cmd.MAX_COUNT                  = 28                                   --地主牌数
cmd.MAX_CARD_COUNT             = 28                                  
cmd.NORMAL_COUNT               = 27                                  --常规牌数
cmd.PUBLIC_CARD_COUNT          = 0                                   --底牌

--游戏状态
cmd.GAME_SCENE_FREE           = 0            --空闲状态 cmd.GAME_GAME_FREE
cmd.GAME_SCENE_PLAY           = 100          --游戏进行 cmd.GAME_SCENE_PLAY
cmd.GAME_SCENE_WAIT           = 101          --等待开始

--服务器命令结构
cmd.SUB_S_GAME_START        = 100           --游戏开始
cmd.SUB_S_OUT_CARD          = 104           --用户出牌
cmd.SUB_S_PASS_CARD         = 105           --用户放弃
cmd.SUB_S_CARD_INFO			= 106			--扑克信息
cmd.SUB_S_GAME_END          = 107           --游戏结束
cmd.SUB_S_CONTINUE_GAME	    = 108			--继续游戏
cmd.SUB_S_AUTOMATISM        = 109           --用户托管cmd.SUB_S_TRUSTEE

-- 倒计时
cmd.TAG_COUNTDOWN_READY     = 1
cmd.TAG_COUNTDOWN_OUTCARD   = 6

-- 游戏倒计时
cmd.COUNTDOWN_READY         = 30            -- 准备倒计时
cmd.COUNTDOWN_OUTCARD       = 30            -- 出牌倒计时35
cmd.COUNTDOWN_HANDOUTTIME   = 30            -- 首出倒计时

--询问好友标志
cmd.FRIEDN_FLAG_DECLAREWAR = 1 ----宣战
cmd.FRIEDN_FLAG_MINGDU = 3  ----明独
cmd.FRIEDN_FLAG_NORMAL = 4  ----正常

-- 游戏胜利方
cmd.kDefault                = -1
cmd.kLanderWin              = 0
cmd.kLanderLose             = 1
cmd.kFarmerWin              = 2
cmd.kFarmerLose             = 3

-- 春天标记
cmd.kFlagDefault            = 0
cmd.kFlagChunTian           = 1
cmd.kFlagFanChunTian        = 2
---------------------------------------------------------------------------------------

------
--服务端消息结构
------
--玩家托管事件
cmd.CMD_S_UserAutomatism =
{
  {k = "wChairID", t = "word"}, 
  {k = "bTrusee", t = "bool"}, 
}

--空闲状态
cmd.CMD_S_StatusFree = 
{   
    {k = "lCellScore", t = "score"},                            --单元积分
    {k = "bAutoStatus", t = "bool", l = {cmd.PLAYER_COUNT}},    --托管状态
}

--游戏状态
cmd.CMD_S_StatusPlay = 
{
	{k = "lCellScore", t = "score"},  						            --单元积分
    {k = "wHeadUser", t = "word"},                                      --庄家
	{k = "wCurrentUser", t = "word"},                                   --当前玩家
	{k = "wPartnerID", t = "word"},                                     --伙伴
    {k = "cbCardPartner", t = "byte"},                                  --伙伴牌
    {k = "bIsShowPartner", t = "bool"},                                 --是否显示伙伴
    {k = "cbGameStatus", t = "byte"},                                   --游戏状态
    {k = "cbCaiShu", t = "byte", l = {cmd.PLAYER_COUNT}},               --彩数
    {k = "wPersistInfo", t = "word", l = {2,2,2,2}},                    --游戏信息
    {k = "b510KCardRecord", t = "byte", l = {8,8,8}},                   --510k卡牌记录

	--等级变量
    {k = "cbMainValue", t = "byte"},                                    --主牌数值
    {k = "cbValueOrder", t = "byte", l = {cmd.PLAYER_COUNT}},           --等级数值

	--胜利信息
    {k = "wWinCount", t = "word"},                                      --胜利人数
    {k = "wWinOrder", t = "word", l = {cmd.PLAYER_COUNT}},              --胜利列表

	--出牌信息
    {k = "wTurnWiner", t = "word"},                                     --本轮胜者
    {k = "cbTurnCardType", t = "byte"},                                 --出牌类型
    {k = "cbTurnCardCount", t = "byte"},                                --出牌数目
    {k = "cbTurnCardData", t = "byte", l = {cmd.MAX_COUNT}},            --出牌数据
    {k = "cbMagicCardData", t = "byte", l = {cmd.MAX_COUNT}},           --变幻扑克

	--扑克信息
    {k = "cbHandCardData", t = "byte", l = {cmd.MAX_COUNT}},            --手上扑克
    {k = "cbHandCardCount", t = "byte", l = {cmd.PLAYER_COUNT}},        --扑克数目
    {k = "bAutoStatus", t = "byte", l = {4}},                           --托管状态
}

--发送扑克/游戏开始
cmd.CMD_S_GameStart = 
{
	--游戏信息
    {k = "cbMainValue", t = "byte"},                                    --主牌数值
    {k = "cbValueOrder", t = "byte", l = {cmd.PLAYER_COUNT}},           --等级数值
    {k = "wPersistInfo", t = "word", l = {2,2,2,2}},                    --游戏信息

	--扑克信息														
    {k = "wHeadUser", t = "word"},                                      --庄家
    {k = "wPartnerID", t = "word"},                                     --伙伴
    {k = "cbCardPartner", t = "byte"},                                  --伙伴牌
    {k = "wCurrentUser", t = "word"},                                   --当前玩家
    {k = "cbCardData", t = "byte", l = {cmd.MAX_COUNT - 1} },           --扑克列表
}

--用户出牌
cmd.CMD_S_OutCard = 
{
    {k = "bIsShowPartner", t = "bool"},                         --是否显示伙伴
    {k = "cbCardCount", t = "byte"},                            --出牌数目
    {k = "wCurrentUser", t = "word"},                           --当前玩家
    {k = "wOutCardUser", t = "word"},                           --出牌玩家
    {k = "TurnScore", t = "score"},		
    {k = "cbCaiShu", t = "byte", l = {cmd.PLAYER_COUNT}},       --彩数
    {k = "wWinOrder", t = "word", l = {cmd.PLAYER_COUNT}},      --名次信息
    {k = "bIsShowWinOrder", t = "bool"},                         --是否显示名次信息
    {k = "b510KCardRecord", t = "byte", l = {8,8,8}},                          
    {k = "cbCardData", t = "byte", l = {cmd.MAX_COUNT-1}},      --扑克列表
}

--放弃出牌
cmd.CMD_S_PassCard = 
{
    {k = "cbTurnOver", t = "byte"},                             --一轮结束
    {k = "wCurrentUser", t = "word"},                           --当前玩家
    {k = "wPassCardUser", t = "word"},                          --放弃玩家					
    {k = "TurnScore", t = "score"},                      
    {k = "PlayerScore", t = "score", l = {cmd.PLAYER_COUNT}},                         
}

--扑克信息
cmd.CMD_S_CardInfo =
{
    {k = "cbCardCount", t = "byte"},                            --扑克数目
    {k = "cbCardData", t = "byte", l = {cmd.MAX_COUNT}},        --扑克列表
}

--游戏结束
cmd.CMD_S_GameEnd = 
{
    {k = "TurnScore", t = "score"},                                 --单元积分
    {k = "PlayerScore", t = "score", l = {cmd.PLAYER_COUNT}},       --游戏输赢分

    --游戏成绩
    {k = "lGameScore", t = "score", l = {cmd.PLAYER_COUNT}},        --游戏积分

    --累计名次
    {k = "wPersistInfo", t = "word", l ={2,2,2,2}},                 --游戏信息

    --扑克信息
    {k = "cbCardCount", t = "byte", l = {cmd.PLAYER_COUNT}},        --扑克数目
    {k = "cbCardData", t = "byte", l = {28,28,28,28}},              --扑克列表
}
--游戏结束,约战
cmd.CMD_S_GameEndYueZhan = 
{	
    {k = "cbCaiShu", t = "byte", l = {cmd.PLAYER_COUNT}},           --彩数
    {k = "lBaseScore", t = "score", l = {cmd.PLAYER_COUNT}},        --基本得分
    {k = "lRoundScore", t = "score", l = {cmd.PLAYER_COUNT}},       --一局总得分
    --累计名次
    {k = "wPersistInfo", t = "word", l ={2,2,2,2}},                 --游戏信息

    --扑克信息
    {k = "cbCardCount", t = "byte", l = {cmd.PLAYER_COUNT}},        --扑克数目
    {k = "cbCardData", t = "byte", l = {28,28,28,28}},              --扑克列表
}
--用户继续
cmd.CMD_S_ContinueGame =
{
    {k = "wChairID", t = "word"},                                   --继续用户
}

---------------------------------------------------------------------客户端命令结构 -------------------------------          
cmd.SUB_C_OUT_CARD				= 1									--用户出牌
cmd.SUB_C_PASS_CARD				= 2									--用户放弃
cmd.SUB_C_CONTINUE_GAME			= 5									--继续游戏
cmd.SUB_C_AUTOMATISM			= 6									--托管消息 SUB_C_TRUSTEE

------
--客户端消息结构
------

--用户托管
cmd.CMD_C_Automatism = 
{                         
    {k = "bAutomatism", t = "bool"},                          
}

--用户出牌
cmd.CMD_C_OutCard = 
{
    {k = "cbCardCount", t = "byte"},                            --出牌数目
    {k = "cbCardData", t = "byte", l = {cmd.MAX_COUNT}},        --扑克数据
}

return cmd