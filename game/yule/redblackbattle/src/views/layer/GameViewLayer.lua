--
-- Author: zhouweixiang
-- Date: 2016-11-28 14:17:03
--
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC.."HeadSprite")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
local Game_CMD = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.models.GameLogic")

local CardSprite = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.CardSprite")
local SitRoleNode = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.SitRoleNode")

--弹出层
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.SettingLayer")
local HelpLayer = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.HelpLayer")
local UserListLayer = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.UserListLayer")
local ApplyListLayer = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.ApplyListLayer")
local GameRecordLayer = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.GameRecordLayer")
local GameResultLayer = appdf.req(appdf.GAME_SRC.."yule.redblackbattle.src.views.layer.GameResultLayer")
local BankLayer = appdf.req(appdf.GAME_SRC .. "yule.redblackbattle.src.views.layer.BankLayer")

local GameViewLayer = class("GameViewLayer",function(scene)
        local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

local TAG_START             = 100
local enumTable = 
{
    "HEAD_BANKER",  --庄家头像
    "TAG_CARD",     --牌
    "BT_MENU",		--菜单按钮
    "BT_CARDTYPE",   --牌型
    "BT_LUDAN",     --路单
    "BT_BANK",		--银行
    "BT_CLOSEBANK", --关闭银行
    "BT_TAKESCORE",	--银行取款
    "BT_SET",       --设置
    "BT_QUIT",      --退出
    "BT_HELP",      --帮助
    "BT_SUPPERROB", --超级抢庄
    "BT_APPLY",     --申请上庄
    "BT_APPLYLIST", --申请上庄列表 
    "BT_USERLIST",  --用户列表                        
    "BT_JETTONAREA_1",--下注区域
    "BT_JETTONAREA_2",
    "BT_JETTONAREA_3",
    "BT_JETTONSCORE_1", --下注按钮    
    "BT_JETTONSCORE_2",
    "BT_JETTONSCORE_3",
    "BT_JETTONSCORE_4",
    "BT_JETTONSCORE_5",
    "BT_JETTONSCORE_6",
    "BT_JETTONSCORE_7",
    "BT_CONTINUECHIP",
    "BT_SEAT_0",       --坐下  
    "BT_SEAT_1",
    "BT_SEAT_2",
    "BT_SEAT_3",
    "BT_SEAT_4",  
    "BT_SEAT_5",
    "BT_CHAT",
    "TAG_GAMESYSTEMMESSAGE"
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(TAG_START, enumTable)

enumTable = {
    "ZORDER_JETTON_GOLD_Layer", --下注时游戏币层级
    "ZORDER_CARD_Layer", --牌层
    "ZORDER_Other_Layer", --用户列表层等
}
local ZORDER_LAYER = ExternalFun.declarEnumWithTable(8, enumTable)

local enumApply =
{
    "kCancelState",
    "kApplyState",
    "kApplyedState",
    "kSupperApplyed"
}

GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state

local enumtipType = 
{
    "TypeNoBanker",           --无人坐庄
    "TypeChangBanker",        --切换庄家
    "TypeSelfBanker",         --自己上庄
    "TypeContinueSend",       --继续发牌
    "TypeReSend",             --重新发牌
    "TypeBeginChip",          --开始下注
    "TypeStopChip",           --停止下注
}
local TIP_TYPE = ExternalFun.declarEnumWithTable(2, enumtipType)


local MaxTimes = 1   ---最大赔率

--下注数值
GameViewLayer.m_BTJettonScore = {100, 1000, 10000, 100000, 1000000, 5000000, 10000000}

--下注值对应游戏币个数
GameViewLayer.m_JettonGoldBaseNum = {1, 1, 2, 2, 3, 3, 4}
--获得基本游戏币个数
GameViewLayer.m_WinGoldBaseNum = {2, 2, 4, 4, 6, 6, 6}
--获得最多游戏币个数
GameViewLayer.m_WinGoldMaxNum = {6, 6, 8, 8, 12, 12, 12}

--发牌位置
local cardpoint = {cc.p(275, 588), cc.p(380, 588), cc.p(485, 588), cc.p(771, 588),cc.p(876, 588),cc.p(981, 588)}
--自己头像位置
local selfheadpoint = cc.p(86, 58)
--庄家头像位置
local bankerheadpoint = cc.p(408, 719) 
--玩家列表按钮位置
local userlistpoint = cc.p(1310, 195)

function GameViewLayer:ctor(scene)
	--注册node事件
    ExternalFun.registerNodeEvent(self)	

	self._scene = scene

    --初始化
    self:paramInit()

	--加载资源
	self:loadResource()

    ExternalFun.setBackgroundAudio("ingameBGMMono.wav")
end

function GameViewLayer:paramInit()
    --用户列表
    self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --是否显示菜单层
    self.m_bshowMenu = false

    --菜单栏
    self.m_menulayout = nil

    --庄家背景框
    self.m_bankerNode = nil
    --庄家名称
    self.m_bankerName = nil

    --自己背景框
    self.m_selfNode = nil

    --下注筹码
    self.m_JettonBtn = {}

    --下注按钮背后光
    self.m_JettonLight = nil

    --续投
    self.m_btContinue = nil

    --选中筹码
    self.m_nJettonSelect = 0

    --自己区域下注分
    self.m_lUserJettonScore = {}
    --自己下注总分
    self.m_lUserAllJetton = 0

    --玩家区域总下注分
    self.m_lAllJettonScore = {}
    --下注区域
    self.m_JettonArea = {}
    self.m_bAreaIsWin ={}

    --自己下注分数文字
    self.m_selfJettonScore = {}
    --总下注分数文字
    self.m_tAllJettonScore = {}
    --下注区域亮光
    self.m_JettAreaLight = {}

    --玩家游戏成绩
    self.m_lEndUserScore = 0
    --牌显示层
    self.m_cardLayer = nil
    self.m_cardType ={}

    --游戏币显示层
    self.m_goldLayer = nil

    --游戏币列表
    self.m_goldList = {{}, {}, {}}

    --玩家列表层
    self.m_userListLayer = nil

    --上庄列表层
    self.m_applyListLayer = nil

    --游戏银行层
    self.m_bankLayer = nil

    --游戏设置层
    self.m_settingLayer = nil
    --路单层
    self.m_GameRecordLayer = nil

    --游戏结算层
    self.m_gameResultLayer = nil

    --倒计时Layout
    self.m_timeLayout = nil

    --当前庄家
    self.m_wBankerUser = yl.INVALID_CHAIR
    --当前庄家分数
    self.m_lBankerScore = 0
    --当前庄家成绩
    self.m_lBankerWinAllScore = 0
    --庄家局数
    self.m_cbBankerTime = 0

    --系统能否做庄
    self.m_bEnableSysBanker = false

    --游戏状态
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    --剩余时间
    self.m_cbTimeLeave = 0

    --显示分数
    self.m_showScore = self:getMeUserItem().lScore or 0

    --最大下注
    self.m_lUserMaxScore = 0

    --申请条件
    self.m_lApplyBankerCondition = 0

    --区域限制
    self.m_lAreaLimitScore = 0

    --桌面扑克数据
    self.m_cbTableCardArray = {}
    --桌面扑克
    self.m_CardArray = {}

    --是否练习房，练习房不能使用银行
    self.m_bGenreEducate = false

    --自己占位
    self.m_nSelfSitIdx = nil

    --用户坐下配置
    self.m_tabSitDownConfig = {}
    self.m_tabSitDownUser = {}
    --自己坐下
    self.m_nSelfSitIdx = nil

    --座位
    self.m_TableSeat = {}

    --游戏结算数据
    --坐下玩家赢分
    self.m_lOccupySeatUserWinScore = nil

    --本局赢分
    self.m_lSelfWinScore = 0

    --本局返还分
    self.m_lSelfReturnScore = 0

    --庄家赢分
    self.m_lBankerWinScore = 0
    --庄家昵称
    self.m_tBankerName = ""

    --申请状态
    self.m_enApplyState = APPLY_STATE.kCancelState
    --游戏币抢庄提示
    self.m_bRobAlert = false
    --当前抢庄用户
    self.m_wCurrentRobApply = yl.INVALID_CHAIR

    --是否播放游戏币飞入音效
    self.m_bPlayGoldFlyIn = true
    --下注倒计时
    self.m_fJettonTime = 0.1

    --游戏开始动画
    self.m_spKing = nil
    self.m_spKingHead = nil
    self.m_spKingJian = nil
    self.m_spQueen = nil
    self.m_spQueenHead = nil
    self.m_spQueenHand = nil
    self.m_spQueenJian = nil    
    self.m_blackPKbg = nil
    self.m_redPKbg = nil    
    --牌型说明
    self.m_AreaExplain = nil

    --小路单
    self.m_bgLudanQiu = nil 
    self.m_bgLudanCardType = nil
    --是否显示续投
    self.m_bIsContiueChip = false
    --输赢人物头部效果图
    self.kingHead = nil
    self.queenHead = nil
    --下注开始标志
    self.m_bIsStartJetton = false
end

function GameViewLayer:loadResource()
    --加载卡牌纹理
    cc.Director:getInstance():getTextureCache():addImage("cards_s.png")

    local rootLayer, csbNode = ExternalFun.loadRootCSB("GameScene.csb", self)
	self.m_rootLayer = rootLayer
    self.m_scbNode = csbNode

	local function btnEvent( sender, eventType )
         ExternalFun.btnEffect(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    --点击事件
--	self:setTouchEnabled(true)
--	self:registerScriptTouchHandler(function(eventType, x, y)
--		return self:onEventTouchCallback(eventType, x, y)
--	end)

    --菜单栏
    self.m_menulayout = csbNode:getChildByName("im_menu")
    self.m_menulayout:retain()
    self.m_menulayout:removeFromParent()
    self.m_menulayout:setScale(0)
    self:addChild(self.m_menulayout, 99)
    --self.m_menulayout:release()

    --菜单按钮
    local btn = csbNode:getChildByName("bt_menu")
    btn:setTag(TAG_ENUM.BT_MENU)
    btn:addTouchEventListener(btnEvent)

    --银行
    btn = self.m_menulayout:getChildByName("bt_bank")
    btn:setTag(TAG_ENUM.BT_BANK)
    btn:addTouchEventListener(btnEvent)
    --btn:setEnabled(self._scene._gameFrame:GetServerType()==yl.GAME_GENRE_GOLD)

    --设置
    btn = self.m_menulayout:getChildByName("bt_setting")
    btn:setTag(TAG_ENUM.BT_SET)
    btn:addTouchEventListener(btnEvent)

    --帮助
    btn = self.m_menulayout:getChildByName("bt_help")
    btn:setTag(TAG_ENUM.BT_HELP)
    btn:addTouchEventListener(btnEvent)

    --退出
    btn = self.m_menulayout:getChildByName("bt_exit")
    btn:setTag(TAG_ENUM.BT_QUIT)
    btn:addTouchEventListener(btnEvent)

    --路单
    local luNode = csbNode:getChildByName("node_trend")
    btn = luNode:getChildByName("bt_ludan")
    btn:setTag(TAG_ENUM.BT_LUDAN)
    btn:addTouchEventListener(btnEvent)

    self.m_bgLudanQiu = luNode:getChildByName("bg_trend_small")
    self.m_bgLudanCardType = luNode:getChildByName("bg_trend")

    --申请上庄
    self.m_btnApply = csbNode:getChildByName("bt_apply")
    self.m_btnApply:setTag(TAG_ENUM.BT_APPLY)
    self.m_btnApply:addTouchEventListener(btnEvent)

    --申请上庄列表
    btn = csbNode:getChildByName("bt_banker_down")
    btn:setTag(TAG_ENUM.BT_APPLYLIST)
    btn:addTouchEventListener(btnEvent)

    --桌面显示的上庄列表
--    self.m_cblist = csbNode:getChildByName("node_cblist")

    --倒计时
    self.m_timeLayout = csbNode:getChildByName("layout_time")

    --庄家背景框
    self.m_bankerNode = csbNode:getChildByName("node_banker")

    --自己背景框
    self.m_selfNode = csbNode:getChildByName("node_self")

    --下注倒计时
    self.m_JettonTime = display.newSprite("#redblackbattle_img_time1.png")
        :setPosition(cc.p(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+40))
        :setVisible(false)
        :addTo(self,3)

    --下注筹码
    for i=1,7 do
        btn = csbNode:getChildByName("bt_jetton_"..i)
        btn:setTag(TAG_ENUM.BT_JETTONSCORE_1+(i-1))
        btn:addTouchEventListener(btnEvent)
        self.m_JettonBtn[i] = btn
    end
    --下注按钮背后光
    self.m_JettonLight = csbNode:getChildByName("im_jetton_effect")
    self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))

    self.m_btContinue = csbNode:getChildByName("bt_continue")
    self.m_btContinue:setTag(TAG_ENUM.BT_CONTINUECHIP)
    self.m_btContinue:addTouchEventListener(btnEvent)
    self.m_btContinue:setEnabled(false)

    local function ChipEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onJettonAreaClicked(sender:getTag()-TAG_ENUM.BT_JETTONAREA_1+1, sender)
        end
    end

    --下注区域
    for i=1,3 do
        local str = string.format("bt_area_%d", i)
        btn = csbNode:getChildByName(str)
        btn:setTag(TAG_ENUM.BT_JETTONAREA_1+(i-1))
        btn:addTouchEventListener(ChipEvent)
        self.m_JettonArea[i] = btn

        local txttemp = btn:getChildByName("txt_all_jetton")
        self.m_tAllJettonScore[i] = txttemp
        txttemp:setVisible(false)
        txttemp:setFontName("fonts/round_body.ttf")

        txttemp = btn:getChildByName("txt_self_jetton")
        self.m_selfJettonScore[i] = txttemp
        txttemp:setVisible(false)
        txttemp:setFontName("fonts/round_body.ttf")      

        txttemp = btn:getChildByName("im_win_light")
        self.m_JettAreaLight[i] = txttemp
        txttemp:setVisible(false)
    end

    self:initBankerInfo()
    self:initSelfInfo()

    --游戏币层
    self.m_goldLayer = cc.Layer:create()
        :setLocalZOrder(11)
        :addTo(self)

    --聊天
    self.m_btnChat = csbNode:getChildByName("bt_chat")
        :setTag(TAG_ENUM.BT_CHAT)
        :addTouchEventListener(btnEvent)

    --上庄排队
    self.m_txtWait = csbNode:getChildByName("text_wait")
    self.m_txtWait:setFontName("fonts/round_body.ttf")
    self.m_txtWait:setVisible(false)

    self.m_bShowExplain = false
    self.m_bShowMenu = false
    btn = csbNode:getChildByName("bt_cardtype")     
    btn:setTag(TAG_ENUM.BT_CARDTYPE)
    btn:addTouchEventListener(btnEvent)

    self.m_AreaExplain = csbNode:getChildByName("im_cardType")
    self.m_AreaExplain:retain()
    self.m_AreaExplain:removeFromParent()
    self.m_AreaExplain:setScale(0)
    self:addChild(self.m_AreaExplain,100)

end


--初始化庄家信息
function GameViewLayer:initBankerInfo()
    --庄家姓名
    self.m_bankerName = self.m_bankerNode:getChildByName("text_name")
    self.m_bankerName:setFontName("fonts/round_body.ttf")

    --庄家头像
--    self.m_spBankerHead = self.m_bankerNode:getChildByName("im_head")

	--庄家金币
	self.m_textBankerCoin = self.m_bankerNode:getChildByName("text_score")
    self.m_textBankerCoin:setFontName("fonts/round_body.ttf")

	--庄家成绩 
--	self.m_textBankerChengJi = self.m_bankerNode:getChildByName("text_score")
--    self.m_textBankerChengJi:setFontName("fonts/round_body.ttf")

    --庄家局数    
    self.m_spBankerRound = self.m_bankerNode:getChildByName("Img_banker")
	self.m_textBankerRound = self.m_spBankerRound:getChildByName("text_num")
    self.m_textBankerRound:setFontName("fonts/round_body.ttf")
end

--刷新庄家信息
function GameViewLayer:resetBankerInfo()
    local head = self.m_bankerNode:getChildByTag(TAG_ENUM.HEAD_BANKER)
    if self.m_wBankerUser == yl.INVALID_CHAIR then
        if self.m_bEnableSysBanker == true then 
            self.m_bankerName:setString("系统坐庄")
            self.m_textBankerCoin:setString(ExternalFun.formatScoreText(9999999999))

            if self.m_cbBankerTime > 0 then 
                self.m_spBankerRound:setVisible(true)
                self.m_textBankerRound:setString(""..self.m_cbBankerTime)
            else
                self.m_spBankerRound:setVisible(false)
                self.m_textBankerRound:setString("")
            end
        else
            self.m_bankerName:setString("无人坐庄")
            self.m_textBankerCoin:setString("")
        
            self.m_spBankerRound:setVisible(false)
            self.m_textBankerRound:setString("")
        end
    else
        local userItem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        self.m_bankerName:setString(ExternalFun.GetShortName(userItem.szNickName,14,10))
        local bankerstr = ExternalFun.formatScoreText(self.m_lBankerScore)
        self.m_textBankerCoin:setString(bankerstr)

        if self.m_cbBankerTime > 0 then 
            self.m_spBankerRound:setVisible(true)
            self.m_textBankerRound:setString(""..self.m_cbBankerTime)
        else
            self.m_spBankerRound:setVisible(false)
            self.m_textBankerRound:setString("")
        end
        if not head then 
        else
		    head:updateHead(userItem)
        end
    end
end

--初始化自己信息
function GameViewLayer:initSelfInfo()
    local userItem = self:getMeUserItem()
    --玩家头像
    local csbHead = self.m_selfNode:getChildByName("sp_head")     -- 头像处理
    local csbHeadX, csbHeadY = csbHead:getPosition()
    head = PopupInfoHead:createNormal(userItem, 85)
    head:setPosition(cc.p(csbHeadX, csbHeadY))   
	self.m_selfNode:addChild(head)

    --玩家名称
    self.m_textUserName = self.m_selfNode:getChildByName("text_name")
    self.m_textUserName:setFontName("fonts/round_body.ttf")
    self.m_textUserName:setString(userItem.szNickName)   
	--玩家金币
	self.m_textUserCoin = self.m_selfNode:getChildByName("text_score")
    self.m_textUserCoin:setFontName("fonts/round_body.ttf")
    self.m_textUserCoin:setString(userItem.lScore)   
    --玩家成绩
    self.m_textCj = self.m_selfNode:getChildByName("text_mark")
    self.m_textCj:setFontName("fonts/round_body.ttf")
    self.m_textCj:setString("0")   

end

--刷新自己信息
function GameViewLayer:resetSelfInfo()
    self.m_textUserCoin:setString(""..self.m_showScore)   
    self.m_textCj:setString(ExternalFun.formatScoreText(self.m_lEndUserScore))  
end

--开始下一局，清空上局数据
function GameViewLayer:resetGameData()
    if nil ~= self.m_cardLayer then
        self.m_cardLayer:stopAllActions()
    end
    
    for i=1,6 do
        if self.m_CardArray[i] ~= nil then
            self.m_CardArray[i]:removeFromParent()
            self.m_CardArray[i] = nil
        end        
    end

    for i=1,2 do
        if self.m_cardType[i] ~= nil then
            self.m_cardType[i]:removeFromParent()
            self.m_cardType[i] = nil
        end  
    end

    self.m_lAllJettonScore = {0,0,0}
    self.m_lUserJettonScore = {0,0,0}
    self.m_lUserAllJetton = 0
    self:updateAreaScore(false)

    for k,v in pairs(self.m_JettAreaLight) do
        v:stopAllActions()
        v:setVisible(false)
    end

    --游戏币清除
    self.m_goldLayer:removeAllChildren()
    self.m_goldList = {{}, {}, {}}

    if nil ~= self.m_gameResultLayer then
        self.m_gameResultLayer:setVisible(false)
    end

    self.m_bPlayGoldFlyIn = true
end

function GameViewLayer:onExit()
    self:stopAllActions()
    self:unloadResource()
    self.m_bgLudanQiu:removeFromParent()
    self.m_bgLudanQiu = nil
    self.m_bgLudanCardType:removeFromParent()
    self.m_bgLudanCardType = nil
end

--释放资源
function GameViewLayer:unloadResource()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("cards_s.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()

    self:getDataMgr():removeAllUser()
    self:getDataMgr():clearRecord()

    if nil ~= self.m_gameResultLayer then
        self.m_gameResultLayer:clear()
    end
end

function GameViewLayer:onButtonClickedEvent(tag, ref)
    
   	if TAG_ENUM.BT_MENU == tag then
		self:ShowMenu()
    elseif TAG_ENUM.BT_CARDTYPE == tag then      
        self:ShowExplain()
    elseif TAG_ENUM.BT_LUDAN == tag then
        if self.m_bShowExplain then
            self:ShowExplain()
        end
        if  nil == self.m_GameRecordLayer then 
            self.m_GameRecordLayer = GameRecordLayer:create(self)
            self:addChild(self.m_GameRecordLayer,20)
        else
            self.m_GameRecordLayer:onShow()
        end

        local recordList = self:getDataMgr():getGameRecord()     
        self.m_GameRecordLayer:refreshRecord(recordList)
        self.m_GameRecordLayer:refreshCardLu(recordList)
    elseif TAG_ENUM.BT_BANK == tag then
        self:ShowMenu()
        local rom = GlobalUserItem.GetRoomInfo()
		if nil ~= rom then
			if rom.wServerType ~= yl.GAME_GENRE_GOLD then
				showToast(cc.Director:getInstance():getRunningScene(), "当前房间禁止操作银行!", 1)
				return
			end
		end	

	    if 0 == GlobalUserItem.tabAccountInfo.cbInsureEnabled then
   	 	    showToast(cc.Director:getInstance():getRunningScene(), "初次使用，请先开通银行！", 1)
    	    return 
	    end
        if self.m_bankLayer == nil then
            self.m_bankLayer = BankLayer:create(self) 
            self:addChild(self.m_bankLayer,20)
        else
            self.m_bankLayer:onShow()
        end
        self.m_bankLayer:refreshBankScore()
    elseif TAG_ENUM.BT_CLOSEBANK == tag  then
        if nil ~= self.m_bankLayer then
            self.m_bankLayer:setVisible(false)
        end
    elseif TAG_ENUM.BT_TAKESCORE == tag then
        self:onTakeScore()
    elseif TAG_ENUM.BT_SET == tag then
        self:ShowMenu()
        if self.m_settingLayer == nil then 
 	        local mgr = self._scene._scene:getApp():getVersionMgr()
            local verstr = mgr:getResVersion(Game_CMD.KIND_ID) or "0"    	
            self.m_settingLayer = SettingLayer:create(verstr)
	        self:addChild(self.m_settingLayer, 20)
        else
            self.m_settingLayer:onShow()
        end
    elseif TAG_ENUM.BT_HELP == tag then
        self:ShowMenu()
        if nil == self.m_helpLayer then
            self.m_helpLayer = HelpLayer:create(self, Game_CMD.KIND_ID, 0)
            self:addChild(self.m_helpLayer, 20)
        else
            self.m_helpLayer:onShow()
        end
    elseif TAG_ENUM.BT_QUIT == tag then
        self:ShowMenu()
        self._scene:onQueryExitGame()
    --下注按钮
    elseif TAG_ENUM.BT_JETTONSCORE_1 <= tag and TAG_ENUM.BT_JETTONSCORE_7 >= tag then
        self:onJettonButtonClicked(ref:getTag()-TAG_ENUM.BT_JETTONSCORE_1+1, ref)
    --下注区域
    elseif TAG_ENUM.BT_JETTONAREA_1 <= tag and  TAG_ENUM.BT_JETTONAREA_3 >= tag then
         self:onJettonAreaClicked(ref:getTag()-TAG_ENUM.BT_JETTONAREA_1+1, ref)
    elseif tag == TAG_ENUM.BT_USERLIST then
        self:ShowMenu()
        if nil == self.m_userListLayer then
            self.m_userListLayer = UserListLayer:create()
            self:addToRootLayer(self.m_userListLayer, ZORDER_LAYER.ZORDER_Other_Layer)
        end

        local userList = self:getDataMgr():getUserList()
        self.m_userListLayer:showLayer()        
        self.m_userListLayer:refreshList(userList)
    elseif tag == TAG_ENUM.BT_APPLY then
        local state = self:getApplyState()
        self:applyBanker( state )     
    elseif tag == TAG_ENUM.BT_APPLYLIST then
        if self.m_bShowExplain then
            self:ShowExplain()
        end
        if nil == self.m_applyListLayer then
            self.m_applyListLayer = ApplyListLayer:create(self)
            self:addChild(self.m_applyListLayer, 20)
        else
            self.m_applyListLayer:onShow()
        end

        local userList = self:getDataMgr():getApplyBankerUserList()  
        self.m_applyListLayer:refreshList(userList)
    elseif tag == TAG_ENUM.BT_CHAT then 
        local item = self:getChildByTag(TAG_ENUM.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            item:resetData()
        else
            local gameSystemMessage = GameSystemMessage:create()
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(TAG_ENUM.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
    elseif tag == TAG_ENUM.BT_CONTINUECHIP then 
        self:getParentNode():sendContinueChip()
    else
        showToast(self,"功能尚未开放！",1)
	end
end

--下注响应
function GameViewLayer:onJettonButtonClicked(tag, ref)
    self.m_nJettonSelect = tag
    self.m_JettonLight:setPositionX(ref:getPositionX())
end

--下注区域
function GameViewLayer:onJettonAreaClicked(tag, ref)
    --print("下注"..tag)
    --非下注状态
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_JETTON or self.m_nJettonSelect == 0 or self.m_bIsStartJetton == false then
        return
    end

    if self:isMeChair(self.m_wBankerUser) == true then
        return
    end
    
    if self.m_bEnableSysBanker == 0 and self.m_wBankerUser == yl.INVALID_CHAIR then
        showToast(self,"无人坐庄，不能下注",1) 
        return
    end

    local jettonscore = GameViewLayer.m_BTJettonScore[self.m_nJettonSelect]
    local selfscore  = (jettonscore + self.m_lUserAllJetton)*MaxTimes
    if  selfscore > self.m_lUserMaxScore then
        showToast(self,"已超过个人最大下注值",1)
        self:setJettonEnable(false)
        return
    end

    local areascore = self.m_lAllJettonScore[tag] + jettonscore
    if areascore > self.m_lAreaLimitScore then
        showToast(self,"已超过该区域最大下注值",1)
        self:setJettonEnable(false)
        return
    end

    self.m_lUserAllJetton = self.m_lUserAllJetton + jettonscore
    if self.m_wBankerUser ~= yl.INVALID_CHAIR then
--        local allscore = jettonscore
--        for k,v in pairs(self.m_lAllJettonScore) do
--            allscore = allscore + v
--        end
--        allscore = allscore*maxTimes
        local allscore = 0
        if 3 == tag then
            allscore = jettonscore * 10
        else
            allscore = jettonscore
        end
        local tmpScore = self.m_lAllJettonScore[1] + self.m_lAllJettonScore[2] + self.m_lAllJettonScore[3] * 10
        allscore = allscore + tmpScore
        local score = math.min(self.m_lBankerScore-tmpScore,self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)  
        self:updateJettonList(score/10)  
        if allscore > self.m_lBankerScore then
            showToast(self,"总下注已超过庄家下注上限",1)           
            return
        end
    else      
        self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)
    end

    local userself = self:getMeUserItem()   
    self:getParentNode():SendPlaceJetton(jettonscore, tag-1)
    self.m_btContinue:setEnabled(false)
end

function GameViewLayer:showJettonTime(time)
    if time <= 3 and time > 0 then 
        self.m_JettonTime:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("redblackbattle_img_time%d.png",time)))
        self.m_JettonTime:setVisible(true)
        self.m_JettonTime:setScale(1)
        self.m_JettonTime:setOpacity(255)
        self.m_JettonTime:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeOut:create(0.5)))
    else
        self.m_JettonTime:stopAllActions()
        self.m_JettonTime:setVisible(false)
    end
