local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.yaoyaole.src"
GameViewLayer.RES_PATH = "game/yule/yaoyaole/res/"

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
local BankLayer = appdf.req(appdf.GAME_SRC .. "yule.yaoyaole.src.views.layer.BankLayer")
--

local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local QueryDialog   = require("app.views.layer.other.QueryDialog")


local UserListLayer = module_pre .. ".views.layer.userlist.UserListLayer"
local ApplyListLayer = module_pre .. ".views.layer.userlist.ApplyListLayer"
local BtnListLayer = module_pre .. ".views.layer.BtnListLayer"
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.yaoyaole.src.views.layer.GameSetLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.TAG_START				= 100
local enumTable = 
{
	"BT_EXIT",
	"BT_LUDAN",
	"BT_BANK",
	"BT_SET",
	"BT_RULE",
	"BT_ROBBANKER",
	"BT_APPLYBANKER",
	"BT_USERLIST",
    "BT_APPLY",
	"BT_APPLYLIST",
	"BANK_LAYER",
	"BT_MENU",
    "BT_CLOSEEND",
    "BT_CLEARCHIP",
    "BT_CHAT"
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enumTable);
local zorders = 
{
	"CLOCK_ZORDER",
	"SITDOWN_ZORDER",
	"DROPDOWN_ZORDER",
	"DROPDOWN_CHECK_ZORDER",
	"GAMECARD_ZORDER",
	"SETTING_ZORDER",
	"ROLEINFO_ZORDER",
	"RULE_ZORDER",
	"BANK_ZORDER",
	"USERLIST_ZORDER",
	"WALLBILL_ZORDER",
	"BTNLISTLAYER_ZORDER",

	"GAMERS_ZORDER",	
	"ENDCLOCK_ZORDER",
	"HELP_ZORDER"
}
local TAG_ZORDER = ExternalFun.declarEnumWithTable(1, zorders);

local enumApply =
{
	"kCancelState",
	"kApplyState",
	"kApplyedState",
	"kSupperApplyed"
}
GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state

--默认选中的筹码
local DEFAULT_BET = 1
--筹码运行时间
local BET_ANITIME = 0.2

GameViewLayer.BANKERFACE 					= 1
local ptJetton = {
   [1] = {cc.p(1030,580),cc.p(1050,456),cc.p(1275,456),cc.p(1182,537)},
   [2] = {cc.p(150,537),cc.p(60,456),cc.p(275,456),cc.p(290,580)},
   [9] = {cc.p(290,545),cc.p(280,460),cc.p(375,460),cc.p(385,545)},
   [10] = {cc.p(386,545),cc.p(378,460),cc.p(473,460),cc.p(480,545)},
   [11] = {cc.p(480,545),cc.p(478,460),cc.p(573,460),cc.p(575,545)},
   [12] = {cc.p(750,545),cc.p(752,460),cc.p(847,460),cc.p(840,545)},
   [13] = {cc.p(845,545),cc.p(850,460),cc.p(945,460),cc.p(935,545)},
   [14] = {cc.p(940,545),cc.p(950,460),cc.p(1045,460),cc.p(1035,545)},      
   [15] = {cc.p(577,545),cc.p(577,460),cc.p(747,460),cc.p(747,545)},
   [16] = {cc.p(55,455),cc.p(17,275),cc.p(90,275),cc.p(125,455)},
   [17] = {cc.p(130,455),cc.p(95,275),cc.p(185,275),cc.p(215,455)},
   [18] = {cc.p(220,455),cc.p(190,275),cc.p(280,275),cc.p(305,455)},
   [19] = {cc.p(308,455),cc.p(285,275),cc.p(375,275),cc.p(393,455)},
   [20] = {cc.p(398,455),cc.p(380,275),cc.p(470,275),cc.p(483,455)},
   [21] = {cc.p(486,455),cc.p(474,275),cc.p(567,275),cc.p(573,455)},
   [22] = {cc.p(575,455),cc.p(570,275),cc.p(660,275),cc.p(660,455)},
   [23] = {cc.p(663,455),cc.p(663,275),cc.p(755,275),cc.p(750,455)},
   [24] = {cc.p(753,455),cc.p(758,275),cc.p(850,275),cc.p(840,455)},
   [25] = {cc.p(843,455),cc.p(853,275),cc.p(943,275),cc.p(928,455)},
   [26] = {cc.p(931,455),cc.p(950,275),cc.p(1038,275),cc.p(1017,455)},
   [27] = {cc.p(1020,455),cc.p(1042,275),cc.p(1133,275),cc.p(1105,455)},
   [28] = {cc.p(1107,455),cc.p(1136,275),cc.p(1228,275),cc.p(1195,455)},
   [29] = {cc.p(1197,455),cc.p(1232,275),cc.p(1317,275),cc.p(1277,455)},
   [45] = {cc.p(17,275),cc.p(88,180),cc.p(245,180),cc.p(257,275)},
   [46] = {cc.p(260,275),cc.p(247,180),cc.p(453,180),cc.p(458,275)},
   [47] = {cc.p(462,275),cc.p(453,180),cc.p(660,180),cc.p(660,275)},
   [48] = {cc.p(663,275),cc.p(663,180),cc.p(868,180),cc.p(863,275)},
   [49] = {cc.p(865,275),cc.p(870,180),cc.p(1075,180),cc.p(1064,275)},
   [50] = {cc.p(1066,275),cc.p(1077,180),cc.p(1248,180),cc.p(1317,275)},
}
function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit();
	--初始化csb界面
	self:initCsbRes();
	--初始化通用动作
	self:initAction();
end

function GameViewLayer:loadRes(  )
	--加载plist	
	cc.SpriteFrameCache:getInstance():addSpriteFrames(GameViewLayer.RES_PATH.."game/yaoyaole_gameLayer.plist")

end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes(  )
    self.addX = 0 
    if yl.WIDTH > yl.DESIGN_WIDTH then 
        self.addX = (yl.WIDTH - yl.DESIGN_WIDTH)/2
    end
	local rootLayer, csbNode = ExternalFun.loadRootCSB(GameViewLayer.RES_PATH .. "yyl_gameLayer.csb", self);
	self.m_rootLayer = rootLayer
	self._csbNode = csbNode


	--摇骰子的节点
	self.m_nodeDiceBg = self._csbNode:getChildByName("Node_dice")
    self.m_nodeDiceBg:setVisible(false)
    --空闲时骰子背景
    self.m_FreeDiceBg = self._csbNode:getChildByName("Sprite_dice")
    self.m_FreeDiceBg:setVisible(true)
    --骰子动画
    self.m_AniDice = self._csbNode:getChildByName("Sprite_diceAni")
    self.m_AniDice:setVisible(false)
    --骰子动画完成Node
    self.m_NodeDiceAni= self._csbNode:getChildByName("Node_diceAni")
    self.m_NodeDiceAni:setVisible(false)

	--轮庄tip
	self.m_nodeBankerTip = self._csbNode:getChildByName("Node_bankertips")
    --轮庄tip
	self.m_nodeStateTip = self._csbNode:getChildByName("Node_statetips")
	--初始化按钮
	self:initBtn(csbNode);

	--初始化庄家信息
	self:initBankerInfo();

	--初始化玩家信息
	self:initUserInfo(csbNode);
    

	--初始化桌面下注
	self:initJetton(csbNode);
    
	--刷新上庄列表
	self:refreshAppLyInfo()

    --倒计时
	self:createClockNode(csbNode)
end

function GameViewLayer:reSet(  )

end

function GameViewLayer:reSetForNewGame(  )
	--重置下注区域
	self:cleanJettonArea()
	--闪烁停止
	self:jettonAreaBlinkClean()

	self:showGameResult(false)
end

