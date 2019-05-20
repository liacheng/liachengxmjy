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
local Game_CMD = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.models.GameLogic")

--弹出层
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.views.layer.SettingLayer")
local HelpLayer = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.views.layer.HelpLayer")
local ApplyListLayer = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.views.layer.ApplyListLayer")
local GameRecordLayer = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.views.layer.GameRecordLayer")
local GameResultLayer = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.views.layer.GameResultLayer")
local BankLayer = appdf.req(appdf.GAME_SRC .. "yule.28gangbattle.src.views.layer.BankLayer")

local GameViewLayer = class("GameViewLayer",function(scene)
        local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

local TAG_START             = 100
local enumTable = 
{
    "HEAD_BANKER",  --庄家头像
    "TAG_NIU_TXT",  --牛点数
    "TAG_CARD",     --牌
    "BT_MENU",		--菜单按钮
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
    "BT_JETTONAREA_1",--下注区域
    "BT_JETTONAREA_2",
    "BT_JETTONAREA_3",
    "BT_JETTONAREA_4",
    "BT_JETTONSCORE_1", --下注按钮    
    "BT_JETTONSCORE_2",
    "BT_JETTONSCORE_3",
    "BT_JETTONSCORE_4",
    "BT_JETTONSCORE_5",
    "BT_JETTONSCORE_6",
    "BT_JETTONSCORE_7",
    "BT_CHAT",
    "TAG_GAMESYSTEMMESSAGE"
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(TAG_START, enumTable)

GameViewLayer.ZORDER_1 = 1 
GameViewLayer.ZORDER_2 = 2 
GameViewLayer.ZORDER_3 = 3 
GameViewLayer.ZORDER_4 = 4 
GameViewLayer.ZORDER_5 = 5 
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

GameViewLayer.m_CardValue = 1

--发牌位置
local cardpoint = {cc.p(592, 484), cc.p(180, 478), cc.p(592, 260), cc.p(1008, 478)}
--自己头像位置
local selfheadpoint = cc.p(196, 60)
--庄家头像位置
local bankerheadpoint = cc.p(345, 673) 
--玩家列表按钮位置
local userlistpoint = cc.p(1310, 195)

--牌堆遮罩
GameViewLayer.MASK_PAIDUI = 10000
GameViewLayer.GAMETIP_BG = 10001
--通杀
GameViewLayer.ALLWIN_BG         = 1
GameViewLayer.ALLWIN_TITLE      = 2
GameViewLayer.ALLWIN_LIGHT      = 3
--通赔
GameViewLayer.ALLLOSE_TITLE     = 1
GameViewLayer.ALLLOSE_EFFECT_1  = 2
GameViewLayer.ALLLOSE_EFFECT_2  = 3
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
    self.m_bankerbg = nil
    --庄家名称
    self.m_bankerName = nil

    --自己背景框
    self.m_selfbg = nil

    --下注筹码
    self.m_JettonBtn = {}

    --下注按钮背后光
    self.m_JettonLight = nil

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

    --游戏币显示层
    self.m_goldLayer = nil

    --游戏币列表
    self.m_goldList = {{}, {}, {}, {},{}}

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

    --区域输赢
    self.m_bUserOxCard = {}

    --是否练习房，练习房不能使用银行
    self.m_bGenreEducate = false

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

    --下注倒计时
    self.m_fJettonTime = 0.1
    --下注开始标志
    self.m_bIsStartJetton = false
end

function GameViewLayer:loadResource()
    --加载卡牌纹理
    cc.Director:getInstance():getTextureCache():addImage("game_res/im_card.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game_effect.plist")

    local rootLayer, csbNode = ExternalFun.loadRootCSB("GameScene.csb", self)
	self.m_rootLayer = rootLayer
    self.m_scbNode = csbNode

	local function btnEvent( sender, eventType )
         ExternalFun.btnEffect(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    --菜单栏
    self.m_menulayout = csbNode:getChildByName("im_menu")
    self.m_menulayout:retain()
    self.m_menulayout:removeFromParent()
    self.m_menulayout:setScale(0)
    self:addChild(self.m_menulayout, 3)
    --self.m_menulayout:release()

    --菜单按钮
    local btn = csbNode:getChildByName("bt_menu")
    btn:setTag(TAG_ENUM.BT_MENU)
    btn:addTouchEventListener(btnEvent)

    --银行
    btn = self.m_menulayout:getChildByName("bt_bank")
    btn:setTag(TAG_ENUM.BT_BANK)
    btn:addTouchEventListener(btnEvent)

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
    btn = csbNode:getChildByName("bt_ludan")
    btn:setTag(TAG_ENUM.BT_LUDAN)
    btn:addTouchEventListener(btnEvent)

    --申请上庄
    self.m_btnApply = csbNode:getChildByName("bt_apply")
    self.m_btnApply:setTag(TAG_ENUM.BT_APPLY)
    self.m_btnApply:addTouchEventListener(btnEvent)

    --申请上庄列表
    btn = csbNode:getChildByName("bt_cblist")
    btn:setTag(TAG_ENUM.BT_APPLYLIST)
    btn:addTouchEventListener(btnEvent)

    --桌面显示的上庄列表
    self.m_cblist = csbNode:getChildByName("node_cblist")

    --倒计时
    self.m_timeLayout = csbNode:getChildByName("layout_time")

    --庄家背景框
    self.m_bankerbg = csbNode:getChildByName("layout_banker")

    --自己背景框
    self.m_selfbg = csbNode:getChildByName("layout_self")

    --总下注金额
    self.m_txtAllChip = csbNode:getChildByName("txt_allchip")

    --桌面牌数
    self.m_NodePaiDui = csbNode:getChildByName("node_paidui")  
    self.m_Im_PaiDui_Di = csbNode:getChildByName("im_paidui_di") 
        :setVisible(false) 
    self.m_Im_PaiDui_GAI = csbNode:getChildByName("im_paidui_gai")  
        :setVisible(false) 
    self.m_Mask_PaiDui = csbNode:getChildByName("mask_paidui")  
        :removeFromParent()

    --下注倒计时
    self.m_JettonTime = display.newSprite("#28gang_img_time1.png")
        :setPosition(cc.p(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+40))
        :setVisible(false)
        :addTo(self,GameViewLayer.ZORDER_3)

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

    local function ChipEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onJettonAreaClicked(sender:getTag()-TAG_ENUM.BT_JETTONAREA_1, sender)
        end
    end

    local nodechip = csbNode:getChildByName("node_chip")
    self.m_goldLayer = nodechip:getChildByName("bet_area") 
    --下注区域
    for i=1,4 do
        local str = string.format("bt_area_%d", i)
        btn = csbNode:getChildByName(str)
        if i ~= 1 then 
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
             
        end

        txttemp = nodechip:getChildByName(string.format("im_win_light_%d", i))
        self.m_JettAreaLight[i] = txttemp
        txttemp:setVisible(false)
    end      

    self:initBankerInfo()
    self:initSelfInfo()
    --刷新上庄列表
    self:resetCbList()
    --牌类层
    self.m_cardLayer = csbNode:getChildByName("node_card")       

    --牌型数值
    self.m_CardType = {}
    for i = 1,4 do 
        local str = string.format("node_cardtype%d", i)
        self.m_CardType[i] = csbNode:getChildByName(str)
        self.m_CardType[i]:setVisible(false)
    end

    --聊天
    self.m_btnChat = csbNode:getChildByName("bt_chat")
        :setTag(TAG_ENUM.BT_CHAT)
        :addTouchEventListener(btnEvent)

    --通杀初始化
    self:initAllWin()   
    --通赔初始化
    self:initAllLose()  

    self:getJettonTable(13900,100)
end

--通杀初始化
function GameViewLayer:initAllWin()
    self.m_AllWinEffect = display.newSprite("#28gang_img_bg_allwin1.png")
        :setPosition(cc.p(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+60))
        :addTo(self,GameViewLayer.ZORDER_4)
        :setVisible(false)
    local bg = display.newSprite("#28gang_img_bg_allwin2.png")
        :setPosition(self.m_AllWinEffect:getContentSize().width/2,self.m_AllWinEffect:getContentSize().height*0.3)
        :setTag(GameViewLayer.ALLWIN_BG)
        :addTo(self.m_AllWinEffect)
    local title = display.newSprite("#28gang_img_title_allwin.png")
        :setPosition(self.m_AllWinEffect:getContentSize().width/2,self.m_AllWinEffect:getContentSize().height*0.3)
        :setTag(GameViewLayer.ALLWIN_TITLE)
        :addTo(self.m_AllWinEffect)
    local light = display.newSprite("#28gang_img_light_allwin.png")
        :setPosition(self.m_AllWinEffect:getContentSize().width/2,self.m_AllWinEffect:getContentSize().height/2)
        :setTag(GameViewLayer.ALLWIN_LIGHT)
        :addTo(self.m_AllWinEffect,-1)
end
function GameViewLayer:initAllLose()
    self.m_AllLoseEffect = display.newSprite("#28gang_img_bg_alllose.png")
        :setPosition(cc.p(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+60))
        :addTo(self,GameViewLayer.ZORDER_4)
        :setVisible(false)
    local title = display.newSprite("#28gang_img_title_alllose.png")
        :setPosition(self.m_AllLoseEffect:getContentSize().width/2,self.m_AllLoseEffect:getContentSize().height*0.3)
        :setTag(GameViewLayer.ALLLOSE_TITLE)
        :addTo(self.m_AllLoseEffect)
    local effect1 = display.newSprite("#flash1.png")
        :setPosition(self.m_AllLoseEffect:getContentSize().width*0.7,self.m_AllLoseEffect:getContentSize().height*0.5)
        :rotate(55)
        :setTag(GameViewLayer.ALLLOSE_EFFECT_1)
        :addTo(self.m_AllLoseEffect,-1)
    local effect2 = display.newSprite("#flash2.png")
        :setPosition(self.m_AllLoseEffect:getContentSize().width*0.3,self.m_AllLoseEffect:getContentSize().height*0.5)
        :rotate(-55)
        :setTag(GameViewLayer.ALLLOSE_EFFECT_2)
        :addTo(self.m_AllLoseEffect,-1)
end
--初始化庄家信息
function GameViewLayer:initBankerInfo()
    --庄家姓名
    self.m_bankerName = self.m_bankerbg:getChildByName("txt_name")
    self.m_bankerName:setFontName("fonts/round_body.ttf")

    --庄家头像
    self.m_spBankerHead = self.m_bankerbg:getChildByName("im_head")

	--庄家金币
	self.m_textBankerCoin = self.m_bankerbg:getChildByName("txt_gold_num")
    self.m_textBankerCoin:setFontName("fonts/round_body.ttf")

	--庄家成绩 
	self.m_textBankerChengJi = self.m_bankerbg:getChildByName("txt_score")
    self.m_textBankerChengJi:setFontName("fonts/round_body.ttf")

    --庄家局数    
    self.m_spBankerRound = self.m_scbNode:getChildByName("im_rebanker")
	self.m_textBankerRound = self.m_spBankerRound:getChildByName("txt_num")
    self.m_textBankerRound:setFontName("fonts/round_body.ttf")
end

--刷新庄家信息
function GameViewLayer:resetBankerInfo()
    local head = self.m_bankerbg:getChildByTag(TAG_ENUM.HEAD_BANKER)
    if self.m_wBankerUser == yl.INVALID_CHAIR then
        if self.m_bEnableSysBanker == true then 
            self.m_bankerName:setString("系统坐庄")
            self.m_textBankerCoin:setString(ExternalFun.formatScoreText(9999999999))
            self.m_textBankerChengJi:setString(ExternalFun.formatScoreText(self.m_lBankerWinAllScore))
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
            self.m_textBankerChengJi:setString("")
            self.m_spBankerRound:setVisible(false)
            self.m_textBankerRound:setString("")
        end
        if head then 
            head:removeFromParent()
        else
            local headBg = display.newSprite("#userinfo_head_frame.png")
            headBg:setPosition(self.m_spBankerHead:getPosition())
            headBg:setScale(0.55,0.55)
            self.m_bankerbg:addChild(headBg)  
        end
       
        local head = PopupInfoHead:createNormal(userItem, 90)                        
		head:setPosition(self.m_spBankerHead:getPosition());
        head:setTag(TAG_ENUM.HEAD_BANKER)            
		self.m_bankerbg:addChild(head)
    else
        local userItem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        self.m_bankerName:setString(userItem.szNickName)
        local bankerstr = ExternalFun.formatScoreText(self.m_lBankerScore)
        self.m_textBankerCoin:setString(bankerstr)
        self.m_textBankerChengJi:setString(ExternalFun.formatScoreText(self.m_lBankerWinAllScore))
        if self.m_cbBankerTime > 0 then 
            self.m_spBankerRound:setVisible(true)
            self.m_textBankerRound:setString(""..self.m_cbBankerTime)
        else
            self.m_spBankerRound:setVisible(false)
            self.m_textBankerRound:setString("")
        end
        if not head then 
            local headBg = display.newSprite("#userinfo_head_frame.png")
            headBg:setPosition(self.m_spBankerHead:getPosition())
            headBg:setScale(0.55,0.55)
            self.m_bankerbg:addChild(headBg)
            head = PopupInfoHead:createNormal(userItem, 90)                        
		    head:setPosition(self.m_spBankerHead:getPosition());
            head:setTag(TAG_ENUM.HEAD_BANKER)                    
		    self.m_bankerbg:addChild(head)
        else
		    head:updateHead(userItem)
        end
    end
end

--初始化自己信息
function GameViewLayer:initSelfInfo()
    local userItem = self:getMeUserItem()
    --玩家头像
    local csbHead = self.m_selfbg:getChildByName("im_head")     -- 头像处理
    local csbHeadX, csbHeadY = csbHead:getPosition()
    head = PopupInfoHead:createNormal(userItem, 85)
    head:setPosition(cc.p(csbHeadX, csbHeadY))   
	self.m_selfbg:addChild(head)

    --玩家名称
    self.m_textUserName = self.m_selfbg:getChildByName("txt_name")
    self.m_textUserName:setFontName("fonts/round_body.ttf")
    self.m_textUserName:setString(userItem.szNickName)   
	--玩家金币
	self.m_textUserCoin = self.m_selfbg:getChildByName("txt_gold_num")
    self.m_textUserCoin:setFontName("fonts/round_body.ttf")
    self.m_textUserCoin:setString(userItem.lScore)   
    --玩家成绩
    self.m_textCj = self.m_selfbg:getChildByName("txt_score")
    self.m_textCj:setFontName("fonts/round_body.ttf")
    self.m_textCj:setString("0")   
end

--刷新自己信息
function GameViewLayer:resetSelfInfo()
    self.m_textUserCoin:setString(""..self.m_showScore)   
    self.m_textCj:setString(ExternalFun.formatScoreText(self.m_lEndUserScore))  
end
--刷新上庄列表
function GameViewLayer:resetCbList()
    local userList = self:getDataMgr():getApplyBankerUserList()
    local name = self.m_cblist:getChildByName("txt_name")
        :setFontName("fonts/round_body.ttf")
        :setString("")
    local score = self.m_cblist:getChildByName("txt_score")
        :setFontName("fonts/round_body.ttf")
        :setString("")
    local Data = userList[#userList]
    if Data then
        local nameStr = Data.m_userItem.szNickName
        name:setString(ExternalFun.GetShortName(nameStr,9,8))
        local scoreStr = ExternalFun.formatScoreText(Data.m_userItem.lScore)
        score:setString(scoreStr)
    end
end
--开始下一局，清空上局数据
function GameViewLayer:resetGameData()
    if nil ~= self.m_cardLayer then
        self.m_cardLayer:stopAllActions()
    end
    
    for i=1,4 do
        if self.m_CardArray[i] ~= nil then
            for k,v in pairs(self.m_CardArray[i]) do
                v:stopAllActions()
                v:setVisible(false)
                if v:getChildByTag(GameViewLayer.m_CardValue) then 
                    v:getChildByTag(GameViewLayer.m_CardValue):removeFromParent()
                end
            end
        end
        self.m_CardType[i]:setVisible(false)
    end
    self.m_lAllJettonScore = {0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0}
    self.m_lUserAllJetton = 0
    self:updateAreaScore(false)
    self:updataAllChip(false)
    for k,v in pairs(self.m_JettAreaLight) do
        v:stopAllActions()
        v:setVisible(false)
    end

    --通杀通赔隐藏
    self:showAllWin(false)
    self:showAllLose(false)   

    --游戏币清除
    self.m_goldLayer:removeAllChildren()     
    self.m_goldList = {{}, {}, {}, {},{}}

    if nil ~= self.m_gameResultLayer then
        self.m_gameResultLayer:setVisible(false)
    end
end

function GameViewLayer:onExit()
    self:stopAllActions()
    self:unloadResource()
end

--释放资源
function GameViewLayer:unloadResource()
    --特殊处理game_res blank.png 冲突
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_all.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_all.png")

    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_all/im_card.png")
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
		self:showMenu()
    elseif TAG_ENUM.BT_LUDAN == tag then
        if nil == self.m_GameRecordLayer then
            self.m_GameRecordLayer = GameRecordLayer:create(self)
                :addTo(self,GameViewLayer.ZORDER_2)
        end
        local recordList = self:getDataMgr():getGameRecord()     
        self.m_GameRecordLayer:refreshRecord(recordList)
    elseif TAG_ENUM.BT_BANK == tag then
        self:showMenu()
        local rom = GlobalUserItem.GetRoomInfo()
		if nil ~= rom then
			if rom.wServerType ~= yl.GAME_GENRE_GOLD then
				showToast(cc.Director:getInstance():getRunningScene(), "当前房间禁止操作银行!", 1)
				return
			end
		end	

	    if 0 == GlobalUserItem.cbInsureEnabled then
   	 	    showToast(cc.Director:getInstance():getRunningScene(), "初次使用，请先开通银行！", 1)
    	    return 
	    end
        if self.m_bankLayer == nil then
            self.m_bankLayer = BankLayer:create(self) 
            self:addChild(self.m_bankLayer,10)
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
        self:showMenu()
        if self.m_settingLayer == nil then 
 	        local mgr = self._scene._scene:getApp():getVersionMgr()
            local verstr = mgr:getResVersion(Game_CMD.KIND_ID) or "0"    	
            self.m_settingLayer = SettingLayer:create(verstr)
	        self:addChild(self.m_settingLayer, 10)
        else
            self.m_settingLayer:onShow()
        end
    elseif TAG_ENUM.BT_HELP == tag then
        self:showMenu()
        if nil == self.m_helpLayer then
            self.m_helpLayer = HelpLayer:create(self, Game_CMD.KIND_ID, 0)
            self:addChild(self.m_helpLayer, 10)
        else
            self.m_helpLayer:onShow()
        end
    elseif TAG_ENUM.BT_QUIT == tag then
        self:showMenu()
        self._scene:onQueryExitGame()
    --下注按钮
    elseif TAG_ENUM.BT_JETTONSCORE_1 <= tag and TAG_ENUM.BT_JETTONSCORE_7 >= tag then
        self:onJettonButtonClicked(ref:getTag()-TAG_ENUM.BT_JETTONSCORE_1+1, ref)
    --下注区域
    elseif TAG_ENUM.BT_JETTONAREA_1 <= tag and  TAG_ENUM.BT_JETTONAREA_4 >= tag then
        self:onJettonAreaClicked(ref:getTag()-TAG_ENUM.BT_JETTONAREA_1, ref)
    elseif tag == TAG_ENUM.BT_APPLY then
        local state = self:getApplyState()
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        self:applyBanker( state )
    elseif tag == TAG_ENUM.BT_APPLYLIST then
        if nil == self.m_applyListLayer then
            self.m_applyListLayer = ApplyListLayer:create(self)
            self:addChild(self.m_applyListLayer, 10)
        else
            self.m_applyListLayer:setVisible(true)
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
    --
    local selfscore  = (jettonscore + self.m_lUserAllJetton)*MaxTimes
    if  selfscore > self.m_lUserMaxScore then
        showToast(self,"已超过个人最大下注值",1)
        return
    end

    local areascore = self.m_lAllJettonScore[tag] + jettonscore
    if areascore > self.m_lAreaLimitScore then
        showToast(self,"已超过该区域最大下注值",1)
        return
    end

    if self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local allscore = jettonscore
        for k,v in pairs(self.m_lAllJettonScore) do
            allscore = allscore + v
        end
        allscore = allscore*MaxTimes
        if allscore > self.m_lBankerScore then
            showToast(self,"总下注已超过庄家下注上限",1)
            return
        end
    end
    
    self.m_lUserAllJetton = self.m_lUserAllJetton + jettonscore
    self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)
    local userItem = self:getMeUserItem()
    self.m_showScore = userItem.lScore - self.m_lUserAllJetton
    self:resetSelfInfo()
    self:getParentNode():SendPlaceJetton(jettonscore, tag)

    local nodechip = self.m_scbNode:getChildByName("node_chip")

    self.m_JettAreaLight[tag+1]:setVisible(true) 
    self.m_JettAreaLight[tag+1]:runAction(
    cc.Sequence:create(
        cc.FadeIn:create(0.1), 
        cc.DelayTime:create(0.1),
        cc.FadeOut:create(0.1),
        cc.FadeIn:create(0.1),
        cc.CallFunc:create(function ()
            self.m_JettAreaLight[tag+1]:setVisible(false)
        end)
        )
    )
end

--用户下注
function GameViewLayer:onPlaceJetton(cmd_table)
    local area = cmd_table.cbJettonArea +1
    if self:isMeChair(cmd_table.wChairID) == true then
        local oldscore = self.m_lUserJettonScore[area]
        self.m_lUserJettonScore[area] = oldscore + cmd_table.lJettonScore 
    end
    
    local oldscore = self.m_lAllJettonScore[area]
    self.m_lAllJettonScore[area] = oldscore + cmd_table.lJettonScore

    self:showUserJetton(cmd_table)
    self:updateAreaScore(true)
    self:updataAllChip(true)
end

--下注失败
function GameViewLayer:onPlaceJettonFail(cmd_table)
    if self:isMeChair(cmd_table.wPlaceUser) == true then
        self.m_lUserAllJetton = self.m_lUserAllJetton - cmd_table.lPlaceScore 
    end
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
    local judgeindex = 0
    if self.m_nJettonSelect == 0 then
        self.m_nJettonSelect = 1
        self.m_JettonLight:setPositionX(self.m_JettonBtn[self.m_nJettonSelect]:getPositionX())
    end
    for i=1,7 do
        local judgescore = GameViewLayer.m_BTJettonScore[i]*MaxTimes
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
    for i=2,4 do
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
function GameViewLayer:showJettonTime(time)
    if time <= 3 and time > 0 then 
        self.m_JettonTime:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("28gang_img_time%d.png",time)))
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
            self.m_fJettonTime = math.min(0.1, time)            
        end
    else
        if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
            return
        end
        if time == self.m_cbTimeLeave then
            --发牌处理
            self:sendCard(true)
        elseif time == self.m_cbTimeLeave-2  then
            --显示点数
            self:showCard()
        elseif time == self.m_cbTimeLeave-5 then
            --游戏币处理
            self:showGoldMove()
        elseif time == self.m_cbTimeLeave-8  then
            --显示结算
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
function GameViewLayer:updataLeftCard()
    self.m_NodePaiDui:removeAllChildren()
    local width = 61*0.55
    local height = 75*0.55
    local PosX = 0
    local PosY = 0
    if self.m_cbLeftCardCount == 0 then 
        self.m_cbLeftCardCount = 40 
    end
    local CardDui = self.m_cbLeftCardCount/2
    for i= 1 ,CardDui do          
        if i > 10 then 
            PosX =(i-11)*(-width)
            PosY = -height
        else
            PosX =(i-1)*(-width)
            PosY = 0
        end 
        for j = 1,2 do 
            local tag = self.m_cbLeftCardCount - ((i-1)*2+(j-1))
            display.newSprite("#28gang_img_pai_back.png")
                :setPosition(PosX,(j-1)*10+PosY)
                :setScale(0.55,0.55)
                :setTag(tag)
                :addTo(self.m_NodePaiDui)
        end
    end
    
end
function GameViewLayer:createPaiDuiClip()   
    local stencil = display.newSprite()
	stencil:setTextureRect(cc.rect(0,0,344,110))
	local Clip = cc.ClippingNode:create(stencil)  
    Clip:move(cc.p(self.m_Im_PaiDui_Di:getPositionX(),self.m_Im_PaiDui_Di:getPositionY()+10))
    Clip:setInverted(true)
    local sp = display.newSprite("#28gang_img_pai_mash.png") 
    sp:setPositionY(-47)
    Clip:addChild(sp)
    Clip:setTag(GameViewLayer.MASK_PAIDUI)
    self:addChild(Clip,GameViewLayer.ZORDER_1)
end
function GameViewLayer:removePaiDuiClip()   
    self:getChildByTag(GameViewLayer.MASK_PAIDUI):removeFromParent()
end
function GameViewLayer:reLoadLeftCard()
    self.m_Im_PaiDui_Di:setVisible(true)
    self.m_Im_PaiDui_GAI:setVisible(true)
    self:updataLeftCard()
    self.m_NodePaiDui:setPosition(cc.p(self.m_NodePaiDui:getPositionX(),self.m_NodePaiDui:getPositionY()-115))
    self.m_NodePaiDui:setVisible(false)
    self:createPaiDuiClip()
    self.m_Im_PaiDui_GAI:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1,0),
            cc.CallFunc:create(
            function()
                self.m_NodePaiDui:setVisible(true)
            end),
            cc.ScaleTo:create(0.8,1,1),
            cc.CallFunc:create(
            function()
                self.m_Im_PaiDui_Di:setVisible(false)
                self.m_Im_PaiDui_GAI:setVisible(false)
            end)))
    self.m_NodePaiDui:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.MoveBy:create(0.5,cc.p(0,130)),
            cc.DelayTime:create(0.1),
            cc.MoveBy:create(0.1,cc.p(0,-15)),
            cc.CallFunc:create(
            function()
                self:removePaiDuiClip()
            end)
            ))
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
    self.m_bGenreEducate = cmd_table.bGenreEducate
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self:showGameStatus()
    self:resetBankerInfo()
    self:resetSelfInfo()
    self.m_lAllJettonScore = {0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0}
    self.m_lUserAllJetton = 0
    self.m_cbLeftCardCount = cmd_table.cbLeftCardCount + 8
    self:updataLeftCard()

    self:updateAreaScore(false)
    self:updateJettonList(self.m_lUserMaxScore)
    self:setJettonEnable(false)
    self.m_bIsStartJetton = false

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
    self.m_cbLeftCardCount = cmd_table.cbLeftCardCount + 8
    self.m_cbTableCardArray = cmd_table.cbTableCardArray
    self:updataLeftCard()
    local temp = cmd_table.lEndUserScore 
    self.m_lEndUserScore = temp + self.m_lEndUserScore
    self:showGameStatus()
    self:resetBankerInfo()
    self:resetSelfInfo()   
    self.m_lAllJettonScore = cmd_table.lAllJettonScore[1]
    self.m_lUserJettonScore = cmd_table.lUserJettonScore[1]