end

function GameViewLayer:OnUpdataClockView(chair, time)
    local selfchair = self:getParent():GetMeChairID()
    local temp = self.m_timeLayout:getChildByName("txt_time")
    temp:setString(string.format("%02d", time))
    local temp1 = self.m_timeLayout:getChildByName("txt_time1")
    temp1:setString(string.format("%02d", time))
    temp1:setVisible(true)
    temp1:setScale(1)
    temp1:setOpacity(255)
    temp1:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeOut:create(0.5)))  

    if self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
        self:showJettonTime(time)    
    end  
    if chair == self:getParentNode():SwitchViewChairID(selfchair) then
        if self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
            self.m_bPlayGoldFlyIn = true
            self.m_fJettonTime = math.min(0.1, time)
            
        end
    else
        if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
            return
        end
        if time == self.m_cbTimeLeave then
              self:showCard()
        elseif time == self.m_cbTimeLeave-2  then
            --显示结算
            self:showGoldMove()   
            self:showGameEnd(true)     
        end
    end     
end

--获取数据
function GameViewLayer:getParentNode()
    return self._scene
end

function GameViewLayer:getMeUserItem()
    return self._scene:GetMeUserItem()
end

function GameViewLayer:isMeChair( wchair )
    local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
    if nil == useritem then
        return false
    else 
        return useritem.dwUserID == GlobalUserItem.dwUserID
    end
