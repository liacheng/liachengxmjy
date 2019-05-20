--
-- Author: Tang
-- Date: 2016-08-09 10:31:00
--炮台
local CannonLayer = class("CannonLayer", cc.Layer)
local module_pre = "game.yule.fishzyqs4.src"			
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local cmd = module_pre..".models.CMD_ZYQSGame"
local Cannon = module_pre..".views.layer.Cannon"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()

CannonLayer.enum = 
{
	Tag_userNick =1, 	
	Tag_userScore=2,
	Tag_GameScore = 10,
	Tag_Buttom = 70 ,
	Tag_Cannon = 200,
}
local TAG =  CannonLayer.enum

function CannonLayer:ctor(viewParent)
	self.parent = viewParent
	self._dataModel = self.parent._dataModel
	self._gameFrame  = self.parent._gameFrame
	self.m_pUserItem = self._gameFrame:GetMeUserItem()      -- 自己信息
    self.m_nTableID  = self.m_pUserItem.wTableID
    self.m_nChairID  = self.m_pUserItem.wChairID
    self.m_dwUserID  = self.m_pUserItem.dwUserID
    self.m_cannonList = {}          -- 炮台列表
    self.isCanCreateBullet = true
    self.m_schedule = nil
    self._userList = {}
    self.m_bulletIon = {}
    self.rootNode = nil
    self.m_userScore = 0            -- 用户分数 
    
    local xoffset = 0
    xoffset = (yl.WIDTH-yl.DESIGN_WIDTH) / 2

    self.m_pCannonPos =             -- 炮台位置
    {
    	cc.p(448 + xoffset,730),
--	    cc.p(667 + xoffset,730),
	    cc.p(896 + xoffset,730),
	    cc.p(438 + xoffset,115),
--	    cc.p(665 + xoffset,115),
        cc.p(896 + xoffset,115)
	}
	self.m_GunPlatformPos =         -- gun位置
	{
		cc.p(448 + xoffset,733),
--		cc.p(667 + xoffset,733),
		cc.p(896 + xoffset,733),
		cc.p(438 + xoffset,70),
--		cc.p(665 + xoffset,70),
        cc.p(896 + xoffset,70)
	}
	self.m_NickPos = cc.p(74,40)    -- 用户信息背景
	self.m_ScorePos = cc.p(74,22)
	self.myPos = 0			        -- 视图位置
	self:init()
    ExternalFun.registerTouchEvent(self,false)  -- 注册事件
end


function CannonLayer:SpecialCannon(chairId, isSpecialCannon)
    for i = 1, 4 do       -- 设置炮台倍数
        local cannon = self:getCannoByPos(i)
        if cannon ~= nil then
            if chairId == cannon.m_ChairID then
                cannon:SpecialCannon(isSpecialCannon)
                cannon:setMultiple(self._dataModel.m_userCurrentMutiple[chairId + 1],chairId)
                break
            end
            
        end
    end
 
end

--双倍炮结束
function CannonLayer:SpecialCannon_timeout(chairId)
    for i=1,4 do       -- 设置炮台倍数
        local cannon = self:getCannoByPos(i)
        if nil ~= cannon then
            if chairId == cannon.m_ChairID then
                local isSpecialCannon = false
                cannon:SpecialCannon_Timeout(isSpecialCannon)
               
                cannon:setMultiple(self._dataModel.m_userCurrentMutiple[chairId + 1],chairId)
            end
            
        end
    end

end


--用户进入显示炮口
function CannonLayer:ShowCannon(chairId, isSpecialCannon)
    local cannon = self:getCannoByPos(chairId+1)
    self.m_bulletIon[chairId+1] = isSpecialCannon
    if nil ~= cannon then
        cannon:ShowCannon(isSpecialCannon)
        cannon:setMultiple(self._dataModel.m_currentMutiple,chairId)
    end

end

