local GameViewLayer = class("GameViewLayer",function(scene)
        return display.newLayer()
end)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local module_pre = "game.yule.animalbattle.src"
local cmd = appdf.req(module_pre .. ".models.CMD_Game")
local ZhuanPanAni=appdf.req(module_pre .. ".views.ZhuanPanAni")
local PopupInfoHead = appdf.req(appdf.CLIENT_SRC.."external.PopupInfoHead")
local ApplyListLayer =appdf.req(appdf.GAME_SRC.."yule.animalbattle.src.views.layer.ApplyListLayer")
local g_var = ExternalFun.req_var
local UserListLayer = module_pre .. ".views.layer.UserListLayer"
local GoldRuleLayer = module_pre .. ".views.layer.GoldRuleLayer"
local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")
local BankLayer=appdf.req(module_pre .. ".views.layer.BankLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751
local DEBUG=1
if DEBUG==1 then
	dbg_assert=assert
	dbg_print=print
else
	dbg_assert=function() end
	dbg_print=function() end
end

local enumApply =
{
	"kCancelState",
	"kApplyState",
	"kApplyedState",
	"kSupperApplyed"
}
GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state

local enumTable = 
{
	"BT_MENU",
	"BT_EXIT",
	"BT_HELP",
	"BT_SET",
    "BT_BANK",
	"BT_ROBBANKER",
	"BT_USERLIST",
    "BT_GOLDRULE",
    "BT_CHAT",
	"BT_APPLYBANKER",
	"BT_CANCELAPPLY",
	"BT_CANCELBANKER",
	"BANK_LAYER",
--	"BT_CLOSEBANK",
--	"BT_TAKESCORE",
    "BT_TREND",
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enumTable)

local zorders = 
{
	"CLOCK_ZORDER",
	"SITDOWN_ZORDER",
	"DROPDOWN_ZORDER",
	"DROPDOWN_CHECK_ZORDER",
	"GAMECARD_ZORDER",
	"SETTING_ZORDER",
	"ROLEINFO_ZORDER",
	"BANK_ZORDER",
	"USERLIST_ZORDER",
	"GAMERS_ZORDER",	
	"ENDCLOCK_ZORDER",
	"HELP_ZORDER"
}
local TAG_ZORDER = ExternalFun.declarEnumWithTable(1, zorders)
GameViewLayer.RES_PATH  = "game/yule/animalbattle/res/"
function GameViewLayer:ctor(scene)
	self._scene = scene
    local rootLayer, csbNode = ExternalFun.loadRootCSB("MainScene.csb",self)
    self.csbNode=csbNode
	self.m_rootLayer = rootLayer
    self.lscore = self._scene:GetMeUserItem().lScore
    self.m_nTableID = self._scene:GetMeUserItem().wTableID
	self.m_tabPlayerList={}
	self.turnTableRecords={}
    self.m_bankerUser = nil
    self.m_userListLayer = nil
    self.m_GoldRuleLayer = nil
    self._bankLayer = nil
    self.recordView=nil
    self.m_clickBanker = false
    self.m_aniWarm = false
    self.bIsJettonForMe = false
    self.m_lAreaTotalScore = 0
	self.noteNumBtns={}
	self.betBtns={}
    self.m_jettonAreaPos={}
    self.m_LightSprite = {}
    self.m_jettonLight = {}
    self.m_coinCount = {}
    self.m_winlist = {}
    self.brightRects={}             --闪烁亮框
    self.m_pEndAniPos = {}
    self.m_pEndAniPos[1] = cc.p(204, 268)
    self.m_pEndAniPos[2] = cc.p(215, 261)
    self.m_pEndAniPos[3] = cc.p(285, 257)
    self.m_pEndAniPos[4] = cc.p(201, 257)
    self.m_pEndAniPos[5] = cc.p(248, 265)
    self.m_pEndAniPos[6] = cc.p(248, 265)
    self.m_pEndAniPos[7] = cc.p(248, 279)
    self.m_pEndAniPos[8] = cc.p(243, 263)
    self.m_pEndAniPos[9] = cc.p(236, 247)
    self.m_pEndAniPos[10] = cc.p(237, 268)
    self.m_pEndAniPos[11] = cc.p(237, 268)
    self.m_pEndAniPos[12] = cc.p(243, 268)
    self.m_pNodeDown = self.csbNode:getChildByName("m_pNodeDown")
    self.m_pNodeBanker = self.csbNode:getChildByName("m_pNodeBanker")
    self.m_pNodeBtn = self.csbNode:getChildByName("m_pNodeBtn")
    self.m_pNodeTop = self.csbNode:getChildByName("m_pNodeTop")
  
    --庄家列表
    self.m_applyListLayer = nil
    self.m_applyListLayer = ApplyListLayer:create(self)
    self.m_applyListLayer:setLocalZOrder(4)
    self:addChild(self.m_applyListLayer)
    
    --上庄列表人数
    self.m_pGoBankerCount = self.m_pNodeBanker:getChildByName("txt_gobanker_count")
    self.m_pGoBankerCount:setFontName(appdf.FONT_FILE)

    --连庄次数
    self.m_pContinueBankBottom = self.m_pNodeBanker:getChildByName("img_numbottom")
    self.m_pContinueBankCount = self.m_pContinueBankBottom:getChildByName("txt_continueBanker")
    self.m_pContinueBankCount:setFontName(appdf.FONT_FILE)

    --用户列表
	self._scene:getDataMgr():initUserList(self._scene:getUserList())

	--当前庄家用户
	self.m_wBankerUser = yl.INVALID_CHAIR

	for i=1,7 do --5个赌注大小按钮
    	self.noteNumBtns[i]=appdf.getNodeByName(self.csbNode,"betnum"..i)
        if i == 6 then
            self.noteNumBtns[i].m_noteNum=5000000
        elseif i==7 then
            self.noteNumBtns[i].m_noteNum=math.pow(10,i)
        else
            self.noteNumBtns[i].m_noteNum=math.pow(10,i+1)
        end
    	self.noteNumBtns[i]:setTag(i)
        self.m_jettonAreaPos[i] = cc.p(self.noteNumBtns[i]:getPosition())
    	self.noteNumBtns[i]:addClickEventListener(function(sender) 
                                                     self:showJettonLight(sender)
                                                     self._scene:OnNoteSwitch(sender) end)
    end

   --初始化轉盤
   self.m_animal = self.csbNode:getChildByName("m_pNodeAnimal")
--   self.m_animal:removeFromParent()
--   self:addChild(self.m_animal,2)

   for i=1,28 do
        self.m_LightSprite[i]=self.m_animal:getChildByName("animal_light"..i)
   end
    
    --设置头像
    self.m_mySelf = self.m_pNodeDown:getChildByName("animalbattle_bg_myself")
    
    self.m_pTextPlayerWinLose = self.m_mySelf:getChildByName("m_pTextWinLose")

    local useritem = self._scene:GetMeUserItem()
    local pHeadImage = PopupInfoHead:createNormal(useritem, 90)
    pHeadImage:setPosition(1,-2)
    pHeadImage:setAnchorPoint(display.CENTER)
    local sprite = display.newSprite("#userinfo_head_frame.png")
    sprite:setScale(0.546)
    sprite:setPosition(1,-2)
    sprite:setAnchorPoint(display.CENTER)
    sprite:addTo(self.m_mySelf:getChildByName("node_head"))
    pHeadImage:addTo(self.m_mySelf:getChildByName("node_head"))
    
    --设置昵称
    self.m_mySelf:getChildByName("txt_user_name"):setString(useritem.szNickName)
    self.m_mySelf:getChildByName("txt_user_name"):setFontName(appdf.FONT_FILE)
    self.m_mySelf:getChildByName("txt_total_score"):setFontName(appdf.FONT_FILE)
    self.m_mySelf:getChildByName("txt_coin"):setFontName(appdf.FONT_FILE)

    self.betBtnPoses={}
    self.betAllArea = self.csbNode:getChildByName("panel_btn_jetton")
    self.betAllArea:setSwallowTouches(false)

    self.m_pNodeJetton = self.csbNode:getChildByName("m_pNodeJetton")

    for i=1,11 do --11个动物下注按钮 --betBtns[i]对应
    	local btn=self.betAllArea:getChildByName("Button_"..(i))
--        btn:removeFromParent()
--        self.betAllArea:addChild(btn,3)
		btn.m_kind=i
        self.brightRects[i] = btn:getChildByName("img_clickarea"..(i))
        self.brightRects[i]:setVisible(false)
        self.brightRects[i].m_bVisible=false
        btn:getChildByName("txt_jettontotal_"..(i)):setVisible(false)
        btn:getChildByName("txt_jetton_"..(i)):setVisible(false)
        
        btn:getChildByName("txt_jettontotal_"..(i)):setFontName(appdf.FONT_FILE)
        btn:getChildByName("txt_jetton_"..(i)):setFontName(appdf.FONT_FILE)
        
        btn:getChildByName("txt_jettontotal_"..(i)):enableOutline(cc.c4b(10, 43, 65, 255), 2)
        btn:getChildByName("txt_jetton_"..(i)):enableOutline(cc.c4b(24, 45, 14, 255), 2)
		self.betBtns[i]=btn
		btn:addTouchEventListener(function(sender, eventType) 
            ExternalFun.btnEffect(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                self.brightRects[sender.m_kind]:setVisible(true)
            elseif eventType == ccui.TouchEventType.ended then
                self.brightRects[sender.m_kind]:setVisible(false)
                self._scene:OnPlaceJetton(sender) 
            elseif eventType == ccui.TouchEventType.canceled then
                self.brightRects[sender.m_kind]:setVisible(false)
		    end
        end)
		self.betBtnPoses[i]=cc.p( btn:getPosition() )
    end

    self.continueBtn=appdf.getNodeByName(self.csbNode,"continuebtn")
    self.continueBtn:addTouchEventListener(
        function(sender, eventType)
            ExternalFun.btnEffect(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self._scene:OnLastPlaceJetton()
		    end
        end
    )
    --local countBg=appdf.getNodeByName(self.csbNode,"countbg")
    self.m_pNodeRecord=self.csbNode:getChildByName("m_pNodeRecord")

	self:updateTotalScore(0)
	self:updateCurrentScore(0)

   --筹码点击光圈
   for i=1,7  do
     self.m_jettonLight[i] = display.newSprite("#animalbattle_img_chipslight.png")
           :setVisible(false)
           :addTo(self)
   end

   -- 初始化结算界面
   self.m_pPanelWinlose = self.csbNode:getChildByName("m_pPanelWinlose")
   self.m_pPanelWinlose:removeFromParent()
   self:addChild(self.m_pPanelWinlose,4)
   self.m_pPanelWinlose:setVisible(false)

   --总下注界面
   
   self.m_pNodeBanker = self.csbNode:getChildByName("m_pNodeBanker")
   self.m_pTextBankerWinLose = self.m_pNodeBanker:getChildByName("m_pTextWinLose")
   self.m_startjetton = self.m_pNodeBanker:getChildByName("panel_jettonmessage")
   self.timeTextImg = self.m_pNodeBanker:getChildByName("panel_startmessage")
   self.timeForGame = self.timeTextImg:getChildByName("txt_time")
   self.timeForTime = self.timeTextImg:getChildByName("txt_time1")
   self.timeType = self.timeTextImg:getChildByName("img_timetype")

   self.m_stopjetton = self.m_pNodeBanker:getChildByName("panel_stopmessage")
   self.m_stopjetton:removeFromParent()
   self:addChild(self.m_stopjetton,3)

   self.m_changebanker = self.m_pNodeBanker:getChildByName("panel_changemessage")
   self.m_changebanker:removeFromParent()
   self:addChild(self.m_changebanker,3)

   self:initBankerInfo()    --初始化庄家信息
   
    --按钮列表
	local function btnEvent( sender, eventType )
        ExternalFun.btnEffect(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender)
		end
	end
    ----------------------------------抢庄界面----------------------------------
	self.m_pBtnApplyBanker = self.m_pNodeBtn:getChildByName("m_pBtnApplyBanker")
	self.m_pBtnApplyBanker:setTag(TAG_ENUM.BT_APPLYBANKER)
	self.m_pBtnApplyBanker:addTouchEventListener(btnEvent)
	self.m_pBtnApplyBanker:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

	self.m_pBtnCancelBanker = self.m_pNodeBtn:getChildByName("m_pBtnCancelBanker")
	self.m_pBtnCancelBanker:setTag(TAG_ENUM.BT_CANCELAPPLY)
	self.m_pBtnCancelBanker:addTouchEventListener(btnEvent)
	self.m_pBtnCancelBanker:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

	self.m_pBtnCancelApply = self.m_pNodeBtn:getChildByName("m_pBtnCancelApply")
	self.m_pBtnCancelApply:setTag(TAG_ENUM.BT_CANCELBANKER)
	self.m_pBtnCancelApply:addTouchEventListener(btnEvent)
	self.m_pBtnCancelApply:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

    self:setBtnBankerType(APPLY_STATE.kCancelState)

    ----------------------------------玩家界面----------------------------------
	local m_pBtnUserList = self.m_pNodeBtn:getChildByName("btn_playlist")
	m_pBtnUserList:setTag(TAG_ENUM.BT_USERLIST)
	m_pBtnUserList:addTouchEventListener(btnEvent)
	m_pBtnUserList:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)
    m_pBtnUserList:setVisible(false)

    --------------------------------聊天界面----------------------------------
	self.m_pBtnUserChat = self.m_pNodeBtn:getChildByName("btn_chat")
	self.m_pBtnUserChat:setTag(TAG_ENUM.BT_CHAT)
	self.m_pBtnUserChat:addTouchEventListener(btnEvent)
	self.m_pBtnUserChat:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

    --------------------------------彩金规则界面----------------------------------
	self.m_pBtnGoldRule = self.m_pNodeTop:getChildByName("btn_goldrule")
	self.m_pBtnGoldRule:setTag(TAG_ENUM.BT_GOLDRULE)
	self.m_pBtnGoldRule:addTouchEventListener(btnEvent)
	self.m_pBtnGoldRule:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

    ----------------------------------下拉界面----------------------------------
    self.m_pNodeDownMenu = self.csbNode:getChildByName("panel_down")
    self.m_pNodeDownMenu:removeFromParent()
    self:addChild(self.m_pNodeDownMenu,3)
	self.m_pNodeDownMenu:setScale(0)
	self.m_pNodeDownMenu:setLocalZOrder(TAG_ZORDER.DROPDOWN_ZORDER)

    self.m_pBtnDown = self.m_pNodeBtn:getChildByName("btn_down")
    self.m_pBtnDown:addTouchEventListener(btnEvent)
	self.m_pBtnDown:setTag(TAG_ENUM.BT_MENU)
	self.m_pBtnDown:setLocalZOrder(TAG_ZORDER.DROPDOWN_CHECK_ZORDER)

    --遮罩
	local m_pBtnChade = self.m_pNodeDownMenu:getChildByName("Button_1")
	m_pBtnChade:setTag(TAG_ENUM.BT_MENU)
	m_pBtnChade:addTouchEventListener(btnEvent)

    --帮助
	local m_pBtnHelp = self.m_pNodeDownMenu:getChildByName("m_pBtnHelp")
	m_pBtnHelp:setTag(TAG_ENUM.BT_HELP)
	m_pBtnHelp:addTouchEventListener(btnEvent)

	--设置
	local m_pBtnSet = self.m_pNodeDownMenu:getChildByName("m_pBtnSet")
	m_pBtnSet:setTag(TAG_ENUM.BT_SET)
	m_pBtnSet:addTouchEventListener(btnEvent)

    --银行
	local m_pBtnBank = self.m_pNodeDownMenu:getChildByName("m_pBtnBank")
	m_pBtnBank:setTag(TAG_ENUM.BT_BANK)
	m_pBtnBank:addTouchEventListener(btnEvent)

	--离开
	local m_pBtnBack = self.m_pNodeDownMenu:getChildByName("m_pBtnBack")
	m_pBtnBack:setTag(TAG_ENUM.BT_EXIT)
	m_pBtnBack:addTouchEventListener(btnEvent)

    --走势按钮
--    local trend = self.csbNode:getChildByName("btn_trend")
--    trend:setTag(TAG_ENUM.BT_TREND)
--    trend:addTouchEventListener(btnEvent)
   
   --**********************************************   结算界面   **********************************************--
    self.m_winlistBanker = self.m_pPanelWinlose:getChildByName("panel_banker")
    self.m_winlistBanker:getChildByName("user_name"):setFontName(appdf.FONT_FILE)     -- 结算界面庄家名字
    --self.winlose:getChildByName("panel_banker_score"):getChildByName("winlose"):setFontName(appdf.FONT_FILE) -- 结算界面庄家分数
   
    self.m_winlistSelf = self.m_pPanelWinlose:getChildByName("panel_myself")
    self.m_winlistSelf:getChildByName("user_name"):setFontName(appdf.FONT_FILE)          -- 结算界面玩家名字
    --self.winlose:getChildByName("panel_myself_score"):getChildByName("myselfwinlose"):setFontName(appdf.FONT_FILE)-- 结算界面玩家分数
    
    for i=1,5  do
        self.m_winlist[i] = self.m_pPanelWinlose:getChildByName(string.format("winlist%d",i ))
        self.m_winlist[i]:getChildByName(string.format("score_winlist%d",i )):setFontName(appdf.FONT_FILE)  -- 结算界面前三分数
        self.m_winlist[i]:getChildByName(string.format("name_winlist%d",i )):setFontName(appdf.FONT_FILE)   -- 结算界面前三名字
    end
    
    --appdf.getNodeByName(self.csbNode,"countbg"):getChildByName("txt_time"):setFontName(appdf.FONT_FILE)
    
    self.csbNode:getChildByName("txt_visible_time1"):setFontName(appdf.FONT_FILE)   -- 金鲨时间
    self.csbNode:getChildByName("txt_visible_time2"):setFontName(appdf.FONT_FILE)   -- 银鲨时间
--    self.m_pNodeBanker:getChildByName("txt_total_score"):setFontName(appdf.FONT_FILE) -- 总下注

    --注册node事件
    ExternalFun.registerNodeEvent(self)
    --播放背景音乐
    ExternalFun.setBackgroundAudio("sound_res/animalbattle_bgm.mp3")
end

--初始化庄家信息
function GameViewLayer:initBankerInfo()
    self.m_pIconBankerBG = self.m_pNodeBanker:getChildByName("node_banker_head")
	self.m_pTextBankerName = self.m_pNodeBanker:getChildByName("txt_user_name")    --庄家姓名
	self.m_pTextBankerGold = self.m_pNodeBanker:getChildByName("txt_bankercoin")    --庄家金币
    self.m_pImgBankerGold = self.m_pNodeBanker:getChildByName("Image_2")    --庄家金币图标

    self.m_pTextBankerName:setFontName(appdf.FONT_FILE)
    self.m_pTextBankerGold:setFontName(appdf.FONT_FILE)
end

function GameViewLayer:showJettonLight(sender)
    if self.m_cbGameStatus~=cmd.GS_PLACE_JETTON then
		return
	end
    for i=1,7  do
        self.m_jettonLight[i]:setVisible(false)
        self.noteNumBtns[i]:stopAllActions()
        self.noteNumBtns[i]:setScale(1)
    end
    sender:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.8,0.9),cc.ScaleTo:create(0.8,1))))
    self.m_jettonLight[sender:getTag()]:setPosition(sender:getPosition())
    self.m_jettonLight[sender:getTag()]:setVisible(true)
    self.m_jettonLight[sender:getTag()]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2.5, 360))))
