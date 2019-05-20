local Fish = class("Fish",function(fishData,target)
	local fish =  display.newSprite()
	return fish
end)

local FISHTAG = 
{
	TAG_GUAN = 10,
    TAG_ACTION = 101
}

local module_pre = "game.yule.fishlk.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
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
    ExternalFun.registerTouchEvent(self,true)       -- 注册事件
    self.stop_index_ = 0
	self.stop_count_ = 0
	self.current_stop_count_ = 0
    self.isActive = true
end

function Fish:schedulerUpdate()
    local function updateFish(dt)
        local nowPos = cc.p(self:getPositionX(),self:getPositionY())
        local endPoint = self:convertPoint(cc.p(self.m_data.init_pos[1][3].x,self.m_data.init_pos[1][3].y))
        local contentsize = self:getContentSize()
        if cc.rectContainsPoint( cc.rect(nowPos.x,nowPos.y,contentsize.width, contentsize.height), endPoint ) then
            self._dataModel.m_fishList[self.m_data.fish_id] = nil
            self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
            self:unScheduleFish()
            self:removeFromParent()
            return
        end

        if cc.rectContainsPoint( cc.rect(0,0,yl.WIDTH, yl.HEIGHT), nowPos ) then
            self._bFishInView = true
            self._dataModel.m_InViewTag[self.m_data.fish_id] = 1
		else
		    self._bFishInView = false
		    self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
		end

		local angle = self._dataModel:getAngleByTwoPoint(nowPos,self.m_oldPoint)
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
	self:schedulerUpdate()
end

function Fish:onExit( )
	self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
	self:unScheduleFish()
end

function Fish:onTouchBegan(touch, event)
	local point = touch:getLocation()
	point = self:convertToNodeSpace(point)
	local rect = self:getBoundingBox()
	rect = cc.rect(0,0,rect.width,rect.height) 
	return cc.rectContainsPoint( rect, point )  
end

