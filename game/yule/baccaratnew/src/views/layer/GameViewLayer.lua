local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.baccaratnew.src"

--external
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
--
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local QueryDialog   = require("app.views.layer.other.QueryDialog")

--utils
local SettingLayer = module_pre .. ".views.layer.GameSetLayer"
local UserListLayer = module_pre .. ".views.layer.userlist.UserListLayer"
local ApplyListLayer = module_pre .. ".views.layer.userlist.ApplyListLayer"
local SitRoleNode = module_pre .. ".views.layer.SitRoleNode"
local CardSprite = module_pre .. ".views.layer.gamecard.CardSprite"
local LudanPoint = module_pre .. ".views.layer.LudanPoint"
local GameResultLayer = module_pre .. ".views.layer.GameResultLayer"
local GameLogic = module_pre .. ".models.GameLogic"
local bjlDefine = module_pre .. ".models.bjlGameDefine"
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local BankLayer=appdf.req(module_pre .. ".views.layer.BankLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751
--
GameViewLayer.TAG_START = 100
local enumTable = 
{
	"BT_MENU",
	"BT_EXIT",
	"BT_HELP",
	"BT_SET",
	"BT_LUDAN",
	"BT_ROBBANKER",
	"BT_USERLIST",
	"BT_APPLYBANKER",
	"BT_CANCELAPPLY",
	"BT_CANCELBANKER",
	"BANK_LAYER",
    "BT_BANK",
    "BT_MESSAGE"
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enumTable)

local zorders = 
{
	"CLOCK_ZORDER",
	"SITDOWN_ZORDER",
	"DROPDOWN_CHECK_ZORDER",
	"DROPDOWN_ZORDER",
	"GAMECARD_ZORDER",
	"USERLIST_ZORDER",
	"SETTING_ZORDER",
	"ROLEINFO_ZORDER",
	"BANK_ZORDER",
	"GAMERS_ZORDER",	
	"ENDCLOCK_ZORDER",
	"HELP_ZORDER"
}
local TAG_ZORDER = ExternalFun.declarEnumWithTable(1, zorders)

local enumApply =
{
	"kCancelState",         -- 闲家状态
	"kApplyState",          -- 申请状态
	"kApplyedState",
	"kSupperApplyed"
}
GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state
local DEFAULT_BET = 1   -- 默认选中的筹码
local BET_ANITIME = 0.3 -- 筹码运行时间

-------------------------------------------------------------  初始化游戏  -------------------------------------------------------------
function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene
	self:gameDataInit()
	self:initCsbRes()   --初始化csb界面
    ExternalFun.registerTouchEvent(self,true)
end

function GameViewLayer:gameDataInit( )
    
    cc.Director:getInstance():getTextureCache():addImageAsync("baccaratnew_game.png", function (args)
        cc.SpriteFrameCache:getInstance():addSpriteFrames("baccaratnew_game.plist")
    end)
    --播放背景音乐
    ExternalFun.setBackgroundAudio("sound_res/baccaratnew_bgm.mp3")

    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --加载资源
	self:loadRes()

	--变量声明
	self.m_nJettonSelect = -1
	self.m_lHaveJetton = 0
	self.m_llMaxJetton = 0
    self.m_llAreaLimitScore = 0
	self.m_llCondition = 0
	yl.m_bDynamicJoin = false
	self.m_scoreUser = (self:getMeUserItem() and self:getMeUserItem().lScore) or 0

	--下注信息
	self.m_tableJettonBtn = {}
	self.m_tableJettonArea = {}
    self.m_tableJettonLight = {}
    self.m_pNodeChipScoreAll = {}
    self.m_pNodeChipScorePlayer = {}

	self.m_applyListLayer = nil
	self.m_userListLayer = nil
	self.m_gameResultLayer = nil
	self.m_pClock = nil
	self._bankLayer = nil

	--申请状态
	self.m_enApplyState = APPLY_STATE.kCancelState
	--超级抢庄申请
	self.m_bSupperRobApplyed = false
	--超级抢庄配置
	self.m_tabSupperRobConfig = {}
	--金币抢庄提示
	self.m_bRobAlert = false

	--用户坐下配置
	self.m_tabSitDownConfig = {}
	self.m_tabSitDownUser = {}
	--自己坐下
	self.m_nSelfSitIdx = nil

	--座位列表
	self.m_tabSitDownList = {}

	--当前抢庄用户
	self.m_wCurrentRobApply = yl.INVALID_CHAIR

	--当前庄家用户
	self.m_wBankerUser = yl.INVALID_CHAIR
	--选中的筹码
	self.m_nSelectBet = DEFAULT_BET

	--是否结算状态
	self.m_bOnGameRes = false

	--是否无人坐庄
	self.m_bNoBanker = false

    --路单记录
    self.m_vecDalutu = {}

    self.m_DalutuHang = 1
    self.m_DalutuLie = 1
    self.m_DalutuMaxLie = 7
    self.m_DalutuSaveLie = 1
    self.m_DalutuBlackGrayHang = 0
    self.m_DalutuBlackGrayLie = 0
    
    self.m_vecZhupanlu = {}
    self.m_vecZhupanluData = {}

    self.m_vecWinlose = {}
    self.m_vecWinloseData = {}

end

function GameViewLayer:loadRes()
	cc.Director:getInstance():getTextureCache():addImage("game/card.png")   --加载卡牌纹理
end

function GameViewLayer:initCsbRes() --界面初始化
	local rootLayer, csbNode = ExternalFun.loadRootCSB("game/GameLayer.csb", self)
	self.m_rootLayer = rootLayer
    self.m_pNodeChip = csbNode:getChildByName("m_pNodeChip")            --下注区域
    self.m_pAniStartChip1 = self.m_pNodeChip:getChildByName("m_pAniStartChip1")
    self.m_pAniStartChip2 = self.m_pNodeChip:getChildByName("m_pAniStartChip2")
    self.m_pTextAllChip = self.m_pNodeChip:getChildByName("m_pTextAllChip")

    self.m_pNodeShowCard                = csbNode:getChildByName("m_pNodeShowCard")    --比牌区域
    self.m_pNodeCardLayer               = self.m_pNodeShowCard:getChildByName("m_pNodeCardLayer")
    self.m_pNodeEndPointPlayer          = self.m_pNodeShowCard:getChildByName("m_pNodeEndPointPlayer")
    self.m_pNodeEndPointPlayer.point    = self.m_pNodeEndPointPlayer:getChildByName("point")
    self.m_pNodeEndPointBanker          = self.m_pNodeShowCard:getChildByName("m_pNodeEndPointBanker")
    self.m_pNodeEndPointBanker.point    = self.m_pNodeEndPointBanker:getChildByName("point")
    self.m_pNodeWinner                  = self.m_pNodeShowCard:getChildByName("m_pNodeWinner")
    self.m_pNodeWinner:getChildByName("m_pIconWinner"):setLocalZOrder(1)
    
    self:initBtn(csbNode)           --初始化按钮
	self:initBankerInfo(csbNode)    --初始化庄家信息
	self:initUserInfo(csbNode)      --初始化玩家信息
	self:initJetton(csbNode)        --初始化桌面下注
	self:createClockNode()          --倒计时

	self.m_applyListLayer = g_var(ApplyListLayer):create(self)
    self:addToRootLayer(self.m_applyListLayer, TAG_ZORDER.USERLIST_ZORDER)

    local m_pNodeCanChip = csbNode:getChildByName("m_pNodeCanChip")            -- 可下注界面
    self.m_pTextCanChipZhuang   = m_pNodeCanChip:getChildByName("m_pTextCanChipZhuang")
    self.m_pTextCanChipXian     = m_pNodeCanChip:getChildByName("m_pTextCanChipXian")
    self.m_pTextCanChipPing     = m_pNodeCanChip:getChildByName("m_pTextCanChipPing")
    
    self.m_pTextCanChipZhuang:setFontName(appdf.FONT_FILE)
    self.m_pTextCanChipXian:setFontName(appdf.FONT_FILE)
    self.m_pTextCanChipPing:setFontName(appdf.FONT_FILE)
end

--初始化按钮
function GameViewLayer:initBtn(csbNode)
	------
	--按钮列表
	local function btnEvent( sender, eventType )
        ExternalFun.btnEffect(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender)
		end
	end	

    ----------------------------------菜单界面----------------------------------
    
	self.m_pNodeMenu = csbNode:getChildByName("m_pNodeMenu")
	self.m_pNodeMenu:setScale(0)
	self.m_pNodeMenu:setLocalZOrder(TAG_ZORDER.DROPDOWN_ZORDER)

	local m_pBtnMenu = csbNode:getChildByName("m_pBtnMenu")
    m_pBtnMenu:addTouchEventListener(btnEvent)
	m_pBtnMenu:setTag(TAG_ENUM.BT_MENU)
	m_pBtnMenu:setLocalZOrder(TAG_ZORDER.DROPDOWN_ZORDER)

	--帮助
	local m_pBtnHelp = self.m_pNodeMenu:getChildByName("m_pBtnHelp")
	m_pBtnHelp:setTag(TAG_ENUM.BT_HELP)
	m_pBtnHelp:addTouchEventListener(btnEvent)

	--设置
	local m_pBtnSet = self.m_pNodeMenu:getChildByName("m_pBtnSet")
	m_pBtnSet:setTag(TAG_ENUM.BT_SET)
	m_pBtnSet:addTouchEventListener(btnEvent)

    --银行
	local m_pBtnBank = self.m_pNodeMenu:getChildByName("m_pBtnBank")
	m_pBtnBank:setTag(TAG_ENUM.BT_BANK)
	m_pBtnBank:addTouchEventListener(btnEvent)

	--离开
	local m_pBtnBack = self.m_pNodeMenu:getChildByName("m_pBtnBack")
	m_pBtnBack:setTag(TAG_ENUM.BT_EXIT)
	m_pBtnBack:addTouchEventListener(btnEvent)

    
    ----------------------------------抢庄界面----------------------------------
	self.m_pBtnApplyBanker = csbNode:getChildByName("m_pBtnApplyBanker")
	self.m_pBtnApplyBanker:setTag(TAG_ENUM.BT_APPLYBANKER)
	self.m_pBtnApplyBanker:addTouchEventListener(btnEvent)
	self.m_pBtnApplyBanker:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

	self.m_pBtnCancelBanker = csbNode:getChildByName("m_pBtnCancelBanker")
	self.m_pBtnCancelBanker:setTag(TAG_ENUM.BT_CANCELAPPLY)
	self.m_pBtnCancelBanker:addTouchEventListener(btnEvent)
	self.m_pBtnCancelBanker:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

	self.m_pBtnCancelApply = csbNode:getChildByName("m_pBtnCancelApply")
	self.m_pBtnCancelApply:setTag(TAG_ENUM.BT_CANCELBANKER)
	self.m_pBtnCancelApply:addTouchEventListener(btnEvent)
	self.m_pBtnCancelApply:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

    self:setBtnBankerType(APPLY_STATE.kCancelState)

    
    ----------------------------------聊天界面----------------------------------
	local m_pBtnMessage = csbNode:getChildByName("m_pBtnMessage")
	m_pBtnMessage:setTag(TAG_ENUM.BT_MESSAGE)
	m_pBtnMessage:addTouchEventListener(btnEvent)
	m_pBtnMessage:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

    ----------------------------------玩家界面----------------------------------
	local m_pBtnUserList = csbNode:getChildByName("m_pBtnUserList")
	m_pBtnUserList:setTag(TAG_ENUM.BT_USERLIST)
	m_pBtnUserList:addTouchEventListener(btnEvent)
	m_pBtnUserList:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)
    m_pBtnUserList:setVisible(false)

    
    ----------------------------------路单界面----------------------------------
    local m_pNodeLudan = csbNode:getChildByName("m_pNodeLudan")
    self.m_pNodeDalutu = m_pNodeLudan:getChildByName("m_pNodeDalutu")
    self.m_pNodeZhupanlu = m_pNodeLudan:getChildByName("m_pNodeZhupanlu")
    self.m_pNodeWinlose = m_pNodeLudan:getChildByName("m_pNodeWinlose")

    self.m_pBtnDalutu = m_pNodeLudan:getChildByName("m_pBtnDalutu")
    self.m_pBtnZhupanlu = m_pNodeLudan:getChildByName("m_pBtnZhupan")
    self.m_pBtnWinlose = m_pNodeLudan:getChildByName("m_pBtnWinlose")
    
    self.m_pScrollDalutu = self.m_pNodeDalutu:getChildByName("m_pScrollDalutu")
    self.m_pScrollZhupanlu = self.m_pNodeZhupanlu:getChildByName("m_pScrollZhupanlu")
    self.m_pScrollWinlose = self.m_pNodeWinlose:getChildByName("m_pScrollWinlose")
    
    self.m_pTextWinloseZhuang = self.m_pNodeWinlose:getChildByName("m_pTextWinloseZhuang")
    self.m_pTextWinloseXian = self.m_pNodeWinlose:getChildByName("m_pTextWinloseXian")
    self.m_pTextWinlosePing = self.m_pNodeWinlose:getChildByName("m_pTextWinlosePing")
    
    self.m_pTextWinloseZhuang:setFontName(appdf.FONT_FILE)
    self.m_pTextWinloseXian:setFontName(appdf.FONT_FILE)
    self.m_pTextWinlosePing:setFontName(appdf.FONT_FILE)

    --初始化大路图 6行7列
    local ludanSpr
    local index
    for i = 1, 7 do     -- 列
        for j = 1, 6 do -- 行
            index = ((self.m_DalutuBlackGrayLie+1)%2+self.m_DalutuBlackGrayHang)%2
            if self.m_DalutuBlackGrayHang < 5 then
                self.m_DalutuBlackGrayHang = self.m_DalutuBlackGrayHang + 1
            else
                self.m_DalutuBlackGrayHang = 0
                self.m_DalutuBlackGrayLie = self.m_DalutuBlackGrayLie + 1
            end
                        
            ludanSpr = g_var(LudanPoint):create(index, 0.6458)
            ludanSpr:setPosition(cc.p((i-1)*ludanSpr:getContentSize().width*0.6458, 186-j*ludanSpr:getContentSize().height*0.6458))
            ludanSpr:setAnchorPoint(cc.p(0, 0))
            self.m_pScrollDalutu:addChild(ludanSpr)
            
            table.insert(self.m_vecDalutu, ludanSpr)
        end
    end


    --初始化珠盘路 3行5列
    for i = 1, 12 do     -- 列
        for j = 1, 3 do -- 行
            index = ((i+1)%2+j)%2
            ludanSpr = g_var(LudanPoint):create(index, 1)
            ludanSpr:setPosition(cc.p((i-1)*ludanSpr:getContentSize().width, 144-j*ludanSpr:getContentSize().height))
            ludanSpr:setAnchorPoint(cc.p(0, 0))
            self.m_pScrollZhupanlu:addChild(ludanSpr)
            table.insert(self.m_vecZhupanlu, ludanSpr)
        end
    end


    --初始化输赢表 3行5列
    for i = 1, 12 do     -- 列
        for j = 1, 3 do -- 行
            index = ((i+1)%2+j)%2
            ludanSpr = g_var(LudanPoint):create(index, 1)
            ludanSpr:setPosition(cc.p((i-1)*ludanSpr:getContentSize().width, 144-j*ludanSpr:getContentSize().height))
            ludanSpr:setAnchorPoint(cc.p(0, 0))
            self.m_pScrollWinlose:addChild(ludanSpr)
            table.insert(self.m_vecWinlose, ludanSpr)
        end
    end

    self.m_bDalutu = true
    self.m_bZhupanlu = false
    self.m_bWinlose = false
    self.m_pBtnDalutu:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.m_pNodeDalutu:setVisible(true)
            self.m_pNodeZhupanlu:setVisible(false)
            self.m_pNodeWinlose:setVisible(false)
            
            self.m_pBtnDalutu:setSelected(true)
            self.m_pBtnZhupanlu:setSelected(false)
            self.m_pBtnWinlose:setSelected(false)
            
            self.m_bDalutu = true
            self.m_bZhupanlu = false
            self.m_bWinlose = false
        elseif eventType == ccui.TouchEventType.canceled then
            self.m_pBtnDalutu:setSelected(self.m_bDalutu)
            self.m_pBtnZhupanlu:setSelected(self.m_bZhupanlu)
            self.m_pBtnWinlose:setSelected(self.m_bWinlose)
        end
    end)
    self.m_pBtnZhupanlu:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.m_pNodeDalutu:setVisible(false)
            self.m_pNodeZhupanlu:setVisible(true)
            self.m_pNodeWinlose:setVisible(false)
            
            self.m_pBtnDalutu:setSelected(false)
            self.m_pBtnZhupanlu:setSelected(true)
            self.m_pBtnWinlose:setSelected(false)
            
            self.m_bDalutu = false
            self.m_bZhupanlu = true
            self.m_bWinlose = false
        elseif eventType == ccui.TouchEventType.canceled then
            self.m_pBtnDalutu:setSelected(self.m_bDalutu)
            self.m_pBtnZhupanlu:setSelected(self.m_bZhupanlu)
            self.m_pBtnWinlose:setSelected(self.m_bWinlose)
        end
    end)
    self.m_pBtnWinlose:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.m_pNodeDalutu:setVisible(false)
            self.m_pNodeZhupanlu:setVisible(false)
            self.m_pNodeWinlose:setVisible(true)
            
            self.m_pBtnDalutu:setSelected(false)
            self.m_pBtnZhupanlu:setSelected(false)
            self.m_pBtnWinlose:setSelected(true)
            
            self.m_bDalutu = false
            self.m_bZhupanlu = false
            self.m_bWinlose = true
        elseif eventType == ccui.TouchEventType.canceled then
            self.m_pBtnDalutu:setSelected(self.m_bDalutu)
            self.m_pBtnZhupanlu:setSelected(self.m_bZhupanlu)
            self.m_pBtnWinlose:setSelected(self.m_bWinlose)
        end
    end)
