--
-- Author: Tang
-- Date: 2016-08-09 10:27:07
--炮
local Cannon = class("Cannon", cc.Sprite)
local module_pre = "game.yule.fishlk.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
local Bullet = require(module_pre..".views.layer.Bullet")
local Gold = require(module_pre..".views.layer.Gold")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()

Cannon.Tag = 
{
	Tag_Award = 10,
	Tag_Light = 20,
	Tag_Type  = 30,
	Tag_lock  = 3000,
    Tag_lockLine = 4000
}

local TagEnum = Cannon.Tag

function Cannon:ctor(viewParent)
	self.m_pos = 0    --炮台位置
	self.m_fort = nil
	self.m_nickName = nil
	self.m_score = nil
	self.m_multiple = nil
	self.m_isShoot = false
	self.m_canShoot = true
	self.m_autoShoot = false
	self.m_typeTime = 0
	self.orignalAngle = 0
	self.m_fishIndex = g_var(cmd).INT_MAX
	self.m_index  = 0                                   -- 子弹索引
	self.m_ChairID  = yl.INVALID_CHAIR
	self.m_autoShootSchedule = nil
	self.m_otherShootSchedule = nil
	self.m_typeSchedule = nil
	self.m_targetPoint = cc.p(0,0)
	self.m_cannonPoint = cc.p(0,0)
	self.m_firelist = {}
	self.m_nMutipleIndex = 0        
    self.m_bulletMutiple = 100                          -- 当前子弹倍数
	self.m_Type = g_var(cmd).CannonType.Normal_Cannon
	self.parent = viewParent
	self._dataModel = self.parent._dataModel
	self.frameEngine = self.parent._gameFrame 
    self.m_laserPos = cc.p(0,0)
	self.m_laserConvertPos = cc.p(0,0)
	self.m_laserBeginConvertPos = cc.p(0,0)
	self.m_pUserItem = self.frameEngine:GetMeUserItem() -- 获取自己信息
  	self.m_nTableID  = self.m_pUserItem.wTableID
  	self.m_nChairID  = self.m_pUserItem.wChairID	
  	self.m_pOtherUserItem = nil                         -- 其他玩家信息
    self.m_pGold = Gold:create()
    self.m_pGold:setPosition(50, 0)
    self:addChild(self.m_pGold)
    ExternalFun.registerTouchEvent(self,false)          -- 注册事件
end

function Cannon:onExit( )
	self:unAutoSchedule()
	self:unTypeSchedule()
	self:unOtherSchedule()
end

function Cannon:setCannonMuitle(multiple)
	self.m_nMutipleIndex = multiple
end

function Cannon:initWithUser(userItem)
	self.m_ChairID = userItem.wChairID
	if self.m_ChairID ~= self.m_nChairID then
        self.m_pOtherUserItem = userItem
	end

	self:setContentSize(100,100)
	self:removeChildByTag(1000)
	self.m_fort = cc.Sprite:createWithSpriteFrameName("btnFort_0.png")
	self.m_fort:setTag(1000)
	self.m_fort:setPosition(50,60)
	self:addChild(self.m_fort,1)
	self.m_pos = userItem.wChairID
	if self._dataModel.m_reversal then 
        self.m_pos = 5 - self.m_pos
	end

	if self.m_pos < 3 then
		self.m_fort:setRotation(180)
	end
end

function Cannon:setFishIndex(index)
	self.m_fishIndex = index
end


function Cannon:setMultiple(multiple,chairId)
    self.m_bulletMutiple = multiple
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_0.png")
    local mutiNum = multiple /self.parent.parent.min_bullet_multiple 
    if multiple < 1000  then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_0.png")
    elseif multiple >= 1000 and multiple < 10000 then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_2.png")
    elseif multiple >= 10000 then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_3.png")
    end
	self.m_fort:setSpriteFrame(frame)
	self.parent:updateMultiple(multiple,chairId+1)
end

function Cannon:setMyMultiple(multiple)
    self.m_nCurrentBulletScore = multiple
    local mutiNum = multiple /self.parent.parent.min_bullet_multiple 
    if multiple < 1000  then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_0.png")
    elseif multiple >= 1000 and multiple < 5000 then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_2.png")
    elseif multiple >= 5000 then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_3.png")
    end
	self.m_fort:setSpriteFrame(frame)
end