function Fish:onTouchEnded(touch, event )
	self._dataModel.m_fishIndex	= self.nFishKey     -- 切换成当前锁定目标
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
    if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_27 then -- 大三元
        namestr = string.format("fish_%d_yd_1.png", self.m_data.fish_kind - g_var(cmd).FishKind.FISH_KIND_22)
        aniName = string.format("fish_%d_yd", self.m_data.fish_kind- g_var(cmd).FishKind.FISH_KIND_22)
        guanName = string.format("fish_bomb_%d.png", self.m_data.fish_kind- g_var(cmd).FishKind.FISH_KIND_24)
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
        else
            return false
        end 
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action1 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action2 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action3 = cc.RepeatForever:create(cc.Animate:create(animation))
        local sp1 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp1:setPosition(-35,35)
        self:addChild(sp1)
        sp1:runAction(action1)
	    
        local guan1 = cc.Sprite:createWithSpriteFrameName(guanName)
		guan1:setPosition(cc.p(-35,35))
		self:addChild(guan1, -1)
		guan1:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))

        local sp2 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp2:setPosition(35,35)
        self:addChild(sp2)
	   	sp2:runAction(action2)
	   	
        local guan2 = cc.Sprite:createWithSpriteFrameName(guanName)
        guan2:setPosition(cc.p(35,35))
		self:addChild(guan2, -1)
		guan2:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))

        local sp3 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp3:setPosition(0,-25)
        self:addChild(sp3)
	   	sp3:runAction(action3)
	   	
        local guan3 = cc.Sprite:createWithSpriteFrameName(guanName)
        guan3:setPosition(cc.p(0,-25))
		self:addChild(guan3, -1)
		guan3:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))
    elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_28 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30 then -- 大四喜
        namestr = string.format("fish_%d_yd_1.png", self.m_data.fish_kind - g_var(cmd).FishKind.FISH_KIND_22)
        aniName = string.format("fish_%d_yd", self.m_data.fish_kind- g_var(cmd).FishKind.FISH_KIND_22)
        guanName = string.format("fish_bomb_%d.png", self.m_data.fish_kind- g_var(cmd).FishKind.FISH_KIND_27)
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
 
        else
            return false
        end 
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action1 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action2 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action3 = cc.RepeatForever:create(cc.Animate:create(animation))
        local action4 = cc.RepeatForever:create(cc.Animate:create(animation))

        local sp1 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp1:setPosition(-35,35)
        self:addChild(sp1)
        sp1:runAction(action1)

        local guan1 = cc.Sprite:createWithSpriteFrameName(guanName)
        guan1:setPosition(cc.p(-35,35))
        self:addChild(guan1, -1)
        guan1:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))

        local sp2 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp2:setPosition(35,35)
        self:addChild(sp2)
	   	sp2:runAction(action2)

        local guan2 = cc.Sprite:createWithSpriteFrameName(guanName)
        guan2:setPosition(cc.p(35,35))
		self:addChild(guan2, -1)
		guan2:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))

        local sp3 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp3:setPosition(35,-35)
        self:addChild(sp3)
	   	sp3:runAction(action3)

        local guan3 = cc.Sprite:createWithSpriteFrameName(guanName)
        guan3:setPosition(cc.p(35,-35))
		self:addChild(guan3, -1)
		guan3:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))

        local sp4 = cc.Sprite:createWithSpriteFrameName(namestr)
        sp4:setPosition(-35,-35)
        self:addChild(sp4)
	   	sp4:runAction(action4)

        local guan4 = cc.Sprite:createWithSpriteFrameName(guanName)
        guan4:setPosition(cc.p(-35,-35))
		self:addChild(guan4, -1)
		guan4:runAction(cc.RepeatForever:create(cc.RotateBy:create(8.5,360)))
    elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_31 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_40 then -- 鱼王
        namestr = string.format("fish_%d_yd_1.png", self.m_data.fish_kind - g_var(cmd).FishKind.FISH_KIND_31)
        aniName = string.format("fish_%d_yd", self.m_data.fish_kind- g_var(cmd).FishKind.FISH_KIND_31)
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
 
        else
            return false
        end 
        local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        local sp1 = cc.Sprite:createWithSpriteFrameName(namestr)
        self:addChild(sp1)
        sp1:runAction(action)
        local guan = nil
        if self.m_data.fish_kind < g_var(cmd).FishKind.FISH_KIND_36 then
            guan = cc.Sprite:create("game_res/halo_1.png")
        else
            guan = cc.Sprite:create("game_res/halo_2.png")
        end

        self:addChild(guan, -1)
        guan:setScale(1.5)
        guan:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_23 then       -- 局部炸弹
        if cc.SpriteFrameCache:getInstance():getSpriteFrame("smallBom.png")  then
            self:initWithSpriteFrameName("smallBom.png")
            return true
        else
            return false
        end 
    elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_24 then       -- 超级炸弹
        namestr = string.format("fishMove_%03d_1.png", g_var(cmd).FishKind.FISH_KIND_24 + 1)
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
            self:setOpacity(0)
	        local rotate = cc.RotateBy:create(8.5,360)
	        local repeatation = cc.RepeatForever:create(rotate)
	        local copySelf = cc.Sprite:createWithSpriteFrameName(namestr)
	        if nil ~= copySelf then
                local contentSize = self:getContentSize()
		        copySelf:setPosition(cc.p(contentSize.width/2,contentSize.height/2))
		        copySelf:runAction(repeatation)
		        self:addChild(copySelf, 1)
            end
            return true
        else
            return false
        end 
	else                                                                        -- 普通鱼
        namestr = string.format("fish_%d_yd_1.png", 1)
        aniName = string.format("fish_%d_yd", 1)
        if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_1 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_17 then
            namestr = string.format("fish_%d_yd_1.png", self.m_data.fish_kind)
            aniName = string.format("fish_%d_yd", self.m_data.fish_kind)
        --elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_41 then  
        --    namestr = string.format("fishMove_%03d_1.png", 27)
        --    aniName = string.format("animation_fish_move%d", 27)
        --elseif self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_42 then  
        --    namestr = string.format("fishMove_%03d_1.png", 23)
        --    aniName = string.format("animation_fish_move%d", 23)
        else
            namestr = string.format("fishMove_%03d_1.png", self.m_data.fish_kind + 1)
            aniName = string.format("animation_fish_move%d", self.m_data.fish_kind + 1)
        end
        if cc.SpriteFrameCache:getInstance():getSpriteFrame(namestr)  then
            self:initWithSpriteFrameName(namestr)
            if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_20  then
                self:setScale(1.2)
            end
            local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
            if nil ~= animation then
                local animation = cc.AnimationCache:getInstance():getAnimation(aniName)
                local action = cc.RepeatForever:create(cc.Animate:create(animation))
                self:runAction(action)
                self:setOpacity(0)  -- 渐变出现
                self:runAction(cc.FadeTo:create(0.2,255))
            end
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
end