end

--初始化庄家信息
function GameViewLayer:initBankerInfo(csbNode)
	self.m_pIconBankerBG = csbNode:getChildByName("m_pIconBankerBG")
	
	self.m_pTextBankerName = self.m_pIconBankerBG:getChildByName("m_pTextBankerName")    --庄家姓名
	self.m_pTextBankerGold = self.m_pIconBankerBG:getChildByName("m_pTextBankerGold")    --庄家金币
	self.m_pTextBankerScore = self.m_pIconBankerBG:getChildByName("m_pTextBankerScore")    --庄家金币
    self:setBankerScore(0)
    
    self.m_lBankerScore = -1
	self.m_pTextBankerName:setFontName(appdf.FONT_FILE)
	self.m_pTextBankerGold:setFontName(appdf.FONT_FILE)
	self.m_pTextBankerScore:setFontName(appdf.FONT_FILE)
end

--初始化玩家信息
function GameViewLayer:initUserInfo(csbNode)
	self.m_pNodeBottom = csbNode:getChildByName("m_pNodeBottom")    --底部按钮
	self.m_pTextGold = self.m_pNodeBottom:getChildByName("m_pTextGold") --玩家金币
	self.m_pTextName = self.m_pNodeBottom:getChildByName("m_pTextName") --玩家名字
	self.m_pTextScore = self.m_pNodeBottom:getChildByName("m_pTextScore") --玩家成绩

	self.m_pTextGold:setFontName(appdf.FONT_FILE)
	self.m_pTextName:setFontName(appdf.FONT_FILE)
	self.m_pTextScore:setFontName(appdf.FONT_FILE)
	self:resetUserInfo()
	--下注按钮	
	self:initJettonBtnInfo()
end

--下注按钮
function GameViewLayer:initJettonBtnInfo()
	self.m_pJettonNumber = 
	{
		{k = 100, i = 1},
		{k = 1000, i = 2},
		{k = 10000, i = 3}, 
		{k = 100000, i = 4}, 
		{k = 1000000, i = 5}, 
		{k = 5000000, i = 6},
		{k = 10000000, i = 7} 
	}

	local function clipEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onJettonButtonClicked(sender:getTag(), sender)
		end
	end

	for i = 1, #self.m_pJettonNumber do
		local str = string.format("m_pBtnChip%d", i - 1)
		local btn = self.m_pNodeBottom:getChildByName(str)
		btn:setTag(i)
		btn:addTouchEventListener(clipEvent)
		self.m_tableJettonBtn[i] = btn
	end
    self.m_pIconChipLight = self.m_pNodeBottom:getChildByName("m_pIconChipLight")
	self:resetJettonBtnInfo(false)
end

--初始化桌面下注
function GameViewLayer:initJetton(csbNode)
	self.m_betAreaLayout = self.m_pNodeChip:getChildByName("bet_area")  --筹码区域
	--按钮列表
	local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            self.m_tableJettonLight[sender:getTag()]:setVisible(true)
		elseif eventType == ccui.TouchEventType.ended then
            self.m_tableJettonLight[sender:getTag()]:setVisible(false)
			self:onJettonAreaClicked(sender:getTag(), sender)
		elseif eventType == ccui.TouchEventType.canceled then
            self.m_tableJettonLight[sender:getTag()]:setVisible(false)
		end
	end	

    local str = ""
	for i = 1, 8 do
		str = string.format("m_pBtnChipArea%d", i - 1)
		self.m_tableJettonArea[i] = self.m_pNodeChip:getChildByName(str)
		self.m_tableJettonArea[i]:setTag(i)
		self.m_tableJettonArea[i]:addTouchEventListener(btnEvent)

		str = string.format("m_pIconTouchArea%d", i - 1)
		self.m_tableJettonLight[i] = self.m_pNodeChip:getChildByName(str)

        str = string.format("m_pTextChipScoreAll%d", i - 1)
		self.m_pNodeChipScoreAll[i] = self.m_pNodeChip:getChildByName(str)
	    self.m_pNodeChipScoreAll[i].m_llScore = 0
        self.m_pNodeChipScoreAll[i]:setFontName(appdf.FONT_FILE)
        self.m_pNodeChipScoreAll[i]:enableOutline(cc.c4b(10, 43, 65, 255), 2)

        str = string.format("m_pTextChipScorePlayer%d", i - 1)
		self.m_pNodeChipScorePlayer[i] = self.m_pNodeChip:getChildByName(str)
	    self.m_pNodeChipScorePlayer[i].m_llScore = 0
        self.m_pNodeChipScorePlayer[i]:setFontName(appdf.FONT_FILE)
        self.m_pNodeChipScorePlayer[i]:enableOutline(cc.c4b(24, 45, 14, 255), 2)
	end

	--下注信息
	local m_userJettonLayout = csbNode:getChildByName("jetton_control")
	local infoSize = m_userJettonLayout:getContentSize()
	local text = ccui.Text:create("本次下注为:", appdf.FONT_FILE, 20)
	text:setAnchorPoint(cc.p(1.0,0.5))
	text:setPosition(cc.p(infoSize.width * 0.495, infoSize.height * 0.19))
	m_userJettonLayout:addChild(text)
	m_userJettonLayout:setVisible(false)

	local m_clipJetton = g_var(ClipText):createClipText(cc.size(120, 23), "")
	m_clipJetton:setPosition(cc.p(infoSize.width * 0.5, infoSize.height * 0.19))
	m_clipJetton:setAnchorPoint(cc.p(0,0.5))
	m_clipJetton:setTextColor(cc.c4b(255,165,0,255))
	m_userJettonLayout:addChild(m_clipJetton)

	self.m_userJettonLayout = m_userJettonLayout
	self.m_clipJetton = m_clipJetton

	self:resetJettonArea(false)
end

--倒计时节点
function GameViewLayer:createClockNode()
	self.m_pClock = cc.Node:create()
	self.m_pClock:setPosition(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2)
	self:addToRootLayer(self.m_pClock, TAG_ZORDER.CLOCK_ZORDER)

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("game/GameClockNode.csb", self.m_pClock)

	--倒计时
	self.m_pClock.m_atlasTimer = csbNode:getChildByName("timer_atlas")
	self.m_pClock.m_atlasTimer:setString("00")
    
	self.m_pClock.m_atlasTimer1 = csbNode:getChildByName("timer_atlas1")
	self.m_pClock.m_atlasTimer1:setString("00")
    self.m_pClock.m_atlasTimer1:setVisible(false)
	--提示
	self.m_pClock.m_spTip = csbNode:getChildByName("sp_tip")

	local frame = yl.GetPublicBlankFrame()
	if nil ~= frame then
		self.m_pClock.m_spTip:setSpriteFrame(frame)
	end
