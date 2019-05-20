--
-- Author: Tang
-- Date: 2016-08-09 10:26:25
-- 子弹

local Bullet = class("Bullet", 	cc.Sprite)
local module_pre = "game.yule.fishlk.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_LKGame"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()

Bullet.bulletType =
{
   Normal_Bullet = 0, --正常炮
   Bignet_Bullet = 1,--网变大
   Special_Bullet = 2--加速炮
}

local Type =  Bullet.bulletType

function Bullet:ctor(angle,chairId,mutiple,CannonType,cannon,android_chairId,bulletSpeedIndex,isSelf)
    self.android_chairId = android_chairId
    self.m_Type = Type.Normal_Bullet
    self.m_fishIndex = g_var(cmd).INT_MAX --鱼索引
    self.m_cannonPos = -1 --炮台索引	
    self.m_index     = -1 --子弹索引
    self.m_moveDir = cc.p(0,0)
    self.m_targetPoint = cc.p(0,0)
    self.m_isSelf = false
    self.m_isturn = false
    self.m_bbullet = nil
    self.m_cbullet = nil
    self.m_bRemove = false
    self.bulletNum = 0
    self.orignalAngle = 0
    self.m_cannon = cannon
    self._dataModule = self.m_cannon._dataModel
    self._gameFrame  = self.m_cannon.frameEngine
    self.initSpeed = 8000
    self.m_speed = self._dataModule.bullet_speed_[bulletSpeedIndex]
	self.m_updateTime = self._dataModule.bullet_update_[bulletSpeedIndex]-- 子弹刷新时间
	if isSelf then
		self.m_speed = self._dataModule.bullet_speed_[bulletSpeedIndex]*self._dataModule.bullet_speed_Mutiple
		self.m_updateTime = self._dataModule.bullet_update_[bulletSpeedIndex] * self._dataModule.bullet_speed_Mutiple
	end
    self.m_nMultiple = mutiple
    self.gameConfig_min_bullet_multiple = self.m_cannon.parent.parent.min_bullet_multiple 
    self:initWithAngle(angle, chairId, score, CannonType)
    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    if self.m_pUserItem ~= nil then
        self.m_nTableID  = self.m_pUserItem.wTableID
        self.m_nChairID  = self.m_pUserItem.wChairID 
    else
        self.m_nChairID  = 0 
    end
    self.bundleChairId = chairId
    
    ExternalFun.registerTouchEvent(self,false)      -- 注册事件
end

function Bullet:initWithAngle(angle,chairId,score,CannonType)
	self:setRotation(angle)
	self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
end

function Bullet:setBbullet( bBullet )
	self.m_bbullet = bBullet        -- 子弹索引
end

function Bullet:getBbullet()
	return self.m_bbullet           -- 子弹索引
end

function Bullet:setCbullet( cBullet )
	self.m_cbullet = cBullet        -- 子弹索引
end

function Bullet:getCbullet()
	return self.m_cbullet           -- 子弹索引
end

function Bullet:setIndex( index )
	self.m_index = index            -- 子弹索引
end

function Bullet:clearMbullet()
	self.m_bbullet = nil
    self.m_cbullet = nil
end

function Bullet:setIsSelf( isself )
	self.m_isSelf = isself
end

function Bullet:setNetColor( color )
	self.m_netColor = color
end

function Bullet:setFishIndex( index )
	self.m_fishIndex = index
end

function Bullet:onEnter( )
	self:schedulerUpdate()
end

function Bullet:onExit( )
    if self:getPhysicsBody() then
        self:getPhysicsBody():onRemove()
    end
    self.m_bRemove = true
	self:removeAllComponents()
	self:unSchedule()
end

function Bullet:schedulerUpdate() 
    local function updateBullet( dt )
        self:update(dt)
	end
	
	if nil == self.m_schedule then  -- 定时器
		self.m_schedule = scheduler:scheduleScriptFunc(updateBullet, 0, false)
	end
end

function Bullet:unSchedule()
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
	    self.m_schedule = nil
	end
end

function Bullet:setBulletNum(bulletNum)
	self.bulletNum = bulletNum
end