function Fish:deadDeal()    -- 死亡处理
    self.isActive = false
	self:getPhysicsBody():onRemove()
	self:setColor(cc.WHITE)
	self:stopAllActions()
	self:unScheduleFish()
    local aniName = nil
    if self.m_data.fish_kind > g_var(cmd).FishKind.FISH_KIND_30 and  self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_40 then
        aniName = string.format("fish_%d_die",self.m_data.fish_kind)
    elseif self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_1 and  self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_17 then
        aniName = string.format("fish_%d_die",self.m_data.fish_kind)
    else
        aniName = string.format("animation_fish_dead%d",self.m_data.fish_kind+1)
    end

	local ani = cc.AnimationCache:getInstance():getAnimation(aniName)
	local parent = self:getParent()

	if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_24 then   -- 爆炸飞镖
        local nKnife = 18
		local angle = 20
		local radius = 1200
		for i=1,nKnife do
            local sKnife = cc.Sprite:create("game_res/knife.png")
			sKnife:setAnchorPoint(0,0.5)
			sKnife:setPosition(self:getPositionX(),self:getPositionY())
			local pos = cc.p(self:getPositionX(),self:getPositionY())
			local purPos = cc.p(0,0)
			purPos.x = pos.x + radius * self._dataModel.m_cosList[20*i]
			purPos.y = pos.y + radius * self._dataModel.m_sinList[20*i]
			purPos = self._dataModel:convertCoordinateSystem(purPos, 1, self._dataModel.m_reversal)
			local callfunc = cc.CallFunc:create(function()
                sKnife:removeFromParent()
			end)
			sKnife:runAction(cc.Sequence:create(cc.MoveTo:create(1.5,purPos),callfunc))
			parent:addChild(sKnife)
            local angle = math.atan2((purPos.y - sKnife:getPositionY()), (purPos.x - sKnife:getPositionX())) / 3.14 * 180
            if angle < 0 then
                angle = angle - (90 + angle)
                if self._dataModel.m_reversal then
                    angle = angle + 180
                end
                sKnife:setRotation(angle)
            else
                angle = 90 - angle 
                if self._dataModel.m_reversal then
                    angle = angle + 180
                end
                sKnife:setRotation(angle)
            end
        end
		--全屏鱼的位置出现飞镖爆炸
		local nBoom = 14 + math.random(5)
		local delayTime = 0
		for i=1,nBoom do
            delayTime = math.random(4) * 0.13
			local boomAnim = cc.AnimationCache:getInstance():getAnimation("BombDartsAnim")
			local bomb = cc.Sprite:createWithSpriteFrameName("boom_darts0.png")
			local pos = cc.p(0,0)
			pos.x = 100 + math.random(1234)
			pos.y = 100 + math.random(650)
			bomb:setPosition(pos.x,pos.y)
			local call = cc.CallFunc:create(function()
                bomb:removeFromParent()
			end)
			local delayAction = cc.DelayTime:create(delayTime)
			local action = cc.Sequence:create(delayAction,cc.Animate:create(boomAnim),call)
			bomb:runAction(action)
			parent:addChild(bomb,41)
        end
    end

	if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_23 then
        local radius = 580
		local nBomb = 12
		local pos = cc.p(self:getPositionX(),self:getPositionY())
		for i=1,nBomb do
            local boomAnim = cc.AnimationCache:getInstance():getAnimation("BlueIceAnim")
			local bomb = cc.Sprite:createWithSpriteFrameName("blue00.png")
			bomb:setPosition(self:getPositionX(),self:getPositionY())
			bomb:runAction(cc.Animate:create(boomAnim))
			parent:addChild(bomb,40)
			if boomAnim then
                local purPos = cc.p(0,0)
				purPos.x = pos.x + radius * self._dataModel.m_cosList[30*i]
				purPos.y = pos.y + radius * self._dataModel.m_sinList[30*i]
				local move = cc.MoveTo:create(0.8,purPos)
				local call = cc.CallFunc:create(function()	
                    bomb:removeFromParent()
				end)
				bomb:runAction(cc.Sequence:create(move,call))
			end
		end
	end

	if (self.m_data.fish_kind >=  g_var(cmd).FishKind.FISH_KIND_14 and self.m_data.fish_kind <=  g_var(cmd).FishKind.FISH_KIND_21) or self.m_data.fish_kind ==  g_var(cmd).FishKind.FISH_KIND_24 then
        local radius = 360
		local nBomb = 1
		if self.m_data.fish_kind >=  g_var(cmd).FishKind.FISH_KIND_14 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_17 then
            nBomb = 1
		elseif self.m_data.fish_kind >  g_var(cmd).FishKind.FISH_KIND_17 and self.m_data.fish_kind <=  g_var(cmd).FishKind.FISH_KIND_21 then
			nBomb = 6
		elseif self.m_data.fish_kind ==  g_var(cmd).FishKind.FISH_KIND_24 then
			nBomb = 8
			radius = 580	
		end

		local pos = cc.p(self:getPositionX(),self:getPositionY())
		for i=1,nBomb do
            local boomAnim = cc.AnimationCache:getInstance():getAnimation("BombAnim")
			local bomb = cc.Sprite:createWithSpriteFrameName("boom00.png")
			bomb:setPosition(pos.x,pos.y)
			bomb:runAction(cc.Animate:create(boomAnim))
			parent:addChild(bomb,40)

			if boomAnim then
                local action = nil
				if nBomb == 1 then
                    action = cc.DelayTime:create(0.8)
				else
					local purPos = cc.p(0,0)
					purPos.x = pos.x + self._dataModel.m_cosList[360/nBomb*i]
					purPos.y = pos.y + self._dataModel.m_sinList[360/nBomb*i]
					purPos = self._dataModel:convertCoordinateSystem(purPos, 2, self._dataModel.m_reversal)
					action = cc.MoveTo:create(0.8,purPos)
				end

				local call = cc.CallFunc:create(function()
                    bomb:removeFromParent()
				end)
				bomb:runAction(cc.Sequence:create(action,call))
			end
		end
	end

    local call = cc.CallFunc:create(function()	
        self._dataModel.m_fishList[self.nFishKey] = nil
        self:unScheduleFish()
        self:removeFromParent()
    end)

	if nil ~= ani then
        if self.m_data.fish_kind ~= g_var(cmd).FishKind.FISH_KIND_26  then
            local times = 4
            local repeats = cc.Repeat:create(cc.Animate:create(ani),times)
	        local action = cc.Sequence:create(repeats,call)
	        self:runAction(action)
        end
	else
        if self.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and self.m_data.fish_kind <= g_var(cmd).FishKind.FISH_KIND_40 then
            local action = cc.Sequence:create(cc.DelayTime:create(1),call)
            self:runAction(action)
        else
		    self:runAction(call)
        end
	end