end
------------------------------------------------------     重置     ------------------------------------------------------

function GameViewLayer:enableJetton( var )
	self:resetJettonBtnInfo(var)    --下注按钮
	self:resetJettonArea(var)       --下注区域
end

function GameViewLayer:resetView()
	self:stopAllActions()
	self:gameDataReset()
end

function GameViewLayer:refreshJetton(  )
	local str = ExternalFun.numberThousands(self.m_lHaveJetton)
	self.m_clipJetton:setString(str)
	--self.m_userJettonLayout:setVisible(self.m_lHaveJetton > 0)
end

function GameViewLayer:refreshJettonNode(area, my, total, bMyJetton)
    local nodeAll = self.m_pNodeChipScoreAll[area]
    local nodePlayer = self.m_pNodeChipScorePlayer[area]

	if true == bMyJetton then
		nodePlayer.m_llScore = nodePlayer.m_llScore + my
	end
	nodeAll.m_llScore = nodeAll.m_llScore + total

	nodeAll:setVisible(nodeAll.m_llScore > 0)
	nodePlayer:setVisible(nodePlayer.m_llScore > 0)

	local str = ExternalFun.numberThousands(nodeAll.m_llScore)
	nodeAll:setString(str)

	str = ExternalFun.numberThousands(nodePlayer.m_llScore)
	nodePlayer:setString(str)

    local allScore = 0
    for i = 1 , g_var(cmd).AREA_MAX do
        allScore = allScore + self.m_pNodeChipScoreAll[i].m_llScore
    end
    self.m_pTextAllChip:setString(tostring(allScore))
end

function GameViewLayer:resetJettonArea( var )
	for i=1,#self.m_tableJettonArea do
		self.m_tableJettonArea[i]:setEnabled(var)
	end
end

function GameViewLayer:resetUserInfo(  )
	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore
	end

	self.m_pTextGold:setString(ExternalFun.formatScoreText(self.m_scoreUser))
    self.m_pTextName:setString(myUser.szNickName)
    self.m_pTextScore:setString(ExternalFun.formatScoreText(self._scene:getMyScore()) or 0)
end

function GameViewLayer:resetJettonNode(area)
    self.m_pNodeChipScoreAll[area]:setVisible(false)
    self.m_pNodeChipScorePlayer[area]:setVisible(false)
    
    self.m_pNodeChipScoreAll[area]:setString("")
    self.m_pNodeChipScorePlayer[area]:setString("")

	self.m_pNodeChipScoreAll[area].m_llScore = 0
	self.m_pNodeChipScorePlayer[area].m_llScore = 0
end

function GameViewLayer:resetJettonBtnInfo(var)
	for i=1,#self.m_tableJettonBtn do
		self.m_tableJettonBtn[i]:setTag(i)
		self.m_tableJettonBtn[i]:setEnabled(var)
        if var then
            self.m_tableJettonBtn[i]:setEnabled(true)
        else
            self.m_pIconChipLight:setVisible(false)
            self.m_tableJettonBtn[i]:setEnabled(false)
        end
	end
end

function GameViewLayer:adjustJettonBtn()
	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton
	local lCondition = math.min(self.m_scoreUser, lCanJetton)

	for i=1,#self.m_tableJettonBtn do
		local enable = false
		if self.m_bOnGameRes then
			enable = false
		else
			enable = self.m_bOnGameRes or (lCondition >= self.m_pJettonNumber[i].k)
		end
		self.m_tableJettonBtn[i]:setEnabled(enable)
	end
    --自动切换小一点的筹码
    if self.m_nSelectBet>0 and self.m_bOnGameRes == false then
        if not self.m_tableJettonBtn[self.m_nSelectBet]:isEnabled() then
            for i=self.m_nSelectBet-1, 1,-1 do
                if self.m_tableJettonBtn[i]:isEnabled() then
                    self:onJettonButtonClicked(self.m_tableJettonBtn[i]:getTag(), self.m_tableJettonBtn[i])
                    break
                end
            end
        end
    end
	if self.m_nJettonSelect > self.m_scoreUser then
		self.m_nJettonSelect = -1
	end
end

-------------------------------------------------------------  游戏动画  -------------------------------------------------------------
--下注筹码结算动画

function GameViewLayer:blinkAnimation()
    for k,v in pairs(self.m_tableJettonLight) do
        if self.cbBetAreaBlink[k] == 1 then
            self.m_tableJettonLight[k]:stopAllActions()
            self.m_tableJettonLight[k]:runAction(cc.Blink:create(6, 10))
        end
    end
end

function GameViewLayer:getAreaJettonCount(score)
    local areaJettonCount = {0,0,0,0,0,0,0}
    while score > 0 do
        local betNum = 0
        if score >= math.pow(10,7) then
            betNum = math.pow(10,7)
            betIndex = 7
        elseif score >= 5000000 then
            betNum = 5000000
            betIndex = 6
        elseif score >= 1000000 then
            betNum = 1000000
            betIndex = 5
        elseif score >= 100000 then
            betNum = 100000
            betIndex = 4
        elseif score >= 10000 then
            betNum = 10000
            betIndex = 3
        elseif score >= 1000 then
            betNum = 1000
            betIndex = 2
        elseif score >= 100 then
            betNum = 100
            betIndex = 1
        end

        if betNum == 0 or score < betNum then
            -- 数据错误
            print("数据错误")
            break
        end

        score = score - betNum
        if betIndex <= 0 or betIndex > 7 then
            betIndex = 1
        end

        areaJettonCount[betIndex] = areaJettonCount[betIndex] + 1
    end
    return areaJettonCount
end

function GameViewLayer:getDistributionPos(isMeChair)
    local pos = cc.p(yl.DESIGN_WIDTH/2, -200)
    if isMeChair then
        pos = cc.p(yl.DESIGN_WIDTH/2, -200)
    else
        pos = cc.p(-200 + math.random(0, 1) * (yl.WIDTH + 400), math.random(250, 500))
    end
    return pos
end

-- 第四步 弹出结算框 
function GameViewLayer:overAnimation()
    self.overCurCount = self.overCurCount + 1
    if self.overCurCount == self.overMaxCount then
        self:showGameResult(true)
    end
end

-- 第三步 玩家收筹码 时间为1.2秒
function GameViewLayer:distributionAnimation()
    self.feedbackCurCount = self.feedbackCurCount + 1
    
    self.overCurCount = 0
    self.overMaxCount = 0
    if self.feedbackCurCount == self.feedbackMaxCount then
        local betList = self.m_betAreaLayout:getChildren()
        local pos = 0
        local gap = 1.0/#betList
        local index = 0
        for k,v in pairs(betList) do
            pos = self:getDistributionPos(v.isMeChair)
            v:stopAllActions()
            self.overMaxCount = self.overMaxCount + 1
            v:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(gap*index), 
                    cc.MoveTo:create(BET_ANITIME, pos), 
                    cc.CallFunc:create(
                        function ()
                            self:overAnimation()
                        end)
                    )
            )
            index = index + 1
        end
    end
end

-- 第二步 反馈筹码 时间为0.2秒
function GameViewLayer:feedbackAnimation()
    self.recoveryCurCount = self.recoveryCurCount + 1
    if self.recoveryCurCount ~= self.recoveryMaxCount then
        return
    end
    -- 计算玩家各区域需要分配的筹码
    local winScore = 0      -- 代表自己
    local jettonList = {}
    local otherScore = {0,0,0,0,0,0,0,0}
    local betList = self.m_betAreaLayout:getChildren()
    self.feedbackMaxCount = 0
    self.feedbackCurCount = 0
    
    print(#betList)
    -- 计算其他人各区域需要分配的筹码
    for k, v in pairs(betList) do
        if v.isMeChair == false then
            otherScore[v.area] = otherScore[v.area] + v.score
        end
    end
    
    for i = 1, g_var(cmd).AREA_MAX do
        winScore = self:getDataMgr().m_tabGameEndCmd.lPlayScore[1][i]
        if winScore > 0 then
            jettonList = self:getAreaJettonCount(winScore)
            for j = 1, 7 do
                print("jettonList:"..jettonList[j])
                if jettonList[j] > 0 then
                    for k = 1, jettonList[j] do
                        item = display.newSprite(string.format("#baccaratnew_icon_smallchip%d.png", j))
                        item:setPosition(cc.p(self.m_pIconBankerBG:getPositionX(), self.m_pIconBankerBG:getPositionY()))
                        item:setScale(0.7)
                        item.area = i
                        item.isMeChair = true
                        self.m_betAreaLayout:addChild(item)
                        item:runAction(cc.Sequence:create(self:getBetAnimation(self:getBetRandomPos(i)), cc.CallFunc:create(function () self:distributionAnimation() end)))
                        self.feedbackMaxCount = self.feedbackMaxCount + 1
                    end
                end
            end
        end
        
        winScore = otherScore[i]
        if winScore > 0 then
            jettonList = self:getAreaJettonCount(winScore)
            for j = 1, 7 do
                print("jettonList:"..jettonList[j])
                if jettonList[j] > 0 then
                    for k = 1, jettonList[j] do
                        item = display.newSprite(string.format("#baccaratnew_icon_smallchip%d.png", j))
                        item:setPosition(cc.p(self.m_pIconBankerBG:getPositionX(), self.m_pIconBankerBG:getPositionY()))
                        item:setScale(0.7)
                        item.area = i
                        item.isMeChair = false
                        self.m_betAreaLayout:addChild(item)
                        item:runAction(cc.Sequence:create(self:getBetAnimation(self:getBetRandomPos(i)), cc.CallFunc:create(function () self:distributionAnimation() end)))
                        self.feedbackMaxCount = self.feedbackMaxCount + 1
                    end
                end
            end
        end
    end

    if self.feedbackMaxCount == 0 then
        self.overCurCount = 0
        self.overMaxCount = 1
        self:overAnimation()
    end
end

-- 第一步 回收筹码 时间为1.2秒
function GameViewLayer:recoveryAnimation()
    local betList = self.m_betAreaLayout:getChildren()
    local noRecovery = true
    local gapTime = 1.0/#betList
    local curIndex = 0
    local callback = cc.CallFunc:create(function () self:feedbackAnimation() end)
    self.recoveryCurCount = 0
    self.recoveryMaxCount = 0
    for k, v in pairs(betList) do
        if self.cbBetAreaBlink[v.area] ~= 1 then
            self.recoveryMaxCount = self.recoveryMaxCount + 1
            noRecovery = false
            v:stopAllActions()
            v:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(curIndex*gapTime),
                    cc.MoveTo:create(BET_ANITIME, cc.p(self.m_pIconBankerBG:getPositionX(), self.m_pIconBankerBG:getPositionY())),
                    callback,
                    cc.RemoveSelf:create()
                )
            )
            curIndex = curIndex + 1
        end
    end

    if noRecovery then
        self.recoveryMaxCount = self.recoveryMaxCount + 1
        self:feedbackAnimation()
    end
end

function GameViewLayer:OnDownMenuSwitchAnimate()
    if self.m_pNodeMenu:getScaleX() == 1 then
        self.m_pNodeMenu:stopAllActions()
        self.m_pNodeMenu:runAction(cc.ScaleTo:create(0.2, 0))
    elseif self.m_pNodeMenu:getScaleX() == 0 then
        self.m_pNodeMenu:stopAllActions()
        self.m_pNodeMenu:runAction(cc.ScaleTo:create(0.2, 1))
    end
end

function GameViewLayer:cleanJettonArea(  )
	--移除界面已下注
	self.m_betAreaLayout:removeAllChildren()

	for i=1,#self.m_tableJettonArea do
        self:resetJettonNode(i)
	end

    self.m_pTextAllChip:setString("0")
	self.m_userJettonLayout:setVisible(false)
	self.m_clipJetton:setString("")
end

-------------------------------------------------------------  游戏按钮  -------------------------------------------------------------