--初始化按钮
function GameViewLayer:initBtn( csbNode )
	------

	------
	--按钮列表
	local function btnEvent( sender, eventType )
        ExternalFun.btnEffect(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect("yaoyaole_click.mp3")
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end

	-- local btn_list = csbNode:getChildByName("Sprite_ListBtn");
	-- self.m_btnList = btn_list;
	-- btn_list:setScaleY(0.0000001)
	-- btn_list:setLocalZOrder(TAG_ZORDER.DROPDOWN_ZORDER)

	--self.m_btnList = btn_list;
	--btn_list:setLocalZOrder(TAG_ZORDER.DROPDOWN_ZORDER)

	-- --离开
	-- local btn = self.m_btnListLayer.m_spBg:getChildByName("Button_back");
	-- btn:setTag(TAG_ENUM.BT_EXIT);
	-- btn:addTouchEventListener(btnEvent);

	-- --规则
	-- btn = self.m_btnListLayer.m_spBg:getChildByName("Button_rule");
	-- btn:setTag(TAG_ENUM.BT_RULE);
	-- btn:addTouchEventListener(btnEvent);

	-- --银行
	-- btn = self.m_btnListLayer.m_spBg:getChildByName("Button_bank");
	-- btn:setTag(TAG_ENUM.BT_BANK);
	-- btn:addTouchEventListener(btnEvent);

	-- --玩家列表
	-- btn = self.m_btnListLayer.m_spBg:getChildByName("Button_playList");
	-- btn:setTag(TAG_ENUM.BT_USERLIST);
	-- btn:addTouchEventListener(btnEvent);

	--菜单
	self.m_BtnMenu = csbNode:getChildByName("Button_menu");
	self.m_BtnMenu:addTouchEventListener(btnEvent);
	self.m_BtnMenu:setTag(TAG_ENUM.BT_MENU);
    --路单
	self.m_BtnLudan = csbNode:getChildByName("Button_ludan");
	self.m_BtnLudan:addTouchEventListener(btnEvent);
	self.m_BtnLudan:setTag(TAG_ENUM.BT_LUDAN);

	--上庄、抢庄
	local banker_bg = csbNode:getChildByName("Node_zhuangjiaInfo");
	self.m_NodeBankerBg = banker_bg;

	--上庄按钮
	btn = csbNode:getChildByName("Button_shangzhuang");
	btn:setTag(TAG_ENUM.BT_APPLY);
	btn:addTouchEventListener(btnEvent);	
	self.m_btnApply = btn;
    ExternalFun.enableBtn(self.m_btnApply, false)

    --上庄列表
    self.m_ApplyList = csbNode:getChildByName("Node_shangzhuang");
    self.m_ApplyList:setContentSize(222,50);
    --上庄列表下拉按钮
    self.m_btnApplyList = csbNode:getChildByName("Button_CbList");
    self.m_btnApplyList:setTag(TAG_ENUM.BT_APPLYLIST);
    self.m_btnApplyList:addTouchEventListener(btnEvent);

    self.bShowApply = false;

	--玩家列表
	 self.m_btnPlayerList = csbNode:getChildByName("Button_playerlist");
	 self.m_btnPlayerList:setTag(TAG_ENUM.BT_USERLIST);
	 self.m_btnPlayerList:addTouchEventListener(btnEvent);
     self.m_btnPlayerList:setVisible(false)

	--聊天界面
    local btnChat = csbNode:getChildByName("Button_chat");
    btnChat:setTag(TAG_ENUM.BT_CHAT);
    btnChat:addTouchEventListener(btnEvent);

    --清空下注
    self.m_btnClearChip = csbNode:getChildByName("Button_clearChip");
	self.m_btnClearChip:setTag(TAG_ENUM.BT_CLEARCHIP);
    self.m_btnClearChip:setVisible(false)
	self.m_btnClearChip:addTouchEventListener(btnEvent);

	--路单 Node_ludan1
	self.nodeLudan1 = csbNode:getChildByName("Node_ludan1");
    self.nodeLudan1:setScale(0)
    self.showLudan = false
	--btn = nodeLudan1:getChildByName("ludan_btn");
	--btn:setTag(TAG_ENUM.BT_LUDAN);
	--btn:addTouchEventListener(btnEvent);

--	local nodeLudan2 = csbNode:getChildByName("Node_ludan2");
--	btn = nodeLudan2:getChildByName("ludan_btn");
--	btn:setTag(TAG_ENUM.BT_LUDAN);
--	btn:addTouchEventListener(btnEvent);

    --结算界面
    local nodeJiesuan = csbNode:getChildByName("Sprite_resultBg")
    local btn = nodeJiesuan:getChildByName("Botton_close")
    btn:setTag(TAG_ENUM.BT_CLOSEEND);
	btn:addTouchEventListener(btnEvent);
end

--初始化庄家信息
function GameViewLayer:initBankerInfo( ... )
	local banker_bg = self.m_NodeBankerBg;
	--庄家姓名
    self.m_clipBankerNick = banker_bg:getChildByName("Text_name")
    self.m_clipBankerNick:setFontName("fonts/round_body.ttf")

    --庄家头像
    self.m_spBankerHead = banker_bg:getChildByName("m_pIconHead")

	--庄家金币
	self.m_textBankerCoin = banker_bg:getChildByName("Text_score")
    self.m_textBankerCoin:setFontName("fonts/round_body.ttf")
	--庄家局数    
    self.m_spBankerRound = banker_bg:getChildByName("sp_round")
	self.m_textBankerRound = self.m_spBankerRound:getChildByName("Text_round")
    self.m_textBankerRound:setFontName("fonts/round_body.ttf")
	--庄家成绩 
	self.m_textBankerChengJi = banker_bg:getChildByName("Text_chengji")
    self.m_textBankerChengJi:setFontName("fonts/round_body.ttf")
end

--初始化玩家信息
function GameViewLayer:initUserInfo( csbNode )
    local PlayerNode = csbNode:getChildByName("Node_Player")
    local userItem = self:getMeUserItem()

	--玩家头像
    local csbHead = PlayerNode:getChildByName("m_pIconHead")     -- 头像处理
    local csbHeadX, csbHeadY = csbHead:getPosition()
    head = g_var(PopupInfoHead):createNormal(userItem, 90)
    head:setPosition(cc.p(csbHeadX, csbHeadY))   
    local headBg = display.newSprite("#userinfo_head_frame.png")
    headBg:setPosition(cc.p(csbHeadX, csbHeadY))
    headBg:setScale(0.55,0.55)
    PlayerNode:addChild(headBg)
	PlayerNode:addChild(head)
    self.m_MeCj = 0
    --玩家名称
    self.m_textUserName = PlayerNode:getChildByName("text_name")
    self.m_textUserName:setFontName("fonts/round_body.ttf")
    self.m_textUserName:setString(userItem.szNickName)   
	--玩家金币
	self.m_textUserCoin = PlayerNode:getChildByName("text_goldnum")
    self.m_textUserCoin:setFontName("fonts/round_body.ttf")
    --玩家成绩
    self.m_textCj = PlayerNode:getChildByName("text_score")
    self.m_textCj:setFontName("fonts/round_body.ttf")
    self.m_IsChip = false
	self:reSetUserInfo()
end

function GameViewLayer:reSetUserInfo()    
	--自己金币
	local lUserCoin = ExternalFun.formatScoreText(self:getMeUserItem().lScore - self.m_lHaveJetton);
	self.m_textUserCoin:setString(lUserCoin);

    --自己的成绩
    local lUserCj = ExternalFun.formatScoreText(self.m_MeCj);
    self.m_textCj:setString(lUserCj);
end

function GameViewLayer:endSetUserInfo(reScore)
	--自己金币
	local lUserCoin = ExternalFun.formatScoreText(self:getMeUserItem().lScore - self.m_lHaveJetton + reScore);
	self.m_textUserCoin:setString(lUserCoin);

    --自己的成绩
    local lUserCj = ExternalFun.formatScoreText(self.m_MeCj);
    self.m_textCj:setString(lUserCj);
end

--初始化桌面下注
function GameViewLayer:initJetton( csbNode )
	local bottom_sp = self.m_spBottom;
	------
	--下注按钮	

	self:initJettonBtnInfo(csbNode);
	------

	------
	--下注区域
	self:initJettonArea(csbNode);
	------

	-----
	--下注胜利提示
	-----
	self:initJettonSp(csbNode);
end

--初始化上庄列表
function GameViewLayer:refreshAppLyInfo()
	local userList = self:getDataMgr():getApplyBankerUserList()
	--print("@@@@@@@@@@@@@@上庄列表@@@@@@@@@@@@@@")

	if self.m_nodeApply == nil then
		self.m_nodeApply= self._csbNode:getChildByName("Node_shangzhuang")
	end
	for i=1,1 do
		local nameLabelStr = "Text_name" .. i
		local name = self.m_nodeApply:getChildByName(nameLabelStr)

		local scoreLabelStr = "Text_score" .. i
		local score = self.m_nodeApply:getChildByName(scoreLabelStr)
        score:setFontName("fonts/round_body.ttf")
		if userList[#userList-i+1] then
			local str = userList[#userList-i+1].m_userItem.szNickName

			if self.m_labelApplyName[i] == nil then
				self.m_labelApplyName[i] = g_var(ClipText):createClipText(cc.size(120, 20), "",nil,22)
				self.m_labelApplyName[i]:setPosition(cc.p(name:getPositionX(), name:getPositionY()))
				self.m_labelApplyName[i]:setAnchorPoint(cc.p(0,0.5));
				self.m_labelApplyName[i]:setTextColor(cc.c4b(255,255,255,255))
				self.m_nodeApply:addChild(self.m_labelApplyName[i])
				name:setVisible(false)
			else
				self.m_labelApplyName[i]:setVisible(true)
			end
			self.m_labelApplyName[i]:setString(ExternalFun.GetShortName(str,9,8))
            if str == self:getMeUserItem().szNickName then 
                self.m_labelApplyName[i]:setTextColor(cc.c4b(160,254,77,255))
            end
			local scoreStr = ExternalFun.formatScoreText(userList[#userList-i+1].m_userItem.lScore)
			score:setString(scoreStr)
			score:setVisible(true)
		else
			if self.m_labelApplyName[i] then
				self.m_labelApplyName[i]:setVisible(false)
			end
			name:setVisible(false)
			score:setVisible(false)
		end
	end
end

function GameViewLayer:enableJetton( var )
	--下注按钮
	self:reSetJettonBtnInfo(var);

	--下注区域
	self:reSetJettonArea(var);
end

--下注按钮
function GameViewLayer:initJettonBtnInfo( csbNode )
	local clip_layout = csbNode:getChildByName("Node_ChipBtn")

	local function clipEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onJettonButtonClicked(sender:getTag(), sender);
		end
	end

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

	self.m_tabJettonAnimate = {}
	for i=1,#self.m_pJettonNumber do
		local str = string.format("Button_chip_%d", i)
		local btn = clip_layout:getChildByName(str)
		btn:setTag(i)
		btn:addTouchEventListener(clipEvent)
		self.m_tableJettonBtn[i] = btn
	end
	local blink = cc.Blink:create(1.0,1)
	self.m_spriteSelect = clip_layout:getChildByName("Sprite_selectBtn")
	self.m_spriteSelect:runAction(cc.RepeatForever:create(blink))

	self:reSetJettonBtnInfo(false);
end

function GameViewLayer:reSetJettonBtnInfo( var )
	for i=1,#self.m_tableJettonBtn do
		self.m_tableJettonBtn[i]:setTag(i)
		self.m_tableJettonBtn[i]:setEnabled(var)

		self.m_spriteSelect:stopAllActions()
		self.m_spriteSelect:setVisible(var)
	end
end

function GameViewLayer:adjustJettonBtn(  )
	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self:getMeUserItem().lScore - self.m_lHaveJetton, lCanJetton);

	for i=1,#self.m_tableJettonBtn do
		local enable = false
		if self.m_bOnGameRes then
			enable = false
		else
			enable = self.m_bOnGameRes or (lCondition >= self.m_pJettonNumber[i].k)
		end
		self.m_tableJettonBtn[i]:setEnabled(enable);
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

	if self.m_nJettonSelect > self:getMeUserItem().lScore - self.m_lHaveJetton then
		self.m_nJettonSelect = -1;
	end

	--筹码动画
	local enable = lCondition >= self.m_pJettonNumber[self.m_nSelectBet].k;
	if false == enable then
		self.m_spriteSelect:stopAllActions()
		self.m_spriteSelect:setVisible(true)
	end

end

function GameViewLayer:refreshJetton(  )
	--local str = ExternalFun.formatScoreText(self.m_lHaveJetton)
	--self.m_textDangqian:setString(str)
	--self.m_userJettonLayout:setVisible(self.m_lHaveJetton > 0)
	--print("self.m_lAllJetton",self.m_lAllJetton)
	--local lAllJetton = ExternalFun.formatScoreText(self.m_lAllJetton);
	--self.m_textallUserIn:setString(lAllJetton)
--    if self.m_lHaveJetton > 0 then 
--        self.m_btnClearChip:setVisible(true)
--    else
--        self.m_btnClearChip:setVisible(false)
--    end
end


function GameViewLayer:switchJettonBtnState( idx )
	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self:getMeUserItem().lScore - self.m_lHaveJetton, lCanJetton);
	if nil ~= idx and nil ~= self.m_spriteSelect and nil ~= self.m_tableJettonBtn[idx] then
		local enable = lCondition >= self.m_pJettonNumber[idx].k;
		if enable then
			if self.m_spriteSelect:isRunning() == true then
				local blink = cc.Blink:create(1.0,1)
				self.m_spriteSelect:runAction(cc.RepeatForever:create(blink))
                self.m_spriteSelect:setVisible(true)
			end
			
			self.m_spriteSelect:setPosition(self.m_tableJettonBtn[idx]:getPositionX(),self.m_tableJettonBtn[idx]:getPositionY())
        else
            self.m_spriteSelect:setVisible(false)
		end
	end
end

--下注筹码结算动画
function GameViewLayer:betAnimation( )
	local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
	if nil == cmd_gameend then
		return
	end

	local tmp = self.m_betAreaLayout:getChildren()
	--数量控制
	local maxCount = 300
	local count = 0
	local children = {}
	for k,v in pairs(tmp) do
        if v then 
		    table.insert(children, v)
		    count = count + 1		    
        end
        if count > maxCount then
            break
        end
	end
	local left = {}
	-- print("下注筹码结算动画")
	local returnScore = cmd_gameend.lUserReturnScore or cmd_gameend.lEndUserReturnScore
	local returnBankScore = cmd_gameend.lBankerScore or cmd_gameend.lBankerWinScore
	--庄家的
	local meChair =  self:getMeUserItem().wChairID
	local call = cc.CallFunc:create(function()
		--print("庄家的")
		left = self:userBetAnimation(children, "banker", returnBankScore)
	end)
	local delay = cc.DelayTime:create(1)
	--自己的 

	local call2 = cc.CallFunc:create(function()		
		-- print("自己金币回来")
		left = self:userBetAnimation(left, meChair, returnScore)
		self:endSetUserInfo(returnScore)      
	end)	
	local delay2 = cc.DelayTime:create(0.5)

	--其余玩家的
	local call4 = cc.CallFunc:create(function()
		self:userBetAnimation(left, "other", 1)
		self:refreshApplyList()
		self:refreshUserList()
	end)

	--剩余没有移走的
	local call5 = cc.CallFunc:create(function()
		--下注筹码数量显示移除
		self:cleanJettonArea()
	end)

	local seq = cc.Sequence:create(call, delay, call2, delay2, call4, cc.DelayTime:create(3), call5)
	self:stopAllActions()
	self:runAction(seq)	
end

--玩家分数
function GameViewLayer:userBetAnimation( children, wchair, score )
	if nil == score or score <= 0 then
		return children
	end

	local left = {}
	local getScore = score
	local tmpScore = 0
	local totalIdx = #self.m_pJettonNumber
	local winSize = self.m_betAreaLayout:getContentSize()
	local remove = true
	local count = 0
	for k,v in pairs(children) do
		local idx = nil
		if remove then
			if nil ~= v and v:getTag() == wchair then
				idx = tonumber(v:getName())
				local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wchair))
				self:generateBetAnimtion(v, {x = pos.x, y = pos.y}, count)
				if nil ~= idx and nil ~= self.m_pJettonNumber[idx] then
					tmpScore = tmpScore + self.m_pJettonNumber[idx].k
				end
				if tmpScore >= score then
					remove = false
				end
			elseif yl.INVALID_CHAIR == wchair then
				--随机抽下注筹码
				idx = self:randomGetBetIdx(getScore, totalIdx)
				local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wchair))
				if nil ~= idx and nil ~= self.m_pJettonNumber[idx] then
					tmpScore = tmpScore + self.m_pJettonNumber[idx].k
					getScore = getScore - tmpScore
				end

				if tmpScore >= score then

					remove = false
				end
			elseif "banker" == wchair then
				--随机抽下注筹码
				idx = tonumber(v:getName())
				pos = self.m_betAreaLayout:convertToNodeSpace(cc.p(667,610))
				self:generateBetAnimtion(v, {x = pos.x, y = pos.y}, count)

				if nil ~= idx and nil ~= self.m_pJettonNumber[idx] then
					tmpScore = tmpScore + self.m_pJettonNumber[idx].k
				end

				if tmpScore >= score then
					remove = false
				end
			elseif "other" == wchair then
				local pos = cc.p(self.m_btnPlayerList:getPositionX(), self.m_btnPlayerList:getPositionY())
				self:generateBetAnimtion(v, {x = pos.x, y = pos.y}, count)
			else
				table.insert(left, v)
			end
		else
			table.insert(left, v)
		end	
		count = count + 1	
	end
	return left
