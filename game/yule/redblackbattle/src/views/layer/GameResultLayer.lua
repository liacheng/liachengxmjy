--
-- Author: zhouweixiang
-- Date: 2016-12-27 17:55:44
--
--游戏结算层
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")

local GameResultLayer = class("GameResultLayer", cc.Layer)
local wincolor = cc.c3b(255, 247, 178)
local failedcolor = cc.c3b(178, 243, 255)

GameResultLayer.BT_CLOSE = 1

function GameResultLayer:ctor()

	self.m_ResultNode = nil
    self:initResultLayer()
end

function GameResultLayer:initResultLayer()

    local function btnEvent( sender, eventType )
         ExternalFun.btnEffect(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

	local csbNode = ExternalFun.loadCSB("GameResult.csb", self)
	self.m_ResultNode = csbNode

	local temp = csbNode:getChildByName("im_result_bg")
	self.m_spBg = temp

    --庄家名称
    self.m_BankerName = csbNode:getChildByName("txt_bankername")
        :setFontName("fonts/round_body.ttf")
    --庄家输赢分
    self.m_BankerScore = csbNode:getChildByName("txt_bankerscore")
    --玩家名称
    self.m_SelfName = csbNode:getChildByName("txt_selfname")
        :setFontName("fonts/round_body.ttf")
    --玩家输赢分
    self.m_SelfScore = csbNode:getChildByName("txt_selfscore")
    --玩家未下注
	self.m_SelfNoChip = csbNode:getChildByName("im_nochip")

    --关闭按钮
	self.m_BtnClose = csbNode:getChildByName("bt_close")
        :setTag(GameResultLayer.BT_CLOSE)
        :addTouchEventListener(btnEvent)
--	self.m_selfreturnscore = temp:getChildByName("txt_self_return")
--	self.m_bankerscore = temp:getChildByName("txt_banker_win")
--	local nousescore = temp:getChildByName("txt_banker_return")
--	nousescore:setVisible(false)
--    csbNode:setOpacity(220)
end


function GameResultLayer:showGameResult(selfscore, selfreturnscore, bankerscore)
	self.m_lselfscore = selfscore
	self.m_lselfreturnscore = selfreturnscore
	self.m_lbankerscore = bankerscore
	ExternalFun.showLayer(self, self,true,true,self.m_spBg,false)
    local score = selfscore - selfreturnscore
--    self:runWinLoseAnimate(score)
end

function GameResultLayer:setWinLoseScore()
     --庄家名称
    if self.m_parent.m_wBankerUser == yl.INVALID_CHAIR then
        self.m_BankerName:setString("系统坐庄")
    else
        local userItem = self.m_parent:getDataMgr():getChairUserList()[self.m_wBankerUser + 1]
        self.m_BankerName:setString(userItem.szNickName)
    end
    --庄家输赢分
    if self.m_lbankerscore < 0 then 
        self.m_BankerScore:setString("/"..math.abs(self.m_lbankerscore))
    else
        self.m_BankerScore:setString("."..math.abs(self.m_lbankerscore))
    end
    --玩家名称
    local userItem = self.m_parent:getMeUserItem()
    self.m_SelfName:setString(userItem.szNickName)   
    --玩家输赢分
    if self.m_lselfscore == 0 and self.m_lselfreturnscore == 0 then 
        self.m_SelfNoChip:setVisible(true)
        self.m_SelfScore:setVisible(false)
    else
        self.m_SelfNoChip:setVisible(false)
        self.m_SelfScore:setVisible(true)
        if self.m_lselfscore < 0 then 
            self.m_SelfScore:setString("/"..math.abs(self.m_lselfscore))
        else
            self.m_SelfScore:setString("."..math.abs(self.m_lselfscore))
        end
    end

	if self.m_lselfscore >= 0 then
		ExternalFun.playSoundEffect("gameWin.wav")
	else
		ExternalFun.playSoundEffect("gameLose.wav")
	end	
end

function GameResultLayer:setMenScore()

end
function GameResultLayer:setRankScore()
end

function GameResultLayer:onButtonClickedEvent(tag, ref)
    if GameResultLayer.BT_CLOSE == tag then
        ExternalFun.hideLayer(self, self, false)
    end
end
function GameResultLayer:clear()
	
end

return GameResultLayer