--    self.m_lOccupySeatUserWinScore = cmd_table.lOccupySeatUserWinScore

    local bankername = "系统坐庄"
    if  self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    self.m_tBankerName = bankername

--    self.m_lSelfWinScore = cmd_table.lEndUserScore
--    self.m_lSelfReturnScore = cmd_table.lEndUserReturnScore
--    self.m_lBankerWinScore = cmd_table.lEndBankerScore
    for k,v in pairs(self.m_lUserJettonScore) do
        self.m_lUserAllJetton = self.m_lUserAllJetton + v
    end
    
    if self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then       
        self:updateJettonList(self.m_lUserMaxScore - self.m_lUserAllJetton*MaxTimes)
        self:updateAreaScore(true)   
        self:updataUserJetton()    
        self.m_bIsStartJetton = true
        if self:isMeChair(self.m_wBankerUser) == true then
            self:setJettonEnable(false)
            self.m_bIsStartJetton = false
        end
    else
        self:setJettonEnable(false)
        self.m_bIsStartJetton = false
--        --自己是否下注
--        local jettonscore = 0
--        for k,v in pairs(cmd_table.lUserJettonScore[1]) do
--            jettonscore = jettonscore + v
--        end
--        --自己是否有输赢
--        jettonscore = jettonscore + self.m_lSelfWinScore
        if self.m_cbTimeLeave >= 5 then 
            self:sendCard(false) 
            self:showCard()
        end
