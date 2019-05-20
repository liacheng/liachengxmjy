--
-- Author: Tang
-- Date: 2016-08-09 10:31:32
-- 预加载资源
local PreLoading = {}
local module_pre = "game.yule.fishlk.src"	
local cmd = module_pre .. ".models.CMD_LKGame"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
--PreLoading.RES_PATH = device.writablePath.."game/yule/fishlk/res/"      -- 资源路径
PreLoading.bLoadingFinish = false                                       -- 是否读取完成
PreLoading.loadingPer = 20                                              -- 进度条进度
PreLoading.bFishData = false                                            -- 
PreLoading.FishAnimNum = 12                                             -- 鱼游动动画的帧数
PreLoading.FishTypeNum = 20                                             -- 鱼的种类数
PreLoading.iLayerTag = 2000                                             -- 图层Tag
function PreLoading.resetData()                                         -- 重置进度条界面数据
    PreLoading.bLoadingFinish = false
	PreLoading.loadingPer = 20
	PreLoading.bFishData = false
end

function PreLoading.StopAnim(bRemove)                                   -- GameViewLayer调用  bRemove是否删除进度条界面
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = scene:getChildByTag(PreLoading.iLayerTag) 

	if not layer  then
		return
	end

	if not bRemove then
		if nil ~= PreLoading.fish then
			PreLoading.fish:stopAllActions()
		end
	else
		layer:stopAllActions()
		layer:removeFromParent()
	end
end

function PreLoading.loadTextures(scene)                                 -- GameViewLayer调用  scene = GameLayer
    local m_nImageOffset = 0        -- 当前已加载的资源数量
	local totalSource = 17          -- 总共需加载的资源数量
    local plists = {"whater.plist",
					"bullet.plist",
					"fish_ignot.plist",
					"fish_dead.plist",
					"watch.plist",
					"fish_move1.plist",
					"fish_move2.plist",
					"lock_fish.plist",
					"boom_darts.plist",
					"bomb.plist",
					"blue.plist",
					"bullet_guns_coins.plist",
                    "wave.plist",
                    "fish_yd_0.plist",
                    "fish_yd_1.plist",
                    "fish_die_0.plist",
                    "fish_die_1.plist",
                    "image.plist"}

    local function imageLoaded(texture)
        m_nImageOffset = m_nImageOffset + 1
        PreLoading.loadingPer = 20 + m_nImageOffset*2

        if m_nImageOffset == totalSource then
            for i = 1, #plists do
                cc.SpriteFrameCache:getInstance():addSpriteFrames("game_res/"..plists[i])
        	end
        	PreLoading.readAniams()             -- 加载动画
        	PreLoading.bLoadingFinish = true    -- 设置加载完成
        	
			local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)    -- 通知
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
			if PreLoading.bFishData then
                local runningScene = cc.Director:getInstance():getRunningScene()
				local layer = runningScene:getChildByTag(PreLoading.iLayerTag)
				if not layer then
                    return
				end

				PreLoading.loadingPer = 100
				PreLoading.updatePercent(PreLoading.loadingPer)
				local callfunc = cc.CallFunc:create(function()
                    PreLoading.loadingBar:stopAllActions()
					PreLoading.loadingBar = nil
					layer:stopAllActions()
					layer:removeFromParent()
				end)
                local fishTrace = cc.CallFunc:create(function()
                    scene:BuildSceneKindTrace()
                end)
				layer:stopAllActions()
				layer:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),fishTrace,callfunc))
			end
        	print("资源加载完成")
        end
    end

    local function loadImages()
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/whater.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/bullet.png",imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_ignot.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_dead.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/watch.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_move1.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_move2.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/lock_fish.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/boom_darts.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/bomb.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/blue.png", imageLoaded)
		cc.Director:getInstance():getTextureCache():addImageAsync("game_res/bullet_guns_coins.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/wave.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_yd_0.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_yd_1.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_die_0.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/fish_die_1.png", imageLoaded)
        cc.Director:getInstance():getTextureCache():addImageAsync("game_res/image.png", imageLoaded)
    end

    local function createSchedule( )
        local function update( dt )
            PreLoading.updatePercent(PreLoading.loadingPer)        
		end

		local scheduler = cc.Director:getInstance():getScheduler()
		PreLoading.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
    
	PreLoading.GameLoadingView()    -- 进度条
	loadImages()                    -- 异步加载资源????先加载后创建界面
	createSchedule()
	PreLoading.addEvent(scene)
end

