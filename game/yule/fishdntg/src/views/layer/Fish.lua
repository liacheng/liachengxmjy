local Fish = class("Fish",function(fishData,target)
	local fish =  display.newSprite()
	return fish
end)

local FISHTAG = 
{
	TAG_GUAN = 10,
    TAG_ACTION = 101
}

local module_pre = "game.yule.fishdntg.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_DNTGGame"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()

function Fish:ctor(fishData,target)
	self.m_bezierArry = {}
    self.gameLayer = target
    self.nFishKey = fishData.fish_id
	self.m_schedule = nil
    self.m_scheduleSceneFish = nil --
	self.m_data = fishData   		
	self.m_producttime = fishData.nProductTime
	self.m_ydtime = 0 			-- 鱼游动时间
	self.m_pathIndex = 1
	self.m_nQucikClickNum = 0
	self.m_fTouchInterval = 0
	self:setPosition(cc.p(-500,-500))
	self:setTag(g_var(cmd).Tag_Fish)
	self._dataModel = target._dataModel
    self._bFishInView = false
    ExternalFun.registerTouchEvent(self, false)       -- 注册事件
    self.stop_index_ = 0
	self.stop_count_ = 0
	self.current_stop_count_ = 0
    self.isActive = true
    self.m_moveDir = cc.p(0, 0)
    self.foshouRotate = 0
    self.isAttacked = false      --是否被攻击（控制变红）
end

function Fish:schedulerUpdate()
    local function updateFish(dt)
        if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_FOSHOU then
        
            self._bFishInView = true
            self._dataModel.m_InViewTag[self.m_data.fish_id] = 1
            local movedis =  5
	        local movedir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis)  
	        local pos = cc.p(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)

	        self:setPosition(pos.x,pos.y)
	        local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)

	        if not cc.rectContainsPoint(rect,pos) then
                if pos.x<0 or pos.x>yl.WIDTH then
                    self.foshouRotate = self.foshouRotate * -1
                    if pos.x<0 then
                        pos.x = 0
                    else
                        pos.x = yl.WIDTH
                    end
                else
                    self.foshouRotate = self.foshouRotate * -1 + 180
                    if pos.y < 0 then
                        pos.y = 0
                    else
                        pos.y = yl.HEIGHT
                    end
                end

                self.m_moveDir = cc.pForAngle(math.rad(90 - self.foshouRotate))
                local moveDir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis) 
                pos = cc.p(self:getPositionX()+moveDir.x,self:getPositionY()+moveDir.y)
                self:setPosition(pos.x,pos.y)
            end
            return
        end

        local nowPos = cc.p(self:getPositionX(),self:getPositionY())

        if cc.rectContainsPoint( cc.rect(0,0,yl.WIDTH, yl.HEIGHT), nowPos ) then
            self._bFishInView = true
            self._dataModel.m_InViewTag[self.m_data.fish_id] = 1
		else
		    self._bFishInView = false
		    self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
		end

		local angle = self._dataModel:getAngleByTwoPoint(nowPos, self.m_oldPoint)
		self:setRotation(angle)

		if nowPos.x < self.m_oldPoint.x and not self._dataModel.m_reversal  then
            self:setFlippedX(true)
		elseif nowPos.x < self.m_oldPoint.x and self._dataModel.m_reversal  then
			self:setFlippedX(false)
		elseif nowPos.x > self.m_oldPoint.x and self._dataModel.m_reversal then
			self:setFlippedX(true)
		else
			self:setFlippedX(false)
		end

        for i = 202, 210 do
            if self:getChildByTag(i) ~= nil then
                self:getChildByTag(i):setFlippedX(self:isFlippedX())    
            end  
        end

        self.m_oldPoint = cc.p(self:getPositionX(),self:getPositionY())
    end

	if nil == self.m_schedule then  -- 定时器
		self.m_schedule = scheduler:scheduleScriptFunc(updateFish, 0, false)
	end
end

function Fish:unScheduleFish()
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
	end
    if nil ~= self.m_scheduleSceneFish then
        scheduler:unscheduleScriptEntry(self.m_scheduleSceneFish)
        self.m_scheduleSceneFish = nil
	end
end

function Fish:onEnter()
    local time = currentTime()
	self.m_ydtime = time - self.m_producttime
    if self.m_data.isSceneFish == false then
	    self:schedulerUpdate()
    end
end

function Fish:onExit()
    if self:getPhysicsBody() then
        self:getPhysicsBody():onRemove()
    end
	self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
	self:unScheduleFish()
end

function Fish:onTouchBegan(touch, event)
	local point = touch:getLocation()
	point = self:convertToNodeSpace(point)
	local rect = self:getBoundingBox()
	rect = cc.rect(0,0,rect.width,rect.height)
    if cc.rectContainsPoint( rect, point )  then
        local fish = self._dataModel.m_fishList[self.nFishKey]
        local fishData = fish.m_data
        if fishData.fish_kind > 8 then
	        self._dataModel.m_fishIndex	= self.nFishKey     -- 切换成当前锁定目标
            self.gameLayer:removeLockTag()
        end
    end
	return true
end

function Fish:onTouchEnded(touch, event )

end

function Fish:RotatePoint(pcircle,dradian,ptsome)
	local tmp = {}
	ptsome.x = ptsome.x - pcircle.x
	ptsome.y = ptsome.y - pcircle.y
	tmp.x = ptsome.x*math.cos(dradian) - ptsome.y*math.sin(dradian) + pcircle.x
	tmp.y = ptsome.x * math.sin(dradian) + ptsome.y*math.cos(dradian) + pcircle.y
	return tmp
end