--        self:showGameEnd(false)
--        self:updateAreaScore(true)
    end

    --申请按钮状态更新
    self:refreshApplyBtnState()
end

function GameViewLayer:getJettonTable(AllSocre,UserScore)
    local AllTab = {}
    for i = #GameViewLayer.m_BTJettonScore ,1 ,-1 do 
        if AllSocre >= GameViewLayer.m_BTJettonScore[i] then 
            local AllNum = math.floor(AllSocre/GameViewLayer.m_BTJettonScore[i])
            local UserNum = 0 
            if UserScore >= GameViewLayer.m_BTJettonScore[i] then 
                UserNum = math.floor(UserScore/GameViewLayer.m_BTJettonScore[i])
            end 
            for j = 1 ,AllNum do 
                local gold = {}
                gold.socre = GameViewLayer.m_BTJettonScore[i]
                gold.isMeJetton = 0
                if j <= UserNum then 
                    gold.isMeJetton = 1
                end
                table.insert(AllTab,gold)
            end
            AllSocre = AllSocre - AllNum * GameViewLayer.m_BTJettonScore[i] 
        end       
    end
    return AllTab 
end
--
function GameViewLayer:updataUserJetton()
    for i = 2 ,4 do       
        local AreaTab = self:getJettonTable(self.m_lAllJettonScore[i],self.m_lUserJettonScore[i])
        for k,v in pairs(AreaTab) do  
            local endPos = self:getJettonPos(i)
            local spJetton = self:getJettonImage(v.socre)
            local pgold = cc.Sprite:createWithSpriteFrameName(spJetton)
            pgold:setPosition(endPos)
            self.m_goldLayer:addChild(pgold)
            pgold.isMeJetton = v.isMeJetton
            pgold.score = v.socre
            table.insert(self.m_goldList[i], pgold)
        end
    end
