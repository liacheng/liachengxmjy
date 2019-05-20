local module_pre    = "game.yule.animalbattle.src"
local cmd           = appdf.req(module_pre .. ".models.CMD_Game")
local ZhuanPanAni   = class("ZhuanPanAni",cc.Layer)

ZhuanPanAni.MAX_COUNT = 28

function ZhuanPanAni:ctor(scene,begIndex,endIndex,duration,totalSec) --从最左边的第一个兔子开始为位置索引开始处，顺时针递增
	self.scene = scene
    self.begIndex = begIndex
    self.endIndex = endIndex
	self.duration = duration
	self.totalSec = totalSec
    self.curIndex = 1
	local deltaC = self.duration or 10
	local deltaT = cc.Director:getInstance():getAnimationInterval()
	self.frames = math.floor(deltaC/deltaT) --持续帧数
    
    self.tabZhuanpanPos = {}
    for i = 1, ZhuanPanAni.MAX_COUNT do
        table.insert(self.tabZhuanpanPos ,cc.p(self.scene.m_LightSprite[i]:getPosition()))
    end	
end

function ZhuanPanAni.zhuanpanPosToKind(index)   -- 从最左边的第一个兔子开始为位置索引开始处，顺时针索引递增
    local tab = {                               -- 服务端发来的转盘停止位置索引[1,28]
        cmd.JS_TU_ZI, cmd.JS_TU_ZI, cmd.JS_TU_ZI, cmd.JS_JIN_SHA, cmd.JS_YAN_ZI, cmd.JS_YAN_ZI, cmd.JS_YAN_ZI,
		cmd.JS_GE_ZI, cmd.JS_GE_ZI, cmd.JS_GE_ZI, cmd.JS_TONG_SHA, cmd.JS_KONG_QUE, cmd.JS_KONG_QUE, cmd.JS_KONG_QUE,
		cmd.JS_LAO_YING, cmd.JS_LAO_YING, cmd.JS_LAO_YING, cmd.JS_YIN_SHA, cmd.JS_SHI_ZI, cmd.JS_SHI_ZI, cmd.JS_SHI_ZI,
		cmd.JS_XIONG_MAO, cmd.JS_XIONG_MAO, cmd.JS_XIONG_MAO, cmd.JS_TONG_PEI, cmd.JS_HOU_ZI, cmd.JS_HOU_ZI, cmd.JS_HOU_ZI 
    }              
    dbg_assert(#tab==ZhuanPanAni.MAX_COUNT)              
    return tab[index]
	end

function ZhuanPanAni:moveAStep(node, index)
	node.m_index = node.m_index+1
	if node.m_index > ZhuanPanAni.MAX_COUNT then
		node.m_index = 1
	end
	node:setPosition(cc.p(self.tabZhuanpanPos[node.m_index]))

    if self.scene.BigAnimal and index == 1 then
        self.scene:BigAnimal(node.m_index)
    end
end

function ZhuanPanAni:ZhuanPan(callback)
    self.callback = callback
	local begTime = os.time()
	local endIndex = self.endIndex
	local begIndex = self.begIndex
	self.startTime = begTime

	if self.frames == 0 then
		return 
	end

	local bright=display.newSprite("#animalbattle_bg_bright.png")	
	bright.m_index = self.begIndex
	bright:setPosition(self.tabZhuanpanPos[bright.m_index])
    self:addChild(bright)
	self.bright = bright

	local perimeter = ZhuanPanAni.MAX_COUNT     -- 总共28个格子
	self.everyNFrame={9,8,7,6,5,4,3,2,1}        -- 表示每隔everyNFrame[speedKind]帧移动一次,只需要设置这里以更改跑马灯动画
    self.fastest = #self.everyNFrame            -- 除最慢外，每种速度跑的steps数 varSpeedSteps=40/everyNFrame[speedKind]
	self.slowest = 1                            -- speedKind
	local t = self.frames/(2*#self.everyNFrame-1)
	self.varSpeedSteps={}
	for i=1,#self.everyNFrame-1 do
		self.varSpeedSteps[i]=math.max( 1, math.floor(t/self.everyNFrame[i]) )
	end

	--计算除最快速度外的总步数
	local steps=0
	for i=1,#self.everyNFrame-1 do
		steps=steps+2*(self.varSpeedSteps[i])
	end
	-- print("steps= ",steps)
	local fastestSteps=(perimeter+endIndex-(begIndex+steps)%perimeter)%perimeter
	if fastestSteps==0 then
		fastestSteps=perimeter
	end
	self.varSpeedSteps[#self.everyNFrame]=fastestSteps
	
	local function 	brightDelayRemoveSelf(t)
		self.bright:runAction(cc.Sequence:create(
		--cc.Blink:create(math.max(0,t),math.max(1,t)),
        cc.DelayTime:create(math.max(1,t)),
		cc.CallFunc:create(function() self.bright:removeSelf() end)
		))
	end
	self.brightDelayRemoveSelf=brightDelayRemoveSelf
	
	self.speedKind=self.slowest 
	self.frameN=0
	self.changeSpeed=1
	self.changeSpeedN=0 --每移动一次加1，当changeSpeedN>=varSpeedSteps[speedKind]，speedKind变化
	self.stepsRunned=0 -- for debug
	self.followRects={}
	local function moveBrightRect(dt)
		self.frameN = self.frameN + 1
		if self.frameN>=self.everyNFrame[self.speedKind] then
			self.frameN=0
			self:moveAStep(self.bright, 1)
			for k,circle in ipairs(self.followRects) do
				self:moveAStep(circle)
			end
			self.stepsRunned=self.stepsRunned+1
			self.changeSpeedN=self.changeSpeedN+1
			if self.changeSpeedN>=self.varSpeedSteps[self.speedKind] then
				self.changeSpeedN=0
				if self.speedKind==self.fastest then
					self.changeSpeed=-self.changeSpeed
				end
				if self.changeSpeed>0 then
					local followRect
					followRect=display.newSprite("#animalbattle_bg_bright.png")
                    --followRect:setScale(0.65)
					followRect:addTo(self)
					local lastFollow=self.followRects[#self.followRects] or self.bright
					followRect.m_index= lastFollow.m_index-1<=0 and ZhuanPanAni.MAX_COUNT or (lastFollow.m_index-1)
                    followRect:setOpacity(255-self.curIndex*20)
					followRect:setPosition(cc.p(self.tabZhuanpanPos[followRect.m_index])) --aw/2==36,ah/2==36
					table.insert(self.followRects,followRect)
                    self.curIndex = self.curIndex+1
				else
					local rect=self.followRects[#self.followRects]
					if nil~=rect then rect:removeSelf() end
					self.followRects[#self.followRects]=nil
				end
	
				self.speedKind=self.speedKind+self.changeSpeed
				if self.speedKind<=self.slowest-1 then

					self:unscheduleUpdate()
					self.bUnscheduleUpdate=true
					local usedSec=os.time()-begTime
					local restSec=math.max(0.1,self.totalSec-usedSec)
					dbg_assert(self.bright.m_index==self.endIndex)

					self:runAction(
						cc.CallFunc:create(function() 
							brightDelayRemoveSelf(self.restSec)
							if self.callback then self.callback(math.max(0,self.restSec)) end
						end)
					)
				end
			end
		end
	end
	self.moveBrightRect = moveBrightRect

	self:scheduleUpdate(
		function()
            local t = os.time()
			if self.lastUpdateTime == nil then
				self.lastUpdateTime = t
				self.restSec = self.totalSec
				moveBrightRect()
				return
			end
			local elapsed = t - self.lastUpdateTime
			if self.lastUpdateTime == nil or ( t - self.startTime < self.duration and elapsed <= 1) then 
				self.lastUpdateTime = t
				self.restSec = self.totalSec - ( t - self.startTime)
				moveBrightRect()
				return
			end
			self.restSec = self.totalSec - ( t - self.startTime)
			self.lastUpdateTime = t
			if t - self.startTime >= self.totalSec then --从后台返回来
				self:unscheduleUpdate()
				self.bright:removeSelf()
				for k,v in pairs(self.followRects) do
					v:removeSelf()
				end
			elseif t-self.startTime>=self.duration then
				self:unscheduleUpdate()
				self.bright:setPosition(cc.p(self.tabZhuanpanPos[self.endIndex]))
				for k,v in pairs(self.followRects) do
					v:removeSelf()
				end
				self.restSec=self.totalSec-(t-self.startTime)
				self:runAction(
						cc.CallFunc:create(function() 
							self.brightDelayRemoveSelf(self.restSec)
							if self.callback then self.callback(self.restSec) end
						end))
			elseif t - self.startTime < self.duration then  --2改成准确数字
				self:resumeZhuanPan(elapsed)
			end
		end
		)
end

function ZhuanPanAni:resumeZhuanPan(timeElapsed) --timeElapsed表示在后台的时间
		self:stopAllActions()
		local animationInterval=cc.Director:getInstance():getAnimationInterval()
		local passedFrames=timeElapsed/animationInterval
		for i=1,passedFrames do --在后台有passedFrames帧(=在后台的时间/animationInterval)没有调用moveBrightRect，这里一次性完成
			if self.bUnscheduleUpdate==true then
				return
			end
			self.moveBrightRect()
		end

		if self.bUnscheduleUpdate~=true then
			self:scheduleUpdate(self.moveBrightRect)
		end
	end

return ZhuanPanAni