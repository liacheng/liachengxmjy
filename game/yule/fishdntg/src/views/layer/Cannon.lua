--
-- Author: Tang
-- Date: 2016-08-09 10:27:07
--炮
local Cannon = class("Cannon", cc.Sprite)
local module_pre = "game.yule.fishdntg.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_DNTGGame"
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
    Tag_switch_fish = 3100,
    Tag_btn_switch = 3200,
    Tag_btn_switch1 = 3300,
    Tag_lockLine = 4000
}

local TagEnum = Cannon.Tag

function Cannon:ctor(viewParent)
	self.m_pos = 0    --炮台位置
	self.m_fort = nil
    self.m_gunPlatformButtom = nil --炮台底座
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
    self.m_updateLockLine = nil 
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
    self.m_pGold:setAnchorPoint(0.5,0)
    self:addChild(self.m_pGold)
    self.m_SpecialCannon = false
    self.m_LockFishid = nil                               -- 其他人锁鱼记录
    self.m_nCurrentBulletScore = self.parent.parent.min_bullet_multiple  -- 初始化当前炮数
    self.AndroidLockFishId = {0,0,0,0}                    --机器人锁鱼ID记录
    ExternalFun.registerTouchEvent(self,false)          -- 注册事件
end


function Cannon:SpecialCannon(isSpecialCannon)
    if self.m_SpecialCannon == false then
        self.m_SpecialCannon = isSpecialCannon
        if isSpecialCannon == true then
            self.m_Type = g_var(cmd).CannonType.Bullet_Special_Cannon
        end
    end
end

function Cannon:SpecialCannon_Timeout(isSpecialCannon)
    if self.m_SpecialCannon == true then
     self.m_SpecialCannon = isSpecialCannon
	 self.m_Type = g_var(cmd).CannonType.Normal_Cannon
    end
end

function Cannon:ShowCannon(isSpecialCannon)
    self.m_SpecialCannon = isSpecialCannon

    self.m_Type = g_var(cmd).CannonType.Normal_Cannon
    if isSpecialCannon == true then
        self.m_Type = g_var(cmd).CannonType.Bullet_Special_Cannon
    end

end

