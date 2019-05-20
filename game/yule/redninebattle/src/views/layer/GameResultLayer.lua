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

function GameResultLayer:ctor(viewParent)
	self.m_parent = viewParent

	self.m_ResultNode = nil
end

function GameResultLayer:initResultLayer()
	local csbNode = ExternalFun.loadCSB("GameResult.csb", self)
	csbNode:setVisible(false)
	self.m_ResultNode = csbNode

	local temp = csbNode:getChildByName("im_result_bg")
	self.m_spBg = temp
	self.m_selfscore = temp:getChildByName("txt_self_win")

	self.m_selfreturnscore = temp:getChildByName("txt_self_return")
	self.m_bankerscore = temp:getChildByName("txt_banker_win")
	local nousescore = temp:getChildByName("txt_banker_return")
	nousescore:setVisible(false)
    csbNode:setOpacity(220)
end


function GameResultLayer:showGameResult(selfscore, selfreturnscore, bankerscore)
	self.m_lselfscore = selfscore
	self.m_lselfreturnscore = selfreturnscore
	self.m_lbankerscore = bankerscore
	self:setVisible(true)
	self:showGameResultData()
end

function GameResultLayer:showGameResultData()
	if nil == self.m_ResultNode then
		self:initResultLayer()
	end

	self.m_ResultNode:setVisible(true)
	self.m_ResultNode:stopAllActions()

	self.m_spBg:setScale(0.1)
	self.m_spBg:runAction(cc.ScaleTo:create(0.2, 1.0))

	local winstr = ExternalFun.numberThousands(self.m_lselfscore)
	self.m_selfscore:setString(winstr)

	winstr = ExternalFun.numberThousands(self.m_lselfreturnscore)
	self.m_selfreturnscore:setString(winstr)

	local bankerstr = ExternalFun.numberThousands(self.m_lbankerscore)
	self.m_bankerscore:setString(bankerstr)

	if self.m_lselfscore >= 0 then
		ExternalFun.playSoundEffect("gameWin.wav")
	else
		ExternalFun.playSoundEffect("gameLose.wav")
	end
	
end

function GameResultLayer:clear()
	
end

return GameResultLayer