end

function Fish:initPhysicsBody()     -- 设置物理属性
    local fish_kind = self.m_data.fish_kind
    local body = nil
    
    if fish_kind == g_var(cmd).FishKind.FISH_KIND_18 or fish_kind == g_var(cmd).FishKind.FISH_KIND_20 then
        fish_kind = g_var(cmd).FishKind.FISH_KIND_21
        body = self._dataModel:getBodyByType(fish_kind) 
    elseif  fish_kind > g_var(cmd).FishKind.FISH_KIND_30 then
        fish_kind = g_var(cmd).FishKind.FISH_KIND_9
        body = self._dataModel:getBodyByType(fish_kind) 
    elseif fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and fish_kind <= g_var(cmd).FishKind.FISH_KIND_30 then
        fish_kind = g_var(cmd).FishKind.FISH_KIND_8
        body = self._dataModel:getBodyByType(fish_kind) 
    else
        body = cc.PhysicsBody:createBox(self:getContentSize())
    end
    self:setPhysicsBody(body)
    self:getPhysicsBody():setCategoryBitmask(1)     -- 设置刚体属性
    self:getPhysicsBody():setCollisionBitmask(0)
    self:getPhysicsBody():setContactTestBitmask(2)
    self:getPhysicsBody():setGravityEnable(false)