function Cannon:onExit( )
	self:unAutoSchedule()
	self:unTypeSchedule()
	self:unOtherSchedule()
    self:unscheduleUpdateLockLine()
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
	self:removeChildByTag(998)
	self:removeChildByTag(999)
	self:removeChildByTag(1000)

	self.m_fort = display.newSprite("#dntg_gun_1_1.png")
	self.m_fort:setTag(998)
	self.m_fort:setPosition(50,3)
	self:addChild(self.m_fort,1)
	self.m_pos = userItem.wChairID
    self.m_fort:setAnchorPoint(0.5,0)

    --底座
	self.m_gunPlatformButtom = display.newSprite("#dntg_gunPlatformButtom1_1.png")
	self.m_gunPlatformButtom:setTag(999)
	self.m_gunPlatformButtom:setPosition(50,3)
	self:addChild(self.m_gunPlatformButtom,1)
    self.m_gunPlatformButtom:setAnchorPoint(0.5,0.5)

    self.m_labelMutiple = cc.LabelAtlas:create("1","game_res/dntg_num_small.png",18,25,string.byte("*")) --倍数
	self.m_labelMutiple:setTag(1000)
	self.m_labelMutiple:setAnchorPoint(0.5,0.5)
	self.m_labelMutiple:setPosition(50,-48)
    local num = string.format("%d",self.parent.parent.min_bullet_multiple)
    self.m_labelMutiple:setString(num)
	self:addChild(self.m_labelMutiple,1)
    
    self.m_pGold:setPosition(50, 0)
	if self._dataModel.m_reversal then 
        self.m_pos = 3 - self.m_pos
	end

    if self.m_ChairID == self.m_nChairID then
        --加减炮按钮 
        self.btnAdd = ccui.Button:create("dntg_btn_addgun.png","dntg_btn_addgun.png","dntg_btn_addgun.png",UI_TEX_TYPE_PLIST)
        self.btnAdd:setPressedActionEnabled(true)
        self.btnAdd:setAnchorPoint(0.5,0.5)
        self.btnAdd:setPosition(135,-40)
        self:addChild(self.btnAdd,1)

        self.btnMinus = ccui.Button:create("dntg_btn_deletegun.png","dntg_btn_deletegun.png","dntg_btn_deletegun.png",UI_TEX_TYPE_PLIST)
        self.btnMinus:setPressedActionEnabled(true)
        self.btnMinus:setAnchorPoint(0.5,0.5)
        self.btnMinus:setPosition(-35,-40)
        self:addChild(self.btnMinus,1)


        self.btnAdd:addTouchEventListener(function( sender , eventType )      
            if self.m_SpecialCannon then
                return
            end
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                local gameMinMutiple = self.parent.parent.min_bullet_multiple
                local gameMaxMutiple = self.parent.parent.max_bullet_multiple

                if self._dataModel.m_currentMutiple == gameMaxMutiple then
                    self._dataModel.m_currentMutiple = gameMinMutiple
                elseif self._dataModel.m_currentMutiple < 10 then
                    self._dataModel.m_currentMutiple = self._dataModel.m_currentMutiple + 1 
                    if self._dataModel.m_currentMutiple > gameMaxMutiple then
                        self._dataModel.m_currentMutiple = gameMaxMutiple
                    end
                elseif self._dataModel.m_currentMutiple >= 10 and self._dataModel.m_currentMutiple < 100 then
                    self._dataModel.m_currentMutiple = self._dataModel.m_currentMutiple + 10 
                    if self._dataModel.m_currentMutiple > gameMaxMutiple then
                        self._dataModel.m_currentMutiple = gameMaxMutiple
                    end  
                elseif self._dataModel.m_currentMutiple >= 100 and self._dataModel.m_currentMutiple < 1000 then
                    self._dataModel.m_currentMutiple = self._dataModel.m_currentMutiple + 100 
                    if self._dataModel.m_currentMutiple > gameMaxMutiple then
                        self._dataModel.m_currentMutiple = gameMaxMutiple
                    end       
                elseif self._dataModel.m_currentMutiple >= 1000 and self._dataModel.m_currentMutiple < 10000 then
                    self._dataModel.m_currentMutiple = self._dataModel.m_currentMutiple + 1000 
                    if self._dataModel.m_currentMutiple > gameMaxMutiple then
                        self._dataModel.m_currentMutiple = gameMaxMutiple
                    end
                else
                    self._dataModel.m_currentMutiple = self._dataModel.m_currentMutiple + 10000
                    if self._dataModel.m_currentMutiple > gameMaxMutiple then
                        self._dataModel.m_currentMutiple = gameMaxMutiple
                    end
                end

                local cannonPos = self.m_ChairID      
                if self._dataModel.m_reversal then 
                    cannonPos = 3 - cannonPos
                end
             
                self.parent:updateMultiple(self._dataModel.m_currentMutiple,cannonPos + 1)
                self._dataModel.m_userCurrentMutiple[self.m_ChairID + 1] = self._dataModel.m_currentMutiple
                self:setMyMultiple(self._dataModel.m_currentMutiple)
            end
        end)


        self.btnMinus:addTouchEventListener(function( sender , eventType )   
            if self.m_SpecialCannon then
                return
            end
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                local gameMinMutiple = self.parent.parent.min_bullet_multiple
                local gameMaxMutiple = self.parent.parent.max_bullet_multiple
                if self._dataModel.m_currentMutiple == gameMinMutiple then
                    self._dataModel.m_currentMutiple = gameMaxMutiple
                elseif self._dataModel.m_currentMutiple <= 10 then
                    self._dataModel.m_currentMutiple  = self._dataModel.m_currentMutiple - 1
                    if  self._dataModel.m_currentMutiple < gameMinMutiple then
                        self._dataModel.m_currentMutiple = gameMinMutiple
                    end
                elseif self._dataModel.m_currentMutiple > 10 and self._dataModel.m_currentMutiple <= 100 then
                    self._dataModel.m_currentMutiple  = self._dataModel.m_currentMutiple - 10
                    if  self._dataModel.m_currentMutiple < gameMinMutiple then
                        self._dataModel.m_currentMutiple = gameMinMutiple
                    end
                elseif self._dataModel.m_currentMutiple > 100 and self._dataModel.m_currentMutiple <= 1000 then
                    self._dataModel.m_currentMutiple  = self._dataModel.m_currentMutiple - 100
                    if  self._dataModel.m_currentMutiple < gameMinMutiple then
                        self._dataModel.m_currentMutiple = gameMinMutiple
                    end
                elseif self._dataModel.m_currentMutiple > 1000 and self._dataModel.m_currentMutiple <= 10000 then
                    self._dataModel.m_currentMutiple  = self._dataModel.m_currentMutiple - 1000
                    if  self._dataModel.m_currentMutiple < gameMinMutiple then
                        self._dataModel.m_currentMutiple = gameMinMutiple
                    end
                else
                    self._dataModel.m_currentMutiple = self._dataModel.m_currentMutiple - 10000
                    if  self._dataModel.m_currentMutiple < gameMinMutiple then
                        self._dataModel.m_currentMutiple = gameMinMutiple
                    end
                end
                   
                local cannonPos = self.m_ChairID      
                if self._dataModel.m_reversal then 
                    cannonPos = 3 - cannonPos
                end
                self.parent:updateMultiple(self._dataModel.m_currentMutiple,cannonPos + 1)
                self._dataModel.m_userCurrentMutiple[self.m_ChairID + 1] = self._dataModel.m_currentMutiple
                self:setMyMultiple(self._dataModel.m_currentMutiple)
            end
        end)
    end

	if self.m_pos < 2 then
        self.m_pGold:setPosition(45, 4)
        self.m_labelMutiple:setPosition(50,53)
		self.m_fort:setRotation(180)
        --self.m_labelMutiple:setRotation(180)
        self.m_gunPlatformButtom:setRotation(180)
        self.m_pGold:setRotation(180)
	end
