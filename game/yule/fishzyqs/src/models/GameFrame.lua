--
-- Author: Tang
-- Date: 2016-08-09 14:50:01
--
local GameFrame = class("GameFrame")
local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.1, 0.5, 0.5)

function GameFrame:ctor()
    self.m_autoshoot = false                    -- 自动射击
 	self.m_autolock = false 	                -- 自动锁定
 	self.m_reversal = false
 	self.m_fishIndex = 2147483647
 	self._bFishInView	    = false
 	self.m_InViewTag = {}
 	self._exchangeSceneing	= false
 	self.m_getFishScore = 0                     -- 捕鱼收获
 	self.lBulletConsume = 0                     -- 子弹消耗的分数
 	self.m_waitList = {}                        -- 等待鱼列表
 	self.m_fishList = {}                        -- 鱼列表
 	self.m_fishKingList = {}                    -- 记录鱼王
 	self.m_fishCreateList = {}                  -- 创建鱼
 	self.m_fishArray = {}	                    -- 场景中鱼
 	self.m_bodyList = {}                        -- 物体刚体数据
 	self.m_secene = {}	                        -- 场景数据
    self.m_nMultiple = {1,10,100,500,1000,5000} -- 房间倍数
    self.m_sinList = {}
    self.m_cosList = {}
    self.exchange_fish_score_ = {0,0,0,0,0,0}   -- 每个位置上交换的鱼币
    self.m_UserBulletId_ = {0,0,0,0,0,0}
    self.fish_score_ = {0,0,0,0,0,0}            -- 捕鱼和交换的总鱼币
    self.bullet_speed_ = {10,20,30,40,50}       -- 子弹的速度
    self.bullet_speed_Mutiple = 1           -- 子弹加速倍数
    self.bullet_speed_index_ = {1,1,1,1,1,1}    -- 子弹的档位
    self.bullet_send_ = {0.25,0.25,0.25,0.25,0.25} --self.bullet_send_ = {0.8,0.7,0.6,0.4,0.2}   -- 发射子弹的速度
    self.bullet_update_ = {0.4,0.3,0.25,0.2,0.15}   -- 子弹刷新的速度
    self.m_currentMutiple = 100                 -- 当前自己的子弹倍数
    self.m_userCurrentMutiple = {0,0,0,0,0,0}   -- 记录用户的子弹倍数
   	self:readyBodyPlist("game_res/fish_bodies.plist")
   	self:readyBodyPlist("game_res/bullet_bodies.plist")
   	self.m_enterTime = 0	                    -- 进入时间 
    self.m_scene_kind = 0                       -- 鱼阵kind
    self:initTrigonomentirc()
    self.m_lUserScore = GlobalUserItem.lUserScore
end

function GameFrame:readyBodyPlist( param )      -- 解析刚体数据 plist
    local Path = cc.FileUtils:getInstance():fullPathForFilename(param)
    local datalist = cc.FileUtils:getInstance():getValueMapFromFile(Path) 
    local bodies = datalist["bodies"]
  
    for k,v in pairs(bodies) do                -- 解析数据
        if  k ~= nil then
            local bodyName = k
    		local sub = bodies[bodyName]
    		local fixtures = sub["fixtures"]
    		local polygonsarr = fixtures[1]
    		local polygons = polygonsarr["polygons"]
    		local points = {}
    		for i=1,#polygons do
                table.insert(points, polygons[i])
    		end
    		table.insert(self.m_bodyList,{k = bodyName,p = points})
    	end
    end
end

function GameFrame:getBodyByType( param )
    local type = string.format("fishMove_%03d_1", param+1)
	return self:getBodyByName(type)
end

function GameFrame:getBodyByName( param )
    if #self.m_bodyList ~= 0 then
        for i=1,#self.m_bodyList do
            local sublist = self.m_bodyList[i]
			local k = sublist.k
	
			if k == param then
                local points = sublist.p
				local physicsBody = cc.PhysicsBody:create(PHYSICS_INFINITY, PHYSICS_INFINITY)
				for s=1,#points do
                    local onePoint = points[s]
					local resultPoints = {}
					for t=1,#onePoint do
                        local vector = onePoint[t]
						local result = string.sub(vector, 2, -2)    -- 去掉大括号
						local len = string.len(result)
						local dindex = string.find(result,",")
						local subx = string.sub(result,1,dindex-1)
						local x = tonumber(subx)
						local suby = string.sub(result,dindex+1,len)
						local y = tonumber(suby)
						local p = cc.p(x,y)
						table.insert(resultPoints, p)
					end
				
					local center = cc.PhysicsShape:getPolyonCenter(resultPoints)
				    local shape = cc.PhysicsShapePolygon:create(resultPoints,cc.PHYSICSBODY_MATERIAL_DEFAULT,cc.p(-center.x, -center.y))
				    physicsBody:addShape(shape)
					physicsBody:setGravityEnable(false)
					return physicsBody
				end
                break
            end
        end
	end
end

