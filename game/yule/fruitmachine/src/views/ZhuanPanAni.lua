	local module_pre = "game.yule.fruitmachine.src"
    local cmd = appdf.req(module_pre .. ".models.CMD_Game")
	local ZhuanPanAni=class("ZhuanPanAni",cc.Layer)
    local scheduler = cc.Director:getInstance():getScheduler()

	ZhuanPanAni.tabZhuanpanPos=cmd.tabZhuanpanPos
    ZhuanPanAni.STOP_SHINE_FRAME = 30

    function ZhuanPanAni:getParentNode()
	    return self._scene
    end

	function ZhuanPanAni:ctor(scene,begIndex,endIndex,duration,totalSec) --从最左边的第一个开始为位置索引开始处，顺时针递增
		scene:addChild(self)
		self.scene,self.begIndex,self.endIndex=scene,begIndex,endIndex
		self.duration=duration
		local deltaT=cc.Director:getInstance():getAnimationInterval()
		--local frameRate=1/deltaT
		duration=duration or 10
		self.frames=math.floor(duration/deltaT) --持续帧数		
		self.totalSec=totalSec

        self.brightFrame=cc.Sprite:create("gui-fruit-run.png")
        self.brightFrame:setVisible(false)
        self:addChild(self.brightFrame)
		
		self._scene = scene
	end

	function ZhuanPanAni.zhuanpanPosToKind(index) 
        return index
	end

	function ZhuanPanAni:moveAStep(node)
		node.m_index=node.m_index+1
		if node.m_index>24 then
			node.m_index=1
		end
		node:setPosition(self.tabZhuanpanPos[node.m_index])
	end

--	function ZhuanPanAni:animationForFirstOpening() --第一次进入为开奖状态，乱闪
--		local bright=cc.Sprite:create("gui-fruit-run.png")
--		bright:addTo(self)
--		bright:scheduleUpdate(function() bright:setPosition(self.tabZhuanpanPos[math.random(24)]) end)
--	end

--	function ZhuanPanAni:animationForFirstOpening(flag) --第一次进入为开奖状态，乱闪
--		local bright=cc.Sprite:create("gui-fruit-run.png")
--		bright:addTo(self)

--        local function test()
--            bright:setPosition(self.tabZhuanpanPos[math.random(24)]) 
--        end