end

function Cannon:setFishIndex(index)
	self.m_fishIndex = index
end


function Cannon:setMultiple(multiple,chairId)
    self.m_bulletMutiple = multiple
    local mutipleStr = string.format("%d", multiple)
    self.m_labelMutiple:setString(mutipleStr)
    local frame = nil
    local gunPlatform = nil
    if self.m_SpecialCannon == true then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_2_2.png")
        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_2.png")
        if multiple >= 10000 then
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_4_2.png")
            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_4.png")
        elseif multiple >= 1000 then 
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_3_2.png")
            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_3.png")
        end

--        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_1_2.png")
--        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_1.png")
--        if multiple >= 100 and multiple < 1000 then
--            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_2_2.png")
--            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_2.png")
--        elseif multiple >= 1000 and multiple < 5000 then
--            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_3_2.png")
--            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_3.png")
--        elseif multiple >= 5000 then
--            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_4_2.png")
--            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom2_4.png")
--        end
    elseif self.m_SpecialCannon == false then 
--        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_1_1.png")
--        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_1.png")
--        if multiple >= 100 and multiple < 1000 then
--            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_2_1.png")
--            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_2.png")
--        elseif multiple >= 1000 and multiple < 5000 then
--            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_3_1.png")
--            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_3.png")
--        elseif multiple >= 5000 then
--            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_4_1.png")
--            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_4.png")
--        end

        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_2_1.png")
        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_2.png")
        if multiple >= 10000 then
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_4_1.png")
            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_4.png")
        elseif multiple >= 1000 then 
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_3_1.png")
            gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_3.png")
        end

    end
    
	self.m_fort:setSpriteFrame(frame)
    self.m_gunPlatformButtom:setSpriteFrame(gunPlatform)
	self.parent:updateMultiple(multiple,chairId+1)
end

function Cannon:setMyMultiple(multiple)
    
    self.m_nCurrentBulletScore = multiple
    local mutipleStr = string.format("%d", multiple)
    self.m_labelMutiple:setString(mutipleStr)
--    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_1_1.png")
--    local gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_1.png")
--    if multiple >= 100 and multiple < 1000 then
--        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_2_1.png")
--        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_2.png")
--    elseif multiple >= 1000 and multiple < 5000 then
--        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_3_1.png")
--        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_3.png")
--    elseif multiple >= 5000 then
--        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_4_1.png")
--        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_4.png")
--    end

    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_2_1.png")
    local gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_2.png")
    if multiple >= 10000  then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_4_1.png")
        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_4.png")
    elseif multiple >= 1000  then
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_3_1.png")
        gunPlatform = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_3.png")
    end


	self.m_fort:setSpriteFrame(frame)
    self.m_gunPlatformButtom:setSpriteFrame(gunPlatform)
end

function Cannon:setAutoShoot( b )       -- 自动射击
	self.m_autoShoot = b
	if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
        self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

--	if self.m_Type >= g_var(cmd).CannonType.Laser_Cannon then
--		return
--	end

	if self.m_autoShoot or self._dataModel.m_autolock then
        local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]] / self._dataModel.bullet_speed_Mutiple
		self:autoSchedule(dt)
	else
		self:unAutoSchedule()	
	end
end

function Cannon:setSpeedUP()
    if self.m_autoShootSchedule then
        self:unAutoSchedule()
        local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]] / self._dataModel.bullet_speed_Mutiple
		self:autoSchedule(dt)
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
            self.m_gunPlatformButtom:setRotation(angle)
		end
	end

	if self.m_Type == g_var(cmd).CannonType.Laser_Shooting then
        return
	end

	if self.m_Type == g_var(cmd).CannonType.Laser_Cannon  then
		self:shootLaser()
		return
	end

	if self.m_autoShoot then
		return
	end

	if not self.m_isShoot and isbegin then
		self.m_isShoot = true
        self:autoUpdate(0)
        local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]] / self._dataModel.bullet_speed_Mutiple
		self:autoSchedule(dt)
	end

	if not isbegin then
		self.m_isShoot = false
		self:unAutoSchedule()
	end
