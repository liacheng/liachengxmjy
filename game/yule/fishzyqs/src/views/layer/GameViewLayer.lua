--
-- Author: Tang
-- Date: 2016-08-09 14:46:36
--
local GameViewLayer = class("GameViewLayer", function(scene)
    local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

--Tag
GameViewLayer.VIEW_TAG = 
{
    tag_bg                  = 200,
    tag_autoshoot           = 210,
    tag_autolock            = 211,
    tag_gameScore           = 212,
    tag_gameMultiple        = 213,
    tag_grounpTips          = 214,
    tag_bulletSpeedIndex    = 215,
    tag_imgSceneChange      = 216,
    tag_speedUp             = 217,
    tag_GoldCycle           = 3000,
    tag_GoldCycleTxt        = 4000,
    tag_Menu                = 5000,
    tag_ShrinkMenu          = 6000
}

local TAG = GameViewLayer.VIEW_TAG
GameViewLayer.RES_PATH = device.writablePath.. "game/yule/fishzyqs/res/"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local module_pre = "game.yule.fishzyqs.src"	
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local PRELOAD = require(module_pre..".views.layer.PreLoading") 
local cmd = module_pre .. ".models.CMD_ZYQSGame"

function GameViewLayer:ctor( scene )
    self._tag = 0
    self._tagvoice = 0
	self._scene = scene
	self:addSerchPaths()
    self.M_PI = 3.14159265358979323846
    self.M_PI_2 = 1.57079632679489661923
    self.m_Inbackground = false
    self.m_setAutoShoot = false
    PRELOAD.loadTextures(scene)                 -- 预加载资源
    ExternalFun.registerTouchEvent(self,true)   -- 注册事件
end

function GameViewLayer:onEnter( )
    --print("------GameViewLayer:onEnter-------")
end

function GameViewLayer:onExit()
    PRELOAD.unloadTextures()
    PRELOAD.removeAllActions()
    PRELOAD.resetData()
    self:StopLoading(true)
    ExternalFun.playPlazzBackgroudAudio()       -- 播放大厅背景音乐
--    ExternalFun.clearSound()
    --重置搜索路径
    if self._gameAddSearchPath then
        ExternalFun.removeSearchPath(self._gameAddSearchPath)
        self._gameAddSearchPath = nil
    end
end

function GameViewLayer:StopLoading( bRemove )
    PRELOAD.StopAnim(bRemove)
end

function GameViewLayer:getDataMgr( )
    return self:getParentNode():getDataMgr()
end

function GameViewLayer:getParentNode( )
    return self._scene;
end

function GameViewLayer:addSerchPaths( )
    local gameList = self._scene._scene:getApp()._gameList; -- 搜索路径
    local gameInfo = {};
    for k,v in pairs(gameList) do
        if tonumber(v._KindID) == tonumber(g_var(cmd).KIND_ID) then
            gameInfo = v;
            break;
        end
    end

    if nil ~= gameInfo._KindName then
        local searchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/"
        self._gameAddSearchPath = ExternalFun.addSearchPath(searchPath)
    end
end

function GameViewLayer:initView( )
    local xoffset = 0
--    local xexcursion = (yl.WIDTH - 1334)/2
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_IPHONE == targetPlatform and yl.WIDTH == 1624 then
        xoffset = 60
    end
    if self._scene._dataModel.m_scene_kind ==  nil then
        self._scene._dataModel.m_scene_kind =  0
    end

    local bgres = string.format("game_res/game_bg_%d.png",self._scene._dataModel.m_scene_kind)
    local bg =  ccui.ImageView:create(bgres)

    bg:setAnchorPoint(cc.p(.5,.5))
    bg:setTag(TAG.tag_bg)
	bg:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	self:addChild(bg)

    --底栏菜单栏
--    local menuBG = cc.Sprite:create("game_res/game_buttom.png")
--    menuBG:setAnchorPoint(0.5,0.0)
--    menuBG:setPosition(yl.WIDTH/2 ,-6)
--    menuBG:setScaleY(0.9)
--    self:addChild(menuBG,20)

--    local bgScore = cc.Sprite:create("game_res/bgScore.png")
--底部框隐藏
--    local bgScore = display.newSprite("#zyqs_bg_lowarticle.png")
--    bgScore:setAnchorPoint(0.5,0.0)
--    bgScore:setPosition(150, -6)
--    bgScore:setScaleX(40)
--    self:addChild(bgScore,20)


    --底部昵称背景
--    local bgname = display.newSprite("#zyqs_bg_name.png")
--    bgname:setAnchorPoint(0.5,0.0)
--    bgname:setPosition(230, 9)
--    self:addChild(bgname,20)

--    local bgnameicon = display.newSprite("#zyqs_icon_name.png")
--    bgnameicon:setAnchorPoint(0.5,0.0)
--    bgnameicon:setPosition(210-85, 11)
--    self:addChild(bgnameicon,20)

    --底部分数背景
--    local bgScoreback = display.newSprite("#zyqs_bg_name.png")
--    bgScoreback:setAnchorPoint(0.5,0.0)
--    bgScoreback:setPosition(472, 9)
--    self:addChild(bgScoreback,20)

--    local bgScorebackicon = display.newSprite("#zyqs_icon_coin.png")
--    bgScorebackicon:setAnchorPoint(0.5,0.0)
--    bgScorebackicon:setPosition(452-85, 8)
--    self:addChild(bgScorebackicon,20)

--底部框隐藏

--    local bgMutiple = cc.Sprite:create("game_res/bgMutiple.png")
--    bgMutiple:setAnchorPoint(0.5,0.0)
--    bgMutiple:setPosition(430,0)
--    bgMutiple:setScaleY(0.9)
--    self:addChild(bgMutiple,20)
    --子弹的档位
    local btnBulletSpeed = ccui.Button:create("game_res/btnBulletSpeed_1.png","game_res/btnBulletSpeed_1.png")
    btnBulletSpeed:setAnchorPoint(0.5,0.5)
    btnBulletSpeed:setTag(TAG.tag_bulletSpeedIndex)
    btnBulletSpeed:setPressedActionEnabled(true)
    btnBulletSpeed:addTouchEventListener(function( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            local bulletSpeedIndex = self._scene._dataModel.bullet_speed_index_[self._scene.m_nChairID + 1]
            if bulletSpeedIndex >= 5 then
                bulletSpeedIndex = 1
            else
                bulletSpeedIndex = bulletSpeedIndex + 1
            end
            
            self._scene.m_cannonLayer:onChangeSchedule(bulletSpeedIndex)    -- 子弹发射间隔
            --local cmddata = CCmd_Data:create(4)
   	        --cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_BULLETSPEED_INDEX);
            --cmddata:pushint(bulletSpeedIndex)
            
	        --if not self._scene:sendNetData(cmddata) then        -- 发送失败

	        --end
        end
    end)
    btnBulletSpeed:setPosition(50, yl.HEIGHT/2 + 150)
    --self:addChild(btnBulletSpeed,21)

    self._scene._dataModel.m_currentMutiple = self._scene.min_bullet_multiple

    for i =1,6  do
        self._scene._dataModel.m_userCurrentMutiple[i] = self._scene.min_bullet_multiple
    end
    


    --[[self.btnAdd = ccui.Button:create("zyqs_btn_addgun.png","zyqs_btn_addgun.png","zyqs_btn_addgun.png",UI_TEX_TYPE_PLIST)
    self.btnAdd:setPressedActionEnabled(true)
    self:addChild(self.btnAdd,22)

    self.btnMinus = ccui.Button:create("zyqs_btn_deletegun.png","zyqs_btn_deletegun.png","zyqs_btn_deletegun.png",UI_TEX_TYPE_PLIST)
    self.btnMinus:setPressedActionEnabled(true)
    self:addChild(self.btnMinus,22)--]]

--    self.btnAdd:setPosition(yl.WIDTH - 164-xoffset, 300)
--    self.btnMinus:setPosition(yl.WIDTH - 64-xoffset, 200)

        --[[if self._scene.m_nChairID == 0 then
            self.btnAdd:setPosition(1102+xexcursion, 27)
            self.btnMinus:setPosition(1100-192+xexcursion, 27)
        elseif self._scene.m_nChairID == 1 then
            self.btnAdd:setPosition(642+xexcursion, 27)
            self.btnMinus:setPosition(635-192+5+xexcursion, 27)
        elseif self._scene.m_nChairID == 2 then
            self.btnAdd:setPosition(199+xexcursion, 27)
            self.btnMinus:setPosition(207-192+xexcursion, 27)
        elseif self._scene.m_nChairID == 3 then
            self.btnAdd:setPosition(199+xexcursion, 27)
            self.btnMinus:setPosition(207-192+xexcursion, 27)
        elseif self._scene.m_nChairID == 4 then
            self.btnAdd:setPosition(642+xexcursion, 27)
            self.btnMinus:setPosition(635-192+5+xexcursion, 27)
        elseif self._scene.m_nChairID == 5 then
            self.btnAdd:setPosition(1102+xexcursion, 27)
            self.btnMinus:setPosition(1100-192+xexcursion, 27)
        end--]]

    --[[self.btnAdd:addTouchEventListener(function( sender , eventType )

        local cannonPos = self._scene.m_nChairID      -- 获取自己炮台

        if self._scene._dataModel.m_reversal then 
            cannonPos = 5 - cannonPos
        end
        local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
        if cannon.m_SpecialCannon then
            return
        end

        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
            local gameMinMutiple = self._scene.min_bullet_multiple
            local gameMaxMutiple = self._scene.max_bullet_multiple--]]
            
            --[[if self._scene._dataModel.m_currentMutiple < 9900 then
                if self._scene._dataModel.m_currentMutiple <  100 then
                    self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 10
                elseif self._scene._dataModel.m_currentMutiple <  1000 and  self._scene._dataModel.m_currentMutiple >=  100 then
                    self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 100
                elseif self._scene._dataModel.m_currentMutiple <   10000 and  self._scene._dataModel.m_currentMutiple >=  1000 then
                    self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 1000
                end
            else
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 10000
            end
           
            if self._scene._dataModel.m_currentMutiple == gameMaxMutiple + 10000 then
                self._scene._dataModel.m_currentMutiple = gameMinMutiple
            end
            if self._scene._dataModel.m_currentMutiple > gameMaxMutiple then
                self._scene._dataModel.m_currentMutiple = gameMaxMutiple
            end--]]
            --[[if self._scene._dataModel.m_currentMutiple == gameMaxMutiple then
                self._scene._dataModel.m_currentMutiple = gameMinMutiple
            elseif self._scene._dataModel.m_currentMutiple < 10 then
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 1 
                if self._scene._dataModel.m_currentMutiple > gameMaxMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMaxMutiple
                end
            elseif self._scene._dataModel.m_currentMutiple >= 10 and self._scene._dataModel.m_currentMutiple < 100 then
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 10 
                if self._scene._dataModel.m_currentMutiple > gameMaxMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMaxMutiple
                end  
            elseif self._scene._dataModel.m_currentMutiple >= 100 and self._scene._dataModel.m_currentMutiple < 1000 then
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 100 
                if self._scene._dataModel.m_currentMutiple > gameMaxMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMaxMutiple
                end       
            elseif self._scene._dataModel.m_currentMutiple >= 1000 and self._scene._dataModel.m_currentMutiple < 10000 then
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 1000 
                if self._scene._dataModel.m_currentMutiple > gameMaxMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMaxMutiple
                end
            else
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple + 10000
                if self._scene._dataModel.m_currentMutiple > gameMaxMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMaxMutiple
                end
            end
                  
            self._scene.m_cannonLayer:updateMultiple(self._scene._dataModel.m_currentMutiple,cannonPos + 1)
            print("add==========="..cannonPos + 1)
            self._scene._dataModel.m_userCurrentMutiple[self._scene.m_nChairID + 1] = self._scene._dataModel.m_currentMutiple
            local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
            cannon:setMyMultiple(self._scene._dataModel.m_currentMutiple)
        end
    end)--]]

    
    --[[self.btnMinus:addTouchEventListener(function( sender , eventType )

        local cannonPos = self._scene.m_nChairID      -- 获取自己炮台
        if self._scene._dataModel.m_reversal then 
            cannonPos = 5 - cannonPos
        end
        local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
        if cannon.m_SpecialCannon then
            return
        end
    
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
            local gameMinMutiple = self._scene.min_bullet_multiple
            local gameMaxMutiple = self._scene.max_bullet_multiple--]]
            --[[if self._scene._dataModel.m_currentMutiple < 10000 then
                if self._scene._dataModel.m_currentMutiple <  100 then
                    self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple - 10
                elseif self._scene._dataModel.m_currentMutiple <  1000 and  self._scene._dataModel.m_currentMutiple >=  100 then
                    self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple - 100
                elseif self._scene._dataModel.m_currentMutiple <  10000 and  self._scene._dataModel.m_currentMutiple >=  1000 then
                    self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple - 1000
                end
            else
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple - 10000
            end
            if self._scene._dataModel.m_currentMutiple < gameMinMutiple then
                self._scene._dataModel.m_currentMutiple = gameMaxMutiple
            end--]]

            --[[if self._scene._dataModel.m_currentMutiple == gameMinMutiple then
                self._scene._dataModel.m_currentMutiple = gameMaxMutiple
            elseif self._scene._dataModel.m_currentMutiple <= 10 then
                self._scene._dataModel.m_currentMutiple  = self._scene._dataModel.m_currentMutiple - 1
                if  self._scene._dataModel.m_currentMutiple < gameMinMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMinMutiple
                end
            elseif self._scene._dataModel.m_currentMutiple > 10 and self._scene._dataModel.m_currentMutiple <= 100 then
                self._scene._dataModel.m_currentMutiple  = self._scene._dataModel.m_currentMutiple - 10
                if  self._scene._dataModel.m_currentMutiple < gameMinMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMinMutiple
                end
            elseif self._scene._dataModel.m_currentMutiple > 100 and self._scene._dataModel.m_currentMutiple <= 1000 then
                self._scene._dataModel.m_currentMutiple  = self._scene._dataModel.m_currentMutiple - 100
                if  self._scene._dataModel.m_currentMutiple < gameMinMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMinMutiple
                end
            elseif self._scene._dataModel.m_currentMutiple > 1000 and self._scene._dataModel.m_currentMutiple <= 10000 then
                self._scene._dataModel.m_currentMutiple  = self._scene._dataModel.m_currentMutiple - 1000
                if  self._scene._dataModel.m_currentMutiple < gameMinMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMinMutiple
                end
            else
                self._scene._dataModel.m_currentMutiple = self._scene._dataModel.m_currentMutiple - 10000
                if  self._scene._dataModel.m_currentMutiple < gameMinMutiple then
                    self._scene._dataModel.m_currentMutiple = gameMinMutiple
                end
            end
                   
            self._scene.m_cannonLayer:updateMultiple(self._scene._dataModel.m_currentMutiple,cannonPos + 1)
            self._scene._dataModel.m_userCurrentMutiple[self._scene.m_nChairID + 1] = self._scene._dataModel.m_currentMutiple
            local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
            cannon:setMyMultiple(self._scene._dataModel.m_currentMutiple)
        end
    end)--]]
--    btnMinus:setPosition(50, yl.HEIGHT/2 - 50)


    
--    local multipleBG = cc.Sprite:create("game_res/multiple_bg.png") -- 上下分
--    multipleBG:setAnchorPoint(0.5,0.0)
--    multipleBG:setPosition(yl.WIDTH/4*3 + 160, -6)
--    multipleBG:setScaleY(0.9)
--    self:addChild(multipleBG,20)

     --所有分数上分
     local cmddata = CCmd_Data:create(1)
     cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_EXCHANGE_FISHSCORE);
     cmddata:pushbool(true)
            
	 if not self._scene:sendNetData(cmddata) then        --发送失败
		    --self._scene._gameFrame._callBack(-1,"发送购买子弹失败")
	 end