function PreLoading.addEvent(scene)
    local function eventListener(event)   -- 通知监听
        cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_FishCreate)
        PreLoading.Finish(scene)
    end

    local listener = cc.EventListenerCustom:create(g_var(cmd).Event_FishCreate, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function PreLoading.Finish(scene)
	PreLoading.bFishData = true
	if  PreLoading.bLoadingFinish then
		PreLoading.loadingPer = 100
		PreLoading.updatePercent(PreLoading.loadingPer)

		local scene = cc.Director:getInstance():getRunningScene()
		local layer = scene:getChildByTag(PreLoading.iLayerTag) 

		if nil ~= layer then
			local callfunc = cc.CallFunc:create(function()
				PreLoading.loadingBar:stopAllActions()
				PreLoading.loadingBar = nil
				PreLoading.fish:stopAllActions()
				PreLoading.fish = nil
				layer:stopAllActions()
				layer:removeFromParent()
			end)
            local fishTrace = cc.CallFunc:create(function()
                scene:BuildSceneKindTrace()
            end)
			layer:stopAllActions()
			layer:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),fishTrace,callfunc))
		end
	end
end

function PreLoading.GameLoadingView()                                   -- 创建读取界面(读取界面图层, 背景图, 进度条背景, 进度条, 鱼)
	--cc.FileUtils:getInstance():addSearchPath(PreLoading.RES_PATH);      -- 设置搜索路径
	local scene = cc.Director:getInstance():getRunningScene()           -- 获取当前正在运行的场景
	local layer = display.newLayer()                                    -- 创建加载界面图层
	layer:setTag(PreLoading.iLayerTag)                                  -- 设置图层Tag
	scene:addChild(layer,30)

	local loadingBG = ccui.ImageView:create("loading/bg.png")           -- 设置加载背景图片
	loadingBG:setTag(1)
	loadingBG:setTouchEnabled(true)
	loadingBG:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	layer:addChild(loadingBG)

	local loadingBarBG = ccui.ImageView:create("loading/loadingBG.png") -- 设置进度条背景图片
	loadingBarBG:setTag(2)
	loadingBarBG:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2-200))
	layer:addChild(loadingBarBG)
                                                                        -- 设置进度条
	PreLoading.loadingBar = cc.ProgressTimer:create(cc.Sprite:create("loading/loading_cell.png"))
	PreLoading.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	PreLoading.loadingBar:setMidpoint(cc.p(0.0,0.5))
	PreLoading.loadingBar:setBarChangeRate(cc.p(1,0))
    PreLoading.loadingBar:setPosition(cc.p(loadingBarBG:getContentSize().width/2,loadingBarBG:getContentSize().height/2))
    PreLoading.loadingBar:runAction(cc.ProgressTo:create(0.2,20))       -- 默认读取到20
    loadingBarBG:addChild(PreLoading.loadingBar)


    PreLoading.fish = cc.Sprite:create("loading/loading_1.png")         -- 设置读取界面鱼(标签)
    PreLoading.fish:setAnchorPoint(cc.p(1.0,0.5))
    PreLoading.fish:setPosition(cc.p(150,PreLoading.loadingBar:getContentSize().height/2))
    loadingBarBG:addChild(PreLoading.fish)
    PreLoading.fish:stopAllActions()

	local frames = {}                                                   -- 设置鱼动画
   	local actionTime = 0.1
	for i = 1, 9 do
		local frameName = string.format("loading/loading_".."%d.png", i)
		local frame = cc.SpriteFrame:create(frameName,cc.rect(0,0,258,97))
		table.insert(frames, frame)
	end
                                                                        -- 循环播放动画
	local animation = cc.Animation:createWithSpriteFrames(frames,actionTime)
    local action = cc.RepeatForever:create(cc.Animate:create(animation))
	PreLoading.fish:runAction(action)
                                                                        -- 移动到进度条20得位置
	local move = cc.MoveTo:create(0.2, cc.p(900*(20/100), PreLoading.loadingBar:getContentSize().height/2))
    PreLoading.fish:runAction(move)
    move:setTag(1)
end

function PreLoading.updatePercent(percent )
	if nil ~= PreLoading.loadingBar then
		local dt = 1.0
		if percent == 100 then
			dt = 2.0
		end

		PreLoading.loadingBar:runAction(cc.ProgressTo:create(dt,percent))
		cc.Director:getInstance():getActionManager():removeActionByTag(1, PreLoading.fish)
		local move =  cc.MoveTo:create(dt,cc.p(900*(percent/100),PreLoading.loadingBar:getContentSize().height/2 ))
		move:setTag(1)
		PreLoading.fish:runAction(move)
	end

	if PreLoading.bLoadingFinish then
		if nil ~= PreLoading.m_scheduleUpdate then
    		local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(PreLoading.m_scheduleUpdate)
			PreLoading.m_scheduleUpdate = nil
		end
	end