function Fish:initAnim()
	local namestr = nil
	local aniName = nil
    local guanName = nil
    if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_SHENXIANCHUAN then     -- 神仙船
        namestr = string.format("fish_%d_yd_0.png", self.m_data.fish_kind)
        aniName = string.format("fish_%d_yd", self.m_data.fish_kind)

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
            self:setScale(1.2)
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            local action = cc.RepeatForever:create(cc.Animate:create(animation))
            self:runAction(action)
            self:setOpacity(0)  -- 渐变出现
            self:runAction(cc.FadeTo:create(0.2,255))
        end

        -- 船上的小鱼1
        namestr = string.format("fish_%d_yd_0.png", g_var(cmd).FishKind.FISH_JINSHA)
        aniName = string.format("fish_%d_yd", g_var(cmd).FishKind.FISH_JINSHA)

        local tempFish = nil
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            tempFish = cc.Sprite:createWithSpriteFrameName(namestr)
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            local action = cc.RepeatForever:create(cc.Animate:create(animation))
            tempFish:runAction(action)
            tempFish:setOpacity(0)  -- 渐变出现
            tempFish:setScale(0.5)
            tempFish:setTag(202)
            tempFish:runAction(cc.FadeTo:create(0.2,255))
            tempFish:setPosition(cc.p(self:getContentSize().width * 0.5, self:getContentSize().height * 0.8))
            self:addChild(tempFish)
        end

        -- 船上的小鱼2
        namestr = string.format("fish_%d_yd_0.png", g_var(cmd).FishKind.FISH_BIANFUYU)
        aniName = string.format("fish_%d_yd", g_var(cmd).FishKind.FISH_BIANFUYU)

        local tempFish = nil
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            tempFish = cc.Sprite:createWithSpriteFrameName(namestr)
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            local action = cc.RepeatForever:create(cc.Animate:create(animation))
            tempFish:runAction(action)
            tempFish:setOpacity(0)  -- 渐变出现
            tempFish:setScale(0.5)
            tempFish:setTag(203)
            tempFish:runAction(cc.FadeTo:create(0.2,255))
            tempFish:setPosition(cc.p(self:getContentSize().width * 0.35, self:getContentSize().height * 0.6))
            self:addChild(tempFish)
        end

        -- 船上的小鱼3
        namestr = string.format("fish_%d_yd_0.png", g_var(cmd).FishKind.FISH_KONGQUEYU)
        aniName = string.format("fish_%d_yd", g_var(cmd).FishKind.FISH_KONGQUEYU)

        local tempFish = nil
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            tempFish = cc.Sprite:createWithSpriteFrameName(namestr)
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            local action = cc.RepeatForever:create(cc.Animate:create(animation))
            tempFish:runAction(action)
            tempFish:setOpacity(0)  -- 渐变出现
            tempFish:setScale(0.5)
            tempFish:setTag(204)
            tempFish:runAction(cc.FadeTo:create(0.2,255))
            tempFish:setPosition(cc.p(self:getContentSize().width * 0.65, self:getContentSize().height * 0.6))
            self:addChild(tempFish)
        end
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_DNTG then         -- 大闹天宫
        namestr = string.format("fish_%d_yd_0.png", self.m_data.tag)
        aniName = string.format("fish_%d_yd", self.m_data.tag)
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
        else
            return false
        end 
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        self:runAction(action)
        local guan = cc.Sprite:createWithSpriteFrameName("dntgquan.png")
        self:addChild(guan, -1)
        guan:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        guan:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YJSD then         -- 一箭双雕
        local kindId1 = g_var(cmd).kYjsdSubFish[self.m_data.tag+1][1]
        local kindId2 = g_var(cmd).kYjsdSubFish[self.m_data.tag+1][2]

              namestr  = string.format("fish_%d_yd_0.png", kindId1)
        local namestr2 = string.format("fish_%d_yd_0.png", kindId2)
        if not cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr) or 
           not cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr2) then
            return false
        end

              aniName    = string.format("fish_%d_yd", kindId1)
        local animation  = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action     = cc.RepeatForever:create(cc.Animate:create(animation))
        
        local aniName2   = string.format("fish_%d_yd", kindId2)
        local animation2 = cc.AnimationCache:getInstance():getAnimation(aniName2)
        local action2    = cc.RepeatForever:create(cc.Animate:create(animation2))
        
        self:initWithSpriteFrameName(namestr)
        self:runAction(action)
        
        local sp2 = cc.Sprite:createWithSpriteFrameName(namestr2)
        sp2:setPosition(self:getContentSize().width/2 + 90, self:getContentSize().height/2)
        sp2:setTag(202)
	   	sp2:runAction(action2)
        self:addChild(sp2)

        local guan = cc.Sprite:createWithSpriteFrameName("yjsdquan.png")
        guan:setPosition(self:getContentSize().width/2 + 45, self:getContentSize().height/2)
        guan:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
        self:addChild(guan, -1)
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YSSN then         -- 一石三鸟
        local kindId1 = g_var(cmd).kYssnSubFish[self.m_data.tag+1][1]
        local kindId2 = g_var(cmd).kYssnSubFish[self.m_data.tag+1][2]
        local kindId3 = g_var(cmd).kYssnSubFish[self.m_data.tag+1][3]

              namestr  = string.format("fish_%d_yd_0.png", kindId1)
        local namestr2 = string.format("fish_%d_yd_0.png", kindId2)
        local namestr3 = string.format("fish_%d_yd_0.png", kindId3)
        if not cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr) or 
           not cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr2) or 
           not cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr3) then
            return false
        end

        aniName = string.format("fish_%d_yd", kindId1)
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        
        local aniName2 = string.format("fish_%d_yd", kindId2)
        local animation2 = cc.AnimationCache:getInstance():getAnimation(aniName2)
        local action2 = cc.RepeatForever:create(cc.Animate:create(animation2))
        
        local aniName3 = string.format("fish_%d_yd", kindId3)
        local animation3 = cc.AnimationCache:getInstance():getAnimation(aniName3)
        local action3 = cc.RepeatForever:create(cc.Animate:create(animation3))
        
        self:initWithSpriteFrameName(namestr)
        self:runAction(action)
        
        local sp2 = cc.Sprite:createWithSpriteFrameName(namestr2)
        sp2:setPosition(self:getContentSize().width/2 + 50, self:getContentSize().height/2)
        sp2:setTag(202)
	   	sp2:runAction(action2)
        self:addChild(sp2)
        
        local sp3 = cc.Sprite:createWithSpriteFrameName(namestr3)
        sp3:setPosition(self:getContentSize().width/2 - 50, self:getContentSize().height/2)
        sp3:setTag(203)
	   	sp3:runAction(action3)
        self:addChild(sp3)

        local guan = cc.Sprite:createWithSpriteFrameName("yssnquan.png")
        guan:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
        guan:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
        self:addChild(guan, -1)
        
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_QJF then         -- 全家福
        -- 先创建海龟
        namestr = string.format("fish_%d_yd_0.png", g_var(cmd).FishKind.FISH_HAIGUI)
        aniName = string.format("fish_%d_yd", g_var(cmd).FishKind.FISH_HAIGUI)

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            local action = cc.RepeatForever:create(cc.Animate:create(animation))
            self:initWithSpriteFrameName(namestr)
            self:runAction(action)
            self:setOpacity(0)  -- 渐变出现
            self:runAction(cc.FadeTo:create(0.2,255))
        else
            return false
        end
        
        local fishPos = {cc.p(self:getContentSize().width/2 - 35 - 35, self:getContentSize().height/2),
                         cc.p(self:getContentSize().width/2 - 35 - 100 - 35, self:getContentSize().height/2 + 150),
                         cc.p(self:getContentSize().width/2 - 35 - 100 - 35, self:getContentSize().height/2 - 150),
                         cc.p(self:getContentSize().width/2 - 35 - 100 + 35, self:getContentSize().height/2 + 150),
                         cc.p(self:getContentSize().width/2 - 35 - 100 + 35, self:getContentSize().height/2 - 150),
                         cc.p(self:getContentSize().width/2 - 35 + 100 - 35, self:getContentSize().height/2 + 150),
                         cc.p(self:getContentSize().width/2 - 35 + 100 - 35, self:getContentSize().height/2 - 150),
                         cc.p(self:getContentSize().width/2 - 35 + 100 + 35, self:getContentSize().height/2 + 150),
                         cc.p(self:getContentSize().width/2 - 35 + 100 + 35, self:getContentSize().height/2 - 150),}

        local quanPos = {cc.p(self:getContentSize().width/2 - 35      , self:getContentSize().height/2),
                         cc.p(self:getContentSize().width/2 - 35 - 100, self:getContentSize().height/2 + 150),
                         cc.p(self:getContentSize().width/2 - 35 - 100, self:getContentSize().height/2 - 150),
                         cc.p(self:getContentSize().width/2 - 35 + 100, self:getContentSize().height/2 + 150),
                         cc.p(self:getContentSize().width/2 - 35 + 100, self:getContentSize().height/2 - 150)}

        for i = 1, 9 do
            namestr = string.format("fish_%d_yd_0.png", i - 1)
            aniName = string.format("fish_%d_yd", i - 1)
            
            if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
                local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
                local action = cc.RepeatForever:create(cc.Animate:create(animation))
                
                local sp = cc.Sprite:createWithSpriteFrameName(namestr)
                sp:setPosition(fishPos[i])
                sp:setTag(201 + i)
	   	        sp:runAction(action)
                self:addChild(sp)
            else
                return false
            end
        end

        for i = 1, 5 do
            local guan = cc.Sprite:createWithSpriteFrameName("qjfdiquan.png")
            guan:setPosition(quanPos[i])
            guan:setScale(0.8)
            guan:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
            self:addChild(guan, -1)
        end
        
        local guan = cc.Sprite:createWithSpriteFrameName("qjfquan.png")
        guan:setPosition(cc.p(self:getContentSize().width/2 - 35, self:getContentSize().height/2))
        guan:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
        self:addChild(guan, -2)
        
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YUQUN then         -- 鱼群
        namestr = string.format("fish_%d_yd_0.png", self.m_data.tag)
        aniName = string.format("fish_%d_yd", self.m_data.tag)
        guanName = "yuqunquan.png"
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
        else
            return false
        end 
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action1 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action2 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action3 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action4 = cc.RepeatForever:create(cc.Animate:create(animation))

        local startX = self:getContentSize().width/2
        local startY = self:getContentSize().height/2

        local sp2 = cc.Sprite:createWithSpriteFrameName(namestr)
        local sp3 = cc.Sprite:createWithSpriteFrameName(namestr)
        local sp4 = cc.Sprite:createWithSpriteFrameName(namestr)
        
        sp2:setTag(202)
        sp3:setTag(203)
        sp4:setTag(204)

        sp2:setPosition(startX + 70, startY)
        sp3:setPosition(startX + 70, startY - 90)
        sp4:setPosition(startX, startY - 90)
        
        self:runAction(action1)
	   	sp2:runAction(action2)
	   	sp3:runAction(action3)
	   	sp4:runAction(action4)

        self:addChild(sp2)
        self:addChild(sp3)
        self:addChild(sp4)

        local guan1 = cc.Sprite:createWithSpriteFrameName(guanName)
        local guan2 = cc.Sprite:createWithSpriteFrameName(guanName)
        local guan3 = cc.Sprite:createWithSpriteFrameName(guanName)
        local guan4 = cc.Sprite:createWithSpriteFrameName(guanName)
        
        guan1:setPosition(cc.p(startX,      startY))
        guan2:setPosition(cc.p(startX + 70, startY))
        guan3:setPosition(cc.p(startX + 70, startY - 90))
        guan4:setPosition(cc.p(startX,      startY - 90))
        
        guan1:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))
		guan2:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))
		guan3:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))
		guan4:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))

        self:addChild(guan1, -1)
		self:addChild(guan2, -1)
		self:addChild(guan3, -1)
		self:addChild(guan4, -1)
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_CHAIN then         -- 闪电鱼
        namestr = string.format("fish_%d_yd_0.png", self.m_data.tag)
        aniName = string.format("fish_%d_yd", self.m_data.tag)
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
        else
            return false
        end 
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        self:runAction(action)
        
        namestr = "Light_Green_1.png"
        aniName = "GreenLight"
        local guan = cc.Sprite:createWithSpriteFrameName(namestr)
        guan:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        guan:setScale((g_var(cmd).kChainFishRadius[self.m_data.tag+1]*2)/200)
        guan:setTag(202)
        self:addChild(guan, 1)

        local animation1 = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action1 = cc.RepeatForever:create(cc.Animate:create(animation1))
        guan:runAction(action1)
	else
        if self.m_data.fish_kind == nil or self.m_data.fish_kind > 33 or self.m_data.fish_kind < 0   then
            return 
        end
        namestr = string.format("fish_%d_yd_0.png", self.m_data.fish_kind)
        aniName = string.format("fish_%d_yd", self.m_data.fish_kind)

        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            local action = cc.RepeatForever:create(cc.Animate:create(animation))
            self:runAction(action)
            self:setOpacity(0)  -- 渐变出现
            self:runAction(cc.FadeTo:create(0.2,255))
        else
            return false
        end
	end
    return true