--注释原来上下分逻辑
--    local mutipleAddBtn = ccui.Button:create("game_res/im_multiple_tip_0.png","game_res/im_multiple_tip_0.png")
--    mutipleAddBtn:setAnchorPoint(0.5,0.0)
--    mutipleAddBtn:setPressedActionEnabled(true)
--    mutipleAddBtn:addTouchEventListener(function( sender , eventType )
--        if eventType == ccui.TouchEventType.ended then
--            local cmddata = CCmd_Data:create(1)
--            cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_EXCHANGE_FISHSCORE);
--            cmddata:pushbool(true)

--	        if not self._scene:sendNetData(cmddata) then        --发送失败
--		        --self._scene._gameFrame._callBack(-1,"发送购买子弹失败")
--	        end
--        end
--    end)
--    mutipleAddBtn:setPosition(yl.WIDTH/4*3 + 115, 2)
--    mutipleAddBtn:setScaleY(0.9)
--    self:addChild(mutipleAddBtn,21)
--    local mutipleMinusBtn = ccui.Button:create("game_res/im_multiple_tip_1.png","game_res/im_multiple_tip_1.png")
--    mutipleMinusBtn:setAnchorPoint(0.5,0.0)
--    mutipleMinusBtn:setPressedActionEnabled(true)
--    mutipleMinusBtn:addTouchEventListener(function( sender , eventType )
--        if eventType == ccui.TouchEventType.ended then
--            local cmddata = CCmd_Data:create(1)
--            cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_EXCHANGE_FISHSCORE);
--            cmddata:pushbool(false)

--	        if not self._scene:sendNetData(cmddata) then    -- 发送失败
--		        --self._scene._gameFrame._callBack(-1,"发送购买子弹失败")
--	        end
--        end
--    end)
--    mutipleMinusBtn:setPosition(yl.WIDTH/4*3 +210, 2)
--    mutipleMinusBtn:setScaleY(0.9)
--    self:addChild(mutipleMinusBtn,21)
--注释原来上下分逻辑

    local function callBack( sender, eventType)
        self:ButtonEvent(sender,eventType)
    end

--    local autoLockBG = cc.Sprite:create("game_res/bgAutoLock.png")
--    autoLockBG:setAnchorPoint(0.5,0.0)
--    autoLockBG:setPosition(750, -6)
--    autoLockBG:setScaleY(0.9)
--    self:addChild(autoLockBG,20)
    
    self.autoShootBtn = ccui.Button:create("zyqs_btn_auto.png","zyqs_btn_auto.png","zyqs_btn_auto.png",UI_TEX_TYPE_PLIST)      -- 自动射击
    self.autoShootBtn:setPosition(yl.WIDTH - 70 - xoffset, 520)
--    self.autoShootBtn:setPosition(yl.WIDTH - 64-xoffset, 480)
--    self.autoShootBtn:setScaleY(0.9)
    self.autoShootBtn:setAnchorPoint(0.5,0.0)
    self.autoShootBtn:setTag(TAG.tag_autoshoot)
    self.autoShootBtn:addTouchEventListener(callBack)
    self:addChild(self.autoShootBtn,22)
    
    self.autoLockBtn = ccui.Button:create("zyqs_btn_lock.png","zyqs_btn_lock.png","zyqs_btn_lock.png",UI_TEX_TYPE_PLIST)       -- 自动锁定
    self.autoLockBtn:setPosition(yl.WIDTH - 70 - xoffset, 380)
--    self.autoLockBtn:setPosition(yl.WIDTH - 164-xoffset, 380)
--    self.autoLockBtn:setScaleY(0.9)
    self.autoLockBtn:setAnchorPoint(0.5,0.0)
    self.autoLockBtn:setTag(TAG.tag_autolock)
    self.autoLockBtn:addTouchEventListener(callBack)
    self:addChild(self.autoLockBtn,22)

    self.speedUpBtn = ccui.Button:create("zyqs_btn_speed1.png","zyqs_btn_speed1.png","zyqs_btn_speed1.png",UI_TEX_TYPE_PLIST)       -- 加速
    self.speedUpBtn:setPosition(yl.WIDTH - 70 - xoffset, 240)
    self.speedUpBtn:setAnchorPoint(0.5,0.0)
    self.speedUpBtn:setTag(TAG.tag_speedUp)
    self.speedUpBtn:addTouchEventListener(callBack)
    self:addChild(self.speedUpBtn,22)

    local render = cc.RenderTexture:create(1334,750)                                                -- 水波效果
    render:beginWithClear(0,0,0,0)
    local water = cc.Sprite:createWithSpriteFrameName("water_0.png")
    water:setScale(2.5)
    water:setOpacity(120)
    water:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    water:visit()
    render:endToLua()
    water:addChild(render)
    render:setPosition(667,375) 
    water:setPosition(667,375)
    self:addChild(water, 1)

    --自动射击按钮粒子特效
    self.tempNode = cc.Node:create()
    self.tempNode:setPosition(cc.p(yl.WIDTH - 70 - xoffset, 580))
    self:addChild(self.tempNode,23)

    local praticleA = cc.ParticleSystemQuad:create("particle/bgtime.plist")
    praticleA:setPosition(cc.p(51, 0))
    praticleA:setRotation(45)
    praticleA:setScale(2)
    self.tempNode:addChild(praticleA,3)

--    praticleA = cc.ParticleSystemQuad:create("particle/bgtime.plist")
--    praticleA:setPosition(cc.p(0, -51))
--    tempNode:addChild(praticleA,3)

    praticleA = cc.ParticleSystemQuad:create("particle/bgtime.plist")
    praticleA:setPosition(cc.p(-51, 0))
    praticleA:setRotation(45)
    praticleA:setScale(2)
    self.tempNode:addChild(praticleA,3)