function Cannon:setAutoShoot( b )       -- 自动射击
	self.m_autoShoot = b
	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
        self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

	if self.m_Type >= g_var(cmd).CannonType.Laser_Cannon then
		return
	end

	if self.m_autoShoot then
        local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]]
		self:autoSchedule(dt)
	else
		self:unAutoSchedule()	
	end
end

function Cannon:typeTimeUpdate( dt )
	self.m_typeTime = self.m_typeTime - dt
	local tmp = self:getChildByTag(TagEnum.Tag_Type)
	if nil ~= tmp then
		local timeshow = tmp:getChildByTag(1)
		timeshow:setString(string.format("%d",self.m_typeTime))
	end

	if self.m_typeTime <= 0 then
        self:removeTypeTag()
		self:unTypeSchedule()
		self:setCannonType(g_var(cmd).CannonType.Normal_Cannon, 0)
	end
end

function Cannon:shoot( vec , isbegin )      -- 自己开火
	if not self.m_canShoot then
		self.m_isShoot = isbegin
		return
	end

	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then
        self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

    self.m_laserPos.x = vec.x
	self.m_laserPos.y = vec.y
	local angle = self._dataModel:getAngleByTwoPoint(vec, self.m_cannonPoint)
	self.m_targetPoint = vec

	if angle < 90  then 
        if not self._dataModel.m_autolock then
            self.m_fort:setRotation(angle)
		end
	end

	if self.m_Type == g_var(cmd).CannonType.Laser_Shooting then
        return
	end

	if self.m_Type == g_var(cmd).CannonType.Laser_Cannon  then
		self:shootLaser()
		return
	end

	if self.m_autoShoot or self._dataModel.m_autolock then
		return
	end

	if not self.m_isShoot and isbegin then
		self.m_isShoot = true
        self:autoUpdate(0)
        local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]]
		self:autoSchedule(dt)
	end

	if not isbegin then
		self.m_isShoot = false
		self:unAutoSchedule()
	end
end

function Cannon:othershoot( firedata )  -- 其他玩家开火
	table.insert(self.m_firelist,firedata)
    local chairId = firedata.chair_id
    if self._dataModel.m_reversal then 
		chairId = 5 - chairId
	end
	self:setMultiple(firedata.bullet_mulriple,chairId)
    self._dataModel.fish_score_[firedata.chair_id + 1] = self._dataModel.fish_score_[firedata.chair_id + 1] + firedata.fish_score
    self.parent:updateUserScore(self._dataModel.fish_score_[firedata.chair_id + 1],self.m_pos+1)	
    if firedata.lock_fishid == g_var(cmd).INT_MAX then
		self:removeLockTag(firedata.chair_id)
	end

	local fish = self._dataModel.m_fishList[firedata.lock_fishid]
	if fish == nil then
		self:removeLockTag(firedata.chair_id)
	end

    if firedata.chair_id ~= self.m_nChairID and fish ~= nil and firedata.lock_fishid ~= g_var(cmd).INT_MAX then
        local fishData = fish.m_data
        self:setLockFishLogo(firedata.chair_id,fishData.fish_kind)
    end

	self:otherSchedule(0.2)
end

function Cannon:setLockFishLogo(chairId,fishKind)
    local frameName = string.format("%d_%d.png", fishKind+1,1)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
    local _chairId = chairId
    if self._dataModel.m_reversal then 
        _chairId = 5 - _chairId
    end

    if nil ~= frame then
        local sp = self:getChildByTag(TagEnum.Tag_lock + chairId)
        if nil == sp then
            local pos = cc.p(-40,145)
            if _chairId < 3 then
                pos = cc.p(-40,0)
            end
            sp = cc.Sprite:createWithSpriteFrame(frame)
            sp:setTag(TagEnum.Tag_lock + chairId)
            sp:setName(frameName)
            sp:setPosition(pos.x,pos.y)
            self:addChild(sp)
            sp:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos.x,pos.y),10)))
        else
            if sp:getName() ~=  frameName then
                sp:setSpriteFrame(frame)
            end 
        end
    else
        self:removeLockTag(chairId)					
    end
end

function Cannon:setLockFishLine(chairId,fishId)
    local function updateLine()

    end
    local width = cc.Director:getInstance():getVisibleSize().width
    local height = cc.Director:getInstance():getVisibleSize().height
    local distanceScreen = math.sqrt(width * width + height * height)
    local num = math.ceil(distanceScreen / 100)
    local node = cc.Node:create()
    node:setTag(TagEnum.Tag_lockLine + chairId)
    self:addChild(node)
    for i = 1,num do
        local sp = cc.Sprite:create("game_res/lock_line.png")
        node:addChild(sp)
    end