end

function Fish:initWithState()
	
end

function  Fish:setConvertPoint( point ) -- 转换坐标
    local WIN32_W = 1336
    local WIN32_H = 768
    local scalex = yl.WIDTH/WIN32_W
    local scaley = yl.HEIGHT/WIN32_H
    local pos = cc.p(point.x*scalex,(WIN32_H-point.y)*scaley) 
    self:setPosition(pos)
end

function Fish:convertPoint(point)       -- 转换坐标
     local WIN32_W = 1336
	 local WIN32_H = 768
	 local scalex = cc.Director:getInstance():getVisibleSize().width/WIN32_W
	 local scaley = cc.Director:getInstance():getVisibleSize().height/WIN32_H
	 local pos = cc.p(point.x*scalex,point.y*scaley)
     return pos
end

function Fish:Stay(time)    -- 鱼停留
	self:unScheduleFish()
	local call = cc.CallFunc:create(function()	
        self:schedulerUpdate()
	end)
	local delay = cc.DelayTime:create(time/1000)
	self:runAction(cc.Sequence:create(delay,call))
end

function Fish:updateScheduleSceneFish(param)    -- 场景鱼的位置坐标
    self.m_oldPoint = self:convertPoint(cc.p(param.init_pos[1][1].x,param.init_pos[1][1].y))
    local function updateFish(dt)
        if nil ~= self.m_schedule then
            scheduler:unscheduleScriptEntry(self.m_schedule)
            self.m_schedule = nil
        end
        local nowPos = cc.p(self:getPositionX(),self:getPositionY())
        if cc.rectContainsPoint( cc.rect(0,0,yl.WIDTH, yl.HEIGHT), nowPos ) then
            self._bFishInView = true
			self._dataModel.m_InViewTag[self.m_data.fish_id] = 1
		else
		    self._bFishInView = false
		    self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
		end
        if self.stop_count_ > 0 and  self.m_pathIndex == self.stop_index_ and self.current_stop_count_< self.stop_count_ then
            self.current_stop_count_ = self.current_stop_count_ + 1
            if self.current_stop_count_ >=  self.stop_count_ then
                self:setStopFishInTime(0,0)
            end
            return
        end
        if self.m_pathIndex >  #param.init_pos[1] - 2 then
            if nil ~= self.m_scheduleSceneFish then
                scheduler:unscheduleScriptEntry(self.m_scheduleSceneFish)
                self.m_scheduleSceneFish = nil
                local function removeCallBack()
                    self._dataModel.m_fishList[self.m_data.fish_id] = nil
                    self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
                    self:removeFromParent()
                end
                local distance = self:CalcDistance(param.init_pos[1][#param.init_pos[1]].x,param.init_pos[1][#param.init_pos[1]].y,param.init_pos[1][#param.init_pos[1]-2].x,param.init_pos[1][#param.init_pos[1]-2].y)
                local swimTime = distance/100
                local angle = self._dataModel:getAngleByTwoPoint(cc.p(param.init_pos[1][#param.init_pos[1]].x,param.init_pos[1][#param.init_pos[1]].y),self.m_oldPoint)
                self:setRotation(angle)
                if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_18 or self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_20 then
                    if angle >= 0 and angle <= 180 then
                        self:setRotation(0)
                    else
                        self:setRotation(90)
                    end
                end
                local bt = cc.MoveTo:create(swimTime,self:convertPoint(cc.p(param.init_pos[1][#param.init_pos[1]].x,param.init_pos[1][#param.init_pos[1]].y)))
                local action = cc.Sequence:create(bt,cc.CallFunc:create(removeCallBack))
                self:runAction(action)
	       end
           return
        end
        self:setPosition(cc.p(param.init_pos[1][self.m_pathIndex].x,param.init_pos[1][self.m_pathIndex].y))
        local angle = self._dataModel:getAngleByTwoPoint(cc.p(param.init_pos[1][self.m_pathIndex].x,param.init_pos[1][self.m_pathIndex].y),self.m_oldPoint)
        self:setRotation(angle)
        if self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_18 or self.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_20 then
            if angle >= 0 and angle <= 180 then
                self:setRotation(0)
            else
                self:setRotation(90)
            end
        end
        self.m_oldPoint = cc.p(param.init_pos[1][self.m_pathIndex].x,param.init_pos[1][self.m_pathIndex].y)
        self.m_pathIndex = self.m_pathIndex + 1
    end
    
	if nil == self.m_scheduleSceneFish then     -- 定时器
		self.m_scheduleSceneFish = scheduler:scheduleScriptFunc(updateFish, 0.05, false)
	end
end

function Fish:initWithType( param,target,isSceneFish)
    self.m_oldPoint = self:convertPoint(cc.p(param.init_pos[1][1].x,param.init_pos[1][1].y))
    self:setPosition(self.m_oldPoint)
    local swimTime = target.fish_speed[param.fish_kind + 1]
    if math.abs(param.init_pos[1][1].x - param.init_pos[1][3].x) >= g_var(cmd).FISHSERVER_WIDTH then
        swimTime =cc.Director:getInstance():getVisibleSize().width/(swimTime*15*g_var(cmd).FISHSERVER_WIDTH/cc.Director:getInstance():getVisibleSize().width)
    elseif  math.abs(param.init_pos[1][1].y - param.init_pos[1][3].y) >= g_var(cmd).FISHSERVER_HEIGHT then
        swimTime =cc.Director:getInstance():getVisibleSize().height/(swimTime*15*g_var(cmd).FISHSERVER_HEIGHT/cc.Director:getInstance():getVisibleSize().height)
    else
        swimTime = swimTime + 10
    end
    
    local  function removeCallBack()
        self._dataModel.m_fishList[self.m_data.fish_id] = nil
        self._dataModel.m_InViewTag[self.m_data.fish_id] = nil
        self:removeFromParent()
    end

    if isSceneFish == true then
        self.m_oldPoint = cc.p(param.init_pos[1][1].x,param.init_pos[1][1].y)
        self:setPosition(self.m_oldPoint)
        bt = cc.MoveTo:create(20,self:convertPoint(cc.p(param.init_pos[1][3].x,param.init_pos[1][3].y)))
        local action = cc.Sequence:create(bt,cc.CallFunc:create(removeCallBack))
        self:runAction(action)
        return
    end

    local bt = nil
    if param.trace_type == g_var(cmd).TraceType.TRACE_LINEAR then
        bt = cc.MoveTo:create(swimTime,self:convertPoint(cc.p(param.init_pos[1][3].x,param.init_pos[1][3].y)))
    else
        bt = cc.BezierTo:create(swimTime,{self:convertPoint(cc.p(param.init_pos[1][1].x,param.init_pos[1][1].y)),self:convertPoint(cc.p(param.init_pos[1][2].x,param.init_pos[1][2].y)),self:convertPoint(cc.p(param.init_pos[1][3].x,param.init_pos[1][3].y))}) 
    end
    local action = cc.Sequence:create(bt,cc.CallFunc:create(removeCallBack))
    self:runAction(action)
end

function Fish:initCircleFish( param,target)
    self.m_oldPoint = self:convertPoint(cc.p(param.init_pos[1][1].x,param.init_pos[1][1].y))
    self:setPosition(self.m_oldPoint)
    local swimTime = self:CalcDistance(param.init_pos[1][3].x,param.init_pos[1][3].y,param.init_pos[1][1].x,param.init_pos[1][1].y)/50
    local function removeCallBack()
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

function Fish:CalcDistance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
end

return Fish