--    praticleA = cc.ParticleSystemQuad:create("particle/bgtime.plist")
--    praticleA:setPosition(cc.p(0, 51))
--    tempNode:addChild(praticleA,3)

    self.tempNode:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
    self.tempNode:setVisible(false)

    --锁定按钮粒子特效
    self.tempLockNode = cc.Node:create()
    self.tempLockNode:setPosition(cc.p(yl.WIDTH - 70 - xoffset, 440))
    self:addChild(self.tempLockNode,23)

    local praticleB = cc.ParticleSystemQuad:create("particle/bgtime.plist")
    praticleB:setPosition(cc.p(51, 0))
    praticleB:setRotation(45)
    praticleB:setScale(2)
    self.tempLockNode:addChild(praticleB,3)

    praticleB = cc.ParticleSystemQuad:create("particle/bgtime.plist")
    praticleB:setPosition(cc.p(-51, 0))
    praticleB:setRotation(45)
    praticleB:setScale(2)
    self.tempLockNode:addChild(praticleB,3)

    self.tempLockNode:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
    self.tempLockNode:setVisible(false)

        --加速按钮粒子特效
    self.tempSpeedNode = cc.Node:create()
    self.tempSpeedNode:setPosition(cc.p(yl.WIDTH - 70 - xoffset, 300))
    self:addChild(self.tempSpeedNode,23)

    local praticleB = cc.ParticleSystemQuad:create("particle/bgtime.plist")
    praticleB:setPosition(cc.p(51, 0))
    praticleB:setRotation(45)
    praticleB:setScale(2)
    self.tempSpeedNode:addChild(praticleB,3)

    praticleB = cc.ParticleSystemQuad:create("particle/bgtime.plist")
    praticleB:setPosition(cc.p(-51, 0))
    praticleB:setRotation(45)
    praticleB:setScale(2)
    self.tempSpeedNode:addChild(praticleB,3)

--    local label3 = cc.LabelAtlas:_create("/1", "game_res/num_clear_multiple.png", 16, 17, string.byte("-"))
--    label3:setPosition(cc.p(0, 51))
--    label3:setScale(3)
--    label3:setName("speedMut")
--    self.speedUpBtn:addChild(label3,3)

    self.tempSpeedNode:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
    self.tempSpeedNode:setVisible(false)


    local praticle1 = cc.ParticleSystemQuad:create("game_res/levelup_bubble.plist")
    praticle1:setPosition(yl.WIDTH /4,0)
    praticle1:setScaleX(0.5);
    praticle1:setScaleY(0.5);
    praticle1:setTotalParticles(30);
    praticle1:setPositionType(cc.POSITION_TYPE_GROUPED)
    self:addChild(praticle1,3)

    local praticle2 = cc.ParticleSystemQuad:create("game_res/levelup_bubble.plist")
    praticle2:setPosition(yl.WIDTH /4*3,0)
    praticle2:setScaleX(0.5);
    praticle2:setScaleY(0.5);
    praticle2:setTotalParticles(30);
    praticle2:setPositionType(cc.POSITION_TYPE_GROUPED)
    self:addChild(praticle2,3)

    local ani1 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("WaterAnim"))
    local ani2 = ani1:reverse()
    local action = cc.RepeatForever:create(cc.Sequence:create(ani1,ani2))
    water:runAction(action)

    --添加按钮背景
--    self.menuSetBtnBg = display.newSprite("#zyqs_btntable_down.png")
--    self.menuSetBtnBg:setAnchorPoint(0.5,1)
--    self.menuSetBtnBg:setPosition(58, yl.HEIGHT -11)
--    self:addChild(self.menuSetBtnBg,21)

--    self.menuSetBtnBg2 = display.newSprite("#zyqs_btntable_down.png")
--    self.menuSetBtnBg2:setAnchorPoint(0.5,1)
--    self.menuSetBtnBg2:setPosition(58, yl.HEIGHT -44)
--    self.menuSetBtnBg2:setFlippedY(true)
--    self:addChild(self.menuSetBtnBg2,21)

--    self.menuSetBg = ccui.ImageView:create("zyqs_bg_down.png",UI_TEX_TYPE_PLIST)      -- 添加菜单背景
--    self.menuSetBg:setScale9Enabled(true)
--    self.menuSetBg:setCapInsets(cc.rect(35,40,5,8))
--    self.menuSetBg:setContentSize(cc.size(self.menuSetBg:getContentSize().width, 265))
--    self.menuSetBg:setAnchorPoint(0,0.5)
--    self.menuSetBg:setPosition(-170, yl.HEIGHT -375)
--    self:addChild(self.menuSetBg,23)


    local function subCallBack( sender , eventType )
        if eventType == ccui.TouchEventType.ended  then
            ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
            self:subMenuEvent(sender,eventType)
        end
    end

    --银行注释
--    local bank = ccui.Button:create("game_res/bt_bank_0.png","game_res/bt_bank_1.png")      -- 添加子菜单
--    bank:setTag(1)
--    bank:addTouchEventListener(subCallBack)
--    bank:setPressedActionEnabled(true)
--    bank:setVisible(false)
--    bank:setPosition(self.menuSetBg:getContentSize().width/2, self.menuSetBg:getContentSize().height - 53)
--    self.menuSetBg:addChild(bank)

    --按钮收缩菜单按钮
--    self.shrinkmenu = ccui.Button:create("zyqs_btn_down.png","zyqs_btn_down.png","zyqs_btn_down.png",UI_TEX_TYPE_PLIST)
--    self.shrinkmenu:addTouchEventListener(callBack)
--    self.shrinkmenu:setTag(TAG.tag_ShrinkMenu)
--    self.shrinkmenu:setPosition(yl.WIDTH - 50-xoffset, yl.HEIGHT -375)
--    self.shrinkmenu:setFlippedX(true)
--    self:addChild(self.shrinkmenu,23)

    --按钮收缩菜单箭头
--    self.shrinkmenuarrows = display.newSprite("#zyqs_btn_downarrow.png")
--    self.shrinkmenuarrows:setAnchorPoint(0.5,0.5)
--    self.shrinkmenuarrows:setPosition(50,48)
--    self.shrinkmenuarrows:setFlippedX(true)
--    self.shrinkmenu:addChild(self.shrinkmenuarrows)

    self.menu = ccui.Button:create("zyqs_btn_down.png","zyqs_btn_down.png","zyqs_btn_down.png",UI_TEX_TYPE_PLIST)               -- 菜单
    self.menu:addTouchEventListener(callBack)
    self.menu:setTag(TAG.tag_Menu)
    self.menu:setPosition(50+xoffset, yl.HEIGHT - 375)
    self:addChild(self.menu,23)

    --菜单箭头
    self.menuarrows = display.newSprite("#zyqs_btn_downarrow.png")
    self.menuarrows:setAnchorPoint(0.5,0.5)
    self.menuarrows:setPosition(50,48)
    self.menu:addChild(self.menuarrows)

    self.help = ccui.Button:create("zyqs_btn_help.png","zyqs_btn_help.png","zyqs_btn_help.png",UI_TEX_TYPE_PLIST)
    self.help:setTag(2)
    self.help:addTouchEventListener(subCallBack)
    self.help:setPressedActionEnabled(true)
    self.help:setPosition(-200+xoffset, yl.HEIGHT -375)
    self:addChild(self.help,23)

    self.set = ccui.Button:create("zyqs_btn_set.png","zyqs_btn_set.png","zyqs_btn_set.png",UI_TEX_TYPE_PLIST)
    self.set:setTag(3)
    self.set:addTouchEventListener(subCallBack)
    self.set:setPressedActionEnabled(true)
    self.set:setPosition(-200+xoffset, yl.HEIGHT -375)
    self:addChild(self.set,23)

    self.clear = ccui.Button:create("zyqs_btn_turnback.png","zyqs_btn_turnback.png","zyqs_btn_turnback.png",UI_TEX_TYPE_PLIST)
    self.clear:setTag(4)
    self.clear:addTouchEventListener(subCallBack)
    self.clear:setPressedActionEnabled(true)
    self.clear:setPosition(-200+xoffset, yl.HEIGHT -375)
    self:addChild(self.clear,23)

    local bg =  ccui.ImageView:create("game_res/imgSceneIsRunning.png")
	bg:setAnchorPoint(cc.p(.5,.5))
    bg:setTag(TAG.tag_imgSceneChange)
	bg:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	self:addChild(bg)

    --local cmddata = CCmd_Data:create(0)
   	--cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_MAX_FISHSCORE);
	--if not self._scene:sendNetData(cmddata) then        -- 发送失败
        --self._scene._gameFrame._callBack(-1,"发送购买子弹失败")
	--end
    --local cmddata = CCmd_Data:create(4)
   	--cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_BULLETSPEED_INDEX);
    --cmddata:pushint(1)
    
	--if not self._scene:sendNetData(cmddata) then        -- 发送失败

	--end
    setbackgroundcallback(function (bEnter)
--        local scene = cc.Director:getInstance():getRunningScene()
--		local layer = scene:getChildByTag(2000) 
--        if layer ~= nil then
--            return 
--        end
        if self._scene == nil then
            return
        end
        self.m_Inbackground = not self.m_Inbackground
        self.m_setAutoShoot = not self.m_setAutoShoot
        --  去除锁鱼开火
        if self.m_setAutoShoot == true then

            if self._scene._dataModel.m_autoshoot == true then
                self._scene._dataModel.m_autoshoot = false
    	    end	


    	    if self._scene._dataModel.m_autolock == true then
    		    self._scene._dataModel.m_autolock = false
    	    end

            local isautoshoot = false

            local function getCannonPos()
                --获取自己炮台
                local cannonPos = self._scene.m_nChairID
                if self._scene._dataModel.m_reversal then 
                    cannonPos = 5 - cannonPos
                end
                return cannonPos
            end
            isautoshoot = self._scene._dataModel.m_autoshoot
            local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
            cannon:setAutoShoot(isautoshoot)

            self:setAutoShoot(self._scene._dataModel.m_autoshoot,self.autoShootBtn)
            self:setAutoLock(self._scene._dataModel.m_autolock,self.autoLockBtn)
        end

        --回到界面做起立
        if self.m_Inbackground == false then
            local getFishScore = self._scene._dataModel.fish_score_[self._scene.m_nChairID + 1]
            local  score = getFishScore / self._scene.exchange_ratio_fishscore * self._scene.exchange_ratio_userscore
            self._scene._dataModel.m_lUserScore = self._scene._dataModel.m_lUserScore + score
            if self._scene.screenShake ~= nil then
                self._scene.screenShake:stop()
            end

            self._scene.screenShake = nil
            self._scene:unSchedule()
            if self._scene._gameFrame.bEnterAntiCheatRoom == true then
                self._scene._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
            end
            self._scene._gameFrame:StandUp(1)
        end
        if type(self.onBackgroundCallBack) == "function" then
            print("---------------setbackgroundcallback------------------")
		end
	end)
end

function GameViewLayer:removeImgChangeScene()
    if self:getChildByTag(TAG.tag_imgSceneChange) then
        self:removeChildByTag(TAG.tag_imgSceneChange)
    end
end

function GameViewLayer:initUserInfo()
    --用户昵称
--    local nick = cc.Label:create()
--    nick:setString("1:1")
--    nick:setAnchorPoint(0.5,0.5)
--    nick:setPosition(430,25)
--    nick:setSystemFontSize(30)
--    nick:setTag(TAG.tag_gameMultiple)
--    self:addChild(nick,22)
    
    --用户分数 
--    local score = cc.Label:createWithCharMap("game_res/zyqs_num_small.png",18,25,string.byte("%"))
--用户的分数隐藏
--    local score =  cc.Label:createWithTTF(self._scene._dataModel.m_lUserScore, "fonts/round_body.ttf", 23)   -- 用户昵称
--	score:setTextColor(cc.WHITE)
--	score:setAnchorPoint(0.0,0.5)
--	score:setTag(TAG.tag_gameScore)
--	score:setPosition(391, 25)
--	self:addChild(score,22)
--用户的分数隐藏



