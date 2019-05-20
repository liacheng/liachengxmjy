--
-- Author: Will
-- Date: 2016-08-09 10:27:07
-- 彩金
local Bingo = class("Bingo", cc.Layer)
local module_pre = "game.yule.fishlk4.src"

function Bingo:ctor(viewParent)
	self.m_pos = 0    --炮台位置
    self.m_wChairID = yl.INVALID_CHAIR
    self.bingoBG = display.newSprite("#Reward_Box_0.png")
        :addTo(self)
    self.bingoScore = cc.LabelAtlas:create(0,"game_res/lkpy_num_small.png",18,25, string.byte("*"))
        :setAnchorPoint(cc.p(0.5, 0.5))
        :addTo(self)

        
    self.m_pBingoPos =             -- 炮台位置
    {
    	cc.p(272,585),
--	    cc.p(662,585),
	    cc.p(1072,585),
	    cc.p(262,215),
--	    cc.p(660,215),
	    cc.p(1075,215)
	}
    self._dataModel = viewParent._dataModel
end

function Bingo:onExit()

end

function Bingo:getChairID()
    return self.m_wChairID
end

function Bingo:showScore(chair, score)

	self.m_pos = chair
	if self._dataModel.m_reversal then 
        self.m_pos = 3 - self.m_pos
	end

	--if self.m_pos < 3 then
	--	self:setRotation(180)
	--end

    self:setPosition(self.m_pBingoPos[self.m_pos+1])
    -- 停止动作
    self.bingoBG:stopAllActions()
    self.bingoScore:stopAllActions()

    self.m_wChairID = chair                                     -- 设置椅子号
    self.bingoScore:setString(string.format("%d", score))       -- 设置分数
    self.bingoScore:setRotation(30)                             -- 设置分数角度
    self.bingoBG:setVisible(true)                               -- 显示动画背景
    self.bingoScore:setVisible(true)                            -- 显示分数
    local animation = cc.AnimationCache:getInstance():getAnimation("animation_reward_box")      -- 获取背景动画并设置动作
    local animate = cc.Animate:create(animation)                                                -- 播放时间为 0.1秒/帧
    local repeatAni = cc.Repeat:create(animate, 3)                                              -- 循环3次
    self.bingoBG:runAction(repeatAni)                     -- 开始背景动画

    local rotateAni1 = cc.RotateTo:create(0.6, -30)
    local rotateAni2 = cc.RotateTo:create(0.6, 30)
    local sequenceAni = cc.Sequence:create(rotateAni1, rotateAni2, rotateAni1, rotateAni2, rotateAni1)
    self.bingoScore:runAction(sequenceAni)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.Hide:create()))
end

return Bingo