end
--空闲
function GameViewLayer:onGameFree(cmd_table)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_FREE
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self:showGameStatus()
    self:setJettonEnable(false)
    self.m_bIsStartJetton = false
    self.m_lAllJettonScore = {0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0}
    self:resetGameData()
    if self.m_cbLeftCardCount == 0 then 
        self:reLoadLeftCard()
    end

    --申请按钮状态更新
    self:refreshApplyBtnState()
end

--开始下注
function GameViewLayer:onGameStart(cmd_table)   
    self:showGameTips(TIP_TYPE.TypeBeginChip)
    ExternalFun.playSoundEffect("game_start.wav")
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_JETTON
    self.m_cbTimeLeave = cmd_table.cbTimeLeave
    self.m_lUserMaxScore = cmd_table.lUserMaxScore
    self.m_wBankerUser = cmd_table.wBankerUser
    self.m_lBankerScore = cmd_table.lBankerScore
    self:showGameStatus()    
    self:resetBankerInfo() 
--    self:setJettonEnable(true)  
--    self:updateJettonList(self.m_lUserMaxScore)
    if self:isMeChair(self.m_wBankerUser) == true then
        self:setJettonEnable(false)
    end  
    --申请按钮状态更新
    self:refreshApplyBtnState()

--    --显示提示
--    if cmd_table.bContinueCard then
--        self:showGameTips(TIP_TYPE.TypeContinueSend)
--    else
--        self:showGameTips(TIP_TYPE.TypeReSend)
--    end
end