function GameViewLayer:onButtonClickedEvent(tag,ref)
    ExternalFun.playSoundEffect("baccaratnew_click.mp3")
    if tag == TAG_ENUM.BT_EXIT then
	    self:getParentNode():onQueryExitGame()
        self:OnDownMenuSwitchAnimate()
    elseif tag == TAG_ENUM.BT_MESSAGE then
        print("聊天按钮被点击")
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            print("item ~= nil")
            item:resetData()
        else
            print("item new")
            local gameSystemMessage = GameSystemMessage:create()
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
    elseif tag == TAG_ENUM.BT_USERLIST then
	    if nil == self.m_userListLayer then
		    self.m_userListLayer = g_var(UserListLayer):create()
		    self:addToRootLayer(self.m_userListLayer, TAG_ZORDER.USERLIST_ZORDER)
	    end
	    local userList = self:getDataMgr():getUserList()		
	    self.m_userListLayer:refreshList(userList)
    elseif tag == TAG_ENUM.BT_APPLYBANKER then
	    self:applyBanker(APPLY_STATE.kCancelState)
    elseif tag == TAG_ENUM.BT_CANCELAPPLY then
	    self:applyBanker(APPLY_STATE.kApplyState)
    elseif tag == TAG_ENUM.BT_CANCELBANKER then
	    self:applyBanker(APPLY_STATE.kApplyedState)
    elseif tag == TAG_ENUM.BT_HELP then
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self,  g_var(cmd).KIND_ID, 0)
            self:addToRootLayer(self.layerHelp, TAG_ZORDER.HELP_ZORDER)
        else
            self.layerHelp:onShow()
        end
        self:OnDownMenuSwitchAnimate()
    elseif tag == TAG_ENUM.BT_SET then
        if nil == self.layerSetting then
            local mgr = self._scene._scene:getApp():getVersionMgr(g_var(cmd).KIND_ID)
            local verstr = mgr:getResVersion() or "0"
	        self.layerSetting = g_var(SettingLayer):create(verstr)
	        self:addToRootLayer(self.layerSetting, TAG_ZORDER.SETTING_ZORDER)
        else
            self.layerSetting:onShow()
        end
        self:OnDownMenuSwitchAnimate()
    elseif tag == TAG_ENUM.BT_ROBBANKER then
	    --超级抢庄
	    if g_var(cmd).SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
		    local str = "超级抢庄将花费 " .. self.m_tabSupperRobConfig.lSuperBankerConsume .. ",确定抢庄?"
		    local query = QueryDialog:create(str, function(ok)
		        if ok == true then
		            self:getParentNode():sendRobBanker()
		        end
		    end):setCanTouchOutside(false)
		        :addTo(self) 
	    else
		    self:getParentNode():sendRobBanker()
	    end
    elseif tag == TAG_ENUM.BT_BANK then
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
        if self._bankLayer == nil  then
            self._bankLayer = BankLayer:create(self) 
            self:addToRootLayer(self._bankLayer,TAG_ZORDER.BANK_ZORDER)
        else
            self._bankLayer:onShow()
        end
	    self:OnDownMenuSwitchAnimate()
    elseif tag == TAG_ENUM.BT_MENU then
        if self.m_pNodeMenu:getNumberOfRunningActions() > 0 then
            return
        end

        self:OnDownMenuSwitchAnimate()
    else
	    showToast(cc.Director:getInstance():getRunningScene(),"功能尚未开放！",1)
    end
end

function GameViewLayer:onJettonButtonClicked( tag, ref )
	if tag >= 1 and tag <= 7 then
		self.m_nJettonSelect = self.m_pJettonNumber[tag].k
        self.m_pIconChipLight:setVisible(true)
        self.m_pIconChipLight:setPosition(self.m_tableJettonBtn[tag]:getPosition())
	else
		self.m_nJettonSelect = -1
	end


	self.m_nSelectBet = tag
end

function GameViewLayer:onJettonAreaClicked( tag, ref )
	local m_nJettonSelect = self.m_nJettonSelect

	if m_nJettonSelect < 0 then
		return
	end

	local area = tag - 1
    local areaMaxPlayerScore = self:GetMaxPlayerScore(area)
	if self.m_lHaveJetton > self.m_llMaxJetton or m_nJettonSelect > areaMaxPlayerScore then
		showToast(cc.Director:getInstance():getRunningScene(),"已超过最大下注限额",1)
		self.m_lHaveJetton = self.m_lHaveJetton - m_nJettonSelect
		return
	end

	--下注
	self:getParentNode():sendUserBet(area, m_nJettonSelect)	
end

function GameViewLayer:onSitDownClick( tag, sender )
	print("sit ==> " .. tag)
	local useritem = self:getMeUserItem()
	if nil == useritem then
		return
	end

	--重复判断
	if nil ~= self.m_nSelfSitIdx and tag == self.m_nSelfSitIdx then
		return
	end

	if nil ~= self.m_nSelfSitIdx then --and tag ~= self.m_nSelfSitIdx  then
		showToast(cc.Director:getInstance():getRunningScene(), "当前已占 " .. self.m_nSelfSitIdx .. " 号位置,不能重复占位!", 2)
		return
	end	

	--坐下条件限制
	if self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_CONSUMETYPE then --金币占座
		if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatConsume then
			local str = "坐下需要消耗 " .. self.m_tabSitDownConfig.lOccupySeatConsume .. " 金币,金币不足!"
			showToast(cc.Director:getInstance():getRunningScene(), str, 2)
			return
		end
		local str = "坐下将花费 " .. self.m_tabSitDownConfig.lOccupySeatConsume .. ",确定坐下?"
			local query = QueryDialog:create(str, function(ok)
		        if ok == true then
		            self:getParentNode():sendSitDown(tag - 1, useritem.wChairID)
		        end
		    end):setCanTouchOutside(false)
		        :addTo(self)
	elseif self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_VIPTYPE then --会员占座
		if useritem.cbMemberOrder < self.m_tabSitDownConfig.enVipIndex then
			local str = "坐下需要会员等级为 " .. self.m_tabSitDownConfig.enVipIndex .. " 会员等级不足!"
			showToast(cc.Director:getInstance():getRunningScene(), str, 2)
			return
		end
		self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
	elseif self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_FREETYPE then --免费占座
		if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatFree then
			local str = "免费坐下需要携带金币大于 " .. self.m_tabSitDownConfig.lOccupySeatFree .. " ,当前携带金币不足!"
			showToast(cc.Director:getInstance():getRunningScene(), str, 2)
			return
		end
		self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
	end
end

------------------------------------------------------     待定     ------------------------------------------------------

function GameViewLayer:showGameResult(bShow)
	if true == bShow then
		if nil == self.m_gameResultLayer then
			self.m_gameResultLayer = g_var(GameResultLayer):create()
			self:addToRootLayer(self.m_gameResultLayer, TAG_ZORDER.GAMERS_ZORDER)
		end

        self.m_gameResultLayer:showGameResult(self:getDataMgr().m_tabGameResult, self.m_pCardData, self)
	else
		if nil ~= self.m_gameResultLayer then
			self.m_gameResultLayer:hideGameResult()
		end
	end
end

function GameViewLayer:onExit()
	self:resetView()
end

------------------------------------------------------   网络请求   ------------------------------------------------------
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


------------------------------------------------------   网络消息   ------------------------------------------------------
--网络接收
function GameViewLayer:onGetUserScore( item )
	--自己
	if item.dwUserID == GlobalUserItem.dwUserID then
       self:resetUserInfo()
    end

    --坐下用户
    for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
    	if nil ~= self.m_tabSitDownUser[i] then
    		if item.wChairID == self.m_tabSitDownUser[i]:getChair() then
    			self.m_tabSitDownUser[i]:updateScore(item)
    		end
    	end
    end

    --庄家
    if self.m_wBankerUser == item.wChairID then
    	--庄家金币
--		local str = ExternalFun.formatNumberThousands(item.lScore)
--		if string.len(str) > 11 then
--			str = string.sub(str, 1, 9) .. "..."
--		end
		self.m_pTextBankerGold:setString(ExternalFun.formatScoreText(item.lScore))
		if yl.INVALID_CHAIR == self.m_wBankerUser then
	        self.m_pTextBankerGold:setString("")
        end
    end
end

function GameViewLayer:onGameFree()        -- 游戏free
	yl.m_bDynamicJoin = false
    self.m_pNodeChip:setVisible(true)           -- 开启下注界面
    self.m_pNodeShowCard:setVisible(false)      -- 关闭开牌界面
	self:cleanJettonArea()                      -- 重置下注区域
    self.m_pNodeCardLayer:removeAllChildren()   -- 清空扑克层
    self.m_pNodeWinner:setVisible(false)        -- 关闭赢家动画
	self:refreshApplyBtnState()             -- 申请按钮状态更新
    self:updateCanChip()
    for k,v in pairs(self.m_tableJettonLight) do
        self.m_tableJettonLight[k]:stopAllActions()
        self.m_tableJettonLight[k]:setVisible(false)
    end
end

function GameViewLayer:onGameStart(lUserJetton)        -- 游戏开始
    if lUserJetton == 0 then
        -- 播放开始下注动画
        self.m_pAniStartChip1:setVisible(true)
        self.m_pAniStartChip2:setVisible(true)

        self.m_pAniStartChip1:setOpacity(0)
        self.m_pAniStartChip2:setOpacity(0)
        
        self.m_pAniStartChip1:setPosition(cc.p(-200, self.m_pAniStartChip1:getPositionY()))
        self.m_pAniStartChip2:setPosition(cc.p(yl.WIDTH+200, self.m_pAniStartChip2:getPositionY()))

        local chip1Move1 = cc.MoveTo:create(0.5, cc.p(yl.WIDTH/2+54, self.m_pAniStartChip1:getPositionY()))
        local chip1Spawn1 = cc.Spawn:create(cc.FadeIn:create(0.5), chip1Move1)
        local chip1Move2 = cc.MoveTo:create(0.1, cc.p(yl.WIDTH/2+27, self.m_pAniStartChip1:getPositionY()))
        local chip1Move3 = cc.MoveTo:create(0.1, cc.p(yl.WIDTH/2+54, self.m_pAniStartChip1:getPositionY()))
        local chip1Delay = cc.DelayTime:create(1)
        local chip1Move4 = cc.MoveTo:create(0.3, cc.p(-400, self.m_pAniStartChip1:getPositionY()))
        local chip1Spawn2 = cc.Spawn:create(cc.FadeOut:create(0.3), chip1Move4)

        local chip2Move1 = cc.MoveTo:create(0.5, cc.p(yl.WIDTH/2-54, self.m_pAniStartChip2:getPositionY()))
        local chip2Spawn1 = cc.Spawn:create(cc.FadeIn:create(0.5), chip2Move1)
        local chip2Move2 = cc.MoveTo:create(0.1, cc.p(yl.WIDTH/2-27, self.m_pAniStartChip2:getPositionY()))
        local chip2Move3 = cc.MoveTo:create(0.1, cc.p(yl.WIDTH/2-54, self.m_pAniStartChip2:getPositionY()))
        local chip2Delay = cc.DelayTime:create(1)
        local chip2Move4 = cc.MoveTo:create(0.3, cc.p(yl.WIDTH+400, self.m_pAniStartChip2:getPositionY()))
        local chip2Spawn2 = cc.Spawn:create(cc.FadeOut:create(0.3), chip2Move4)

        self.m_pAniStartChip1:stopAllActions()
        self.m_pAniStartChip2:stopAllActions()

        self.m_pAniStartChip1:runAction(cc.Sequence:create(chip1Spawn1, chip1Move2, chip1Move3, chip1Delay, chip1Spawn2))
        self.m_pAniStartChip2:runAction(cc.Sequence:create(chip2Spawn1, chip2Move2, chip2Move3, chip2Delay, chip2Spawn2))
    end

    self:showGameResult(false)
    self.m_pNodeChip:setVisible(true)
    self.m_pNodeShowCard:setVisible(false)
    self.m_pNodeWinner:setVisible(false)
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k
	self.m_lHaveJetton = lUserJetton
	self:resetUserInfo()        -- 获取玩家携带游戏币
	self.m_bOnGameRes = false
	if false == self:isMeChair(self.m_wBankerUser) and false == self.m_bNoBanker then   -- 自己不是庄家,且有庄家
		self:enableJetton(true) -- 下注
		self:adjustJettonBtn()  -- 调整下注按钮
	end
	--math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	self:refreshApplyBtnState() -- 申请按钮状态更新
    self:updateCanChip()
end

--下注条件
function GameViewLayer:onGetApplyBankerCondition( llCon , rob_config)
	self.m_llCondition = llCon
	self.m_tabSupperRobConfig = rob_config  -- 超级抢庄配置
end