end

function GameViewLayer:addToRootLayer( node , zorder)
	if nil == node then
		return
	end

	self.m_rootLayer:addChild(node)
	node:setLocalZOrder(zorder)
end

function GameViewLayer:brightRectBlink(index,showtime)
	self.brightRects[index]:setVisible(true)
	self.brightRects[index].m_bVisible=true
	self.brightRects[index]:runAction(cc.Sequence:create(
			cc.Blink:create(showtime,math.ceil(showtime)),
			cc.CallFunc:create(function() self.brightRects[index]:setVisible(false) self.brightRects[index].m_bVisible=false end)))
end

function GameViewLayer:onButtonClickedEvent(tag,ref)
	ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
        self:OnDownMenuSwitchAnimate()
        self._scene:onKeyBack()
	elseif tag == TAG_ENUM.BT_USERLIST then
		if nil == self.m_userListLayer then
			self.m_userListLayer = g_var(UserListLayer):create()
			self:addChild(self.m_userListLayer, 5)
		end
		local userList = self:getDataMgr():getUserList()		
		self.m_userListLayer:refreshList(userList)
   elseif tag == TAG_ENUM.BT_GOLDRULE then
		if nil == self.m_GoldRuleLayer then
			self.m_GoldRuleLayer = g_var(GoldRuleLayer):create()
			self:addChild(self.m_GoldRuleLayer, 5)
        else
            self.m_GoldRuleLayer:onShow()
		end
	elseif tag == TAG_ENUM.BT_APPLYBANKER then
		self:applyBanker(APPLY_STATE.kCancelState)
    elseif tag == TAG_ENUM.BT_CHAT then
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
    elseif tag == TAG_ENUM.BT_CANCELAPPLY then
		self:applyBanker(APPLY_STATE.kApplyState)
    elseif tag == TAG_ENUM.BT_CANCELBANKER then
		self:applyBanker(APPLY_STATE.kApplyedState)
    elseif tag == TAG_ENUM.BT_MENU then
        if self.m_pNodeDownMenu:getNumberOfRunningActions() > 0 then
            return
        end
        
        self:OnDownMenuSwitchAnimate()
    elseif tag == TAG_ENUM.BT_HELP then
        --self._scene._scene:popHelpLayer2(123,0)
        if nil == self.layerHelp then
            self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
            self.layerHelp:addTo(self)
            self.layerHelp:setLocalZOrder(TAG_ZORDER.HELP_ZORDER)
        else
            self.layerHelp:onShow()
        end
        self:OnDownMenuSwitchAnimate()
    elseif tag == TAG_ENUM.BT_SET then
        self:OnDownMenuSwitchAnimate()
        if self.settingLayer == nil then 
            self:addChild(SettingLayer:create(self),100)
        else
            self.settingLayer:onShow()
        end
    elseif tag == TAG_ENUM.BT_BANK then
        local rom = GlobalUserItem.GetRoomInfo()
		if nil ~= rom then
			if rom.wServerType ~= yl.GAME_GENRE_GOLD then
				showToast(cc.Director:getInstance():getRunningScene(), "当前房间禁止操作银行!", 1)
				return
			end
		end	

        self:OnDownMenuSwitchAnimate()
	    if 0 == GlobalUserItem.tabAccountInfo.cbInsureEnabled then
   	 	    showToast(cc.Director:getInstance():getRunningScene(), "初次使用，请先开通银行！", 1)
    	    return 
	    end
        if nil == self._bankLayer then
            self._bankLayer = BankLayer:create(self) 
            self:addChild(self._bankLayer,10)
        else
            self._bankLayer:onShow()
        end
        self:OnDownMenuSwitchAnimate()