end

function Fish:removeFishFromParent()
    self._dataModel.m_fishList[self.m_data.fish_id] = nil
    self:unScheduleFish()
    self:removeFromParent()
    -- 未移除刚体
end

function Fish:delayRemoveFish(time)
    if self:getPhysicsBody() then
        self:getPhysicsBody():onRemove()
    end
    self.isActive = false
	self:unScheduleFish()
    local removeCall = cc.CallFunc:create(function()	
        self._dataModel.m_fishList[self.nFishKey] = nil
        self:removeFromParent()
    end)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(time), removeCall))
end

function Fish:delayDeadDeal(delayMove, pos, delayDead, radius)
    -- 清除
    if self:getPhysicsBody() then
        self:getPhysicsBody():onRemove()
    end
    self.isActive = false
	self:setColor(cc.WHITE)
	self:stopAllActions()
	self:unScheduleFish()
    
    -- 定义
    local fishRadius = g_var(cmd).kChainFishRadius[self.m_data.tag + 1]
    local M_PI = 3.14159265358979323846
    local fishPos = cc.p(self:getPositionX(), self:getPositionY())
    if self._dataModel.m_reversal then                          -- 坐标根据视图反转
        fishPos = cc.p(yl.WIDTH - self:getPositionX(), yl.HEIGHT - self:getPositionY())
    end
    local tarRotate = 90 - self._dataModel:getAngleByTwoPoint(cc.p(fishPos.x, fishPos.y), cc.p(pos.x, pos.y))
    local tarX = pos.x + (fishRadius + radius) * math.cos(tarRotate * M_PI / 180)
    local tarY = pos.y + (fishRadius + radius) * math.sin(tarRotate * M_PI / 180)
    local scaleTime = 1
    
    if self._dataModel.m_reversal then                          -- 坐标根据视图反转
        tarX = yl.WIDTH - tarX
        tarY = yl.HEIGHT - tarY
    end
    local maxLength = cc.pGetDistance(cc.p(yl.WIDTH, yl.HEIGHT), cc.p(0, 0))
    local curLength = cc.pGetDistance(cc.p(self:getPositionX(), self:getPositionY()), cc.p(tarX, tarY))
    local moveTime = curLength / maxLength * 2
    -- 动画
    namestr = "Light_Green_1.png"
    aniName = "GreenLight"
    local guan = cc.Sprite:createWithSpriteFrameName(namestr)
    guan:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    guan:setScale(1)
    guan:setVisible(false)
    guan:setTag(202)
    self:addChild(guan, 1)
    local animation1 = cc.AnimationCache:getInstance():getAnimation(aniName)
    local action1 = cc.RepeatForever:create(cc.Animate:create(animation1))
    guan:runAction(cc.Sequence:create(cc.DelayTime:create(delayMove), cc.Show:create(), cc.ScaleTo:create(scaleTime, (fishRadius*2)/200), action1))

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(delayMove + scaleTime), 
        cc.CallFunc:create(function () 
            self.gameLayer._gameView:showLight1(fishPos.x, fishPos.y, pos.x, pos.y, moveTime) 
        end), 
        cc.Spawn:create(
            cc.MoveTo:create(moveTime, cc.p(tarX, tarY)), 
            cc.RotateBy:create(moveTime, 720)
        ), 
        cc.CallFunc:create(function()
            if self:getChildByTag(202) ~= nil then
                self:getChildByTag(202):stopAllActions()
                self:getChildByTag(202):removeFromParent()

                namestr = "Light_Blue_1.png"
                aniName = "BlueLight"
                local guan = cc.Sprite:createWithSpriteFrameName(namestr)
                guan:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
                guan:setScale((g_var(cmd).kChainFishRadius[self.m_data.tag+1]*2)/200)
                guan:setTag(202)
                self:addChild(guan, 1)

                local animation1 = cc.AnimationCache:getInstance():getAnimation(aniName)
                local action1 = cc.RepeatForever:create(cc.Animate:create(animation1))
                guan:runAction(action1)
            end
        end)))
    
    return scaleTime + moveTime