--        if(flag == false) then
--		    bright:scheduleUpdate(test)
--        else
--            bright:unscheduleUpdate()
--            print("-----------bright:unscheduleUpdate()")
--        end
--	end

	function ZhuanPanAni:ZhuanPan(callback)

		self.callback=callback
		local begTime=os.time()
		self.startTime=begTime
		local endIndex=self.endIndex
		local begIndex=self.begIndex

		if self.frames==0 then
			return 
		end

		local scene=self.scene
		
        self.bright=cc.Sprite:create("gui-fruit-run.png")
          
		self:addChild(self.bright)
		self.bright.m_index=self.begIndex
		self.bright:setPosition( self.tabZhuanpanPos[self.bright.m_index] )
		--self.bright=bright
		local perimeter=24 --总共24个格子
		 --表示每隔everyNFrame[speedKind]帧移动一次
		--self.everyNFrame={9,8,7,6,5,4,3,2,1} --只需要设置这里以更改跑马灯动画
        self.everyNFrame={16,14,12,10,5,3,3,1,1} --只需要设置这里以更改跑马灯动画
		
		--除最慢外，每种速度跑的steps数 varSpeedSteps=40/everyNFrame[speedKind]
		self.fastest=#self.everyNFrame --speedKind
		self.slowest=1			   --speedKind

		local t=self.frames/(2*#self.everyNFrame-1)
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
			--print("t: ",t)
			self.bright:runAction(cc.Sequence:create(
			cc.Blink:create(math.max(0,t),math.max(1,t)),
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

			self.frameN=self.frameN+1
			if self.frameN>=self.everyNFrame[self.speedKind] then
				self.frameN=0
				self:moveAStep(self.bright)

				self.stepsRunned=self.stepsRunned+1
				self.changeSpeedN=self.changeSpeedN+1
				if self.changeSpeedN>=self.varSpeedSteps[self.speedKind] then
					self.changeSpeedN=0
					if self.speedKind==self.fastest then
						self.changeSpeed=-self.changeSpeed
					end

					self.speedKind=self.speedKind+self.changeSpeed
                    if self.speedKind <= self.slowest-1 then

--                    print("self.speedKind = "..self.speedKind)
--                    print("self.slowest = "..self.slowest)

						self:unscheduleUpdate()
						self.bUnscheduleUpdate=true
						local usedSec=os.time()-begTime
						local restSec=math.max(0.1,self.totalSec-usedSec)

--						print("restSec:",restSec)
--						print("usedSec",usedSec)
						
						--跑灯完成
						self._scene:RunOver()
						
						--dbg_assert(self.bright.m_index==self.endIndex)

						self:runAction(
							cc.CallFunc:create(function()
           
--                              brightDelayRemoveSelf(self.restSec+3)
                                brightDelayRemoveSelf(self.restSec)
                                if self.brightFrame == nil then
                                    self.brightFrame=cc.Sprite:create("gui-fruit-run.png")
                                    self:addChild(self.brightFrame)
                                end
                                self.brightFrame:setVisible(true)
                                self.brightFrame:setPosition( self.tabZhuanpanPos[self.bright.m_index] )

                                local actStopShineFrame = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.Blink:create(3,6)))
                                actStopShineFrame:setTag(ZhuanPanAni.STOP_SHINE_FRAME)
                                self.brightFrame:runAction(actStopShineFrame)
								if self.callback then self.callback(math.max(0,self.restSec)) end
							end)
						)

					end
				end
			end
		end
		self.moveBrightRect=moveBrightRect

		self:scheduleUpdate(
			function()
				local t=os.time()
				if self.lastUpdateTime==nil then
					self.lastUpdateTime=t
					self.restSec=self.totalSec
					moveBrightRect()
					return
				end
                
				local elapsed=t-self.lastUpdateTime
				--print("elapsed:",elapsed)
				--if self.lastUpdateTime==nil or (t-self.startTime<self.duration and elapsed<=1) then 
                --if self.lastUpdateTime==nil or (t-self.startTime<=self.duration and elapsed<=1) then 
					self.lastUpdateTime=t
					self.restSec=self.totalSec-(t-self.startTime)
					moveBrightRect()
					return
				end
			--end
			)
	end

    function ZhuanPanAni:StopShineFrame()
        if self.brightFrame~=nil then
            self.brightFrame:stopAction(self.brightFrame:getActionByTag(ZhuanPanAni.STOP_SHINE_FRAME))
            self.brightFrame:removeSelf()
            self.brightFrame=nil
        end
    end

	function ZhuanPanAni:ZhuanPanLuck(callback)

		self.callback=callback
		local begTime=os.time()
		self.startTime=begTime
		local endIndex=self.endIndex
		local begIndex=self.begIndex

		if self.frames==0 then
			return 
		end

		local scene=self.scene
		
        self.bright=cc.Sprite:create("gui-fruit-run.png")
          
		self:addChild(self.bright)
		self.bright.m_index=self.begIndex
		self.bright:setPosition( self.tabZhuanpanPos[self.bright.m_index] )
		local perimeter=24 --总共24个格子
		 --表示每隔everyNFrame[speedKind]帧移动一次
        self.everyNFrame={16,15,14,13,2,2,1,1,1} --只需要设置这里以更改跑马灯动画
		
		--除最慢外，每种速度跑的steps数 varSpeedSteps=40/everyNFrame[speedKind]
		self.fastest=#self.everyNFrame --speedKind
		self.slowest=1			   --speedKind

		local t=self.frames/(2*#self.everyNFrame-1)
		self.varSpeedSteps={}
		for i=1,#self.everyNFrame-1 do
			self.varSpeedSteps[i]=math.max( 1, math.floor(t/self.everyNFrame[i]) )
		end

		--计算除最快速度外的总步数
		local steps=0
		for i=1,#self.everyNFrame-1 do
			steps=steps+2*(self.varSpeedSteps[i])
		end
		local fastestSteps=(perimeter+endIndex-(begIndex+steps)%perimeter)%perimeter
		if fastestSteps==0 then
			fastestSteps=perimeter
		end
		self.varSpeedSteps[#self.everyNFrame]=fastestSteps
		
		local function 	brightDelayRemoveSelf(t)
			print("t: ",t)
			self.bright:runAction(cc.Sequence:create(
			cc.Blink:create(math.max(0,t),math.max(1,t)),
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

			self.frameN=self.frameN+1
			if self.frameN>=self.everyNFrame[self.speedKind] then
				self.frameN=0
				self:moveAStep(self.bright)

				self.stepsRunned=self.stepsRunned+1
				self.changeSpeedN=self.changeSpeedN+1
				if self.changeSpeedN>=self.varSpeedSteps[self.speedKind] then
					self.changeSpeedN=0
					if self.speedKind==self.fastest then
						self.changeSpeed=-self.changeSpeed
					end

					self.speedKind=self.speedKind+self.changeSpeed
                    if self.speedKind <= self.slowest-1 then

						self:unscheduleUpdate()
						self.bUnscheduleUpdate=true
						local usedSec=os.time()-begTime
						local restSec=math.max(0.1,self.totalSec-usedSec)
						
						--跑灯完成
						self._scene:RunOver()
						
						self:runAction(
							cc.CallFunc:create(function()
                                brightDelayRemoveSelf(self.restSec)
                                self.brightFrame:setVisible(true)
                                self.brightFrame:setPosition( self.tabZhuanpanPos[self.bright.m_index] )
								if self.callback then self.callback(math.max(0,self.restSec)) end
							end)
						)

					end
				end
			end
		end
		self.moveBrightRect=moveBrightRect

		self:scheduleUpdate(
			function()
				local t=os.time()
				if self.lastUpdateTime==nil then
					self.lastUpdateTime=t
					self.restSec=self.totalSec
					moveBrightRect()
					return
				end
           
				local elapsed=t-self.lastUpdateTime

                if self.lastUpdateTime==nil or (t-self.startTime<=self.duration and elapsed<=1) then 
					self.lastUpdateTime=t
					self.restSec=self.totalSec-(t-self.startTime)
					moveBrightRect()
					return
				end
			end
			)
	end

return ZhuanPanAni