end

function Cannon:otherlockfish(lockfish) -- 锁鱼计算
    local fish = nil

    if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
        self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

    if lockfish.lock_fishid == -2 or lockfish.lock_fishid == g_var(cmd).INT_MAX then
        self:removeLockTag(lockfish.chair_id)
    end

    local angle = 0
    fish = self._dataModel.m_fishList[lockfish.lock_fishid]
    if fish ~= nil then
        local pos = cc.p(fish:getPositionX(),fish:getPositionY())
        if self._dataModel.m_reversal then
            pos = cc.p(yl.WIDTH-pos.x,yl.HEIGHT-pos.y)
		end
		angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint)
    end

    if angle == 0 or angle == nil then
        return 
    end


    if self.m_LockFishid ~= lockfish.lock_fishid then
        self:removeLockTag(lockfish.chair_id)
        self.m_LockFishid = lockfish.lock_fishid
    end
    

    if fish ~= nil and lockfish.lock_fishid ~= g_var(cmd).INT_MAX then
        if self._dataModel._exchangeSceneing == true then
            return 
        end
        local fishData = fish.m_data
        self:setLockFishLogo(lockfish.chair_id,fishData.fish_kind)
        self:setLockFishLine(lockfish.chair_id,lockfish.lock_fishid)
    end

    
	self.m_fort:setRotation(angle)
    self.m_gunPlatformButtom:setRotation(angle)

end

function Cannon:othershoot(firedata)  -- 其他玩家开火
    local chairId = firedata.chair_id

    if self._dataModel.m_reversal then 
		chairId = 3 - chairId
	end


    self._dataModel.m_userCurrentMutiple[firedata.chair_id + 1] = firedata.bullet_mulriple
	self:setMultiple(firedata.bullet_mulriple,chairId)
    self._dataModel.fish_score_[firedata.chair_id + 1] = self._dataModel.fish_score_[firedata.chair_id + 1] + firedata.fish_score
    self.parent:updateUserScore(self._dataModel.fish_score_[firedata.chair_id + 1],self.m_pos+1)	

    local fish = nil
    if  firedata.lock_fish_id > 0 then
        fish = self._dataModel.m_fishList[firedata.lock_fish_id]
    end

    if fish ~= nil and firedata.lock_fish_id ~= g_var(cmd).INT_MAX then
        if self._dataModel._exchangeSceneing == true then
            return 
        end
        local fishData = fish.m_data
        local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
        if  not cc.rectContainsPoint(rect, cc.p(fish:getPositionX(), fish:getPositionY())) then
            firedata.lock_fish_id = 0;
        else
            self:setLockFishLogo(firedata.chair_id,fishData.fish_kind)
        end
        
    end
    
    if firedata.lock_fish_id == g_var(cmd).INT_MAX or firedata.lock_fish_id == 0 or fish == nil then
		self:removeLockTag(firedata.chair_id)
	end
    
	if  firedata.is_android_scene == true then
        self:otherSchedule(0.2)
    else
        table.insert(self.m_firelist,firedata)
        self:otherSchedule(0.2)
    end

end

