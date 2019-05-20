local GameViewLayer = class("GameViewLayer", function(scene)
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end )

local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameEndView = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.views.layer.GameEndView")
local AnimationMgr = appdf.req(appdf.EXTERNAL_SRC .. "AnimationMgr")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local SetLayer = appdf.req(appdf.GAME_SRC .. "yule.dzshowhand.src.views.layer.SetLayer")
local GameChatLayer = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local module_pre = "game.yule.dzshowhand.src"
local Define = appdf.req(module_pre .. ".models.Define")
local TAG_ENUM = Define.TAG_ENUM
local TAG_ZORDER = Define.TAG_ZORDERlocal cmd = appdf.req(module_pre .. ".models.CMD_Game")
local GameLogic = appdf.req(module_pre .. ".models.GameLogic")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

local posChat = { cc.p(175, 635), cc.p(175, 395), cc.p(524, 312), cc.p(1159, 395), cc.p(1159, 635), cc.p(1159, 395), cc.p(1159, 635), cc.p(1159, 395) }
local AddScoreMultiple = { 1, 3, 5, 10, 20 }   -- 加注选择

-- 按钮tag
GameViewLayer.BT_ADD                = 1
GameViewLayer.BT_FOLLOW             = 2
GameViewLayer.BT_GIVEUP             = 3
GameViewLayer.BT_SHOWHAND           = 4
GameViewLayer.BT_PASS               = 5
GameViewLayer.BT_READY              = 6
GameViewLayer.BT_EXIT               = 7
GameViewLayer.BT_CHAT               = 8
GameViewLayer.BT_SET                = 9
GameViewLayer.BT_GOLDCONTROL        = 10
GameViewLayer.BT_CHIP               = 11
GameViewLayer.BT_CHIP_1             = 12
GameViewLayer.BT_CHIP_2             = 13
GameViewLayer.BT_CHIP_3             = 14
GameViewLayer.BT_CHIP_4             = 15
GameViewLayer.BT_CHIP_5             = 16
GameViewLayer.BT_CHIP_6             = 17
GameViewLayer.BTN_HELP              = 18
GameViewLayer.BT_MENU               = 19

GameViewLayer.CHIPNUM               = 100
GameViewLayer.AddScoreBtnNum        = 6        -- 加注按钮个数
-- 动画参数
GameViewLayer.TO_USERCARD = 1     -- 用户扑克
GameViewLayer.TO_GIVEUP_CARD = 2     -- 回收扑克
GameViewLayer.TO_CENTER_CARD = 3     -- 中心扑克
GameViewLayer.TO_SHOWUSERCARD = 4    -- 显示用户扑克
GameViewLayer.TO_SHOWCENTER_CARD = 5 -- 显示中心扑克
-- 移动类型
GameViewLayer.AA_BASEFROM_TO_BASEDEST = 0     -- 底注筹码下注
GameViewLayer.AA_BASEDEST_TO_CENTER = 1     -- 加注筹码移至中间
GameViewLayer.AA_CENTER_TO_BASEFROM = 2     -- 中加筹码移至底注

function GameViewLayer:OnResetView()
    self:HideScoreControl()
    self:ClearnView()
    self:SetOperatStatus(yl.INVALID_CHAIR)
    self:OnCloseClockView()

    -- 设置游戏初始积分
    for i = 1, cmd.GAME_PLAYER do
        self:SetGameInitScore(i - 1, 0)
        self:SetTotalScore(i - 1, 0)
        self:SetCurUserMaxScore(i-1,0)
        self:SetUserTableScore(i - 1, 0)
    end
end

