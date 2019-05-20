--                            _ooOoo_  
--                           o8888888o  
--                           88" . "88  
--                           (| -_- |)  
--                            O\ = /O  
--                        ____/`---'\____  
--                      .   ' \\| |// `.  
--                      / \\||| : |||// \  
--                     / _||||| -:- |||||- \  
--                       | | \\\ - /// | |  
--                     | \_| ''\---/'' | |  
--                      \ .-\__ `-` ___/-. /  
--                   ___`. .' /--.--\ `. . __  
--                ."" '< `.___\_<|>_/___.' >'"".  
--               | | : `- \`.;`\ _ /`;.`/ - ` : | |  
--                 \ \ `-. \_ __\ /__ _/ .-` / /  
--         ======`-.____`-.___\_____/___.-`____.-'======  
--                            `=---='  
--  
--         .............................................  
--                  佛祖保佑             永无BUG 

local GameLayer = class("GameLayer", function(frameEngine,scene)        --创建物理世界
    cc.Director:getInstance():getRunningScene():initWithPhysics()
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0,-100))
    local gameLayer = display.newLayer()
    return gameLayer
end)  

local TAG_ENUM = 
{
    Tag_Fish = 200
}

require("cocos.init")
local module_pre    = "game.yule.fishlk.src"
local cmd           = module_pre .. ".models.CMD_LKGame"
local Fish          = module_pre .. ".views.layer.Fish"
local GameFrame     = module_pre .. ".models.GameFrame"
local FishTrace     = module_pre .. ".models.FishTrace"
local CannonLayer   = module_pre .. ".views.layer.CannonLayer"
local ScreenShaker  = module_pre .. ".models.ScreenShaker"
local GameViewLayer = module_pre .. ".views.layer.GameViewLayer"
local ExternalFun   = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var         = ExternalFun.req_var
local game_cmd      = appdf.HEADER_SRC .. "CMD_GameServer"
local scheduler     = cc.Director:getInstance():getScheduler()
local Bingo         = module_pre .. ".views.layer.Bingo"

function GameLayer:ctor(frameEngine,scene)
    self.m_infoList = {}
    self.m_scheduleUpdate = nil
    self.m_secondCountSchedule = nil
    self._scene = scene
    self.m_bScene = false
    self.m_bSynchronous = false
    self.m_nSecondCount = 60
    self.m_catchFishCount = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self._gameFrame = frameEngine
    self._gameFrame:setKindInfo(cmd.KIND_ID,cmd.VERSION)
    self._roomRule = self._gameFrame._dwServerRule
    self.fishTrace = g_var(FishTrace):create()          -- 场景鱼路径创建
    self.m_isSceneChanging = false                      -- 是否处在场景切换中
    self._gameView = g_var(GameViewLayer):create(self):addTo(self)
    self._dataModel = g_var(GameFrame):create()
    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID  = self.m_pUserItem.wTableID
    self.m_nChairID  = self.m_pUserItem.wChairID  
    self.exchange_ratio_userscore = 0
    self.exchange_ratio_fishscore = 0
    self.exchange_count = 0
    self.min_bullet_multiple = 0
    self.max_bullet_multiple = 0
    self.fish_speed = {}
    self.bullet_speed = {}
    self.nFishMultiple = {}
    self.exchangeFishScore = 0
    self:setReversal()
    self.m_fishLayer = cc.Layer:create()              -- 鱼层
    self._gameView:addChild(self.m_fishLayer, 5)
    self.bingo_list = {}

    if self._dataModel.m_reversal then
        self.m_fishLayer:setRotation(180)
    end

    self.screenShake = g_var(ScreenShaker):create(self.m_fishLayer,0.5)
    self._gameView:initUserInfo()               -- 自己信息
    self:onCreateSchedule()                     -- 创建定时器
    self:createSecoundSchedule()                -- 60秒未开炮倒计时
    ExternalFun.registerTouchEvent(self,true)   -- 注册事件
    self:addEvent()                             -- 注册通知

    --打开调试模式
    --cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
end


function GameLayer:BuildSceneKindTrace()    -- 计算鱼的场景
    --coroutine.yield(2 * a)
    local co = coroutine.create(function()
        self.fishTrace:BuildSceneKind1Trace(cc.Director:getInstance():getVisibleSize().width,cc.Director:getInstance():getVisibleSize().height)
        self.fishTrace:BuildSceneKind2Trace(cc.Director:getInstance():getVisibleSize().width,cc.Director:getInstance():getVisibleSize().height)
        self.fishTrace:BuildSceneKind3Trace(cc.Director:getInstance():getVisibleSize().width,cc.Director:getInstance():getVisibleSize().height)
        self.fishTrace:BuildSceneKind4Trace(cc.Director:getInstance():getVisibleSize().width,cc.Director:getInstance():getVisibleSize().height)
        self.fishTrace:BuildSceneKind5Trace(cc.Director:getInstance():getVisibleSize().width,cc.Director:getInstance():getVisibleSize().height)  
    end)

    if #self.fishTrace.scene_kind_1_trace_ == 0 or #self.fishTrace.scene_kind_2_trace_ == 0 or #self.fishTrace.scene_kind_3_trace_ == 0 or #self.fishTrace.scene_kind_4_trace_ == 0 or #self.fishTrace.scene_kind_5_trace_ == 0  then
        coroutine.resume(co)
    end
end

function GameLayer:addEvent()
    local function eventListener(event)         -- 通知监听
        self._gameView:initView()                               -- 初始化界面
        self.m_cannonLayer = g_var(CannonLayer):create(self)    -- 添加炮台层
        self._gameView:addChild(self.m_cannonLayer, 6)
        for i = 0,5 do
            local cannonPos = i
            if self._dataModel.m_reversal then 
                cannonPos = 5 - cannonPos
            end
            self.m_cannonLayer:updateUserScore( self._dataModel.fish_score_[i + 1],cannonPos+1 )            -- 更新用户分数
        end

        self._gameFrame:QueryUserInfo(self.m_nTableID,yl.INVALID_CHAIR)                                     -- 查询本桌其他用户查询本桌其他用户
        AudioEngine.playMusic(cc.FileUtils:getInstance():fullPathForFilename(g_var(cmd).Music_Back_1),true) -- 播放背景音乐
    end

    local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function GameLayer:setReversal( )   -- 判断自己位置 是否需翻转
    if self.m_pUserItem then
        if self.m_pUserItem.wChairID < 3 then
            self._dataModel.m_reversal = true
        end
    end
    return self._dataModel.m_reversal
end


function GameLayer:addContact() -- 添加碰撞
    local function onContactBegin(contact)
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
        local bullet = nil
        local fish = nil

        if a and b then
            if a:getTag() == g_var(cmd).Tag_Bullet then
                bullet = a
                fish = b
            end

            if b:getTag() == g_var(cmd).Tag_Bullet then
                bullet = b
                fish = a
            end
        end

        if fish == nil then
           return true
        end

        if fish.isActive == false then
           return true
        end

        if nil ~= bullet then
           bullet:fallingNet(fish.nFishKey)
           bullet:removeFromParent()
        end

        return true
    end

    local dispatcher = self:getEventDispatcher()
    self.contactListener = cc.EventListenerPhysicsContact:create()
    self.contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(self.contactListener, self)

end

function GameLayer:setSecondCount(dt)       -- 60开炮倒计时
    self.m_nSecondCount = dt
    if dt == 60 then
        local tipBG = self._gameView:getChildByTag(10000)
        if nil ~= tipBG then
            tipBG:removeFromParent()
        end
    end
end

function GameLayer:onCreateSchedule()       -- 创建定时器
    local isBreak0 = false
    local isBreak1 = true
------------------------------ 鱼队列 ------------------------------
    local function dealCanAddFish()     
        if isBreak0 then
            isBreak1 = false
            return
        end

        if #self._dataModel.m_waitList >= 5 then
            isBreak0 = true
            isBreak1 = false
            return
        end

        table.sort(self._dataModel.m_fishCreateList, function(a, b) return a.nProductTime < b.nProductTime end)

        local function isCanAddtoScene(data)
            local iscanadd = false
            local time = currentTime()
            if data.nProductTime <= time and data.nProductTime ~= 0  then
                iscanadd = true
                return iscanadd
            end
            return iscanadd
        end

        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey("game_res/fish_move1.png")
        local texture1 = cc.Director:getInstance():getTextureCache():getTextureForKey("game_res/fish_move2.png")
        local anim = cc.AnimationCache:getInstance():getAnimation("animation_fish_move26")
        if not texture or not texture1 or not anim then
            return
        end

        if 0 ~= #self._dataModel.m_fishCreateList  then
            local fishcount = #self._dataModel.m_fishCreateList      -- 每一帧最多刷鱼鱼数目
            if fishcount > 20 then
                fishcount = 20
            end

            for i=1,fishcount do
                local fishdata = self._dataModel.m_fishCreateList[1]
                table.remove(self._dataModel.m_fishCreateList,1)
                local iscanadd = isCanAddtoScene(fishdata)
                if iscanadd then
                    local fish =  g_var(Fish):create(fishdata,self)
                    if fish == nil then
                        return
                    end

                    if fish:initAnim() then
                        if fishdata.isSceneFish == true then
                            if fishdata.sceneKind == 1 then
                                if fishdata.sceneIndex  <= 200 then      -- 场景2的鱼群
                                    fish:setStopFishInTime(self.fishTrace.scene_kind_2_small_fish_stop_index_[fishdata.sceneIndex],self.fishTrace.scene_kind_2_small_fish_stop_count_)
                                else
                                    fish:setStopFishInTime(self.fishTrace.scene_kind_2_big_fish_stop_index_,self.fishTrace.scene_kind_2_big_fish_stop_count_)
                                end
                            end
                            fish:updateScheduleSceneFish(fishdata)
                        else 
                            fish:initWithType(fishdata,self,false)
                        end
                
                        fish:setTag(g_var(cmd).Tag_Fish)
                        fish:initWithState()
                        fish:initPhysicsBody()
                        self.m_fishLayer:addChild(fish, fish.m_data.fish_kind + 1)
                        self._dataModel.m_fishList[fish.m_data.fish_id] = fish
                    end
                else
                    table.insert(self._dataModel.m_waitList, fishdata)
                end
            end
        end 
    end
------------------------------ 等待队列 ------------------------------
    local function dealWaitList( )
        if isBreak1 then
            isBreak0 = false
            return
        end

        if #self._dataModel.m_waitList == 0 then
            isBreak0 = false
            isBreak1 = true
            return
        end

        if #self._dataModel.m_waitList ~= 0 then
            for i=1, #self._dataModel.m_waitList do
                local fishdata = self._dataModel.m_waitList[i]
                table.insert(self._dataModel.m_fishCreateList,1,fishdata)
            end
            self._dataModel.m_waitList = {}
        end
    end
------------------------------ 定位大鱼 ------------------------------
    local function selectMaxFish()
        if self._dataModel.m_autolock  then       -- 自动锁定
            local fish = self._dataModel.m_fishList[self._dataModel.m_fishIndex]
            if nil == fish then
                self._dataModel.m_fishIndex = self._dataModel:selectMaxFish()
                return
            end

            local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
            local pos = cc.p(fish:getPositionX(),fish:getPositionY()) 
            if not cc.rectContainsPoint(rect,pos) then
                self._dataModel.m_fishIndex = self._dataModel:selectMaxFish()
            end
        end
    end
------------------------------ 刷新函数 ------------------------------
    local function update(dt)
        selectMaxFish()       -- 筛选大鱼
        dealCanAddFish()      -- 能加入显示的鱼群
        dealWaitList()        -- 需等待的鱼群
    end
------------------------------ 游戏定时器 ------------------------------
	if nil == self.m_scheduleUpdate then
        self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
	end
end

function GameLayer:createSecoundSchedule() 
    local function setSecondTips()      -- 提示
        if nil == self._gameView:getChildByTag(10000) then 
            local tipBG = cc.Sprite:create("game_res/secondTip.png")
            tipBG:setPosition(667, 630)
            tipBG:setTag(10000)
            self._gameView:addChild(tipBG,100)

            local watch = cc.Sprite:createWithSpriteFrameName("watch_0.png")
            watch:setPosition(60, 45)
            tipBG:addChild(watch)

            local animation = cc.AnimationCache:getInstance():getAnimation("watchAnim")
            if nil ~= animation then
                watch:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
            end

            local time = cc.Label:createWithTTF(string.format("%d秒",self.m_nSecondCount), "fonts/round_body.ttf", 20)
            time:setTextColor(cc.YELLOW)
            time:setAnchorPoint(0.0,0.5)
            time:setPosition(117, 55)
            time:setTag(1)
            tipBG:addChild(time)

            local buttomTip = cc.Label:createWithTTF("60秒未开炮,即将退出游戏", "fonts/round_body.ttf", 20)
            buttomTip:setAnchorPoint(0.0,0.5)
            buttomTip:setPosition(117, 30)
            tipBG:addChild(buttomTip)
        else
            local tipBG = self._gameView:getChildByTag(10000)
            local time = tipBG:getChildByTag(1)
            time:setString(string.format("%d秒",self.m_nSecondCount))      
        end
    end

    local function removeTip()
        local tipBG = self._gameView:getChildByTag(10000)
        if nil ~= tipBG then
            tipBG:removeFromParent()
        end
    end

    local function update(dt)
        if self.m_nSecondCount == 0 then --发送起立
            removeTip()
            self:onKeyBack()
            return
        end

        if self.m_nSecondCount - 1 >= 0 then 
            self.m_nSecondCount = self.m_nSecondCount - 1
        end

        if self.m_nSecondCount <= 10 then
            setSecondTips()
        end
    end

    if nil == self.m_secondCountSchedule then
        self.m_secondCountSchedule = scheduler:scheduleScriptFunc(update, 1.0, false)
    end
end

function GameLayer:unSchedule()
    if nil ~= self.m_scheduleUpdate then        -- 游戏定时器
		scheduler:unscheduleScriptEntry(self.m_scheduleUpdate)
		self.m_scheduleUpdate = nil
	end

    if nil ~= self.m_secondCountSchedule then   -- 60秒倒计时定时器
        scheduler:unscheduleScriptEntry(self.m_secondCountSchedule)
        self.m_secondCountSchedule = nil
    end

    if nil ~= self.m_CircleFishesSchedule then 
        scheduler:unscheduleScriptEntry(self.m_CircleFishesSchedule)
        self.m_CircleFishesSchedule = nil
    end
end

function GameLayer:createCircleFishesSchedule()     -- 废弃掉
    local time =0
    local function update(dt)
        time = time + 1
        if time == 40  then
            time = 0
            self:onCircleFishCreate()
        end
    end
    if nil == self.m_CircleFishesSchedule then
        self.m_CircleFishesSchedule = scheduler:scheduleScriptFunc(update, 1.0, false)
    end
end

function GameLayer:onEnter()

end

function GameLayer:onEnterTransitionFinish()
    --AudioEngine.playMusic(g_var(cmd).Music_Back_1,true)
    self:addContact()     -- 碰撞监听
end

function GameLayer:onExit()
    print("gameLayer onExit()....")
    self.screenShake = nil
    
	cc.Director:getInstance():getEventDispatcher():removeEventListener(self.contactListener)    -- 移除碰撞监听
    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_LoadingFinish)
    self:unSchedule()     -- 释放游戏所有定时器
end

function GameLayer:onTouchBegan(touch, event)       -- 触摸事件
    return true
end

function GameLayer:onTouchMoved(touch, event)

end

function GameLayer:onTouchEnded(touch, event )
	
end

function GameLayer:onEventUserEnter( wTableID,wChairID,useritem )   -- 用户进入
    print("gameLayer onEventUserEnter()....")
    if wTableID ~= self.m_nTableID or  useritem.cbUserStatus == yl.US_LOOKON or not self.m_cannonLayer then
        return
    end

    self.m_cannonLayer:onEventUserEnter( wTableID,wChairID,useritem )
    --self:setUserMultiple()
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)  -- 用户状态
    print("gameLayer onEventUserStatus()....")
    if useritem.cbUserStatus == yl.US_LOOKON or not self.m_cannonLayer then
        return
    end
    self.m_cannonLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    --self:setUserMultiple()
end

function GameLayer:onEventUserScore(item)   -- 用户分数
    print("fishlk onEventUserScore...")
end

function GameLayer:showPopWait()            -- 显示等待
    if self._scene and self._scene.showPopWait then
        self._scene:showPopWait()
    end
end

function GameLayer:dismissPopWait()         -- 关闭等待
    if self._scene and self._scene.dismissPopWait then
        self._scene:dismissPopWait()
    end
end

function GameLayer:onInitData()             -- 初始化游戏数据

end

function GameLayer:onQueryExitGame()        -- 退出询问
    -- body
end

function GameLayer:onResetData()            -- 重置游戏数据
    -- body
end

function GameLayer:setUserMultiple()
    if not self.m_cannonLayer then
        return
    end

    for i=1,6 do       -- 设置炮台倍数
        local cannon = self.m_cannonLayer:getCannoByPos(i)
        local pos = i
        if nil ~= cannon then
            if self._dataModel.m_reversal then 
                pos = 6+1-i
            end
            cannon:setMultiple(self.min_bullet_multiple,pos-1)
        end
    end
end

function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)        -- 场景信息
    print("-----场景数据-----")

    if self.m_bScene then
        self:dismissPopWait()
        return
    end

    self.m_bScene = true
  	local systime = currentTime()
    self._dataModel.m_enterTime = systime
    self._dataModel.m_seceneStatus = ExternalFun.read_netdata(g_var(cmd).CMD_S_GameStatus,dataBuffer)
    self._dataModel.exchange_fish_score_ = self._dataModel.m_seceneStatus.exchange_fish_score[1]
    self._dataModel.fish_score_ = self._dataModel.m_seceneStatus.fish_score[1]
    self:dismissPopWait()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------   消息接收    -------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

function GameLayer:onEventGameMessage(sub,dataBuffer)       -- 游戏消息
    if nil == self._gameView  then
        return
    end 

    if sub == g_var(cmd).SUB_S_GAME_CONFIG then                     -- 游戏配置
        local event = cc.EventCustom:new(g_var(cmd).Event_FishCreate)   -- 通知
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
        self:onSubGameConfig(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_FISH_TRACE then                  -- 创建鱼
        if self.m_isSceneChanging == true then
            return
        end
        self._gameView:removeImgChangeScene()
        if math.mod(dataBuffer:getlen(),56) == 0 then 
            self:onSubFishCreate(dataBuffer)                        -- 鱼创建
        end
    elseif sub == g_var(cmd).SUB_S_EXCHANGE_FISHSCORE then          -- 上下分
        self:onSubExchangeFishScore(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_USER_FIRE then                   -- 开炮
        self:onSubFire(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_CATCH_FISH	then                -- 捕获鱼
        self:onSubFishCatch(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_CATCH_SWEEP_FISH then            -- 捕获超级炸弹
        self:onSubCatchSweepFish(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_CATCH_SWEEP_FISH_RESULT then     -- 超级炸弹的捕获结果
        self:onSubCatchSweepFishResult(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_SWITCH_SCENE then                -- 场景切换
        self.m_isSceneChanging = true 
        self:onSubExchangeScene(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_SCENE_END then                   -- 场景结束
        self.m_isSceneChanging = false
    elseif sub == g_var(cmd).SUB_S_TREASURE_BOX_RESULT then
        self:onSubTreasureBoxResult(dataBuffer)
    elseif sub == g_var(cmd).SUB_S_FISH_OUT then
        self:onSubFishOut(dataBuffer)
    --elseif sub == g_var(cmd).SUB_S_CIRCLE_FIRSH then                -- 小场景鱼
    --    self:onCircleFishCreate(dataBuffer)
    --elseif sub == g_var(cmd).SUB_S_BULLETSPEED_INDEX then           -- 子弹档位
    --    self:onSubBulletSpeedIndex(dataBuffer)
    else

    end
end

function GameLayer:onSubGameConfig( databuffer )    -- 游戏配置
    print("---------游戏配置---------")
    local gameConfig = ExternalFun.read_netdata(g_var(cmd).CMD_S_GameConfig,databuffer)
    self.exchange_ratio_userscore = gameConfig.exchange_ratio_userscore
    self.exchange_ratio_fishscore = gameConfig.exchange_ratio_fishscore
    self.exchange_count = gameConfig.exchange_count
    self.min_bullet_multiple = gameConfig.min_bullet_multiple
    self.max_bullet_multiple = gameConfig.max_bullet_multiple
    self.fish_speed = gameConfig.fish_speed[1]
    self.bullet_speed = gameConfig.bullet_speed[1]
    self.nFishMultiple = gameConfig.fish_multiple[1]
    --self:BuildSceneKindTrace()
end

function GameLayer:onSubFishCreate( dataBuffer )    -- 创建鱼
    -- print("鱼创建")
    local fishNum = math.floor(dataBuffer:getlen()/56)
    if fishNum >= 1 then
        for i=1,fishNum do
            local FishCreate =   ExternalFun.read_netdata(g_var(cmd).CMD_S_FishTrace,dataBuffer)
            local function dealproducttime ()
                local entertime = self._dataModel.m_enterTime
                local productTime = entertime + FishCreate.unCreateTime
                return productTime 
            end

            FishCreate.nProductTime = 1
            FishCreate.isSceneFish = false
            table.insert(self._dataModel.m_fishCreateList, FishCreate)

            if FishCreate.fish_kind >= g_var(cmd).FishKind.FISH_KIND_18 and FishCreate.fish_kind <= g_var(cmd).FishKind.FISH_KIND_20 then
                if self:getChildByName("groupTipsFish") then
                    self:removeChildByName("groupTipsFish")
                end
                local groupTips
                if FishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_18 then
                    groupTips = ccui.ImageView:create("game_res/fish_luzhishen.png")
                elseif FishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_19 then
                    groupTips = ccui.ImageView:create("game_res/fish_jinglong.png")
                elseif FishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_20 then
                    groupTips = ccui.ImageView:create("game_res/fish_bawangji.png")
                elseif FishCreate.fish_kind == g_var(cmd).FishKind.FISH_KIND_21 then
                    groupTips = ccui.ImageView:create("game_res/fish_likui.png")
                end
                groupTips:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
                groupTips:setName("groupTipsFish")
                self._gameView:addChild(groupTips,30)
                local callFunc = cc.CallFunc:create(function()
                    groupTips:removeFromParent() 
                end)
                groupTips:runAction(cc.Sequence:create(cc.DelayTime:create(2),callFunc))
            end
        end
    end
    dataBuffer = nil
end

function GameLayer:onSubExchangeFishScore( databuffer )     -- 上下分
    local cmdExchangeFishScore = ExternalFun.read_netdata(g_var(cmd).CMD_S_ExchangeFishScore,databuffer)
    local cannonPos = cmdExchangeFishScore.chair_id
    if self._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end
    local exchange_fish_score_ = self._dataModel.exchange_fish_score_[cmdExchangeFishScore.chair_id + 1]
    self._dataModel.exchange_fish_score_[cmdExchangeFishScore.chair_id + 1] = cmdExchangeFishScore.exchange_fish_score
    self._dataModel.fish_score_[cmdExchangeFishScore.chair_id + 1] = self._dataModel.fish_score_[cmdExchangeFishScore.chair_id + 1] + cmdExchangeFishScore.swap_fish_score
    if self._dataModel.fish_score_[cmdExchangeFishScore.chair_id + 1] < 0 then
        self._dataModel.fish_score_[cmdExchangeFishScore.chair_id + 1] = 0
    end

    if self.m_cannonLayer then
        self.m_cannonLayer:updateUserScore(self._dataModel.fish_score_[cmdExchangeFishScore.chair_id + 1],cannonPos + 1)
    end
    
    if cmdExchangeFishScore.chair_id == self.m_nChairID then
        self._dataModel.m_lUserScore = self._dataModel.m_lUserScore - (cmdExchangeFishScore.swap_fish_score / self.exchange_ratio_fishscore *self.exchange_ratio_userscore )
        self._gameView:updateUserScore(self._dataModel.m_lUserScore)
    end
end

function GameLayer:onSubFire(databuffer)        -- 开炮13850067197
    if not self.m_cannonLayer  then
        dataBuffer = nil
        return
    end

    local fire =  ExternalFun.read_netdata(g_var(cmd).CMD_S_Fire,databuffer)
    --print("开炮.............................:"..fire.bullet_id)
    if fire.chair_id == self.m_nChairID then
        return
    end

    local cannonPos = fire.chair_id
    if self._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end

    local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)
    if nil ~= cannon then
        cannon:othershoot(fire)
    end
    dataBuffer = nil
end

function GameLayer:onSubFishCatch( databuffer )     -- 捕获鱼
    if not self.m_cannonLayer  then
        return
    end
    
    local catchNum = math.floor(databuffer:getlen()/19)

    if catchNum >= 1 then
        for i=1,catchNum do
            local catchData = ExternalFun.read_netdata(g_var(cmd).CMD_S_CatchFish,databuffer)
            local fish = self._dataModel.m_fishList[catchData.fish_id]

            if ((catchData.fish_kind >= g_var(cmd).FishKind.FISH_KIND_16 and catchData.fish_kind <= g_var(cmd).FishKind.FISH_KIND_21) or
                (catchData.fish_kind >= g_var(cmd).FishKind.FISH_KIND_25 and catchData.fish_kind <= g_var(cmd).FishKind.FISH_KIND_30)) then

                local bHaveBingo = false
                for i = 1, #self.bingo_list do
                    if self.bingo_list[i]:getChairID() == catchData.chair_id then
                        bHaveBingo = true
                        self.bingo_list[i]:setVisible(true)
                        self.bingo_list[i]:showScore(catchData.chair_id, catchData.fish_score)
                    end
                end
                
                if bHaveBingo == false then
                    local tempBingo = g_var(Bingo):create(self)
                    tempBingo:showScore(catchData.chair_id, catchData.fish_score)
                    self._gameView:addChild(tempBingo, 6)
                    table.insert(self.bingo_list, tempBingo)
                end
            end

            if nil ~= fish then
                local random = math.random(5)
                local smallSound = string.format("sound_res/samll_%d.wav", random)  
                local bigSound = string.format("sound_res/big_%d.wav", fish.m_data.fish_kind)

                if fish.m_data.fish_kind <  g_var(cmd).FISH_KING_MAX then
                    self._dataModel:playEffect(smallSound)
                else
                    self._dataModel:playEffect(bigSound)
                end

                local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
  
                if self._dataModel.m_reversal then 
                    fishPos = cc.p(yl.WIDTH-fishPos.x,yl.HEIGHT-fishPos.y)
                end

                if fish.m_data.fish_kind > g_var(cmd).FishType.FishType_JianYu then
                    self._dataModel:playEffect(g_var(cmd).CoinLightMove)
                    if self.screenShake and GlobalUserItem.bShake == 1 then
                        self.screenShake:stop()
                        self.screenShake:run()
                    end
                    local praticle = cc.ParticleSystemQuad:create("particle/yanhua_l.plist")
                    praticle:setPosition(fishPos)
                    praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
                    self._gameView:addChild(praticle,3)
                    local call = cc.CallFunc:create(function()
                        praticle:removeFromParent()
                    end)
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),call))
                end

                if catchData.chair_id == self.m_nChairID and  (fish.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_20 or fish.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_23 or fish.m_data.fish_kind == g_var(cmd).FishKind.FISH_KIND_19) then
                    self._dataModel:playEffect(g_var(cmd).bigCoins)
                    if self.screenShake and GlobalUserItem.bShake == 1 then
                        self.screenShake:stop()
                        self.screenShake:run()
                    end
                    local praticle = cc.ParticleSystemQuad:create("particle/bigwin_blowout_1.plist")
                    praticle:setPosition(cc.p(yl.WIDTH / 2,yl.HEIGHT / 2))
                    praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
                    self._gameView:addChild(praticle,3)
                    local call = cc.CallFunc:create(function()
                        if praticle then
                            praticle:removeFromParent()
                        end
                    end)
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),call))
                end
                local fishtype = fish.m_data.fish_kind
                fish:deadDeal()     -- 鱼死亡处理
                
                local call = cc.CallFunc:create(function()      -- 金币动画
                    self._gameView:ShowCoin1(catchData.fish_score, catchData.chair_id, fishPos, fishtype)
                end)
                self:runAction(call)
            end
            
            local cannonPos = catchData.chair_id    -- 获取炮台视图位置
            if self._dataModel.m_reversal then 
                cannonPos = 5 - cannonPos
            end

            if catchData.chair_id == self.m_nChairID then   --自己
                self._dataModel.fish_score_[catchData.chair_id + 1] = self._dataModel.fish_score_[catchData.chair_id + 1] + catchData.fish_score
                self.m_cannonLayer:updateUserScore( self._dataModel.fish_score_[catchData.chair_id + 1],cannonPos+1 )   -- 更新用户分数
                self._dataModel.m_getFishScore = self._dataModel.m_getFishScore + catchData.fish_score                  -- 捕获鱼收获
                self.m_cannonLayer:setFishScore(catchData.fish_score, cannonPos+1 )   -- 捕获鱼收获
                if nil ~= fish then     -- 捕鱼数量
                    local fishtype = fish.m_data.fish_kind
                    if fishtype <= 21 then 
                        self.m_catchFishCount[fishtype+1] = self.m_catchFishCount[fishtype+1] + 1
                    end
                end
            else    -- 其他玩家
                local userid = self.m_cannonLayer:getUserIDByCannon(cannonPos+1)    -- 获取用户
                self._dataModel.fish_score_[catchData.chair_id + 1] = self._dataModel.fish_score_[catchData.chair_id + 1] + catchData.fish_score
                self.m_cannonLayer:updateUserScore( self._dataModel.fish_score_[catchData.chair_id + 1],cannonPos+1 )   -- 更新用户分数
                self.m_cannonLayer:setFishScore(catchData.fish_score, cannonPos+1 )   -- 捕获鱼收获
                for k,v in pairs(self.m_cannonLayer._userList) do
                    local item = v
                    if item.dwUserID == userid  then
                        break
                    end
                end
            end
        end
    end
end

function GameLayer:onSubCatchSweepFish(databuffer)      -- 捕获超级炸弹
    local cmdCatchSweepFish = ExternalFun.read_netdata(g_var(cmd).CMD_S_CatchSweepFish,databuffer)
    local fish = self._dataModel.m_fishList[cmdCatchSweepFish.fish_id]
    if nil ~= fish then 
        self._dataModel:playEffect("sound_res/bcombo.wav")
        local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
        if self._dataModel.m_reversal then 
            fishPos = cc.p(yl.WIDTH-fishPos.x,yl.HEIGHT-fishPos.y)
        end
        if fish.m_data.fish_kind > g_var(cmd).FishType.FishType_JianYu then
            self._dataModel:playEffect(g_var(cmd).CoinLightMove)
            local praticle = cc.ParticleSystemQuad:create("particle/yanhua_l.plist")
            praticle:setPosition(fishPos)
            praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
            self._gameView:addChild(praticle,3)
            local call = cc.CallFunc:create(function()
                praticle:removeFromParent()
            end)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(2),call))
        end
            
        fish:deadDeal()     -- 鱼死亡处理
        self:sendCatchSweepFish(cmdCatchSweepFish.fish_id,fishPos,fish.m_data.fish_kind,cmdCatchSweepFish.chair_id)
    end
end

function GameLayer:onSubCatchSweepFishResult(databuffer)        -- 捕获超级炸弹
    local catchData = ExternalFun.read_netdata(g_var(cmd).CMD_S_CatchSweepFishResult,databuffer)
    for i = 1,catchData.catch_fish_count do
        local fish = self._dataModel.m_fishList[catchData.catch_fish_id[1][i]]
        if nil ~= fish then
            local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
            if self._dataModel.m_reversal then 
                fishPos = cc.p(yl.WIDTH-fishPos.x,yl.HEIGHT-fishPos.y)
            end

            if fish.m_data.fish_kind > g_var(cmd).FishType.FishType_JianYu then
                local praticle = cc.ParticleSystemQuad:create("particle/yanhua_l.plist")
                praticle:setPosition(fishPos)
                praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
                self._gameView:addChild(praticle,3)
                local call = cc.CallFunc:create(function()
                       praticle:removeFromParent()
                end)
                self:runAction(cc.Sequence:create(cc.DelayTime:create(2),call))
            end

            local fishtype = fish.m_data.fish_kind
            local fishScore = self.nFishMultiple[fish.m_data.fish_kind + 1];
            local cannonPos = catchData.chair_id

            if self._dataModel.m_reversal then 
                cannonPos = 5 - cannonPos
            end

            local bulletMutiple = self.min_bullet_multiple;

            if self.m_cannonLayer:getCannon(cannonPos+1) then
                bulletMutiple = self.m_cannonLayer:getCannon(cannonPos+1).m_bulletMutiple;
            end

            if catchData.chair_id == self.m_nChairID then
                bulletMutiple = self._dataModel.m_currentMutiple
            end
            
            fish:deadDeal()     -- 鱼死亡处理
            
            local call = cc.CallFunc:create(function()
                self._gameView:ShowCoin1(fishScore*bulletMutiple, catchData.chair_id, fishPos, fishtype)    -- 金币动画
            end)

            self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),call))

            if catchData.chair_id == self.m_nChairID then   --自己
                if fishtype <= 21 then      -- 捕鱼数量
                    self.m_catchFishCount[fishtype+1] = self.m_catchFishCount[fishtype+1] + 1
                end
            end
        end
    end

    if catchData.chair_id == self.m_nChairID  then
        self._dataModel:playEffect(g_var(cmd).bigCoins)
        local praticle = cc.ParticleSystemQuad:create("particle/bigwin_blowout_1.plist")
        praticle:setPosition(cc.p(yl.WIDTH / 2,yl.HEIGHT / 2))
        praticle:setPositionType(cc.POSITION_TYPE_GROUPED)
        self._gameView:addChild(praticle,3)
        local call = cc.CallFunc:create(function()
            if praticle then
                praticle:removeFromParent()
            end
        end)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2),call))
    end
        
    local cannonPos = catchData.chair_id        -- 获取炮台视图位置

    if self._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end
    
    if catchData.chair_id == self.m_nChairID then   -- 自己
        self._dataModel.fish_score_[catchData.chair_id + 1] = self._dataModel.fish_score_[catchData.chair_id + 1] + catchData.fish_score
        self.m_cannonLayer:updateUserScore( self._dataModel.fish_score_[catchData.chair_id + 1],cannonPos+1 )       -- 更新用户分数
        self._dataModel.m_getFishScore = self._dataModel.m_getFishScore + catchData.fish_score                      -- 捕获鱼收获
    else                                            -- 其他玩家
        if self.m_cannonLayer == nil then
            return
        end

        local userid = self.m_cannonLayer:getUserIDByCannon(cannonPos+1)

        for k,v in pairs(self.m_cannonLayer._userList) do
            local item = v
            if item.dwUserID == userid  then
                self._dataModel.fish_score_[catchData.chair_id + 1] = self._dataModel.fish_score_[catchData.chair_id + 1] + catchData.fish_score
                self.m_cannonLayer:updateUserScore( self._dataModel.fish_score_[catchData.chair_id + 1],cannonPos+1 )   -- 更新用户分数
                break
            end
        end
    end
end

function GameLayer:onSubExchangeScene(dataBuffer)     -- 切换场景
    print("场景切换")
    self._dataModel:playEffect(g_var(cmd).Change_Scene)
    local systime = currentTime()
    self._dataModel.m_enterTime = systime
    self._dataModel._exchangeSceneing = true
    local exchangeScene = ExternalFun.read_netdata(g_var(cmd).CMD_S_SwitchScene,dataBuffer)
    self._gameView:updteBackGround(exchangeScene.scene_kind)
    local callfunc = cc.CallFunc:create(function()
        self._dataModel._exchangeSceneing = false
        for k,v in pairs(self._dataModel.m_fishList) do
            local fish = v
		    if nil ~= fish then
                fish:removeFishFromParent()
            end
	    end
        for i = 1, exchangeScene.fish_count do
            local sceneFish = {}
            sceneFish.trace_type = g_var(cmd).TraceType.TRACE_LINEAR
            sceneFish.fish_id = exchangeScene.fish_id[1][i]
            sceneFish.fish_kind = exchangeScene.fish_kind[1][i]
            sceneFish.init_count = 1
            sceneFish.nProductTime = 1
            sceneFish.isSceneFish = true
            sceneFish.sceneKind = exchangeScene.scene_kind
            sceneFish.init_pos = {{{},{},{},{},{}}}

            if exchangeScene.scene_kind == 0 then
                sceneFish.init_pos[1] = self.fishTrace.scene_kind_1_trace_[i]
            elseif exchangeScene.scene_kind == 1 then
                sceneFish.init_pos[1] = self.fishTrace.scene_kind_2_trace_[i]
                sceneFish.sceneIndex = i
            elseif exchangeScene.scene_kind == 2 then
                sceneFish.init_pos[1] = self.fishTrace.scene_kind_3_trace_[i]
            elseif exchangeScene.scene_kind == 3 then
                sceneFish.init_pos[1] = self.fishTrace.scene_kind_4_trace_[i]
            elseif exchangeScene.scene_kind == 4 then
                sceneFish.init_pos[1] = self.fishTrace.scene_kind_5_trace_[i]
            end
            
            table.insert(self._dataModel.m_fishCreateList, sceneFish)
        end
    end)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(8.0),callfunc)) 
end

function GameLayer:onSubTreasureBoxResult(dataBuffer)
    local boxResult = ExternalFun.read_netdata(g_var(cmd).CMD_S_TreasureBoxResult,dataBuffer)
end

function GameLayer:onSubFishOut(dataBuffer)
    local fishOut = ExternalFun.read_netdata(g_var(cmd).CMD_S_Fishout,dataBuffer)
end

function GameLayer:onCircleFishCreate(databuffer)
    local circleFishData = ExternalFun.read_netdata(g_var(cmd).CMD_S_CircleFish,databuffer)
    local winSize = cc.Director:getInstance():getWinSize()
    local kind = circleFishData.fish_kind
    local offsetx = winSize.width / 2 + circleFishData.offsetx
	local offsety = winSize.height / 2 + circleFishData.offsety
    local perCircleFishNum = circleFishData.fish_count / 3;
    for i = 1, circleFishData.fish_count do
        local sceneFish = {}
        sceneFish.trace_type = g_var(cmd).TraceType.TRACE_LINEAR
        sceneFish.fish_id = circleFishData.fish_id[1][i]
        sceneFish.fish_kind = kind
        sceneFish.init_count = 1
        sceneFish.nProductTime = 1
        sceneFish.isSceneFish = false
        sceneFish.init_pos = {{{},{},{},{},{}}}
        sceneFish.init_pos[1][1].x = offsetx
        sceneFish.init_pos[1][1].y = offsety
        sceneFish.init_pos[1][2].x = 0
        sceneFish.init_pos[1][2].y = 0
        local posT = self.fishTrace:GetTargetPoint(winSize.width,winSize.height,offsetx,offsety,(i % perCircleFishNum)*20 * 3.1415926 / 180,sceneFish.init_pos[1][3].x,sceneFish.init_pos[1][3].y)
        sceneFish.init_pos[1][3].x = posT[1]
        sceneFish.init_pos[1][3].y = posT[2]
        local function createFish()
            local fish =  g_var(Fish):create(sceneFish,self)
            if fish == nil then
                return
            end

            if fish:initAnim() then
                fish:initCircleFish(sceneFish,self)
                fish:setTag(g_var(cmd).Tag_Fish)
                fish:initWithState()
                fish:initPhysicsBody()
                self.m_fishLayer:addChild(fish, i)
                fish:setOpacity(0)
                self._dataModel.m_fishList[fish.m_data.fish_id] = fish      -- 添加到鱼队列中
                local function setOpacity()
                    fish:setOpacity(255)
                end
                local time  = 0
                if i % perCircleFishNum == 0 then
                    time = 0.2*perCircleFishNum
                else
                    time = 0.2*(i%perCircleFishNum)
                end
                local action = cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(setOpacity))
                fish:runAction(action)
            end
        end
        
        local action = nil
        if i <= perCircleFishNum  then
            action = cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(createFish)) 
        elseif i > perCircleFishNum and i <= perCircleFishNum*2 then
            action = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(createFish)) 
        else
            action = cc.Sequence:create(cc.DelayTime:create(6),cc.CallFunc:create(createFish))
        end  
        self:runAction(action)
    end
end

function GameLayer:onSubBulletSpeedIndex(databuffer)        -- 子弹档位
    local bulletSpeedData = ExternalFun.read_netdata(g_var(cmd).CMD_S_BulletSpeedIndex,databuffer)
    self._dataModel.bullet_speed_index_ = bulletSpeedData.bulletSpeedIndex[1]
    self._gameView:updateBulletSpeedIndexImg()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------   消息发送    -------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

function GameLayer:sendCatchSweepFish(sweepFishId,targetFishPos,fishKind,chairId)
    local fishNum = 0
    local fishList = {}
    for k,v in pairs(self._dataModel.m_fishList) do
        local fish = self._dataModel.m_fishList[k]
        if nil ~= fish and nil ~= fish.m_data and fish._bFishInView then
            if  fish.m_data.nFishKey ~= sweepFishId then
                if fishKind ~= g_var(cmd).FishKind.FISH_KIND_24 and fish.m_data.fish_kind == (fishKind - g_var(cmd).FishKind.FISH_KIND_31) then
                    table.insert(fishList,fish)
                    local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
                    if self._dataModel.m_reversal then 
                        fishPos = cc.p(yl.WIDTH-fishPos.x,yl.HEIGHT-fishPos.y)
                    end
                    self._gameView:showLight2(fishPos.x,fishPos.y,targetFishPos.x,targetFishPos.y)
                elseif fishKind == g_var(cmd).FishKind.FISH_KIND_23 then
                    local fishPos = cc.p(fish:getPositionX(),fish:getPositionY())
                    local distance =  math.sqrt((fishPos.x - targetFishPos.x) * (fishPos.x - targetFishPos.x) + (fishPos.y - targetFishPos.y) * (fishPos.y - targetFishPos.y))
                    if distance < cc.Director:getInstance():getWinSize().width / 6  then
                        table.insert(fishList,fish)
                    end
                elseif fishKind == g_var(cmd).FishKind.FISH_KIND_24 then
                    table.insert(fishList,fish)
                end 
            end
        end  
    end

    local fishCount = #fishList

    if fishCount == 0 then
        return
    end

    local cmddata = CCmd_Data:create(1210)
   	cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_CATCH_SWEEP_FISH);
    cmddata:pushword(chairId)
    cmddata:pushint(sweepFishId)
    cmddata:pushint(fishCount)

    for i=1,fishCount do
	    cmddata:pushint(fishList[i].nFishKey) 
    end

    if not self._gameFrame then
        return
    end
    
	if not self._gameFrame:sendSocketData(cmddata) then     -- 发送失败
		--self._gameFrame._callBack(-1,"发送捕鱼信息失败")
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------   消息发送    -------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

function GameLayer:onSubAwardTip( databuffer )      -- 获取奖励提示
    local award = ExternalFun.read_netdata(g_var(cmd).CMD_S_AwardTip,databuffer)
    --dump(award, "award is =================================", 6)
    local mutiple = award.nFishMultiple

    if mutiple>=50 or (award.nFishType==19 and award.nScoreType==g_var(cmd).SupplyType.EST_Cold and award.wChairID==self.m_nChairID) then
        self._gameView:ShowAwardTip(award)
    end
end

function GameLayer:onSubMultiple( databuffer )      -- 倍数
    local mutiple = ExternalFun.read_netdata(g_var(cmd).CMD_S_Multiple,databuffer)
    local cannonPos = mutiple.wChairID
    if self._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end
 
    if nil ~= self.m_cannonLayer then
        local cannon = self.m_cannonLayer:getCannoByPos(cannonPos + 1)

        if nil == cannon then
            return
        end

        cannon:setMultiple(mutiple.nMultipleIndex)
    end
 
    self._dataModel.m_secene.nMultipleIndex[1][mutiple.wChairID + 1] = mutiple.nMultipleIndex

    if mutiple.wChairID == self.m_nChairID then 
        self._gameView:updateMultiple(self._dataModel.m_secene.nMultipleValue[1][mutiple.nMultipleIndex+1])
    end
end

function GameLayer:onSubUpdateGame( databuffer )        -- 更新游戏119
    local update = ExternalFun.read_netdata(g_var(cmd).CMD_S_UpdateGame,databuffer)
    self._dataModel.m_secene.nBulletVelocity = update.nBulletVelocity
    self._dataModel.m_secene.nBulletCoolingTime = update.nBulletCoolingTime
    self._dataModel.m_secene.nFishMultiple = update.nFishMultiple
    self._dataModel.m_secene.nMultipleValue = update.nMultipleValue
end

function GameLayer:onSubStayFish( databuffer )      -- 停留鱼
    local stay = ExternalFun.read_netdata(g_var(cmd).CMD_S_StayFish,databuffer)
    local fish = self._dataModel.m_fishList[stay.nFishKey]
    if nil ~= fish then
        fish:Stay(stay.nStayTime)
    end
end

function GameLayer:onSubSupply(databuffer )         -- 补给
  
end

function GameLayer:onSubSynchronous( databuffer )   -- 同步时间
    print("同步时间")
    self.m_bSynchronous = true
    local synchronous = ExternalFun.read_netdata(g_var(cmd).CMD_S_FishFinish,databuffer)
    if 0 ~= synchronous.nOffSetTime then
        print("同步时间1")
        local offtime = synchronous.nOffSetTime
        self._dataModel.m_enterTime = self._dataModel.m_enterTime - offtime
    end
end

function GameLayer:onSocketInsureEvent(sub,dataBuffer)    -- 银行 
    print(sub)
    self:dismissPopWait()
    if sub == g_var(game_cmd).SUB_GR_USER_INSURE_SUCCESS then
        local cmd_table = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureSuccess, dataBuffer)
        self.bank_success = cmd_table
        self._gameView:onBankSuccess()
    elseif sub == g_var(game_cmd).SUB_GR_USER_INSURE_FAILURE then
        local cmd_table = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureFailure, dataBuffer)
        self.bank_fail = cmd_table
        self._gameView:onBankFailure()
    else
        print("unknow gamemessage sub is ==>"..sub)
    end
end

function GameLayer:onExitTable()
    self._scene:onKeyBack()
end

function GameLayer:onKeyBack()
    self._gameView:StopLoading(false)
    self._gameFrame:StandUp(1)
    return true
end

function GameLayer:standUpAndQuit()
    self._gameView:StopLoading(false)
    self._gameFrame:StandUp(1)
end

function GameLayer:getDataMgr()
    return self._dataModel;
end

function GameLayer:sendNetData(cmddata)
    return self._gameFrame:sendSocketData(cmddata);
end

return GameLayer