end

function GameViewLayer:generateBetAnimtion( bet, pos, count)
	--筹码动画	
	local moveTo = cc.MoveTo:create(BET_ANITIME, cc.p(pos.x, pos.y))
	local call = cc.CallFunc:create(function ( )
		bet:removeFromParent()
	end)
	bet:stopAllActions()
	bet:runAction(cc.Sequence:create(cc.DelayTime:create(0.05 * count),moveTo, call))
end

function GameViewLayer:randomGetBetIdx( score, totalIdx )
	if score > self.m_pJettonNumber[1].k and score < self.m_pJettonNumber[2].k then
		return math.random(1,2)
	elseif score > self.m_pJettonNumber[2].k and score < self.m_pJettonNumber[3].k then
		return math.random(1,3)
	elseif score > self.m_pJettonNumber[3].k and score < self.m_pJettonNumber[4].k then
		return math.random(1,4)
	else
		return math.random(totalIdx)
	end
end

--下注区域
function GameViewLayer:initJettonArea( csbNode )
	local tag_control = csbNode:getChildByName("Node_InBtn");
	self.m_tagControl = tag_control

    local function JettonEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onTouchJetton(sender:getTouchEndPosition());
		end
	end
    self.canBet = false
    self.m_btnBet = csbNode:getChildByName("btnBet")
    self.m_btnBet:addTouchEventListener(JettonEvent);

	--筹码区域
	self.m_betAreaLayout = tag_control:getChildByName("bet_area")
	--按钮列表
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onJettonAreaClicked(sender:getTag(), sender);
		end
	end	

    for i=1,52 do
		local str = string.format("Button_%d", i)
		local tag_btn = tag_control:getChildByName(str)
        if tag_btn ~= nil then 
		    tag_btn:setTag(i);
		    self.m_tableJettonArea[i] = tag_btn;
        end
	end

	self:reSetJettonArea(false)
end

function GameViewLayer:reSetJettonArea( var )
    for k,v in pairs(self.m_tableJettonArea) do 
        v:setEnabled(var)
    end
    self.canBet = var
end
function GameViewLayer:onTouchJetton(pos)    
    local m_nJettonSelect = self.m_nJettonSelect;
	if m_nJettonSelect < 0 then
		return;
	end
    if self.canBet == true then 
        local count = 4
        local area;
        for k,v in pairs(ptJetton) do 
            local vertX = {}
            local vertY = {}
            for i = 1 ,count do 
                table.insert(vertX,v[i].x+self.addX)
                table.insert(vertY,v[i].y)
            end
            
            if ExternalFun.pnpoly(count,vertX,vertY,pos.x,pos.y) then 
                area = k -1 
                if self.m_lHaveJetton > self.m_llMaxJetton then
		            showToast(cc.Director:getInstance():getRunningScene(),"已超过最大下注限额",1)
		            return;
	            end
	            --下注
	            self:getParentNode():sendUserBet(area, m_nJettonSelect);
                self.m_IsChip = true 
                return
            end
        end
    end
end
function GameViewLayer:cleanJettonArea(  )
	--移除界面已下注
	self.m_betAreaLayout:removeAllChildren()
    for k,v in pairs(self.m_tableJettonNode) do 
        self:reSetJettonNode(v)
    end
	self.m_lHaveJetton = 0;
	self.m_lAllJetton = 0;
end

--下注胜利提示
function GameViewLayer:initJettonSp( csbNode )
	self.m_tagSpControls = {};
	local sp_control = csbNode:getChildByName("Node_area");
	for i=1,52 do
		--local tag = i - 1;
		local str = string.format("yyl_higtlight_%d", i);
		local tagsp = sp_control:getChildByName(str);
        if tagsp ~= nil then 
		    self.m_tagSpControls[i] = tagsp;
        end
	end

	self:reSetJettonSp();
end

function GameViewLayer:reSetJettonSp(  )
    for k,v in pairs(self.m_tagSpControls) do
        v:setVisible(false);
    end
end

--胜利区域闪烁
function GameViewLayer:jettonAreaBlink( tabArea )
	for k,v in pairs(tabArea) do
		local score = v        
		if score > 0 and self.m_tagSpControls[k] ~= nil then		
            local rep = cc.RepeatForever:create(cc.Blink:create(1.0,1))
            self.m_tagSpControls[k]:setVisible(true)
            self.m_tagSpControls[k]:runAction(rep)
		end
	end
end

function GameViewLayer:jettonAreaBlinkClean(  )
	for i = 1, g_var(cmd).AREA_COUNT do
        if self.m_tagSpControls[i] ~= nil then 
		    self.m_tagSpControls[i]:stopAllActions()
		    self.m_tagSpControls[i]:setVisible(false)
        end
	end
end

function GameViewLayer:initAction(  )
	local dropIn = cc.ScaleTo:create(0.2, 1, 1);
	dropIn:retain();
	self.m_actDropIn = dropIn;

	local dropOut = cc.ScaleTo:create(0.2, 0, 0);
	dropOut:retain();
	self.m_actDropOut = dropOut;
end
--设置状态
function GameViewLayer:SetGameStaus( gameStaus )
    self.m_cbGameStatus = gameStaus;
end

---------------------------------------------------------------------------------------

function GameViewLayer:onButtonClickedEvent(tag,ref)
    ExternalFun.playClickEffect()
    if tag == TAG_ENUM.BT_EXIT then
	    self:getParentNode():onQueryExitGame()
    elseif tag == TAG_ENUM.BT_CHAT then
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            item:resetData()
        else
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
    elseif tag == TAG_ENUM.BT_APPLY then
        local state = self:getApplyState()
        self:applyBanker( state )
    elseif tag == TAG_ENUM.BT_APPLYLIST then
        if nil == self.m_applyListLayer then
		    self.m_applyListLayer = g_var(ApplyListLayer):create(self)
		    self:addToRootLayer(self.m_applyListLayer, TAG_ZORDER.USERLIST_ZORDER)
        else
            self.m_applyListLayer:setVisible(true)
	    end
	    local userList = self:getDataMgr():getApplyBankerUserList()	
	    self.m_applyListLayer:refreshList(userList)
    elseif tag == TAG_ENUM.BT_RULE then  --帮助
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, g_var(cmd).KIND_ID, 0)
            self:addToRootLayer(self.layerHelp, TAG_ZORDER.HELP_ZORDER)
        else
            self.layerHelp:onShow()
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
        if self._bankLayer == nil then
            self._bankLayer=BankLayer:create(self) 
            self:addChild(self._bankLayer,10)
        else
            self._bankLayer:onShow()
        end
    elseif tag == TAG_ENUM.BT_CLEARCHIP then 
        --清空下注

    elseif tag == TAG_ENUM.BT_SET then
        if self.settingLayer == nil then 
 	        local mgr = self._scene._scene:getApp():getVersionMgr()
            local verstr = mgr:getResVersion(g_var(cmd).KIND_ID) or "0"    	
            self.settingLayer = SettingLayer:create(verstr)
	        self:addToRootLayer(self.settingLayer, TAG_ZORDER.SETTING_ZORDER)
        else
            self.settingLayer:onShow()
        end
    elseif tag == TAG_ENUM.BT_LUDAN then
        if self.showLudan == true then
            self.showLudan = false
            self.nodeLudan1:runAction(self.m_actDropOut);
        else
            self.showLudan = true
            self.nodeLudan1:runAction(self.m_actDropIn);
        end

    --		local nodeLudan1 = self._csbNode:getChildByName("Node_ludan1")
    --		local nodeLudan2 = self._csbNode:getChildByName("Node_ludan2")
    --		if nodeLudan1:isVisible() == true then
    --			nodeLudan1:setVisible(false)
    --			nodeLudan2:setVisible(true)
    --		else
    --			nodeLudan1:setVisible(true)
    --			nodeLudan2:setVisible(false)
    --		end

    elseif tag == TAG_ENUM.BT_ROBBANKER then
	    --超级抢庄
	    -- if g_var(cmd).SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
	    -- 	local str = "超级抢庄将花费 " .. self.m_tabSupperRobConfig.lSuperBankerConsume .. ",确定抢庄?"
	    -- 	local query = QueryDialog:create(str, function(ok)
	    --         if ok == true then
	    --             self:getParentNode():sendRobBanker()
	    --         end
	    --     end):setCanTouchOutside(false)
	    --         :addTo(self) 
	    -- else
	    -- 	self:getParentNode():sendRobBanker()
	    -- end
    elseif tag == TAG_ENUM.BT_MENU then
	    if nil == self.m_btnListLayer then
		    self.m_btnListLayer = g_var(BtnListLayer):create(self)
		    self:addToRootLayer(self.m_btnListLayer, TAG_ZORDER.BTNLISTLAYER_ZORDER)
		    self.m_btnListLayer.superParent = self
	    else
		    self.m_btnListLayer:setVisible(true)
	    end
	    self.m_btnListLayer.m_spBg:stopAllActions()
	    self.m_btnListLayer.m_spBg:runAction(self.m_actDropIn)
    elseif tag == TAG_ENUM.BT_CLOSEEND then 
        self:hideResult()
    else
	    showToast(cc.Director:getInstance():getRunningScene(),"功能尚未开放！",1)
    end