--[[
@function  convertCoordinateSystem

@param type : 0 左下角坐标系转换到左上角坐标系 
			  1 左上角坐标系转换到左下角坐标系
			  2 爆炸动画坐标系

@return cc.p
]]
function GameFrame:convertCoordinateSystem(point,type,bconvert)
    local WIN32_W = 1280
    local WIN32_H = 800
    local scalex = yl.WIDTH/WIN32_W
    local scaley = yl.HEIGHT/WIN32_H
    local point1 = point 
    if type ==0 then
        point1.x = point.x/scalex
        point1.y = WIN32_H - point1.y/scaley
        if bconvert then
            point1.x = WIN32_W - point1.x
            point1.y = WIN32_H - point1.y
        end
    elseif type == 1 then	
        point1.x = point.x*scalex
        point1.y = yl.HEIGHT - point.y*scaley
        if bconvert then
            point1.x = yl.WIDTH - point1.x
            point1.y = yl.HEIGHT - point1.y
        end
    else
        point1.x = point1.x/scalex
        if bconvert then
            point1.x = WIN32_W - point1.x
            point1.y = WIN32_H - point1.y/scaley
        end
    end
    return point1 
end

function GameFrame:getAngleByTwoPoint( param,param1 )
    if type(param) ~= "table" or type(param1) ~= "table" then
        print("传入参数有误")
        return
    end

	local point = cc.p(param.x-param1.x,param.y-param1.y)
	local angle = 90 - math.deg(math.atan2(point.y, point.x))
    -- print("angle is ========>"..angle)
    return angle
end

function GameFrame:getNetColor( param )
	if type(param) ~= "number" then
        return
	end

	if param == 0 or param > 5 then
        param = 1
	end

    local switch = 
	{
		[1] = function( )
            return  cc.WHITE
		end,

		[2] = function( )
			return  cc.BLUE
		end,

		[3] = function( )
			return cc.GREEN
		end,

		[4] = function( )
			return cc.c3b(255, 0, 255)
		end,

		[5] = function( )
			return cc.RED
		end,

		[6] = function( )
			return cc.YELLOW
		end
	}

	local f = switch[param]
	return f()
end

function GameFrame:selectMaxFish(index)     -- 自动锁定搜寻大鱼
    local fishtype = 8
	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
    local curIndex = 2147483647
    local fishlist = {}
	for k,v in pairs(self.m_fishList) do
        local fish = v
		if fish.m_data.fish_kind > fishtype then
            local pos = cc.p(fish:getPositionX(), fish:getPositionY())
			if cc.rectContainsPoint(rect, pos) then
                table.insert(fishlist, k)
			end
		end
	end

    if index == nil then
        if #fishlist > 0 then
            curIndex = fishlist[1]
        end
    else
        for k, v in pairs(fishlist) do
            print("-----------v:"..v.."    index:"..index)
            if v ~= index then
                curIndex = v
                break
            end
        end
        if curIndex == 2147483647 then
            curIndex = index
        end
    end

	return curIndex
end
-- function GameFrame:selectMaxFish( )
--    local fishlist = {}
--	local fishtype = 16
--	local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)

--	for k,v in pairs(self.m_fishList) do
--        local fish = v
--		if fish.m_data.fish_kind > fishtype then
--            local pos = cc.p(fish:getPositionX(),fish:getPositionY())
--			if cc.rectContainsPoint( rect, pos ) then
--                fishtype = fish.m_data.fish_kind
--				fishlist = {}
--				table.insert(fishlist,fish)
--			end
--		end

--        if fish.m_data.fish_kind == fishtype then
--			table.insert(fishlist,fish)
--		end
--	end

--	local mid = cc.p(yl.WIDTH/2,yl.HEIGHT/2)
--	local distant = 1000
--	local fishIndex = 2147483647
--	for i=1,#fishlist do
--		local fish = fishlist[i]
--		local pos = cc.p(fish:getPositionX(),fish:getPositionY())
--		local distant1 =  cc.pGetDistance(pos,mid)
--		if distant1 < distant then
--			distant = distant1
--			fishIndex = fish.nFishKey
--		end
--	end

--	fishlist = {}
--	return fishIndex

--	end
function GameFrame:checkRes()
	local bFinish = false
    local texture = cc.Director:getInstance():getTextureCache():getTextureForKey("game_res/fishyqs_fish_3.png")
    local anim = cc.AnimationCache:getInstance():getAnimation("fish_22_yd")
    if texture and anim then
       bFinish = true
    end
    return bFinish
end

function GameFrame:initTrigonomentirc( )
    for i=1,360 do
        local sin = math.sin(3.14 / 180 * i)
		local cos = math.cos(3.14 / 180 * i)
		table.insert(self.m_sinList, sin)
		table.insert(self.m_cosList, cos)
	end
end

function GameFrame:playEffect( file )
	if GlobalUserItem.nSound == 0 then
		return
	end
	AudioEngine.playEffect(file)
end

return GameFrame