function Cannon:setLockFishLogo(chairId,fishKind)
    local frameName = string.format("dntg_lock_flag_%d.png", fishKind+1)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)

    local switchfish = cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_switch_fish.png")
    local _chairId = chairId
    if self._dataModel.m_reversal then 
        _chairId = 3 - _chairId
    end

    local function callBack( sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
            self:ButtonEvent(sender,eventType)
        end
    end

    if nil ~= frame then
        local sp = self:getChildByTag(TagEnum.Tag_lock)
        local sp1 = self:getChildByTag(TagEnum.Tag_switch_fish)
        if nil == sp then
            local pos = cc.p(-40,145)
            local pos1 = cc.p(60,145)
            if _chairId < 2 then
                pos = cc.p(-40,-60)
                pos1 = cc.p(60,-60)
            end
            sp = cc.Sprite:createWithSpriteFrame(frame)
            sp:setTag(TagEnum.Tag_lock)
            sp:setName(frameName)
            sp:setPosition(pos.x,pos.y)
            self:addChild(sp)
            sp:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos.x,pos.y),10)))

            local btnswitchfish = ccui.Button:create(frameName,frameName,frameName,UI_TEX_TYPE_PLIST)
            btnswitchfish:setPosition(pos.x,pos.y)
            btnswitchfish:setAnchorPoint(0.5,0.5)
            btnswitchfish:setTag(TagEnum.Tag_btn_switch)
            btnswitchfish:addTouchEventListener(callBack)
            self:addChild(btnswitchfish)
            btnswitchfish:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos.x,pos.y),10)))

            sp1 = cc.Sprite:createWithSpriteFrame(switchfish)
            sp1:setTag(TagEnum.Tag_switch_fish)
            sp1:setName("dntg_switch_fish.png")
            sp1:setPosition(pos1.x,pos1.y)
            self:addChild(sp1)
            sp1:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos1.x,pos1.y),10)))

            local btnswitchfish1 = ccui.Button:create("dntg_switch_fish.png","dntg_switch_fish.png","dntg_switch_fish.png",UI_TEX_TYPE_PLIST)
            btnswitchfish1:setPosition(pos1.x,pos1.y)
            btnswitchfish1:setAnchorPoint(0.5,0.5)
            btnswitchfish1:setTag(TagEnum.Tag_btn_switch1)
            btnswitchfish1:addTouchEventListener(callBack)
            self:addChild(btnswitchfish1)
            btnswitchfish1:runAction(cc.RepeatForever:create(CirCleBy:create(1.0,cc.p(pos1.x,pos1.y),10)))

        else
            if sp:getName() ~=  frameName then
                sp:setSpriteFrame(frame)
                sp1:setSpriteFrame(switchfish)
            end 
        end
    else
        self:removeLockTag(chairId)					
    end
end

function Cannon:ButtonEvent( sender , eventType)
    local tag = sender:getTag()
    if tag == TagEnum.Tag_btn_switch or tag == TagEnum.Tag_btn_switch1 then 
        self._dataModel.m_fishIndex = self._dataModel:selectMaxFish(self._dataModel.m_fishIndex)

        local fish = self._dataModel.m_fishList[self._dataModel.m_fishIndex]
        if fish.m_data then
            local fishData = fish.m_data
            self:removeLockTag(self.m_nChairID)
--            self:setLockFishLogo(self.m_nChairID,fishData.fish_kind)
        end
    end  
end

function Cannon:setLockFishLine(chairId,fishId)

    -- 锁鱼线节点

    local cannonPos = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
    local fishPos = cc.p(0,0)

    --获取鱼坐标
    local fish = self._dataModel.m_fishList[fishId]
    if fish ~= nil then
        fishPos = fish:getParent():convertToWorldSpace(cc.p(fish:getPositionX(),fish:getPositionY()))
    else
        return 
    end

    if self._dataModel._exchangeSceneing == true then
        return 
    end

    
    local sp = nil -- 锁鱼线资源

    local width = (fishPos.x-cannonPos.x) 
    local height =  (fishPos.y-cannonPos.y)
    local distanceScreen = math.sqrt(width * width  + height * height)
    local num = math.ceil(distanceScreen / 50)  -- 气泡个数
    num = num - 1
    local xExcursion = 	width / num
    local yExcursion = 	height / num
    self.chairId1 = chairId
    self.fishId1 = fishId
    local node = self:getChildByTag(TagEnum.Tag_lockLine)
    if  node == nil then
        node = cc.Node:create()
        node:setTag(TagEnum.Tag_lockLine)
        node:setRotation(self:getRotation()*-1)
        self:addChild(node)
        for i = 1,num+1 do
            sp = cc.Sprite:create("game_res/lock_line.png")
            sp:setPosition(cc.p(xExcursion*(i-1)+50,yExcursion*(i-1)-5))
            node:addChild(sp)
        end
        self:scheduleUpdateLockLine()
    end
end

        
function Cannon:scheduleUpdateLockLine() 
    local function tempUpdateLockLine( dt )
        self:updateLockLine(dt)
	end
	
	if nil == self.m_updateLockLine then  -- 定时器
		self.m_updateLockLine = scheduler:scheduleScriptFunc(tempUpdateLockLine, 0, false)
	end
end

function Cannon:unscheduleUpdateLockLine()
    if nil ~= self.m_updateLockLine then
        scheduler:unscheduleScriptEntry(self.m_updateLockLine)
	    self.m_updateLockLine = nil
	end
end