function CannonLayer:init()
    local xoffset = 0
    xoffset = (yl.WIDTH-yl.DESIGN_WIDTH) / 2
	local csbNode = ExternalFun.loadCSB("game_res/Cannon.csb", self)        -- 加载csb资源
    self.rootNode = csbNode
    self.rootNode:setPosition(cc.p(self.rootNode:getPositionX()+xoffset, self.rootNode:getPositionY()))
	local myCannon = g_var(Cannon):create(self)                             -- 初始化自己炮台
	myCannon:initWithUser(self.m_pUserItem)
	myCannon:setPosition(self.m_pCannonPos[myCannon.m_pos + 1])
	self:removeChildByTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
	myCannon:setTag(TAG.Tag_Cannon + myCannon.m_pos + 1)
    myCannon:setMyMultiple(self._dataModel.m_currentMutiple)
	self.mypos = myCannon.m_pos + 1
	self:initCannon()
	self:addChild(myCannon)

	
	local tipsImage = ccui.ImageView:create("zyqs_bg_tag.png",UI_TEX_TYPE_PLIST)        -- 位置提示
	tipsImage:setAnchorPoint(cc.p(0.5,0.0))
	tipsImage:setPosition(cc.p(myCannon:getPositionX(),260))
	self:addChild(tipsImage)

	local arrow = ccui.ImageView:create("zyqs_bg_tagarrows.png",UI_TEX_TYPE_PLIST)
	arrow:setAnchorPoint(cc.p(0.5,1.0))
	arrow:setPosition(cc.p(tipsImage:getContentSize().width/2,3))
	tipsImage:addChild(arrow)

	local jumpUP = cc.MoveTo:create(0.4,cc.p(myCannon:getPositionX(),290))  -- 跳跃动画
	local jumpDown =  cc.MoveTo:create(0.4,cc.p(myCannon:getPositionX(),260))
	tipsImage:runAction(cc.Repeat:create(cc.Sequence:create(jumpUP,jumpDown), 20))
	tipsImage:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function()
		tipsImage:removeFromParent()
	end)))

	local pos = self.m_nChairID
	if self._dataModel.m_reversal then 
        pos = 3 - pos
	end

	self:showCannonByChair(pos+1)
	self:initUserInfo(pos+1,self.m_pUserItem)
	local cannonInfo ={d=self.m_dwUserID,c=pos+1}
	table.insert(self.m_cannonList,cannonInfo)
    self:onChangeSchedule(1);
end	

function CannonLayer:onChangeSchedule(index)
    if index < 1 or index > 5 then
        return
    end

    local function updateBullet( dt )
        self.isCanCreateBullet = true
    end
    local time = self._dataModel.bullet_update_[index] / self._dataModel.bullet_speed_Mutiple
    if nil ~= self.m_schedule then
        scheduler:unscheduleScriptEntry(self.m_schedule)
        self.m_schedule = nil
    end
	
	if nil == self.m_schedule then      -- 定时器
        self.m_schedule = scheduler:scheduleScriptFunc(updateBullet, time, false)
	end
end

function CannonLayer:initCannon()
	local mypos = self.m_nChairID
	if self._dataModel.m_reversal then 
        mypos = 3 - mypos
	end

	for i=1,4 do
		if i~= mypos+1 then
            self:HiddenCannonByChair(i)
		end
	end
end

function CannonLayer:initUserInfo(viewpos,userItem)
    local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", viewpos))

	if infoBG == nil then
		return
	end
    --用户昵称隐藏
--	local nick =  cc.Label:createWithTTF(userItem.szNickName, "fonts/round_body.ttf", 23)   -- 用户昵称
--	nick:setTextColor(cc.WHITE)
--	nick:setAnchorPoint(0.5,0.5)
--	nick:setTag(TAG.Tag_userNick)
--	nick:setPosition(self.m_NickPos.x+120, self.m_NickPos.y-15)
--	self:removeChildByTag(TAG.Tag_userNick)
--	self:addChild(nick)
    --用户昵称隐藏
--	local score = cc.Label:createWithCharMap("game_res/zyqs_num_small.png",18,25,string.byte("%"))    -- 用户分数
    local score = cc.LabelAtlas:create(num,"game_res/zyqs_num_small.png",18,25, string.byte("*"))
	score:setString(string.format("%d", self._dataModel.fish_score_[userItem.wChairID+1]))
	score:setAnchorPoint(0.5,0.5)
	score:setTag(TAG.Tag_userScore)
	score:setPosition(self.m_ScorePos.x+22, self.m_ScorePos.y)
	infoBG:removeChildByTag(TAG.Tag_userScore)
	infoBG:addChild(score)

	if viewpos<3 then
--        nick:setRotation(180)
		--score:setRotation(180)
--        nick:setPosition(self.m_NickPos.x, self.m_ScorePos.y*2-self.m_NickPos.y)
	end
end

function CannonLayer:updateMultiple( mutiple,cannonPos )
--	local gunPlatformButtom = self:getChildByTag(TAG.Tag_Buttom+cannonPos)
--    if gunPlatformButtom == nil then
--        return
--    end
	local labelMutiple = self:getChildByTag(500+cannonPos)
	if nil ~= labelMutiple then
        labelMutiple:setString(string.format("%d", mutiple))
	end
end