end

function GameViewLayer:onJettonButtonClicked( tag, ref )
	if tag >= 1 and tag <= 7 then
		self.m_nJettonSelect = self.m_pJettonNumber[tag].k;
	else
		self.m_nJettonSelect = -1;
	end

	self.m_nSelectBet = tag
	self:switchJettonBtnState(tag)
end

function GameViewLayer:onJettonAreaClicked( tag, ref )
	local m_nJettonSelect = self.m_nJettonSelect;
	if m_nJettonSelect < 0 then
		return;
	end
	--print("@@@tag@@@",tag)
	local area = tag - 1;

	if self.m_lHaveJetton > self.m_llMaxJetton then
		showToast(cc.Director:getInstance():getRunningScene(),"已超过最大下注限额",1)

		return;
	end

	--下注
	self:getParentNode():sendUserBet(area, m_nJettonSelect);
end

function GameViewLayer:showGameResult( bShow )
	if true == bShow then
		if nil == self.m_gameResultLayer then
			self.m_gameResultLayer = self._csbNode:getChildByName("Sprite_resultBg")
		end
		self:showResult()
	else
		if nil ~= self.m_gameResultLayer then
			self:hideResult()
		end
        self.m_FreeDiceBg:setVisible(true)
        self.m_nodeDiceBg:setVisible(false)
	end
end
function GameViewLayer:setResultDice(Data)
    local Node = self.m_gameResultLayer:getChildByName("Node_dice")
    local diceResult = Node:getChildByName("dice_result")
    --骰子
	for i=1,3 do
		local diceStr = string.format("dice_%d",i)
		local dice = diceResult:getChildByName(diceStr)
		local diceFrameStr = string.format("yyl_icon_ludan%d.png",Data.cbDiceValue[i])
		dice:setSpriteFrame(diceFrameStr)
	end
    --点数
    local diceDianshu = diceResult:getChildByName("Text_dianshu")
    diceDianshu:setFontName("fonts/round_body.ttf")
    diceDianshu:setString(""..Data.cbDicePoints)
    --大小图片
    local diceDaxiao = diceResult:getChildByName("Sprite_daxiao")
    local daxiaoStr
    if Data.cbDiceDaxiao == "大" then
        daxiaoStr = "yyl_tab_end_big.png"
    elseif Data.cbDiceDaxiao == "小" then
        daxiaoStr = "yyl_tab_end_small.png"
    end
    local DxSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(daxiaoStr)
    diceDaxiao:setSpriteFrame(DxSpriteFrame)
end
function GameViewLayer:showResult()

	local resultData = self:getDataMgr().m_tabGameResult
	self.m_gameResultLayer:setVisible(true)
    dump(resultData)
    --设置骰子
    self:setResultDice(resultData)
    --背景光效
    local ligth = self.m_gameResultLayer:getChildByName("bg_light")
    ligth:runAction(cc.RotateBy:create(20, 3600))

	--播放声音
	if resultData.lUserScore > 0 then
        ExternalFun.playSoundEffect("yaoyaole_end_win.mp3")
        ExternalFun.playSoundEffect("yaoyaole_end_win1.mp3")
	elseif resultData.lUserScore <0  then
		ExternalFun.playSoundEffect("yaoyaole_end_lose.mp3")
	end

	--1-3名
    if resultData.tagUserWinRank then 
        local tabWinList = resultData.tagUserWinRank[1];
        dump(tabWinList)
        for i = 1,3 do 
            local mcName = self.m_gameResultLayer:getChildByName("Text_mcName"..i)
            mcName:setFontName("fonts/round_body.ttf")
            local mcScore = self.m_gameResultLayer:getChildByName("Text_mcScore"..i)
            mcScore:setFontName("fonts/round_body.ttf")
            local name = ""
            local score = 0
            if tabWinList[i].lRankWinScore <= 0 then 
                name = "无"
            else
                name = ExternalFun.GetShortName(tabWinList[i].szNickName,12,10)
                score = tabWinList[i].lRankWinScore
            end
            mcName:setString(name)
            local tScore = self:getParentNode():formatScoreText(score)
            mcScore:setString(tScore)
        end   
    end
    --玩家名称
    local textMyName = self.m_gameResultLayer:getChildByName("Text_myName")
    textMyName:setFontName("fonts/round_body.ttf")
    textMyName:setString(ExternalFun.GetShortName(self:getMeUserItem().szNickName,12,10))
	--玩家分数
	local textMyScore = self.m_gameResultLayer:getChildByName("Text_myScore")
    textMyScore:setFontName("fonts/round_body.ttf")
	local myScore = self:getParentNode():formatScoreText(resultData.lUserScore)
	textMyScore:setString(myScore)
    self.m_MeCj = self.m_MeCj + resultData.lUserScore 
    self:reSetUserInfo()
    --玩家输赢
    local myWinLose = self.m_gameResultLayer:getChildByName("Sprite_winlose_my")
    local myStr = nil
    if self.m_IsChip == true then 
        if resultData.lUserScore > 0 then 
            myStr = "yyl_icon_end_wintitle.png"
            myWinLose:setVisible(true)
        elseif resultData.lUserScore == 0 then 
            myStr = "yyl_text_nochip.png"
            myWinLose:setVisible(false)
        elseif resultData.lUserScore < 0 then 
            myStr = "yyl_icon_end_losetitle.png"
            myWinLose:setVisible(true)
        end
    else
        myStr = "yyl_text_nochip.png"
        myWinLose:setVisible(true)
    end
    local mySpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(myStr)
    myWinLose:setSpriteFrame(mySpriteFrame)

    --庄家名称
    local textBankerName = self.m_gameResultLayer:getChildByName("Text_bankerName")
    textBankerName:setFontName("fonts/round_body.ttf")
    textBankerName:setString(ExternalFun.GetShortName(self.m_clipBankerNick:getString(),12,10))
	--庄家分数
	local textBankerScore = self.m_gameResultLayer:getChildByName("Text_bankerScore")
    textBankerScore:setFontName("fonts/round_body.ttf")
	local bankerScore = self:getParentNode():formatScoreText(resultData.lBankerScore)
	textBankerScore:setString(bankerScore)

    --庄家输赢
    local bankerWinLose = self.m_gameResultLayer:getChildByName("Sprite_winlose_banker")
    local bankerStr = nil
    if resultData.lBankerScore > 0 then 
        bankerStr = "yyl_icon_end_wintitle.png"
    elseif resultData.lBankerScore == 0 then 
        bankerStr = "yyl_text_nochip.png"
    elseif resultData.lBankerScore < 0 then 
        bankerStr = "yyl_icon_end_losetitle.png"
    end
    local bankerSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(bankerStr)
    bankerWinLose:setSpriteFrame(bankerSpriteFrame)
end

function GameViewLayer:hideResult(  )
    if self.m_gameResultLayer then 
        local ligth = self.m_gameResultLayer:getChildByName("bg_light")
        ligth:stopAllActions()
	    self.m_gameResultLayer:setVisible(false)
    end
    self.m_FreeDiceBg:setVisible(true)
    self.m_nodeDiceBg:setVisible(false)
end 

function GameViewLayer:onCheckBoxClickEvent( sender,eventType )
	ExternalFun.playClickEffect()
	if eventType == ccui.CheckBoxEventType.selected then
		self.m_btnList:stopAllActions();
		self.m_btnList:runAction(self.m_actDropIn);
	elseif eventType == ccui.CheckBoxEventType.unselected then
		self.m_btnList:stopAllActions();
		self.m_btnList:runAction(self.m_actDropOut);
	end
end

-- function GameViewLayer:onSitDownClick( tag, sender )
-- 	print("sit ==> " .. tag)
-- 	local useritem = self:getMeUserItem()
-- 	if nil == useritem then
-- 		return
-- 	end

-- 	--重复判断
-- 	if nil ~= self.m_nSelfSitIdx and tag == self.m_nSelfSitIdx then
-- 		return
-- 	end

-- 	if nil ~= self.m_nSelfSitIdx then --and tag ~= self.m_nSelfSitIdx  then
-- 		showToast(self, "当前已占 " .. self.m_nSelfSitIdx .. " 号位置,不能重复占位!", 2)
-- 		return
-- 	end	

-- 	--坐下条件限制
-- 	if self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_CONSUMETYPE then --金币占座
-- 		if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatConsume then
-- 			local str = "坐下需要消耗 " .. self.m_tabSitDownConfig.lOccupySeatConsume .. " 金币,金币不足!"
-- 			showToast(self, str, 2)
-- 			return
-- 		end
-- 		local str = "坐下将花费 " .. self.m_tabSitDownConfig.lOccupySeatConsume .. ",确定坐下?"
-- 			local query = QueryDialog:create(str, function(ok)
-- 		        if ok == true then
-- 		            self:getParentNode():sendSitDown(tag - 1, useritem.wChairID)
-- 		        end
-- 		    end):setCanTouchOutside(false)
-- 		        :addTo(self)
-- 	elseif self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_VIPTYPE then --会员占座
-- 		if useritem.cbMemberOrder < self.m_tabSitDownConfig.enVipIndex then
-- 			local str = "坐下需要会员等级为 " .. self.m_tabSitDownConfig.enVipIndex .. " 会员等级不足!"
-- 			showToast(self, str, 2)
-- 			return
-- 		end
-- 		self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
-- 	elseif self.m_tabSitDownConfig.occupyseatType == g_var(cmd).OCCUPYSEAT_FREETYPE then --免费占座
-- 		if useritem.lScore < self.m_tabSitDownConfig.lOccupySeatFree then
-- 			local str = "免费坐下需要携带金币大于 " .. self.m_tabSitDownConfig.lOccupySeatFree .. " ,当前携带金币不足!"
-- 			showToast(self, str, 2)
-- 			return
-- 		end
-- 		self:getParentNode():sendSitDown(tag - 1, self:getMeUserItem().wChairID)
-- 	end
-- end