function GameViewLayer:onExit()
    print("GameViewLayer onExit")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(cmd.RES .. "game/card.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey(cmd.RES .. "game/card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("gameScene_oxex.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("gameScene_oxex.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function GameViewLayer:getParentNode()
    return self._scene
end

function GameViewLayer:GetMeChairID()
    return self._scene:GetMeChairID()
end

function GameViewLayer:GetMeViewID()
    return self:SwitchViewChairID(self:GetMeChairID())
end

function GameViewLayer:SwitchViewChairID(wChairID)
    return self._scene:SwitchViewChairID(wChairID)
end
-- 初始化
function GameViewLayer:ctor(scene)
    self._scene = scene	
    display.loadSpriteFrames(cmd.RES .. "game/card.plist", cmd.RES .. "game/card.png")
    display.loadSpriteFrames(cmd.RES .. "game/game.plist", cmd.RES .. "game/game.png")

    self.m_pCardLayer = nil          -- 扑克层    	                            
    self.m_chatLayer = nil	         -- 聊天层
    self.m_pGLPosNode = nil          -- 坐标节点   
    self.m_setLayer   = nil          -- 设置层    
    self.m_tGLPosTable = { }         -- 左边位置   
    self.m_tUserNode = { }           -- 用户节点 
    self.m_tOperator = { }           -- 操作按钮  
    self.m_tHandCard = { }           -- 手牌 
    for i = 1, GAME_PLAYER do
        self.m_tHandCard[i] = { }    
    end

    self.m_tCenterCard = { }         -- 中心扑克    
    self.m_UserChat = { }
    self.m_UserExpression = { }
    self.m_nChip = { }

    self.m_tSendCard = { }
    self.m_setLayer = SetLayer:create(self):addTo(self._scene, 4)
    self.m_chatLayer = GameChatLayer:create(self._scene._gameFrame):addTo(self._scene, 4)
    self.m_sparrowUserItem = { }

    -- 注册onExit()
    ExternalFun.registerNodeEvent(self)
    -- 注册touch事件
    ExternalFun.registerTouchEvent(self, false)

    -- 加载csb资源
    rootLayer, self._csbNode = ExternalFun.loadRootCSB("game/GameLayer.csb", self)
    local Panel_Btn = self._csbNode:getChildByName("Panel_Btn")	
	
	--聊天窗口层
	self.m_GameChat = GameChatLayer:create(scene._gameFrame)
		:setLocalZOrder(10)
        :addTo(self)

    -- 按钮回调
    local btcallback = function(ref, type)
        if type == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
        elseif type == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif type == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:OnButtonClickedEvent(ref:getTag(), ref)
        end
    end

    -- 筹码缓存
    self.nodeChipPool = cc.Node:create():addTo(self)

    -- 设置按钮	    
    ccui.Button:create("game/menu.png","")
    :setTag(GameViewLayer.BT_MENU)
    :move(yl.WIDTH-50,yl.HEIGHT-50)
	:addTo(self)
	:addTouchEventListener(btcallback)

    -- 退出按钮 
	ccui.Button:create("game/gb.png","")
	:setTag(GameViewLayer.BT_EXIT)
    :setVisible(false)
	--:move(870,220)
	:move(yl.WIDTH-50,yl.HEIGHT-127)
	:addTo(self)
	:addTouchEventListener(btcallback)

	--设置按钮
    ccui.Button:create("game/sz.png","")
	:setTag(GameViewLayer.BT_SET)
    :setVisible(false)
	--:move(870,220)
	:move(yl.WIDTH-50,yl.HEIGHT-204)
	:addTo(self)
	:addTouchEventListener(btcallback)

    --聊天按钮
	ccui.Button:create("game/lt.png","")
	:setTag(GameViewLayer.BT_CHAT)
    :setVisible(false)
	--:move(870,220)
	:move(yl.WIDTH-50,yl.HEIGHT-281)
	:addTo(self)
	:addTouchEventListener(btcallback)		
		
	--玩法按钮
	ccui.Button:create("game/wf.png","")
	:setTag(GameViewLayer.BTN_HELP)
    :setVisible(false)
	--:move(870,220)
	:move(yl.WIDTH-50,yl.HEIGHT-351)
	:addTo(self)
	:addTouchEventListener(btcallback)		

    -- 准备按钮
    self.m_BtnReady = self._csbNode:getChildByName("Button_Start")
    self.m_BtnReady:setTag(GameViewLayer.BT_READY)
    self.m_BtnReady:setVisible(true)
    self.m_BtnReady:addTouchEventListener(btcallback)

    -- 设置操作按钮
    --弃牌按钮
    local addScoreNode = self._csbNode:getChildByName("Panel_Btn")
	self.btnGiveUp = addScoreNode:getChildByName("Btn_GiveUp")
	self.btnGiveUp:setTag(GameViewLayer.BT_GIVEUP)
	self.btnGiveUp:setVisible(false)
	self.btnGiveUp:addTouchEventListener(btcallback)

    --让牌按钮
    self.btnNoAdd = addScoreNode:getChildByName("Btn_Pass")
	self.btnNoAdd:setTag(GameViewLayer.BT_PASS)
	self.btnNoAdd:setVisible(false)
	self.btnNoAdd:addTouchEventListener(btcallback)

	--跟注按钮   
	self.btnFollow = addScoreNode:getChildByName("Btn_Follow")
	self.btnFollow:setTag(GameViewLayer.BT_FOLLOW)
	self.btnFollow:setVisible(false)
	self.btnFollow:addTouchEventListener(btcallback)

    --全压按钮
	self.btnAddScoreAll = addScoreNode:getChildByName("Btn_ShowHand")
	self.btnAddScoreAll:setTag(GameViewLayer.BT_SHOWHAND)
	self.btnAddScoreAll:setVisible(false)
	self.btnAddScoreAll:addTouchEventListener(btcallback)

    --加注按钮
	self.btnAdd = addScoreNode:getChildByName("Btn_Add")
	self.btnAdd:setTag(GameViewLayer.BT_ADD)
	self.btnAdd:setVisible(false)
	self.btnAdd:addTouchEventListener(btcallback)

    -- 获取扑克层
    self.m_pCardLayer = self._csbNode:getChildByName("GameCardLayer")

    -- 初始化用户信息
    self._csbNode:getChildByName("UserInfoNode"):setVisible(false)
    self.m_pGLPosNode = self._csbNode:getChildByName("GLPosNode")
    self.m_tGLPosTable.UserInfo = { }
    for i = 1, GAME_PLAYER do
        local sGLName = string.format("UserInfo_%02d", i)
        local pos = cc.p(self.m_pGLPosNode:getChildByName(sGLName):getPosition())
        local UserNode, csbNode = ExternalFun.loadRootCSB("game/UserInfoNode.csb", self)
        self.m_tUserNode[i] = csbNode
        self.m_tUserNode[i]:setVisible(false)
        self.m_tUserNode[i]:setPosition(pos)
        self.m_tUserNode[i]:setScale(0.8)
        self.m_tUserNode[i]:getChildByName("Img_Card_01"):setVisible(false)
        self.m_tUserNode[i]:getChildByName("Img_Card_02"):setVisible(false)
        self.m_tUserNode[i]:getChildByName("Img_Status"):setVisible(false)
        self.m_tUserNode[i]:getChildByName("zhuangflag"):setVisible(false)

        self.m_tGLPosTable.UserInfo[i] = pos
    end

    -- 获取坐标位置
    self.m_tGLPosTable.SendCardStart = cc.p(self.m_pGLPosNode:getChildByName("SendCardStart"):getPosition())
    self.m_tGLPosTable.CenterCardStart = cc.p(self.m_pGLPosNode:getChildByName("CenterCardStart"):getPosition())
    self.m_tGLPosTable.ChipStart = cc.p(self.m_pGLPosNode:getChildByName("Node_Chip"):getPosition())
--    self.m_pGLPosNode:getChildByName("SendCardStart"):setVisible(false)
    for i = 1, 5 do
        self.m_tSendCard[i] = self.m_pGLPosNode:getChildByName("Img_Card_" .. i)
        self.m_tSendCard[i]:setVisible(false)
    end

    -- 筹码加注选择界面
    -- 加注节点
    self._AddScoreNode = self._csbNode:getChildByName("AddScoreNode")
    local AddScoreNode, AddScoreCSBNode = ExternalFun.loadRootCSB("game/AddScoreNode.csb", self._AddScoreNode)
    -- self._AddScoreNode:addChild(AddScoreCSBNode)
    AddScoreCSBNode:move(280, 0)
    -- 加注背景
    self.m_ChipBG = AddScoreCSBNode:getChildByName("AddScoreBg")
    self.m_ChipBG:setTag(GameViewLayer.BT_GOLDCONTROL)
    self.m_ChipBG:setVisible(false)   

    -- 添加加注选择按钮
    self.btChip = { }
    for i = 1, GameViewLayer.AddScoreBtnNum do
        self.btChip[i] = self.m_ChipBG:getChildByName("Button_" .. i)
        :setPressedActionEnabled(true)
        :setTag(GameViewLayer.BT_CHIP + i)
        self.btChip[i]:addTouchEventListener(btcallback)

        -- 文本
        local AddScoreText = self.btChip[i]:getChildByName("Text_1")
        :setTag(GameViewLayer.CHIPNUM)
    end
    -- 中心奖池分数
    self.TotalScore = self._csbNode:getChildByName("Img_TotalScore"):setVisible(false)

    -- 聊天泡泡框
    self.m_UserChatView = { }
    for i = 1, cmd.GAME_PLAYER do
        local strFile = ""
        if i == 1 or i == 4 then
            strFile = "#sp_bubble_2.png"
        else
            strFile = "#sp_bubble_1.png"
        end
        self.m_UserChatView[i] = display.newSprite(strFile, { scale9 = true, capInsets = cc.rect(0, 0, 204, 68) })
        :setAnchorPoint(cc.p(0.5, 0.5))
        :move(0, 100)
        :setVisible(false)
        :addTo(self.m_tUserNode[i], 3)
    end

    AnimationMgr.loadAnimationFromFrame("record_play_ani_%d.png", 1, 3, cmd.VOICE_ANIMATION_KEY)
end

-- 隐藏控制
function GameViewLayer:HideScoreControl()
    self.btnGiveUp:setVisible(false)
    self.btnNoAdd:setVisible(false)
    self.btnFollow:setVisible(false)
    self.btnAddScoreAll:setVisible(false)
    self.btnAdd:setVisible(false)
end

-- 设置私有房的层级
function GameViewLayer:priGameLayerZorder()
    return 9
end

-- 设置庄家
function GameViewLayer:SetDFlag(wDUserChairID, isZhuang)
    local nViewID = self:SwitchViewChairID(wDUserChairID)
    local ZhuangFlag = self.m_tUserNode[nViewID]:getChildByName("zhuangflag")
    ZhuangFlag:setVisible(isZhuang)
    ZhuangFlag:setLocalZOrder(6)
end
--设置用户每局携带分数
function GameViewLayer:SetCurUserMaxScore(wChairID,CurUserMaxScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 筹码
    local Text_UserCurScore = self.m_tUserNode[nViewID]:getChildByName("Img_UserCurScore"):getChildByName("Text")
    Text_UserCurScore:setString(tostring(CurUserMaxScore))
end
-- 设置每人当局下注
function GameViewLayer:SetTotalScore(wChairID, lTotalScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 筹码
    local Text_Chip = self.m_tUserNode[nViewID]:getChildByName("Img_Chip"):getChildByName("Text")
    Text_Chip:setString(tostring(lTotalScore))
end

-- 设置当轮下注
function GameViewLayer:SetUserTableScore(wChairID, lTableScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 筹码
    local Text_TableChip = self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):getChildByName("Text")
    Text_TableChip:setString(tostring(lTableScore))
end

-- 设置游戏初始积分（改成每人总是输赢）
function GameViewLayer:SetGameInitScore(wChairID, lGameInitScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 用户积分
    local Text_UserGameScore = self.m_tUserNode[nViewID]:getChildByName("Img_Coin"):getChildByName("Text")
    Text_UserGameScore:setString(tostring(lGameInitScore))
end

-- 设置中心分数
function GameViewLayer:SetCenterScore(lCenterScore)
    self.TotalScore:setVisible(true)
    local text = self.TotalScore:getChildByName("Text_TotalScore")
    text:setString(tostring(lCenterScore))
end

-- 设置开牌数据
function GameViewLayer:SetCardData(wChairID, tCardData, bGray)
    assert(type(tCardData) == "table" and #tCardData == 2)
    local nViewID = self:SwitchViewChairID(wChairID)
    for i, obj in ipairs(self.m_tHandCard[nViewID]) do
        self:UpdateCardSpriteByValue(obj, tCardData[i])
        if bGray then
            obj:setColor(cc.c3b(77, 77, 77))
        end
    end
end

-- 设置操作状态
function GameViewLayer:SetOperatStatus(wChairID, cbStatus)
    assert(wChairID)
    local nViewID = self:SwitchViewChairID(wChairID)
    if wChairID == yl.INVALID_CHAIR then
        for i = 1, GAME_PLAYER do
            self.m_tUserNode[i]:getChildByName("Img_Status"):setVisible(false)
        end
    else
        local Img_Status = self.m_tUserNode[nViewID]:getChildByName("Img_Status")
        Img_Status:setVisible(true)
        local text = Img_Status:getChildByName("Text")
        local strBtOperatorInfo = {  [GameViewLayer.BT_GIVEUP] = "弃牌", [GameViewLayer.BT_FOLLOW] = "跟注",[GameViewLayer.BT_ADD] = "加注", [GameViewLayer.BT_SHOWHAND] = "全下",  [GameViewLayer.BT_PASS] = "让牌",}
        text:setString(strBtOperatorInfo[cbStatus])
    end
end
--设置赢的状态
function GameViewLayer:WinerFlag(wChairID,String)
   local nViewID = self:SwitchViewChairID(wChairID)
    local Text_Name = self.m_tUserNode[nViewID]:getChildByName("UserName")
    Text_Name:setColor(cc.c3b(155,165,0))
    Text_Name:setString(tostring(String))
end
-- 创建牌
function GameViewLayer:CreateCardSpriteByValue(cbCardData)
    assert(cbCardData, 'cbCardData is nil')
    local obj = ccui.ImageView:create(string.format("card_%02d.png", cbCardData), ccui.TextureResType.plistType)
    obj:setTag(cbCardData)
    return obj
end

-- 更新牌值
function GameViewLayer:UpdateCardSpriteByValue(obj, cbCardData)
    assert(obj)
    local sName = string.format("card_%02d.png", cbCardData)
    obj:loadTexture(sName, UI_TEX_TYPE_PLIST)
end

-- 更新时钟
function GameViewLayer:OnUpdataClockView(nViewID, nTimes)
    if not nViewID or nViewID == yl.INVALID_CHAIR then
        return
    end
    local Img_Clock = self.m_tUserNode[nViewID]:getChildByName("Img_Clock")
    Img_Clock:setVisible(true)
    local Text = Img_Clock:getChildByName("Text")
    Text:setString(string.format("%02d", nTimes))
end

-- 关闭时钟
function GameViewLayer:OnCloseClockView(nViewID)
    for i = 1, GAME_PLAYER do
        local Img_Clock = self.m_tUserNode[i]:getChildByName("Img_Clock")
        Img_Clock:setVisible(false)
    end
end

-- 更新用户显示
function GameViewLayer:OnUpdateUser(nViewID, userItem)
    if not nViewID or nViewID == yl.INVALID_CHAIR then
        print("OnUpdateUser viewid is nil")
        return
    end
    self.m_sparrowUserItem[nViewID] = userItem
    self.m_tUserNode[nViewID]:setVisible(userItem ~= nil)

    if not userItem then
        return
    else
        -- 准备标识
        self.m_tUserNode[nViewID]:getChildByName("Image_Ready"):setVisible(yl.US_READY == userItem.cbUserStatus)
        -- 头像
        local head = self.m_tUserNode[nViewID]:getChildByName("head")
        -- 头像背景
        local Img_Head = self.m_tUserNode[nViewID]:getChildByName("Img_Head")
        -- 用户初始积分
        local Text_Coin = self.m_tUserNode[nViewID]:getChildByName("Img_Coin"):getChildByName("Text")
        -- 用户累计下注
        local Text_Chip = self.m_tUserNode[nViewID]:getChildByName("Img_Chip"):getChildByName("Text")
        -- 用户当轮下注
        local Text_TableChip = self.m_tUserNode[nViewID]:getChildByName("Img_TableChip"):getChildByName("Text")
        -- 状态
        local Img_Status = self.m_tUserNode[nViewID]:getChildByName("Img_Status")
        -- 昵称
        local Text_Name = self.m_tUserNode[nViewID]:getChildByName("UserName")
        -- 关闭时钟
        self:OnCloseClockView(nViewID)
        --金币		
        Img_Head:setVisible(false)
        Text_Coin:setString(userItem.lScore)
        Text_Chip:setString("0")
        Text_TableChip:setString("0")
        Text_Name:setString(userItem.szNickName)        

        --头像
		if not head then
			head = PopupInfoHead:createClipHead(userItem, 80,"game/hkfivecardnew_bg_headBg2.png")           
			head:setPosition(cc.p(Img_Head:getPosition()))			--初始位置
			head:enableHeadFrame(false)			
			self.m_tUserNode[nViewID]:addChild(head)
            --点击弹出的位置
	        if nViewID < 3 then
		        --head:enableInfoPop(true, cc.p(70,162), cc.p(0.2, 0.5))
	        elseif nViewID > 3 then
		        --head:enableInfoPop(true, cc.p(300,162), cc.p(0.8, 0.5))
	        else    
		        --head:enableInfoPop(true, cc.p(140,100), cc.p(0.5, 0.5))		
	        end
		else
			head:updateHead(userItem)
		end
		head:setVisible(true) 
    end
end

-- 注册触摸
function GameViewLayer:onTouchBegan(touch, event)
    return self.m_ChipBG:isVisible()
end

function GameViewLayer:onTouchMoved(touch, event)

end

function GameViewLayer:onTouchEnded(touch, event)
    local touchPos = touch:getLocation()
    touchPos = self.m_ChipBG:convertToNodeSpace(touchPos)
    local rect = self.m_ChipBG:getBoundingBox()
    if not cc.rectContainsPoint(rect, touchPos) then
        self.m_ChipBG:setVisible(false)
        self._scene:UpdateScoreControl()
    end
end

-- 筹码移动动画
function GameViewLayer:ChipMoveAction(wViewChairId, num, notani)
    if not num or num < 1 or not self.m_lCellScore or self.m_lCellScore < 1 then
        return
    end
    if num > self.m_nChip[#self.m_nChip] then
        num = self.m_nChip[#self.m_nChip] * 3
    end
    local chipscore = num
    while
        chipscore > 0
    do
        local strChip
        local strScore
        if chipscore >= self.m_lCellScore * self.m_nChip[3] then
            strChip = "#bigchip_2.png"
            chipscore = chipscore - self.m_lCellScore * self.m_nChip[3]
            strScore =(self.m_lCellScore * self.m_nChip[3]) .. ""
        elseif chipscore >= self.m_lCellScore * self.m_nChip[2] then
            strChip = "#bigchip_1.png"
            chipscore = chipscore - self.m_lCellScore * self.m_nChip[2]
            strScore =(self.m_lCellScore * self.m_nChip[2]) .. ""
        else
            strChip = "#bigchip_0.png"
            chipscore = chipscore - self.m_lCellScore
            strScore = self.m_lCellScore .. ""
        end
        local chip = display.newSprite(strChip)
        :setScale(0.5)
        :setPosition(cc.p(self.m_tUserNode[wViewChairId]:getPosition()))
        :addTo(self.nodeChipPool)

        cc.Label:createWithTTF(strScore, appdf.FONT_FILE, 30)
        :move(54, 53)
        :setColor(cc.c3b(48, 48, 48))
        :addTo(chip)

        chip:runAction(cc.MoveTo:create(0.2, cc.p(self.m_tGLPosTable.ChipStart.x + math.random(600), self.m_tGLPosTable.ChipStart.y + math.random(-50))))

    end
    if not notani then
        self._scene:PlaySound(cmd.RES .. "sound_res/ADD_SCORE.wav")
    end
end

-- 清理视图
function GameViewLayer:ClearnView()
    self:ClearnCard()
    self:ClearnClip()
end

-- 清理筹码
function GameViewLayer:ClearnClip()
    self.nodeChipPool:removeAllChildren()
end

-- 清理牌
function GameViewLayer:ClearnCard()
    self.m_pCardLayer:removeAllChildren()
    for i = 1, GAME_PLAYER do
        self.m_tHandCard[i] = { }
    end
    self.m_tCenterCard = { }
end

-- 筹码移动
function GameViewLayer:DrawMoveAnte(wChairID, iMoveType, lTableScore)
    local nViewID = self:SwitchViewChairID(wChairID)
    if iMoveType == GameViewLayer.AA_BASEFROM_TO_BASEDEST then
        -- 底注筹码下注（玩家加注）
        -- self:ChipMoveAction(nViewID,lTableScore,false)
    elseif iMoveType == GameViewLayer.AA_CENTER_TO_BASEFROM then
        -- 中间筹码移至下注（赢的人）
        self:WinTheChipAction(nViewID)
    elseif iMoveType == GameViewLayer.AA_BASEDEST_TO_CENTER then
        -- 加注合并到中间(下注完成)
    end

    self._scene:PlaySound(cmd.RES .. "sound_res/ADD_SCORE.wav")
end

-- 发牌动画
function GameViewLayer:SendCardAction(wChairID, cbCardData, SendCardType)
    local fDelay = 0.2
    -- 用户校验
    if not wChairID or wChairID == yl.INVALID_CHAIR then
        return
    end
    -- 转换视图
    local nViewID = self:SwitchViewChairID(wChairID)
    -- 是否显示牌值
    local isShowCardValue = false
    local fScale = 1.0
    local fMoveTimes = 0.2
    -- 起始发牌位置
    local SendCardStartNode = self.m_pGLPosNode:getChildByName("SendCardStart")
    local SendCardStartPos = self.m_tGLPosTable.SendCardStart
    -- 创建背面牌
    local spCard = self:CreateCardSpriteByValue(0x00)
    spCard:setPosition(cc.p(SendCardStartPos.x + 30, SendCardStartPos.y + 5))
    spCard:addTo(self.m_pCardLayer)
    -- 目的位置
    local EndPos = nil
    if SendCardType == GameViewLayer.TO_USERCARD then
        -- 用户扑克
        local nIndex = #self.m_tHandCard[nViewID] + 1
        local UserPos = cc.p(self.m_tUserNode[nViewID]:getPosition())
        local Spacing = 40 *(nIndex - 1) + 100
        -- 间距
        if self:GetMeChairID() == wChairID then
            Spacing = 70 *(nIndex - 1) + 100
            isShowCardValue = true
        end
        EndPos = cc.p(UserPos.x + Spacing, UserPos.y)
        self.m_tHandCard[nViewID][nIndex] = spCard

        -- 创建发牌动画
        spCard:runAction(cc.Sequence:create(cc.DelayTime:create(fDelay * nIndex),
        cc.Spawn:create(
        cc.ScaleTo:create(fMoveTimes, fScale),
        cc.MoveTo:create(fMoveTimes, EndPos)),
        cc.CallFunc:create( function()
            -- 如果是自己，显示牌值
            if isShowCardValue then
                self:UpdateCardSpriteByValue(spCard, cbCardData)
            end
        end )))

        -- 更新操作
        self._scene:OnSendFinish()
    elseif SendCardType == GameViewLayer.TO_CENTER_CARD then
        -- 中心扑克
        local nIndex = #self.m_tCenterCard + 1
        local pos = cc.p(self.m_tSendCard[nIndex]:getPosition())
        fScale = self.m_tSendCard[nIndex]:getScale()
        spCard:setPosition(pos)
        spCard:setScale(fScale)
        self.m_tCenterCard[nIndex] = spCard

        -- 创建翻牌动画
        local OrbitCamera1 = cc.OrbitCamera:create(fMoveTimes, 1, 0, 0, -90, 0, 0)
        local OrbitCamera2 = cc.OrbitCamera:create(fMoveTimes, 1, 0, 90, -90, 0, 0)
        spCard:runAction(cc.Sequence:create(OrbitCamera1, cc.CallFunc:create( function()
            self:UpdateCardSpriteByValue(spCard, cbCardData)
        end ), OrbitCamera2))

        -- 更新操作
        self._scene:OnSendFinish()
        -- 断线重连，显示用户牌值
    elseif SendCardType == GameViewLayer.TO_SHOWUSERCARD then
        local nIndex = #self.m_tHandCard[nViewID] + 1
        local UserPos = cc.p(self.m_tUserNode[nViewID]:getPosition())
        local Spacing = 40 *(nIndex - 1) + 100
        -- 间距
        if self:GetMeChairID() == wChairID then
            Spacing = 70 *(nIndex - 1) + 100
            isShowCardValue = true
        end
        EndPos = cc.p(UserPos.x + Spacing, UserPos.y)
        self.m_tHandCard[nViewID][nIndex] = spCard
        spCard:setScale(fScale)
        spCard:setPosition(EndPos)

        -- 如果是自己，显示牌值
        if isShowCardValue then
            self:UpdateCardSpriteByValue(spCard, cbCardData)
        end

        -- 更新操作
        self._scene:OnSendFinish()
        -- 断线重连，显示中心牌值
    elseif SendCardType == GameViewLayer.TO_SHOWCENTER_CARD then
        -- 中心扑克
        local nIndex = #self.m_tCenterCard + 1
        local pos = cc.p(self.m_tSendCard[nIndex]:getPosition())
        fScale = self.m_tSendCard[nIndex]:getScale()
        spCard:setPosition(pos)
        spCard:setScale(fScale)
        self.m_tCenterCard[nIndex] = spCard

        self:UpdateCardSpriteByValue(spCard, cbCardData)

        -- 更新操作
        self._scene:OnSendFinish()
    end
end

-- 移动扑克
function GameViewLayer:DrawMoveCard(wChairID, iMoveType, cbCardData)
    local nViewID = self:SwitchViewChairID(wChairID)
    if iMoveType == GameViewLayer.TO_USERCARD then               -- 用户扑克       
        self:SendCardAction(wChairID, cbCardData, GameViewLayer.TO_USERCARD)
    elseif iMoveType == GameViewLayer.TO_SHOWUSERCARD then       -- 用户扑克(不要动画效果，用于断线重连)       
        self:SendCardAction(wChairID, cbCardData, GameViewLayer.TO_SHOWUSERCARD)
    elseif iMoveType == GameViewLayer.TO_CENTER_CARD then        -- 中心扑克
        self:SendCardAction(wChairID, cbCardData, GameViewLayer.TO_CENTER_CARD)
    elseif iMoveType == GameViewLayer.TO_SHOWCENTER_CARD then    -- 中心扑克(不要动画效果，用于断线重连)        
        self:SendCardAction(wChairID, cbCardData, GameViewLayer.TO_SHOWCENTER_CARD)
    elseif iMoveType == GameViewLayer.TO_GIVEUP_CARD then
        -- 回收扑克(弃牌)
    end
end

-- 设置底分
function GameViewLayer:SetCellScore(m_lCellScore)
    self.m_lCellScore = m_lCellScore
end

-- 赢得筹码动画
function GameViewLayer:WinTheChipAction(wWinnerViewID)
    -- 筹码动作
    local children = self.nodeChipPool:getChildren()
    for k, v in pairs(children) do
        v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 *(#children - k)),
        cc.MoveTo:create(0.5, cc.p(self.m_tUserNode[wWinnerViewID]:getPosition())),
        cc.CallFunc:create( function()
            self.nodeChipPool:removeAllChildren()
        end )))
    end
end


-- 按键响应
function GameViewLayer:OnButtonClickedEvent(tag, ref)
    if tag == GameViewLayer.BT_EXIT then
        self._scene:onQueryExitGame()
    elseif tag == GameViewLayer.BT_READY then         -- 准备        
        self.m_BtnReady:setVisible(false)
        self._scene:onStartGame(true)
    elseif tag == GameViewLayer.BT_GIVEUP then        -- 弃牌        
        self._scene:OnGiveUp()
    elseif tag == GameViewLayer.BT_ADD then           -- 加注        
        self._scene:OnAddScore()
    elseif tag == GameViewLayer.BT_CHIP_1 then
        self._scene:OnOKScore(self.m_nChip[1])
    elseif tag == GameViewLayer.BT_CHIP_2 then
        self._scene:OnOKScore(self.m_nChip[2])
    elseif tag == GameViewLayer.BT_CHIP_3 then
        self._scene:OnOKScore(self.m_nChip[3])
    elseif tag == GameViewLayer.BT_CHIP_4 then
        self._scene:OnOKScore(self.m_nChip[4])
    elseif tag == GameViewLayer.BT_CHIP_5 then
        self._scene:OnOKScore(self.m_nChip[5])
    elseif tag == GameViewLayer.BT_FOLLOW then         -- 跟注       
        self._scene:OnFollow()
        -- elseif tag == BT_SHOWHAND then
    elseif tag == GameViewLayer.BT_CHIP_6  then     -- 梭哈（全下）        
        self._scene:OnShowHand()
    elseif tag == GameViewLayer.BT_PASS then               -- 让牌       
        self._scene:OnPassCard()
    elseif tag == GameViewLayer.BT_CHAT then
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
    elseif tag == GameViewLayer.BT_SET then
			print("设置")
		self.m_setLayer:showLayer()    
    elseif  GameViewLayer.BTN_HELP == tag then                --玩法
       self._scene._scene:popHelpLayer2(cmd.KIND_ID, 0)
    elseif GameViewLayer.BT_MENU == tag then
        print("这是菜单")
        local bt_gb = self:getChildByTag(GameViewLayer.BT_EXIT)
        local bt_sz = self:getChildByTag(GameViewLayer.BT_SET)
        local bt_lt = self:getChildByTag(GameViewLayer.BT_CHAT)
        local bt_wf = self:getChildByTag(GameViewLayer.BTN_HELP)
        if bt_gb:isVisible() == true then
            bt_gb:setVisible(false)
            bt_sz:setVisible(false)
            bt_lt:setVisible(false)
            bt_wf:setVisible(false)
        else
            bt_gb:setVisible(true)
            bt_sz:setVisible(true)
            bt_lt:setVisible(true)
            bt_wf:setVisible(true)
        end
    end
	
end

function GameViewLayer:ShowMenu(bShow)
	local this = self
	if self.m_bShowMenu ~= bShow then
		self.m_bShowMenu = bShow
		
		if self.m_bShowMenu == true and not self.m_AreaMenu:isVisible() then
			self.m_AreaMenu:setVisible(true)
			self.m_AreaMenu:runAction(
				cc.Sequence:create(
					cc.MoveTo:create(0.3,cc.p(240 + 96,692)),
					cc.CallFunc:create(
					function()
						this:setMenuBtnEnabled(true)
					end
				)))
		
		end
	end
end

-- 更新可以加注的按钮
function GameViewLayer:UpdateAddScoreBtn(canAddMaxScore,lTotalScore)
    for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
        local isShow =(canAddMaxScore >= (self.m_nChip[i] +lTotalScore))
        self.btChip[i]:setVisible(isShow)
    end
        self.btChip[GameViewLayer.AddScoreBtnNum]:setVisible(true)
end

-- 显示隐藏按钮
function GameViewLayer:ShowWindow(nTag, bShow)

end

-- 显示聊天
function GameViewLayer:ShowUserChat(viewid, message)
    if message and #message > 0 then
        self.m_chatLayer:showGameChat(false)
        -- 取消上次
        if self.m_UserChat[viewid] then
            self.m_UserChat[viewid]:stopAllActions()
            self.m_UserChat[viewid]:removeFromParent()
            self.m_UserChat[viewid] = nil
        end

        -- 创建label
        local limWidth = 24 * 12
        local labCountLength = cc.Label:createWithTTF(message, appdf.FONT_FILE, 24)
     --   if labCountLength:getContentSize().width > limWidth then
            self.m_UserChat[viewid] = cc.Label:createWithTTF(message, appdf.FONT_FILE, 24, cc.size(limWidth, 0))
       -- else
        --    self.m_UserChat[viewid] = cc.Label:createWithTTF(message, appdf.FONT_FILE, 24)
      --  end

        self.m_UserChat[viewid]:setColor(cc.c3b(255, 255, 255))
        self.m_UserChat[viewid]:move(150, 30)
        self.m_UserChat[viewid]:setAnchorPoint(cc.p(0.5, 0))
        self.m_UserChat[viewid]:addTo(self.m_UserChatView[viewid], 3)

        -- 改变气泡大小
        self.m_UserChatView[viewid]:setContentSize(self.m_UserChat[viewid]:getContentSize().width + 28, self.m_UserChat[viewid]:getContentSize().height + 27)
        :setVisible(true)
        -- 动作
        self.m_UserChat[viewid]:runAction(cc.Sequence:create(
        cc.DelayTime:create(3),
        cc.CallFunc:create( function()
            self.m_UserChatView[viewid]:setVisible(false)
            self.m_UserChat[viewid]:removeFromParent()
            self.m_UserChat[viewid] = nil
        end )
        ))
    end
end

-- 显示表情
function GameViewLayer:ShowUserExpression(wViewChairId, wItemIndex)
    if wItemIndex and wItemIndex >= 0 then
        self.m_chatLayer:showGameChat(false)
        -- 取消上次
        if self.m_UserExpression[wViewChairId] then
            self.m_UserExpression[wViewChairId]:stopAllActions()
            self.m_UserExpression[wViewChairId]:removeFromParent()
            self.m_UserExpression[wViewChairId] = nil
        end
        -- 创建表情
        local strName = string.format("e(%d).png", wItemIndex)
        local m_UserExpressionView = cc.Sprite:createWithSpriteFrameName(strName)
        self.m_UserExpression[wViewChairId] = m_UserExpressionView
        self.m_UserExpression[wViewChairId]:setAnchorPoint(cc.p(0.5, 0))
        self.m_UserExpression[wViewChairId]:move(50, 50)
        self.m_UserChatView[wViewChairId]:addChild(self.m_UserExpression[wViewChairId], 3)

        -- 改变气泡大小
        self.m_UserChatView[wViewChairId]:setContentSize(90, 100)
        :setVisible(true)

        self.m_UserExpression[wViewChairId]:runAction(cc.Sequence:create(
        cc.DelayTime:create(3),
        cc.CallFunc:create( function(ref)
            self.m_UserChatView[wViewChairId]:setVisible(false)
            self.m_UserExpression[wViewChairId]:removeFromParent()
            self.m_UserExpression[wViewChairId] = nil
        end )))
    end
end

--录音开始
function GameViewLayer:onUserVoiceStart(viewid)
    -- 取消文字，表情
        self.m_chatLayer:showGameChat(false)
        -- 取消上次
        if self.m_UserExpression[viewid] then
            self.m_UserExpression[viewid]:stopAllActions()
            self.m_UserExpression[viewid]:removeFromParent()
            self.m_UserExpression[viewid] = nil
        end

    -- 语音动画
    local param = AnimationMgr.getAnimationParam()
    param.m_fDelay = 0.1
    param.m_strName = cmd.VOICE_ANIMATION_KEY
    local animate = AnimationMgr.getAnimate(param)
    self.m_actVoiceAni = cc.RepeatForever:create(animate)

    self.m_UserExpression[viewid] = display.newSprite( yl.PNG_PUBLIC_BLANK )
    :move(posChat[viewid].x, posChat[viewid].y + 15)
    :setAnchorPoint(cc.p(0.5, 0.5))
    :addTo(self, 3)
    if viewId == 2 or viewId == 3 then
        self.m_UserExpression[viewid]:setRotation(180)
    end
    self.m_UserExpression[viewid]:runAction(self.m_actVoiceAni)

    -- 改变气泡大小
    self.m_UserChatView[viewid]:setContentSize(90, 100)
    :setVisible(true)
end
--录音结束
function GameViewLayer:onUserVoiceEnded(viewId)
    if self.m_UserExpression[viewId] then
        self.m_UserExpression[viewId]:removeFromParent()
        self.m_UserExpression[viewId] = nil
        self.m_UserChatView[viewId]:setVisible(false)
    end
end
-- 更新加注倍数
function GameViewLayer:UpdataAddScoreMultiple(cellscore)
    if cellscore == 0 or cellscore == nil then
        cellscore = 1
    end
    if not AddScoreMultiple or not cellscore then
        for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
            self.btChip[i]:getChildByTag(CHIPNUM):setString("0")
        end
        return
    end

    -- 设置倍数
    for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
        self.m_nChip[i] = AddScoreMultiple[i] + cellscore
    end

    -- 设置下注倍数
    for i = 1, GameViewLayer.AddScoreBtnNum - 1 do
        self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString(self.m_nChip[i])
    end
    self.btChip[GameViewLayer.AddScoreBtnNum]:getChildByTag(GameViewLayer.CHIPNUM):setString("全下")
end

return GameViewLayer