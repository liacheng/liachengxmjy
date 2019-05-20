--
-- Author: zhong
-- Date: 2016-07-04 19:06:23
--
--游戏结果层
local GameResultLayer = class("GameResultLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local module_pre = "game.yule.baccaratnew.src"
local cmd = module_pre .. ".models.CMD_Game"
local CardSprite = module_pre .. ".views.layer.gamecard.CardSprite"

GameResultLayer.TAG_BANKERCARDLAYER = 201
GameResultLayer.TAG_PLAYERCARDLAYER = 202
function GameResultLayer:ctor( )
	local function btnEvent( sender, eventType )
        ExternalFun.btnEffect(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender)
		end
	end	

	--加载csb资源
	local csbNode = ExternalFun.loadCSB("game/GameResultLayer.csb",self)
    csbNode:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    csbNode:setAnchorPoint(cc.p(0.5, 0.5))

	local csbBg = csbNode:getChildByName("m_pIconBG")
    self.m_pTextBankerName      = csbBg:getChildByName("m_pTextBankerName")     -- 庄家名字
    self.m_pTextPlayerName      = csbBg:getChildByName("m_pTextPlayerName")     -- 玩家名字
    self.m_pTextBankerScore     = csbBg:getChildByName("m_pTextBankerScore")    -- 庄家分数
    self.m_pTextPlayerScore     = csbBg:getChildByName("m_pTextPlayerScore")    -- 玩家分数
    self.m_pIconPlayerNoChip    = csbBg:getChildByName("m_pIconPlayerNoChip")   -- 玩家未下注
    self.m_pNodePointBanker     = csbBg:getChildByName("m_pNodePointBanker")    -- 庄点数节点
    self.m_pNodePointPlayer     = csbBg:getChildByName("m_pNodePointPlayer")    -- 闲点数节点
    self.m_pBtnClose            = csbBg:getChildByName("m_pBtnClose")           -- 关闭按钮
    self.m_pBtnClose:addTouchEventListener(btnEvent)

	self.m_pTextPointZhuang = self.m_pNodePointBanker:getChildByName("m_pTextPointZhuang")   -- 庄点数
	self.m_pTextPointXian   = self.m_pNodePointPlayer:getChildByName("m_pTextPointXian")       -- 闲点数

    self._rankList = {}         -- 排行数据
    for i = 1, 5 do
        self._rankList[i] = {}
        self._rankList[i].name = csbBg:getChildByName(string.format("m_pNodeRank%d", i)):getChildByName("name")
        self._rankList[i].score = csbBg:getChildByName(string.format("m_pNodeRank%d", i)):getChildByName("score")
        
        self._rankList[i].name:setFontName(appdf.FONT_FILE)
        self._rankList[i].score:setFontName(appdf.FONT_FILE)

        if i == 4 or i == 5 then
            csbBg:getChildByName(string.format("m_pNodeRank%d", i)):getChildByName("icon"):setFontName(appdf.FONT_FILE)
        end
    end
    
    self.m_pTextBankerName:setFontName(appdf.FONT_FILE)
    self.m_pTextPlayerName:setFontName(appdf.FONT_FILE)

    
    self.m_pNodePointBanker:setLocalZOrder(1)
    self.m_pNodePointPlayer:setLocalZOrder(1)

    self.m_pCsbBg = csbBg
	self:hideGameResult()
end

function GameResultLayer:onButtonClickedEvent(tag,ref)
    ExternalFun.playClickEffect()
    self:hideGameResult()
end

function GameResultLayer:hideGameResult()
	self:reSet()
    ExternalFun.hideLayer(self, self, false, function() self:setVisible(false) end)
end

function GameResultLayer:showGameResult(rs, cardData, viewLayer)
	self:reSet()
	local str = ""
    local playerScore = rs.m_lPlayerTotalScore
    local bankerScore = rs.m_lBankerTotalScore
    local useritem = viewLayer:getMeUserItem()
    
    if useritem ~= nil then
        self.m_pTextPlayerName:setString(useritem.szNickName)
    end
    
    useritem = viewLayer:getDataMgr():getChairUserList()[rs.m_wBankerChairId + 1]
    if useritem == nil then
        self.m_pTextBankerName:setString("系统坐庄")
    else
        self.m_pTextBankerName:setString(useritem.szNickName)
    end

    if rs.m_bJoin then
	    if playerScore > 0 then
            ExternalFun.playSoundEffect("baccaratnew_end_win.mp3")
            ExternalFun.playSoundEffect("baccaratnew_end_win1.mp3")
		    str = "." .. playerScore
            self.m_pTextPlayerScore:setProperty(str, "baccaratnew_num_score_2.png", 27, 36, "*")
	    elseif playerScore < 0 then
            ExternalFun.playSoundEffect("baccaratnew_end_lost.mp3")
		    str = "/" .. math.abs(playerScore)
            self.m_pTextPlayerScore:setProperty(str, "baccaratnew_num_score_1.png", 27, 36, "*")
	    else
		    ExternalFun.playSoundEffect("baccaratnew_end_draw.mp3")
            self.m_pTextPlayerScore:setProperty("0", "baccaratnew_num_score_2.png", 27, 36, "*")
	    end
    else
        self.m_pTextPlayerScore:setString("")
        self.m_pIconPlayerNoChip:setVisible(true)
    end

	if bankerScore > 0 then
	    str = "." .. bankerScore
        self.m_pTextBankerScore:setProperty(str, "baccaratnew_num_score_2.png", 27, 36, "*")
	elseif bankerScore < 0 then
	    str = "/" .. math.abs(bankerScore)
        self.m_pTextBankerScore:setProperty(str, "baccaratnew_num_score_1.png", 27, 36, "*")
	else
        self.m_pTextBankerScore:setProperty("0", "baccaratnew_num_score_2.png", 27, 36, "*")
	end
	--合计

    local cardWidth = 55
    local cardHeight = 75

    local bankerCardLayer = cc.Node:create()
    bankerCardLayer:setPosition(cc.p(self.m_pNodePointBanker:getPositionX()-(#cardData.m_masterCards*cardWidth)/2, self.m_pNodePointBanker:getPositionY()-21))
    bankerCardLayer:setTag(GameResultLayer.TAG_BANKERCARDLAYER)
    self.m_pCsbBg:addChild(bankerCardLayer)

    local playerCardLayer = cc.Node:create()
    playerCardLayer:setPosition(cc.p(self.m_pNodePointPlayer:getPositionX()-(#cardData.m_idleCards*cardWidth)/2, self.m_pNodePointPlayer:getPositionY()-21))
    playerCardLayer:setTag(GameResultLayer.TAG_PLAYERCARDLAYER)
    self.m_pCsbBg:addChild(playerCardLayer)

    local cData = 1
    for i = 1, #cardData.m_masterCards do
        cData = cardData.m_masterCards[i]
        local card = g_var(CardSprite):createCard(cData)
        card:setPosition(cc.p(cardWidth/2+(i-1)*cardWidth, cardHeight/2))
        card:setScale(0.5)
        bankerCardLayer:addChild(card)
    end

    for i = 1, #cardData.m_idleCards do
        cData = cardData.m_idleCards[i]
        local card = g_var(CardSprite):createCard(cData)
        card:setPosition(cc.p(cardWidth/2+(i-1)*cardWidth, cardHeight/2))
        card:setScale(0.5)
        playerCardLayer:addChild(card)
    end
    
	--点数
	str = string.format("%d", rs.m_cbPlayerPoint)
	self.m_pTextPointXian:setString(str)
	str = string.format("%d", rs.m_cbBankerPoint)
	self.m_pTextPointZhuang:setString(str)

    for i = 1, 5 do
        useritem = nil
        if rs.m_tabRankList[i].wChairId ~= yl.INVALID_CHAIR then
            useritem = viewLayer:getDataMgr():getChairUserList()[rs.m_tabRankList[i].wChairId + 1]
        end
        if useritem ~= nil then
            local scoreStr = "+"..tostring(rs.m_tabRankList[i].lScore)
            self._rankList[i].name:setString(useritem.szNickName)
            self._rankList[i].score:setString(scoreStr)
        else
            self._rankList[i].name:setString("暂无排名")
            self._rankList[i].score:setString("")
        end
    end
    
    ExternalFun.showLayer(self, self, true, true)
end

function GameResultLayer:reSet( )
    local bankerCardLayer = self.m_pCsbBg:getChildByTag(GameResultLayer.TAG_BANKERCARDLAYER)
    local playerCardLayer = self.m_pCsbBg:getChildByTag(GameResultLayer.TAG_PLAYERCARDLAYER)

    if bankerCardLayer ~= nil then
        bankerCardLayer:removeFromParent()
    end

    if playerCardLayer ~= nil then
        playerCardLayer:removeFromParent()
    end

    self.m_pTextBankerName:setString("")
    self.m_pTextPlayerName:setString("")
    self.m_pTextBankerScore:setString("")
    self.m_pTextPlayerScore:setString("")
    self.m_pIconPlayerNoChip:setVisible(false)
	self.m_pTextPointZhuang:setString("")
	self.m_pTextPointXian:setString("")

    for i = 1, 5 do
        self._rankList[i].name:setString("")
        self._rankList[i].score:setString("")
    end
end
return GameResultLayer