function Bullet:getBulletNum()
    local mutipleNum = 1
    if self.m_nMultiple >= 100 and self.m_nMultiple < 1000 then
        mutipleNum = 2
    elseif self.m_nMultiple >= 1000 and self.m_nMultiple < 5000 then
        mutipleNum = 3
    elseif self.m_nMultiple >= 5000 then
        mutipleNum = 4
    end

	return mutipleNum
end

function Bullet:setType(wChairID, type)
    self.m_Type = type
    local nBulletNum = self:getBulletNum()
    local sBulletName = string.format("#lkpy_bullet%d_norm%d.png", nBulletNum, wChairID + 1)
    if self.m_Type == g_var(cmd).CannonType.Bullet_Special_Cannon then
        if wChairID + 1 <=3 then
            sBulletName = string.format("#lkpy_bullet%d_ion%d.png", nBulletNum, 1)
        else
            sBulletName = string.format("#lkpy_bullet%d_ion%d.png", nBulletNum, 2)
        end
    end
    local pwarhead = display.newSprite(sBulletName)
    pwarhead:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2+50))
    self:addChild(pwarhead)
	
    local movedis = 100
	local movedir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis)  
	local pos = cc.p(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)
	self:setPosition(pos.x,pos.y)
end

function Bullet:initPhysicsBody()
	if self.m_fishIndex  ~= g_var(cmd).INT_MAX then
		return	
	end

	self:setPhysicsBody(cc.PhysicsBody:createBox(cc.size(self:getContentSize().width,self:getContentSize().height/2)))
    self:getPhysicsBody():setCategoryBitmask(2)
    self:getPhysicsBody():setCollisionBitmask(0)
    self:getPhysicsBody():setContactTestBitmask(1)
    self:getPhysicsBody():setGravityEnable(false)
end

function Bullet:changeDisplayFrame( chairId , score)
	local nBulletNum = self:getBulletNum()
	local frame = string.format("lkpy_bullet%d_norm%d.png", nBulletNum,chairId + 1)
	self:setSpriteFrame(frame)
end

function Bullet:update( dt )
	if self.m_fishIndex == g_var(cmd).INT_MAX then
        self:normalUpdate(dt) --正常发射
	else
		self:followFish(dt) --锁定鱼
	end
end

function Bullet:normalUpdate( dt )  -- 正常发射
	local movedis =  self.m_speed 
    self.initSpeed = self.m_speed
	local movedir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis)  
	local pos = cc.p(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)
	self:setPosition(pos.x,pos.y)
	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	pos = cc.p(self:getPositionX(),self:getPositionY())

	if not cc.rectContainsPoint(rect,pos) then
        if pos.x<0 or pos.x>yl.WIDTH then
            local angle = self:getRotation()
            self:setRotation(-angle)
            if pos.x<0 then
                pos.x = 0
            else
                pos.x = yl.WIDTH
            end
        else
            local angle = self:getRotation()
            self:setRotation(-angle + 180)
            if pos.y < 0 then
                pos.y = 0
            else
                pos.y = yl.HEIGHT
            end
        end

        self.m_moveDir = cc.pForAngle(math.rad(90-self:getRotation()))
        local movedis =  self.m_speed
        local moveDir = cc.p(self.m_moveDir.x*movedis,self.m_moveDir.y*movedis) 
        pos = cc.p(self:getPositionX()+moveDir.x,self:getPositionY()+moveDir.y)
        self:setPosition(pos.x,pos.y)
    end
end