end

function Cannon:productBullet( isSelf,fishIndex, netColor,bundleChairId,bullet_mulriple,bulletId,android_chairid,bulletSpeedIndex)  -- 制造子弹
    local angleFort = self.m_fort:getRotation()
	self:setFishIndex(self._dataModel.m_fishIndex)
	local bullet0 = Bullet:create(angleFort,bundleChairId,bullet_mulriple,self.m_Type,self,android_chairid,bulletSpeedIndex)
    local bulletB = nil
    local bulletC = nil
	local angle = math.rad(90-angleFort)
	local movedir = cc.pForAngle(angle)
	movedir = cc.p(movedir.x * 25 , movedir.y * 25)
	local offset = cc.p(20 * math.sin(angle),20 * math.cos(angle))
	local moveBy = cc.MoveBy:create(0.065,cc.p(-movedir.x*0.65,-movedir.y * 0.65))
	self.m_fort:runAction(cc.Sequence:create(moveBy,moveBy:reverse()))

	bullet0:setType(self.m_Type)
	bullet0:setIndex(bulletId)
	bullet0:setIsSelf(isSelf)
    bullet0:setBbullet(bulletB)
	bullet0.m_bbullet = bulletB
    bullet0:setCbullet(bulletC)
	bullet0.m_cbullet = bulletC
    bullet0:setNetColor(netColor)
	bullet0:setFishIndex(fishIndex)
	bullet0:initPhysicsBody()
    bullet0:setBulletNum(1)
	bullet0:setTag(g_var(cmd).Tag_Bullet)
	local pos0 = cc.p(self.m_cannonPoint.x ,self.m_cannonPoint.y )
	bullet0:setPosition(pos0)
	self.parent.parent._gameView:addChild(bullet0,5) --self.parent.parent为GameLayer
   
	if isSelf then
        local pos = cc.p(movedir.x * 25 , movedir.y * 25)
  		pos = cc.p(self.m_cannonPoint.x + pos.x , self.m_cannonPoint.y + pos.y)
  		pos = self._dataModel:convertCoordinateSystem(pos, 0, self._dataModel.m_reversal)
  		self._dataModel:playEffect(g_var(cmd).Shell_8)
	end
end

function Cannon:fastDeal(  )
	self.m_canShoot = false
    self:runAction(cc.Sequence:create(cc.DelayTime:create(5.0),cc.CallFunc:create(function(	)
        self.m_canShoot = true
	end)))
end