end

function PreLoading.unloadTextures( )
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/whater.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/whater.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/bullet.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/bullet.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_ignot.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_ignot.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_dead.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_dead.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/watch.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/watch.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_move1.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_move1.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_move2.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_move2.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/lock_fish.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/lock_fish.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/boom_darts.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/boom_darts.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/bomb.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/bomb.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/blue.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/blue.png")
	
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/bullet_guns_coins.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/bullet_guns_coins.png")
	
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/wave.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/wave.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_yd_0.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_yd_0.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_yd_1.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_yd_1.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_die_0.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_die_0.png")

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game_res/fish_die_1.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game_res/fish_die_1.png")

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function PreLoading.readAnimation(file, key, num, time,formatBit)
	local frames = {}
   	local actionTime = time
	for i=1,num do
		local frameName
		if formatBit == 1 then
            frameName = string.format(file.."%d.png", i-1)
		elseif formatBit == 2 then
            frameName = string.format(file.."%2d.png", i-1)
		end
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		table.insert(frames, frame)
	end

	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, key)
end

function PreLoading.readAniByFileName( file,width,height,rownum,linenum,savename)
	local frames = {}
	for i=1,rownum do
        for j=1,linenum do
            local frame = cc.SpriteFrame:create(file,cc.rect(width*(j-1),height*(i-1),width,height))
			table.insert(frames, frame)
		end
	end
	local animation = cc.Animation:createWithSpriteFrames(frames,0.03)
   	cc.AnimationCache:getInstance():addAnimation(animation, savename)
end

function PreLoading.removeAllActions()
    for index=0,PreLoading.FishTypeNum - 1 do
		cc.AnimationCache:getInstance():removeAnimation(string.format("fish_%d_yd", index))
	end

    for i=0,17 do
    	cc.AnimationCache:getInstance():removeAnimation(string.format("fish_%d_die", i))
	end
	
	for i=1,g_var(cmd).Fish_MOVE_TYPE_NUM do    -- 鱼游动动画
		local key = string.format("animation_fish_move%d", i)
		cc.AnimationCache:getInstance():removeAnimation(key)
	end

	for i=1,g_var(cmd).Fish_DEAD_TYPE_NUM do    -- 鱼死亡动画
		local key = string.format("animation_fish_dead%d", i)
		cc.AnimationCache:getInstance():removeAnimation(key)
	end	

	--元宝鱼游动动画
   	cc.AnimationCache:getInstance():removeAnimation("fish_ignot_move")

   	--元宝鱼死亡动画
   	cc.AnimationCache:getInstance():removeAnimation("fish_ignot_dead")

   	--元宝鱼金币翻滚动画
   	cc.AnimationCache:getInstance():removeAnimation("fish_ignot_coin")
    cc.AnimationCache:getInstance():removeAnimation("WaterAnim")
    cc.AnimationCache:getInstance():removeAnimation("FortAnim")
    cc.AnimationCache:getInstance():removeAnimation("FortLightAnim")
    cc.AnimationCache:getInstance():removeAnimation("SilverAnim")
    cc.AnimationCache:getInstance():removeAnimation("CopperAnim")
    cc.AnimationCache:getInstance():removeAnimation("BombAnim")
    cc.AnimationCache:getInstance():removeAnimation("GoldAnim")
    cc.AnimationCache:getInstance():removeAnimation("BombDartsAnim")
    cc.AnimationCache:getInstance():removeAnimation("BlueIceAnim")
    cc.AnimationCache:getInstance():removeAnimation("BulletAnim")
    cc.AnimationCache:getInstance():removeAnimation("LightAnim")
    cc.AnimationCache:getInstance():removeAnimation("watchAnim")
    cc.AnimationCache:getInstance():removeAnimation("FishBall")
    cc.AnimationCache:getInstance():removeAnimation("FishLight")
    cc.AnimationCache:getInstance():removeAnimation("WaveAnim")

    -- 奖励金动画
    cc.AnimationCache:getInstance():removeAnimation("animation_reward_box")
end

function PreLoading.readFishAnimation(file, key,FishType, num, time)
	local frames = {}
   	local actionTime = time
   	local  n = num - 1
	for i=0,n do
        local frameName = string.format(file,FishType, i)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		table.insert(frames, frame)
	end
	local savename = string.format(key,FishType)
	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, savename)
end