function Bullet:followFish(dt)      -- 锁定鱼
    local fish = self._dataModule.m_fishList[self.m_fishIndex]

	if nil == fish then
        self.m_fishIndex = g_var(cmd).INT_MAX
        self:initPhysicsBody()
		return
	end

	if fish.isActive == false then
        self.m_fishIndex = g_var(cmd).INT_MAX
        self:initPhysicsBody()
        return 
    end

	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	if not cc.rectContainsPoint(rect, cc.p(fish:getPositionX(), fish:getPositionY())) then
        self.m_fishIndex = g_var(cmd).INT_MAX
		self:initPhysicsBody()
		return
	end

	local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
	if self._dataModule.m_reversal then
		fishPos = cc.p(yl.WIDTH - fishPos.x , yl.HEIGHT - fishPos.y)
	end

	local angle = self._dataModule:getAngleByTwoPoint(fishPos, cc.p(self:getPositionX(),self:getPositionY()))
	self:setRotation(angle)
	self.m_moveDir = cc.pForAngle(math.rad(90-angle))
	local movedis =  self.m_speed
	local movedir = cc.pMul(self.m_moveDir,movedis)
	self:setPosition(self:getPositionX()+movedir.x,self:getPositionY()+movedir.y)
	if cc.pGetDistance(fishPos,cc.p(self:getPositionX(),self:getPositionY())) <= movedis then
        self:setPosition(fishPos)
--        fish:slowDown()
		self:fallingNet(self.m_fishIndex)
        fish:ForHit()
		self:removeFromParent()
	end
end

function Bullet:fallingNet(fishId)      -- 撒网
    local points0 = {cc.p(0,0)}         -- 两个网
	local points1 = {cc.p(-50,0),cc.p(50,0)} -- 两个网
	local points2 = {cc.p(0,40),cc.p(-math.cos(3.14/6)*40,-math.sin(3.14/6)*40),cc.p(math.cos(3.14/6)*40,-math.sin(3.14/6)*40)} -- 三个网
	local points3 = {cc.p(-40,40),cc.p(40,40),cc.p(40,-40),cc.p(-40,-40)} -- 四个网

	self:unSchedule()

	local parent = self:getParent()
	if parent == nil then
        return
	end
    
	local bulletNum = 1
	local tmp = {}
	bulletNum = self:getBulletNum()
	if bulletNum == 1 then
        tmp = points0
	elseif bulletNum == 2 then
		tmp = points1
	elseif bulletNum == 3 then
		tmp = points2
    else
        tmp = points3
	end

	local offset =  cc.pMul(self.m_moveDir,20)
	local rect = nil

	for i=1,bulletNum do
--        local net = cc.Sprite:create("game_res/im_net.png") 
        local net = display.newSprite("#lkpy_icon_net1.png")
        if self.m_Type == Type.Normal_Bullet or self.m_Type == Type.Special_Bullet  then
			net = display.newSprite("#lkpy_icon_net1.png")
		elseif self.m_Type == g_var(cmd).CannonType.Bullet_Special_Cannon  then
			net = display.newSprite("#lkpy_icon_net2.png")
		end
        

		net:setScale(205/net:getContentSize().width)

		if self.m_Type == Type.Bignet_Bullet then
			net:setScale(net:getScale()*1.5)
		end

		local pos = cc.p(self:getPositionX(),self:getPositionY())
		pos = cc.pAdd(pos,offset)
		net:setPosition(pos.x,pos.y)

		rect = net:getBoundingBox()
	    pos = cc.pAdd(pos,offset)
		net:setPosition( cc.pAdd(pos,tmp[i]))

		local scalTo = cc.ScaleTo:create(0.08,net:getScale()*1.16)
		local scalTo1 = cc.ScaleTo:create(0.08,net:getScale())
  
		local seq = cc.Sequence:create(scalTo,scalTo1,scalTo,cc.RemoveSelf:create())
		net:runAction(seq)
		net:runAction(cc.Sequence:create(cc.DelayTime:create(0.16),cc.FadeTo:create(0.05,0)))
		parent:addChild(net,20)
        if i == 1 then
            if parent:getChildByTag(100000 + self.bundleChairId) then
                parent:getChildByTag(100000 + self.bundleChairId):removeFromParent()
            end

            if parent:getChildByTag(100001 + self.bundleChairId) then
                parent:getChildByTag(100001 + self.bundleChairId):removeFromParent()
            end

--            local praticle3 = cc.ParticleSystemQuad:create("particle/harpoon_explode1.plist")
--            praticle3:setPosition(pos)
--            praticle3:setPositionType(cc.POSITION_TYPE_GROUPED)
--            praticle3:setTag(100000 + self.bundleChairId)
--            parent:addChild(praticle3,3)