end

function Fish:deadDeal()    -- 死亡处理
    -- 清除
    if self:getPhysicsBody() then
        self:getPhysicsBody():onRemove()
    end
    self.isActive = false
	self:setColor(cc.WHITE)
	self:stopAllActions()
	self:unScheduleFish()
    local removeCall = cc.CallFunc:create(function()	
        self._dataModel.m_fishList[self.nFishKey] = nil
        self:removeFromParent()
    end)

    local aniName = nil
    local ani = nil
    if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_WONIUYU and 
       self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_BGLU and 
       self.m_data.fish_kind ~= g_var(cmd).FishKind.FISH_SHENXIANCHUAN and 
       self.m_data.fish_kind ~= g_var(cmd).FishKind.FISH_FOSHOU then
        aniName = string.format("fish_%d_die", self.m_data.fish_kind)
	    ani = cc.AnimationCache:getInstance():getAnimation(aniName)
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_DNTG then
        aniName = string.format("fish_%d_die", self.m_data.tag)
	    ani = cc.AnimationCache:getInstance():getAnimation(aniName)
    end

	if ani ~= nil then
        local times = 4
        if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_MEIRENYU or 
           self.m_data.fish_kind == g_var(cmd).FishKind.FISH_SWK or 
           self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YUWANGDADI then
            times = 1
        end

        if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_BGLU then
            local aniName1 = string.format("bglu_gun_%d",self.m_data.tag + 1)
	        local ani1 = cc.AnimationCache:getInstance():getAnimation(aniName1)
            self:runAction(cc.Sequence:create(cc.Animate:create(ani), cc.Animate:create(ani1), removeCall))
            self:setRotation(0)

            local aniName2 = string.format("bglu_str_%d",self.m_data.tag + 1)
	        local ani2 = cc.AnimationCache:getInstance():getAnimation(aniName2)

            local tipName = "fishex_27_str_1_0.png"
            if self.m_data.tag == 1 then
                tipName = "fishex_27_str_2_0.png"
            elseif self.m_data.tag == 2 then
                tipName = "fishex_27_str_3_0.png"
            end
            
            local tipStr = cc.Sprite:createWithSpriteFrameName(tipName)
            tipStr:setPosition(cc.p(self:getContentSize().width/2 + 100, self:getContentSize().height/2 - 50))
            self:addChild(tipStr, 1)
            tipStr:runAction(cc.Animate:create(ani2))
            tipStr:setRotation(90)
            if self._dataModel.m_reversal then
                tipStr:setRotation(-90)
            end

            if self.m_data.tag == 1 then
                ExternalFun.playSoundEffect(g_var(cmd).FengHuoLun)
            elseif self.m_data.tag == 2 then
                ExternalFun.playSoundEffect(g_var(cmd).RuYiJGB)
            else
                ExternalFun.playSoundEffect(g_var(cmd).JinGangTa)
            end

        else
            local repeats = cc.Repeat:create(cc.Animate:create(ani), times)
            self:runAction(cc.Sequence:create(repeats, cc.DelayTime:create(0.1), removeCall))
        end

	else
        if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_SHENXIANCHUAN then
            local fish1 = self:getChildByTag(202)
            local fish2 = self:getChildByTag(203)
            local fish3 = self:getChildByTag(204)
            
            if fish1 then
                fish1:stopAllActions()
                aniName = string.format("fish_%d_die", g_var(cmd).FishKind.FISH_JINSHA)
                ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                fish1:runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
            end
            
            if fish2 then
                fish2:stopAllActions()
                aniName = string.format("fish_%d_die", g_var(cmd).FishKind.FISH_BIANFUYU)
                ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                fish2:runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
            end
            
            if fish3 then
                fish3:stopAllActions()
                aniName = string.format("fish_%d_die", g_var(cmd).FishKind.FISH_KONGQUEYU)
                ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                fish3:runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
            end
            
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1), removeCall))  -- 延迟一秒播放
        elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YJSD then
            local kindId1 = g_var(cmd).kYjsdSubFish[self.m_data.tag+1][1]
            local kindId2 = g_var(cmd).kYjsdSubFish[self.m_data.tag+1][2]
            aniName = string.format("fish_%d_die", kindId1)
	        ani = cc.AnimationCache:getInstance():getAnimation(aniName)
            self:runAction(cc.Sequence:create(cc.Repeat:create(cc.Animate:create(ani), 4), removeCall))

            if self:getChildByTag(202) then
                self:getChildByTag(202):stopAllActions()
                aniName = string.format("fish_%d_die", kindId2)
	            ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                self:getChildByTag(202):runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
            end
            
        elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YSSN then
            local kindId1 = g_var(cmd).kYssnSubFish[self.m_data.tag+1][1]
            local kindId2 = g_var(cmd).kYssnSubFish[self.m_data.tag+1][2]
            local kindId3 = g_var(cmd).kYssnSubFish[self.m_data.tag+1][3]

            aniName = string.format("fish_%d_die", kindId1)
	        ani = cc.AnimationCache:getInstance():getAnimation(aniName)
            self:runAction(cc.Sequence:create(cc.Repeat:create(cc.Animate:create(ani), 4), removeCall))

            if self:getChildByTag(202) then
                self:getChildByTag(202):stopAllActions()
                aniName = string.format("fish_%d_die", kindId2)
	            ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                self:getChildByTag(202):runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
            end

            if self:getChildByTag(203) then
                self:getChildByTag(203):stopAllActions()
                aniName = string.format("fish_%d_die", kindId3)
	            ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                self:getChildByTag(203):runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
            end

        elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_QJF then
            aniName = string.format("fish_%d_die", g_var(cmd).FishKind.FISH_HAIGUI)
	        ani = cc.AnimationCache:getInstance():getAnimation(aniName)
            self:runAction(cc.Sequence:create(cc.Repeat:create(cc.Animate:create(ani), 4), removeCall))
            for i = 1, 9 do
                if self:getChildByTag(201 + i) then
                    self:getChildByTag(201 + i):stopAllActions()
                    aniName = string.format("fish_%d_die", i - 1)
	                ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                    self:getChildByTag(201 + i):runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
                end
            end
        elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_YUQUN then
            aniName = string.format("fish_%d_die", self.m_data.tag)
	        ani = cc.AnimationCache:getInstance():getAnimation(aniName)
            self:runAction(cc.Sequence:create(cc.Repeat:create(cc.Animate:create(ani), 4), removeCall))
            for i = 1, 3 do
                if self:getChildByTag(201 + i) then
                    self:getChildByTag(201 + i):stopAllActions()
	                ani = cc.AnimationCache:getInstance():getAnimation(aniName)
                    self:getChildByTag(201 + i):runAction(cc.Repeat:create(cc.Animate:create(ani), 4))
                end
            end
        elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_CHAIN then
            if self:getChildByTag(202) ~= nil then
                self:getChildByTag(202):stopAllActions()
                self:getChildByTag(202):removeFromParent()

                namestr = "Light_Blue_1.png"
                aniName = "BlueLight"
                local guan = cc.Sprite:createWithSpriteFrameName(namestr)
                guan:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
                guan:setScale((g_var(cmd).kChainFishRadius[self.m_data.tag+1]*2)/200)
                guan:setTag(202)
                self:addChild(guan, 1)

                local animation1 = cc.AnimationCache:getInstance():getAnimation(aniName)
                local action1 = cc.RepeatForever:create(cc.Animate:create(animation1))
                guan:runAction(action1)
            end
        else
		    self:runAction(removeCall)
        end
	end