function Cannon:updateLockLine(dt)
    -- 锁鱼线节点

    local cannonPos = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
    local fishPos = cc.p(0,0)

    --获取鱼坐标
    local fish = self._dataModel.m_fishList[self.fishId1]
    
    local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
    if fish == nil or not cc.rectContainsPoint(rect, cc.p(fish:getPositionX(), fish:getPositionY())) then
        self:removeLockTag(1)
        local cmddata = CCmd_Data:create(6)     
        cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_USER_LOCKFISH)
        cmddata:pushint(-2)
        cmddata:pushword(self.m_pos)
        if not self.frameEngine:sendSocketData(cmddata) then
            print("----------发送失败----------")
        end
    else
        fishPos = fish:getParent():convertToWorldSpace(cc.p(fish:getPositionX(),fish:getPositionY()))
    end

    
    local sp = nil -- 锁鱼线资源

    local width = (fishPos.x-cannonPos.x) 
    local height =  (fishPos.y-cannonPos.y)
    local distanceScreen = math.sqrt(width * width  + height * height)
    local num = math.ceil(distanceScreen / 50)  -- 气泡个数
    num = num - 1
    local xExcursion = 	width / num
    local yExcursion = 	height / num
    
    local node = self:getChildByTag(TagEnum.Tag_lockLine)

    if  node ~= nil then
        node:removeAllChildren()
        for i = 1,num+1 do
            sp = cc.Sprite:create("game_res/lock_line.png")
            sp:setPosition(cc.p(xExcursion*(i-1)+50,yExcursion*(i-1)-5))
            node:addChild(sp)
        end
    end
end


function Cannon:productBullet( isSelf,fishIndex, netColor,bundleChairId,bullet_mulriple,bulletId,android_chairid,bulletSpeedIndex)  -- 制造子弹
    local angleFort = self.m_fort:getRotation()
	self:setFishIndex(self._dataModel.m_fishIndex)
	local bullet0 = Bullet:create(angleFort,bundleChairId,bullet_mulriple,self.m_Type,self,android_chairid,bulletSpeedIndex,isSelf)
    local bulletB = nil
    local bulletC = nil
	local angle = math.rad(90-angleFort)
	local movedir = cc.pForAngle(angle)
	local offset = cc.p(20 * math.sin(angle),20 * math.cos(angle))
	movedir = cc.p(movedir.x * 12 , movedir.y * 12)
	local moveBy = cc.MoveBy:create(0.065,cc.p(-movedir.x*0.65,-movedir.y * 0.65))
	self.m_fort:runAction(cc.Sequence:create(moveBy,moveBy:reverse()))

    
	movedir = cc.p(movedir.x * 0.5 , movedir.y * 0.5)
	local moveBy1 = cc.MoveBy:create(0.065,cc.p(-movedir.x*0.65,-movedir.y * 0.65))
	self.m_gunPlatformButtom:runAction(cc.Sequence:create(moveBy1,moveBy1:reverse()))


    local gun_spark = display.newSprite("#dntg_iocn_fire.png")
    gun_spark:setPosition(cc.p(self.m_gunPlatformButtom:getContentSize().width / 2, self.m_gunPlatformButtom:getContentSize().height / 2+100))
    self.m_gunPlatformButtom:addChild(gun_spark)
    gun_spark:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.RemoveSelf:create()))

	bullet0:setType(bundleChairId, self.m_Type)
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
  		ExternalFun.playSoundEffect(g_var(cmd).Shell_8)
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
            local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]] / self._dataModel.bullet_speed_Mutiple
			self:autoSchedule(dt)
		end

		if 0 ~= #self.m_firelist then
			self:unOtherSchedule()
			local time = self._dataModel.m_secene.nBulletCoolingTime/1200
			self:otherSchedule(time)
		end
	end

	if cannontype == g_var(cmd).CannonType.Special_Cannon then
--        return
		self.m_fort:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_1_1.png"))
        self.m_gunPlatformButtom:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_1.png"))
		self.m_Type = g_var(cmd).CannonType.Special_Cannon
		if self.m_autoShoot or self.m_isShoot then
            self:unAutoSchedule()
            local dt = self._dataModel.bullet_send_[self._dataModel.bullet_speed_index_[self.m_nChairID + 1]] / self._dataModel.bullet_speed_Mutiple
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
		if self.m_pos < 2 then
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

	
	elseif cannontype== g_var(cmd).CannonType.Bignet_Cannon then
		self.m_Type = g_var(cmd).CannonType.Bignet_Cannon
		self:removeTypeTag()
		local Type = cc.Sprite:create("game_res/im_icon_1.png")
		Type:setTag(TagEnum.Tag_Type)
		Type:setPosition(-16,40)
		self:addChild(Type)
		if self.m_pos < 2 then
			Type:setPositionY(self:getContentSize().height - 30)
		end
		self.m_typeTime = times
		self:typeTimeSchedule(1.0)

	elseif cannontype == g_var(cmd).CannonType.Normal_Cannon then
		self.m_Type = g_var(cmd).CannonType.Normal_Cannon
		self.m_fort:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gun_1_1.png"))
        self.m_gunPlatformButtom:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("dntg_gunPlatformButtom1_1.png.png"))
		self:removeTypeTag()
	end