--    elseif tag == TAG_ENUM.BT_TREND then
--        self.recordbg:setVisible(not self.recordbg:isVisible())
    end
end

function GameViewLayer:OnDownMenuSwitchAnimate()
    if self.m_pNodeDownMenu:getScaleX() == 1 then
        self.m_pNodeDownMenu:runAction(cc.ScaleTo:create(0.2, 0))
    elseif self.m_pNodeDownMenu:getScaleX() == 0 then
        self.m_pNodeDownMenu:runAction(cc.ScaleTo:create(0.2, 1))
    end
end

function GameViewLayer:setBankerInfo(wBankerChair,bankerScore,cbBankerTime)
    local useritem = nil
    if wBankerChair then
        useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,wBankerChair)
        if useritem then
            self.m_pContinueBankBottom:setVisible(true)
            self.m_pContinueBankCount:setString(string.format("%d",cbBankerTime))
            self.m_pNodeBanker:getChildByName("txt_user_name"):setString(useritem.szNickName)
            self.m_pNodeBanker:getChildByName("txt_bankercoin"):setString(useritem.lScore)   
        end
    else
        self.m_pContinueBankBottom:setVisible(false)
        self.m_pNodeBanker:getChildByName("txt_user_name"):setString("无人坐庄")
        self.m_pNodeBanker:getChildByName("txt_bankercoin"):setString(0)   
    end
end

function GameViewLayer:setSharkComeTime(goldSharkTime ,sharkTime)
    if goldSharkTime == 0 then 
        self.csbNode:getChildByName("txt_visible_time1"):setString("暂时还未出现")
    else
        self.csbNode:getChildByName("txt_visible_time1"):setString(os.date("%H小时%M分%S秒", goldSharkTime))
    end

    if sharkTime == 0 then 
        self.csbNode:getChildByName("txt_visible_time2"):setString("暂时还未出现")
    else
        self.csbNode:getChildByName("txt_visible_time2"):setString(os.date("%H小时%M分%S秒", sharkTime))
    end
end

function GameViewLayer:getPlayerList()
	return self._scene:getPlayerList()
end

function GameViewLayer:AddTurnTableRecord(betResultId)
	local len = #self.turnTableRecords
    if len < cmd.RECORD_COUNT_MAX then --少于25条记录	
        table.insert(self.turnTableRecords,betResultId)
    else
        --删除第一条记录
        table.remove(self.turnTableRecords,1)
        table.insert(self.turnTableRecords,betResultId)
    end
--	if len > 10 * cmd.RECORD_COUNT_MAX then         --10可以换成任意大于1的数字
--		for i = 1, cmd.RECORD_COUNT_MAX - 1 do      --删除old记录，只保留最近的cmd.RECORD_COUNT_MAX-1个
--			self.turnTableRecords[i] = self.turnTableRecords[i + 1 + len - cmd.RECORD_COUNT_MAX]
--		end

--		for i = cmd.RECORD_COUNT_MAX, len do
--			self.turnTableRecords[cmd.RECORD_COUNT_MAX] = nil
--		end
--	end
--	table.insert(self.turnTableRecords,betResultId)
end

function GameViewLayer:updateShowTurnTableRecord(resttime)
	local recordTable=self.turnTableRecords
	local len=#recordTable
    local lv_tab = self.m_pNodeRecord:getChildByName("recordList")
    lv_tab:removeAllChildren()
    lv_tab:setScrollBarEnabled( false )    -- 隐藏滚动条

    if len == 0 or recordTable ==  nil then
        return
    end
    local item = self.csbNode:getChildByName("panel_frame")
    local rec = nil
    for i = 1, #recordTable do  
        rec = recordTable[#recordTable - i + 1]
        local itemClone = item:clone()
        local item1= itemClone:getChildByTag(173)
        local image = string.format("animalbattle_img_%d.png", rec)
        item1:loadTexture(image,1)
        local itemImg = itemClone:getChildByTag(177)
        if  i == 1 then
            itemImg:runAction(cc.Sequence:create(cc.Blink:create(resttime, resttime*2),cc.CallFunc:create(function() end)))
        else
            itemImg:setVisible(false)
        end
        
        lv_tab:pushBackCustomItem(itemClone)
        lv_tab:jumpToTop()
    end
end

function GameViewLayer:refreshUserList(  )
	if nil ~= self.m_userListLayer and self.m_userListLayer:isVisible() then
		local userList = self:getDataMgr():getUserList()		
		self.m_userListLayer:refreshList(userList)
	end
end

function  GameViewLayer:showJieSuanView(resultKind,showtime,pGameEnd)
    if resultKind < 0 or resultKind > 11 or showtime <= 0 then 
        return 
    end

    local jsLayer = cc.Layer:create()
    jsLayer:setScale(0)
    --jsLayer:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    jsLayer:setContentSize(cc.size(yl.DESIGN_WIDTH, yl.DESIGN_HEIGHT))
    jsLayer:setAnchorPoint(cc.p(0.5, 0.5))
    jsLayer:setCascadeOpacityEnabled(true)
    jsLayer:setOpacity(0)
    jsLayer:addTo(self)
    self.jsLayer = jsLayer

    local light = display.newSprite("#animalbattle_img_slight.png")
    light:setCascadeOpacityEnabled(true)
    light:setOpacity(0)
	light:addTo(jsLayer)
	light:setPosition(yl.DESIGN_WIDTH/2-22,yl.DESIGN_HEIGHT/2+40)
	
    display.newSprite("#animalbattle_img_end"..resultKind..".png")
		:addTo(jsLayer)
		:setPosition(yl.DESIGN_WIDTH/2-22,yl.DESIGN_HEIGHT/2+50)
    
    --闪烁区域
    if resultKind==cmd.JS_YIN_SHA or resultKind==cmd.JS_JIN_SHA then
        self:brightRectBlink(9, showtime)
    else
        if resultKind<=3 then 
            self:brightRectBlink(10,showtime)
        elseif resultKind<=7 then
            self:brightRectBlink(11,showtime)
        end
        local tbAnimaRealIndex = {2,3,4,5,6,7,8,1}
        self:brightRectBlink(tbAnimaRealIndex[resultKind+1],showtime)
    end

    if resultKind==cmd.JS_YIN_SHA then
        local shark = display.newSprite("#animalbattle_txt_mul8.png")
			:addTo(jsLayer)
		local sharkMul = cc.LabelAtlas:create(24+pGameEnd.cbShaYuAddMulti,"animalbattle_num_1.png",46, 64,string.byte("0"))
            :setAnchorPoint(0,0.5)
			:addTo(jsLayer)
        shark:setPosition(display.center.x - sharkMul:getContentSize().width/2,300)
		sharkMul:setPosition(shark:getPositionX()+shark:getContentSize().width/2,300)
	else
		display.newSprite("#animalbattle_txt_mul"..resultKind..".png")
			:addTo(jsLayer)
			:setPosition(yl.DESIGN_WIDTH/2-22,300)
	end
    local time = 1
    local bIsWuRen = false
    local useritem = self:getDataMgr():getChairUserList()[pGameEnd.wBankerUser + 1]
    if useritem == nil and  self._scene:getBankerStatus() == false then
        time = showtime
        bIsWuRen = true
    end

    light:runAction(cc.Sequence:create(cc.FadeIn:create(1),cc.RotateBy:create(4, 360)))
	jsLayer:runAction(
		cc.Sequence:create(
            cc.Spawn:create(cc.FadeIn:create(0.2),cc.ScaleTo:create(0.2, 1)),
            cc.DelayTime:create(1.6),
            cc.Spawn:create(cc.FadeOut:create(0.2),cc.ScaleTo:create(0.2,0)),
			cc.CallFunc:create(function() 
                    if resultKind == cmd.JS_YIN_SHA then
                        self:showAnims(2)
                    else
                        if bIsWuRen == false then
                            self:runJettonToBankerAni(resultKind,showtime,pGameEnd)
                        end
                    end
			end),
            cc.RemoveSelf:create()
        )
    )
end
 
 function GameViewLayer:showAllLoseAni(resultKind,showtime,pGameEnd)
    local imgAllWin = display.newSprite("#animalbattle_img_end9.png")
        :setScale(0)
        :setOpacity(255)
		:addTo(self)
		:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+50)
        
	local tempText = display.newSprite("#animalbattle_txt_mul9.png")
        :addTo(self)
		:setPosition(yl.DESIGN_WIDTH/2-20,yl.DESIGN_HEIGHT/2-140)

    local imgAllWin1 = display.newSprite("#animalbattle_img_end9.png")
		:addTo(self)
        :setVisible(false)
		:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+50)
    local imgAllWin2 = display.newSprite("#animalbattle_img_end9.png")
		:addTo(self)
        :setVisible(false)
		:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+50)
    
    imgAllWin:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1), cc.DelayTime:create(1), cc.RemoveSelf:create()))
    
    tempText:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeOut:create(1),
            cc.RemoveSelf:create()
        )
    )

    imgAllWin1:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.Show:create(),
            cc.Spawn:create(
                cc.ScaleTo:create(1, 2.5), 
                cc.FadeOut:create(1)
            ),
            cc.RemoveSelf:create()
        )
    )

    imgAllWin2:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.Show:create(),
            cc.Spawn:create(
                cc.ScaleTo:create(0.5, 1.75), 
                cc.FadeOut:create(0.5)
            ),
            cc.CallFunc:create(function() 
                self:runJettonToBankerAni(resultKind,showtime,pGameEnd)
            end),
            cc.RemoveSelf:create()
        )
    )