--刷新庄家信息
function GameViewLayer:onChangeBanker( wBankerUser, lBankerScore, bEnableSysBanker )
	print("更新庄家数据:" .. wBankerUser .. " coin =>" .. lBankerScore)

	--上一个庄家是自己，且当前庄家不是自己，标记自己的状态
	if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
        self:setBtnBankerType(APPLY_STATE.kCancelState)
	end

    if self.m_wBankerUser ~= wBankerUser then
        self:setBankerScore(0)
    end
	self.m_wBankerUser = wBankerUser
	--获取庄家数据
	self.m_bNoBanker = false

	local nickstr = ""
	--庄家姓名
	if true == bEnableSysBanker then --允许系统坐庄
		if yl.INVALID_CHAIR == wBankerUser then
			nickstr = "系统坐庄"
			lBankerScore = 9999999999
            
            local head = self.m_pIconBankerBG:getChildByTag(199)
            if head ~= nil then
                head:removeFromParent()
            end
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1]
			if nil ~= userItem then
				nickstr = userItem.szNickName 

				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
                    self:setBtnBankerType(APPLY_STATE.kApplyedState)
				end
			else
				print("获取用户数据失败")
			end
		end	
	else
		if yl.INVALID_CHAIR == wBankerUser then
			nickstr = "无人坐庄"
			self.m_bNoBanker = true
            
            local head = self.m_pIconBankerBG:getChildByTag(199)
            if head ~= nil then
                head:removeFromParent()
            end
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1]
			if nil ~= userItem then
				nickstr = userItem.szNickName 

				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
                    self:setBtnBankerType(APPLY_STATE.kApplyedState)
				end
			else
				print("获取用户数据失败")
			end
		end
	end
	self.m_pTextBankerName:setString(nickstr)

    if yl.INVALID_CHAIR ~= wBankerUser then
        local head = self.m_pIconBankerBG:getChildByTag(199)
        if head ~= nil then
            head:removeFromParent()
        end

        local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1]
		if userItem ~= nil then
			head = g_var(PopupInfoHead):createNormal(userItem, 90)
            local headBg = display.newSprite("#userinfo_head_frame.png")
            headBg:setPosition(cc.p(64, 54))
            headBg:setScale(0.55,0.55)
			head:setPosition(cc.p(64, 54))
			head:enableHeadFrame(false)
			--head:enableInfoPop(false, cc.p(0, 0), cc.p(0, 0))
			head:setTag(199)
            self.m_pIconBankerBG:addChild(headBg)
            self.m_pIconBankerBG:addChild(head)
        end
    end
    
    local head = self.m_pIconBankerBG:getChildByTag(199)
    if head == nil then
        local headBg = display.newSprite("#userinfo_head_frame.png")
        local head = display.newSprite("#userinfo_head_0.png")
        headBg:setPosition(cc.p(64, 54))
        headBg:setScale(0.55)
		head:setPosition(cc.p(63, 54))
        head:setScale(0.55)
		head:setTag(199)
        self.m_pIconBankerBG:addChild(headBg)
        self.m_pIconBankerBG:addChild(head)
    end 
	--庄家金币
--	local str = ExternalFun.formatNumberThousands(lBankerScore)
--	if string.len(str) > 11 then
--		str = string.sub(str, 1, 7) .. "..."
--	end
    
    self.m_lBankerScore = lBankerScore
	self.m_pTextBankerGold:setString(ExternalFun.formatScoreText(lBankerScore))
    
	if true == bEnableSysBanker then --允许系统坐庄
		if yl.INVALID_CHAIR == wBankerUser then
	        self.m_pTextBankerGold:setString("")
        end
    end
	--如果是超级抢庄用户上庄
	if wBankerUser == self.m_wCurrentRobApply then
		self.m_wCurrentRobApply = yl.INVALID_CHAIR
		--willself:refreshCondition()
	end

	--坐下用户庄家
	local chair = -1
	for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		if nil ~= self.m_tabSitDownUser[i] then
			chair = self.m_tabSitDownUser[i]:getChair()
			self.m_tabSitDownUser[i]:updateBanker(chair == wBankerUser)
		end
	end
end

--更新用户下注
function GameViewLayer:onGetUserBet( )
	local data = self:getParentNode().cmd_placebet
	if nil == data then
		return
	end
	local area = data.cbBetArea + 1
	local wUser = data.wChairID
	local llScore = data.lBetScore
	local nIdx = self:getJettonIdx(data.lBetScore)
	local str = string.format("baccaratnew_icon_smallchip%d.png", nIdx)
	local sp = nil
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
	local btn = self.m_tableJettonArea[area]
	if nil ~= frame then
		sp = cc.Sprite:createWithSpriteFrame(frame)
	end

	if nil ~= sp and nil ~= btn then
		
		local name = string.format("%d", area)  --下注
		local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))  --筹码飞行起点位置
		local act = self:getBetAnimation(self:getBetRandomPos(area), cc.CallFunc:create(function()  --筹码飞行动画
			ExternalFun.playSoundEffect("baccaratnew_add_score.mp3")    --播放下注声音
		end))

        sp:setScale(0.7)
		sp:setTag(wUser)
		sp:setName(name)
		sp:setPosition(pos)
		sp:stopAllActions()
		sp:runAction(act)
        sp.isMeChair = self:isMeChair(wUser)
        sp.area = area
        sp.score = llScore
		self.m_betAreaLayout:addChild(sp)

		self:refreshJettonNode(area, llScore, llScore, self:isMeChair(wUser))
	end

	if self:isMeChair(wUser) then
		self.m_scoreUser = self.m_scoreUser - self.m_nJettonSelect
		self.m_lHaveJetton = self.m_lHaveJetton + llScore
		self:adjustJettonBtn()  --调整下注按钮
		self:refreshJetton()    --显示下注信息
	end
end

--更新用户下注失败
function GameViewLayer:onGetUserBetFail(  )
	local data = self:getParentNode().cmd_jettonfail
	if nil == data then
		return
	end

	local wUser = data.wPlaceUser       -- 下注玩家
	local cbArea = data.cbBetArea + 1   -- 下注区域
	local llScore = data.lPlaceScore    -- 下注数额

	if self:isMeChair(wUser) then
		local str = string.format("下注 %s 失败", tostring(llScore))    -- 提示下注失败
		showToast(cc.Director:getInstance():getRunningScene(),str,1)

		self.m_scoreUser = self.m_scoreUser + llScore       --自己下注失败
		self.m_lHaveJetton = self.m_lHaveJetton - llScore
		self:adjustJettonBtn()
		self:refreshJetton()

		if 0 ~= self.m_lHaveJetton then
            self:refreshJettonNode(cbArea,-llScore, -llScore, true)

			local name = string.format("%d", cbArea)        --移除界面下注元素
			self.m_betAreaLayout:removeChildByName(name)
		end
	end
end

--断线重连更新界面已下注
function GameViewLayer:reEnterGameBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea]
	if nil == btn or 0 == llSocre then
		return
	end

	local vec = self:getDataMgr().calcuteJetton(llScore, false)
	for k,v in pairs(vec) do
		local info = v
		for i=1,info.m_cbCount do
			local str = string.format("baccaratnew_icon_smallchip%d.png", info.m_cbIdx)
			local sp = cc.Sprite:createWithSpriteFrameName(str)
			if nil ~= sp then
				sp:setScale(0.7)
				sp:setTag(yl.INVALID_CHAIR)
				local name = string.format("%d", cbArea)
				sp:setName(name)

				self:randomSetJettonPos(cbArea, sp)
				self.m_betAreaLayout:addChild(sp)
			end
		end
	end

	self:refreshJettonNode(cbArea, llScore, llScore, false)
end

--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea]
	if nil == btn or 0 == llSocre then
		return
	end

	self:refreshJettonNode(cbArea, llScore, 0, true)
end

--游戏结束
function GameViewLayer:onGetGameEnd(  )
	self.m_bOnGameRes = true

	--不可下注
	self:enableJetton(false)
end

--申请庄家
function GameViewLayer:onGetApplyBanker()
	if self:isMeChair(self:getParentNode().cmd_applybanker.wApplyUser) then
		self.m_enApplyState = APPLY_STATE.kApplyState
        self:setBtnBankerType(APPLY_STATE.kApplyState)
	end

	self:refreshApplyList()
end

--取消申请庄家
function GameViewLayer:onGetCancelBanker(  )
	if self:isMeChair(self:getParentNode().cmd_cancelbanker.wCancelUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
        self:setBtnBankerType(APPLY_STATE.kCancelState)
	end
	
	self:refreshApplyList()
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)
	end
end

function GameViewLayer:refreshUserList(  )
	if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
		local userList = self:getDataMgr():getUserList()		
		self.m_userListLayer:refreshList(userList)
	end
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		self.m_applyListLayer:refreshBtnState()
	end
end

--更新扑克牌
function GameViewLayer:onGetGameCard( tabRes, bAni, cbTime )    
    --self.m_pNodeChip:setVisible(false)
    self.m_pNodeShowCard:setVisible(true)
    self.m_pNodeCardLayer:removeAllChildren()
        
    self.m_pCardData = tabRes
    self.m_pHandDataXian = {}
    self.m_pHandDataZhuang = {}
    
    self.m_tabCardXian = {}
    self.m_tabCardZhuang = {}
    self.m_pCurDir = 0
    self:showCardAnimation()
end