function GameViewLayer:onResetView()
	self:stopAllActions()
	self:gameDataReset()
end

function GameViewLayer:onExit()

	print("GameViewLayer onExit")

 	--播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
    self:onResetView()
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

---------------------------------------------------------------------------------------
--网络消息

------
--网络接收
function GameViewLayer:onGetUserScore( item )
	--自己
	if item.dwUserID == GlobalUserItem.dwUserID then
       self:reSetUserInfo()
    end

    --庄家
    if self.m_wBankerUser == item.wChairID then
    	--庄家金币
		local str = ExternalFun.formatScoreText(item.lScore);
		self.m_textBankerCoin:setString(str);
        
		if yl.INVALID_CHAIR == self.m_wBankerUser then
	        self.m_textBankerCoin:setString("");
        end
    end

end

function GameViewLayer:refreshCondition(  )
	local applyable = self:getApplyable()
	if applyable then
		------
		--超级抢庄

		--如果当前有超级抢庄用户且庄家不是自己
		--if (yl.INVALID_CHAIR ~= self.m_wCurrentRobApply) or (true == self:isMeChair(self.m_wBankerUser)) then
			--ExternalFun.enableBtn(self.m_btnRob, false)
		-- else
		-- 	local useritem = self:getMeUserItem()
		-- 	--判断抢庄类型
		-- 	if g_var(cmd).SUPERBANKER_VIPTYPE == self.m_tabSupperRobConfig.superbankerType then
		-- 		--vip类型				
		-- 		ExternalFun.enableBtn(self.m_btnRob, useritem.cbMemberOrder >= self.m_tabSupperRobConfig.enVipIndex)
		-- 	elseif g_var(cmd).SUPERBANKER_CONSUMETYPE == self.m_tabSupperRobConfig.superbankerType then
		-- 		--游戏币消耗类型(抢庄条件+抢庄消耗)
		-- 		local condition = self.m_tabSupperRobConfig.lSuperBankerConsume + self.m_llCondition
		-- 		ExternalFun.enableBtn(self.m_btnRob, useritem.lScore >= condition)
		-- 	end
		-- end		
	-- else
	-- 	ExternalFun.enableBtn(self.m_btnRob, false)
	end
end

--游戏free
function GameViewLayer:onGameFree( )
	yl.m_bDynamicJoin = false
	self:reSetForNewGame()

	--上庄条件刷新
	self:refreshCondition()

	--申请按钮状态更新
	self:refreshApplyBtnState()

end

--游戏开始
function GameViewLayer:onGameStart( )
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
    self.m_IsChip = false 
	--获取玩家携带游戏币	
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家,且有庄家
	if false == self:isMeChair(self.m_wBankerUser) and false == self.m_bNoBanker then
		--下注
		self:enableJetton(true);
		--调整下注按钮
		self:adjustJettonBtn();

		--默认选中的筹码
		self:switchJettonBtnState(DEFAULT_BET)
	end	

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))

	--申请按钮状态更新
	self:refreshApplyBtnState()	
    self:showStateTips(101)
end

--游戏进行
function GameViewLayer:reEnterStart( lUserJetton )
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
	self.m_lHaveJetton = lUserJetton;

	--获取玩家携带游戏币
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家
	if false == self:isMeChair(self.m_wBankerUser) then
		--下注
		self:enableJetton(true);
		--调整下注按钮
		self:adjustJettonBtn();

		--默认选中的筹码
		self:switchJettonBtnState(DEFAULT_BET)
	end
end

--下注条件
function GameViewLayer:onGetApplyBankerCondition( llCon , rob_config)
	self.m_llCondition = llCon
	--超级抢庄配置
	-- if rob_config then
	-- 	self.m_tabSupperRobConfig = rob_config
	-- end

	self:refreshCondition();
end

--刷新庄家信息
function GameViewLayer:onChangeBanker( _wBankerUser, _lBankerScore,_cbBankerTime ,_lBankerWinScore)
	local gameBankInfo =  self:getParentNode():getDataMgr().m_tabGameBankInfo
	-- dump(gameBankInfo)
	local wBankerUser = _wBankerUser and _wBankerUser or  gameBankInfo.wBankerUser
	local lBankerScore = _lBankerScore and _lBankerScore or  gameBankInfo.lBankerScore
	local cbBankerTime = _cbBankerTime and _cbBankerTime or  gameBankInfo.nBankerTime
	local lBankerWinScore = _lBankerWinScore and _lBankerWinScore or gameBankInfo.lBankerWinScore
	local bEnableSysBanker = self:getParentNode().m_bEnableSystemBanker
	--print("更新庄家数据:" .. wBankerUser .. "; coin =>" .. lBankerScore)
	--print("cbBankerTime,lBankerWinScore",cbBankerTime,lBankerWinScore)
	--上一个庄家是自己，且当前庄家不是自己，标记自己的状态
	if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end
	-- 5 无人坐庄  6 由您坐庄   7 轮换坐庄
	if self.m_wBankerUser ~= wBankerUser then
		if self:isMeChair(wBankerUser) then
			--print("由您坐庄")
			self:refreshBankerTip(6)
		elseif wBankerUser ~= yl.INVALID_CHAIR then
			--print("轮换坐庄")
			self:refreshBankerTip(7)
		else
			--print("无人坐庄")
			self:refreshBankerTip(5)
		end
	end
	self.m_wBankerUser = wBankerUser 
	--获取庄家数据
	self.m_bNoBanker = false
    local head = self.m_NodeBankerBg:getChildByTag(GameViewLayer.BANKERFACE)
	local nickstr = "";
	--庄家姓名
	--print("bEnableSysBanker",bEnableSysBanker)
	if true == bEnableSysBanker then --允许系统坐庄
		if yl.INVALID_CHAIR == self.m_wBankerUser then
			nickstr = "系统坐庄"
			lBankerScore = 9999999999
            if head then 
                head:removeFromParent()
            else
                local headBg = display.newSprite("#userinfo_head_frame.png")
                headBg:setPosition(self.m_spBankerHead:getPosition())
                headBg:setScale(0.55,0.55)
                self.m_NodeBankerBg:addChild(headBg)
            end          
            local head = g_var(PopupInfoHead):createNormal(userItem, 90)                        
			head:setPosition(self.m_spBankerHead:getPosition());
            head:setTag(GameViewLayer.BANKERFACE)            
			self.m_NodeBankerBg:addChild(head)
		else
			local userItem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1];
			if nil ~= userItem then
				nickstr = userItem.szNickName 
                --头像
                if not head then
                    local headBg = display.newSprite("#userinfo_head_frame.png")
                    headBg:setPosition(self.m_spBankerHead:getPosition())
                    headBg:setScale(0.55,0.55)
                    self.m_NodeBankerBg:addChild(headBg)
                    head = g_var(PopupInfoHead):createNormal(userItem, 90)                        
			        head:setPosition(self.m_spBankerHead:getPosition());
                    head:setTag(GameViewLayer.BANKERFACE)                    
			        self.m_NodeBankerBg:addChild(head)
                else
			        head:updateHead(userItem)
		        end
		        head:setVisible(true)
				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
				end
			else
				--print("获取用户数据失败")
			end
		end	
	else
		--print("yl.INVALID_CHAIR == wBankerUser",yl.INVALID_CHAIR == wBankerUser)
		if yl.INVALID_CHAIR == wBankerUser then
			nickstr = "无人坐庄"
			self.m_bNoBanker = true
            if head then
                head:setVisible(false) 
            end
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1];
			if nil ~= userItem then
				nickstr = userItem.szNickName 
                --头像
                if not head then
                    local headBg = display.newSprite("#userinfo_head_frame.png")
                    headBg:setPosition(self.m_spBankerHead:getPosition())
                    headBg:setScale(0.55,0.55)
                    self.m_NodeBankerBg:addChild(headBg)
                    head = g_var(PopupInfoHead):createNormal(userItem, 90)                        
			        head:setPosition(self.m_spBankerHead:getPosition());
                    head:setTag(GameViewLayer.BANKERFACE)                   
			        self.m_NodeBankerBg:addChild(head)
		        else
			        head:updateHead(userItem)
		        end
		        head:setVisible(true)
				if self:isMeChair(wBankerUser) then
					self.m_enApplyState = APPLY_STATE.kApplyedState
				end
				--提示
				--print("获取用户数据成功")
			else
				--print("获取用户数据失败")
			end
		end
	end
	self.m_clipBankerNick:setString(nickstr);
	--庄家金币
	local str = ExternalFun.formatScoreText(lBankerScore);
	self.m_textBankerCoin:setString(str);
    
	--如果是超级抢庄用户上庄
	--if wBankerUser == self.m_wCurrentRobApply then
		--self.m_wCurrentRobApply = yl.INVALID_CHAIR
		--self:refreshCondition()
	--end
	--庄家局数
	if cbBankerTime then
        self.m_spBankerRound:setVisible(true)
		self.m_textBankerRound:setString(cbBankerTime)
	else
		self.m_spBankerRound:setVisible(false)
	end

	--庄家成绩 
	if lBankerWinScore then
		local chengJiStr = self:getParentNode():formatScoreText(lBankerWinScore);
		self.m_textBankerChengJi:setString(chengJiStr)
	else
		self.m_textBankerChengJi:setString("0")
	end
    
	if true == bEnableSysBanker then --允许系统坐庄
		if yl.INVALID_CHAIR == self.m_wBankerUser then
	        self.m_textBankerCoin:setString("");
		    self.m_textBankerChengJi:setString("")
        end
    end

    self:refreshApplyBtnState()
end