end                                                         

function GameViewLayer:showAllWinAni(resultKind,showtime,pGameEnd)
    local imgAllWin = display.newSprite("#animalbattle_img_end10.png")
        :setScale(0)
        :setCascadeOpacityEnabled(true)
        :setOpacity(0)
        :setAnchorPoint(cc.p(0.5, 0))
		:addTo(self)
		:setPosition(yl.DESIGN_WIDTH/2-20,yl.DESIGN_HEIGHT/2-100)
        
	local tempText = display.newSprite("#animalbattle_txt_mul10.png")
        :addTo(self)
		:setPosition(yl.DESIGN_WIDTH/2-20,yl.DESIGN_HEIGHT/2-140)

    local reward_box_frames = {}

    for i = 1, 12 do
        local frameName =string.format("animalbattle_ani_allwin%d.png",i)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(reward_box_frames, frame)
    end

    local reward_box_ani = cc.Animation:createWithSpriteFrames(reward_box_frames, 0.1) 

    local WinAniAllWin = display.newSprite("#animalbattle_ani_allwin1.png")
    WinAniAllWin:setVisible(false)
    WinAniAllWin:ignoreAnchorPointForPosition(false)
    WinAniAllWin:setAnchorPoint(cc.p(0.5, 0))
    WinAniAllWin:setPosition(yl.DESIGN_WIDTH/2+10,yl.DESIGN_HEIGHT/2-170)
    WinAniAllWin:addTo(self)
    imgAllWin:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.3),
                cc.ScaleTo:create(0.3,1.2)
            ),
            cc.DelayTime:create(0.05),
            cc.ScaleTo:create(0.05, 1, 1.4),
            cc.DelayTime:create(0.05),
            cc.ScaleTo:create(0.05, 0.5),
            cc.RemoveSelf:create()
        )
    )

    tempText:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeOut:create(1),
            cc.RemoveSelf:create()
        )
    )

    WinAniAllWin:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.Show:create(),
            cc.Animate:create(reward_box_ani),
            cc.CallFunc:create(function() 
                self:runJettonToBankerAni(resultKind,showtime,pGameEnd)
            end),
            cc.RemoveSelf:create()
        )
    )
end

function GameViewLayer:runWinGoldAni(resultKind,pGameEnd)
    --遮罩
    local btcallback = function(ref, tType)
        if type == ccui.TouchEventType.ended then
        end
    end
    local touchEnable = ccui.Layout:create()
    touchEnable:setContentSize(cc.size(display.width, display.height))
    touchEnable:setAnchorPoint(cc.p(0.5, 0.5))
    touchEnable:setPosition(cc.p(display.width/2, display.height/2))
    touchEnable:addTouchEventListener(btcallback)
    touchEnable:setTouchEnabled(true)
    touchEnable:setSwallowTouches(true)
    self:addChild(touchEnable,10)

    --恭喜动画
    local Win = display.newSprite("#animalbattle_bg_explosion machine2.png")
        :setPosition(display.center)
        :setScaleX(0)
        :setLocalZOrder(5)
        :addTo(self)
    local WinLight = display.newSprite("#animalbattle_img_slight.png")
        :setLocalZOrder(-2)
        :setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2 - 15)
        :addTo(Win)
    local WinTitle = display.newSprite("#animalbattle_txt_explosionmachine2.png")
        :setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2 + 10)
        :setScale(0.3)
        :addTo(Win)

    local WinUser = display.newSprite("#animalbattle_bg_explosion machine3.png")
        :setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2 -55)
        :addTo(Win)
    
    --彩金数字
    local str = string.format("%d",pGameEnd.lBonusGold)
    local lenNumber = string.len(str)
    local numMul = 8
    local tbWinText = {}
    for key = 1, lenNumber do
        local WinText = cc.LabelAtlas:_create("0", GameViewLayer.RES_PATH.."animalbattle_font_baojinum.png", 68, 83, string.byte("0"))
            :setLocalZOrder(-1)
            :setScale(numMul)
            :setCascadeOpacityEnabled(true)
            :setOpacity(0)
            :setName(string.format("num_%d",key))
            :setAnchorPoint(cc.p(0.5, 0.5))
            :setString(""..string.sub(str,key,key))
            :addTo(Win)
        tbWinText[key] = WinText
    end

    local function showGoldScore() 
        local offsetX = 0
        local offsetY = 0
        local iCenterAddOne = 1
        if lenNumber%2 == 0 then
            iCenterAddOne = 0
        end
        for i =lenNumber, 1,-1 do
            offsetX = -2+2*(math.random(1,3)-1)
            offsetY = -2+2*(math.random(1,3)-1)
            tbWinText[i]:setPosition(cc.p(Win:getContentSize().width/2 + 68*(lenNumber - iCenterAddOne)/2 - 68 * (lenNumber - i),Win:getContentSize().height))
            tbWinText[i]:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1*(lenNumber-i +1)),
                cc.Spawn:create(
                    cc.FadeIn:create(0.2),
                    cc.ScaleTo:create(0.2,1),
                    cc.MoveTo:create(0.2, cc.p(tbWinText[i]:getPositionX(),Win:getContentSize().height - 200))
                ),
                cc.MoveBy:create(0.05, cc.p(offsetX,offsetY)),
                cc.MoveBy:create(0.05, cc.p(-offsetX*2,-offsetY*2)),
                cc.MoveBy:create(0.05, cc.p(offsetX,offsetY))
            ))
        end
    end
    showGoldScore()
    
    --金币动画
    local reward_box_frames = {}
    for i = 1, 7 do
        local frameName =string.format("animalbattle_ani_coin%d.png",i)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(reward_box_frames, frame)
    end
    local WinAniCoin = display.newSprite("#animalbattle_ani_coin1.png")
    local reward_box_ani = cc.Animation:createWithSpriteFrames(reward_box_frames, 0.1) 
    WinAniCoin:setPosition(Win:getContentSize().width/2,Win:getContentSize().height+30)
    WinAniCoin:setLocalZOrder(-3)
    WinAniCoin:addTo(Win)
    WinAniCoin:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.Animate:create(reward_box_ani))) 
    WinLight:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1),cc.RotateBy:create(2.5, 360)))
    WinTitle:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.ScaleTo:create(0.3, 1)))
    WinUser:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.ScaleTo:create(0.3, 1)))
    Win:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.4, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function(ref)
			                    Win:setVisible(false)
                                Win:removeSelf()
                                touchEnable:removeFromParent()
                                self:showWinLoseScore(resultKind,4,pGameEnd)
		                    end))) 
end