function Cannon:setCannonType( cannontype,times)	
    if self.m_Type == g_var(cmd).CannonType.Special_Cannon and cannontype ~= g_var(cmd).CannonType.Special_Cannon then 
        if self.m_autoShoot or self.m_isShoot then
            self:unAutoSchedule()
            local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]]
			self:autoSchedule(dt)
		end

		if 0 ~= #self.m_firelist then
			self:unOtherSchedule()
			local time = self._dataModel.m_secene.nBulletCoolingTime/1200
			self:otherSchedule(time)
		end
	end

	if cannontype == g_var(cmd).CannonType.Special_Cannon then
        local nBulletNum = math.floor(self.m_nMutipleIndex/2) + 1
		local str = string.format("btnFort_0.png",nBulletNum)
		self.m_fort:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_0.png"))
		self.m_Type = g_var(cmd).CannonType.Special_Cannon
		if self.m_autoShoot or self.m_isShoot then
            self:unAutoSchedule()
            local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]]
			self:autoSchedule(dt)
		end

		if #self.m_firelist > 0 then 
			self:unOtherSchedule()
			local  time = self._dataModel.m_secene.nBulletCoolingTime/2400
			self:otherSchedule(time)
		end

		local Type = cc.Sprite:create("game_res/im_icon_0.png")
		Type:setTag(TagEnum.Tag_Type)
		Type:setPosition(-16,-40)
		self:removeTypeTag()
		self:addChild(Type)

		local pos = nil
		if self.m_pos < 3 then
			pos = cc.p(110,-45)
		else
			pos = cc.p(110,150)
		end

		Type:setPosition(pos.x,pos.y)
		self.m_typeTime = times
		self:typeTimeSchedule(1.0)

		local timeShow = cc.LabelAtlas:create(string.format("%d", times),"game_res/lockNum.png",16,22,string.byte("0"))
		timeShow:setAnchorPoint(0.5,0.5)
		timeShow:setPosition(Type:getContentSize().width/2, 27)
		timeShow:setTag(1)
		Type:addChild(timeShow)
		Type:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos.x,pos.y),10)))

	elseif cannontype == g_var(cmd).CannonType.Laser_Cannon then
		if self.m_Type == g_var(cmd).CannonType.Laser_Cannon  then
			if self.m_ChairID == self.m_nChairID then
				self:unAutoSchedule()
				self.m_fort:setSpriteFrame("fort_light_0.png")
				self.m_typeTime = times
			end

			return
		end

		self._dataModel:playEffect(g_var(cmd).Small_Begin)
		self.m_Type = g_var(cmd).CannonType.Laser_Cannon
		self:unAutoSchedule()
		self.m_fort:setSpriteFrame("fort_light_0.png")
		local light = cc.Sprite:createWithSpriteFrameName("light_0.png")
		light:setTag(TagEnum.Tag_Light)

		if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
			self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
		end
		light:setPosition(self.m_fort:getPositionX(),self:getPositionY())
		self:addChild(light)
		local animate = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("LightAnim"))
		local action = cc.RepeatForever:create(cc.Sequence:create(animate,animate:reverse()))
		light:runAction(action)
	
	elseif cannontype== g_var(cmd).CannonType.Bignet_Cannon then
		self.m_Type = g_var(cmd).CannonType.Bignet_Cannon
		self:removeTypeTag()
		local Type = cc.Sprite:create("game_res/im_icon_1.png")
		Type:setTag(TagEnum.Tag_Type)
		Type:setPosition(-16,40)
		self:addChild(Type)
		if self.m_pos < 3 then
			Type:setPositionY(self:getContentSize().height - 30)
		end
		self.m_typeTime = times
		self:typeTimeSchedule(1.0)

	elseif cannontype == g_var(cmd).CannonType.Normal_Cannon then
		self.m_Type = g_var(cmd).CannonType.Normal_Cannon
		local nBulletNum = math.floor(self.m_nMutipleIndex/2) + 1
		local str = string.format("gun_%d_1.png", nBulletNum)
		self.m_fort:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("btnFort_0.png"))
		self:removeTypeTag()
	end
end

function Cannon:ShowSupply( data )  -- 补给
	local pos = {}
	local box = cc.Sprite:createWithSpriteFrameName("fishDead_025_1.png")
	if self.m_pos < 3 then
		pos = cc.p(-30,20)
	else
        pos = cc.p(-40,self:getPositionY() - 30)
	end

	box:setPosition(pos.x, pos.y)
	self:addChild(box,1)
	local nSupplyType = data.nSupplyType
	local action = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("animation_fish_dead25"))
	local call = cc.CallFunc:create(function ()
        if nSupplyType ~= g_var(cmd).SupplyType.EST_NULL then
            local gold = cc.Sprite:create("game_res/im_box_gold.png")
			gold:setPosition(box:getContentSize().width/2,box:getContentSize().height/2)
			box:addChild(gold)

			local typeStr = string.format("game_res/im_supply_%d.png", nSupplyType)
			local title = cc.Sprite:create(typeStr)
			if nil ~= title  then
				title:setPosition(box:getContentSize().width/2,100)
				box:addChild(title)
			end
		end
	end)

	box:runAction(cc.Sequence:create(action,call))
	call = cc.CallFunc:create(function()
        box:removeFromParent()
	end)

	local delay = cc.DelayTime:create(4)
	box:runAction(cc.Sequence:create(delay,call))

	if nSupplyType == g_var(cmd).SupplyType.EST_Laser then
        if self.m_ChairID == self.m_nChairID then
            self:setCannonType(g_var(cmd).CannonType.Laser_Cannon, data.lSupplyCount)
			local ptPos = cc.p(0,0)
			ptPos.x = math.random(200) + 200
			ptPos.y = math.random(200) + 200
			local cmddata = CCmd_Data:create(4)
			cmddata:pushword(ptPos.x)
			cmddata:pushword(ptPos.y)
			if not self.frameEngine:sendSocketData(cmddata) then
                --self.frameEngine._callBack(-1,"发送准备激光消息失败")
			end
		end
	elseif nSupplyType == g_var(cmd).SupplyType.EST_Speed then
        self:setCannonType(g_var(cmd).CannonType.Special_Cannon, data.lSupplyCount)	 
	end