function GameViewLayer:refreshBankerTip( tag )
	--空闲状态
	-- print("self.m_cbGameStatus ~= g_var(cmd).SUB_S_GAME_FREE",self.m_cbGameStatus ~= g_var(cmd).SUB_S_GAME_FREE)
	-- print("self.m_cbGameStatus",self.m_cbGameStatus)
	-- print("g_var(cmd).SUB_S_GAME_FREE",g_var(cmd).SUB_S_GAME_FREE)
  
	--print("@@@@@@@@@@上庄提示@@@@@@@@@")
	local spriteTip = self.m_nodeBankerTip:getChildByName("Sprite_tips")

	local call1 = cc.CallFunc:create(function (  )
		self.m_nodeBankerTip:setVisible(true)
	end)
	local scale = cc.ScaleTo:create(0.2, 0.0001, 1.0)
	local call2 = cc.CallFunc:create(function (  )
		local str = string.format("yyl_text_tips%d.png", tag)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)

		--self.m_pClock.m_spTip:setVisible(false)
		if nil ~= frame then
			spriteTip:setVisible(true)
			spriteTip:setSpriteFrame(frame)
		end
	end)
	local scaleBack = cc.ScaleTo:create(0.2,1.0)
	local delayTime = cc.DelayTime:create(1.5)
	local call3 = cc.CallFunc:create(function (  )
		self.m_nodeBankerTip:setVisible(false)
	end)
	local seq = cc.Sequence:create(call1,scale, call2, scaleBack,delayTime,call3)
	spriteTip:runAction(seq)
end

--更新用户下注
function GameViewLayer:onGetUserBet( )
	local data = self:getParentNode().cmd_placebet;
	-- dump(data)
	if nil == data then
		return
	end
	local area = data.cbJettonArea + 1;
	local wUser = data.wChairID;
	local llScore = data.lJettonScore

	local nIdx = self:getJettonIdx(data.lJettonScore);
	local str = string.format("yyl_icon_chip_%d.png", nIdx);
	local sp = nil
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
	if nil ~= frame then
		sp = cc.Sprite:createWithSpriteFrame(frame);
	end
	local btn = self.m_tableJettonArea[area];
	--print("jettonBtn")
	--dump(self.m_tableJettonArea)
	if nil == sp then
        print("sp nil");
	end

	if nil == btn then
		print("btn nil");
	end
	if nil ~= sp and nil ~= btn then
		--下注
		sp:setTag(wUser);
		local name = string.format("%d", nIdx)
		sp:setName(name)
		
		--筹码飞行起点位置
		local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))
		--pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))
		sp:setPosition(pos)
		--筹码飞行动画
		local act = self:getBetAnimation(self:getBetRandomPos(btn), cc.CallFunc:create(function()
			--播放下注声音
		end))
		sp:stopAllActions()
		sp:runAction(act)
		self.m_betAreaLayout:addChild(sp)

		--下注信息显示
		--print("self.m_tableJettonNode[area]",self.m_tableJettonNode[area])
		if nil == self.m_tableJettonNode[area] then
			local jettonNode = self:createJettonNode(area)
			--jettonNode:setPosition(btn:getPosition());
			self.m_tagControl:addChild(jettonNode);
			jettonNode:setTag(-1);
			self.m_tableJettonNode[area] = jettonNode;
		end

		self:refreshJettonNode(self.m_tableJettonNode[area], llScore, llScore, self:isMeChair(wUser))
	end

	if self:isMeChair(wUser) then
		self.m_lHaveJetton = self.m_lHaveJetton + self.m_nJettonSelect;
		self:reSetUserInfo()
		--调整下注按钮
		self:adjustJettonBtn();
		--显示下注信息
		self:refreshJetton();
	end
end

--更新用户下注失败
function GameViewLayer:onGetUserBetFail(  )
	local data = self:getParentNode().cmd_jettonfail;
	if nil == data then
		return;
	end
	--下注玩家
	local wUser = data.wPlaceUser;
	--下注区域
	local cbArea = data.lJettonArea + 1;
	--下注数额
	local llScore = data.lPlaceScore;

	if self:isMeChair(wUser) then
		--提示下注失败
		local str = string.format("下注 %s 失败", tostring(llScore))
		showToast(cc.Director:getInstance():getRunningScene(),str,1)
		--自己下注失败
		--self.m_lHaveJetton = self.m_lHaveJetton - llScore;
		--self.m_lAllJetton = self.m_lAllJetton -  llScore
		self:adjustJettonBtn();
		self:refreshJetton()
		--
		if 0 ~= self.m_lHaveJetton then
			if nil ~= self.m_tableJettonNode[cbArea] then
				--self:refreshJetton(-llScore, -llScore, true)
				self:refreshJettonNode(self.m_tableJettonNode[cbArea],0, 0, true)
			end

			--移除界面下注元素
			local name = string.format("%d", cbArea)
			self.m_betAreaLayout:removeChildByName(name)
		end
	end
end

--断线重连更新界面已下注
function GameViewLayer:reEnterGameBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea];
	if nil == btn or 0 == llSocre  then
		return;
	end


	local vec = self:getDataMgr().calcuteJetton(llScore, false);
	for k,v in pairs(vec) do
		local info = v;

		for i=1,info.m_cbCount do
			local str = string.format("yyl_icon_chip_%d.png", info.m_cbIdx);
			local sp = cc.Sprite:createWithSpriteFrameName(str);
			if nil ~= sp then
				--sp:setScale(0.35);
				sp:setTag(yl.INVALID_CHAIR);
				local name = string.format("%d", cbArea)
				sp:setName(name);

				self:randomSetJettonPos(btn, sp);
				self.m_betAreaLayout:addChild(sp);
			end
		end
	end

	--下注信息显示
	if nil == self.m_tableJettonNode[cbArea] then
		--print("cbArea",cbArea)
		local jettonNode = self:createJettonNode(cbArea)
		--jettonNode:setPosition(btn:getPosition());
		self.m_tagControl:addChild(jettonNode);
		jettonNode:setTag(-1);
		self.m_tableJettonNode[cbArea] = jettonNode;
	end

	self:refreshJettonNode(self.m_tableJettonNode[cbArea], llScore, llScore, false)
end

--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea];
	if nil == btn or 0 == llSocre then
		return;
	end
	--print("@@@@@@@@@@@断线重连更新玩家已下注@@@@@@@@@@@")
	-- print("cbArea",cbArea)
	-- print("llScore",llScore)

	local vec = self:getDataMgr().calcuteJetton(llScore, false);
	for k,v in pairs(vec) do
		local info = v;

		for i=1,info.m_cbCount do
			local str = string.format("yyl_icon_chip_%d.png", info.m_cbIdx);
			local sp = cc.Sprite:createWithSpriteFrameName(str);
			if nil ~= sp then
				--sp:setScale(0.35);
				sp:setTag(yl.INVALID_CHAIR);
				local name = string.format("%d", cbArea)
				sp:setName(name);

				self:randomSetJettonPos(btn, sp);
				self.m_betAreaLayout:addChild(sp);
			end
		end
	end

	--下注信息显示
	if nil == self.m_tableJettonNode[cbArea] then
		local jettonNode = self:createJettonNode(cbArea)
		--jettonNode:setPosition(btn:getPosition());
		self.m_tagControl:addChild(jettonNode);
		jettonNode:setTag(-1);
		self.m_tableJettonNode[cbArea] = jettonNode;
	end
	self:refreshJettonNode(self.m_tableJettonNode[cbArea], llScore, 0, true)
end

--游戏结束
function GameViewLayer:onGetGameEnd( cbTimeLeave )
	self.m_bOnGameRes = true
	--不可下注
	self:enableJetton(false)
    self:showStateTips(102)
	--界面资源清理
	self:reSet()
	--骰子动画
	self:runDiceAnimate(cbTimeLeave)
end
function GameViewLayer:runDiceAni1()
    ExternalFun.playSoundEffect("yaoyaole_shake_dice.mp3")
    local oldPosX = self.m_FreeDiceBg:getPositionX()
    local oldPosY = self.m_FreeDiceBg:getPositionY()
    local NewPos = cc.p(681,439)
    --变大移动
    local diceBgSeq1 = cc.Spawn:create(
                            cc.MoveTo:create(0.3,NewPos),
                            cc.ScaleTo:create(0.3,3.3, 3.3, 3.3),
                            cc.CallFunc:create(function(node)
			                    node:rotate(-25)
                            end))                           
    --左两下 
    local diceBgSeq2 = cc.Sequence:create(
                            cc.MoveTo:create(0.15,cc.p(NewPos.x-30,NewPos.y+20)),
                            cc.MoveTo:create(0.15,cc.p(NewPos.x,NewPos.y)),  
                            cc.MoveTo:create(0.15,cc.p(NewPos.x-30,NewPos.y+20)),
                            cc.MoveTo:create(0.15,cc.p(NewPos.x,NewPos.y)),  
                            cc.CallFunc:create(function(node)                
			                    node:rotate(25)                              
                            end))                                            
    --右两下                                                                 
    local diceBgSeq3 = cc.Sequence:create(                                   
                            cc.MoveTo:create(0.15,cc.p(NewPos.x+30,NewPos.y+20)),
                            cc.MoveTo:create(0.15,cc.p(NewPos.x,NewPos.y)),  
                            cc.MoveTo:create(0.15,cc.p(NewPos.x+30,NewPos.y+20)),
                            cc.MoveTo:create(0.15,cc.p(NewPos.x,NewPos.y)),
                            cc.CallFunc:create(function(node)
			                    node:rotate(0)                           
                            end))
    --中间一下 
    local diceBgSeq4 = cc.Sequence:create(
                            cc.MoveTo:create(0.1,cc.p(NewPos.x,NewPos.y+35)),
                            cc.MoveTo:create(0.1,cc.p(NewPos.x,NewPos.y)),
                            cc.CallFunc:create(function(node)
			                    node:setPosition(cc.p(oldPosX,oldPosY)) 
                                node:setScale(1) 
                                node:setVisible(false)                                                       
                            end))
    self.m_FreeDiceBg:runAction(cc.Sequence:create(diceBgSeq1,diceBgSeq2,diceBgSeq3,diceBgSeq4,
                                cc.CallFunc:create(function() 
                                    self.m_NodeDiceAni:setVisible(true)                                   
                                    self:runDiceAni2()                                                       
                                end)))
end
function GameViewLayer:runDiceAni2()
    --初始化数据
    local gameResult =  self:getDataMgr().m_tabGameResult  
    
	--骰子
	for i=1,3 do
        local diceStr = string.format("dice_%d",i)
		local dice = self.m_NodeDiceAni:getChildByName(diceStr)
		local diceFrameStr = string.format("yyl_icon_dice%d.png",gameResult.cbDiceValue[i])
		dice:setSpriteFrame(diceFrameStr)
	end
    local nodeGai = self.m_NodeDiceAni:getChildByName("Sprite_gai")
    nodeGai:setPosition(cc.p(762,566))
    nodeGai:rotate(0)
    nodeGai:runAction(cc.Spawn:create(
                         cc.MoveTo:create(0.4,cc.p(956,607)), 
                         cc.RotateTo:create(0.4,35)
                         ))
    local nodeLight = self.m_NodeDiceAni:getChildByName("Sprite_light")
    nodeLight:runAction(cc.Sequence:create(
                        cc.RotateBy:create(2.5,360),
                        cc.CallFunc:create(function()
                            self.m_NodeDiceAni:setVisible(false)
                            self.m_nodeDiceBg:setVisible(true)
		   		            self:setDiceData()
		   		            self:showBetAreaBlink()                                                     
                         end)))