end

function Fish:initPhysicsBody()     -- 设置物理属性
    local fish_kind = self.m_data.fish_kind    
    local fishBody = {cc.size(24,  70), cc.size( 24,  60), cc.size( 24,  70), cc.size( 24,  70), cc.size( 30,  70),
                      cc.size(40,  80), cc.size( 30,  90), cc.size( 35, 100), cc.size( 50,  70), cc.size( 50,  90), 
                      cc.size(30, 100), cc.size( 24, 120), cc.size( 28, 200), cc.size( 40, 210), cc.size( 55, 100), 
                      cc.size(70, 220), cc.size( 70, 220), cc.size( 80, 300), cc.size(150, 150), cc.size(100, 300), 
                      cc.size(30, 240), cc.size( 24, 300), cc.size( 24, 300), cc.size( 24, 300), cc.size(150, 100), 
                      cc.size(280, 50), cc.size( 80,  80), cc.size( 80,  80), cc.size( 80,  80), cc.size( 80,  80), 
                      cc.size(80,  80), cc.size(250, 250), cc.size(100, 100), cc.size( 30,  80)}
    
    local body = cc.PhysicsBody:createBox(fishBody[fish_kind + 1])
    body:setRotationOffset(0)
    self:setPhysicsBody(body)
    self:getPhysicsBody():setCategoryBitmask(1)     -- 设置刚体属性
    self:getPhysicsBody():setCollisionBitmask(0)
    self:getPhysicsBody():setContactTestBitmask(2)
    self:getPhysicsBody():setGravityEnable(false)