end

function GameViewLayer:addToRootLayer( node , zorder)
    if nil == node then
        return
    end

    self.m_rootLayer:addChild(node)
    node:setLocalZOrder(zorder)
end

function GameViewLayer:getChildFromRootLayer( tag )
    if nil == tag then
        return nil
    end
    return self.m_rootLayer:getChildByTag(tag)
end

function GameViewLayer:getDataMgr( )
    return self:getParentNode():getDataMgr()
end

function GameViewLayer:getApplyState(  )
    return self.m_enApplyState
end

function GameViewLayer:getApplyCondition(  )
    return self.m_lApplyBankerCondition
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
    local userItem = self:getMeUserItem()
    if nil ~= userItem then         
        return userItem.lScore >= self.m_lApplyBankerCondition
    else      
        return false
    end
end

--获取能否取消上庄
function GameViewLayer:getCancelable(  )
    return self.m_cbGameStatus == Game_CMD.GAME_SCENE_FREE
end

function GameViewLayer:logData(msg)
    local p = self:getParentNode()
    if nil ~= p.logData then
        p:logData(msg)
    end 
end

function GameViewLayer:showPopWait( )
    self:getParentNode():showPopWait()
end

function GameViewLayer:dismissPopWait( )
    self:getParentNode():dismissPopWait()
end

----网络消息处理------- 
function GameViewLayer:onGameSceneFree(cmd_table)
    --玩家分数
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_lApplyBankerCondition = cmd_table.lApplyBankerCondition
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self.m_lBankerWinAllScore = cmd_table.lBankerWinScore
    self.m_cbBankerTime = cmd_table.cbBankerTime
    self.m_bEnableSysBanker = cmd_table.bEnableSysbanker
    self.m_lAreaLimitScore = cmd_table.lAreaLimitScore
--    self.m_bGenreEducate = cmd_table.bGenreEducate
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self:ShowKingQueen()
    self:showGameStatus()
    self:resetBankerInfo()
    self:resetSelfInfo()
    self.m_lAllJettonScore = {0,0,0}
    self.m_lUserJettonScore = {0,0,0}
    self.m_lUserAllJetton = 0
    self:setJettonEnable(false)
    self.m_bIsStartJetton = false
    self:updateAreaScore(false)
    --self:updateJettonList(self.m_lUserMaxScore)
        --申请按钮状态更新
    self:refreshApplyBtnState()
end

function GameViewLayer:onGameScenePlaying(cmd_table)
    --玩家分数
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_lApplyBankerCondition = cmd_table.lApplyBankerCondition
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self.m_lBankerWinAllScore = cmd_table.lBankerWinScore
    self.m_cbBankerTime = cmd_table.cbBankerTime
    self.m_bEnableSysBanker = cmd_table.bEnableSysbanker
    self.m_lAreaLimitScore = cmd_table.lAreaLimitScore
    self.m_bGenreEducate = cmd_table.bGenreEducate
    self.m_cbGameStatus = cmd_table.cbGameStatus
    local temp = cmd_table.lEndUserScore 
    self.m_lEndUserScore = temp + self.m_lEndUserScore
    self:showGameStatus()
    self:resetBankerInfo()
    self:resetSelfInfo()   
    self.m_lAllJettonScore = cmd_table.lAllJettonScore[1]
    self.m_lUserJettonScore = cmd_table.lUserJettonScore[1]

--    self.m_lSelfWinScore = cmd_table.lUserScore
--    self.m_lSelfReturnScore = cmd_table.lUserReturnScore

    local bankername = "系统坐庄"
    if  self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    self.m_tBankerName = bankername

    self.m_cbTableCardArray = cmd_table.cbTableCardArray
    self.m_bAreaIsWin = cmd_table.bAreaIsWin
    self:ShowKingQueen()
    self:GameSenceShowCard()
    self:GameSencePlayShowGlod()
    if cmd_table.cbGameStatus == Game_CMD.GAME_SCENE_JETTON and (self.m_bEnableSysBanker ~= false or self.m_wBankerUser ~= yl.INVALID_CHAIR) then
        self:setJettonEnable(true)  
        self.m_bIsStartJetton = true    
        self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)                   
        self:updateAreaScore(true)      
    else
        self:setJettonEnable(false)
        self.m_bIsStartJetton = false
        if cmd_table.cbGameStatus == Game_CMD.GAME_SCENE_END then
            if self.m_cardLayer == nil then
                self.m_cardLayer = cc.Layer:create()
                self:addToRootLayer(self.m_cardLayer, ZORDER_LAYER.ZORDER_CARD_Layer)
            end
            self:GameSenceEndShowCard()        
            self:showGoldMove()      
            self:showGameEnd(true)       
        end
    end    
    --申请按钮状态更新
    self:refreshApplyBtnState()
end

--空闲
function GameViewLayer:onGameFree(cmd_table)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self:showGameStatus()
    self:setJettonEnable(false)
    self.m_bIsStartJetton = false
    self.m_lAllJettonScore = {0,0,0}
    self.m_lUserJettonScore = {0,0,0}
    self.m_bAreaIsWin = {false,false,false}
    self:resetGameData()
    self:removeHead()
    --申请按钮状态更新
    self:refreshApplyBtnState()
end

--开始下注
function GameViewLayer:onGameStart(cmd_table)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_JETTON
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self:showGameStatus()
    self:resetBankerInfo()   
    --self:updateJettonList(self.m_lUserMaxScore)    
       
    self.m_cardLayer = cc.Layer:create()
    self.m_bIsContiueChip = cmd_table.bIsContiueChip
    self:addToRootLayer(self.m_cardLayer, ZORDER_LAYER.ZORDER_CARD_Layer)
--    print("下注最大值,",self.m_lUserMaxScore)
    if self:isMeChair(self.m_wBankerUser) == true then
        self:setJettonEnable(false)       
    end
--    self.m_nJettonSelect = 0
--    self.m_lAllJettonScore = {0,0,0}
--    self.m_lUserJettonScore = {0,0,0}
--    self.m_bAreaIsWin = {false,false,false}
--    self:resetGameData()
    --申请按钮状态更新
    self:refreshApplyBtnState()
end