end

function Cannon:autoUpdate(dt)      -- 自己开火
    if not self.m_canShoot or self.m_Type == g_var(cmd).CannonType.Laser_Cannon  then
		return
	end

	if self._dataModel._exchangeSceneing  then 	--切换场景中不能发炮
		return false
	end

	if 0 == table.nums(self._dataModel.m_InViewTag) then 
		print("the view is not fish")
		return
	end
	self:setFishIndex(self._dataModel.m_fishIndex)

    local mutiple = self._dataModel.m_currentMutiple
    local score = self._dataModel.fish_score_[self.m_nChairID + 1] - mutiple

	if score < 0 then
        self:unAutoSchedule()
		self.m_autoShoot = false

		if nil == self._queryDialog then
            local this = self
	    	self._queryDialog = QueryDialog:create("鱼币不足,请上分", function(ok)
                this._queryDialog = nil
            end)
            :setCanTouchOutside(false)
	        :addTo(cc.Director:getInstance():getRunningScene()) 
    	end

    	if self._dataModel.m_autoShoot then
            self._dataModel.m_autoShoot = false
    	end	

    	if self._dataModel.m_autolock then
    		self._dataModel.m_autolock = false
    	end

    	return

	end
    self._dataModel.fish_score_[self.m_nChairID + 1] = self._dataModel.fish_score_[self.m_nChairID + 1] - self.m_nCurrentBulletScore
    self.parent:updateUserScore(self._dataModel.fish_score_[self.m_nChairID + 1],self.m_pos+1)	
    local fishIndex  = g_var(cmd).INT_MAX
    local bulletSpeedIndex = self._dataModel.bullet_speed_index_[self.m_nChairID + 1]

	if self.m_autoShoot  and  self._dataModel.m_autolock then
		if self._dataModel.m_fishIndex== g_var(cmd).INT_MAX then
            self:removeLockTag(self.m_nChairID)
		end

		local fish = self._dataModel.m_fishList[self.m_fishIndex]
		if fish == nil then
			self:removeLockTag(self.m_nChairID)
            return
		end
        if self._dataModel.m_fishIndex ~= g_var(cmd).INT_MAX then
            if fish.m_data then
               local fishData = fish.m_data
		       self:setLockFishLogo(self.m_nChairID,fishData.fish_kind)
            end
        end

		local pos = cc.p(fish:getPositionX(),fish:getPositionY())
		if self._dataModel.m_reversal then
            pos = cc.p(yl.WIDTH-pos.x,yl.HEIGHT-pos.y)
		end
		local angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint)
		self.m_fort:setRotation(angle)
        fishIndex = self._dataModel.m_fishIndex
	else
        fishIndex  = g_var(cmd).INT_MAX
	end

    self.m_index  = self.m_index + 1
    self:productBullet(true, fishIndex, cc.WHITE,self.m_nChairID,self.m_nCurrentBulletScore,self.m_index,self.m_nChairID,bulletSpeedIndex)
    self.parent.parent:setSecondCount(60)
	local cmddata = CCmd_Data:create(20)
   	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_USER_FIRE)
    cmddata:pushint(0)
    cmddata:pushfloat(self.m_fort:getRotation())
    cmddata:pushint(self.m_nCurrentBulletScore)
    cmddata:pushint(fishIndex)
    cmddata:pushint(self.m_index)
    
	if not self.frameEngine or not self.frameEngine:sendSocketData(cmddata) then
		print("----------发送失败----------")
	end
    
	self._dataModel.lBulletConsume = self._dataModel.lBulletConsume + mutiple
end

function Cannon:autoSchedule(dt)
	local function updateAuto(dt)
		self:autoUpdate(dt)
	end

	if nil == self.m_autoShootSchedule then
		self.m_autoShootSchedule = scheduler:scheduleScriptFunc(updateAuto, dt, false)
	end
end

function Cannon:unAutoSchedule()
	if nil ~= self.m_autoShootSchedule then
		scheduler:unscheduleScriptEntry(self.m_autoShootSchedule)
		self.m_autoShootSchedule = nil
	end
end