function CannonLayer:updateUserScore( score,cannonpos )
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", cannonpos))
	if infoBG == nil then
        return
	end
	local scoreLB = infoBG:getChildByTag(TAG.Tag_userScore)
	if score >= 0 and nil ~= scoreLB then
		scoreLB:setString(tostring(score))
	end

	local mypos = self.m_nChairID

	if self._dataModel.m_reversal then 
        mypos = 3 - mypos
	end

	if mypos == cannonpos - 1 then
		--self.parent._gameView:updateUserScore(score)
	end
end

function CannonLayer:setFishScore( score,cannonpos )
    if score >= 0 then
        local cannon = self:getChildByTag(cannonpos + TAG.Tag_Cannon )
        if cannon ~= nil then
            cannon:showGold(score)
        end
	end
end

function CannonLayer:HiddenCannonByChair( chair )

	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))
	infoBG:setVisible(false)

	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(false)

	self:removeChildByTag(TAG.Tag_Buttom + chair)
end

function CannonLayer:showCannonByChair( chair )
	local infoBG = self.rootNode:getChildByName(string.format("im_info_bg_%d", chair))

	if infoBG == nil then
		return
	end

	infoBG:setVisible(true) --玩家信息
    local gameMinMutiple = self.parent.min_bullet_multiple
    local gameMaxMutiple = self.parent.max_bullet_multiple
	local gunPlatformCenter = self.rootNode:getChildByName(string.format("gunPlatformCenter_%d", chair))
	gunPlatformCenter:setVisible(true)
    local pos = self.m_nChairID
	if self._dataModel.m_reversal then 
		pos = 3 - pos
	end

--	local gunPlatformButtom = display.newSprite("#zyqs_gunPlatformButtom1_1.png")
--	gunPlatformButtom:setPosition(self.m_GunPlatformPos[chair].x, self.m_GunPlatformPos[chair].y)
--	gunPlatformButtom:setTag(TAG.Tag_Buttom+chair)
--	self:removeChildByTag(TAG.Tag_Buttom+chair)
--	self:addChild(gunPlatformButtom,5)
end

function CannonLayer:getCannon(pos)
	local cannon = self:getChildByTag(pos + TAG.Tag_Cannon)
	return cannon 
end


function CannonLayer:getCannoByPos( pos )
	local cannon = self:getChildByTag(TAG.Tag_Cannon + pos)
	return  cannon
end


function CannonLayer:getUserIDByCannon(viewid)
    local userid = 0
	if #self.m_cannonList > 0 then
        for i=1,#self.m_cannonList do
            local cannonInfo = self.m_cannonList[i]
			if cannonInfo.c == viewid then
                userid = cannonInfo.d
				break
			end
		end
 	end
    return userid
end

function CannonLayer:onEnter()
	
end

function CannonLayer:onEnterTransitionFinish()

end

function CannonLayer:onExit()
    self.m_cannonList = nil
end

function CannonLayer:onTouchBegan(touch, event)
    if self._dataModel._exchangeSceneing  then 	-- 切换场景中不能发炮
        return false
	end
    
    local pos = touch:getLocation()
--    if pos.y < 68 then
--        return false
--    end
    if self.isCanCreateBullet then
        local cannon = self:getCannon(self.mypos)
	    if nil ~= cannon then
		    cannon:shoot(cc.p(pos.x,pos.y), true)
		    self.parent:setSecondCount(60)
	    end
        self.isCanCreateBullet = false
    else
        return false
    end
	
	return true
end

function CannonLayer:onTouchMoved(touch, event)
	local cannon = self:getCannon(self.mypos)
	if nil ~= cannon then
		local pos = touch:getLocation()
		cannon:shoot(cc.p(pos.x,pos.y), true)
		self.parent:setSecondCount(60)
	end
end

function CannonLayer:onTouchEnded(touch, event )
	local cannon = self:getCannon(self.mypos)
	if nil ~= cannon then
        local pos = touch:getLocation()
		cannon:shoot(cc.p(pos.x,pos.y), false)
		self.parent:setSecondCount(60)
	end
end