end

function Fish:initWithState()
	
end

function  Fish:setConvertPoint( point ) -- 转换坐标
    local WIN32_W = 1366
    local WIN32_H = 768
    local scalex = yl.WIDTH/WIN32_W
    local scaley = yl.HEIGHT/WIN32_H
    local pos = cc.p(point.x*scalex,(WIN32_H-point.y)*scaley) 
    self:setPosition(pos)
end

function Fish:convertPoint(point)       -- 转换坐标
     local WIN32_W = 1366
	 local WIN32_H = 768
	 local scalex = cc.Director:getInstance():getVisibleSize().width/WIN32_W
	 local scaley = cc.Director:getInstance():getVisibleSize().height/WIN32_H
	 local pos = cc.p(point.x*scalex,point.y*scaley)
     return pos
end

function Fish:Stay(time)    -- 鱼停留
	self:unScheduleFish()
    self:pauseActionByTag(FISHTAG.TAG_ACTION)
	local call = cc.CallFunc:create(function()	
        if self.m_data.isSceneFish == false then
	        self:schedulerUpdate()
        end
        self:resumeActionByTag(FISHTAG.TAG_ACTION)
	end)
	local delay = cc.DelayTime:create(time/1000)
	self:runAction(cc.Sequence:create(delay,call))
end

function Fish:updateScheduleSceneFish(param)    -- 场景鱼的位置坐标
    self:unScheduleFish()
    local function removeCallBack()
        self._dataModel.m_fishList[self.m_data.fish_id] = nil
        self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
        self:unScheduleFish()
        self:removeFromParent()
    end

    self.m_oldPoint = self:convertPoint(cc.p(param.position[1][1].x,param.position[1][1].y))
    self:setPosition(self.m_oldPoint)

    if self.m_data.sceneKind == 1 then
        self:initPhysicsBody()
        self:runAction(cc.Sequence:create(cc.MoveTo:create(30, cc.p(param.position[1][2].x, param.position[1][2].y)), cc.CallFunc:create(removeCallBack)))
    elseif self.m_data.sceneKind == 2 then
        self:initPhysicsBody()
        local fishPos = {}
        local moveTime = 20
        for i = 1, #param.position[1]-2 do
            fishPos[i] = {}
            fishPos[i].x = param.position[1][i+1].x
            fishPos[i].y = param.position[1][i+1].y
        end
        if param.sceneIndex == 1 then
            moveTime = 23
        elseif param.sceneIndex <= 11 then
            moveTime = 20
        elseif param.sceneIndex <= 29 then
            moveTime = 17
        elseif param.sceneIndex <= 59 then
            moveTime = 14
        elseif param.sceneIndex <= 89 then
            moveTime = 11
        end

        local action1 = cc.CardinalSplineBy:create(moveTime, fishPos, 0)
        self:runAction(cc.Sequence:create(action1, cc.CallFunc:create(function()
            local m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
            self:runAction(cc.Sequence:create(cc.MoveBy:create(8, cc.p(m_moveDir.x * 1000, m_moveDir.y * 1000)), cc.CallFunc:create(removeCallBack)))
        end)))
    elseif self.m_data.sceneKind == 3 then
        
        local fishPos = {}
        local moveTime = 20
        local showTime = 0
        for i = 1, #param.position[1]-2 do
            fishPos[i] = {}
            fishPos[i].x = param.position[1][i+1].x
            fishPos[i].y = param.position[1][i+1].y
        end
        if param.sceneIndex == 1 then
            showTime = 0
        elseif param.sceneIndex > 5 and param.sceneIndex <= 11 then
            showTime = (param.sceneIndex - 5) * 2
        elseif param.sceneIndex > 17 and param.sceneIndex <= 29 then
            showTime = param.sceneIndex - 17
        elseif param.sceneIndex > 38 and param.sceneIndex <= 59 then
            showTime = (param.sceneIndex - 38) / 1.5
        elseif param.sceneIndex > 68 and param.sceneIndex <= 89 then
            showTime = (param.sceneIndex - 68) / 1.5
        end
        
        if param.sceneIndex == 1 then
            moveTime = 23
        elseif param.sceneIndex <= 11 then
            moveTime = 20
        elseif param.sceneIndex <= 29 then
            moveTime = 17
        elseif param.sceneIndex <= 59 then
            moveTime = 14
        elseif param.sceneIndex <= 89 then
            moveTime = 11
        end

        self:setVisible(false)
        local delayNode = cc.Node:create()
        self:addChild(delayNode)
        delayNode:runAction(cc.Sequence:create(
            cc.DelayTime:create(showTime), 
            cc.CallFunc:create(function(sender) 
                self:initPhysicsBody()
                sender:getParent():setVisible(true) 
            end)))

        local action1 = cc.CardinalSplineBy:create(moveTime, fishPos, 0)
        self:runAction(cc.Sequence:create(action1, cc.CallFunc:create(function()
            local m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
            self:runAction(cc.Sequence:create(cc.MoveBy:create(8, cc.p(m_moveDir.x * 1000, m_moveDir.y * 1000)), cc.CallFunc:create(removeCallBack)))
        end)))
    elseif self.m_data.sceneKind == 4 then
        self:initPhysicsBody()
        self:runAction(cc.Sequence:create(cc.MoveTo:create(30, cc.p(param.position[1][2].x, param.position[1][2].y)), cc.CallFunc:create(removeCallBack)))
    elseif self.m_data.sceneKind == 5 then
        self:setVisible(false)
        local delayTime = 0
        local moveTime = 5
        if param.sceneIndex <= 15 then
            delayTime = 0
        elseif param.sceneIndex <= 30 then
            delayTime = moveTime
        elseif param.sceneIndex <= 45 then
            delayTime = moveTime*2
        elseif param.sceneIndex <= 60 then
            delayTime = moveTime*3
        elseif param.sceneIndex <= 75 then
            delayTime = moveTime*4
        end
        local outMove = cc.MoveTo:create(moveTime, cc.p(param.position[1][2].x, param.position[1][2].y))
        local inMove = cc.MoveTo:create(moveTime, cc.p(param.position[1][1].x, param.position[1][1].y))
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(delayTime), 
            cc.CallFunc:create(function (sender)
                sender:initPhysicsBody()
                sender:setVisible(true)
            end), 
            outMove, 
            inMove, 
            cc.CallFunc:create(removeCallBack)))
    elseif self.m_data.sceneKind == 6 then
        self:setVisible(false)
        local delayTime = 0
        local moveTime = 5
        if param.sceneIndex <= 15 then
            delayTime = 0
        elseif param.sceneIndex <= 30 then
            delayTime = moveTime/2
        elseif param.sceneIndex <= 45 then
            delayTime = moveTime/2*2
        elseif param.sceneIndex <= 60 then
            delayTime = moveTime/2*3
        elseif param.sceneIndex <= 75 then
            delayTime = moveTime/2*4
        elseif param.sceneIndex <= 90 then
            delayTime = moveTime/2*5
        elseif param.sceneIndex <= 105 then
            delayTime = moveTime/2*6
        elseif param.sceneIndex <= 120 then
            delayTime = moveTime/2*7
        elseif param.sceneIndex <= 135 then
            delayTime = moveTime/2*8
        end
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.CallFunc:create(function (sender)
                sender:setVisible(true)
                sender:initPhysicsBody()
            end),
            cc.MoveTo:create(moveTime, cc.p(param.position[1][2].x, param.position[1][2].y)),
            cc.CallFunc:create(function (sender)
                local fishPos = {}
                for i = 1, #param.position[1]-2 do
                    fishPos[i] = {}
                    fishPos[i].x = param.position[1][i+2].x
                    fishPos[i].y = param.position[1][i+2].y
                end
                local action1 = cc.CardinalSplineBy:create(10, fishPos, 1)
                self:runAction(cc.Sequence:create(action1, cc.CallFunc:create(removeCallBack)))
                self.m_oldPoint = self:convertPoint(cc.p(param.position[1][1].x,param.position[1][1].y))
                self:setPosition(self.m_oldPoint)
            end)))
    end

    local function updateFish(dt)
        local nowPos = cc.p(self:getPositionX(),self:getPositionY())
		local angle = self._dataModel:getAngleByTwoPoint(nowPos,self.m_oldPoint)
		self:setRotation(angle)
        self.m_oldPoint = cc.p(self:getPositionX(), self:getPositionY())
        
        if cc.rectContainsPoint( cc.rect(0,0,yl.WIDTH, yl.HEIGHT), nowPos ) then
            self._bFishInView = true
            self._dataModel.m_InViewTag[self.m_data.fish_id] = 1
		else
		    self._bFishInView = false
		    self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
		end
    end
    
	if nil == self.m_scheduleSceneFish then     -- 定时器
		self.m_scheduleSceneFish = scheduler:scheduleScriptFunc(updateFish, 0.05, false)
	end