--结束
function GameViewLayer:onGameEnd(cmd_table)
    self:showGameTips(TIP_TYPE.TypeStopChip)
    self.m_cbGameStatus = Game_CMD.GAME_SCENE_END
    self.m_cbTableCardArray = cmd_table.cbTableCardArray
    self.m_lSelfWinScore = cmd_table.lUserScore
    self.m_lSelfReturnScore = cmd_table.lUserReturnScore
    self.m_lPlayScore = cmd_table.lPlayScore
    self.m_lBankerWinScore = cmd_table.lBankerScore
    self.m_alBankerWinScore = cmd_table.alBankerScore
    self.m_lOccupySeatUserWinScore = cmd_table.lOccupySeatUserWinScore
    self.m_lBankerWinAllScore = cmd_table.lBankerTotallScore 
    self.m_cbBankerTime = cmd_table.nBankerTime
    self.m_tagUserWinRank = cmd_table.tagUserWinRank
    self.m_lEndUserScore = cmd_table.lUserScore + self.m_lEndUserScore
    local bankername = "系统坐庄"
    if  self.m_wBankerUser ~= yl.INVALID_CHAIR then
        local useritem = self:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        if nil ~= useritem then
            bankername = useritem.szNickName
        end
    end
    self.m_tBankerName = bankername
    self:resetBankerInfo()
    self:showGameStatus()
    self:setJettonEnable(false)
    self.m_bIsStartJetton = false
end

function GameViewLayer:updataAllChip(bUpData)
    local chipNum = 0
    if bUpData == false then 
        self.m_txtAllChip:setString(chipNum)
    else       
        for k,v in pairs(self.m_lAllJettonScore) do
            chipNum = v + chipNum
        end
        self.m_txtAllChip:setString(chipNum)
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

    self:showGameTips(TIP_TYPE.TypeChangBanker)

    --自己上庄
    if self:isMeChair(cmd_table.wBankerUser) == true then
        self.m_enApplyState = APPLY_STATE.kApplyedState
    end
end

--取消申请
function GameViewLayer:onGetCancelBanker(cmd_table)
    if self:isMeChair(cmd_table.wCancelUser) == true then
        self.m_enApplyState = APPLY_STATE.kCancelState
    end

    self:refreshApplyList()
end

