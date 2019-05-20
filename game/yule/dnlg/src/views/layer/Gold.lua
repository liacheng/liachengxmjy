--
-- Author: Will
-- Date: 2016-08-09 10:27:07
-- 金币
local Gold = class("Gold", cc.Layer)
local module_pre = "game.yule.fishlk.src"
local scheduler = cc.Director:getInstance():getScheduler()

function Gold:ctor()
    self.m_goldList = {} 
    self.m_goldPos = {cc.p(-65,5), cc.p(-120,5), cc.p(-175,5)}
    self.m_goldRatio = {0, 0, 0}
    self.m_numBGColor = 0
    local function update(dt)
        if self.m_goldRatio ~= nil then
            for i = 1, #self.m_goldRatio do
                if self.m_goldRatio[i] > 0 and self.m_goldList[i] ~= nil and self.m_goldList[i]:getTextureRect().height/7 < self.m_goldRatio[i] then
                    local gold = self.m_goldList[i]
                    gold:setTextureRect(cc.rect(0, 0, 38, 7*(gold:getTextureRect().height/7+1)))
                    gold:getChildByTag(500):setPosition(cc.p(gold:getContentSize().width/2, gold:getTextureRect().height+10))
                end
            end
        end
    end

    self.m_updateSchedule = scheduler:scheduleScriptFunc(update, 1/60, false)
end

function Gold:onExit( )
	if nil ~= self.m_updateSchedule then
		scheduler:unscheduleScriptEntry(self.m_updateSchedule)
		self.m_updateSchedule = nil
	end
end

function Gold:showGold(curScore)
    local ratio = math.min(50, math.max(1, math.floor(curScore / 1000)))
    if #self.m_goldList >= 3 then
        self.m_goldList[1]:removeFromParent()
        table.remove(self.m_goldList, 1)

        local gold = cc.Sprite:create("game_res/golds.png", cc.rect(0, 0, 38, 7));
        gold:setAnchorPoint(cc.p(0.5,0))
        gold:setPosition(self.m_goldPos[3])
        self:addChild(gold)
        table.insert(self.m_goldList,gold)
        
        local goldNumBg = cc.Sprite:create("game_res/gold_banner.png", cc.rect(0, self.m_numBGColor*18, 75, 18));
        goldNumBg:setAnchorPoint(cc.p(0.5, 0))
        goldNumBg:setScale(0.8)
        goldNumBg:setPosition(cc.p(gold:getContentSize().width/2, gold:getTextureRect().height+10))
        goldNumBg:setTag(500)
        gold:addChild(goldNumBg)

        local num = string.format("%d",curScore)
        local goldNum = cc.LabelAtlas:create(num,"game_res/num_game_gold.png",37,34, string.byte("0"))
        goldNum:setAnchorPoint(cc.p(0.5,0))
        goldNum:setPosition(cc.p(goldNumBg:getContentSize().width/2,goldNumBg:getContentSize().height/2))
        goldNumBg:addChild(goldNum)

        self.m_goldRatio[1] = self.m_goldRatio[2]
        self.m_goldRatio[2] = self.m_goldRatio[3]
        self.m_goldRatio[3] = ratio

        self.m_numBGColor = 1 - self.m_numBGColor
    else
        local gold = cc.Sprite:create("game_res/golds.png", cc.rect(0, 0, 38, 7));
        gold:setAnchorPoint(cc.p(0.5,0))
        gold:setPosition(self.m_goldPos[3])
        self:addChild(gold)
        table.insert(self.m_goldList,gold)
        
        local goldNumBg = cc.Sprite:create("game_res/gold_banner.png", cc.rect(0, self.m_numBGColor*18, 75, 18));
        goldNumBg:setAnchorPoint(cc.p(0.5, 0))
        goldNumBg:setScale(0.8)
        goldNumBg:setPosition(cc.p(gold:getContentSize().width/2, gold:getTextureRect().height+10))
        goldNumBg:setTag(500)
        gold:addChild(goldNumBg)
        
        local num = string.format("%d",curScore)
        local goldNum = cc.LabelAtlas:create(num,"game_res/num_game_gold.png",37,34, string.byte("0"))
        goldNum:setAnchorPoint(cc.p(0.5,0))
        goldNum:setPosition(cc.p(goldNumBg:getContentSize().width/2,goldNumBg:getContentSize().height/2))
        goldNumBg:addChild(goldNum)
        
        self.m_goldRatio[#self.m_goldList] = ratio

        self.m_numBGColor = 1 - self.m_numBGColor
    end

    local curIndex = 3
    for i = 1, #self.m_goldList do
        self.m_goldList[#self.m_goldList-i+1]:stopAllActions()
        self.m_goldList[#self.m_goldList-i+1]:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, self.m_goldPos[curIndex]),cc.DelayTime:create(3), cc.FadeOut:create(0.3), cc.Hide:create()))
        curIndex = curIndex - 1
    end
end



return Gold