--    local score = cc.LabelAtlas:create(num,"game_res/zyqs_num_small.png",18,25, string.byte("*"))
--    score:setString(ExternalFun.numberThousands(self._scene._dataModel.m_lUserScore))
--    score:setAnchorPoint(0.0,0.5)
--    score:setTag(TAG.tag_gameScore)
--    score:setPosition(391, 25)
--    self:addChild(score,22)
end

function GameViewLayer:updateUserScore( score )
    local _score  = self:getChildByTag(TAG.tag_gameScore)
    if nil ~=  _score then
        _score:setString(ExternalFun.numberThousands(score))
    end
end

function GameViewLayer:updateMultiple( multiple )       -- 游戏底部的倍数
    local _Multiple = self:getChildByTag(TAG.tag_gameMultiple)
    if nil ~=  _Multiple then
        --_Multiple:setString(string.format("%d:",multiple))
        -- _Multiple:setString(string.format("%d:%d",self._scene.exchange_ratio_userscore,self._scene.exchange_ratio_fishscore))   
    end
end

function GameViewLayer:updateBulletSpeedIndexImg()      -- 更新子弹档位
    local sender = self:getChildByTag(TAG.tag_bulletSpeedIndex)
    if sender ~= nil then
        local bulletSpeedIndex = self._scene._dataModel.bullet_speed_index_[self._scene.m_nChairID + 1] 
        sender:loadTextureNormal(string.format("game_res/btnBulletSpeed_%d.png",bulletSpeedIndex))
        sender:loadTexturePressed(string.format("game_res/btnBulletSpeed_%d.png",bulletSpeedIndex))
        if self._scene._dataModel.m_autoshoot or self._scene._dataModel.m_autolock then
            local cannonPos = self._scene.m_nChairID    -- 获取自己炮台
            if self._scene._dataModel.m_reversal then 
                cannonPos = 5 - cannonPos
            end
            local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
            cannon:setAutoShoot(false)
            cannon:setAutoShoot(true)
        end
    end
end

function GameViewLayer:updteBackGround(param)
    local bg = self:getChildByTag(TAG.tag_bg)
    if bg then
        local call = cc.CallFunc:create(function()
            bg:removeFromParent()
        end)

        bg:runAction(cc.Sequence:create(cc.DelayTime:create(8.0),call))
        local bgfile = string.format("game_res/game_bg_%d.png", param)
        local _bg = cc.Sprite:create(bgfile)
        _bg:setPosition(yl.WIDTH*1.5+50+200, yl.HEIGHT/2)
        _bg:setTag(TAG.tag_bg)
        self:addChild(_bg,5)
        local groupTipsWav = cc.Sprite:createWithSpriteFrameName("wave1.png")
        groupTipsWav:setPosition(cc.p(-50,0))
        groupTipsWav:setAnchorPoint(cc.p(0,0))
        _bg:addChild(groupTipsWav,30)
        local animation = cc.AnimationCache:getInstance():getAnimation("WaveAnim")
        if nil ~= animation then
            groupTipsWav:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
        end
        local callFunc1 = cc.CallFunc:create(function()
            groupTipsWav:runAction(cc.MoveTo:create(2.5,cc.p(-yl.WIDTH*0.5,0)))
        end)
        local callFunc2 = cc.CallFunc:create(function()
            groupTipsWav:removeFromParent()
            _bg:setLocalZOrder(0)
        end)
        _bg:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),cc.MoveTo:create(5,cc.p(yl.WIDTH*0.5,yl.HEIGHT/2)),callFunc1,cc.DelayTime:create(2.5),callFunc2))
    end
        --鱼阵提示
        local groupTips = ccui.ImageView:create("game_res/fish_grounp.png")
        groupTips:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
        groupTips:setTag(TAG.tag_grounpTips)
        self:addChild(groupTips,30)
        local callFunc = cc.CallFunc:create(function()
            groupTips:removeFromParent() 
        end)
        groupTips:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),callFunc))
end

function GameViewLayer:setAutoShoot(b,target)
    if b then
        self.tempNode:setVisible(true)
        target:loadTextureNormal("zyqs_btn_autoing.png",UI_TEX_TYPE_PLIST);
        target:loadTexturePressed("zyqs_btn_autoing.png",UI_TEX_TYPE_PLIST);
    else
        self.tempNode:setVisible(false)
        target:loadTextureNormal("zyqs_btn_auto.png",UI_TEX_TYPE_PLIST);
        target:loadTexturePressed("zyqs_btn_auto.png",UI_TEX_TYPE_PLIST);
    end
end

function GameViewLayer:setAutoLock(b,target)
    if b then
        self.tempLockNode:setVisible(true)
        target:loadTextureNormal("zyqs_btn_locking.png",UI_TEX_TYPE_PLIST);
        target:loadTexturePressed("zyqs_btn_locking.png",UI_TEX_TYPE_PLIST);
    else
        self.tempLockNode:setVisible(false)
        target:loadTextureNormal("zyqs_btn_lock.png",UI_TEX_TYPE_PLIST);
        target:loadTexturePressed("zyqs_btn_lock.png",UI_TEX_TYPE_PLIST);
        --取消自动射击
        self._scene._dataModel.m_fishIndex = g_var(cmd).INT_MAX
        
        --删除自动锁定图标
        local cannonPos = self._scene.m_nChairID
        if self._scene._dataModel.m_reversal then 
            cannonPos = 5 - cannonPos
        end
        local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
        cannon:removeLockTag(self._scene.m_nChairID)

        local cmddata = CCmd_Data:create(6)
   	    cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_USER_LOCKFISH);
        cmddata:pushint(g_var(cmd).INT_MAX)
    
	    if not self._scene:sendNetData(cmddata) then        -- 发送失败
        end
    end              
end

function GameViewLayer:setSpeedUP(mutiple,target)
    if mutiple == 1 then
        self.tempSpeedNode:setVisible(false)
    else
        self.tempSpeedNode:setVisible(true)
    end

    local TextureName = string.format("zyqs_btn_speed%d.png",mutiple)
    target:loadTextureNormal(TextureName,UI_TEX_TYPE_PLIST);
    target:loadTexturePressed(TextureName,UI_TEX_TYPE_PLIST);

end

function GameViewLayer:onBankSuccess( ) -- 银行操作成功
    self._scene:dismissPopWait()
    local bank_success = self._scene.bank_success
    if nil == bank_success then
        return
    end
    GlobalUserItem.lUserScore = bank_success.lUserScore
    GlobalUserItem.lUserInsure = bank_success.lUserInsure
    self:refreshScore()
    showToast(cc.Director:getInstance():getRunningScene(), bank_success.szDescribrString, 2)
end

function GameViewLayer:onBankFailure( ) -- 银行操作失败
    self._scene:dismissPopWait()
    local bank_fail = self._scene.bank_fail
    if nil == bank_fail then
        return
    end
    showToast(cc.Director:getInstance():getRunningScene(), bank_fail.szDescribeString, 2)
end

function GameViewLayer:refreshScore( )  -- 刷新金币
    local str = ExternalFun.numberThousands(GlobalUserItem.lUserScore)  -- 携带游戏币
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.textCurrent:setString(str)
    
    str = ExternalFun.numberThousands(GlobalUserItem.lUserInsure)       -- 银行存款
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.textBank:setString(ExternalFun.numberThousands(GlobalUserItem.lUserInsure))

    --用户分数
    self:updateUserScore(GlobalUserItem.lUserScore)
end

function GameViewLayer:subMenuEvent( sender , eventType)        -- 子菜单
    local function addBG()
        local bg = ccui.ImageView:create()
        bg:setContentSize(cc.size(yl.WIDTH, yl.HEIGHT))
        bg:setScale9Enabled(true)
        bg:setPosition(yl.WIDTH/2, yl.HEIGHT/2)
        bg:setTouchEnabled(true)
        self:addChild(bg,50)
        bg:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