--银行操作成功
function GameViewLayer:onBankSuccess( )
    local bank_success = self:getParentNode().bank_success
    if nil == bank_success then
        return
    end
    GlobalUserItem.lUserScore = bank_success.lUserScore
    GlobalUserItem.lUserInsure = bank_success.lUserInsure

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

-------界面显示更新--------
--菜单栏操作
function GameViewLayer:showMenu()
    local btMenu = self.m_menulayout:getChildByName("bt_menu")
    if self.m_bshowMenu == false then
        self.m_bshowMenu = true
        self.m_menulayout:runAction(cc.ScaleTo:create(0.2, 1, 1))
    else
        self.m_bshowMenu = false
        self.m_menulayout:runAction(cc.ScaleTo:create(0.2, 0, 0))
    end
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
        content:loadTexture("28gang_bg_title_freetime.png", UI_TEX_TYPE_PLIST)
    elseif self.m_cbGameStatus == Game_CMD.GAME_SCENE_JETTON then
        content:loadTexture("28gang_bg_title_chiptime.png", UI_TEX_TYPE_PLIST)
    elseif self.m_cbGameStatus == Game_CMD.GAME_SCENE_END then   
        content:loadTexture("28gang_bg_title_opentime.png", UI_TEX_TYPE_PLIST) 
    end
end

function GameViewLayer:removePaiDuiCard()
    for i = 1,self.m_cbLeftCardCount do 
        local obj = self.m_NodePaiDui:getChildByTag(i)
        if i <= 8 then 
            obj:setVisible(false)
            obj:removeFromParent()
            obj = nil
        else
            obj:setTag(i-8)
        end
    end 
    local num = self.m_NodePaiDui:getChildrenCount() 
    self.m_cbLeftCardCount = num
end

function GameViewLayer:createSendCard()
    local tag = 0
    for i=1,4 do
        local temp = {}
        tag = i*2
        for j=1,2 do           
            local Pos = self.m_NodePaiDui:convertToWorldSpace(cc.p(self.m_NodePaiDui:getChildByTag(tag):getPositionX(),self.m_NodePaiDui:getChildByTag(tag):getPositionY()))
            temp[j] = display.newSprite("#28gang_img_pai_back.png")
                :setPosition(Pos)
                :setScale(0.55,0.55)
                :setTag(j)
            self.m_cardLayer:addChild(temp[j])
            tag = tag-1
        end        
        self.m_CardArray[i] = temp
    end
    self:removePaiDuiCard()
end

--发牌动画
function GameViewLayer:sendCard(banim)
    self:createSendCard()
    local index = 0
    if banim then
        local delaytime = 0.1
        for i=1,4 do
            index = index +1 
            local pos = cc.p(self.m_scbNode:getChildByName("node_pai"..i):getPositionX(),self.m_scbNode:getChildByName("node_pai"..i):getPositionY())
            for j=1,2 do
                local card = self.m_CardArray[i][j]
                card:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime*index),
                                cc.Spawn:create(cc.MoveTo:create(0.33, pos),cc.ScaleTo:create(0.33, 1)),
                                cc.CallFunc:create(
                                     function()
                                        if j == 1 then 
                                            card:runAction(cc.MoveBy:create(0.2,cc.p(-30,0)))
                                        else
                                            card:runAction(cc.MoveBy:create(0.2,cc.p(30,0)))
                                        end
                                     end
                                )))
            end
        end
    else
        for i=1,4 do
            index = index +1 
            local pos = cc.p(self.m_scbNode:getChildByName("node_pai"..i):getPositionX(),self.m_scbNode:getChildByName("node_pai"..i):getPositionY())
            for j=1,2 do
                local card = self.m_CardArray[i][j]
                card:setScale(1)
                if j == 1 then 
                    card:setPosition(cc.p(pos.x-30,pos.y)) 
                else
                    card:setPosition(cc.p(pos.x+30,pos.y)) 
                end                              
            end
        end
    end
end

function GameViewLayer:getCardImg(menIndex,cardIndex)
    local cardValue = self.m_cbTableCardArray[menIndex][cardIndex]
    if cardValue == 16 then 
        return cc.SpriteFrameCache:getInstance():getSpriteFrame("28gang_img_value10.png")
    else
        return cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("28gang_img_value%d.png",cardValue))
    end
end

function GameViewLayer:showAllLose(bShow)
    self.m_AllLoseEffect:stopAllActions()
    self.m_AllLoseEffect:setVisible(false)
    if bShow == true then
        self.m_AllLoseEffect:setVisible(true)
        self.m_AllLoseEffect:setScale(0.3)
        self.m_AllLoseEffect:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1),cc.DelayTime:create(4),cc.CallFunc:create(
                                                            function(ref)
                                                                ref:stopAllActions()
                                                                ref:setVisible(false)
                                                            end
                                                            )))
        local title = self.m_AllLoseEffect:getChildByTag(GameViewLayer.ALLLOSE_TITLE)
            :setScale(0.5)
            :setOpacity(0)
        title:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.Spawn:create(cc.ScaleTo:create(0.2, 1.1),cc.FadeIn:create(0.2)),cc.ScaleTo:create(0.05, 1)))

        local effect1 = self.m_AllLoseEffect:getChildByTag(GameViewLayer.ALLLOSE_EFFECT_1)
        local effect2 = self.m_AllLoseEffect:getChildByTag(GameViewLayer.ALLLOSE_EFFECT_2)
        local effect_frames = {}
        for k = 1, 3 do
            local frameName =string.format("flash%d.png",k)  
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
            table.insert(effect_frames, frame)
        end
        local effect_ani = cc.Animation:createWithSpriteFrames(effect_frames, 0.15)
        local ani1 = cc.RepeatForever:create(cc.Animate:create(effect_ani))
        local ani2 = cc.RepeatForever:create(cc.Animate:create(effect_ani))
        effect1:runAction(ani1)
        effect2:runAction(ani2)
    end
end
function GameViewLayer:showAllWin(bShow)
    self.m_AllWinEffect:stopAllActions()
    self.m_AllWinEffect:setVisible(false)
    if bShow == true then
        self.m_AllWinEffect:setVisible(true)
        self.m_AllWinEffect:setScale(0.3)
        self.m_AllWinEffect:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1),cc.DelayTime:create(4),cc.CallFunc:create(
                                                            function(ref)
                                                                ref:stopAllActions()
                                                                ref:setVisible(false)
                                                            end
                                                            )))
        local bg = self.m_AllWinEffect:getChildByTag(GameViewLayer.ALLWIN_BG)
            :setScale(0.5)
            :setOpacity(0)
        local title = self.m_AllWinEffect:getChildByTag(GameViewLayer.ALLWIN_TITLE)
            :setScale(0.5)
            :setOpacity(0)
        local light = self.m_AllWinEffect:getChildByTag(GameViewLayer.ALLWIN_LIGHT)

        bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.Spawn:create(cc.ScaleTo:create(0.2, 1.1),cc.FadeIn:create(0.2)),cc.ScaleTo:create(0.05, 1)))
        title:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.Spawn:create(cc.ScaleTo:create(0.2, 1.1),cc.FadeIn:create(0.2)),cc.ScaleTo:create(0.05, 1)))
        light:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))
        
        self.m_JettAreaLight[1]:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1))) 
    end