function GameViewLayer:showWinLoseScore(resultKind,showtime,pGameEnd)
    local scoreStr = tostring(math.abs(pGameEnd.lBankerScore))
    if pGameEnd.lBankerScore >= 0 then
        scoreStr = "." .. scoreStr
        self.m_pTextBankerWinLose:setProperty(scoreStr, "animalbattle_font_num1.png", 27, 36, "*")
    else
        scoreStr = "/" .. scoreStr
        self.m_pTextBankerWinLose:setProperty(scoreStr, "animalbattle_font_num2.png", 27, 36, "*")
    end
    
    scoreStr = tostring(math.abs(pGameEnd.lUserScore))
    if pGameEnd.lUserScore > 0 then
        scoreStr = "." .. scoreStr
        self.m_pTextPlayerWinLose:setProperty(scoreStr, "animalbattle_font_num1.png", 27, 36, "*")
    elseif pGameEnd.lUserScore < 0 then
        scoreStr = "/" .. scoreStr
        self.m_pTextPlayerWinLose:setProperty(scoreStr, "animalbattle_font_num2.png", 27, 36, "*")
    else
        self.m_pTextPlayerWinLose:setProperty(scoreStr, "animalbattle_font_num1.png", 27, 36, "*")
    end
    
    self.m_pTextBankerWinLose:setVisible(true)
    self.m_pTextBankerWinLose:setOpacity(0)
    self.m_pTextBankerWinLose:setPosition(cc.p(755, 550))
    self.m_pTextBankerWinLose:runAction(cc.Sequence:create(
    cc.Spawn:create(cc.FadeIn:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 50))), 
    cc.DelayTime:create(2),
    cc.Spawn:create(cc.FadeOut:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 50))),cc.CallFunc:create(function()
        self:showAllJieSuanView(resultKind,showtime,pGameEnd)
    end)))
    
    self.m_pTextPlayerWinLose:setVisible(true)
    self.m_pTextPlayerWinLose:setOpacity(0)
    self.m_pTextPlayerWinLose:setPosition(cc.p(214, 65))
    self.m_pTextPlayerWinLose:runAction(cc.Sequence:create(
    cc.Spawn:create(cc.FadeIn:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 50))), 
    cc.DelayTime:create(2),
    cc.Spawn:create(cc.FadeOut:create(0.5), cc.MoveBy:create(0.5, cc.p(0, 50)))))
end

function GameViewLayer:showAllJieSuanView(resultKind,showtime,pGameEnd)
    self.m_pPanelWinlose:setScale(0)
    self.m_pPanelWinlose:setCascadeOpacityEnabled(true)
    self.m_pPanelWinlose:setOpacity(0)
    self.m_pPanelWinlose:setVisible(true)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("animalbattle_img_end%d.png",resultKind))
    self.m_pPanelWinlose:getChildByName("img_anikind"):setSpriteFrame(frame)

    self.m_pPanelWinlose:getChildByName("img_anikind"):setPosition(self.m_pEndAniPos[resultKind+1])
    self.m_pPanelWinlose:getChildByName("img_baoji"):setVisible(pGameEnd.bSystemBaoJi)
    
    self.m_pPanelWinlose:getChildByName("btn_jsclose"):addTouchEventListener(
        function( sender, eventType )
            ExternalFun.btnEffect(sender, eventType)
		    if eventType == ccui.TouchEventType.ended then
			    self.m_pPanelWinlose:setVisible(false)
		    end
        end)

    --倍数
    local shark = self.m_pPanelWinlose:getChildByName("img_anikind_mul")
    if resultKind==cmd.JS_YIN_SHA then
        local aniFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("animalbattle_txt_mul8.png")
        shark:setSpriteFrame(aniFrame)
        if self.sharkMul == nil then
            self.sharkMul = cc.LabelAtlas:create(24+pGameEnd.cbShaYuAddMulti,"animalbattle_num_1.png",46, 64,string.byte("0"))
			    :addTo(self.m_pPanelWinlose)
        end
        self.sharkMul:setString(24+pGameEnd.cbShaYuAddMulti)
		self.sharkMul:setPosition(shark:getPositionX()+shark:getContentSize().width/2 - 15,shark:getPositionY()-15)
	else 
        if self.sharkMul ~= nil then
            self.sharkMul:removeFromParent()
            self.sharkMul = nil
        end
        local aniFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("animalbattle_txt_mul%d.png",resultKind))
        shark:setSpriteFrame(aniFrame)
	end
    

    --前五
    for key, var in pairs(pGameEnd.wFrontWinThreeUser[1]) do 
        local useritem = self:getDataMgr():getChairUserList()[var + 1]
        self.m_winlist[key]:getChildByName(string.format("name_winlist%d",key )):setString(useritem == nil and "暂无排名" or ExternalFun.GetShortName(useritem.szNickName,12,10))
    end
    for key, var in pairs(pGameEnd.lFrontWinThreeScore[1]) do  
        local str = string.format("%d",var) 
        self.m_winlist[key]:getChildByName(string.format("score_winlist%d",key )):setString(str)
        if var == 0 then
            self.m_winlist[key]:getChildByName(string.format("score_winlist%d",key )):setString("")
            self.m_winlist[key]:getChildByName(string.format("name_winlist%d",key )):setString("暂无排名")
        end
    end

    --庄家信息
    local useritem = self:getDataMgr():getChairUserList()[pGameEnd.wBankerUser + 1]
    if useritem == nil then
         self.m_winlistBanker:getChildByName("user_name"):setString("系统坐庄")
    else
         self.m_winlistBanker:getChildByName("user_name"):setString(ExternalFun.GetShortName(useritem.szNickName,12,10))
    end
    
    --庄家胜利失败分数
    if self.loseScore ~= nil then
        self.loseScore:setString("")
    end
    if self.winScore ~= nil then
        self.winScore:setString("")
    end
    self.m_winlistBanker:getChildByName("winlose"):setString("")
    if pGameEnd.lBankerScore>0 then
        if self.winScore == nil then
            self.winScore = cc.LabelAtlas:_create(".0000000", GameViewLayer.RES_PATH.."animalbattle_font_num1.png", 27, 35, string.byte("*"))
                :setPosition(self.m_winlistBanker:getChildByName("winlose"):getPosition())
                :setAnchorPoint(cc.p(1, 0.5))
                :addTo(self.m_winlistBanker)
        end
        self.winScore:setString("."..pGameEnd.lBankerScore)
    elseif pGameEnd.lBankerScore == 0 then
        self.m_winlistBanker:getChildByName("winlose"):setString("0")
    else
        if self.loseScore == nil then
            self.loseScore = cc.LabelAtlas:_create("/0000000", GameViewLayer.RES_PATH.."animalbattle_font_num2.png", 27, 36, string.byte("*"))
                :setPosition(self.m_winlistBanker:getChildByName("winlose"):getPosition())
                :setAnchorPoint(cc.p(1, 0.5))
                :addTo(self.m_winlistBanker)
        end
        self.loseScore:setString("/"..math.abs(pGameEnd.lBankerScore))
    end

    --我的信息
    local useritem = self._scene:GetMeUserItem()
    self.m_winlistSelf:getChildByName("user_name"):setString(useritem == nil and "" or ExternalFun.GetShortName(useritem.szNickName,12,10))
    self.m_winlistSelf:getChildByName("myselfwinlose"):setString("")
    
    --我的胜利失败分数
    if self.loseScoreSelf ~= nil then
        self.loseScoreSelf:setString("")
    end
    if self.winScoreSelf ~= nil then
        self.winScoreSelf:setString("")
    end
    if self.isJettonImg ~= nil then
        self.isJettonImg:setVisible(false)
    end
    if pGameEnd.lUserScore>0 then
        if self.winScoreSelf == nil then
            self.winScoreSelf = cc.LabelAtlas:_create(".0000000", GameViewLayer.RES_PATH.."animalbattle_font_num1.png", 27, 35, string.byte("*"))
                :setPosition(self.m_winlistSelf:getChildByName("myselfwinlose"):getPosition())
                :setAnchorPoint(cc.p(1, 0.5))
                :addTo(self.m_winlistSelf)
        end
        self.winScoreSelf:setString("."..pGameEnd.lUserScore)
    elseif pGameEnd.lUserScore==0 and self.bIsJettonForMe == false then
        if self.isJettonImg == nil then
            self.isJettonImg = display.newSprite("#animalbattle_txt_nulljetton.png")
                :setPosition(cc.p(self.m_winlistSelf:getChildByName("myselfwinlose"):getPositionX()-80, self.m_winlistSelf:getChildByName("myselfwinlose"):getPositionY()))
                :addTo(self.m_winlistSelf)
        end
        self.isJettonImg:setVisible(true)
    else
        if self.loseScoreSelf == nil then
            self.loseScoreSelf = cc.LabelAtlas:_create("/0000000", GameViewLayer.RES_PATH.."animalbattle_font_num2.png", 27, 36, string.byte("*"))
                :setPosition(self.m_winlistSelf:getChildByName("myselfwinlose"):getPosition())
                :setAnchorPoint(cc.p(1, 0.5))
                :addTo(self.m_winlistSelf)
        end
        self.loseScoreSelf:setString("/"..math.abs(pGameEnd.lUserScore))
    end

    --开始动画
    local winloseTitle = self.m_pPanelWinlose:getChildByName("img_title")
    local winloseBottom = self.m_pPanelWinlose:getChildByName("img_bottom") 
    self.m_pPanelWinlose:runAction(cc.Sequence:create(
                            cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2)),
                            cc.DelayTime:create(showtime),
                            cc.Spawn:create(cc.ScaleTo:create(0.2, 0),cc.FadeOut:create(0.2)),
		                    cc.CallFunc:create(function(ref)
                                self:setSharkComeTime(pGameEnd.dwGoldSharkTime,pGameEnd.dwSharkTime)
		                    end)
                 ))
    self.m_pPanelWinlose:getChildByName("winloselight"):runAction(cc.RotateBy:create(showtime, 360)) 
end

function GameViewLayer:enableBetBtns(bEnable) 
	for i=1,11 do
		self.betBtns[i]:setEnabled(bEnable)
	end
end

function GameViewLayer:enableAllBtns(bEnable)
    if bEnable then
        self.betAllArea:setVisible(true)
    end

	for i=1,7 do
        if self.m_jettonLight[i]:isVisible() == true  then
             self.m_jettonLight[i]:stopAllActions()
             self.m_jettonLight[i]:setVisible(false)
             self.noteNumBtns[i]:stopAllActions()
             self.noteNumBtns[i]:setScale(1)
        end
        self:setBtnEnabled(self.noteNumBtns[i], bEnable)
	end
	for i=1,11 do
		self.betBtns[i]:setEnabled(bEnable)
	end
	self.continueBtn:setEnabled(bEnable)