--用户进入
function CannonLayer:onEventUserEnter( wTableID,wChairID,useritem )
    if wChairID > 3 or wTableID ~= self.m_nTableID or wChairID == self.m_nChairID then
        return
    end

    local pos = wChairID
    if self._dataModel.m_reversal then 
    	pos = 3 -pos 
    end
    
    if pos + 1 == self.m_pos then  --过滤自己
 		return
 	end
    self:showCannonByChair(pos + 1)
 	self:removeChildByTag(TAG.Tag_Cannon + pos + 1)

 	if #self.m_cannonList > 0 then
 		for i=1,#self.m_cannonList do
 			local cannonInfo = self.m_cannonList[i]
 			if cannonInfo.d == useritem.dwUserID then
                table.remove(self.m_cannonList,i)
 				break
 			end
 		end
 	end

 	if #self._userList > 0 then
 		for i=1,#self._userList do
 			local Item = self._userList[i]
 			if Item.dwUserID == useritem.dwUserID then
 				table.remove(self._userList,i)
 				break
 			end
 		end
 	end
 	
    local Cannon = g_var(Cannon):create(self)
	Cannon:initWithUser(useritem)
	Cannon:setPosition(self.m_pCannonPos[Cannon.m_pos + 1])
	Cannon:setTag(TAG.Tag_Cannon + Cannon.m_pos + 1)
	self:addChild(Cannon)
	self:initUserInfo(pos + 1,useritem)
	local cannonInfo ={d=useritem.dwUserID,c=pos+1}
	table.insert(self.m_cannonList,cannonInfo)
	table.insert(self._userList, useritem)
end

function CannonLayer:onEventUserStatus(useritem,newstatus,oldstatus)    -- 用户状态
    --    if newstatus.wTableID ~= self.m_nTableID and oldstatus.wTableID == yl.INVALID_TABLE then
--        return
--    end
    

    if oldstatus.wTableID ~= self.m_nTableID then
        if newstatus.wTableID ~= self.m_nTableID then
            return
        end
    elseif newstatus.wTableID == self.m_nTableID then
        if oldstatus.wTableID ~= yl.INVALID_TABLE then
            return
        end
    end

    local chairId = yl.INVALID_CHAIR
    if newstatus.wChairID ~= yl.INVALID_CHAIR then
        chairId = newstatus.wChairID
    end
    if oldstatus.wChairID ~= yl.INVALID_CHAIR then
        chairId = oldstatus.wChairID
    end
    if newstatus.cbUserStatus == yl.US_FREE or  newstatus.cbUserStatus == yl.US_NULL then
        if #self.m_cannonList > 0 then
            for i=1,#self.m_cannonList do
                local cannonInfo = self.m_cannonList[i]
                if cannonInfo.d == useritem.dwUserID then
                    print("用户离开"..cannonInfo.c)
                    self:HiddenCannonByChair(cannonInfo.c)
                    table.remove(self.m_cannonList,i)
                    if #self._userList > 0 then
                        for i=1,#self._userList do
                            local Item = self._userList[i]
                            if Item.dwUserID == useritem.dwUserID then
                                --chairId = useritem.wChairID
                                table.remove(self._userList,i)
                                break
                            end
                        end
                    end
                    local cannon = self:getChildByTag(TAG.Tag_Cannon + cannonInfo.c)
                    if nil ~= cannon then
                        cannon:removeChildByTag(1000)
                        cannon:removeTypeTag()
                        cannon:removeLockTag(chairId)
                        cannon:removeFromParent()
                        if chairId ~= yl.INVALID_CHAIR then
                            self._dataModel.fish_score_[chairId + 1] = 0
                            self._dataModel.exchange_fish_score_[chairId + 1] = 0
                        end
                    end
                    break
                end
            end
        end 
    else
        local pos = useritem.wChairID
        if self._dataModel.m_reversal then 
            pos = 3 -pos 
        end

        if pos + 1 == self.m_pos then  --过滤自己
            return
        end
        self:showCannonByChair(pos + 1)
        self:initUserInfo(pos + 1,useritem)
        self:removeChildByTag(TAG.Tag_Cannon + pos + 1)
        if #self.m_cannonList > 0 then
            for i=1,#self.m_cannonList do
                local cannonInfo = self.m_cannonList[i]
                if cannonInfo == nil then
                    break
                end
                if cannonInfo.d == useritem.dwUserID then
                    table.remove(self.m_cannonList,i)
                end
            end
        end

        if #self._userList > 0 then
            for i=1,#self._userList do
                local Item = self._userList[i]
                if Item.dwUserID == useritem.dwUserID then
                    table.remove(self._userList,i)
                    break
                end
            end
        end

        table.insert(self._userList,useritem)
        local Cannon = g_var(Cannon):create(self)
        Cannon:initWithUser(useritem)
        Cannon:setPosition(self.m_pCannonPos[Cannon.m_pos + 1])-- change
        Cannon:setTag(TAG.Tag_Cannon + Cannon.m_pos + 1)
        self:addChild(Cannon)
        --self._dataModel.fish_score_[useritem.wChairID + 1] = 0
        --self._dataModel.exchange_fish_score_[useritem.wChairID + 1] = 0
        local cannonInfo = {d=useritem.dwUserID,c=pos+1}
        table.insert(self.m_cannonList,cannonInfo)
    end
end

return CannonLayer