--结束
function GameViewLayer:onGameEnd(cmd_table)
    self:showGameTips(TIP_TYPE.TypeStopChip)
    --dump(cmd_table, "比赛结束信息", 10)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_END
    self.m_cbTableCardArray = cmd_table.cbTableCardArray
    self.m_lSelfWinScore = cmd_table.lUserScore
    self.m_lSelfReturnScore = cmd_table.lUserReturnScore
    self.m_lBankerWinScore = cmd_table.lBankerScore
    self.m_lOccupySeatUserWinScore = cmd_table.lOccupySeatUserWinScore
    self.m_lBankerWinAllScore = cmd_table.lBankerTotallScore
    self.m_cbBankerTime = cmd_table.nBankerTime
    self.m_bAreaIsWin = cmd_table.bAreaIsWin
    self.m_showScore = self.m_showScore +  self.m_lSelfWinScore - self.m_lSelfReturnScore
    self.m_lEndUserScore = self.m_lSelfWinScore - self.m_lSelfReturnScore + self.m_lEndUserScore      
    local bankername = "系统坐庄"
    if  self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    if self.m_cardLayer == nil then
        self.m_cardLayer = cc.Layer:create()
        self:addToRootLayer(self.m_cardLayer, ZORDER_LAYER.ZORDER_CARD_Layer)
    end
    self.m_tBankerName = bankername
    self:showGameStatus()
    self:setJettonEnable(false)
    self.m_btContinue:setEnabled(false)
    self.m_bIsStartJetton = false
--    self.m_nJettonSelect = 0
end

--用户下注
function GameViewLayer:onPlaceJetton(cmd_table)
    if self:getParent():GetMeChairID() == cmd_table.wChairID then
        local oldscore = self.m_lUserJettonScore[cmd_table.cbJettonArea+1]
        self.m_lUserJettonScore[cmd_table.cbJettonArea+1] = oldscore + cmd_table.lJettonScore     
    end
    
    oldscore = self.m_lAllJettonScore[cmd_table.cbJettonArea+1]
    self.m_lAllJettonScore[cmd_table.cbJettonArea+1] = oldscore + cmd_table.lJettonScore

   -- dump(self.m_lAllJettonScore)
    self:showUserJetton(cmd_table)
    self:updateAreaScore(true)
end

--下注失败
function GameViewLayer:onPlaceJettonFail(cmd_table)
    if self:isMeChair(cmd_table.wPlaceUser) == true then
        self.m_lUserAllJetton = self.m_lUserAllJetton - cmd_table.lPlaceScore 
    end
end

--提前开牌
function GameViewLayer:onAdvanceOpenCard()
    showToast(self, "下注已超上限，提前开牌", 1)
end

--申请上庄
function GameViewLayer:onApplyBanker( cmd_table)
    if self:isMeChair(cmd_table.wApplyUser) == true then
        self.m_enApplyState = APPLY_STATE.kApplyState
    end
    self:refreshApplyList()
    self:refreshApplyWait()
end

--切换庄家
function GameViewLayer:onChangeBanker(cmd_table)
    --上一个庄家是自己，且当前庄家不是自己，标记自己的状态
    if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
        self.m_enApplyState = APPLY_STATE.kCancelState
    end
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self.m_cbBankerTime = 0
    self.m_lBankerWinAllScore = 0
    self:resetBankerInfo()
    --print("切换庄家", cmd_table.lBankerScore)

    self:showGameTips(TIP_TYPE.TypeChangBanker)

    --自己上庄
    if self:isMeChair(cmd_table.wBankerUser) == true then
        self.m_enApplyState = APPLY_STATE.kApplyedState
    end
    self:refreshApplyWait()
end

--取消申请
function GameViewLayer:onGetCancelBanker(cmd_table)
    if self:isMeChair(cmd_table.wCancelUser) == true then
        self.m_enApplyState = APPLY_STATE.kCancelState
    end

    self:refreshApplyList()
    self:refreshApplyWait()
end

function GameViewLayer:refreshApplyWait()
    local userList = self:getDataMgr():getApplyBankerUserList()    
    if #userList > 0 then
        self.m_txtWait:setString(string.format("%d人排队", #userList))
        self.m_txtWait:setVisible(true)
    else
        self.m_txtWait:setVisible(false)
    end
end

--续投
function GameViewLayer:onContinueJetton(cmd_table)
    local base = 0 
    local score = 0
    local chipnum = 0 
    local chipscore = 0
    local allScore = 0 
    for i = 1, 3 do
        chipscore = cmd_table.lLastAllJettonPlace[1][i]	    
        allScore = chipscore + allScore
        for j = 7, 1, -1 do
            if chipscore >= GameViewLayer.m_BTJettonScore[j] then
                base = GameViewLayer.m_BTJettonScore[j]
			    score = chipscore - (chipscore % base)
			    chipscore = chipscore % base
                chipnum = score/base              
                for k = 1, chipnum do
                    self._scene:SendPlaceJetton(GameViewLayer.m_BTJettonScore[j], i - 1)
                end			        
            end
        end	  
    end  
    self.m_btContinue:setEnabled(cmd_table.bIsContinueChip)
    local userScore = self.m_showScore - allScore
    self:updateJettonList(userScore)
end

--抢庄条件
function GameViewLayer:onGetApplyBankerCondition( llCon , rob_config)
    self.m_llCondition = llCon
    self:refreshCondition()
end

--座位坐下
function GameViewLayer:onGetSitDown( index, wchair, bAni )
    if wchair ~= nil 
        and nil ~= index
        and index ~= Game_CMD.SEAT_INVALID_INDEX 
        and wchair ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[wchair + 1]

        if nil ~= useritem then
            --下标加1
            index = index + 1
            if nil == self.m_tabSitDownUser[index] then
                self.m_tabSitDownUser[index] = SitRoleNode:create(self, index)
                self.m_tabSitDownUser[index]:setPosition(self.m_TableSeat[index]:getPosition())
                self:addToRootLayer(self.m_tabSitDownUser[index], 1)
            end
            self.m_tabSitDownUser[index]:onSitDown(useritem, bAni, wchair == self.m_wBankerUser)

            if useritem.dwUserID == GlobalUserItem.tabAccountInfo.dwUserID then
                self.m_nSelfSitIdx = index
            end
        end
    end
end

--座位失败/离开
function GameViewLayer:onGetSitDownLeave( index )
    if index ~= Game_CMD.SEAT_INVALID_INDEX 
        and nil ~= index then
        index = index + 1
        if nil ~= self.m_tabSitDownUser[index] then
            self.m_tabSitDownUser[index]:removeFromParent()
            self.m_tabSitDownUser[index] = nil
        end

        if self.m_nSelfSitIdx == index then
            self.m_nSelfSitIdx = nil
        end
    end
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
    local bank_success = self:getParentNode().bank_success
    if nil == bank_success then
        return
    end
    GlobalUserItem.tabAccountInfo.lUserScore = bank_success.lUserScore
    GlobalUserItem.tabAccountInfo.lUserInsure = bank_success.lUserInsure

    if nil ~= self.m_bankLayer and true == self.m_bankLayer:isVisible() then
        self.m_bankLayer:refreshBankScore()
    end

    showToast(self, bank_success.szDescribrString, 2)
end

--银行操作失败
function GameViewLayer:onBankFailure( )
    local bank_fail = self:getParentNode().bank_fail
    if nil == bank_fail then
        return
    end

    showToast(self, bank_fail.szDescribeString, 2)
end

--银行资料
function GameViewLayer:onGetBankInfo(bankinfo)
    bankinfo.wRevenueTake = bankinfo.wRevenueTake or 10
    if nil ~= self.m_bankLayer then
        local str = "温馨提示:取款将扣除" .. bankinfo.wRevenueTake .. "‰的手续费"
--        self.m_bankLayer.m_textTips:setString(str)
    end
end

-------界面显示更新--------
--菜单栏操作
function GameViewLayer:ShowExplain()
    local fSpeed = 0.2
	local fScale = 0

    if self.m_bShowExplain then
        fScale = 0      		
        self.m_AreaExplain:setTouchEnabled(false)
	else
		fScale = 1
        self.m_AreaExplain:setTouchEnabled(true)
        if self.m_bShowMenu then 
             self:ShowMenu()
        end
	end

    --背景图移动
    self.m_bShowExplain = not self.m_bShowExplain
    self.m_AreaExplain:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1)) 
end

function GameViewLayer:ShowMenu()
    local fSpeed = 0.2
	local fScale = 0

    if self.m_bShowMenu then
		fScale = 0
	else
		fScale = 1
        if self.m_bShowExplain then 
             self:ShowExplain()
        end     
	end

    --背景图移动
    self.m_bShowMenu = not self.m_bShowMenu
    self.m_menulayout:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))   
end

--更新游戏状态显示
function GameViewLayer:showGameStatus()
    local content = self.m_timeLayout:getChildByName("im_txt")
    local time = self.m_timeLayout:getChildByName("txt_time")
    time:setString(string.format("%02d", self.m_cbTimeLeave))

    local temp1 = self.m_timeLayout:getChildByName("txt_time1")
    temp1:setString(string.format("%02d", self.m_cbTimeLeave))
    temp1:setVisible(true)
    temp1:setScale(1)
    temp1:setOpacity(255)
    temp1:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeOut:create(0.5)))

    if self.m_cbGameStatus == Game_CMD.GAME_SCENE_FREE then
        --print("空闲")
        content:loadTexture("redblackbattle_icon_info2.png", UI_TEX_TYPE_PLIST)
    elseif self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
        --print("下注")
        content:loadTexture("redblackbattle_icon_info3.png", UI_TEX_TYPE_PLIST)
    elseif self.m_cbGameStatus == Game_CMD.GAME_SCENE_END then   
        --print("开牌")
        content:loadTexture("redblackbattle_icon_info1.png", UI_TEX_TYPE_PLIST) 
    end
end

--发牌动画
function GameViewLayer:sendCard()
    for j=1,2 do
        for i=1,3 do
            local index = (i+(j-1)*3)
            local temp = CardSprite:createCard(0)
            temp:setVisible(true)
            temp:setAnchorPoint(0, 0.5)
            temp:setTag(TAG_ENUM.TAG_CARD)
            temp:setPosition(637,584)
            temp:setScale(0.8)
            temp:showCardBack(true)
            temp:setLocalZOrder(9)
            temp:addTo(self)   
            self.m_CardArray[index] = temp    
            temp:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*index),cc.MoveTo:create(0.1, cardpoint[index]),cc.CallFunc:create(
                        function()
                            if i == 1 then
                                ExternalFun.playSoundEffect("send_card.wav")
                            end                      
                        end
                    )))
        end    
    end  
end

function GameViewLayer:showFunction(index,value)      
    if self.m_CardArray[index] == nil then
        return
    end  
    
    local sprite = display.newSprite()
            :setPosition(cardpoint[index])
            :addTo(self)
            :setLocalZOrder(5)
            :setAnchorPoint(0, 0.5)
            :setScale(0.8)
    local animation = cc.Animation:create()
    for j = 1, 3 do
        local frameName = string.format("redblackbattle_icon_fanpai%d.png", j)
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        animation:addSpriteFrame(spriteFrame)
    end  
    animation:setDelayPerUnit(0.1)          -- 设置两个帧播放时间                   
    animation:setRestoreOriginalFrame(true)    -- 动画执行后还原初始状态   
    self.m_CardArray[index]:setVisible(false)    
    local action = cc.Animate:create(animation)            
    sprite:runAction(cc.Sequence:create(action,cc.CallFunc:create( function()
        sprite:removeFromParent()
        if self.m_CardArray[index] ~= nil then
            self.m_CardArray[index]:removeFromParent()   
            self.m_CardArray[index] = nil   
        end
        local temp = CardSprite:createCard(value)
        temp:setAnchorPoint(0, 0.5)
        temp:setTag(TAG_ENUM.TAG_CARD) 
        temp:setScale(0.8)   
        temp:setLocalZOrder(9)
        temp:addTo(self)  
        temp:setPosition(cardpoint[index]) 
        self.m_CardArray[index] = temp

        if index == 3 or index == 6 then
            local savetype = GameLogic:getCardType(self.m_cbTableCardArray[index/3])
            self:setCardType(index,savetype)
        end
    end )
    )) 