end

function GameViewLayer:updateBtnLight()
    if self.noteNumBtns[1]:isTouchEnabled() and self.noteNumBtns[1]:isEnabled() then
        self:showJettonLight(self.noteNumBtns[1])
        self._scene:OnNoteSwitch(self.noteNumBtns[1])
    end
end

function GameViewLayer:setBtnEnabled(btn, isEnabled)
    btn:setEnabled(isEnabled)
end

function GameViewLayer:enable_NoteNum_Clear_ContinueBtn(bEnable)
	for i=1,7 do
        if self.m_jettonLight[i]:isVisible() == true  then
            self.m_jettonLight[i]:stopAllActions()
             self.m_jettonLight[i]:setVisible(false)
             self.noteNumBtns[i]:stopAllActions()
             self.noteNumBtns[i]:setScale(1)
        end
        self:setBtnEnabled(self.noteNumBtns[i], bEnable)
	end
	self.continueBtn:setEnabled(bEnable)
end

function GameViewLayer:disableNoteNumBtns(startIndex)
    local countEnabled = 0;
	for i=startIndex,7 do
        countEnabled = countEnabled + 1
        if self.m_jettonLight[i]:isVisible() == true  then
            self.m_jettonLight[i]:stopAllActions()
            self.m_jettonLight[i]:setVisible(false)
            self.noteNumBtns[i]:stopAllActions()
            self.noteNumBtns[i]:setScale(1)
        end
        self:setBtnEnabled(self.noteNumBtns[i], false)
	end
    if countEnabled == 7 then
        self.continueBtn:setEnabled(false)
    end
end

function GameViewLayer:runJettonAni(indexJetton ,indexTager, isMeChair)
    local coin = display.newSprite("#animalbattle_img_schips"..indexJetton..".png")
    local btnPosX = self.betBtns[indexTager]:getPositionX() - self.betBtns[indexTager]:getContentSize().width/2 + 22 + math.random(0, self.betBtns[indexTager]:getContentSize().width-44)
    local btnPosY = self.betBtns[indexTager]:getPositionY() - self.betBtns[indexTager]:getContentSize().height/2 + 32 + math.random(0, self.betBtns[indexTager]:getContentSize().height-64)
    local pos = cc.p(0, 0)
    if isMeChair then
        local headPos = self.m_mySelf:getChildByName("node_head")
        pos = cc.p(headPos:getPositionX(), headPos:getPositionY())
        self.bIsJettonForMe = true
        coin:setName("myselfCoin")
    else
        pos = cc.p(-200 + math.random(0, 1)*(yl.WIDTH+400), math.random(50, yl.HEIGHT/2))
        coin:setName("otherCoin")
    end
    coin:setPosition(pos)
    table.insert(self.m_coinCount, coin)
    self.m_pNodeJetton:addChild(coin,2)
    coin:runAction(cc.MoveTo:create(0.3,cc.p(btnPosX,btnPosY)))
end

function GameViewLayer:runJettonToBankerAni(resultKind,showtime,pGameEnd)
    function showSendMySelf()
        local pos = cc.p(0, 0)
        local gap = 1.0/#self.m_coinCount
        local index = 0
        for k, v in pairs(self.m_coinCount) do
            if k == #self.m_coinCount then
                if v:getName() == "myselfCoin" and pGameEnd.lUserScore > 0 then
                    local headPos = self.m_mySelf:getChildByName("node_head")
                    pos = cc.p(headPos:getPosition())
                    v:runAction(cc.Sequence:create(
                        cc.DelayTime:create(gap*index),
                        cc.Spawn:create(cc.MoveTo:create(0.3,pos),cc.FadeIn:create(0.3)),
                        cc.CallFunc:create(function(ref)
                            ref:setVisible(false)
                            if pGameEnd.bSystemBaoJi then
                                self:runWinGoldAni(resultKind,pGameEnd)
                            else
                                self:showWinLoseScore(resultKind,showtime,pGameEnd)    
                            end
                        end)))
                elseif v:getName() == "otherCoin" then
                    if math.random(0,2)>1 then
                        pos = cc.p(0, math.random(140,yl.HEIGHT))
                    else
                        pos = cc.p(yl.WIDTH, math.random(0,yl.HEIGHT))
                    end
                    v:runAction(cc.Sequence:create(
                        cc.DelayTime:create(gap*index),
                        cc.Spawn:create(cc.MoveTo:create(0.3,pos),cc.FadeIn:create(0.3)),
                        cc.CallFunc:create(function(ref)
                            ref:setVisible(false)
                            if pGameEnd.bSystemBaoJi then
                                self:runWinGoldAni(resultKind,pGameEnd)
                            else
                                self:showWinLoseScore(resultKind,showtime,pGameEnd)    
                            end
                        end)))
                else
                    v:setVisible(false)
                    if pGameEnd.bSystemBaoJi then
                        self:runWinGoldAni(resultKind,pGameEnd)
                    else
                        self:showWinLoseScore(resultKind,showtime,pGameEnd)    
                    end
                end
            else
                if v:getName() == "myselfCoin" and pGameEnd.lUserScore > 0 then
                    local headPos = self.m_mySelf:getChildByName("node_head")
                    pos = cc.p(headPos:getPosition())
                    v:runAction(cc.Sequence:create(
                        cc.DelayTime:create(gap*index),
                        cc.Spawn:create(cc.MoveTo:create(0.3,pos),cc.FadeIn:create(0.3)),
                        cc.CallFunc:create(function(ref)
                            ref:setVisible(false)
                        end)))
                elseif v:getName() == "otherCoin" then
                    if math.random(0,2)>1 then
                        pos = cc.p(0, math.random(140,yl.HEIGHT))
                    else
                        pos = cc.p(yl.WIDTH, math.random(0,yl.HEIGHT))
                    end
                    v:runAction(cc.Sequence:create(
                        cc.DelayTime:create(gap*index),
                        cc.Spawn:create(cc.MoveTo:create(0.3,pos),cc.FadeIn:create(0.3)),
                        cc.CallFunc:create(function(ref)
                            ref:setVisible(false)
                        end)))
                else
                    v:setVisible(false)
                end
            end
            index = index + 1
        end  
    end
    
    if #self.m_coinCount == 0 then
        if pGameEnd.bSystemBaoJi then
            self:runWinGoldAni(resultKind,pGameEnd)
        else
            self:showWinLoseScore(resultKind,showtime,pGameEnd)    
        end
    else
        local gap = 1.0/#self.m_coinCount
        local index = 0
        for k, v in pairs(self.m_coinCount) do
            if k == #self.m_coinCount then
                v:runAction(cc.Sequence:create(
                    cc.DelayTime:create(gap*index),
                    cc.Spawn:create(cc.MoveTo:create(0.3,cc.p(self.m_pIconBankerBG:getPositionX(),self.m_pIconBankerBG:getPositionY())),cc.FadeOut:create(0.3)),
                    cc.CallFunc:create(function()
                        showSendMySelf()
                end))) 
            else
                v:runAction(cc.Sequence:create(
                cc.DelayTime:create(gap*index),
                cc.Spawn:create(cc.MoveTo:create(0.3,cc.p(self.m_pIconBankerBG:getPositionX(),self.m_pIconBankerBG:getPositionY())), cc.FadeOut:create(0.3))
                ))         
            end 
            index = index + 1      
        end
    end
end

function GameViewLayer:enableNoteNumBtns(endIndex)
	for i=1,endIndex do
        if self.m_jettonLight[i]:isVisible() == true  then
            self.m_jettonLight[i]:stopAllActions()
             self.m_jettonLight[i]:setVisible(false)
             self.noteNumBtns[i]:stopAllActions()
             self.noteNumBtns[i]:setScale(1)
        end
        self:setBtnEnabled(self.noteNumBtns[i], true)
	end
end

local leftAligned=0
local centerAligned=1
local rightAligned=2
local totalscoreDigitKind=1
local curscoreDigitKind=2
local digitSpriteConfig={ --数字图片配置  --彩金池靠右对齐，其余居中对齐  --dis表示数字间间距
	{name="scorenum",filepath="score.png",w=17,h=20,dis=0,align=centerAligned},   --总得分 ,可能为负数
	{name="curscorenum",filepath="score.png",w=17,h=20,dis=0,align=centerAligned},
}