end

--[[function Cannon:ShowSupply( data )  -- 补给
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
end]]--

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

    --计算子弹打类型 bulletKind
    local current_bullet_kind = 0
--    if mutiple < 100 then
--        current_bullet_kind = 0
--    elseif mutiple >= 100 and mutiple < 1000  then
--        current_bullet_kind = 1
--    elseif mutiple >= 1000 and mutiple < 5000 then
--        current_bullet_kind = 2
--    elseif mutiple >= 5000 then 
--        current_bullet_kind = 3
--    end

    if mutiple >= 10000 then
        current_bullet_kind = 2
    elseif mutiple >= 1000 then 
        current_bullet_kind = 1
    else
        current_bullet_kind = 0
    end
    
    if self.m_SpecialCannon then 
        current_bullet_kind = current_bullet_kind + 3
    end

    local score = self._dataModel.fish_score_[self.m_nChairID + 1] - mutiple

	if score < 0 then
        self:unAutoSchedule()
		self.m_autoShoot = false

		if nil == self._queryDialog then
            local this = self
	    	self._queryDialog = QueryDialog:create("鱼币不足,请上分", function(ok)
                this._queryDialog = nil
            end)

            local x = 0
            if yl.WIDTH > yl.DESIGN_WIDTH then 
                x = (yl.WIDTH - yl.DESIGN_WIDTH)/2
            end
            self._queryDialog:setPositionX(self._queryDialog:getPositionX()+x)

            :setCanTouchOutside(false)
	        :addTo(cc.Director:getInstance():getRunningScene()) 
    	end

    	if self._dataModel.m_autoshoot then
            self._dataModel.m_autoshoot = false
    	end	

    	if self._dataModel.m_autolock then
    		self._dataModel.m_autolock = false
    	end

        self.parent.parent._gameView:setAutoShoot(self._dataModel.m_autoshoot,self.parent.parent._gameView.autoShootBtn)
        self.parent.parent._gameView:setAutoLock(self._dataModel.m_autolock,self.parent.parent._gameView.autoLockBtn)
    	return

	end