--                bg:removeFromParent()
                self.textCurrent = nil
                self.textBank = nil
            end
        end)
        return bg
    end

    local function showPopWait()
        self._scene:showPopWait()
    end

    local function dismissPopWait()     -- 关闭等待
        self._scene:dismissPopWait()
    end

    local tag = sender:getTag()
    if 1 == tag then --银行
        --申请取款
        local function sendTakeScore( lScore,szPassword )
            local cmddata = ExternalFun.create_netdata(g_var(game_cmd).CMD_GR_C_TakeScoreRequest)
            cmddata:setcmdinfo(g_var(game_cmd).MDM_GR_INSURE, g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
            cmddata:pushbyte(g_var(game_cmd).SUB_GR_TAKE_SCORE_REQUEST)
            cmddata:pushscore(lScore)
            cmddata:pushstring(md5(szPassword),yl.LEN_PASSWORD)
            self._scene:sendNetData(cmddata)
        end

        local function onTakeScore( )
            --参数判断
            local szScore = string.gsub( self.m_editNumber:getText(),"([^0-9])","")
            local szPass =   self.m_editPasswd:getText()
            if #szScore < 1 then 
                showToast(cc.Director:getInstance():getRunningScene(),"请输入操作金额！",2)
                return
            end

            local lOperateScore = tonumber(szScore)
            if lOperateScore<1 then
                showToast(cc.Director:getInstance():getRunningScene(),"请输入正确金额！",2)
                return
            end

            if #szPass < 1 then 
                showToast(cc.Director:getInstance():getRunningScene(),"请输入银行密码！",2)
                return
            end

            if #szPass <6 then
                showToast(cc.Director:getInstance():getRunningScene(),"密码必须大于6个字符，请重新输入！",2)
                return
            end

            showPopWait()
            sendTakeScore(lOperateScore,szPass)
        end

        local bg = addBG()
        local csbNode = ExternalFun.loadCSB("game_res/Bank.csb", bg)
        csbNode:setAnchorPoint(0.5,0.5)
        csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

        self.textCurrent =  csbNode:getChildByName("Text_Score")        -- 当前金币
        local pos = cc.p(self.textCurrent:getPositionX(),self.textCurrent:getPositionY())
        local text = self.textCurrent:getString()
        self.textCurrent:removeFromParent()
        self.textCurrent = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        self.textCurrent:setPosition(pos.x, pos.y)
        csbNode:addChild(self.textCurrent)
        self.textBank    =  csbNode:getChildByName("Text_inSave")       --银行存款
        pos = cc.p(self.textBank:getPositionX(),self.textBank:getPositionY())
        text = self.textBank:getString()
        self.textBank:removeFromParent()
        self.textBank = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        self.textBank:setPosition(pos.x, pos.y)
        csbNode:addChild(self.textBank)
        self:refreshScore()

        local take = csbNode:getChildByName("Text_tipNum")      --输入取出金额
        pos = cc.p(take:getPositionX(),take:getPositionY())
        text = take:getString()
        take:removeFromParent()
        take = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        take:setPosition(pos.x, pos.y)
        csbNode:addChild(take)

        local password = csbNode:getChildByName("Text_tipPassWord") -- 输入银行密码  
        pos = cc.p(password:getPositionX(),password:getPositionY())
        text = password:getString()
        password:removeFromParent()
        password = cc.Label:createWithTTF(text, "fonts/round_body.ttf", 20)
        password:setPosition(pos.x, pos.y)
        csbNode:addChild(password)

        local btnTake = csbNode:getChildByName("btn_takeout")       --取款按钮
        btnTake:addTouchEventListener(function( sender , envetType )
            if envetType == ccui.TouchEventType.ended then
                onTakeScore()
            end
        end)

        local btnClose = csbNode:getChildByName("bt_close")         --关闭按钮
        btnClose:addTouchEventListener(function( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                bg:removeFromParent()
            end
        end)
------------------------------------EditBox---------------------------------------------------
        -- 取款金额
        local editbox = ccui.EditBox:create(cc.size(325, 47),"bank_res/edit_frame.png")
        :setPosition(cc.p(30,take:getPositionY()))
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款金额")
        csbNode:addChild(editbox)
        self.m_editNumber = editbox
  

        -- 取款密码
        editbox = ccui.EditBox:create(cc.size(325, 47),"bank_res/edit_frame.png")
        :setPosition(cc.p(30,password:getPositionY()))
        :setFontName("fonts/round_body.ttf")
        :setPlaceholderFontName("fonts/round_body.ttf")
        :setFontSize(24)
        :setPlaceholderFontSize(24)
        :setMaxLength(32)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
        :setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        :setPlaceHolder("请输入取款密码")
        csbNode:addChild(editbox)
        self.m_editPasswd = editbox
---------------------------------------------------------------------------------------------------------
    elseif 2 == tag then --帮助
        local  bg = addBG()
        local csbNode = ExternalFun.loadCSB("game_res/HelpLayer.csb", bg)
        csbNode:setAnchorPoint(0.5,0.5)
        csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
--        local imageBG = csbNode:getChildByName("Image_bg")      
--        local titlehelp = csbNode:getChildByName("Sprite_titlehelp")
--        local title = csbNode:getChildByName("Sprite_title")
--        local light = csbNode:getChildByName("Sprite_light")

        local btnclose = csbNode:getChildByName("Button_close")

        self.btnnormal = csbNode:getChildByName("CheckBox_normnal")
        self.btnrare = csbNode:getChildByName("CheckBox_rare")  
        self.btncombination = csbNode:getChildByName("CheckBox_combination")   
        self.btnspecial = csbNode:getChildByName("CheckBox_special")

        self.normalfishBG  = csbNode:getChildByName("Spnormalfish")
        self.rarefishBG  = csbNode:getChildByName("Sprarefish")
        self.combinationBG  = csbNode:getChildByName("Spcombinationfish")
        self.specialfishBG  = csbNode:getChildByName("Spspecialfish")
        
        self.m_control1 = false
        self.m_control2 = true
        self.m_control3 = true
        self.m_control4 = true
        self.btnnormal:addTouchEventListener(function ( sender , eventType )    -- 添加点击事件
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.normalfishBG:setVisible(true)
                self.rarefishBG:setVisible(false)
                self.combinationBG:setVisible(false)
                self.specialfishBG:setVisible(false)

                self.btnnormal:setSelected(false)
                self.btnrare:setSelected(true)
                self.btncombination:setSelected(true)
                self.btnspecial:setSelected(true)

                self.m_control1 = false
                self.m_control2 = true
                self.m_control3 = true
                self.m_control4 = true
            elseif eventType == ccui.TouchEventType.canceled then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.btnnormal:setSelected(self.m_control1)
                self.btnrare:setSelected(self.m_control2)
                self.btncombination:setSelected(self.m_control3)
                self.btnspecial:setSelected(self.m_control4)

            end
        end)

        self.btnrare:addTouchEventListener(function ( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.normalfishBG:setVisible(false)
                self.rarefishBG:setVisible(true)
                self.combinationBG:setVisible(false)
                self.specialfishBG:setVisible(false)

                self.btnnormal:setSelected(true)
                self.btnrare:setSelected(false)
                self.btncombination:setSelected(true)
                self.btnspecial:setSelected(true)

                self.m_control1 = true
                self.m_control2 = false
                self.m_control3 = true
                self.m_control4 = true
            elseif eventType == ccui.TouchEventType.canceled then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.btnnormal:setSelected(self.m_control1)
                self.btnrare:setSelected(self.m_control2)
                self.btncombination:setSelected(self.m_control3)
                self.btnspecial:setSelected(self.m_control4)
            end
        end)

        self.btncombination:addTouchEventListener(function ( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.normalfishBG:setVisible(false)
                self.rarefishBG:setVisible(false)
                self.combinationBG:setVisible(true)
                self.specialfishBG:setVisible(false)

                self.btnnormal:setSelected(true)
                self.btnrare:setSelected(true)
                self.btncombination:setSelected(false)
                self.btnspecial:setSelected(true)

                self.m_control1 = true
                self.m_control2 = true
                self.m_control3 = false
                self.m_control4 = true
            elseif eventType == ccui.TouchEventType.canceled then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.btnnormal:setSelected(self.m_control1)
                self.btnrare:setSelected(self.m_control2)
                self.btncombination:setSelected(self.m_control3)
                self.btnspecial:setSelected(self.m_control4)

            end
        end)

        self.btnspecial:addTouchEventListener(function ( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.normalfishBG:setVisible(false)
                self.rarefishBG:setVisible(false)
                self.combinationBG:setVisible(false)
                self.specialfishBG:setVisible(true)

                self.btnnormal:setSelected(true)
                self.btnrare:setSelected(true)
                self.btncombination:setSelected(true)
                self.btnspecial:setSelected(false)

                self.m_control1 = true
                self.m_control2 = true
                self.m_control3 = true
                self.m_control4 = false
            elseif eventType == ccui.TouchEventType.canceled then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                self.btnnormal:setSelected(self.m_control1)
                self.btnrare:setSelected(self.m_control2)
                self.btncombination:setSelected(self.m_control3)
                self.btnspecial:setSelected(self.m_control4)

            end
        end)

        btnclose:addTouchEventListener(function ( sender , eventType )     -- 关闭
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                bg:removeFromParent()
            end
        end)
    elseif 3 == tag then --设置
        local bMute = false
        local bg = addBG()
        local mgr = self._scene._scene:getApp():getVersionMgr(g_var(cmd).KIND_ID)
        local verstr = mgr:getResVersion() or "0"

        local csbNode = ExternalFun.loadCSB("game_res/Setting.csb", bg)
        csbNode:setAnchorPoint(0.5,0.5)
        csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)

        local btnClose = csbNode:getChildByName("bt_close")
        local muteBtnVoice = csbNode:getChildByName("btn_mute")          -- 音乐按钮
        local muteBtn = csbNode:getChildByName("btn_mutevoice")          -- 音效按钮
        local btnShake = csbNode:getChildByName("btn_shake")        -- 震屏按钮
        local txtlevel = csbNode:getChildByName("Text_level")
        txtlevel:setString("当前版本: ver " .. appdf.BASE_C_VERSION .. "." .. verstr)

        if GlobalUserItem.nMusic == 100 then
            muteBtnVoice:loadTextureNormal("zyqs_btn_setopen.png",UI_TEX_TYPE_PLIST)
        end

        if GlobalUserItem.nSound == 100 then
            muteBtn:loadTextureNormal("zyqs_btn_setopen.png",UI_TEX_TYPE_PLIST)   
        end

        if GlobalUserItem.bShake == 1 then
            btnShake:loadTextureNormal("zyqs_btn_setopen.png", UI_TEX_TYPE_PLIST) 
        end

        btnClose:addTouchEventListener(function ( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                bg:removeFromParent()
            end
        end)

        muteBtn:addTouchEventListener(function( sender,eventType ) -- 音效按钮
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                local volume = GlobalUserItem.nSound
                volume = math.abs(volume - 100)
                GlobalUserItem.setSoundVolume(volume)

                if GlobalUserItem.nSound == 100 then
                    muteBtn:loadTextureNormal("zyqs_btn_setopen.png",UI_TEX_TYPE_PLIST) 
                else
                    muteBtn:loadTextureNormal("zyqs_btn_setclose.png",UI_TEX_TYPE_PLIST)
                end
            end
        end)

        muteBtnVoice:addTouchEventListener(function( sender,eventType ) -- 音乐按钮
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                local volume = GlobalUserItem.nMusic
                volume = math.abs(volume - 100)
                GlobalUserItem.setMusicVolume(volume)

                if GlobalUserItem.nMusic == 100 then
                    muteBtnVoice:loadTextureNormal("zyqs_btn_setopen.png",UI_TEX_TYPE_PLIST)
                else
                    muteBtnVoice:loadTextureNormal("zyqs_btn_setclose.png",UI_TEX_TYPE_PLIST)
                end
            end
        end)

        btnShake:addTouchEventListener(function(sender,eventType)       -- 震屏按钮
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                local volume = GlobalUserItem.bShake
                volume = math.abs(volume - 1)
                GlobalUserItem.setShake(volume)

                if GlobalUserItem.bShake == 1 then
                    btnShake:loadTextureNormal("zyqs_btn_setopen.png",UI_TEX_TYPE_PLIST)
                else
                    btnShake:loadTextureNormal("zyqs_btn_setclose.png",UI_TEX_TYPE_PLIST)
                end
            end
        end)
    else --结算
        local bg = addBG()
        local csbNode = ExternalFun.loadCSB("game_res/GameClear.csb", bg)
        csbNode:setAnchorPoint(0.5,0.5)
        csbNode:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
        --按钮

        local btnClose = csbNode:getChildByName("btn_close")
        btnClose:addTouchEventListener(function ( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                bg:removeFromParent()
            end
        end)

        local quit = csbNode:getChildByName("btn_gameQuit")
        quit:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                local getFishScore = self._scene._dataModel.fish_score_[self._scene.m_nChairID + 1]
                local  score = getFishScore / self._scene.exchange_ratio_fishscore * self._scene.exchange_ratio_userscore
                self._scene._dataModel.m_lUserScore = self._scene._dataModel.m_lUserScore + score
                if self._scene.screenShake ~= nil then
                    self._scene.screenShake:stop()
                end

                self._scene.screenShake = nil
                self._scene:unSchedule()
                if self._scene._gameFrame.bEnterAntiCheatRoom == true then
                    self._scene._gameFrame:setEnterAntiCheatRoom(false)--退出防作弊
                end
                self._scene._gameFrame:StandUp(1)
            end
        end)

        local back = csbNode:getChildByName("btn_gameBack")
        back:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
                bg:removeFromParent()
            end
        end)

        --[[--子弹消耗
        local bulletConsum = csbNode:getChildByName("Text_bulletConsum")
        local  pos  = cc.p(bulletConsum:getPositionX(),bulletConsum:getPositionY())
        local anrchor = bulletConsum:getAnchorPoint()
        bulletConsum:removeFromParent()
        bulletConsum = cc.LabelAtlas:create(string.format("%d",self._scene._dataModel.lBulletConsume),"game_res/num_award.png",21,21,string.byte("0"))
        bulletConsum:setPosition(pos.x, pos.y)
        bulletConsum:setAnchorPoint(anrchor)
        csbNode:addChild(bulletConsum)
  
        --捕鱼收获
        local getNum = self._scene._dataModel.m_getFishScore
        local fishGet = csbNode:getChildByName("Text_fishGet")  
        pos  = cc.p(fishGet:getPositionX(),fishGet:getPositionY())
        anrchor = fishGet:getAnchorPoint()
        fishGet:removeFromParent()
        fishGet = cc.LabelAtlas:create(string.format("%d",getNum),"game_res/num_award.png",21,21,string.byte("0"))
        fishGet:setPosition(pos.x, pos.y)
        fishGet:setAnchorPoint(anrchor)
        csbNode:addChild(fishGet)  
        local gameMultiple = self._scene.nFishMultiple
        local userScore = csbNode:getChildByName("Text_totalScore")     -- 用户分数
        pos  = cc.p(userScore:getPositionX(),userScore:getPositionY())
        anrchor = userScore:getAnchorPoint()
        userScore:removeFromParent()
        local getFishScore = self._scene._dataModel.fish_score_[self._scene.m_nChairID + 1]
        local  score = getFishScore / self._scene.exchange_ratio_fishscore * self._scene.exchange_ratio_userscore
        userScore = cc.LabelAtlas:create(string.format("%d",score),"game_res/num_award.png",21,21,string.byte("0"))
        userScore:setPosition(pos.x, pos.y)
        userScore:setAnchorPoint(anrchor)
        csbNode:addChild(userScore)--]]
    end
end

function GameViewLayer:ButtonEvent( sender , eventType)
    local xoffset = 0
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_IPHONE == targetPlatform and yl.WIDTH == 1624 then
        xoffset = 60
    end
    if eventType == ccui.TouchEventType.ended then
        ExternalFun.playSoundEffect(g_var(cmd).BtnSound)
        local function getCannonPos()
            --获取自己炮台
            local cannonPos = self._scene.m_nChairID
            if self._scene._dataModel.m_reversal then 
                cannonPos = 5 - cannonPos
            end
            return cannonPos
        end
        local tag = sender:getTag()
        if tag == TAG.tag_autoshoot then            -- 自动射击
            self._scene._dataModel.m_autoshoot = not self._scene._dataModel.m_autoshoot
--            if self._scene._dataModel.m_autoshoot then
--                self._scene._dataModel.m_autolock = false
--            end
            self:setAutoShoot(self._scene._dataModel.m_autoshoot,sender)
--            local lock = self:getChildByTag(TAG.tag_autolock)
--            self:setAutoLock(self._scene._dataModel.m_autolock,lock)
            local isauto = false
--            if self._scene._dataModel.m_autoshoot or self._scene._dataModel.m_autolock then
            if self._scene._dataModel.m_autoshoot then
                isauto =  true
            end
            local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
            cannon:setAutoShoot(isauto)
            if self._scene._dataModel.m_autoshoot then
                cannon:removeLockTag(self._scene.m_nChairID)
            end
        elseif tag == TAG.tag_autolock then --自动锁定
            self._scene._dataModel.m_autolock = not self._scene._dataModel.m_autolock
--            if self._scene._dataModel.m_autolock then
--                self._scene._dataModel.m_autoshoot = false
--            end
--            local auto = self:getChildByTag(TAG.tag_autoshoot)
--            self:setAutoShoot(self._scene._dataModel.m_autoshoot,auto)
            self:setAutoLock(self._scene._dataModel.m_autolock,sender) 

            local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
            if self._scene._dataModel.m_autoshoot == true then
                cannon:setAutoShoot(true)
            else
                cannon:setAutoShoot(false)
            end
            

--            if self._scene._dataModel.m_autoshoot then
--                cannon:removeLockTag(self._scene.m_nChairID)
--            end

--        elseif tag == TAG.tag_ShrinkMenu then --收缩按钮菜单
--            if self.autoShootBtn:getNumberOfRunningActions() > 0 or self.btnMinus:getNumberOfRunningActions() > 0 then
--                return
--            end
--            if self.autoShootBtn:getPositionX() <= yl.WIDTH - 34-xoffset then
--                self.shrinkmenuarrows:runAction(cc.RotateBy:create(0.2,180))
--                self.autoShootBtn:runAction(cc.MoveTo:create(0.2,cc.p(yl.WIDTH+66+xoffset, yl.HEIGHT -375)))
--                self.autoLockBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.MoveTo:create(0.2,cc.p(yl.WIDTH+66+xoffset, yl.HEIGHT -375))))
--                self.btnAdd:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(0.2,cc.p(yl.WIDTH+66+xoffset, yl.HEIGHT -375))))
--                self.btnMinus:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.MoveTo:create(0.2,cc.p(yl.WIDTH+66+xoffset, yl.HEIGHT -375))))