function GameViewLayer:updateNumberPic(kind,bg,pos,number)--左对齐则pos为左边界位置，中心对齐则pos为中心位置
	dbg_assert(bg)
	dbg_assert(not tolua.isnull(bg))
	print("updateNumberPic kind: ",kind)

	local numbersNode=bg:getChildByName(digitSpriteConfig[kind].name)
	if numbersNode and not tolua.isnull(numbersNode) then
		numbersNode:removeSelf()
	end

	if nil==number then return end
	
	local function getDigits(number)
		dbg_assert(number)
		local sign=number>=0 and 1 or -1
		if number<0 then number=-number end
		local digits={}
		if number==0 then
			digits[1]=0
			return digits
		end
		while number~=0 do
			local residue=number%10
			number=math.floor(number/10)
			table.insert(digits,residue)
		end
		if sign<0 then table.insert(digits,'-') end  --else table.insert(digits,'+') 
		return digits
	end

	local function newDigitSp(filepath,digit,w,h) --digit单个数字0-9
		if digit=='+' then 
			digit=10 
		elseif digit=='-' then 
			digit=11 
		end
		return cc.Sprite:create( filepath,cc.rect(w*digit,0,w,h) )
	end

	local digits=getDigits(number) --将number的每个位上数字存入table
	dbg_assert(#digits>0)

	local dsc=digitSpriteConfig[kind]
	local node=cc.Node:create() --对于一个size为0的node，setAnchorPoint(,)会对其子节点的显示有影响吗?
	node:addTo(bg):setName(digitSpriteConfig[kind].name)
	
	for i=1,#digits do
		print(i,digits[i])
		local sp= newDigitSp(dsc.filepath,digits[i],dsc.w,dsc.h)
		sp:addTo(node)
		sp:setAnchorPoint(0,0)
		sp:setPosition( (dsc.dis+dsc.w)*(#digits-i),0 )
	end

	local totalWidth= (#digits) * (dsc.dis+dsc.w)
	if dsc.align==centerAligned then
		node:setPosition(pos.x-totalWidth/2,pos.y)
	elseif dsc.align==rightAligned then
		node:setPosition( pos.x-totalWidth,pos.y)
	elseif dsc.align==leftAligned then
		node:setPosition(pos)
	end
end



function GameViewLayer:updateTotalBets(tabBets)
    local totalScore = 0
    local len = #tabBets
	for i=1,cmd.AREA_COUNT-1 do
		--print(i..":  "..(tabBets[i] or 0))
		if tabBets[i] == nil or len == 0 then
			self:updateTotalBet(i,nil)
		else
			self:updateTotalBet(i,tabBets[i])
            totalScore = totalScore+tabBets[i]
		end
	end
    self.m_lAreaTotalScore = totalScore 
   
    if totalScore == 0 then
        self.m_pNodeBanker:getChildByName("txt_total_score"):setString("")
        self.m_pNodeBanker:getChildByName("img_wait_jetton"):setVisible(true)
    else
        self.m_pNodeBanker:getChildByName("img_wait_jetton"):setVisible(false)
        self.m_pNodeBanker:getChildByName("txt_total_score"):setString(totalScore)
    end
    
end

function GameViewLayer:updateMyBets(tabBets)
	for i=1,cmd.AREA_COUNT-1 do
		if tabBets[i]==0 then
			self:updateMyBet(i,nil)
		else
			self:updateMyBet(i,tabBets[i])
		end
	end
end

function GameViewLayer:updateTotalBet(kind,num)
	local bg=self.betBtns[kind]
    if num == nil or num == 0 then
        bg:getChildByName("txt_jettontotal_"..kind):setVisible(false)
        bg:getChildByName("txt_jettontotal_"..kind):setString("")
    else
        bg:getChildByName("txt_jettontotal_"..kind):setVisible(true)
        bg:getChildByName("txt_jettontotal_"..kind):setString(num)
    end
end

function GameViewLayer:updateMyBet(kind,num)
	local bg=self.betBtns[kind]
    if num == nil then
        bg:getChildByName("txt_jetton_"..kind):setVisible(false)
        bg:getChildByName("txt_jetton_"..kind):setString("")
    elseif num>0 then
        bg:getChildByName("txt_jetton_"..kind):setVisible(true)
        bg:getChildByName("txt_jetton_"..kind):setString(num)
    end
end

function GameViewLayer:playBackgroundMusic()
end

function GameViewLayer:updateCurrentScore(score)
   --self.winlose:getChildByName("panel_myself_score"):getChildByName("winlose"):setString(score)
end

function GameViewLayer:updateTotalScore(score)
    self.m_mySelf:getChildByName("txt_total_score"):setString(ExternalFun.formatScoreText(score))
end

function GameViewLayer:updateAsset(assetNum)
    self.m_mySelf:getChildByName("txt_coin"):setString(ExternalFun.formatScoreText(assetNum))
end

function GameViewLayer:updateCountDown(clockTime)
    if self.m_cbGameStatus==cmd.GAME_STATUS_FREE then
        for i=1,#self.brightRects do
			if true==self.brightRects[i].m_bVisible then
				self.brightRects[i]:stopAllActions()
				self.brightRects[i]:setVisible(false)
				self.brightRects[i].m_bVisible=false
			end
		end

        self.m_startjetton:setVisible(false)
        self.m_stopjetton:setVisible(false)
        self.timeForGame:setString(clockTime)
        self.timeType:loadTexture("animalbattle_txt_freetime.png",1)
	elseif self.m_cbGameStatus==cmd.GS_PLACE_JETTON then
        self.timeForGame:setString(clockTime)
        self.timeType:loadTexture("animalbattle_txt_freejettontime.png",1)
        if clockTime ~= nil and clockTime <= 1 then
            self.m_aniWarm = false
            self.m_startjetton:setVisible(false)
        elseif self.m_aniWarm == false then
            self.m_aniWarm = true
            self.m_stopjetton:setVisible(false)
            self:showStartJetton()
        end
    elseif self.m_cbGameStatus==cmd.GS_GAME_END then
        self.timeForGame:setString(clockTime)
        self.timeType:loadTexture("animalbattle_txt_endtime.png",1)
    end

    self.timeForTime:setString(clockTime)
    self.timeForTime:setVisible(true)
    self.timeForTime:setScale(1)
    self.timeForTime:setOpacity(255)
    self.timeForTime:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 2), cc.FadeOut:create(0.5)))
end

function GameViewLayer:updateStorage(num) --彩金池
    appdf.getNodeByName(self.csbNode,"AtlasLabel_Gold"):setString(num)
end

function GameViewLayer:enableBtns(bEnable)
	for i=1,7 do
        if self.m_jettonLight[i]:isVisible() == true  then
             self.m_jettonLight[i]:stopAllActions()
             self.m_jettonLight[i]:setVisible(false)
             self.noteNumBtns[i]:stopAllActions()
             self.noteNumBtns[i]:setScale(1)
        end
        self:setBtnEnabled(self.noteNumBtns[i], bEnable)
	end
	self.continueBtn:setEnabled(bEnable)
end

function GameViewLayer:SetGameStatus(gameStatus) --设置显示得分
	self.m_cbGameStatus=gameStatus
    self:setBtnEnabled(self.continueBtn, gameStatus == cmd.GAME_STATUS_PLAY)
    if gameStatus == cmd.GAME_STATUS_FREE then
        for k, v in pairs(self.m_coinCount) do
            v:removeFromParent()         
        end
        self.m_coinCount = {}
        self.bIsJettonForMe = false
        self.betAllArea:setVisible(false)
		self._scene:clearBets()
    end
end

function  GameViewLayer:removeFirstOpeningAni( )
	if self.firstOpeningAni and not tolua.isnull(self.firstOpeningAni) then
		self.firstOpeningAni:removeSelf()
		self.firstOpeningAni=nil
	end
end

function GameViewLayer:OnUpdataClockView(clockViewChair,clockTime)

	local t=os.time()

	self.cbTimeLive=clockTime
	self:updateCountDown(clockTime)
	if self.m_cbGameStatus==cmd.GS_PLACE_JETTON and clockTime<5 then
		ExternalFun.playSoundEffect("animalbattle_time_waring.mp3")
	end

	if (self.m_cbGameStatus ~= cmd.GS_GAME_END or (clockTime>0 and clockTime<=3)) then
		if self.jsLayer and not tolua.isnull(self.jsLayer) then
			if self.testShowJieSuan~=1 then self.jsLayer:removeSelf() end
		end

		if self.zhuanPanAni and not tolua.isnull(self.zhuanPanAni) then
            print("cccccccccccccccccccccccccccccc")
			self.zhuanPanAni:removeSelf()
		end
	end

	local dt
	dt=self.lastupdataT==nil and 0 or t-self.lastupdataT
	if dt<=1 
	  or (self._lastStatus==cmd.GS_PLACE_JETTON and self.m_cbGameStatus==cmd.GS_PLACE_JETTON and dt<self._lastTimeLive) 
	  or (self._lastStatus==cmd.GS_GAME_END and self.m_cbGameStatus==cmd.GS_GAME_END and dt<self._lastTimeLive)
	then
		--donothing
	else
		print("dt: ",dt)
		--self._scene:clearBets()
	end

	if self._lastStatus==cmd.GS_GAME_END  and dt>=self._lastTimeLive then --and self._lastTimeLive>0
		self:updateCurrentScore(0)
	end

	self.lastupdataT=t
	self._lastStatus=self.m_cbGameStatus
	self._lastTimeLive=clockTime
end

function GameViewLayer:GameOver(pGameEnd,cumulativeScore) --转盘结束后更新记录 self.tabRecords
    local nTurnTableTarget = pGameEnd.cbTableCardArray[1]
    self.cumulativeScore   = cumulativeScore
    self.pGameEnd          = pGameEnd
 	self.nTurnTableTarget  = nTurnTableTarget
 	                   
	local deltaT        = 5     -- 连续两次开奖动画间隔时间
	local dur           = 14    --  转盘时间
	self.durations      = {}
    self.durations[1]   = dur
    self.durations[2]   = 0
 	self.totalSec       = 20
	self.bTurnTwoTime   = 0     -- bTurnTwoTime为1时，开奖时间为30秒

	if nTurnTableTarget[2] >= 1 and nTurnTableTarget[2] <= 28 then 
		self.durations[1]   = dur - 2
		self.durations[2]   = dur - 2
		self.totalSec       = 32       -- 10
        self.bTurnTwoTime   = 1 
    end

	self:showAnims(1)
    self:showStopJetton()
end

function GameViewLayer:showAnims(i)
	if self.m_cbGameStatus ~= cmd.GS_GAME_END then 
        return 
    end
    
	local resultKind = ZhuanPanAni.zhuanpanPosToKind(self.nTurnTableTarget[i])
    local startIndex = 1
	self:AddTurnTableRecord(resultKind)    -- 添加路单记录,但没有刷新视图显示
    if i == 2 then
        startIndex = 19
    end
	self.zhuanPanAni = ZhuanPanAni:create(self, startIndex, self.nTurnTableTarget[i], self.durations[i], self.totalSec)
    self.m_animal:addChild(self.zhuanPanAni)
	local function callback(resttime)
        if self.m_cbGameStatus ~= cmd.GS_GAME_END then 
            return 
        end
        
        if resultKind == cmd.JS_TONG_PEI or resultKind == cmd.JS_TONG_SHA then 
  	        ExternalFun.playSoundEffect("animalbattle_sound_"..(resultKind)..".wav")
        else 
            ExternalFun.playSoundEffect("animalbattle_sound_"..(resultKind)..".mp3")
        end

        if resultKind == cmd.JS_TONG_SHA then
            self:showAllWinAni(resultKind, resttime, self.pGameEnd)
        elseif resultKind == cmd.JS_TONG_PEI then
            self:showAllLoseAni(resultKind, resttime, self.pGameEnd)
        else
            self:showJieSuanView(resultKind, resttime, self.pGameEnd)
        end

        self:updateShowTurnTableRecord(resttime)            -- 刷新路单视图
		self:updateTotalScore(self.cumulativeScore)         -- 刷新玩家成绩
		self:updateAsset(self._scene:GetMeScore())          -- 刷新玩家分数
	end

	self.zhuanPanAni:ZhuanPan(callback)
end

function GameViewLayer:BigAnimal(index)
    self.m_animal:getChildByName("animal"..index):runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.1, 1)))