function PreLoading.readAniams()

    local reward_box_frames = {}
    for i = 0, 9 do
        local frameName =string.format("Reward_Box_%d.png",i)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(reward_box_frames, frame)
    end
    local reward_box_ani = cc.Animation:createWithSpriteFrames(reward_box_frames, 0.1)
    cc.AnimationCache:getInstance():addAnimation(reward_box_ani, "animation_reward_box")

	for index = 0, PreLoading.FishTypeNum - 1 do   --鱼游动动画
		local animnum = PreLoading.FishAnimNum
		local animtime = 0.1
		if index == 5 then
			animnum = 36
            animtime = 0.1
        elseif index >= 13 and index < PreLoading.FishTypeNum - 1 then
            animnum = 24
            animtime = 0.1
        end
        PreLoading.readFishAnimation("fish_%d_yd_%d.png", "fish_%d_yd", index, animnum, animtime)
	end

    for i = 0, 17 do
		PreLoading.readFishAnimation("fish_%d_die_%d.png", "fish_%d_die", i, 12, 0.05)
	end

    local fishFrameMoveNum =
	{
		6,8,12,
	    12,12,13,
	    12,10,12,
	    8,12,6,
	    12,10,12,
	    12,12,15,
	    16,15,15,
	    8,25,1,
	    12,7,5
	}

	local fishFrameDeadNum =
	{
		2,2,2,
	    3,3,3,
	    6,3,2,
	    6,4,3,
	    3,3,3,
	    3,3,17,
	    8,21,9,
	    12
	}
   
	for i = 1, g_var(cmd).Fish_MOVE_TYPE_NUM do        -- 鱼游动动画
		local frames = {}
		local actionTime = 0.09
		if i == 21 then
			actionTime = 0.15
		end

		local num = fishFrameMoveNum[i]
    	for j=1,num do
	        local frameName =string.format("fishMove_%03d_%d.png",i,j)  
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end

    	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_fish_move%d", i)
		cc.AnimationCache:getInstance():addAnimation(animation, key)
	end

	for i = 1 ,g_var(cmd).Fish_DEAD_TYPE_NUM do            -- 鱼死亡动画
		frames = {}
		local actionTime = 0.05
		local num = fishFrameDeadNum[i]
    	for j=1,num do
	        local frameName =string.format("fishDead_%03d_%d.png",i,j)  
	        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
	        table.insert(frames, frame)
    	end
    	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
		local key = string.format("animation_fish_dead%d", i)
		cc.AnimationCache:getInstance():addAnimation(animation, key)
	end	

	
    frames = {}                                             -- 元宝鱼游动动画
	local actionTime = 0.05
	for i=1,2 do
		local frameName = string.format("fishMove_ignot_%d.png", i)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		table.insert(frames, frame)
	end

	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, "fish_ignot_move")

   	frames = {}                                             -- 元宝鱼死亡动画
   	local actionTime = 0.05
	for i=1,8 do
		local frameName = string.format("fishDead_ignot_%d.png", i)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		table.insert(frames, frame)
	end

	local  animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, "fish_ignot_dead")

   	frames = {}                                             -- 元宝鱼金币翻滚动画
   	local actionTime = 0.05
	for i=1,15 do
		local frameName = string.format("ignot_coin_%d.png", i)
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		table.insert(frames, frame)
	end

	local animation =cc.Animation:createWithSpriteFrames(frames,actionTime)
   	cc.AnimationCache:getInstance():addAnimation(animation, "fish_ignot_coin")

   	PreLoading.readAnimation("water_","WaterAnim",12,0.12,1)
   	PreLoading.readAnimation("fort_","FortAnim",6,0.02,1)
   	PreLoading.readAnimation("fort_light_", "FortLightAnim", 6, 0.02,1);
    PreLoading.readAnimation("silver_coin_", "SilverAnim", 12, 0.05,1);
    PreLoading.readAnimation("gold_coin_", "GoldAnim", 12, 0.08,1);
    PreLoading.readAnimation("copper_coin_", "CopperAnim", 10, 0.05,1);
    PreLoading.readAnimation("boom", "BombAnim", 32,0.03,2);
    PreLoading.readAnimation("boom_darts", "BombDartsAnim", 33,0.03,1);
    PreLoading.readAnimation("blue", "BlueIceAnim", 22,0.03,2);
    PreLoading.readAnimation("bullet_", "BulletAnim", 10,1);
    PreLoading.readAnimation("light_", "LightAnim", 16, 0.05,1);
    PreLoading.readAnimation("watch_", "watchAnim", 24, 0.08,1);
    PreLoading.readAnimation("wave", "WaveAnim", 2, 0.5,1);
    PreLoading.readAniByFileName("game_res/fish_bomb_ball.png", 70, 70, 2, 5, "FishBall")
    PreLoading.readAniByFileName("game_res/fish_bomb_light.png", 40, 256, 1, 6, "FishLight")
end

return PreLoading