--            local praticle = cc.ParticleSystemQuad:create("particle/mission_complete.plist")
--            praticle:setPosition(pos)
--            praticle:setTotalParticles(30)
--            praticle:setTag(100001 + self.bundleChairId)
--            praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
--            parent:addChild(praticle,3)
        end
    end
	if self.m_isSelf then
        local net = display.newSprite("#lkpy_icon_net1.png")
		if self.m_Type == Type.Normal_Bullet or self.m_Type == Type.Special_Bullet  then
			net = display.newSprite("#lkpy_icon_net1.png")
		elseif self.m_Type == g_var(cmd).CannonType.Bullet_Special_Cannon  then
			net = display.newSprite("#lkpy_icon_net2.png")
		end

		local pos = cc.p(self:getPositionX(),self:getPositionY())
		pos = cc.pAdd(pos,offset)
		local catchPos = self._dataModule:convertCoordinateSystem(pos, 2, self._dataModule.m_reversal)
		net:setPosition(catchPos)
		rect = net:getBoundingBox()
		rect.width = rect.width - 20 + bulletNum*10
		rect.height = rect.height - 20 + bulletNum*10
        ExternalFun.playSoundEffect(g_var(cmd).FallNetSound)
	end
    if self.m_nChairID ~= self.bundleChairId  and self.android_chairId ~= self.m_nChairID then
        return
    end

    self:sendCathcFish(rect,fishId)
end

function Bullet:sendCathcFish( rect,fishId )        -- 发送捕获消息
    local tmp = {}

	for k,v in pairs(self._dataModule.m_fishList) do
        local fish = v
		local pos = fish:getPosition()
		local _rect = fish:getBoundingBox()
		local bIntersect = cc.rectIntersectsRect(rect,_rect)
		if bIntersect then
            table.insert(tmp, fish)
		end
	end

	local count = 0     -- 网中符合条件的鱼的个数
	local catchList = {}
	local isBigFish = true
	local bigFishList = {}
    local bigIndex = {}
	
	for i = 1, #tmp do     -- 筛选大鱼
		local fish = tmp[i]
		if fish.m_data.fish_kind >= g_var(cmd).FishKind.FISH_KIND_16 then
			table.insert(bigFishList,fish)
            table.insert(bigIndex,i)
		end
	end

    for i = 1, #bigIndex do
		table.remove(tmp,bigIndex[i])
	end

	bigIndex = {}
	
	if 0 ~= #bigFishList then   -- 把大鱼插入队列的前端
		for i=1,#bigFishList do
			local fish = bigFishList[i]
			table.insert(tmp, 1,fish)
		end
	end
	
	bigFishList = nil

	if #tmp > 2 then        -- 取出前5条鱼
		count = 2
	else
		count = #tmp
	end

	for i=1,count do
		local fish = tmp[i]
		table.insert(catchList,fish)
	end

	local request = {0,0,0,0,0}     -- 发送消息包

	for i=1,#catchList do
		local fish = catchList[i]
		request[i] = fish.nFishKey
	end

    local mutiple = self.m_nMultiple
    --计算子弹打类型 bulletKind
    local current_bullet_kind = 0
    if mutiple < 100 then
        current_bullet_kind = 0
    elseif mutiple >= 100 and mutiple < 1000  then
        current_bullet_kind = 1
    elseif mutiple >= 1000 and mutiple < 5000 then
        current_bullet_kind = 2
    elseif mutiple >= 5000 then 
        current_bullet_kind = 3
    end
    
     if self.m_Type == g_var(cmd).CannonType.Bullet_Special_Cannon then 
        current_bullet_kind = current_bullet_kind + 4
    end


	local cmddata = CCmd_Data:create(18)
   	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_CATCH_FISH);
    cmddata:pushword(self.bundleChairId)
    cmddata:pushint(fishId)
    cmddata:pushint(current_bullet_kind)
    cmddata:pushint(self.m_index)
    cmddata:pushint(self.m_nMultiple)
    if not  self._gameFrame then
        return
    end
    
	if not self._gameFrame:sendSocketData(cmddata) then     -- 发送失败
		--self._gameFrame._callBack(-1,"发送捕鱼信息失败")
	end
end

return Bullet