end

function GameViewLayer:onExit()
	
	for i=8,11 do
		cc.Director:getInstance():getTextureCache():removeTextureForKey("js"..i..".png")
	end
	cc.Director:getInstance():getTextureCache():removeTextureForKey("animalbattle_bg.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()

end

function GameViewLayer:OnUpdateUser(viewId, userItem, bLeave)
    local myViewId=self._scene:SwitchViewChairID(self._scene:GetMeChairID()) 
    if viewId==myViewId then
    	return 
    end
	if bLeave then
		self.m_tabPlayerList[viewId]=nil
		print(viewId.." leave")
	else
		if userItem then
			print("viewId", viewId)
			self.m_tabPlayerList[viewId]=userItem
		end
	end
end

--申请庄家
function GameViewLayer:onGetApplyBanker( )
	if self:isMeChair(self._scene.cmd_applybanker.wApplyUser) then
		self.m_enApplyState = APPLY_STATE.kApplyState
        self:setBtnBankerType(APPLY_STATE.kApplyState)
	end

	self:refreshApplyList()
end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1]
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function GameViewLayer:getDataMgr( )
	return self._scene:getDataMgr()
end

--取消申请庄家
function GameViewLayer:onGetCancelBanker(  )
	if self:isMeChair(self._scene.cmd_cancelbanker.wCancelUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
        self:setBtnBankerType(APPLY_STATE.kCancelState)
	end
	
	self:refreshApplyList()
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
    local userList = self:getDataMgr():getApplyBankerUserList()	
    self.m_pGoBankerCount:setString(string.format("%d人排队",#userList))
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then	
		self.m_applyListLayer:refreshList(userList)
	end
end

--上庄状态
function GameViewLayer:applyBanker( state )
	if state == APPLY_STATE.kCancelState then
		self._scene:sendApplyBanker()		
	elseif state == APPLY_STATE.kApplyState then
		self._scene:sendCancelApply()
	elseif state == APPLY_STATE.kApplyedState then
		self._scene:sendCancelApply()		
	end
end

function GameViewLayer:getApplyState(  )
	return self.m_enApplyState
end

function GameViewLayer:setBtnBankerType(tag)
    self.m_pBtnApplyBanker:setVisible(tag == APPLY_STATE.kCancelState)
    self.m_pBtnCancelApply:setVisible(tag == APPLY_STATE.kApplyState)
    self.m_pBtnCancelBanker:setVisible(tag == APPLY_STATE.kApplyedState)
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		self.m_applyListLayer:refreshBtnState()
	end
end

--刷新庄家信息
function GameViewLayer:onChangeBanker( wBankerUser, lBankerScore, bEnableSysBanker)
	print("更新庄家数据:" .. wBankerUser .. " coin =>" .. lBankerScore)

	--上一个庄家是自己，且当前庄家不是自己，标记自己的状态
	if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
        self:setBtnBankerType(APPLY_STATE.kCancelState)
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
            self.m_pContinueBankBottom:setVisible(false)
            local head = self.m_pIconBankerBG:getChildByTag(199)
            local sprite = self.m_pIconBankerBG:getChildByTag(198)
            if head ~= nil then
                head:removeFromParent()
                sprite:removeFromParent()
            end
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1]
			if nil ~= userItem then
				nickstr = userItem.szNickName 
                self.m_pContinueBankBottom:setVisible(true)
                --self.m_pContinueBankCount:setString("0")
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
            self.m_pContinueBankBottom:setVisible(false)
            local head = self.m_pIconBankerBG:getChildByTag(199)
            local sprite = self.m_pIconBankerBG:getChildByTag(198)
            if head ~= nil then
                head:removeFromParent()
                sprite:removeFromParent()
            end
		else
			local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1]
			if nil ~= userItem then
				nickstr = userItem.szNickName 
                self.m_pContinueBankBottom:setVisible(true)
               -- self.m_pContinueBankCount:setString("0")
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
        local sprite = self.m_pIconBankerBG:getChildByTag(198)
        if head ~= nil then
            head:removeFromParent()
            sprite:removeFromParent()
        end

        local userItem = self:getDataMgr():getChairUserList()[wBankerUser + 1]
		if userItem ~= nil then
			head = PopupInfoHead:createNormal(userItem,62)
			head:enableHeadFrame(false)
			--head:enableInfoPop(false, cc.p(0, 0), cc.p(0, 0))
			head:setTag(199)
            sprite = display.newSprite("#userinfo_head_frame.png")
            sprite:setTag(198)
            sprite:setScale(0.38)
            self.m_pIconBankerBG:addChild(sprite)
            self.m_pIconBankerBG:addChild(head)
        end
    elseif true == bEnableSysBanker then    
        local head = self.m_pIconBankerBG:getChildByTag(199)
        local sprite = self.m_pIconBankerBG:getChildByTag(198)
        if head ~= nil then
            head:removeFromParent()
            sprite:removeFromParent()
        end

        head = display.newSprite("#userinfo_head_0.png")
        head:setScale(0.38)
		head:setTag(199)
        sprite = display.newSprite("#userinfo_head_frame.png")
        sprite:setTag(198)
        sprite:setScale(0.38)
        self.m_pIconBankerBG:addChild(sprite)
        self.m_pIconBankerBG:addChild(head)
    end

	--庄家金币
--	local str = ExternalFun.formatNumberThousands(lBankerScore)
--	if string.len(str) > 11 then
--		str = string.sub(str, 1, 7) .. "..."
--	end
    
    self.m_lBankerScore = lBankerScore
	self.m_pTextBankerGold:setString(ExternalFun.formatScoreText(self.m_lBankerScore))
    self.m_pImgBankerGold:setVisible(true)
    
	if true == bEnableSysBanker then --允许系统坐庄
		if yl.INVALID_CHAIR == wBankerUser then
	        self.m_pTextBankerGold:setString("")
            self.m_pImgBankerGold:setVisible(false)
        end
    end
end

function GameViewLayer:reSetUserInfo(  )
	self.m_scoreUser = 0
	local myUser = self._scene:GetMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore
	end	
--	local str = ExternalFun.numberThousands(self.m_scoreUser)
--	if string.len(str) > 11 then
--		str = string.sub(str,1,11) .. "..."
--	end
    
    self:updateAsset(self.m_scoreUser)
    self.m_mySelf:getChildByName("txt_user_name"):setString(myUser.szNickName)
end


function GameViewLayer:onGetUserScore( item )
	--自己
	if item.dwUserID == GlobalUserItem.dwUserID then
       self:reSetUserInfo()
    end

    --庄家
    if self.m_wBankerUser == item.wChairID then
    	--庄家金币
		local str = ExternalFun.formatNumberThousands(item.lScore)
		if string.len(str) > 11 then
			str = string.sub(str, 1, 9) .. "..."
		end
		self.m_pTextBankerGold:setString(ExternalFun.formatScoreText(item.lScore))
        self.m_pImgBankerGold:setVisible(true)
        
		if yl.INVALID_CHAIR == self.m_wBankerUser then
	        self.m_pTextBankerGold:setString("")
            self.m_pImgBankerGold:setVisible(false)
        end
    end
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
	if self._bankLayer and not tolua.isnull(self._bankLayer) then
		self._bankLayer:onBankSuccess()
	end
end

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

function GameViewLayer:showPopWait( )
	self._scene:showPopWait()
end

function GameViewLayer:dismissPopWait( )
	self._scene:dismissPopWait()
end


function GameViewLayer:showStartJetton()
    self.m_startjetton:stopAllActions()
    self.m_startjetton:setVisible(true)
    self.m_startjetton:setPosition(cc.p(-700, 375))
    self.m_startjetton:setOpacity(0)
    self.m_startjetton:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.5), 
                cc.MoveTo:create(0.5, cc.p(645, 375))
            ), 
            cc.DelayTime:create(1), 
            cc.Spawn:create(
                cc.FadeOut:create(0.5), 
                cc.MoveTo:create(0.5, cc.p(2034, 375))
            )
        )
    )
end

function GameViewLayer:showStopJetton()
    self.m_stopjetton:stopAllActions()
    self.m_stopjetton:setVisible(true)
    self.m_stopjetton:setPosition(cc.p(-700, 375))
    self.m_stopjetton:setOpacity(0)
    self.m_stopjetton:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.5), 
                cc.MoveTo:create(0.5, cc.p(645, 375))
            ), 
            cc.DelayTime:create(1), 
            cc.Spawn:create(
                cc.FadeOut:create(0.5), 
                cc.MoveTo:create(0.5, cc.p(2034, 375))
            )
        )
    )
end

function GameViewLayer:showChangeBanker()
    self.m_changebanker:stopAllActions()
    self.m_changebanker:setVisible(true)
    self.m_changebanker:setPosition(cc.p(-700, 375))
    self.m_changebanker:setOpacity(0)
    self.m_changebanker:runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.5), 
                cc.MoveTo:create(0.5, cc.p(645, 375))
            ), 
            cc.DelayTime:create(1), 
            cc.Spawn:create(
                cc.FadeOut:create(0.5), 
                cc.MoveTo:create(0.5, cc.p(2034, 375))
            )
        )
    )
end

return GameViewLayer