--            elseif self.autoShootBtn:getPositionX() > yl.WIDTH - 34-xoffset then
--                self.shrinkmenuarrows:runAction(cc.RotateBy:create(0.2,180))
--                self.autoShootBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.MoveTo:create(0.2,cc.p(yl.WIDTH-64-xoffset, 480))))
--                self.autoLockBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(0.2,cc.p(yl.WIDTH-164-xoffset, 380))))
--                self.btnAdd:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.MoveTo:create(0.2,cc.p(yl.WIDTH-164-xoffset, 300))))
--                self.btnMinus:runAction(cc.MoveTo:create(0.2,cc.p(yl.WIDTH-64-xoffset, 200)))

--            end
            
        elseif tag == TAG.tag_speedUp then --加速
            if self._scene._dataModel.bullet_speed_Mutiple == 1 or self._scene._dataModel.bullet_speed_Mutiple == 2 then
                self._scene._dataModel.bullet_speed_Mutiple = 2 * self._scene._dataModel.bullet_speed_Mutiple
                self:setSpeedUP(self._scene._dataModel.bullet_speed_Mutiple,sender)
                local bulletSpeedIndex = self._scene._dataModel.bullet_speed_index_[self._scene.m_nChairID + 1]
                self._scene.m_cannonLayer:onChangeSchedule(bulletSpeedIndex)
            else
                self._scene._dataModel.bullet_speed_Mutiple = 1
                self:setSpeedUP(self._scene._dataModel.bullet_speed_Mutiple,sender)
            end

            local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
            cannon:setSpeedUP()
            
--            sender:getChildByName("speedMut"):setString("/"..self._scene._dataModel.bullet_speed_Mutiple)
        elseif tag == TAG.tag_Menu then --菜单
            if  self.help:getNumberOfRunningActions() > 0  or self.set:getNumberOfRunningActions() > 0 then
                return
            end
            if self.help:getPositionX() >= 0+xoffset then
--               self.menu:runAction(cc.MoveTo:create(0.2,cc.p(31, yl.HEIGHT - 375)))
               self.menuarrows:runAction(cc.RotateBy:create(0.2,180))
               self.help:runAction(cc.MoveTo:create(0.2,cc.p(-200+xoffset, yl.HEIGHT -375)))
               self.set:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.MoveTo:create(0.2,cc.p(-200+xoffset, yl.HEIGHT -375))))
               self.clear:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(0.2,cc.p(-200+xoffset, yl.HEIGHT -375))))
            elseif self.help:getPositionX() < 0+xoffset then
--               self.menu:runAction(cc.MoveTo:create(0.2,cc.p(201,yl.HEIGHT - 375)))
               self.menuarrows:runAction(cc.RotateBy:create(0.2,180))
               self.help:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(0.2,cc.p(74+xoffset, 515))))
               self.set:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.MoveTo:create(0.2,cc.p(174+xoffset, 375))))
               self.clear:runAction(cc.MoveTo:create(0.2,cc.p(74+xoffset, 235)))
            end
        end
    end
end

function GameViewLayer:Showtips( tips )
    local lb =  cc.Label:createWithTTF(tips, "fonts/round_body.ttf", 20)
    local bg = ccui.ImageView:create("game_res/clew_box.png")
    lb:setTextColor(cc.YELLOW)
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(lb:getContentSize().width + 60  , 40))
    bg:setScale(0.1)
    lb:setPosition(bg:getContentSize().width/2, 20)
    bg:addChild(lb)
    self:ShowTipsForBg(bg)
end

function GameViewLayer:ShowCoin( score,wChairID,pos,fishtype )
    ExternalFun.playSoundEffect(g_var(cmd).Coinfly)
    local silverNum = {2,2,3,4,4}
    local goldNum = {1,1,1,2,2,3,3,4,5,6,8,16,16,16,18,18,18,20,20,20,20,20,20,20,20,20,20,20,20,20,20}
    local cannonPos = wChairID
    --获取炮台
    if self._scene._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end
    local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
    if nil == cannon then
        return
    end
    local anim = nil
    local coinNum = 1
    local frameName = nil
    local distant = 50

    if fishtype < 5 then
        anim = cc.AnimationCache:getInstance():getAnimation("SilverAnim")
        frameName = "zyqs_silver_coin_0.png"
        coinNum = silverNum[fishtype+1]
    elseif fishtype>=5 and fishtype<17 then
        anim = cc.AnimationCache:getInstance():getAnimation("GoldAnim")
        frameName = "zyqs_gold_coin_1.png"
        coinNum = goldNum[fishtype+1]
    elseif fishtype>=24 and fishtype<30 then
        anim = cc.AnimationCache:getInstance():getAnimation("GoldAnim")
        frameName = "zyqs_gold_coin_1.png"
        coinNum = goldNum[fishtype+1]
    elseif fishtype == g_var(cmd).FishType.FishType_YuanBao then
        return
    end
    local posX = {}
    local initX = -105
    posX[1] = initX

    for i=2,10 do
        posX[i] = initX-(i-1)*39
    end

    local node = cc.Node:create()
    node:setAnchorPoint(0.5,0.5)
    node:setContentSize(cc.size(distant*5 , distant*4))
  
    if coinNum > 5 then
        node:setContentSize(cc.size(distant*5 , distant*2+40))
    end

    node:setPosition(pos.x, pos.y)
    self._scene.m_cannonLayer:addChild(node,1)

    if nil ~= anim then
        local action = cc.RepeatForever:create(cc.Animate:create(anim))
        if coinNum > 10 then
            coinNum = 10
        end

        local num = cc.LabelAtlas:create(string.format("%d", score),"game_res/zyqs_num_small.png",18,25, string.byte("*"))
        num:setAnchorPoint(0.5,0.5)
        num:setScale(1.5)
        num:setPosition(node:getContentSize().width/2, node:getContentSize().height)
        node:addChild(num)
        local call = cc.CallFunc:create(function()
            num:removeFromParent()
        end)

        num:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),call))

        local secondNum = coinNum
        if coinNum > 5 then
            secondNum = coinNum/2 
        end

        local node1 = cc.Node:create()
        node1:setContentSize(cc.size(distant*secondNum, distant))
        node1:setAnchorPoint(0.5,0.5)
        node1:setPosition(node:getContentSize().width/2, distant/2)
        node:addChild(node1)

        for i=1,secondNum do
            local coin = cc.Sprite:createWithSpriteFrameName(frameName)
            coin:runAction(action:clone())
            coin:setPosition(distant/2+(i-1)*distant, distant/2)
            node1:addChild(coin)
        end

        if coinNum > 5 then
            local firstNum = coinNum - secondNum
            local node2 = cc.Node:create()
            node2:setContentSize(cc.size(distant*firstNum, distant))
            node2:setAnchorPoint(0.5,0.5)
            node2:setPosition(node:getContentSize().width/2, distant*3/2)
            node:addChild(node2)
        end
    end

    local cannonPos = cc.p(cannon:getPositionX(),cannon:getPositionY())
    local call = cc.CallFunc:create(function()
        node:removeFromParent()
    end)

    node:runAction(cc.Sequence:create(cc.MoveBy:create(1.0,cc.p(0,40)),cc.MoveTo:create(0.5,cannonPos),call))

    --[[local angle = 70.0
    local time = 0.12
    local moveY = 30.0

    if (fishtype >= g_var(cmd).FishType.FishType_JianYu and fishtype <= g_var(cmd).FishType.FishType_LiKui) or (fishtype >= g_var(cmd).FishKind.FISH_KIND_25 and fishtype <= g_var(cmd).FishKind.FISH_KIND_30) then
    
       local goldCycle = self:getChildByTag(TAG.tag_GoldCycle + wChairID )
        if nil == goldCycle then
            goldCycle = cc.Sprite:create("game_res/goldCircle.png")
            goldCycle:setTag(TAG.tag_GoldCycle + wChairID)
            goldCycle:setPosition(pos.x, pos.y)
            self:addChild(goldCycle,6)
            local call = cc.CallFunc:create(function( )
                goldCycle:removeFromParent()
            end)
            goldCycle:runAction(cc.Sequence:create(cc.RotateBy:create(time*18,360*1.3),call))
        end

        local goldTxt = self:getChildByTag(TAG.tag_GoldCycleTxt + wChairID)
        if goldTxt == nil then
            goldTxt = cc.LabelAtlas:create(string.format("%d", score),"game_res/mutipleNum.png",14,17,string.byte("0"))
            goldTxt:setAnchorPoint(0.5,0.5)
            goldTxt:setPosition(pos.x, pos.y)          
            self:addChild(goldTxt,6)
            local action = cc.Sequence:create(cc.RotateTo:create(time*2,angle),cc.RotateTo:create(time*4,-angle),cc.RotateTo:create(time*2,0))
            local call = cc.CallFunc:create(function()  
                goldTxt:removeFromParent()
            end)
            goldTxt:runAction(cc.Sequence:create(action,call))
        end
    end]]--