--    if  self._dataModel.m_autolock == false or (self._dataModel.m_autolock == true and self._dataModel.m_autoShoot == true) then
--        self._dataModel.fish_score_[self.m_nChairID + 1] = self._dataModel.fish_score_[self.m_nChairID + 1] - self.m_nCurrentBulletScore
--        self.parent:updateUserScore(self._dataModel.fish_score_[self.m_nChairID + 1],self.m_pos+1)	
--    end

    local fishIndex  = g_var(cmd).INT_MAX
    local bulletSpeedIndex = self._dataModel.bullet_speed_index_[self.m_nChairID + 1]

	if self._dataModel.m_autolock then
       
        fishIndex = self._dataModel.m_fishIndex

		if not self.m_autoShoot and not self.m_isShoot then
            return
        end
	else
        fishIndex  = g_var(cmd).INT_MAX
	end

    self._dataModel.fish_score_[self.m_nChairID + 1] = self._dataModel.fish_score_[self.m_nChairID + 1] - self.m_nCurrentBulletScore
    self.parent:updateUserScore(self._dataModel.fish_score_[self.m_nChairID + 1],self.m_pos+1)	

     --断线重连导致子弹ID错误打不到鱼修改
    if self._dataModel.m_UserBulletId_[self.m_nChairID + 1] ~= 0 and self.m_index == 0 then
        self.m_index = self._dataModel.m_UserBulletId_[self.m_nChairID + 1]
    end

    self.m_index  = self.m_index + 1
    self:productBullet(true, fishIndex, cc.WHITE,self.m_nChairID,self.m_nCurrentBulletScore,self.m_index,self.m_nChairID,bulletSpeedIndex)
    self.parent.parent:setSecondCount(60)
	local cmddata = CCmd_Data:create(24)
   	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_USER_FIRE)
    cmddata:pushint(self.m_index)
    cmddata:pushint(current_bullet_kind)
    cmddata:pushint(self.m_nCurrentBulletScore)
    cmddata:pushint(fishIndex)

    local ConvertAngle = 0

    if  self.m_nChairID < 2 then
        ConvertAngle = 6.28 - (180-self.m_fort:getRotation())/180*3.14
    elseif self.m_nChairID >= 2 then
        ConvertAngle = 12.56 - (360+self.m_fort:getRotation())/180*3.14
    end
    cmddata:pushfloat(ConvertAngle)
    cmddata:pushdword(0)

    
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
        local fire = self.m_firelist[1]
        table.remove(self.m_firelist,1)
		return
	end

	local fire = self.m_firelist[1]
	table.remove(self.m_firelist,1)
    if self.m_cannonPoint.x == 0 and self.m_cannonPoint.y == 0 then 
        self.m_cannonPoint = self:convertToWorldSpace(cc.p(self.m_fort:getPositionX(),self.m_fort:getPositionY()))
	end

    local angle = 0

    if self._dataModel.m_reversal and fire.chair_id > 1 then
        angle = 180 + ((12.56 - fire.angle)/3.14*180 - 360)
    elseif not self._dataModel.m_reversal and fire.chair_id < 2 then
        angle = 180 + (180-(6.28 - fire.angle)/3.14*180)
    else
        if fire.chair_id > 1 then
            angle = (12.56 - fire.angle)/3.14*180 - 360
        elseif  fire.chair_id < 2 then
            angle = 180-(6.28 - fire.angle)/3.14*180
        end
    end

    local fish1 = nil
    if fire.android_chairid < 4 then    
        fish1 = self._dataModel.m_fishList[fire.lock_fish_id]
        local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
        if fish1 == nil or fire.lock_fish_id == g_var(cmd).INT_MAX or not cc.rectContainsPoint(rect, cc.p(fish1:getPositionX(), fish1:getPositionY())) then
            self:removeLockTag(fire.chair_id)
            fire.lock_fish_id = 0;
        end
        if fish1 == nil then
            local cmddata = CCmd_Data:create(6)     
            cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_USER_LOCKFISH)
            cmddata:pushint(-2)
            cmddata:pushword(fire.chair_id)
            if not self.frameEngine:sendSocketData(cmddata) then
                print("----------发送失败----------")
            end
        end
        if self.AndroidLockFishId[fire.android_chairid] ~= fire.lock_fish_id then
             self:removeLockTag(fire.chair_id)
        end

        if fish1 ~= nil then
           self:setLockFishLine(fire.chair_id,fire.lock_fish_id)
            local pos = cc.p(fish1:getPositionX(), fish1:getPositionY())
            if self._dataModel.m_reversal then
               pos = cc.p(yl.WIDTH-pos.x,yl.HEIGHT-pos.y)
		   end
           angle = self._dataModel:getAngleByTwoPoint(pos, self.m_cannonPoint)

           --发送锁鱼信息
           local cmddata = CCmd_Data:create(6)
           cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_USER_LOCKFISH)
		   cmddata:pushint(fire.lock_fish_id)
		   cmddata:pushword(fire.chair_id)
           if not self.frameEngine:sendSocketData(cmddata) then
		       print("----------发送失败----------")
	       end
           --记录机器人锁鱼ID
           self.AndroidLockFishId[fire.android_chairid] = fire.lock_fish_id
       end
    end
    
    self.m_fort:setRotation(angle)
    self.m_gunPlatformButtom:setRotation(angle)
    
    local bulletSpeedIndex = self._dataModel.bullet_speed_index_[fire.chair_id + 1]     -- 玩家的子弹速度
    if self._dataModel._exchangeSceneing  then 	                                        -- 切换场景中不能发炮
		return 
	end
    
    if self.frameEngine:GetMeUserItem() ~= nil then
        self:productBullet(false, fire.lock_fish_id, cc.WHITE,fire.chair_id,fire.bullet_mulriple,fire.bullet_id,fire.android_chairid,bulletSpeedIndex)
    end	
end

function Cannon:updateScore(score)
    if self.parent ~= nil then
        self.parent:updateUserScore(score,self.m_pos+1)	
    end
end

function Cannon:showGold(score)
    --self.m_pGold:showGold(score)
   self.m_pGold:showGoldEx(score,self.m_nChairID) 

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
    if self:getChildByTag(TagEnum.Tag_lock) then
        self.fishId1 = g_var(cmd).INT_MAX
        self:removeChildByTag(TagEnum.Tag_lock)
        self:removeChildByTag(TagEnum.Tag_switch_fish)
        self:removeChildByTag(TagEnum.Tag_btn_switch)
        self:removeChildByTag(TagEnum.Tag_btn_switch1)
    end

    if self:getChildByTag(TagEnum.Tag_lockLine) then
        self:removeChildByTag(TagEnum.Tag_lockLine)
    end
end

function Cannon:removeTypeTag()
	self:removeChildByTag(TagEnum.Tag_Type)
end

return Cannon