end

function GameViewLayer:setCardType(cardIndex,cardType)
    local frameName  = string.format("#redblackbattle_icon_cardtype_show%d.png",cardType)   
	self.m_cardType[cardIndex/3] = display.newSprite(frameName)         
    self.m_cardType[cardIndex/3]:setPosition(cardpoint[cardIndex-1].x+30,cardpoint[cardIndex-1].y-20)          	
	self.m_cardType[cardIndex/3]:addTo(self)		 
    self.m_cardType[cardIndex/3]:setLocalZOrder(10)  
end

--显示牌
function GameViewLayer:showCard()
    if self.m_cardLayer == nil then 
        return
    end
    local time = 0.1
    for j=1,2 do
        for i=1,3 do
            local index = (i+(j-1)*3)
            self.m_cardLayer:runAction(cc.Sequence:create(cc.DelayTime:create(time*index+(j-1)*0.5), cc.CallFunc:create(
                function ()
                    ExternalFun.playSoundEffect("open_card.wav")     
                    self:showFunction(index,self.m_cbTableCardArray[j][i])      
                end
                ))) 
        end 
    end
    self:ShowWinLight(1)
end

function GameViewLayer:ShowWinLight(delaytime)
    local function lightfunction()
        for i=1,3 do
            if self.m_bAreaIsWin[1][i] and nil ~= self.m_JettAreaLight[i] then
                self.m_JettAreaLight[i]:setVisible(true)
                self.m_JettAreaLight[i]:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
            end
        end

        if self.m_bAreaIsWin[1][1] then
            self:runKingWin(true)
        else
            self:runKingWin(false)
        end
    end

    self.m_cardLayer:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime), cc.CallFunc:create(
        function ()
            lightfunction()             
        end
        )))
end

--显示用户下注
function GameViewLayer:showUserJetton(cmd_table)
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_JETTON then
        return
    end
    local cbJettonArea = cmd_table.cbJettonArea+1
    if cbJettonArea < 1 or cbJettonArea > 3 then 
        return 
    end

    local isMeJetton = 0
    local beginPos = userlistpoint
    if self:isMeChair(cmd_table.wChairID) == true then
        beginPos = selfheadpoint
        isMeJetton = 1
    end
    
    local endPos = self:getJettonPos(cbJettonArea)
    local spJetton,tag = self:getJettonImage(cmd_table.lJettonScore)
    local pgold = cc.Sprite:createWithSpriteFrameName(spJetton)
    pgold:setPosition(beginPos)
    pgold.isMeJetton = isMeJetton
    pgold.score = cmd_table.lJettonScore
    self.m_goldLayer:addChild(pgold)

    pgold:runAction(cc.MoveTo:create(0.33, endPos)) 

    table.insert(self.m_goldList[cbJettonArea], pgold)
end

function GameViewLayer:getJettonImage(JettonScore)
    local tag = 1 
    if JettonScore == 100 then 
        tag = 1
    elseif JettonScore == 1000 then 
        tag = 2
    elseif JettonScore == 10000 then 
        tag = 3
    elseif JettonScore == 100000 then 
        tag = 4
    elseif JettonScore == 1000000 then 
        tag = 5
    elseif JettonScore == 5000000 then 
        tag = 6
    elseif JettonScore == 10000000 then 
        tag = 7
    end
    local sp = "redblackbattle_icon_chip"..tag..".png"
    return sp,tag
end

function GameViewLayer:getJettonPos(Area)
    local nodeArea = self.m_scbNode:getChildByName("bt_area_"..Area)
    local nodeSize = cc.size(nodeArea:getContentSize().width - 300, nodeArea:getContentSize().height - 90);
	local xOffset = math.random()
	local yOffset = math.random()    
    --chip:runAction(cc.MoveTo:create(0.2, cc.p(445+ math.random(451), 320 + math.random(161))))

	local posX = nodeArea:getPositionX() - nodeArea:getAnchorPoint().x * nodeSize.width
	local posY = nodeArea:getPositionY() - nodeArea:getAnchorPoint().y * nodeSize.height
	local pos = cc.p(xOffset * nodeSize.width + posX, yOffset * nodeSize.height + posY)
	return pos
end

--结算游戏币处理
function GameViewLayer:showGoldMove()
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    local winAreaNum = 0
    local winScore = 0
    for i=1,Game_CMD.AREA_COUNT do
        --表示该区域庄家赢分
        if self.m_bAreaIsWin[1][i]==false then
            winAreaNum = winAreaNum + 1
            winScore = winScore + self.m_lAllJettonScore[i]
            self:showGoldToZ(i)
        else
            self:showGoldZToArea(i)
            self:showGoldToUser(i)
        end
    end
end

--显示游戏币飞到庄家处
function GameViewLayer:showGoldToZ(cbArea)
    local goldnum = #self.m_goldList[cbArea]
    if goldnum == 0 then
        return
    end
    ExternalFun.playSoundEffect("coinCollide.wav")

    local timeGap = 0.5/goldnum

    for i=goldnum, 1, -1 do
        local pgold = self.m_goldList[cbArea][i]
--        table.remove(self.m_goldList[cbArea], i)
--        table.insert(self.m_goldList[cbArea], pgold)
        if pgold then             
            local moveaction = cc.MoveTo:create(0.3, cc.p(bankerheadpoint.x,bankerheadpoint.y))              
            pgold:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create((i-1)*timeGap), 
                    moveaction,
                    cc.CallFunc:create(
                        function (ref)
                            ref:setVisible(false)
                        end)
                )
            )                        
        end
    end

--    for i=goldnum, 1, -1 do
--        local pgold = self.m_goldList[cbArea][i]
--        table.remove(self.m_goldList[cbArea], i)
--        table.insert(self.m_goldList[1], pgold)
--        outnum = outnum + 1
--        if pgold then             
--            local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), bankerheadpoint, 1, 0)
--            pgold:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.03), moveaction, cc.CallFunc:create(
--                    function (ref)
--                        ref:setVisible(false)
--                    end
--                )))                        
--        end
--        if outnum >= cellnum then
--            cellindex = cellindex + 1
--            outnum = 0
--        end
--    end
end

function GameViewLayer:showGoldZToArea(cbArea)
    local goldnum = #self.m_goldList[cbArea]
    if goldnum == 0 then
        return
    end
    local timeGap = 0.5/goldnum

    for i = 1 ,goldnum do        
        local spJetton,tag = self:getJettonImage(self.m_goldList[cbArea][i].score)
        local pgold = cc.Sprite:createWithSpriteFrameName(spJetton)
        pgold.isMeJetton = 0
        if self.m_goldList[cbArea][i].isMeJetton == 1 then 
            pgold.isMeJetton = 1
        end
        pgold:setPosition(bankerheadpoint)

        self.m_goldLayer:addChild(pgold)
        table.insert(self.m_goldList[cbArea], pgold)
        local moveaction = cc.MoveTo:create(0.3, cc.p(self:getJettonPos(cbArea)))       
        pgold:runAction(
            cc.Sequence:create(
            cc.DelayTime:create((i-1)*timeGap + 0.8), 
            moveaction)
        )
    end
    
--    local cellnum = math.floor(goldnum/10)
--    if cellnum == 0 then
--        cellnum = 1
--    end
--    local cellindex = 0
--    local outnum = 0

--    for i = 1 ,goldnum do        
--        local spJetton,tag = self:getJettonImage(self.m_goldList[cbArea][i].score)
--        local pgold = cc.Sprite:createWithSpriteFrameName(spJetton)
--        outnum = outnum + 1
--        pgold.isMeJetton = 0
--        if self.m_goldList[cbArea][i].isMeJetton == 1 then 
--            pgold.isMeJetton = 1
--        end
--        pgold:setPosition(bankerheadpoint)
--        self.m_goldLayer:addChild(pgold)
--        table.insert(self.m_goldList[cbArea], pgold)
--        local moveaction = self:getMoveAction(bankerheadpoint, self:getJettonPos(cbArea), 1, 0)
--        pgold:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.05), moveaction))
--        if outnum >= cellnum then
--            cellindex = cellindex + 1
--            outnum = 0
--        end
--    end
end

function GameViewLayer:showGoldToUser(cbArea)
    local lJettonScore = self.m_lUserJettonScore[cbArea]
    if lJettonScore > 0 then
        self:showGoldToSelf(cbArea)
    end
    self:showGoldToOther(cbArea)
end

function GameViewLayer:showGoldToOther(cbArea)
    if #self.m_goldList[cbArea] == 0 then
        return
    end
    local timeGap = 1.1/#self.m_goldList[cbArea]
    for i= 1 ,#self.m_goldList[cbArea] do 
        local pgold = self.m_goldList[cbArea][i]      
        if pgold and pgold.isMeJetton ~= 1 then                            
            local moveaction = cc.MoveTo:create(0.3, cc.p(userlistpoint.x, userlistpoint.y))
            pgold:runAction(
                cc.Sequence:create(
                cc.DelayTime:create((i-1)*timeGap + 1.6),
                moveaction,
                cc.CallFunc:create(
                    function (ref)
                        ref:setVisible(false)            
                    end)
                )
            )                    
        end
    end

--    local cellnum = math.floor(#self.m_goldList[cbArea]/10)
--    if cellnum == 0 then
--        cellnum = 1
--    end
--    local cellindex = 0
--    local outnum = 0

--    for i= 1 ,#self.m_goldList[cbArea] do 
--        local pgold = self.m_goldList[cbArea][i]
--        outnum = outnum + 1
--        if pgold then   
--            if pgold.isMeJetton ~= 1 then                   
--                local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), userlistpoint, 1, 0)
--                pgold:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.2), moveaction, cc.CallFunc:create(
--                        function (ref)
--                            ref:setVisible(false)
--                        end
--                    )))  
--            end       
--        end
--        if outnum >= cellnum then
--            cellindex = cellindex + 1
--            outnum = 0
--        end
--    end
end

function GameViewLayer:showGoldToSelf(cbArea)
    if #self.m_goldList[cbArea] == 0 then
        return
    end
    local timeGap = 1.1/#self.m_goldList[cbArea]
    for i= 1 ,#self.m_goldList[cbArea] do 
        local pgold = self.m_goldList[cbArea][i]
        if pgold and pgold.isMeJetton == 1 then 
            local moveaction = cc.MoveTo:create(0.3, cc.p(selfheadpoint.x, selfheadpoint.y))
            pgold:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create((i-1)*timeGap + 1.6), 
                    moveaction, 
                    cc.CallFunc:create(function (ref)
                        ref:setVisible(false)                    
                    end)
                )
            )  
        end
    end
--    local cellnum = math.floor(#self.m_goldList[cbArea]/10)
--    if cellnum == 0 then
--        cellnum = 1
--    end
--    local cellindex = 0
--    local outnum = 0

--    for i= 1 ,#self.m_goldList[cbArea] do 
--        local pgold = self.m_goldList[cbArea][i]
--        outnum = outnum + 1
--        if pgold then 
--            if pgold.isMeJetton == 1 then       
--                local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), selfheadpoint, 1, 0)
--                pgold:runAction(cc.Sequence:create(cc.DelayTime:create(cellindex*0.2), moveaction, cc.CallFunc:create(
--                        function (ref)
--                            ref:setVisible(false)
--                        end
--                    )))                
--            end
--        end
--        if outnum >= cellnum then
--            cellindex = cellindex + 1
--            outnum = 0
--        end
--    end
end

function GameViewLayer:showGameEnd(bRecord)
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    if bRecord then 
        local record = Game_CMD.getEmptyGameRecord()   
	    record.bWinKing = self.m_bAreaIsWin[1][1]
	    record.bWinQueen = self.m_bAreaIsWin[1][2]
        if self.m_bAreaIsWin[1][1] then
            record.bWinCardType = GameLogic:getCardType(self.m_cbTableCardArray[1])
        else
            record.bWinCardType = GameLogic:getCardType(self.m_cbTableCardArray[2])
        end
	    self:getDataMgr():addGameRecord(record)
        self:refreshGameRecord()
        if nil ~= self.m_GameRecordLayer then   
            self.m_GameRecordLayer:addLudan(record)
        end               
    end
    local score = self.m_lSelfWinScore - self.m_lSelfReturnScore
    if score > 0 then
        self:runWinLoseAnimate(score)
    end
    self:SetUserEndScore(score)