function Cannon:otherUpdate(dt)     -- 其他玩家开火
    if 0 == #self.m_firelist then
        self:unOtherSchedule()
		self.m_isShoot = false
		return
	end

	if 0 == table.nums(self._dataModel.m_InViewTag) then 
		print("the view is not fish")
		return
	end

	local fire = self.m_firelist[1]
	table.remove(self.m_firelist,1)
    if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
        self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

    local angle = 0

    if self._dataModel.m_reversal and fire.chair_id > 2 then
        angle = 180 + fire.angle
    elseif not self._dataModel.m_reversal and fire.chair_id < 3 then
        angle = 180 + fire.angle
    else
        angle = fire.angle
    end

    local isAndroid = false
    if self.frameEngine:getTableUserItem(self.m_nTableID, fire.chair_id) then
        isAndroid = self.frameEngine:getTableUserItem(self.m_nTableID, fire.chair_id).bIsAndroid
    end

    if isAndroid then
        if self._dataModel.m_reversal then
            if fire.chair_id  == 0 then
                angle = -math.abs(fire.angle) - 5
            end
            if fire.chair_id  == 2 then
                angle =   math.abs(fire.angle) +5
            end
            if fire.chair_id  == 3 then
                angle = 180 + math.abs(fire.angle) + 5
            end
            if fire.chair_id  == 5 then
                angle = 180 - math.abs(fire.angle) -5
            end
        else
            if fire.chair_id  == 0 then
                angle = 180 - math.abs(fire.angle) -5
            end
            if fire.chair_id  == 2 then
                angle = 180 + math.abs(fire.angle) + 5
            end
            if fire.chair_id  == 3 then
                angle = math.abs(fire.angle) + 5
            end
            if fire.chair_id  == 5 then
                angle = -math.abs(fire.angle) - 5
            end
        end
        if self._dataModel._exchangeSceneing == true then
            local fishBig =  self._dataModel:selectMaxFish();
            local fish = self._dataModel.m_fishList[fishBig]
            if fish == nil then
                return
            end
            local pos = cc.p(fish:getPositionX(),fish:getPositionY())
            if self._dataModel.m_reversal then
                pos = cc.p(yl.WIDTH-pos.x,yl.HEIGHT-pos.y)
		    end
		    angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint)
        end
    end
    
	self.m_fort:setRotation(angle)
    
    local bulletSpeedIndex = self._dataModel.bullet_speed_index_[fire.chair_id + 1]     -- 玩家的子弹速度
    if fire.chair_id == self.m_nChairID then
        --self:productBullet(true, fire.lock_fishid, cc.WHITE,fire.chair_id,fire.bullet_mulriple,fire.bullet_id,fire.android_chairid,bulletSpeed)	
    else
        if self.frameEngine:GetMeUserItem() ~= nil then
            self:productBullet(false, fire.lock_fishid, cc.WHITE,fire.chair_id,fire.bullet_mulriple,fire.bullet_id,fire.android_chairid,bulletSpeedIndex)
        end	
    end
end

function Cannon:updateScore(score)
    if self.parent ~= nil then
        self.parent:updateUserScore(score,self.m_pos+1)	
    end
end

function Cannon:showGold(score)
    self.m_pGold:showGold(score)
end


function Cannon:otherSchedule(dt)
	local function updateOther(dt)
        self:otherUpdate(dt)
	end

	if nil == self.m_otherShootSchedule then
        self.m_otherShootSchedule = scheduler:scheduleScriptFunc(updateOther, dt, false)
	end
end

function Cannon:unOtherSchedule()
	if nil ~= self.m_otherShootSchedule then
		scheduler:unscheduleScriptEntry(self.m_otherShootSchedule)
		self.m_otherShootSchedule = nil
	end
end

function Cannon:typeTimeSchedule( dt )
	local function  update( dt  )
		self:typeTimeUpdate(dt)
	end

	if nil == self.m_typeSchedule then
		self.m_typeSchedule = scheduler:scheduleScriptFunc(update, dt, false)
	end
end

function Cannon:unTypeSchedule()
	if nil ~= self.m_typeSchedule then
		self:removeChildByTag(TagEnum.Tag_Light)
		scheduler:unscheduleScriptEntry(self.m_typeSchedule)
		self.m_typeSchedule = nil
	end
end

function Cannon:removeLockTag(chairId)
    if self:getChildByTag(TagEnum.Tag_lock + chairId) then
        self:removeChildByTag(TagEnum.Tag_lock + chairId)
    end
end

function Cannon:removeTypeTag()
	self:removeChildByTag(TagEnum.Tag_Type)
end

return Cannon