end
function GameViewLayer:runDiceAnimate(cbTimeLeave)
    self.m_nodeDiceBg:setVisible(false)
    self.m_btnClearChip:setVisible(false)
    if cbTimeLeave > 16 then
        self:runDiceAni1()
    else
        --无骰子动画
        self.m_NodeDiceAni:setVisible(false)
        self.m_FreeDiceBg:setVisible(false)
        self.m_nodeDiceBg:setVisible(true)
   		self:setDiceData()
   		self:showBetAreaBlink()
    end
end
--骰子动画
--function GameViewLayer:runDiceAnimate(cbTimeLeave)
----	if self.m_nodeDiceBg == nil then
----		self.m_nodeDiceBg = self._csbNode:getChildByName("Node_dice")
----	end
--	--local sprite = self.m_nodeDiceBg:getChildByName("Sprite_diceAni")
--    self.m_FreeDiceBg:setVisible(false)
--    self.m_nodeDiceBg:setVisible(false)
--    local sprite = self.m_AniDice
--    sprite:setVisible(true)
--	if cbTimeLeave > 16 then
--		--有骰子动画
--		local spriteFrameNum = 8
--		local perUnit = 0.05
--		local animation =cc.Animation:create()
--		for i=1,spriteFrameNum do  
--		    local frameName =string.format("118_diceAni_%d.png",i)                                            
--		    --print("frameName =%s",frameName)  
--		    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)               
--		   animation:addSpriteFrame(spriteFrame)                                                             
--		end  
--	   	animation:setDelayPerUnit(perUnit)          --设置两个帧播放时间                   
--	   	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态    
--	   	local repeatNum = math.floor((cbTimeLeave-16)/(spriteFrameNum*perUnit))
--	   	--print("repeatNum",repeatNum)
--	   	local action =  cc.Repeat:create(cc.Animate:create(animation),repeatNum)    
--	   	sprite:runAction(cc.Sequence:create(
--	   		cc.CallFunc:create(function ()
--		   		sprite:setVisible(true)
--		   		local diceResult = self.m_nodeDiceBg:getChildByName("dice_result")
--		   		diceResult:setVisible(false)
--		   		ExternalFun.playSoundEffect("IDW_SHACK_DICE.wav")
--		   	end),
--	   		action,
--	   		cc.CallFunc:create(function ()
--		   		sprite:setVisible(false)
--                self.m_nodeDiceBg:setVisible(true)
--		   		local diceResult = self.m_nodeDiceBg:getChildByName("dice_result")
--		   		diceResult:setVisible(true)
--		   		self:setDiceData()
--		   		self:showBetAreaBlink()
--		   		ExternalFun.playSoundEffect("DISPATCH_CARD.wav")
--		   	end)
--	   	))  
--	else   
--		--无骰子动画
--   		sprite:setVisible(false)
--        self.m_nodeDiceBg:setVisible(true)
--   		local diceResult = self.m_nodeDiceBg:getChildByName("dice_result")
--   		diceResult:setVisible(true)
--   		self:setDiceData()
--   		self:showBetAreaBlink()
--	end
--end

function GameViewLayer:setDiceData()
	local gameResult =  self:getDataMgr().m_tabGameResult
	--dump(gameResult)
	local diceResult = self.m_nodeDiceBg:getChildByName("dice_result")
	--骰子
	for i=1,3 do
		local diceStr = string.format("dice_%d",i)
		local dice = diceResult:getChildByName(diceStr)
		local diceFrameStr = string.format("yyl_icon_ludan%d.png",gameResult.cbDiceValue[i])
		dice:setSpriteFrame(diceFrameStr)
	end
end

--申请庄家
function GameViewLayer:onGetApplyBanker( )
	if self:isMeChair(self:getParentNode().cmd_applybanker.wApplyUser) then
		self.m_enApplyState = APPLY_STATE.kApplyState
	end
	self:refreshApplyList()
    self:refreshApplyBtnState()
end

--取消申请庄家
function GameViewLayer:onGetCancelBanker(  )
	if self:isMeChair(self:getParentNode().cmd_cancelbanker.wCancelUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end
	self:refreshApplyList()
    self:refreshApplyBtnState()
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
	local userList = self:getDataMgr():getApplyBankerUserList()
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		self.m_applyListLayer:refreshList(userList)
	end
	--刷新上庄列表
	self:refreshAppLyInfo(userList)
end

function GameViewLayer:refreshUserList(  )
	if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
		local userList = self:getDataMgr():getUserList()
		self.m_userListLayer:refreshList(userList)
	end
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState(  )
    if nil == self:getApplyState() then
		ExternalFun.enableBtn(self.m_btnApply, false)
		return
	end
    --获取当前申请状态
	local state = self:getApplyState()
	local str1 = nil
	ExternalFun.enableBtn(self.m_btnApply, false)
	--未申请状态则申请、申请状态则取消申请、已申请则取消申请
	if state == self._apply_state.kCancelState then
		str1 = "yyl_btntab_sqsz.png"
		--申请条件限制
		ExternalFun.enableBtn(self.m_btnApply, self:getApplyable())
	elseif state == self._apply_state.kApplyState then
		str1 = "yyl_btntab_cancelsq.png"
		ExternalFun.enableBtn(self.m_btnApply, true)
	elseif state == self._apply_state.kApplyedState then
		str1 = "yyl_btntab_wtxz.png"
		--取消上庄限制
		ExternalFun.enableBtn(self.m_btnApply, self:getCancelable())
	end
    local btnText = self.m_btnApply:getChildByName("Text_sqsz")
	if nil ~= str1 then
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str1)  
		btnText:setSpriteFrame(spriteFrame)
    end
end