function GameViewLayer:showCardAnimation()
    if (#self.m_pCardData.m_idleCards+#self.m_pCardData.m_masterCards) == (#self.m_pHandDataXian+#self.m_pHandDataZhuang) then
        self:getShowCardResult()
        return
    end

    local cardData = 0
    local startX = 0
    local startY = 330-33
    local addDir = 0
    local cardWidth = 110
    local cardHeight = 150
    local targetX = 0
    local card = nil

    if self.m_pCurDir == 0 then
        if #self.m_pHandDataXian < #self.m_pCardData.m_idleCards then
            cardData = self.m_pCardData.m_idleCards[#self.m_pHandDataXian+1]        -- 获取卡牌数据
            self.m_pHandDataXian[#self.m_pHandDataXian+1] = cardData                -- 添加到手牌
            card = g_var(CardSprite):createCard(cardData)                           -- 创建扑克
            table.insert(self.m_tabCardXian, card)                                  -- 保存到数组
            startX = 334-(#self.m_tabCardXian-1)*(cardWidth/2)                      -- 继续起始点
            targetX = startX+(#self.m_tabCardXian-1)*cardWidth                      -- 计算终点
            addDir = 0                                                              -- 保存这次添加的区域
            self.m_pCurDir = 1                                                      -- 设置下一次添加的区域
        elseif #self.m_pHandDataZhuang < #self.m_pCardData.m_masterCards then
            cardData = self.m_pCardData.m_masterCards[#self.m_pHandDataZhuang+1]
            self.m_pHandDataZhuang[#self.m_pHandDataZhuang+1] = cardData
            card = g_var(CardSprite):createCard(cardData)
            table.insert(self.m_tabCardZhuang, card)
            startX = 1000-(#self.m_tabCardZhuang-1)*(cardWidth/2)
            targetX = startX+(#self.m_tabCardZhuang-1)*cardWidth
            addDir = 1
            self.m_pCurDir = 0
        end
    else
        if #self.m_pHandDataZhuang < #self.m_pCardData.m_masterCards then
            cardData = self.m_pCardData.m_masterCards[#self.m_pHandDataZhuang+1]
            self.m_pHandDataZhuang[#self.m_pHandDataZhuang+1] = cardData
            card = g_var(CardSprite):createCard(cardData)
            table.insert(self.m_tabCardZhuang, card)
            startX = 1000-(#self.m_tabCardZhuang-1)*(cardWidth/2)
            targetX = startX+(#self.m_tabCardZhuang-1)*cardWidth
            addDir = 1
            self.m_pCurDir = 0
        end
    end
    
    if card == nil then
        return
    end
    card:setPosition(cc.p(378,669))
    card:setRotation(50)
    card:setScale(0.30)
    self.m_pNodeCardLayer:addChild(card)
    card:stopAllActions()
    card.isMove = true

    local animation = cc.Animation:create()
    for i = 1, 3 do
        local frameName = string.format("baccaratnew_ani_end_card%d.png", i)
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
        animation:addSpriteFrame(spriteFrame)
    end  
    animation:setDelayPerUnit(0.1)          -- 设置两个帧播放时间                   
    animation:setRestoreOriginalFrame(true) -- 动画执行后还原初始状态   
    local action = cc.Animate:create(animation)

    -- 先旋转并且移动到目标点
    card:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(0.2, cc.p(targetX, startY+cardHeight/2)),
                cc.RotateTo:create(0.2, 720),
                cc.ScaleTo:create(0.2, 1)
            ),
            action,
            cc.CallFunc:create(function()
                local xianPoint = g_var(GameLogic).GetCardListPip(self.m_pHandDataXian)
                local zhuangPoint = g_var(GameLogic).GetCardListPip(self.m_pHandDataZhuang)
                card:showCardBack(false)
                card.isMove = false
                self.m_pNodeEndPointPlayer.point:setString(string.format(xianPoint))
                self.m_pNodeEndPointBanker.point:setString(string.format(zhuangPoint))
                self:showCardAnimation()
            end)
        )
    )

    -- 调整坐标
    
    if addDir == 0 then
        for k,v in pairs(self.m_tabCardXian) do
            if v.isMove == false then
                v:stopAllActions()
                v:runAction(cc.MoveTo:create(0.2, cc.p(startX+(k-1)*cardWidth, startY+cardHeight/2)))
            end
        end
    else
        for k,v in pairs(self.m_tabCardZhuang) do
            if v.isMove == false then
                v:stopAllActions()
                v:runAction(cc.MoveTo:create(0.2, cc.p(startX+(k-1)*cardWidth, startY+cardHeight/2)))
            end
        end
    end
end

function GameViewLayer:getShowCardResult()
    self.cbBetAreaBlink = {0,0,0,0,0,0,0,0}
    local xianPoint = g_var(GameLogic).GetCardListPip(self.m_pHandDataXian)
    local zhuangPoint = g_var(GameLogic).GetCardListPip(self.m_pHandDataZhuang)
	self:getDataMgr().m_tabGameResult.m_cbPlayerPoint = xianPoint
	self:getDataMgr().m_tabGameResult.m_cbBankerPoint = zhuangPoint
	local nowCBWinner = g_var(cmd).AREA_MAX
	local nowCBKingWinner = g_var(cmd).AREA_MAX

    local isShowNodeWinner = false
    local nodeWinnerPos = cc.p(0, 0)

	if xianPoint > zhuangPoint then		
		nowCBWinner = g_var(cmd).AREA_XIAN
		self.cbBetAreaBlink[g_var(cmd).AREA_XIAN + 1] = 1
		if 8 == xianPoint or 9 == xianPoint then        --闲天王
            nowCBKingWinner = g_var(cmd).AREA_XIAN_TIAN
			self.cbBetAreaBlink[g_var(cmd).AREA_XIAN_TIAN + 1] = 1
		end
        -- 这里
        isShowNodeWinner = true
        nodeWinnerPos = cc.p(self.m_pNodeEndPointPlayer:getPositionX(), self.m_pNodeWinner:getPositionY())
	elseif xianPoint < zhuangPoint then
		nowCBWinner = g_var(cmd).AREA_ZHUANG
		self.cbBetAreaBlink[g_var(cmd).AREA_ZHUANG + 1] = 1  --庄
		if 8 == zhuangPoint or 9 == zhuangPoint then
            nowCBKingWinner = g_var(cmd).AREA_ZHUANG_TIAN
			self.cbBetAreaBlink[g_var(cmd).AREA_ZHUANG_TIAN + 1] = 1
		end
        
        isShowNodeWinner = true
        nodeWinnerPos = cc.p(self.m_pNodeEndPointBanker:getPositionX(), self.m_pNodeWinner:getPositionY())
	elseif xianPoint == zhuangPoint then
		nowCBWinner = g_var(cmd).AREA_PING
		self.cbBetAreaBlink[g_var(cmd).AREA_PING + 1] = 1    --平
		--判断是否为同点平
		local bAllPointSame = false
		if #self.m_pHandDataXian == #self.m_pHandDataZhuang then
            g_var(GameLogic).SortCardList(self.m_pHandDataXian, g_var(GameLogic).ST_ORDER)
            g_var(GameLogic).SortCardList(self.m_pHandDataZhuang, g_var(GameLogic).ST_ORDER)
			for i = 1, #self.m_pHandDataXian do
				local cbZhuangValue = g_var(GameLogic).GetCardValue(self.m_pHandDataZhuang[i])
				local cbXianValue = g_var(GameLogic).GetCardValue(self.m_pHandDataXian[i])

				if cbZhuangValue ~= cbXianValue then
					break
				end

				if i == #self.m_pHandDataZhuang then
					bAllPointSame = true
				end
			end
		end

		--同点平
		if true == bAllPointSame then
            nowCBKingWinner = g_var(cmd).AREA_TONG_DUI
			self.cbBetAreaBlink[g_var(cmd).AREA_TONG_DUI + 1] = 1
		end
        isShowNodeWinner = false
	end
    
	local nowBIdleTwoPair = false
	local nowBMasterTwoPair = false
	--闲对子
	if g_var(GameLogic).GetCardValue(self.m_pHandDataXian[1]) == g_var(GameLogic).GetCardValue(self.m_pHandDataXian[2]) then
        nowBIdleTwoPair = true
		self.cbBetAreaBlink[g_var(cmd).AREA_XIAN_DUI + 1] = 1
	end
	--庄对子
	if g_var(GameLogic).GetCardValue(self.m_pHandDataZhuang[1]) == g_var(GameLogic).GetCardValue(self.m_pHandDataZhuang[2]) then
        nowBMasterTwoPair = true
		self.cbBetAreaBlink[g_var(cmd).AREA_ZHUANG_DUI + 1] = 1
	end

    if isShowNodeWinner then
        local winnerAni = display.newSprite("#baccaratnew_ani_end_winner1.png")
        winnerAni:setPosition(cc.p(100, 100))
        self.m_pNodeWinner:addChild(winnerAni)
        local animation = cc.Animation:create()
        for i = 1, 8 do
            local frameName = string.format("baccaratnew_ani_end_winner%d.png", i)
            local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
            animation:addSpriteFrame(spriteFrame)
        end  
        animation:setDelayPerUnit(0.1)          -- 设置两个帧播放时间                   
        animation:setRestoreOriginalFrame(true) -- 动画执行后还原初始状态   
        local action = cc.Animate:create(animation)
        winnerAni:runAction(cc.Sequence:create(cc.DelayTime:create(3.2), action, cc.RemoveSelf:create()))
        
        self.m_pNodeWinner:setScale(0)
        self.m_pNodeWinner:setPosition(nodeWinnerPos)
        self.m_pNodeWinner:stopAllActions()
        self.m_pNodeWinner:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(3), 
                cc.CallFunc:create(function() 
                    ExternalFun.playSoundEffect("baccaratnew_game_winner.mp3") 
                end), 
                cc.Show:create(), 
                cc.ScaleTo:create(0.2, 1),
                cc.CallFunc:create(function()
                    self:blinkAnimation()
                end),
                cc.DelayTime:create(1.2),
                cc.ScaleTo:create(0.2, 0),
                cc.CallFunc:create(function()
                    self:recoveryAnimation()
                end)
            )
        )
    else
        self.m_pNodeWinner:setVisible(false)
        self.m_pNodeWinner:stopAllActions()
        self.m_pNodeWinner:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(2),
                cc.CallFunc:create(function()
                    self:blinkAnimation()
                end), 
                cc.DelayTime:create(1),
                cc.CallFunc:create(function()
                    self:recoveryAnimation()
                end)
            )
        )
    end

    local bJoin = self:getDataMgr().m_bJoin
	local res = self:getDataMgr().m_tabGameResult
	if false == yl.m_bDynamicJoin then
        local serverrecord = g_var(bjlDefine).getEmptyServerRecord()    -- 添加路单记录
        serverrecord.cbKingWinner = nowCBKingWinner
        serverrecord.bPlayerTwoPair = nowBIdleTwoPair
        serverrecord.bBankerTwoPair = nowBMasterTwoPair
        serverrecord.cbPlayerCount = idlePoint
        serverrecord.cbBankerCount = masterPoint

		local rec = g_var(bjlDefine).getEmptyRecord()
        rec.m_pServerRecord = serverrecord
        rec.m_cbGameResult = nowCBWinner
        
        rec.m_tagUserRecord.m_bJoin = bJoin
        if bJoin then        	
        	rec.m_tagUserRecord.m_bWin = res.m_lPlayerTotalScore > 0
        end

        self:addGameRecord(rec)
	end
end

function GameViewLayer:addGameRecord(rec)
    -----------------------------大路图----------------------------------
    local curIndex = (self.m_DalutuLie - 1) * 6 + self.m_DalutuHang

    if curIndex == 1 then
        if self.m_vecDalutu[curIndex]:getCheck() == g_var(cmd).AREA_MAX then
            self.m_vecDalutu[curIndex]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, rec.m_cbGameResult)   -- 直接添加
        else 
            if self.m_vecDalutu[curIndex]:getCheck() == rec.m_cbGameResult or rec.m_cbGameResult == g_var(cmd).AREA_PING or self.m_vecDalutu[curIndex]:getCheck() == g_var(cmd).AREA_PING then
                if rec.m_cbGameResult == g_var(cmd).AREA_PING then
                    self.m_vecDalutu[curIndex+1]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, self.m_vecDalutu[curIndex]:getCheck()) -- 在下一行添加
                else
                    self.m_vecDalutu[curIndex+1]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, rec.m_cbGameResult) -- 在下一行添加
                end
                self.m_DalutuHang = self.m_DalutuHang + 1
            else
                if rec.m_cbGameResult == g_var(cmd).AREA_PING then
                    self.m_vecDalutu[curIndex+6]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, self.m_vecDalutu[curIndex]:getCheck())
                else
                    self.m_vecDalutu[curIndex+6]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, rec.m_cbGameResult)
                end

                self.m_DalutuLie = self.m_DalutuLie + 1
                self.m_DalutuSaveLie = self.m_DalutuLie
            end
        end
    else
        if self.m_vecDalutu[curIndex]:getCheck() == rec.m_cbGameResult or rec.m_cbGameResult == g_var(cmd).AREA_PING or self.m_vecDalutu[curIndex]:getCheck() == g_var(cmd).AREA_PING then
            if self.m_DalutuHang == 6 or self.m_vecDalutu[curIndex+1]:getCheck() ~= g_var(cmd).AREA_MAX then  -- 接龙,大于6的话往右
                local gapIndex = 6
                local saveCheck = self.m_vecDalutu[curIndex]:getCheck()
                if self.m_DalutuLie >= self.m_DalutuMaxLie then     -- 是否大于当前列表宽度
                    if self.m_DalutuMaxLie < 20 then                -- 当前列表宽度是否大于最大宽度 20
                        self.m_DalutuMaxLie = self.m_DalutuMaxLie + 1
                    else                                            -- 大于20的话删除第一列
                        gapIndex = 0
                        for i = 6, 1, -1 do -- 行
                            self.m_vecDalutu[i]:removeFromParent()
                            table.remove(self.m_vecDalutu, i)
                        end
                        self.m_DalutuSaveLie = self.m_DalutuSaveLie - 1
                    end
                    local ludanSpr
                    local index
                    for j = 1, 6 do -- 行
                        index = ((self.m_DalutuBlackGrayLie+1)%2+self.m_DalutuBlackGrayHang)%2
                        if self.m_DalutuBlackGrayHang < 5 then
                            self.m_DalutuBlackGrayHang = self.m_DalutuBlackGrayHang + 1
                        else
                            self.m_DalutuBlackGrayHang = 0
                            self.m_DalutuBlackGrayLie = self.m_DalutuBlackGrayLie + 1
                        end
                        
                        ludanSpr = g_var(LudanPoint):create(index, 0.6458)
                        ludanSpr:setPosition(cc.p((self.m_DalutuMaxLie-1)*ludanSpr:getContentSize().width*0.6458, 186-j*ludanSpr:getContentSize().height*0.6458))
                        ludanSpr:setAnchorPoint(cc.p(0, 0))
                        self.m_pScrollDalutu:addChild(ludanSpr)
                        table.insert(self.m_vecDalutu, ludanSpr)
                    end
                end
                self.m_pScrollDalutu:setInnerContainerSize(cc.size(math.floor(self.m_vecDalutu[curIndex]:getContentSize().width*0.6458*self.m_DalutuMaxLie), 186))
                self.m_pScrollDalutu:jumpToRight()
                if rec.m_cbGameResult == g_var(cmd).AREA_PING then
                    self.m_vecDalutu[curIndex+gapIndex]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, saveCheck)
                else
                    self.m_vecDalutu[curIndex+gapIndex]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, rec.m_cbGameResult)
                end
                if self.m_DalutuLie < 20 then
                    self.m_DalutuLie = self.m_DalutuLie + 1
                end
                for i = 1, #self.m_vecDalutu do -- 行 刷新列表
                    self.m_vecDalutu[i]:setPosition(cc.p(math.floor((i-1)/6)*self.m_vecDalutu[i]:getContentSize().width*0.6458, 186-((i-1)%6+1)*self.m_vecDalutu[i]:getContentSize().height*0.6458))
                end
            else
                if rec.m_cbGameResult == g_var(cmd).AREA_PING then
                    self.m_vecDalutu[curIndex+1]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, self.m_vecDalutu[curIndex]:getCheck()) -- 在下一行添加
                else
                    self.m_vecDalutu[curIndex+1]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, rec.m_cbGameResult) -- 在下一行添加
                end
                if self.m_DalutuHang < 6 then
                    self.m_DalutuHang = self.m_DalutuHang + 1
                end
            end
        else
            --新开一列
            local gapIndex = 6
            local saveCheck = self.m_vecDalutu[curIndex]:getCheck()
            if self.m_DalutuSaveLie >= self.m_DalutuMaxLie then     -- 是否大于当前列表宽度
                if self.m_DalutuMaxLie < 20 then                -- 当前列表宽度是否大于最大宽度 20
                    self.m_DalutuMaxLie = self.m_DalutuMaxLie + 1
                else                                            -- 大于20的话删除第一列
                    gapIndex = 0
                    for i = 6, 1, -1 do -- 行
                        self.m_vecDalutu[i]:removeFromParent()
                        table.remove(self.m_vecDalutu, i)
                    end
                    self.m_DalutuSaveLie = self.m_DalutuSaveLie - 1
                end
                local ludanSpr
                local index
                for j = 1, 6 do -- 行
                    index = ((self.m_DalutuBlackGrayLie+1)%2+self.m_DalutuBlackGrayHang)%2
                    if self.m_DalutuBlackGrayHang < 5 then
                        self.m_DalutuBlackGrayHang = self.m_DalutuBlackGrayHang + 1
                    else
                        self.m_DalutuBlackGrayHang = 0
                        self.m_DalutuBlackGrayLie = self.m_DalutuBlackGrayLie + 1
                    end
                        
                    ludanSpr = g_var(LudanPoint):create(index, 0.6458)
                    ludanSpr:setPosition(cc.p((self.m_DalutuMaxLie-1)*ludanSpr:getContentSize().width*0.6458, 186-j*ludanSpr:getContentSize().height*0.6458))
                    ludanSpr:setAnchorPoint(cc.p(0, 0))
                    self.m_pScrollDalutu:addChild(ludanSpr)
                    table.insert(self.m_vecDalutu, ludanSpr)
                end
            end
            self.m_pScrollDalutu:setInnerContainerSize(cc.size(math.floor(self.m_vecDalutu[curIndex]:getContentSize().width*0.6458*self.m_DalutuMaxLie), 186))
                self.m_pScrollDalutu:jumpToRight()
            if rec.m_cbGameResult == g_var(cmd).AREA_PING then
                self.m_vecDalutu[self.m_DalutuSaveLie*6+1]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, saveCheck)
            else
                self.m_vecDalutu[self.m_DalutuSaveLie*6+1]:addWinner(rec.m_cbGameResult, g_var(cmd).AREA_MAX, rec.m_cbGameResult)
            end
            self.m_DalutuSaveLie = self.m_DalutuSaveLie + 1
            self.m_DalutuLie = self.m_DalutuSaveLie
            self.m_DalutuHang = 1
            for i = 1, #self.m_vecDalutu do -- 行 刷新列表
                self.m_vecDalutu[i]:setPosition(cc.p(math.floor((i-1)/6)*self.m_vecDalutu[i]:getContentSize().width*0.6458, 186-((i-1)%6+1)*self.m_vecDalutu[i]:getContentSize().height*0.6458))
            end 
        end
    end
    -----------------------------珠盘路----------------------------------
    if #self.m_vecZhupanluData == 36 then
        table.remove(self.m_vecZhupanluData, 1)
    end
    
    table.insert(self.m_vecZhupanluData, rec)
    
    for i = 1, #self.m_vecZhupanluData do
        self.m_vecZhupanlu[i]:addWinner(self.m_vecZhupanluData[i].m_cbGameResult, self.m_vecZhupanluData[i].cbKingWinner, self.m_vecZhupanluData[i].m_cbGameResult)
    end
    
    -----------------------------输赢表----------------------------------
    if #self.m_vecWinloseData == 12 then
        table.remove(self.m_vecWinloseData, 1)
    end

    table.insert(self.m_vecWinloseData, rec)
    
    for i = 1, #self.m_vecWinlose do
        self.m_vecWinlose[i]:addWinType(false)
    end

    local hang = 0
    local zhuangCount = 0
    local xianCount = 0
    local pingCount = 0
    for i = 1, #self.m_vecWinloseData do
        if self.m_vecWinloseData[i].m_cbGameResult == g_var(cmd).AREA_ZHUANG then
            hang = (i-1)*3+1
            zhuangCount = zhuangCount + 1
        elseif self.m_vecWinloseData[i].m_cbGameResult == g_var(cmd).AREA_XIAN then
            hang = (i-1)*3+2
            xianCount = xianCount + 1
        elseif self.m_vecWinloseData[i].m_cbGameResult == g_var(cmd).AREA_PING then
            hang = (i-1)*3+3
            pingCount = pingCount + 1
        end

        if hang > 0 then
            self.m_vecWinlose[hang]:addWinType(true)
        end
    end
    self.m_pTextWinloseZhuang:setString(string.format("%d", zhuangCount))
    self.m_pTextWinloseXian:setString(string.format("%d", xianCount))
    self.m_pTextWinlosePing:setString(string.format("%d", pingCount))
    