end

function GameViewLayer:removeHead()
    if nil ~= self.kingHead and nil ~= self.queenHead then
        self.kingHead:stopAllActions()
        self.queenHead:stopAllActions()
        self.kingHead:removeFromParent()
        self.queenHead:removeFromParent()
        self.kingHead = nil
        self.queenHead = nil
        self.m_spKingHead:setVisible(true)
        self.m_spQueenHead:setVisible(true)
    end
end

--运行输赢动画
function GameViewLayer:runWinLoseAnimate(score)
	--胜利失败动画
    local WinLose = display.newSprite("#redblackbattle_bg_end_lose.png")
        :setPosition(yl.DESIGN_WIDTH /2, yl.DESIGN_HEIGHT/2+50)
        :setScale(0)
        :setLocalZOrder(12)
        :addTo(self)
    local WinLoseTitle = display.newSprite("#redblackbattle_icon_fail.png")
        :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2+50)
        :setScale(0.3)
        :addTo(WinLose)
          
    local bgFram
    local lightFrame
    local TitleFrame
    local TabFrame
    local WinLoseText
    if score > 0 then
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("redblackbattle_bg_end_win.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("redblackbattle_icon_win.png")
        WinLoseText = cc.LabelAtlas:_create(".0000000", "game/redblackbattle_num_win.png", 27, 36, string.byte("*"))
            :setPosition(WinLose:getContentSize().width/4+40,WinLose:getContentSize().height/4)
            :setAnchorPoint(cc.p(0, 0.5))
            :addTo(WinLose)
        WinLoseText:setString("."..score)          
    else
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("redblackbattle_bg_end_lose.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("redblackbattle_icon_fail.png")
        WinLoseText = cc.LabelAtlas:_create("/0000000", "game/redblackbattle_num_lose.png", 27, 36, string.byte("*"))
            :setPosition(WinLose:getContentSize().width/4+40,WinLose:getContentSize().height/8-15)
            :setAnchorPoint(cc.p(0, 0.5))
            :addTo(WinLose)
        WinLoseText:setString("/"..math.abs(score))
    end

    WinLose:setSpriteFrame(bgFram)     
    WinLoseTitle:setSpriteFrame(TitleFrame) 
    WinLose:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.2, 1, 1, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function(ref)
			                    WinLose:setVisible(false)  
		                    end)
                 ))
    if score > 0 then
        local WinLoseLight = display.newSprite("#redblackbattle_bg_win_light.png")
            :setLocalZOrder(-2)
            :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2)
            :addTo(WinLose)
        WinLoseLight:runAction(cc.RotateBy:create(2.5, 360))
    end
    WinLoseTitle:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.ScaleTo:create(0.3, 1, 1, 1),
                    cc.DelayTime:create(2.1)
                     ))                
end

function GameViewLayer:SetUserEndScore(score)
    if score == 0 then
        return
    end
    local endScoreStr = score > 0 and "redblackbattle_num_win.png" or "redblackbattle_num_lose.png"   
    local txtCellScoreStr = score > 0 and ".0000000" or "/0000000"   

    local score2 = cc.LabelAtlas:_create(txtCellScoreStr, "game/"..endScoreStr, 27, 36, string.byte("*"))
            :setPosition(cc.p(65, 116))
            :setAnchorPoint(cc.p(0,0.5))
            :setVisible(true)
            :setLocalZOrder(4)
            :addTo(self)

    if score > 0 then
        score2:setString("." .. math.abs(score))           
    else
        score2:setString("/" .. math.abs(score))  
    end		        
            
    local nTime = 1.5 
    score2:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveBy:create(nTime, cc.p(0, 30)), 
			cc.FadeIn:create(nTime)),
            cc.CallFunc:create(function()
			      score2:removeFromParent()       
                  self:resetSelfInfo()      
		     end)))

	if score >= 0 then
		ExternalFun.playSoundEffect("gameWin.wav")
	else
		ExternalFun.playSoundEffect("gameLose.wav")
	end	   
end

--显示提示
function GameViewLayer:showGameTips(showtype)
    local pimagestr = "txt_banker_null.png"
    local ptY = yl.DESIGN_HEIGHT/2
    if showtype == TIP_TYPE.TypeChangBanker then
        pimagestr = "#redblackbattle_icon_change_banker.png"
        ptY = ptY - 40
    elseif showtype == TIP_TYPE.TypeSelfBanker then
        pimagestr = "txt_banker_selficon.png"
    elseif showtype == TIP_TYPE.TypeContinueSend then
        pimagestr = "txt_continue_sendcard.png"
    elseif showtype == TIP_TYPE.TypeReSend then
        pimagestr = "txt_game_resortpoker.png"
    elseif showtype == TIP_TYPE.TypeBeginChip then
        pimagestr = "#redblackbattle_icon_start_chip.png"
    elseif showtype == TIP_TYPE.TypeStopChip then    
        pimagestr = "#redblackbattle_icon_stop_chip.png"
    end     

    local Tipbg = display.newSprite(pimagestr)
        :setPosition(cc.p(0,ptY))
        :setLocalZOrder(12)
        :addTo(self)
    Tipbg:runAction(cc.Sequence:create( cc.MoveBy:create(0.2, cc.p(yl.WIDTH/2,0)), 
            cc.DelayTime:create(0.5),
            cc.MoveBy:create(0.2, cc.p(yl.WIDTH/2,0)), 
            cc.CallFunc:create(
            function()
                Tipbg:removeFromParent()
                if showtype == TIP_TYPE.TypeBeginChip then    
                    if self:isMeChair(self.m_wBankerUser) == false and (self.m_bEnableSysBanker ~= false or self.m_wBankerUser ~= yl.INVALID_CHAIR) then
                       self:setJettonEnable(true) 
                       self.m_bIsStartJetton = true
                       self:updateJettonList(self.m_lUserMaxScore)                         
                       self.m_btContinue:setEnabled(self.m_bIsContiueChip)
                    end                                  
                end
            end    
        )))
end

--设置下注按钮是否可以点击
function GameViewLayer:setJettonEnable(value)
    for k,v in pairs(self.m_JettonBtn) do
        v:setEnabled(value)
    end
    if nil ~= self.m_JettonLight then
        self.m_JettonLight:setVisible(value)
        if value == false then
            self.m_JettonLight:stopAllActions()
        elseif value == true then
            self.m_JettonLight:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
        end
    end
end

--更新下注按钮
--score：可以下注金额*MaxTimes
function GameViewLayer:updateJettonList(score)
    local btjettonscore = 0
    local judgeindex = 0
    if self.m_nJettonSelect == 0 then
        self.m_nJettonSelect = 1
        self.m_JettonLight:setPositionX(self.m_JettonBtn[self.m_nJettonSelect]:getPositionX())
    end
    for i=1,7 do
        btjettonscore = btjettonscore + GameViewLayer.m_BTJettonScore[i]
        local judgescore = btjettonscore*MaxTimes
        if judgescore > score then
            self.m_JettonBtn[i]:setEnabled(false)
        else
            self.m_JettonBtn[i]:setEnabled(true)
            judgeindex = i
        end
    end
    if self.m_nJettonSelect > judgeindex then
        self.m_nJettonSelect = judgeindex
        if judgeindex == 0 then
            self:setJettonEnable(false)
        else
            self.m_JettonLight:setPositionX(self.m_JettonBtn[judgeindex]:getPositionX())
        end
    end
end

--更新下注分数显示
function GameViewLayer:updateAreaScore(bshow)
    if bshow == false then
        for k,v in pairs(self.m_selfJettonScore) do
            v:setVisible(bshow)
        end
        for k,v in pairs(self.m_tAllJettonScore) do
            v:setVisible(bshow)
        end
        return
    end
    for i=1,3 do
        if self.m_lUserJettonScore[i] > 0 then
            self.m_selfJettonScore[i]:setVisible(true)
            self.m_selfJettonScore[i]:setString(""..self.m_lUserJettonScore[i])
        end
        if self.m_lAllJettonScore[i] > 0 then
            self.m_tAllJettonScore[i]:setVisible(true)
            self.m_tAllJettonScore[i]:setString(""..self.m_lAllJettonScore[i])
        end
    end
end

--刷新游戏记录
function GameViewLayer:refreshGameRecord()
    local recordList = self:getDataMgr():getGameRecord()   
    if nil ~= self.m_GameRecordLayer and self.m_GameRecordLayer:isVisible() then          
        self.m_GameRecordLayer:refreshRecord(recordList)
    end
    if nil ~= self.m_bgLudanQiu and nil~= self.m_bgLudanCardType then      
        self:ShowLudanQiu(recordList)
    end
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
    if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
        local userList = self:getDataMgr():getApplyBankerUserList()     
        self.m_applyListLayer:refreshList(userList)
    end
    self:refreshApplyBtnState()
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState(  )
    --获取当前申请状态
	local state = self:getApplyState()
	local str1 = nil
    local im_Apply = self.m_btnApply:getChildByName("apply")
    local im_UnApply = self.m_btnApply:getChildByName("unapply")
    local im_Down = self.m_btnApply:getChildByName("down")   
	--未申请状态则申请、申请状态则取消申请、已上庄则下庄
	if state == self._apply_state.kCancelState then        
        im_Apply:setVisible(true)
        im_UnApply:setVisible(false)
        im_Down:setVisible(false)
		--申请条件限制
		ExternalFun.enableBtn(self.m_btnApply, true)
	elseif state == self._apply_state.kApplyState then
		im_Apply:setVisible(false)
        im_UnApply:setVisible(true)
        im_Down:setVisible(false)
		ExternalFun.enableBtn(self.m_btnApply, true)
	elseif state == self._apply_state.kApplyedState then
		im_Apply:setVisible(false)
        im_UnApply:setVisible(false)
        im_Down:setVisible(true)
		--取消上庄限制
       	ExternalFun.enableBtn(self.m_btnApply, true)
	end
end

--刷新用户列表
function GameViewLayer:refreshUserList(  )
    if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
        local userList = self:getDataMgr():getUserList()        
        self.m_userListLayer:refreshList(userList)
    end
end

--刷新抢庄按钮
function GameViewLayer:refreshCondition(  )
    local applyable = self:getApplyable()
    if applyable then
        ------
        --超级抢庄

        --如果当前有超级抢庄用户且庄家不是自己
        if (yl.INVALID_CHAIR ~= self.m_wCurrentRobApply) or (true == self:isMeChair(self.m_wBankerUser)) then
            ExternalFun.enableBtn(self.m_btSupperRob, false)
        else
            local useritem = self:getMeUserItem()
        end     
    else
        ExternalFun.enableBtn(self.m_btSupperRob, false)
    end
end

--刷新用户分数
function GameViewLayer:onGetUserScore( useritem )
    --自己
    if useritem.dwUserID == GlobalUserItem.dwUserID then
        self.m_showScore = useritem.lScore
        self:resetSelfInfo()
    end

    --坐下用户
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            if useritem.wChairID == self.m_tabSitDownUser[i]:getChair() then
                self.m_tabSitDownUser[i]:updateScore(useritem.lScore)
            end
        end
    end

    --庄家
    if self.m_wBankerUser == useritem.wChairID then
        --庄家游戏币
        self.m_lBankerScore = useritem.lScore
        self:resetBankerInfo()
    end
end

--获取下注显示游戏币个数
function GameViewLayer:getGoldNum(lscore)
    local goldnum = 1
    for i=1,7 do
        if lscore >= GameViewLayer.m_BTJettonScore[i] then
            goldnum = i
        end
    end
    return GameViewLayer.m_JettonGoldBaseNum[goldnum]
end