end

function GameViewLayer:ShowCoin1( score,wChairID,pos,fishtype )
    ExternalFun.playSoundEffect(g_var(cmd).Coinfly)
    local silverNum = {2,2,3,4,4}
    local goldNum = {1,1,1,2,2,3,3,4,4,4,5,5,5,6,6,6,14,15,16,17,18,19,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20}
    local cannonPos = wChairID
    --获取炮台
    if self._scene._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end
    local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
    if nil == cannon then
        return
    end

    local coinNum = goldNum[fishtype+1]
    local frameName = "particle/baozha02.png"
    local distant = 50
    local posX = {}
    local initX = -105
    posX[1] = initX
    for i=2,10 do
        posX[i] = initX-(i-1)*39
    end

    local node = cc.Node:create()
    node:setAnchorPoint(0.5,0.5)
    node:setPosition(pos.x, pos.y)
    self._scene.m_cannonLayer:addChild(node,1)
    local num = cc.LabelAtlas:create(string.format("%d", score),"game_res/atlas_gold.png",36,44,string.byte("0"))
    if wChairID ==  self._scene.m_nChairID then
        num = cc.LabelAtlas:create(string.format(">%d", score),"game_res/atlas_gold.png",36,44,string.byte("0"))
        local CoinMoveTo = cc.MoveTo:create(1,cc.p(cannon:getPositionX() + cannon:getContentSize().width + 10 ,cannon:getPositionY() + 60))
        local coin = cc.Sprite:create(frameName)
        coin:setScale(0.2)
        coin:setPosition(cc.p(cannon:getPositionX() + cannon:getContentSize().width + 10,cannon:getPositionY() + 10))
        self:addChild(coin)
        coin:runAction(cc.Sequence:create(cc.DelayTime:create(2),CoinMoveTo))
        local showNum = cc.LabelAtlas:create(string.format(">%d", score),"game_res/atlas_gold.png",36,44,string.byte("0"))
        showNum:setAnchorPoint(0,0.5)
        showNum:setScale(0.5)
        showNum:setPosition(cc.p(cannon:getPositionX() + cannon:getContentSize().width + 30,cannon:getPositionY() + 10))
        self:addChild(showNum,8)
        showNum:setVisible(false)
        coin:setVisible(false)
        local call = cc.CallFunc:create(function()
            showNum:removeFromParent()
            coin:removeFromParent()
        end)
        local callVisible = cc.CallFunc:create(function()
            showNum:setVisible(true)
            coin:setVisible(true)
        end)
        local moveTo = cc.MoveTo:create(1,cc.p(cannon:getPositionX() + cannon:getContentSize().width + 30 ,cannon:getPositionY() + 60))
        showNum:runAction(cc.Sequence:create(cc.DelayTime:create(2),callVisible,moveTo,call))
    end

    num:setAnchorPoint(0.5,0.5)
    num:setScale(1.5)
    num:setPosition(0,0)
    node:addChild(num)
    local call = cc.CallFunc:create(function()
        num:removeFromParent()
    end)
    num:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),call))

    local secondNum = coinNum
    --local cannonPos = cc.p(cannon:getPositionX(),cannon:getPositionY()) 34,44
    for i=1,secondNum do
        local coin = cc.Sprite:create(frameName)
        local posX = math.random(-100,100)
        local posY = math.random(-10,50)
        coin:setPosition(math.random(-100,100),posY)
        node:addChild(coin)
        coin:setScale(0.1)
        local scale = cc.ScaleTo:create(1,0.65)
        local moveBy1 = cc.MoveTo:create(0.5,cc.p(posX,posY + 60))
        local moveBy2 = cc.MoveTo:create(0.6,cc.p(posX,posY - 80))
        local moveBy3 = cc.MoveTo:create(0.1,cc.p(posX,posY - 65))
        local moveBy4 = cc.MoveTo:create(0.1,cc.p(posX,posY - 80))
        local sequence = cc.Sequence:create(moveBy1,moveBy2,moveBy3,moveBy4)
        local spawn = cc.Spawn:create(scale,sequence)
        coin:runAction(spawn)
    end

    local praticle3 = cc.ParticleSystemQuad:create("particle/baozha02.plist")
    praticle3:setPosition(pos.x, pos.y)
    praticle3:setPositionType(cc.POSITION_TYPE_GROUPED)
    cc.Director:getInstance():getRunningScene():addChild(praticle3,3)
    local cannonPos = cc.p(cannon:getPositionX(),cannon:getPositionY())
    local call = cc.CallFunc:create(function()
        praticle3:removeFromParent()
        node:removeFromParent()
    end)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.MoveBy:create(0.5,cc.p(0,40)),cc.MoveTo:create(0.5,cannonPos),call))
    --node:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),call))
    --[[local angle = 70.0
    local time = 0.12
    local moveY = 30.0

    if (fishtype >= g_var(cmd).FishType.FishType_JianYu and fishtype <= g_var(cmd).FishType.FishType_LiKui) or (fishtype >= g_var(cmd).FishKind.FISH_KIND_25 and fishtype <= g_var(cmd).FishKind.FISH_KIND_30) then
    
        local goldCycle = self:getChildByTag(TAG.tag_GoldCycle + wChairID )
        if nil == goldCycle then
            goldCycle = cc.Sprite:create("game_res/goldCircle.png")
            goldCycle:setTag(TAG.tag_GoldCycle + wChairID)
            goldCycle:setPosition(cannonPos)
            self:addChild(goldCycle,6)
            local call = cc.CallFunc:create(function( )
                goldCycle:removeFromParent()
            end)
            goldCycle:runAction(cc.Sequence:create(cc.RotateBy:create(time*18,360*1.3),call))
        end
        local goldTxt = self:getChildByTag(TAG.tag_GoldCycleTxt + wChairID)
        if goldTxt == nil then
            goldTxt = cc.LabelAtlas:create(string.format("%d", score),"game_res/mutipleNum.png",14,17,"0")
            goldTxt:setAnchorPoint(0.5,0.5)
            goldTxt:setPosition(pos.x, pos.y)          
            self:addChild(goldTxt,6)
            local action = cc.Sequence:create(cc.RotateTo:create(time*2,angle),cc.RotateTo:create(time*4,-angle),cc.RotateTo:create(time*2,0))
            local call = cc.CallFunc:create(function()  
                goldTxt:removeFromParent()
            end)
            goldTxt:runAction(cc.Sequence:create(action,call))
        end
    end]]--
end

function GameViewLayer:ShowCoin2(score, wChairID, fish_pos, fishRotation)
    local cannonPos = wChairID
    --获取炮台
    if self._scene._dataModel.m_reversal then 
        cannonPos = 5 - cannonPos
    end
    local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
    if nil == cannon then
        return
    end

    local kCoinCountEnum = { 0, 100, 1000, 10000, 100000 };
    local kCointCount = { 2, 6, 8, 10, 20 };
    local coin_width = 78
    local coin_count = 0;

    for i = #kCoinCountEnum, 1, -1 do
        if score >= kCoinCountEnum[i] then
            if i == #kCoinCountEnum then
                coin_count = kCointCount[i] + math.floor((score - kCoinCountEnum[i]) / 10000)
                coin_count = math.min(20, coin_count)
            else
                coin_count = kCointCount[i]
            end
            break
        end
    end

    local num = string.format("%d",score)
    local goldNum = cc.LabelAtlas:create(num,"game_res/zyqs_num_bigfish.png",54,75,string.byte("/"))
    goldNum:setAnchorPoint(cc.p(0.5,0))
    goldNum:setScale(0.6)
    goldNum:setPosition(cc.p(fish_pos.x,fish_pos.y))
    :addTo(self._scene.m_cannonLayer, 1)

    local callFunc = cc.CallFunc:create(function()
                    goldNum:removeFromParent() 
                end)
    goldNum:runAction(cc.Sequence:create(cc.MoveTo:create(0.8, cc.p(fish_pos.x,fish_pos.y+40))))
    goldNum:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1 ,0.85),cc.FadeIn:create(0.1),cc.DelayTime:create(0.4),cc.ScaleTo:create(0.1 ,0.8),cc.FadeOut:create(0.1),callFunc))


    self:RandomCoin(fish_pos, coin_count, cannon, score)

end