end

--座位坐下信息
function GameViewLayer:onGetSitDownInfo( config, info )
	self.m_tabSitDownConfig = config
	
	local pos = cc.p(0,0)
	--获取已占位信息
	for i = 1, g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		print("sit chair " .. info[i])
		self:onGetSitDown(i - 1, info[i], false)
	end
end

--座位坐下
function GameViewLayer:onGetSitDown( index, wchair, bAni )
	if wchair ~= nil 
		and nil ~= index
		and index ~= g_var(cmd).SEAT_INVALID_INDEX 
		and wchair ~= yl.INVALID_CHAIR then
		local useritem = self:getDataMgr():getChairUserList()[wchair + 1]

		if nil ~= useritem then
			--下标加1
			index = index + 1
			if nil == self.m_tabSitDownUser[index] then
				self.m_tabSitDownUser[index] = g_var(SitRoleNode):create(self, index)
				self.m_tabSitDownUser[index]:setPosition(self.m_tabSitDownList[index]:getPosition())
				self.m_roleSitDownLayer:addChild(self.m_tabSitDownUser[index])
			end
			self.m_tabSitDownUser[index]:onSitDown(useritem, bAni, wchair == self.m_wBankerUser)

			if useritem.dwUserID == GlobalUserItem.dwUserID then
				self.m_nSelfSitIdx = index
			end
		end
	end
end

--座位失败/离开
function GameViewLayer:onGetSitDownLeave( index )
	if index ~= g_var(cmd).SEAT_INVALID_INDEX 
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
    if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankSuccess()
	end
end

--银行操作失败
function GameViewLayer:onBankFailure( )
   if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankFailure()
	end
end

function GameViewLayer:onGetBankInfo(bankinfo)
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onGetBankInfo(bankinfo)
	end
end
------
---------------------------------------------------------------------------------------

function GameViewLayer:addToRootLayer( node , zorder)
	if nil == node then
		return
	end

	self.m_rootLayer:addChild(node)
	node:setLocalZOrder(zorder)
end

--下注区域闪烁--will
--[[function GameViewLayer:showBetAreaBlink(  )
	local blinkArea = self:getDataMgr().m_tabBetArea
	self:jettonAreaBlink(blinkArea)
end]]--

function GameViewLayer:randomSetJettonPos( nodeArea, jettonSp )
	if nil == jettonSp then
		return
	end

	local pos = self:getBetRandomPos(nodeArea)
	jettonSp:setPosition(cc.p(pos.x, pos.y))
end
------------------------------------------------------   设置函数   ------------------------------------------------------

function GameViewLayer:setBankerScore(lBankerScore)
    self.m_pTextBankerScore:setString(ExternalFun.formatScoreText(lBankerScore))
    if yl.INVALID_CHAIR == self.m_wBankerUser then
        self.m_pTextBankerScore:setString("")
    end
end

function GameViewLayer:setBtnBankerType(tag)
    self.m_pBtnApplyBanker:setVisible(tag == APPLY_STATE.kCancelState)
    self.m_pBtnCancelApply:setVisible(tag == APPLY_STATE.kApplyState)
    self.m_pBtnCancelBanker:setVisible(tag == APPLY_STATE.kApplyedState)
end

------------------------------------------------------   获取函数   ------------------------------------------------------
function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function GameViewLayer:getParentNode( )
	return self._scene
end

function GameViewLayer:getMeUserItem()
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID]
	end
	return nil
end

function GameViewLayer:getApplyState(  )
	return self.m_enApplyState
end

function GameViewLayer:getApplyCondition(  )
	return self.m_llCondition
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
	--自己超级抢庄已申请，则不可进行普通申请
	if APPLY_STATE.kSupperApplyed == self.m_enApplyState then
		return false
	end

	local userItem = self:getMeUserItem()
	if nil ~= userItem then
		return userItem.lScore > self.m_llCondition
	else
		return false
	end
end

--获取能否取消上庄
function GameViewLayer:getCancelable(  )
	return self.m_cbGameStatus == g_var(cmd).GAME_SCENE_FREE
end

function GameViewLayer:getJettonIdx( llScore )
	local idx = 2
	for i=1,#self.m_pJettonNumber do
		if llScore == self.m_pJettonNumber[i].k then
			idx = self.m_pJettonNumber[i].i
			break
		end
	end
	return idx
end

function GameViewLayer:getBetFromPos( wchair )
	if nil == wchair then
		return {x = 0, y = 0}
	end
	local winSize = cc.Director:getInstance():getWinSize()

	--是否是自己
	if self:isMeChair(wchair) then
        return {x = winSize.width/2, y = 0}
	end

	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	if nil == useritem then
		return {x = winSize.width, y = 0}
	end

	--是否是坐下列表
	local idx = nil
	for i = 1,g_var(cmd).MAX_OCCUPY_SEAT_COUNT do
		if (nil ~= self.m_tabSitDownUser[i]) and (wchair == self.m_tabSitDownUser[i]:getChair()) then
			idx = i
			break
		end
	end
	if nil ~= idx then
		local pos = cc.p(self.m_tabSitDownUser[idx]:getPositionX(), self.m_tabSitDownUser[idx]:getPositionY())
		pos = self.m_roleSitDownLayer:convertToWorldSpace(pos)
		return {x = pos.x, y = pos.y}
	end

	--默认位置
	return {x = winSize.width, y = 0}
end

function GameViewLayer:getBetAnimation( pos, call_back )
	local moveTo = cc.MoveTo:create(BET_ANITIME, cc.p(pos.x, pos.y))
	if nil ~= call_back then
		return cc.Sequence:create(cc.EaseIn:create(moveTo, 2), call_back)
	else
		return cc.EaseIn:create(moveTo, 2)
	end
end