--获取输钱区域需要游戏币数
function GameViewLayer:getWinGoldNumWithAreaID(cbArea)
    local goldnum = 0
    local lAllJettonScore = self.m_lAllJettonScore[cbArea]
    goldnum = goldnum + self:getWinGoldNum(self.m_lUserJettonScore[cbArea])
    --全是自己下注
    if self.m_lUserJettonScore[cbArea] == self.m_lAllJettonScore[cbArea] then
        return goldnum
    end
    lAllJettonScore = lAllJettonScore - self.m_lUserJettonScore[cbArea]

    --坐下用户
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            local seatJettonScore = self.m_tabSitDownUser[i]:getJettonScoreWithArea(cbArea)
            if seatJettonScore > 0 then
               goldnum = goldnum + self:getWinGoldNum(seatJettonScore)
               lAllJettonScore = lAllJettonScore - seatJettonScore
            end 
        end
    end

    if lAllJettonScore <= 0 then
        return goldnum
    end

    goldnum = goldnum + self:getWinGoldNum(lAllJettonScore)
    return goldnum
end

--获取赢钱需要游戏币数
function GameViewLayer:getWinGoldNum(lscore, index)
    if lscore == 0 then
        return 0
    end
    local goldnum = 0
    for i=1,7 do
        if lscore >= GameViewLayer.m_BTJettonScore[i] then
            goldnum = i
        end
    end
    if index == nil then
        return GameViewLayer.m_WinGoldMaxNum[goldnum]
    end
    return GameViewLayer.m_WinGoldBaseNum[goldnum]
end

--获取随机显示位置
function GameViewLayer:getRandPos(nodeArea)
    local beginpos = cc.p(nodeArea:getPositionX()-80, nodeArea:getPositionY()-65)

    local offsetx = math.random()
    local offsety = math.random()

    return cc.p(beginpos.x + offsetx*160, beginpos.y + offsety*130)
end

--获取移动动画
--inorout,0表示加速飞出,1表示加速飞入
--isreverse,0表示不反转,1表示反转
function GameViewLayer:getMoveAction(beginpos, endpos, inorout, isreverse)
    local offsety = (endpos.y - beginpos.y)*0.7
    local controlpos = cc.p(beginpos.x, beginpos.y+offsety)
    if isreverse == 1 then
        offsety = (beginpos.y - endpos.y)*0.7
        controlpos = cc.p(endpos.x, endpos.y+offsety)
    end
    local bezier = {
        controlpos,
        endpos,
        endpos
    }
    local beaction = cc.BezierTo:create(0.42, bezier)
    if inorout == 0 then
        return cc.EaseOut:create(beaction, 1)
    else
        return cc.EaseIn:create(beaction, 1)
    end
end

--判断该用户是否坐下
function GameViewLayer:getIsUserSit(wChair)
    for i = 1, Game_CMD.MAX_OCCUPY_SEAT_COUNT do
        if nil ~= self.m_tabSitDownUser[i] then
            if wChair == self.m_tabSitDownUser[i]:getChair() then
                return self.m_tabSitDownUser[i]
            end
        end
    end
    return nil
end

--上庄状态
function GameViewLayer:applyBanker( state )
    if state == APPLY_STATE.kCancelState then
        self:getParentNode():sendApplyBanker()      
    elseif state == APPLY_STATE.kApplyState then
        self:getParentNode():sendCancelApply()
    elseif state == APPLY_STATE.kApplyedState then
        self:getParentNode():sendCancelApply()      
    end
end

------
--银行节点
function GameViewLayer:createBankLayer()
    self.m_bankLayer = cc.Node:create()
    self:addToRootLayer(self.m_bankLayer, ZORDER_LAYER.ZORDER_Other_Layer)

    --加载csb资源
    local csbNode = ExternalFun.loadCSB("BankLayer.csb", self.m_bankLayer)
    local sp_bg = csbNode:getChildByName("sp_bg")

    ------
    --按钮事件
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end 
    --关闭按钮
    local btn = sp_bg:getChildByName("close_btn")
    btn:setTag(TAG_ENUM.BT_CLOSEBANK)
    btn:addTouchEventListener(btnEvent)

    local layout_bg = csbNode:getChildByName("layout_bg")
    layout_bg:setTag(TAG_ENUM.BT_CLOSEBANK)
    layout_bg:addTouchEventListener(btnEvent)

    --取款按钮
    btn = sp_bg:getChildByName("out_btn")
    btn:setTag(TAG_ENUM.BT_TAKESCORE)
    btn:addTouchEventListener(btnEvent)
    ------

    ------
    --编辑框
    --取款金额
    local tmp = sp_bg:getChildByName("count_temp")
    local editbox = ccui.EditBox:create(tmp:getContentSize(),"im_bank_edit.png",UI_TEX_TYPE_PLIST)
        :setPosition(tmp:getPosition())
        :setFontName(appdf.FONT_FILE)
        :setPlaceholderFontName(appdf.FONT_FILE)
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款金额")
    sp_bg:addChild(editbox)
    self.m_bankLayer.m_editNumber = editbox
    tmp:removeFromParent()

    --取款密码
    tmp = sp_bg:getChildByName("passwd_temp")
    editbox = ccui.EditBox:create(tmp:getContentSize(),"im_bank_edit.png",UI_TEX_TYPE_PLIST)
        :setPosition(tmp:getPosition())
        :setFontName(appdf.FONT_FILE)
        :setPlaceholderFontName(appdf.FONT_FILE)
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款密码")
    sp_bg:addChild(editbox)
    self.m_bankLayer.m_editPasswd = editbox
    tmp:removeFromParent()
    ------

    --当前游戏币
    self.m_bankLayer.m_textCurrent = sp_bg:getChildByName("text_current")

    --银行游戏币
    self.m_bankLayer.m_textBank = sp_bg:getChildByName("text_bank")

    --取款费率
--    self.m_bankLayer.m_textTips = sp_bg:getChildByName("text_tips")
    self:getParentNode():sendRequestBankInfo()
end

--取款
function GameViewLayer:onTakeScore()
    --参数判断
    local szScore = string.gsub(self.m_bankLayer.m_editNumber:getText(),"([^0-9])","")
    local szPass = self.m_bankLayer.m_editPasswd:getText()

    if #szScore < 1 then 
        showToast(self,"请输入操作金额！",2)
        return
    end

    local lOperateScore = tonumber(szScore)
    if lOperateScore<1 then
        showToast(self,"请输入正确金额！",2)
        return
    end

    if #szPass < 1 then 
        showToast(self,"请输入保险柜密码！",2)
        return
    end
    if #szPass <6 then
        showToast(self,"密码必须大于6个字符，请重新输入！",2)
        return
    end

    self:showPopWait()  
    self:getParentNode():sendTakeScore(szScore,szPass)
end

--刷新银行游戏币
--function GameViewLayer:refreshBankScore( )
--    --携带游戏币
--    local str = ExternalFun.numberThousands(GlobalUserItem.tabAccountInfo.lUserScore)
--    if string.len(str) > 19 then
--        str = string.sub(str, 1, 19)
--    end
--    self.m_bankLayer.m_textCurrent:setString(str)

--    --银行存款
--    str = ExternalFun.numberThousands(GlobalUserItem.tabAccountInfo.lUserInsure)
--    if string.len(str) > 19 then
--        str = string.sub(str, 1, 19)
--    end
--    self.m_bankLayer.m_textBank:setString(ExternalFun.numberThousands(GlobalUserItem.tabAccountInfo.lUserInsure))

--    self.m_bankLayer.m_editNumber:setText("")
--    self.m_bankLayer.m_editPasswd:setText("")
--end

function GameViewLayer:runGameStart()
    self.m_blackPKbg = display.newSprite("#redblackbattle_bg_start_black.png")
        :setPosition(-1,520)
        :setLocalZOrder(15)
        :setOpacity(0)
        :addTo(self)

    self.m_redPKbg = display.newSprite("#redblackbattle_bg_start_red.png")
        :setPosition(1294,520)
        :setLocalZOrder(15)
        :setOpacity(0)
        :addTo(self)

    local acttion = cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.33, cc.p(434,520))))
    self.m_blackPKbg:runAction(acttion)  

    local acttion1 = cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.33, cc.p(923,520))),cc.CallFunc:create(
                function ()                   
                   -- self:runShowPK()
                end
                ))
    self.m_redPKbg:runAction(acttion1)
    self:runShowPK()
end
        
function GameViewLayer:runShowPK()
    local spKing = display.newSprite("#redblackbattle_icon_king_head4.png")
        :setPosition(-240,496)
        :setLocalZOrder(16)
        :setOpacity(0)
        :addTo(self)

    local spKingHead = display.newSprite("#redblackbattle_icon_king_head3.png")
        :setPosition(135,215)
        :setLocalZOrder(15)
        :setOpacity(0)
        :addTo(spKing)

    local spQueen = display.newSprite("#redblackbattle_icon_queen_head5.png")
        :setPosition(1550,468)
        :setLocalZOrder(16)
        :setOpacity(0)
        :addTo(self)

    local spQueenHead = display.newSprite("#redblackbattle_icon_queen_head4.png")
        :setPosition(113,174)
        :setLocalZOrder(15)
        :setOpacity(0)
        :addTo(spQueen)

    local spQueenHand = display.newSprite("#redblackbattle_icon_queen_head1.png")
        :setPosition(63,80)
        :setLocalZOrder(16)
        :setOpacity(0)
        :addTo(spQueen)

    local time = 0.3
    
    local atc = cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(880,468))))
    spQueen:runAction(atc)
    spQueenHead:runAction(cc.FadeIn:create(time))
    spQueenHand:runAction(cc.FadeIn:create(time))

    local atc1 = cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(416,496))))
    spKing:runAction(atc1)
    spKingHead:runAction(cc.FadeIn:create(time))

    local spKingJian = display.newSprite("#redblackbattle_icon_vs_left.png")
        :setPosition(568,439)
        :setLocalZOrder(17)
        :setOpacity(0)
        :addTo(self)

    local spQueenJian = display.newSprite("#redblackbattle_icon_vs_right.png")
        :setPosition(749,439)
        :setLocalZOrder(17)
        :setOpacity(0)
        :addTo(self)

    local acttion = cc.Sequence:create(cc.DelayTime:create(0.2),cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(646,521))))
    spKingJian:runAction(acttion)  
    local acttion1 = cc.Sequence:create(cc.DelayTime:create(0.2),cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(0.3, cc.p(670,521))),cc.CallFunc:create(
                function ()                   
                    self:runShowPKLight()
                end
                ),
                cc.DelayTime:create(1),
                cc.CallFunc:create(
                function ()       
                    local action = cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-240,496)),
                    cc.CallFunc:create(
                    function ()                   
                        spKing:removeFromParent()    
                        spKing = nil
                        spKingHead = nil   
                    end
                    ))    
                    spKing:runAction(action)

                    local action1 = cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(1550,468)),
                    cc.CallFunc:create(
                    function ()                   
                        spQueen:removeFromParent()    
                        spQueen = nil  
                        spQueenHead = nil
                        spQueenHand = nil   
                                                
                        local action4 = cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-240,520)),
                        cc.CallFunc:create(
                        function ()                   
                                self.m_blackPKbg:removeFromParent()
                                self.m_blackPKbg = nil 
                        end
                        ))    
                        self.m_blackPKbg:runAction(action4)

                        local action5 = cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(1550,520)),
                        cc.CallFunc:create(
                        function ()                   
                                self.m_redPKbg:removeFromParent()
                                self.m_redPKbg = nil 
                                self:showGameTips(TIP_TYPE.TypeBeginChip)
                                ExternalFun.playSoundEffect("game_start.wav")    
                                self:sendCard() 
                        end
                        ))    
                        self.m_redPKbg:runAction(action5)
                    end
                    ))    
                    spQueen:runAction(action1)

                    local action2 = cc.Sequence:create(cc.FadeOut:create(0.2),
                    cc.CallFunc:create(
                    function ()                   
                         spKingJian:removeFromParent()
                         spKingJian = nil
                    end
                    ))    
                    spKingJian:runAction(action2)

                    local action3 = cc.Sequence:create(cc.FadeOut:create(0.2),
                    cc.CallFunc:create(
                    function ()                   
                         spQueenJian:removeFromParent()
                         spQueenJian = nil
                    end
                    ))    
                    spQueenJian:runAction(action3)        
                end
                ))
    spQueenJian:runAction(acttion1)  