end

function Fish:initWithType(param,target)
    self.m_oldPoint = self:convertPoint(cc.p(param.position[1][1].x,param.position[1][1].y))
    self:setPosition(self.m_oldPoint)

    if param.fish_kind == g_var(cmd).FishKind.FISH_FOSHOU then
	    local angle = self._dataModel:getAngleByTwoPoint(cc.p(param.position[1][2].x,param.position[1][2].y), cc.p(self:getPositionX(),self:getPositionY()))
	    self.foshouRotate = angle
        self:setRotation(-90)
	    self.m_moveDir = cc.pForAngle(math.rad(90-angle))
        return
    end
    
    local  function removeCallBack()
        self._dataModel.m_fishList[self.m_data.fish_id] = nil
        self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
        self:unScheduleFish()
        self:removeFromParent()
    end

    local fishSpeed = target.fish_speed[param.fish_kind + 1]
    local moveTime = self:getDuration(param.position[1], param.position_count, fishSpeed)

    local bt = nil
    local action = nil
    if param.position_count ==  2 then
        bt = cc.MoveTo:create(moveTime, self:convertPoint(cc.p(param.position[1][2].x, param.position[1][2].y)))
        action = cc.Sequence:create(bt, cc.CallFunc:create(removeCallBack))
    elseif param.position_count ==  3 then
        bt = cc.BezierTo:create(moveTime,{  self:convertPoint(cc.p(param.position[1][2].x,param.position[1][2].y)),
                                            self:convertPoint(cc.p(param.position[1][3].x,param.position[1][3].y))})
                                            
        action = cc.Sequence:create(bt, cc.CallFunc:create(removeCallBack))
    elseif param.position_count ==  4 then
        bt = cc.BezierTo:create(moveTime,{  self:convertPoint(cc.p(param.position[1][2].x,param.position[1][2].y)),
                                            self:convertPoint(cc.p(param.position[1][3].x,param.position[1][3].y)),
                                            self:convertPoint(cc.p(param.position[1][4].x,param.position[1][4].y))})
                                           
        action = cc.Sequence:create(bt, cc.CallFunc:create(removeCallBack))
    elseif param.position_count ==  7 then
        local bt1 = cc.BezierTo:create(moveTime,{   self:convertPoint(cc.p(param.position[1][2].x,param.position[1][2].y)),
                                                    self:convertPoint(cc.p(param.position[1][3].x,param.position[1][3].y)),
                                                    self:convertPoint(cc.p(param.position[1][4].x,param.position[1][4].y))})

        local bt2 = cc.BezierTo:create(moveTime,{   self:convertPoint(cc.p(param.position[1][5].x,param.position[1][5].y)),
                                                    self:convertPoint(cc.p(param.position[1][6].x,param.position[1][6].y)),
                                                    self:convertPoint(cc.p(param.position[1][7].x,param.position[1][7].y))})
                                            
        action = cc.Sequence:create(bt1, bt2, cc.CallFunc:create(removeCallBack))
    end

    action:setTag(FISHTAG.TAG_ACTION)
    self:runAction(action)
    local elasped = target.timerManager:GetDelayTick(param.tick_count)
    action:step(0)
    action:step(elasped/1000)