function GameViewLayer:RandomCoin(fishPos, coinNum, cannon, score)
    local targetPos = cc.p(cannon:getPositionX(), cannon:getPositionY())
    local fishSpr = nil
    local randomwidth = coinNum*20
    local curLenght = math.sqrt( math.pow((fishPos.y-targetPos.y), 2) + math.pow((fishPos.x-targetPos.x), 2)) -- 获取金币到炮台的向量
    local maxLenght = math.sqrt( math.pow((cc.Director:getInstance():getWinSize().height), 2) + math.pow((cc.Director:getInstance():getWinSize().width), 2))    -- 获取屏幕最长向量
    local moveTime = curLenght/maxLenght * 2
    local callfun = function() end
    for i = 1, coinNum do
        local coinAnimate = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("FishCoin"))
        local moveAction = cc.MoveTo:create(moveTime, cc.p(targetPos.x, targetPos.y))
        fishSpr = display.newSprite("#zyqs_gold_coin_7.png")
        :addTo(self._scene.m_cannonLayer, 1)
        fishSpr:setPosition(cc.p(fishPos.x-randomwidth/2+math.random(0, randomwidth), fishPos.y-randomwidth/2+math.random(0, randomwidth)))
        fishSpr:setScaleX(0)
        fishSpr:setScaleY(0)
        fishSpr:runAction(cc.RepeatForever:create(coinAnimate))
        if i == coinNum then
            callfun = function()
                if cannon.showGold ~= nil then
                    local cannonPos = self._scene.m_nChairID      -- 获取自己炮台
                    if self._scene._dataModel.m_reversal then 
                        cannonPos = 5 - cannonPos
                    end
                    local cannon1 = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
                    if cannon1 == cannon then
                        cannon:showGold(score)
                    end
                end
            end
        end
        fishSpr:runAction(cc.Sequence:create(cc.DelayTime:create(0.02*i), cc.ScaleTo:create(0.5, 1), cc.DelayTime:create(0.5), moveAction, cc.CallFunc:create(callfun), cc.RemoveSelf:create()))
    end
end
function GameViewLayer:ShowAwardTip(data)
    local fishName = {"小黄刺鱼","小草鱼","热带黄鱼","大眼金鱼","热带紫鱼","小丑鱼","河豚鱼",
    "狮头鱼","灯笼鱼","海龟","神仙鱼","蝴蝶鱼","铃铛鱼","剑鱼","魔鬼鱼","大白鲨","大金鲨",
    "双头企鹅","巨型黄金鲨","金龙","李逵","水浒传","忠义堂","爆炸飞镖","宝箱","元宝鱼"}

    local labelList = {}
    local tipStr  = nil
    local tipStr1 = nil
    local tipStr2 = nil

    if data.nFishMultiple >= 50 then
        if data.nScoreType == g_var(cmd).SupplyType.EST_Cold then
            tipStr = "捕中了"..fishName[data.nFishType+1]..",获得"
        elseif data.nScoreType == g_var(cmd).SupplyType.EST_Laser then
            tipStr = "使用激光,获得"
        end
        tipStr1 = string.format("%d倍 %d分数",data.nFishMultiple,data.lFishScore)
        if data.nFishMultiple > 500 then
            tipStr2 = "超神了!!!"
        elseif data.nFishMultiple == 19 then
            tipStr2 = "运气爆表!!!"   
        else
            tipStr2 = "实力超群!!!"     
        end

        local name = data.szPlayName
        local tableStr = nil
        if data.wTableID == self._scene.m_nTableID  then 
            tableStr = "本桌玩家"
        else
            tableStr = string.format("第%d桌玩家",data.wTableID+1)
        end
        local lb1 =  cc.Label:createWithTTF(tableStr, "fonts/round_body.ttf", 20)
        lb1:setTextColor(cc.YELLOW)
        lb1:setAnchorPoint(0,0.5)
        table.insert(labelList, lb1)

        local lb2 =  cc.Label:createWithTTF(name, "fonts/round_body.ttf", 20)
        lb2:setTextColor(cc.RED)
        lb2:setAnchorPoint(0,0.5)
        table.insert(labelList, lb2)

        local lb3 =  cc.Label:createWithTTF(tipStr, "fonts/round_body.ttf", 20)
        lb3:setTextColor(cc.YELLOW)
        lb3:setAnchorPoint(0,0.5)
        table.insert(labelList, lb3)

        local lb4 =  cc.Label:createWithTTF(tipStr1, "fonts/round_body.ttf", 20)
        lb4:setTextColor(cc.RED)
        lb4:setAnchorPoint(0,0.5)
        table.insert(labelList, lb4)

        local lb5 =  cc.Label:createWithTTF(tipStr2, "fonts/round_body.ttf", 20)
        lb5:setTextColor(cc.YELLOW)
        lb5:setAnchorPoint(0,0.5)
        table.insert(labelList, lb5)
    else

        local lb1 =  cc.Label:createWithTTF("恭喜你捕中了补给箱,获得", "fonts/round_body.ttf", 20)
        lb1:setTextColor(cc.YELLOW)
        lb1:setAnchorPoint(0,0.5)

        local lb1 =  cc.Label:createWithTTF(string.format("%d倍 %d分数 !", data.nFishMultiple,data.lFishScore), "fonts/round_body.ttf", 20)
        lb1:setTextColor(cc.RED)
        lb1:setAnchorPoint(0,0.5)
        table.insert(labelList, lb1)
        table.insert(labelList, lb2)
    end

    local length = 60
    for i=1,#labelList do
        local lb = labelList[i]
        lb:setPosition(length - 30 , 20)
        length =  length + lb:getContentSize().width + 5 
    end

    local bg = ccui.ImageView:create("game_res/clew_box.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(length,40)
    bg:setScale(0.1)

    for i=1,#labelList do
        local lb = labelList[i]
        bg:addChild(lb)
    end

    self:ShowTipsForBg(bg)
    labelList = {}
end

function GameViewLayer:ShowTipsForBg( bg )
    local infoCount = #self._scene.m_infoList
    local sublist = {}

    while infoCount >= 3 do
        local node = self._scene.m_infoList[1]
        table.remove(self._scene.m_infoList,1)
        node:removeFromParent()
        for i=1,#self._scene.m_infoList do
            local bg = self._scene.m_infoList[i]
            bg:runAction(cc.MoveBy:create(0.2,cc.p(0,60)))
        end
        infoCount = #self._scene.m_infoList
    end

    bg:setPosition(yl.WIDTH/2, yl.HEIGHT-120-60*infoCount)
    self:addChild(bg,30)
    table.insert(self._scene.m_infoList, bg)

    local call = cc.CallFunc:create(function()
        bg:removeFromParent()
        for i=1,#self._scene.m_infoList do
            local _bg = self._scene.m_infoList[i]
            if bg == _bg then
                table.remove(self._scene.m_infoList,i)
                break
            end
        end

        if #self._scene.m_infoList > 0 then
            for i=1,#self._scene.m_infoList do
                local _bg = self._scene.m_infoList[i]
                _bg:runAction(cc.MoveBy:create(0.2,cc.p(0,60)))
            end
        end
    end)
    bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.17,1.0),cc.DelayTime:create(5),cc.ScaleTo:create(0.17,0.1,1.0),call)) 
end

function GameViewLayer:showLight(fishtype, nFishIndex)
    print("--------- showLight fishtype ----------", fishtype, nFishIndex)
    ExternalFun.playSoundEffect(g_var(cmd).DepthBomb)
    local fishList = {}
    local fish = self._scene._dataModel.m_fishList[nFishIndex]
    if nil == fish then
         return
    end
    local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)

    for k,v in pairs(self._scene._dataModel.m_fishList) do
        local fish = self._scene._dataModel.m_fishList[k]
        if nil ~= fish and nil ~= fish.m_data then
            if fish.m_data.nFishType == fishtype and fish.m_data.nFishKey ~= nFishIndex then
                table.insert(fishList,fish)
            end
        end
    end

    if fishList == nil then
        print("--------- showLight fishList nil----------")
        return
    end
    dump(fishList, "showLight fishList", 6)
    local fishpoint = cc.p(fish:getPositionX(), fish:getPositionY())
    if self._scene._dataModel.m_reversal then
        fishpoint = cc.p(yl.WIDTH - fish:getPositionX(), yl.HEIGHT - fish:getPositionY())
    end
    self:showBall(fishpoint)

    for k,v in pairs(fishList) do
        local point = cc.p(v:getPositionX(), v:getPositionY())
        if self._scene._dataModel.m_reversal then
            point = cc.p(yl.WIDTH - v:getPositionX(), yl.HEIGHT - v:getPositionY())
        end
        self:showBall(point)
        self:showLight2(fishpoint.x, fishpoint.y, point.x , point.y)
    end
end   

function GameViewLayer:showLight2(point1X, point1Y, point2X, point2Y)
    print("--------- showLight2 ----------")
    local point1 = cc.p(point1X,point1Y)
    local point2 = cc.p(point2X,point2Y)
    self:showBall(point2)
    local distant = cc.pGetDistance(point1, point2)
    local pscaley = distant / 256
    local angle = self._scene._dataModel:getAngleByTwoPoint(point1, point2)
    local plight1 = cc.Sprite:create("game_res/fish_bomb_light.png", cc.rect(0, 0, 60, 256))
    plight1:setPosition(cc.p((point1X + point2X) / 2,(point1Y + point2Y) / 2))
    plight1:setColor(cc.c3b(255, 255, 0))
    plight1:setOpacity(255)
    plight1:setRotation(angle)
    plight1:setScaleY(pscaley)
    plight1:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    self:addChild(plight1,6)

    local plight2 = cc.Sprite:create("game_res/fish_bomb_light.png", cc.rect(0, 0, 60, 256))
    plight2:setPosition(cc.p((point1X + point2X) / 2,(point1Y + point2Y) / 2))
    plight2:setColor(cc.c3b(0, 215, 255))
    plight2:setOpacity(150)
    plight2:setRotation(angle)
    plight2:setScaleY(pscaley)
    plight2:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    self:addChild(plight2,6)

    local anim = cc.AnimationCache:getInstance():getAnimation("FishLight")
    local panim = cc.Repeat:create(cc.Animate:create(anim), 5)
    local call1 = cc.CallFunc:create(function()
        plight1:removeFromParent()
    end)
    local call2 = cc.CallFunc:create(function()
        plight2:removeFromParent()
    end)
    plight1:runAction(cc.Sequence:create(panim, call1)) 
    plight2:runAction(cc.Sequence:create(panim, call2))
end

function GameViewLayer:showBall(pos)
    local pball1 = cc.Sprite:create("game_res/fish_bomb_ball.png", cc.rect(0, 0, 70, 70))
    pball1:setPosition(pos)
    pball1:setColor(cc.c3b(255, 255, 0))
    pball1:setOpacity(255)
    pball1:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    self:addChild(pball1,6)

    local pball2 = cc.Sprite:create("game_res/fish_bomb_ball.png", cc.rect(0, 0, 70, 70))
    pball2:setPosition(pos)
    pball2:setColor(cc.c3b(255, 255, 0))
    pball2:setOpacity(150)
    pball2:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    self:addChild(pball2,6)

    local anim = cc.AnimationCache:getInstance():getAnimation("FishBall")
    local panim = cc.Repeat:create(cc.Animate:create(anim), 3)
    --local panim = cc.Repeat:create(cc.Animate:create(cc.AnimationCache:getInstance:getAnimation(g_var(cmd).FishBall)), 3)
    local call1 = cc.CallFunc:create(function()
        pball1:removeFromParent()
    end)
    local call2 = cc.CallFunc:create(function()
        pball2:removeFromParent()
    end)
    pball1:runAction(cc.Sequence:create(panim, call1)) 
    pball2:runAction(cc.Sequence:create(panim, call2))
end

return GameViewLayer