end

function GameViewLayer:runShowPKLight()
    local sprite = display.newSprite()
	        :setPosition(656,532)       	
            :setLocalZOrder(18)
            :addTo(self)        
	local animation =cc.Animation:create()
	for i=1,5 do  
	    local frameName =string.format("redblackbattle_bg_pk_light%d.png",i)                                            
	    --print("frameName =%s",frameName)  
	    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
	    animation:addSpriteFrame(spriteFrame)                                                             
	end  
   	animation:setDelayPerUnit(0.1)          --设置两个帧播放时间                   
   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    

   	local action =cc.Animate:create(animation)                                                         
   	sprite:runAction(cc.Sequence:create(action, cc.DelayTime:create(1),cc.CallFunc:create(
                function()
                    sprite:removeFromParent()    
--                    self:runMovePK()                    
                end
                )))
end

function GameViewLayer:removePK()
--    if self.m_spKing ~= nil then
--        self.m_spKing:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(-250,558)),cc.CallFunc:create(
--                    function()
--                       self.m_spKing:removeFromParent()    
--                       self.m_spKing = nil
--                       self.m_spKingHead = nil         
--                    end
--                    )))
--    end
--    if self.m_spQueen ~= nil then
--        self.m_spQueen:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(1590,546)),cc.CallFunc:create(
--                    function()
--                       self.m_spQueen:removeFromParent()  
--                       self.m_spQueen = nil  
--                       self.m_spQueenHead = nil
--                       self.m_spQueenHand = nil      
--                    end
--                    )))
--    end
--    if self.m_spKingJian ~= nil then 
--        self.m_spKingJian:removeFromParent()
--        self.m_spKingJian = nil
--    end

--    if self.m_spQueenJian ~= nil then 
--        self.m_spQueenJian:removeFromParent()
--        self.m_spQueenJian = nil
--    end   
end

function GameViewLayer:runMovePK()
--    if nil == self.m_spKing or nil == self.m_spQueen or nil == self.m_spKingJian or nil == self.m_spQueenJian then
--        return
--    end
--  	local action = cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.33, cc.p(114,558)),cc.ScaleTo:create(0.33,0.8)))
--    self.m_spKing:runAction(action)

--    local action1 = cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.33, cc.p(1245,546)),cc.ScaleTo:create(0.33,0.8)))
--    self.m_spQueen:runAction(action1)

--    local action2 = cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.33, cc.p(660,585)),cc.ScaleTo:create(0.33,0.8)))
--    self.m_spKingJian:runAction(action2)

--    local action3 = cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.33, cc.p(680,585)),cc.ScaleTo:create(0.33,0.8)),
--     cc.DelayTime:create(1),cc.CallFunc:create(
--                function()
--                     self:showGameTips(TIP_TYPE.TypeBeginChip)
--                     ExternalFun.playSoundEffect("game_start.wav")    
--                     self:sendCard()         
--                end
--                ))
--    self.m_spQueenJian:runAction(action3)

--    if self.m_blackPKbg ~= nil then
--        self.m_blackPKbg:removeFromParent()
--        self.m_blackPKbg = nil
--    end

--    if self.m_redPKbg ~= nil then
--        self.m_redPKbg:removeFromParent()
--        self.m_redPKbg = nil
--    end
end

function GameViewLayer:runKingWin(isWin)
    local time = 0.2
    if isWin == true then
        self.kingHead = display.newSprite("#redblackbattle_icon_king_head2.png")
                :setPosition(135,215)
                :setLocalZOrder(5)           
                :addTo(self.m_spKing)

        self.m_spKingHead:setVisible(false)
        self.kingHead:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveTo:create(time, cc.p(135,220)),
        cc.MoveTo:create(time,cc.p(135,215))
--        cc.MoveTo:create(time, cc.p(135,220)),
--        cc.MoveTo:create(time,cc.p(135,215)),
--        cc.MoveTo:create(time, cc.p(135,220)),
--        cc.MoveTo:create(time,cc.p(135,215)),
--        cc.CallFunc:create(
--            function()
--                kingHead:removeFromParent()    
--                self.m_spKingHead:setVisible(true)
--            end
--         )
        )))

        self.queenHead = display.newSprite("#redblackbattle_icon_queen_head2.png")
            :setPosition(113,174)
            :setLocalZOrder(5)        
            :addTo(self.m_spQueen)
        self.m_spQueenHead:setVisible(false)

        self.queenHead:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveTo:create(time, cc.p(113,171)),
                    cc.MoveTo:create(time, cc.p(113,174))
        --        cc.MoveTo:create(time, cc.p(113,171)),
        --        cc.MoveTo:create(time, cc.p(113,174)),
        --        cc.MoveTo:create(time, cc.p(113,171)),
        --        cc.MoveTo:create(time, cc.p(113,174)),
        --        cc.CallFunc:create(
        --                    function()
        --                        queenHead:removeFromParent()             
        --                        self.m_spQueenHead:setVisible(true)
        --                    end
        --                    )
                )
            )
        )

    else
        self.queenHead = display.newSprite("#redblackbattle_icon_queen_head3.png")
                :setPosition(113,174)
                :setLocalZOrder(5)           
                :addTo(self.m_spQueen)

        self.m_spQueenHead:setVisible(false)
        self.queenHead:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveTo:create(time, cc.p(113,179)),
                    cc.MoveTo:create(time,cc.p(113,174))
        --        cc.MoveTo:create(time, cc.p(113,179)),
        --        cc.MoveTo:create(time,cc.p(113,174)),
        --        cc.MoveTo:create(time, cc.p(113,179)),
        --        cc.MoveTo:create(time,cc.p(113,174)),
        --        cc.CallFunc:create(
        --                    function()
        --                        queenHead:removeFromParent()    
        --                        self.m_spQueenHead:setVisible(true)
        --                    end
        --                    )
                )
            )
        )

        self.kingHead = display.newSprite("#redblackbattle_icon_king_head1.png")
            :setPosition(135,215)
            :setLocalZOrder(5)           
            :addTo(self.m_spKing)

        self.m_spKingHead:setVisible(false)
        self.kingHead:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                        cc.MoveTo:create(time, cc.p(135,212)),
                        cc.MoveTo:create(time,cc.p(135,215))
                --        cc.MoveTo:create(time, cc.p(135,212)),
                --        cc.MoveTo:create(time,cc.p(135,215)),
                --        cc.MoveTo:create(time, cc.p(135,212)),
                --        cc.MoveTo:create(time,cc.p(135,215)),
                --        cc.CallFunc:create(
                --                    function()
                --                        kingHead:removeFromParent()    
                --                        self.m_spKingHead:setVisible(true)
                --                    end
                --                    )
                )
            )
        )
    end
end

--屏幕点击
function GameViewLayer:onEventTouchCallback(eventType, x, y)

end

--正在游戏状态进入桌子初始化
function GameViewLayer:ShowKingQueen()
    self.m_spKing = display.newSprite("#redblackbattle_icon_king_head4.png")
        :setPosition(114, 558)
        :setLocalZOrder(6)
        :addTo(self)

    self.m_spKingHead = display.newSprite("#redblackbattle_icon_king_head3.png")
        :setPosition(135, 215)
        :setLocalZOrder(5)
        :addTo(self.m_spKing)
    self.m_spKing:setScale(0.8)

     self.m_spQueen = display.newSprite("#redblackbattle_icon_queen_head5.png")
        :setPosition(1245,546)
        :setLocalZOrder(6)      
        :addTo(self)

    self.m_spQueenHead = display.newSprite("#redblackbattle_icon_queen_head4.png")
        :setPosition(113,174)
        :setLocalZOrder(5)    
        :addTo(self.m_spQueen)

    self.m_spQueenHand = display.newSprite("#redblackbattle_icon_queen_head1.png")
        :setPosition(63,80)
        :setLocalZOrder(6)
        :addTo(self.m_spQueen)
    self.m_spQueen:setScale(0.8)

    self.m_spKingJian = display.newSprite("#redblackbattle_icon_vs_left.png")
        :setPosition(660,585)
        :setLocalZOrder(7)
        :setScale(0.8)
        :addTo(self)

    self.m_spQueenJian = display.newSprite("#redblackbattle_icon_vs_right.png")
        :setPosition(680,585)
        :setLocalZOrder(7)
        :setScale(0.8)
        :addTo(self)
end

function GameViewLayer:GameSenceShowCard()
    for j=1,2 do
        for i=1,3 do
            local index = (i+(j-1)*3)
            local temp = CardSprite:createCard(0)
            temp:setVisible(true)
            temp:setAnchorPoint(0, 0.5)
            temp:setTag(TAG_ENUM.TAG_CARD)
            temp:setPosition(cardpoint[index])
            temp:setScale(0.8)
            temp:showCardBack(true)
            temp:setLocalZOrder(9)
            temp:addTo(self)   
            self.m_CardArray[index] = temp    
        end    
    end  
end

function GameViewLayer:GameSenceEndShowCard()
  for j=1,2 do
        for i=1,3 do
            local index = (i+(j-1)*3)
            self.m_CardArray[index]:removeFromParent()   
            self.m_CardArray[index] = nil
            local temp = CardSprite:createCard(self.m_cbTableCardArray[j][i])
            temp:setAnchorPoint(0, 0.5)
            temp:setTag(TAG_ENUM.TAG_CARD) 
            temp:setScale(0.8)   
            temp:setLocalZOrder(9)
            temp:addTo(self)  
            temp:setPosition(cardpoint[index]) 
            self.m_CardArray[index] = temp
            if i == 3 then
                local savetype = GameLogic:getCardType(self.m_cbTableCardArray[j])
                self:setCardType(index,savetype)
            end
        end    
    end  
    self:ShowWinLight(0)
end

function GameViewLayer:ShowLudanQiu(vecRecord)
    local cardTypeindex = 0
    local count = #vecRecord
    if count > 8 then
        cardTypeindex = count - 8
    end 

    for i,v in ipairs(vecRecord) do
        if i <= 20 then
            local imgStr = v.bWinKing == true and "redblackbattle_icon_win_black.png" or "redblackbattle_icon_win_red.png"   
            local tmpSp =cc.Sprite:createWithSpriteFrameName(imgStr)
                :setPosition(26+47*(i-1),19)
                :addTo(self.m_bgLudanQiu)        
        end

        if i > cardTypeindex then  
                local frameName  = string.format("redblackbattle_icon_cardtype%d.png",v.bWinCardType) 
		        pimage = cc.Sprite:createWithSpriteFrameName(frameName)
                pimage:setPosition(64+(i-cardTypeindex-1)*121,33)
                pimage:addTo(self.m_bgLudanCardType)  
        end
    end   
   
end

function GameViewLayer:GameSencePlayShowGlod()
    if nil == self.m_lAllJettonScore then
        return
    end
    local base = 0 
    local score = 0
    local chipnum = 0 
    local chipscore = 0
    for i = 1, 3 do
        chipscore = self.m_lAllJettonScore[i]	 
        for j = 7, 1, -1 do
            if chipscore >= GameViewLayer.m_BTJettonScore[j] then
                base = GameViewLayer.m_BTJettonScore[j]
			    score = chipscore - (chipscore % base)
			    chipscore = chipscore % base
                chipnum = score/base              
                for k = 1, chipnum do
                    local endPos = self:getJettonPos(i)
                    local spJetton,tag = self:getJettonImage(GameViewLayer.m_BTJettonScore[j])
                    local pgold = cc.Sprite:createWithSpriteFrameName(spJetton)
                    pgold:setPosition(endPos)
                    pgold.JetTag = tag
                    self.m_goldLayer:addChild(pgold)                   
                    table.insert(self.m_goldList[i], pgold)
                end			        
            end
        end	  
    end  

end

return GameViewLayer