end

function Fish:initCircleFish(param,target)
    self.m_oldPoint = self:convertPoint(cc.p(param.init_pos[1][1].x,param.init_pos[1][1].y))
    self:setPosition(self.m_oldPoint)
    local swimTime = self:CalcDistance(param.init_pos[1][3].x,param.init_pos[1][3].y,param.init_pos[1][1].x,param.init_pos[1][1].y)/50
    local function removeCallBack()
        -- 未移除刚体
        self._dataModel.m_fishList[self.m_data.fish_id] = nil
        self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
        self:removeFromParent()
    end
    local bt = cc.MoveTo:create(swimTime,self:convertPoint(cc.p(param.init_pos[1][3].x,param.init_pos[1][3].y)))
    local action = cc.Sequence:create(bt,cc.CallFunc:create(removeCallBack))
    self:runAction(action)
end

function Fish:setStopFishInTime(stop_index,stop_count)
    self.stop_index_ = stop_index;
	self.stop_count_ = stop_count;
	self.current_stop_count_ = 0;
end

function Fish:getDuration(posArray, posCount, fishSpeed)
    local duration = 0
    if posCount ==  2 then
        local delta = cc.p(posArray[2].x - posArray[1].x, posArray[2].y - posArray[1].y)
        local length = math.sqrt(math.pow(delta.x, 2) + math.pow(delta.y, 2))
        duration = length/fishSpeed
    elseif posCount ==  3 then
        local points = { self:convertPoint(cc.p(posArray[1].x, posArray[1].y)),
                         self:convertPoint(cc.p(posArray[2].x, posArray[2].y)),
                         self:convertPoint(cc.p(posArray[3].x, posArray[3].y)) }
        
        local bezierCount = self:getBezierPointSize(points, 3, fishSpeed/60)
        duration = bezierCount/60
    elseif posCount ==  4 then
        local points = { self:convertPoint(cc.p(posArray[1].x, posArray[1].y)),
                         self:convertPoint(cc.p(posArray[2].x, posArray[2].y)),
                         self:convertPoint(cc.p(posArray[3].x, posArray[3].y)),
                         self:convertPoint(cc.p(posArray[4].x, posArray[4].y)) }
        
        local bezierCount = self:getBezierPointSize(points, 4, fishSpeed/60)
        duration = bezierCount/60
    elseif posCount ==  7 then
        local points1 = { self:convertPoint(cc.p(posArray[1].x, posArray[1].y)),
                          self:convertPoint(cc.p(posArray[2].x, posArray[2].y)),
                          self:convertPoint(cc.p(posArray[3].x, posArray[3].y)),
                          self:convertPoint(cc.p(posArray[4].x, posArray[4].y)) }

        local points2 = { self:convertPoint(cc.p(posArray[4].x, posArray[4].y)),
                          self:convertPoint(cc.p(posArray[5].x, posArray[5].y)),
                          self:convertPoint(cc.p(posArray[6].x, posArray[6].y)),
                          self:convertPoint(cc.p(posArray[7].x, posArray[7].y)) }
        
        local bezierCount1 = self:getBezierPointSize(points1, 4, fishSpeed/60)
        local bezierCount2 = self:getBezierPointSize(points2, 4, fishSpeed/60)
        duration = (bezierCount1 + bezierCount2)/60
    end
    return duration
end

function Fish:getBezierPointSize(posArray, posCount, fishSpeed)
    local bezierPoints = {}
    bezierPoints = self:buildBezier(posArray, posCount, fishSpeed)
    return #bezierPoints
end

function Fish:buildBezier(posArray, posCount, distance)
    assert(posCount == 3 or posCount == 4)
    if (posCount ~= 3 and posCount ~= 4) then
        return
    end
    local move_points = {}
    table.insert(move_points, cc.p(posArray[1].x, posArray[1].y))
    local index = 0
    local temp_pos0 = cc.p(0, 0)
    local temp_pos = cc.p(0, 0)
    local t = 0
    local count = posCount - 1
    local temp_value = 0

    while t < 1 do
        temp_pos.x = 0
        temp_pos.y = 0
        index = 0
        while index <= count do
            temp_value = math.pow(t, index) * math.pow(1 - t, (count - index)) * self:Combination(count, index)
            temp_pos.x = temp_pos.x + posArray[index + 1].x * temp_value
            temp_pos.y = temp_pos.y + posArray[index + 1].y * temp_value
            index = index + 1
        end

        local back_pos = move_points[#move_points]
        temp_value = self:CalcDistance(back_pos.x, back_pos.y, temp_pos.x, temp_pos.y)

        if temp_value >= distance then
            local temp_dis = self:CalcDistance(temp_pos.x, temp_pos.y, temp_pos0.x, temp_pos0.y)
            if temp_dis ~= 0 then
                temp_value = (temp_pos.x - temp_pos0.x) / temp_dis
            end
	        if t >= 0.008 then
                table.insert(move_points, cc.p(temp_pos.x, temp_pos.y))
            end
            temp_pos0.x = temp_pos.x
            temp_pos0.y = temp_pos.y
        end

        t = t + 0.001
    end
    return move_points
end

function Fish:CalcDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function Fish:Factorial(number)
    local factorial = 1
    local temp = number
    for i = 1, number do
        factorial = factorial * temp
    end

    return factorial
end

function Fish:Combination(count, r)
  return self:Factorial(count) / (self:Factorial(r) * self:Factorial(count - r))
end

--被攻击时的效果（变红）
function Fish:ForHit()
    local temp = nil
    if self:getChildByTag(120)then
        temp = self:getChildByTag(120)
    else
        temp = display.newSprite()
        temp:addTo(self)
        temp:setTag(120)
        temp:setVisible(false)
    end
    local callfunc1 = cc.CallFunc:create(function()
        self.isAttacked = true
        self:setColor(cc.c3b(255, 0, 0))
    end)
    local callfunc2 = cc.CallFunc:create(function()
        self.isAttacked = false
        self:setColor(cc.c3b(255, 255, 255))
    end)
    local action = cc.Sequence:create(callfunc1, cc.DelayTime:create(0.5),callfunc2)
    if not isAttacked then
        temp:runAction(action)
    else
        temp:stopAllActions()
        temp:runAction(action)
    end
end


return Fish