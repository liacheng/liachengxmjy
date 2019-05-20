--
-- Author: cjm
-- Date: 2018年9月25日 17:50:01
--
--设置界面
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local ResultLayer = class("ResultLayer", cc.Layer)
ResultLayer.BT_CONFIRM = 1
ResultLayer.RES_PATH =  "game/yule/watermargin/res/"

--构造
function ResultLayer:ctor(tbScore)
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)

    --加载csb资源
    self._csbNode = ExternalFun.loadCSB("SHZ_GameResult.csb", self)
    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(sender:getTag(),sender)
        end
    end
    local sp_bg = self._csbNode:getChildByName("node_img"):getChildByName("bg")
    self.m_spBg = sp_bg

    --关闭按钮
    self.m_nodeBtn = self._csbNode:getChildByName("node_btn")
    local btn = self.m_nodeBtn:getChildByName("closeBtn")
    btn:addTouchEventListener(function (ref, eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playClickEffect()
            self:removeFromParent()
        end
    end)

    --确认
    self.m_btnConfirm = self.m_nodeBtn:getChildByName("confirmBtn")
    self.m_btnConfirm:setTag(ResultLayer.BT_CONFIRM)
    self.m_btnConfirm:addTouchEventListener(cbtlistener)
    
    --加载数据
    self.m_tbScore = tbScore
    self:loadData()
end

function ResultLayer:loadData()
    self.m_lScore1 = cc.LabelAtlas:_create("/0000000", ResultLayer.RES_PATH.."shz_font_num1.png", 27, 36, string.byte("*"))
             :setPosition(self.m_nodeBtn:getChildByName("txt1"):getPosition())
             :setAnchorPoint(cc.p(0, 0.5))
             :addTo(self.m_nodeBtn)

    self.m_lScore2 = cc.LabelAtlas:_create("/0000000", ResultLayer.RES_PATH.."shz_font_num1.png", 27, 36, string.byte("*"))
             :setPosition(self.m_nodeBtn:getChildByName("txt2"):getPosition())
             :setAnchorPoint(cc.p(0, 0.5))
             :addTo(self.m_nodeBtn)

    self.m_lScore3 = cc.LabelAtlas:_create("/0000000", ResultLayer.RES_PATH.."shz_font_num1.png", 27, 36, string.byte("*"))
             :setPosition(self.m_nodeBtn:getChildByName("txt3"):getPosition())
             :setAnchorPoint(cc.p(0, 0.5))
             :addTo(self.m_nodeBtn)

    if self.m_tbScore.score1 > 0 then
        self.m_lScore1:setString("."..self.m_tbScore.score1)
    elseif self.m_tbScore.score1 == 0 then
        self.m_lScore1:setString("0")
    else
        self.m_lScore1:setString("/"..math.abs(self.m_tbScore.score1))
    end

    if self.m_tbScore.score2 > 0 then
        self.m_lScore2:setString("."..self.m_tbScore.score2)
    elseif self.m_tbScore.score2 == 0 then
        self.m_lScore2:setString("0")
    else
        self.m_lScore2:setString("/"..math.abs(self.m_tbScore.score2))
    end

    local score3 = self.m_tbScore.score2 + self.m_tbScore.score1
    if score3 > 0 then
        self.m_lScore3:setString("."..score3)
    elseif score3 == 0 then
        self.m_lScore3:setString("0")
    else
        self.m_lScore3:setString("/"..math.abs(score3))
    end
end

function ResultLayer:showLayer( var )
    self:setVisible(var)
end

function ResultLayer:OnButtonClickedEvent( tag, sender )
    if ResultLayer.BT_CONFIRM == tag then
        ExternalFun.playClickEffect()
        self:removeFromParent()
    end
end

function ResultLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function ResultLayer:onTouchEnded(touch, event)
    local pos = touch:getLocation() 
    local m_spBg = self.m_spBg
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:removeFromParent()
    end
end

return ResultLayer