function GameViewLayer:getBetRandomPos(nodeArea)
	if nil == nodeArea then
		return {x = 0, y = 0}
	end
    
	local areaX = 0         -- x轴范围
	local areaY = 0         -- y轴范围
    local startX = 0        -- x轴起点
    local startY = 0        -- y轴起点
    local betRadius = 22    -- 筹码半径
    local btn = self.m_tableJettonArea[nodeArea]
    if  nodeArea-1 == g_var(cmd).AREA_XIAN then
        startX = 174
        startY = 333
        areaX = 330 - betRadius
        areaY = 106 - betRadius
    elseif  nodeArea-1 == g_var(cmd).AREA_PING then
        startX = 513
        startY = 333
        areaX = 294 - betRadius
        areaY = 106 - betRadius
    elseif nodeArea-1 == g_var(cmd).AREA_ZHUANG then
        startX = 816
        startY = 333
        areaX = 331 - betRadius
        areaY = 106 - betRadius
    elseif  nodeArea-1 == g_var(cmd).AREA_XIAN_TIAN then
        startX = 285
        startY = 214
        areaX = 219 - betRadius
        areaY = 110 - betRadius
    elseif  nodeArea-1 == g_var(cmd).AREA_ZHUANG_TIAN then
        startX = 817
        startY = 214
        areaX = 219 - betRadius
        areaY = 110 - betRadius
    elseif  nodeArea-1 == g_var(cmd).AREA_TONG_DUI then
        startX = 513
        startY = 214
        areaX = 294 - betRadius
        areaY = 110 - betRadius
    elseif  nodeArea-1 == g_var(cmd).AREA_XIAN_DUI then
        startX = 200
        startY = 448
        areaX = 304 - betRadius
        areaY = 99 - betRadius
    elseif  nodeArea-1 == g_var(cmd).AREA_ZHUANG_DUI then
        startX = 816
        startY = 448
        areaX = 304 - betRadius
        areaY = 99 - betRadius
    end
    local posX = startX + math.random(betRadius, areaX)
    local posY = startY + math.random(betRadius, areaY)
	return cc.p(posX, posY)
end

function GameViewLayer:getDataMgr( )
	return self:getParentNode():getDataMgr()
end

------------------------------------------------------   系统函数   ------------------------------------------------------
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

function GameViewLayer:gameDataReset(  )
	--资源释放
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/game.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/game.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/pk_card.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/pk_card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("bank/bank.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("bank/bank.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("public_res/public_res.png")

	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("setting/setting.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("setting/setting.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()


	--播放大厅背景音乐
	ExternalFun.playPlazzBackgroudAudio()
    self.m_pNodeCardLayer:removeAllChildren()

	yl.m_bDynamicJoin = false
	self:getDataMgr():removeAllUser()
	self:getDataMgr():clearRecord()
end

function GameViewLayer:updateClock(tag, left)
	self.m_pClock:setVisible(left > -1)

	local str = string.format("%02d", left)
	self.m_pClock.m_atlasTimer:setString(str)

    self.m_pClock.m_atlasTimer1:setString(str)
    self.m_pClock.m_atlasTimer1:setVisible(true)
    self.m_pClock.m_atlasTimer1:setScale(1)
    self.m_pClock.m_atlasTimer1:setOpacity(255)
    self.m_pClock.m_atlasTimer1:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeOut:create(0.5)))

    if left <= 5 and left ~= 0 then
        ExternalFun.playSoundEffect("baccaratnew_clock.mp3")
    end
end

function GameViewLayer:showTimerTip(tag)
	tag = tag or -1
	local call = cc.CallFunc:create(function()
		local str = "baccaratnew_icon_game_statusfree.png"
        if tag == 2 then
            str = "baccaratnew_icon_game_statuschip.png"
        elseif tag == 3 then
            str = "baccaratnew_icon_game_statusshow.png"
        end
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)

		self.m_pClock.m_spTip:setVisible(false)
		if nil ~= frame then
			self.m_pClock.m_spTip:setVisible(true)
			self.m_pClock.m_spTip:setSpriteFrame(frame)
		end
	end)

	local scale = cc.ScaleTo:create(0.2, 0.0001, 1.0)
	local scaleBack = cc.ScaleTo:create(0.2, 1.0)
	local seq = cc.Sequence:create(scale, call, scaleBack)

	self.m_pClock.m_spTip:stopAllActions()
	self.m_pClock.m_spTip:runAction(seq)
end

------------------------------------------------------  计算可下注  ------------------------------------------------------

function GameViewLayer:GetMaxPlayerScore(cbBetArea)
	local userItem = self:getMeUserItem()

	if userItem == nil or cbBetArea >= g_var(cmd).AREA_MAX then
		return 0
    end
    
	-- 已下注额
	local lNowBet = 0
	for nAreaIndex = 1, g_var(cmd).AREA_MAX do
		lNowBet = lNowBet + self.m_pNodeChipScorePlayer[nAreaIndex].m_llScore
    end
	-- 庄家金币
	local lBankerScore = self.m_lBankerScore

	-- 区域倍率
	local cbMultiple = {g_var(cmd).MULTIPLE_XIAN, 
                        g_var(cmd).MULTIPLE_PING, 
                        g_var(cmd).MULTIPLE_ZHUANG, 
                        g_var(cmd).MULTIPLE_XIAN_TIAN, 
                        g_var(cmd).MULTIPLE_ZHUANG_TIAN, 
                        g_var(cmd).MULTIPLE_TONG_DIAN, 
                        g_var(cmd).MULTIPLE_XIAN_PING, 
                        g_var(cmd).MULTIPLE_ZHUANG_PING}

	-- 区域输赢
	local cbArae = {{g_var(cmd).AREA_XIAN_DUI,	    255,                        g_var(cmd).AREA_MAX,			g_var(cmd).AREA_MAX}, 
                    {g_var(cmd).AREA_ZHUANG_DUI,    255,                        g_var(cmd).AREA_MAX,			g_var(cmd).AREA_MAX}, 
                    {g_var(cmd).AREA_XIAN,          g_var(cmd).AREA_PING,		g_var(cmd).AREA_ZHUANG,         g_var(cmd).AREA_MAX},  
                    {g_var(cmd).AREA_XIAN_TIAN,	    g_var(cmd).AREA_TONG_DUI,	g_var(cmd).AREA_ZHUANG_TIAN,	255 }}
	-- 筹码设定
	for nTopL = 1, 4 do
		if cbArae[1][nTopL] ~= g_var(cmd).AREA_MAX then
			for nTopR = 1, 4 do
                if cbArae[2][nTopR] ~= g_var(cmd).AREA_MAX then
                    for nCentral = 1, 4 do
                        if cbArae[3][nCentral] ~= g_var(cmd).AREA_MAX then
                            for nBottom = 1, 4 do
                                if cbArae[4][nBottom] ~= g_var(cmd).AREA_MAX then
                                    local cbWinArea = {false, false, false, false, false, false, false, false}

                                    -- 指定获胜区域
					                if cbArae[1][nTopL] ~= 255 then
						                cbWinArea[cbArae[1][nTopL]+1] = true
                                    end
					                if cbArae[2][nTopR] ~= 255 then
						                cbWinArea[cbArae[2][nTopR]+1] = true
                                    end

					                if cbArae[3][nCentral] ~= 255 then
						                cbWinArea[cbArae[3][nCentral]+1] = true
                                    end

					                if cbArae[4][nBottom] ~= 255 then
						                cbWinArea[cbArae[4][nBottom]+1] = true
                                    end

					                -- 选择区域为玩家胜利，同等级的其他的区域为玩家输。以得出最大下注值
					                for i = 1, 4 do
					                    for j = 1, 4 do
							                if cbArae[i][j] == cbBetArea then
					                            for n = 1, 4 do
									                if cbArae[i][n] ~= 255 and cbArae[i][n] ~= g_var(cmd).AREA_MAX then
										                cbWinArea[cbArae[i][n]+1] = false
                                                    end
                                                end
                                                cbWinArea[cbArae[i][j]+1] = true
                                            end
                                        end
                                    end

					                local lScore = self.m_lBankerScore
					                for nAreaIndex = 1, g_var(cmd).AREA_MAX do
						                if cbWinArea[nAreaIndex] == true then
							                lScore = lScore - self.m_pNodeChipScoreAll[nAreaIndex].m_llScore*(cbMultiple[nAreaIndex] - 1)
						                elseif cbWinArea[g_var(cmd).AREA_PING+1] == true and (nAreaIndex == g_var(cmd).AREA_XIAN or nAreaIndex == g_var(cmd).AREA_ZHUANG) then
						                else
                                            lScore = lScore + self.m_pNodeChipScoreAll[nAreaIndex].m_llScore
						                end
					                end
					                if lBankerScore == -1 then
                                        lBankerScore = lScore
					                else
						                lBankerScore = math.min(lBankerScore, lScore)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

	-- 最大下注
	local lMaxBet = 0

    -- 最大下注
	lMaxBet = math.min(userItem.lScore - lNowBet, self.m_llAreaLimitScore - self.m_pNodeChipScorePlayer[cbBetArea+1].m_llScore)

	lMaxBet = math.min(lMaxBet, self.m_llAreaLimitScore - self.m_pNodeChipScoreAll[cbBetArea+1].m_llScore)

	lMaxBet = math.min(lMaxBet, lBankerScore / (cbMultiple[cbBetArea+1] - 1))
	-- 非零限制
	lMaxBet = math.max(lMaxBet, 0)
    
	if     cbBetArea == g_var(cmd).AREA_XIAN 
    and 0       < (self.m_pNodeChipScoreAll[g_var(cmd).AREA_ZHUANG + 1].m_llScore - self.m_pNodeChipScoreAll[g_var(cmd).AREA_XIAN + 1].m_llScore) 
    and lMaxBet < (self.m_pNodeChipScoreAll[g_var(cmd).AREA_ZHUANG + 1].m_llScore - self.m_pNodeChipScoreAll[g_var(cmd).AREA_XIAN + 1].m_llScore) then
		lMaxBet =  self.m_pNodeChipScoreAll[g_var(cmd).AREA_ZHUANG + 1].m_llScore - self.m_pNodeChipScoreAll[g_var(cmd).AREA_XIAN + 1].m_llScore
	elseif cbBetArea == g_var(cmd).AREA_ZHUANG 
    and 0       < (self.m_pNodeChipScoreAll[g_var(cmd).AREA_XIAN + 1].m_llScore - self.m_pNodeChipScoreAll[g_var(cmd).AREA_ZHUANG + 1].m_llScore) 
    and lMaxBet < (self.m_pNodeChipScoreAll[g_var(cmd).AREA_XIAN + 1].m_llScore - self.m_pNodeChipScoreAll[g_var(cmd).AREA_ZHUANG + 1].m_llScore) then
		lMaxBet =  self.m_pNodeChipScoreAll[g_var(cmd).AREA_XIAN + 1].m_llScore - self.m_pNodeChipScoreAll[g_var(cmd).AREA_ZHUANG + 1].m_llScore
    end

	return lMaxBet
end

function GameViewLayer:updateCanChip()
    local lScore = self:GetMaxPlayerScore(g_var(cmd).AREA_ZHUANG)
    self.m_pTextCanChipZhuang:setString(string.format("%d",lScore))
    lScore = self:GetMaxPlayerScore(g_var(cmd).AREA_XIAN)
    self.m_pTextCanChipXian:setString(string.format("%d",lScore))
    lScore = self:GetMaxPlayerScore(g_var(cmd).AREA_PING)
    self.m_pTextCanChipPing:setString(string.format("%d",lScore))
end
----------------------------------------------------  超级抢庄  ----------------------------------------------------
--超级抢庄申请
function GameViewLayer:onGetSupperRobApply(  )
	if yl.INVALID_CHAIR ~= self.m_wCurrentRobApply then
		self.m_bSupperRobApplyed = true
	end
	--如果是自己
	if true == self:isMeChair(self.m_wCurrentRobApply) then
		--普通上庄申请不可用
		self.m_enApplyState = APPLY_STATE.kSupperApplyed
	end
end

--超级抢庄用户离开
function GameViewLayer:onGetSupperRobLeave( wLeave )
	if yl.INVALID_CHAIR == self.m_wCurrentRobApply then
		self.m_bSupperRobApplyed = false    -- 普通上庄申请不可用
	end
end

----------------------------------------------------  点击事件  ----------------------------------------------------

function GameViewLayer:onTouchBegan(touch, event)
    local pos = touch:getLocation()
    if self.m_pNodeMenu:getScaleX() == 1 then
        if cc.rectContainsPoint(self.m_pNodeMenu:getBoundingBox(), pos) == false then
            self.m_pNodeMenu:stopAllActions()
            self.m_pNodeMenu:runAction(cc.ScaleTo:create(0.2, 0))
        end
    end
    return true
end

function GameViewLayer:onTouchMoved(touch, event)
    local pos = touch:getLocation()
end

function GameViewLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation()
end

return GameViewLayer