end
function GameViewLayer:showWinEffect(index)
    --胜利动画
    local win_frames = {}
    for k = 1, 8 do
        local frameName =string.format("win%d.png",k)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(win_frames, frame)
    end
    local win_ani = cc.Animation:createWithSpriteFrames(win_frames, 0.1) 
    --local areaNode = self.m_scbNode:getChildByName("bt_area_"..index)
    local nodechip = self.m_scbNode:getChildByName("node_chip")
    local winFlag = nodechip:getChildByName("im_win_"..index)
        :setVisible(true)
    local winEffect = nodechip:getChildByName("im_win_effect_"..index)
        :setVisible(true)
    local seqAn = cc.Sequence:create(cc.Animate:create(win_ani),
                                    cc.CallFunc:create(
                                    function ()
                                        winEffect:setVisible(false)
                                    end),                                    
                                    cc.DelayTime:create(1),
                                    cc.CallFunc:create(
                                    function ()
                                        winFlag:setVisible(false)
                                    end
                                    ))     
    winEffect:runAction(seqAn)                      
end
function GameViewLayer:showCardType(index)
    local obj = self.m_CardType[index]
            :setVisible(true)
    local im_CardType = obj:getChildByName("im_cardtype")
    local txt_dianshu = obj:getChildByName("txt_dianshu")
    local im_dianshu1 = obj:getChildByName("im_dianshu1")
    local im_dianshu2 = obj:getChildByName("im_dianshu2")

    local cardData = self.m_cbTableCardArray[index]
    local cardType = GameLogic:GetCardType(cardData,#cardData)
    if cardType > 1 then 
        im_CardType:setVisible(true)
        txt_dianshu:setVisible(false)
        im_dianshu1:setVisible(false)
        im_dianshu2:setVisible(false)
        im_CardType:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("28gang_img_cardtype%d.png",cardType)))
    else
        im_CardType:setVisible(false)
        txt_dianshu:setVisible(true)
        im_dianshu1:setVisible(true)
        local cardPoint,isWhite = GameLogic:GetCardListPip( cardData )
        if isWhite == true then 
            txt_dianshu:setString(cardPoint-0.5)
            im_dianshu2:setVisible(true)
        else
            txt_dianshu:setString(cardPoint)
            im_dianshu2:setVisible(false)
        end      
    end
end
--显示牌跟牌值
function GameViewLayer:showCard()   
    --胜利光效
    local function effectfunction()
        local winNum = 0
        for i=1,3 do
            if self.m_bUserOxCard[i+1] > 0 then                
                self.m_JettAreaLight[i+1]:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))            
                self:showWinEffect(i+1)
                winNum = winNum + 1
            end
        end
        if winNum == 0 then 
            --通杀
            self:showAllWin(true)
        elseif winNum == 3 then 
            --通赔
            self:showAllLose(true)
        end
    end

    --开牌动画
    local open_frames = {}
    for k = 1, 3 do
        local frameName =string.format("open%d.png",k)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(open_frames, frame)
    end
    local open_ani = cc.Animation:createWithSpriteFrames(open_frames, 0.1) 

    local seqAn = nil
    local count = 0
    for i=1,4 do
        if i > 1 then
            local a = GameLogic:CompareCard(self.m_cbTableCardArray[1], self.m_cbTableCardArray[i])
            self.m_bUserOxCard[i] = a
        end      
        for j = 1,2 do 
            count = count + 1
            seqAn = cc.Sequence:create(cc.DelayTime:create(count*0.2),
                                    cc.Animate:create(open_ani),
                                    cc.CallFunc:create(
                                    function ()
                                        if i == 4 and j == 2 then 
                                            effectfunction()
                                        end
                                        if j == 2 then 
                                            self:showCardType(i)
                                        end
                                    end
                                    ))
            local card = self.m_CardArray[i][j]:runAction(cc.Sequence:create(seqAn,cc.CallFunc:create(function (ref)
                        ref:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("28gang_img_pai_front.png"))
                        local sprite = display.newSprite()
                            :setSpriteFrame(self:getCardImg(i,j))
                            :setTag(GameViewLayer.m_CardValue)
                            :setPosition(ref:getContentSize().width/2,ref:getContentSize().height/2)
                            :addTo(ref)
                     end)))
        end
    end   

    --刷新路单
    local vecRecord = {}
    if self.m_bUserOxCard[2] == 1 then 
        vecRecord.bWinShangMen = true
    else
        vecRecord.bWinShangMen = false
    end
    if self.m_bUserOxCard[3] == 1 then 
        vecRecord.bWinTianMen = true
    else
        vecRecord.bWinTianMen = false
    end
    if self.m_bUserOxCard[4] == 1 then 
        vecRecord.bWinXiaMen = true
    else
        vecRecord.bWinXiaMen = false
    end

    self:getDataMgr():addGameRecord(vecRecord)
    self:refreshGameRecord()
end
--显示用户下注
function GameViewLayer:showUserJetton(cmd_table)
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_JETTON then
        return
    end
    if cmd_table.cbJettonArea < 1 or cmd_table.cbJettonArea > 3 then 
        return 
    end
    local isMeJetton = 0
    local beginPos = userlistpoint
    if self:isMeChair(cmd_table.wChairID) == true then
        beginPos = selfheadpoint
        isMeJetton = 1
    end
    local endPos = self:getJettonPos(cmd_table.cbJettonArea+1)
    local spJetton = self:getJettonImage(cmd_table.lJettonScore)
    local pgold = cc.Sprite:createWithSpriteFrameName(spJetton)
    pgold:setPosition(beginPos)
    pgold.isMeJetton = isMeJetton
    pgold.score = cmd_table.lJettonScore
    self.m_goldLayer:addChild(pgold)

    pgold:runAction(cc.MoveTo:create(0.33, endPos)) 

    table.insert(self.m_goldList[cmd_table.cbJettonArea+1], pgold)
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
    local sp = "28gang_icon_chip"..tag..".png"
    return sp
end
function GameViewLayer:getJettonPos(Area)
    local nodeArea = self.m_scbNode:getChildByName("bt_area_"..Area)
    local nodeSize = cc.size(nodeArea:getContentSize().width - 135, nodeArea:getContentSize().height - 70);
	local xOffset = math.random()
	local yOffset = math.random()

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
    self.ToUserTime = 0
    local bWin = {0,0,0,0}        --庄家赢分
    for i=2,Game_CMD.AREA_COUNT do
        if self.m_bUserOxCard[i] <= 0 then
            self:showGoldToZ(i)
        else
            self:showGoldZToArea(i)
            self:showGoldToUser(i)
        end
    end   