--刷新路单
function GameViewLayer:updateWallBill()
	--dump(gameRecord)
	--dump(self:getDataMgr().m_vecRecord)
	local gameRecord = self:getDataMgr().m_vecRecord
	if nil ~= gameRecord then--and self.m_wallBill:isVisible() then
        local nodeLudan1 = self._csbNode:getChildByName("Node_ludan1")    
		--local maxRecordNum1 = #gameRecord > 4 and 4 or #gameRecord
		for i=1,5 do
			local strItem = string.format("ludan_%d",i)
			local ludanItem = nodeLudan1:getChildByName(strItem)
			--dump(gameRecord[#gameRecord-i+1])
			if gameRecord[#gameRecord-i+1] then
				ludanItem:setVisible(true)
				--local num = 0
				--骰子
				for j=1,3 do
					local diceStr = string.format("dice_%d",j)
					local dice =  ludanItem:getChildByName(diceStr)
					local diceFrameStr = string.format("yyl_ludan_%d.png",gameRecord[#gameRecord-i+1].cbDiceValue[j])
					dice:setSpriteFrame(diceFrameStr)
					--num = num + gameRecord[#gameRecord-i+1].cbDiceValue[j]
				end
				--数字
				local Text_num = ludanItem:getChildByName("Text_num")
                Text_num:setFontName("fonts/round_body.ttf")
				Text_num:setString(gameRecord[#gameRecord-i+1].cbDicePoints)
				--大小 
				local Text_daxiao = ludanItem:getChildByName("Text_daxiao")
                Text_daxiao:setFontName("fonts/round_body.ttf")
				Text_daxiao:setString(gameRecord[#gameRecord-i+1].cbDiceDaxiao)
				--颜色
				if gameRecord[#gameRecord-i+1].cbDiceDaxiao == "大" then
					Text_daxiao:setTextColor(cc.c3b(238,255,50))
				else
					Text_daxiao:setTextColor(cc.c3b(69,255,50))
				end
			else
				ludanItem:setVisible(false)
			end
		end

--		local nodeLudan2 = self._csbNode:getChildByName("Node_ludan2")
--		--local maxRecordNum2 = #gameRecord > 10 and 10 or #gameRecord
--		for i=1,10 do
--			local strItem = string.format("ludan_%d",i)
--			local ludanItem = nodeLudan2:getChildByName(strItem)
--			if gameRecord[#gameRecord-i+1] then
--				ludanItem:setVisible(true)
--				--骰子
--				for j=1,3 do
--					local strDice = string.format("dice_%d",j)
--					local dice =  ludanItem:getChildByName(strDice)
--					local strDiceFrame = string.format("118_ludan_%d.png",gameRecord[#gameRecord-i+1].cbDiceValue[j])
--					dice:setSpriteFrame(strDiceFrame)
--				end
--				--数字
--				local Text_num = ludanItem:getChildByName("Text_num")
--				Text_num:setString(gameRecord[#gameRecord-i+1].cbDicePoints)
--				--大小 
--				local Text_daxiao = ludanItem:getChildByName("Text_daxiao")
--				Text_daxiao:setString(gameRecord[#gameRecord-i+1].cbDiceDaxiao)
--				if gameRecord[#gameRecord-i+1].cbDiceDaxiao == "大" then
--					Text_daxiao:setTextColor(cc.c3b(238,255,50))
--				else
--					Text_daxiao:setTextColor(cc.c3b(69,255,50))
--				end
--			else
--				ludanItem:setVisible(false)
--			end
--		end
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
function GameViewLayer:getParentNode( )
	return self._scene;
end

function GameViewLayer:getMeUserItem(  )
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID];
	end
	return nil;
end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1];
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

function GameViewLayer:getApplyState(  )
	return self.m_enApplyState
end

function GameViewLayer:getApplyCondition(  )
	return self.m_llCondition
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
	--自己超级抢庄已申请，则不可进行普通申请
	-- if APPLY_STATE.kSupperApplyed == self.m_enApplyState then
	-- 	return false
	-- end
    --print("坐庄最小值:"..self.m_llCondition)
	local userItem = self:getMeUserItem();
	if nil ~= userItem then
		return userItem.lScore > self.m_llCondition
	else
		return false
	end
end

--获取能否取消上庄
function GameViewLayer:getCancelable( )
	return self.m_cbGameStatus == g_var(cmd).GS_GAME_FREE
end

--下注区域闪烁
function GameViewLayer:showBetAreaBlink(  )
	local blinkArea = self:getDataMgr().m_tabBetArea
	self:jettonAreaBlink(blinkArea)
end

function GameViewLayer:getDataMgr( )
	return self:getParentNode():getDataMgr()
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

function GameViewLayer:gameDataInit(  )

    --播放背景音乐
    print("播放背景音乐")
    ExternalFun.setBackgroundAudio("sound_res/yaoyaole_bgm.mp3")

    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --加载资源
	self:loadRes()

	--变量声明
	--限制信息
	self.m_lMeMaxScore = 0								--最大下注
	self.m_lAreaLimitScore = 0							--区域限制
	self.m_lApplyBankerCondition = 0					--申请条件
	--个人下注
	self.m_lUserBet = {}								--个人总注
	self.m_lAllUserBet = {}								--全体总注
	self.m_lInitUserScore = {}							--原始分数
	self.m_lUserJettonScore = {}
	--庄家信息
	self.m_lBankerScore = 0								--庄家积分
	self.m_wCurrentBanker = 0							--当前庄家
	self.m_cbLeftCardCount = 0							--数量
	self.m_bEnableSysBanker = false						--系统坐庄
	--状态变量
	self.m_bMeApplyBanker = false   					--申请标识
	self.m_bCanPlaceJetton = false						--可以下注

	self.m_nJettonSelect = -1    						--选择筹码
	self.m_lCurrentJetton = 0							--当前筹码

	self.m_lHaveJetton = 0;								--
	self.m_lAllJetton = 0
	self.m_llMaxJetton = 0;
	self.m_llCondition = 0;
	yl.m_bDynamicJoin = false;

	--下注信息
	self.m_tableJettonBtn = {};
	self.m_tableJettonArea = {};
	--上庄列表名
	self.m_labelApplyName = {}
	--下注提示
	self.m_tableJettonNode = {};

	self.m_applyListLayer = nil
	self.m_userListLayer = nil
	self.m_btnListLayer = nil
	--self.m_cardLayer = nil
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
end

function GameViewLayer:gameDataReset(  )
	--资源释放                                                                                     
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameViewLayer.RES_PATH.."game/yaoyaole_gameLayer.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey(GameViewLayer.RES_PATH.."game/yyl_all.png")

	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

	--播放大厅背景音乐
	ExternalFun.playPlazzBackgroudAudio()

	--变量释放
	self.m_actDropIn:release();
	self.m_actDropOut:release();
	if nil ~= self.m_cardLayer then
		self.m_cardLayer:clean()
	end

	yl.m_bDynamicJoin = false;
	self:getDataMgr():removeAllUser()
	self:getDataMgr():clearRecord()
end

function GameViewLayer:getJettonIdx( llScore )
	local idx = 2;
	for i=1,#self.m_pJettonNumber do
		if llScore == self.m_pJettonNumber[i].k then
			idx = self.m_pJettonNumber[i].i;
			break;
		end
	end
	return idx;
end

function GameViewLayer:randomSetJettonPos( nodeArea, jettonSp )
	if nil == jettonSp then
		return;
	end

	local pos = self:getBetRandomPos(nodeArea)
	jettonSp:setPosition(cc.p(pos.x, pos.y));
end

function GameViewLayer:getBetFromPos( wchair )
	if nil == wchair then
		return {x = 0, y = 0}
	end
	local winSize = cc.Director:getInstance():getWinSize()

	--是否是自己
	if self:isMeChair(wchair) then
		--print("从自己发出筹码")
		local tmp = self._csbNode:getChildByName("Node_Player")
		if nil ~= tmp then
			--print("从自己发出筹码")
			local pos = cc.p(tmp:getPositionX()/2, tmp:getPositionY()/2)
			--pos = self.m_spBottom:convertToWorldSpace(pos)
			return {x = pos.x, y = pos.y}
		else
            local posX = self.m_btnPlayerList:getPositionX()
		    local posY = self.m_btnPlayerList:getPositionY()
		    return {x = posX, y = posY}
		end
	else
        local posX = self.m_btnPlayerList:getPositionX()
		local posY = self.m_btnPlayerList:getPositionY()
		return {x = posX, y = posY}
	end
end

function GameViewLayer:getBetAnimation( pos, call_back )
	--print("筹码终点位置1：",pos.x,pos.y)
	pos = self.m_betAreaLayout:convertToNodeSpace(pos)
	--print("筹码终点位置2：",pos.x,pos.y)
	local moveTo = cc.MoveTo:create(BET_ANITIME, cc.p(pos.x + self.addX, pos.y))
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

	local nodeSize = cc.size(nodeArea:getContentSize().width - 80, nodeArea:getContentSize().height - 80);
	local xOffset = math.random()
	local yOffset = math.random()

	local posX = nodeArea:getPositionX() - nodeArea:getAnchorPoint().x * nodeSize.width
	local posY = nodeArea:getPositionY() - nodeArea:getAnchorPoint().y * nodeSize.height
	local pos = cc.p(xOffset * nodeSize.width + posX, yOffset * nodeSize.height + posY)
	--print("pos pos",pos.x,pos.y)
	return pos
end

------
--倒计时节点
function GameViewLayer:createClockNode(csbNode)
	self.m_pClock = cc.Node:create()
	self.m_pClock:setPosition(665,450)
	self:addToRootLayer(self.m_pClock, TAG_ZORDER.CLOCK_ZORDER)

	local nodeClock = csbNode:getChildByName("Node_clock")
	--倒计时
	self.m_pClock.m_atlasTimer = nodeClock:getChildByName("Text_num")
	self.m_pClock.m_atlasTimer:setString("00")

	--提示
	self.m_pClock.m_spTip = nodeClock:getChildByName("Sprite_tips")

    --下注提示
    self.m_pClock.m_spChipTip = nodeClock:getChildByName("Sprite_chipwarn")
    self.m_pClock.m_spChipTip:setVisible(false)
end

function GameViewLayer:updateClock(tag, left)
	self.m_pClock:setVisible(left > 0)

	local str = string.format("%02d", left)
	self.m_pClock.m_atlasTimer:setString(str)
    self.m_pClock.m_spChipTip:setVisible(false)

	if g_var(cmd).kGAMEOVER_COUNTDOWN == tag then
		if 15 == left then
			self:showGameResult(true)
			--改变庄家分数
			self:onChangeBanker()
		elseif 8 == left then				
			--筹码动画
			self:betAnimation()	
		elseif 6 == left then
            --更新路单列表
			self:updateWallBill()
		elseif 4 == left then	
			--更新上庄列表	
			self:refreshApplyList()	
		elseif 3 == left then

		elseif 1 == left then
			self:showGameResult(false)	
			--闪烁停止
			self:jettonAreaBlinkClean()
		end
	elseif g_var(cmd).kGAMEPLAY_COUNTDOWN == tag then
		if 5 >= left then
            self.m_pClock.m_spChipTip:setVisible(true)
        else
            self.m_pClock.m_spChipTip:setVisible(false)
		end
	end

    if left == 5 then
        ExternalFun.playSoundEffect("yaoyaole_game_warn.mp3")
    end
end

function GameViewLayer:showTimerTip(tag)
	tag = tag or -1
	local scale = cc.ScaleTo:create(0.2, 0.0001, 1.0)
	local call = cc.CallFunc:create(function (  )
		local str = string.format("yyl_text_tips%d.png", tag)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)

		self.m_pClock.m_spTip:setVisible(false)
		if nil ~= frame then
			self.m_pClock.m_spTip:setVisible(true)
			self.m_pClock.m_spTip:setSpriteFrame(frame)
		end
	end)
	local scaleBack = cc.ScaleTo:create(0.2,1.0)
	local seq = cc.Sequence:create(scale, call, scaleBack)

	self.m_pClock.m_spTip:stopAllActions()
	self.m_pClock.m_spTip:runAction(seq)
end
------
function GameViewLayer:showStateTips(tag)
    local str = nil
    if tag == 101 then 
        str = "yyl_text_beginchip.png"
    elseif tag == 102 then 
        str = "yyl_text_stopchip.png"
    end
    local spriteTip = self.m_nodeStateTip:getChildByName("Sprite_tips")

	local call1 = cc.CallFunc:create(function (  )
		self.m_nodeStateTip:setVisible(true)
	end)
	local scale = cc.ScaleTo:create(0.2, 0.0001, 1.0)
	local call2 = cc.CallFunc:create(function (  )
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
		if nil ~= frame then
			spriteTip:setVisible(true)
			spriteTip:setSpriteFrame(frame)
		end
	end)
	local scaleBack = cc.ScaleTo:create(0.2,1.0)
	local delayTime = cc.DelayTime:create(1.5)
	local call3 = cc.CallFunc:create(function (  )
		self.m_nodeStateTip:setVisible(false)
	end)
	local seq = cc.Sequence:create(call1,scale, call2, scaleBack,delayTime,call3)
	spriteTip:runAction(seq)
end
------
--下注节点
function GameViewLayer:createJettonNode(area)
    local jettonNode = cc.Node:create()
    local Node_myjetton = self._csbNode:getChildByName("Node_myjetton")

    local totalStr = string.format("jetton_%d_1",area)
    local myStr = string.format("jetton_%d",area)

    local m_TotalJetton = Node_myjetton:getChildByName(totalStr)
    local m_textTotalJetton = m_TotalJetton:getChildByName("Text")
    m_textTotalJetton:setFontName("fonts/round_body.ttf")
    m_TotalJetton:setVisible(false)
    local m_MyJetton = Node_myjetton:getChildByName(myStr)
    local m_textMyJetton = m_MyJetton:getChildByName("Text")
    m_textMyJetton:setFontName("fonts/round_body.ttf")
    m_MyJetton:setVisible(false)

    jettonNode.m_totalBg = m_TotalJetton
    jettonNode.m_myBg = m_MyJetton
    jettonNode.m_textTotalJetton = m_textTotalJetton
	jettonNode.m_textMyJetton = m_textMyJetton

    jettonNode.m_llMyTotal = 0
    jettonNode.m_llAreaTotal = 0   
    jettonNode.m_llOtherTotal = 0

    jettonNode.area = area
    return jettonNode
end

--刷新下注节点
function GameViewLayer:refreshJettonNode( node, my, total, bMyJetton )	

	if true == bMyJetton then
		node.m_llMyTotal = node.m_llMyTotal + my
	else
		node.m_llOtherTotal = node.m_llOtherTotal + my
	end
	--总数
	node.m_llAreaTotal = node.m_llAreaTotal + total

	node:setVisible( node.m_llMyTotal > 0)
	local isShow = node.m_llAreaTotal > 0 or node.m_llMyTotal > 0  

    local score = 0
    if self.m_wBankerUser == self:getParentNode():GetMeChairID() then
    	node.m_textMyJetton:setTextColor(cc.c3b(255,255,0))
    	node.m_myBg:setVisible(false)
    else
    	local score = node.m_llMyTotal
    	node.m_myBg:setVisible(isShow)
    end
    
    if node.m_llMyTotal > 0 then 
        local str = ExternalFun.formatScoreText(node.m_llMyTotal);
        node.m_textMyJetton:setString(str);
        node.m_textMyJetton:setVisible(true)
        node.m_myBg:setVisible(true)
    else
        node.m_textMyJetton:setString(0);
        node.m_textMyJetton:setVisible(false)
        node.m_myBg:setVisible(false)
    end
    
    str = ExternalFun.formatScoreText(node.m_llAreaTotal)
    node.m_textTotalJetton:setString(str);
    node.m_totalBg:setVisible(isShow)
end

function GameViewLayer:reSetJettonNode(node)
    node.m_textMyJetton:setString("0/")
	node.m_myBg:setVisible(false)
	if node.m_textTotalJetton then
		node.m_textTotalJetton:setString("0")
		node.m_totalBg:setVisible(false)
	end

	node.m_llMyTotal = 0
	node.m_llAreaTotal = 0
end
------
return GameViewLayer