end
function GameViewLayer:showGoldZToArea(cbArea)
    local goldnum = #self.m_goldList[cbArea]
    if goldnum == 0 then
        return
    end
    self.ToUserTime = goldnum*0.03+1
    for i = 1 ,goldnum do 
        local pgold = cc.Sprite:createWithSpriteFrameName(self:getJettonImage(self.m_goldList[cbArea][i].score))
        pgold.isMeJetton = 0
        if self.m_goldList[cbArea][i].isMeJetton == 1 then 
            pgold.isMeJetton = 1
        end
        pgold:setPosition(bankerheadpoint)
        self.m_goldLayer:addChild(pgold)
        table.insert(self.m_goldList[cbArea], pgold)
        local moveaction = self:getMoveAction(bankerheadpoint, self:getJettonPos(cbArea), 1, 0)
        pgold:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03), moveaction))
    end
end
function GameViewLayer:showGoldToZ(cbArea)
    local goldnum = #self.m_goldList[cbArea]
    if goldnum == 0 then
        return
    end
    for i=goldnum, 1, -1 do
        local pgold = self.m_goldList[cbArea][i]
        table.remove(self.m_goldList[cbArea], i)
        table.insert(self.m_goldList[1], pgold)
        if pgold then             
            local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), bankerheadpoint, 1, 0)
            pgold:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03), moveaction, cc.CallFunc:create(
                    function (ref)
                        ref:setVisible(false)
                    end
                )))            
        end
    end
end
function GameViewLayer:showGoldToUser(cbArea)
    local lJettonScore = self.m_lUserJettonScore[cbArea]
    if lJettonScore > 0 then
        self:showGoldToSelf(cbArea)
    end
    self:showGoldToOther(cbArea)
end
function GameViewLayer:showGoldToOther(cbArea)
    for i= 1 ,#self.m_goldList[cbArea] do 
        local pgold = self.m_goldList[cbArea][i]
        if pgold then   
            if pgold.isMeJetton ~= 1 then                   
                local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), userlistpoint, 1, 0)
                pgold:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03+self.ToUserTime), moveaction, cc.CallFunc:create(
                        function (ref)
                            ref:setVisible(false)
                        end
                    )))  
            end       
        end
    end
end
function GameViewLayer:showGoldToSelf(cbArea)
    for i= 1 ,#self.m_goldList[cbArea] do 
        local pgold = self.m_goldList[cbArea][i]
        if pgold then 
            if pgold.isMeJetton == 1 then       
                local moveaction = self:getMoveAction(cc.p(pgold:getPosition()), selfheadpoint, 1, 0)
                pgold:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03+self.ToUserTime), moveaction, cc.CallFunc:create(
                        function (ref)
                            ref:setVisible(false)
                        end
                    )))                
            end
        end
    end
end

function GameViewLayer:showGameEnd(bRecord)
    self:showAllWin(false)
    self:showAllLose(false)
    if self.m_cbGameStatus ~= Game_CMD.GAME_SCENE_END then
        return
    end
    if bRecord then 
        local record = Game_CMD.getEmptyGameRecord()
    end
    if nil == self.m_gameResultLayer then
        self.m_gameResultLayer = GameResultLayer:create(self)
            :addTo(self,GameViewLayer.ZORDER_3)
    end
    self.m_gameResultLayer:showGameResult(self.m_lSelfWinScore, self.m_lPlayScore[1], self.m_lBankerWinScore,self.m_alBankerWinScore,self.m_tagUserWinRank)
    self:onGetUserScore(self:getMeUserItem())
end

--显示提示
function GameViewLayer:showGameTips(showtype)
    local OldTip = self:getChildByTag(GameViewLayer.GAMETIP_BG) 
    if OldTip then 
        return 
    end
    local pimagestr = "28gang_img_title_changebanker.png"
    if showtype == TIP_TYPE.TypeChangBanker then
        pimagestr = "28gang_img_title_changebanker.png"
--    elseif showtype == TIP_TYPE.TypeSelfBanker then
--        pimagestr = "txt_banker_selficon.png"
--    elseif showtype == TIP_TYPE.TypeContinueSend then
--        pimagestr = "txt_continue_sendcard.png"
--    elseif showtype == TIP_TYPE.TypeReSend then
--        pimagestr = "txt_game_resortpoker.png"
    elseif showtype == TIP_TYPE.TypeBeginChip then
        pimagestr = "28gang_img_title_beginchip.png"
    elseif showtype == TIP_TYPE.TypeStopChip then    
        pimagestr = "28gang_img_title_stopchip.png"
    end

    local Tipbg = display.newSprite("#28gang_img_title_bg.png")
        :setPosition(cc.p(0,yl.DESIGN_HEIGHT/2))
        :setTag(GameViewLayer.GAMETIP_BG)
        :addTo(self,GameViewLayer.ZORDER_2)
    local ptipimage = cc.Sprite:createWithSpriteFrameName(pimagestr)
        :setPosition(Tipbg:getContentSize().width/2,Tipbg:getContentSize().height/2)
        :addTo(Tipbg)
    Tipbg:runAction(cc.Sequence:create( cc.MoveBy:create(0.3, cc.p(yl.DESIGN_WIDTH/2,0)), 
            cc.DelayTime:create(1),
            cc.MoveBy:create(0.3, cc.p(yl.DESIGN_WIDTH/2,0)), 
            cc.CallFunc:create(
            function()
                Tipbg:removeFromParent()
                if showtype == TIP_TYPE.TypeBeginChip then    
                    if self:isMeChair(self.m_wBankerUser) == false and (self.m_bEnableSysBanker ~= false or self.m_wBankerUser ~= yl.INVALID_CHAIR) then
                       self:setJettonEnable(true) 
                       self:updateJettonList(self.m_lUserMaxScore)        
                       self.m_bIsStartJetton = true
                    end                                  
                end
            end    
        )))
end

--刷新游戏记录
function GameViewLayer:refreshGameRecord()
    if nil ~= self.m_GameRecordLayer and self.m_GameRecordLayer:isVisible() then
        local recordList = self:getDataMgr():getGameRecord()     
        self.m_GameRecordLayer:refreshRecord(recordList)
    end
end

--刷新列表
function GameViewLayer:refreshApplyList()
    if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
        local userList = self:getDataMgr():getApplyBankerUserList()     
        self.m_applyListLayer:refreshList(userList)
    end
    self:resetCbList()
    self:refreshApplyBtnState()
end

--刷新申请列表按钮状态
function GameViewLayer:refreshApplyBtnState()
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
		ExternalFun.enableBtn(self.m_btnApply,true)
	end
end

--刷新用户分数
function GameViewLayer:onGetUserScore( useritem )
    --自己
    if useritem.dwUserID == GlobalUserItem.dwUserID then
        self.m_showScore = useritem.lScore + self.m_lSelfWinScore        
        self:resetSelfInfo()       
        self.m_lSelfWinScore = 0
    end

    --庄家
    if self.m_wBankerUser == useritem.wChairID then
        --庄家游戏币
        self.m_lBankerScore = useritem.lScore
        self:resetBankerInfo()
    end
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

return GameViewLayer

