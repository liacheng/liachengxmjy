-- 预加载资源
local PreLoading = {}
local module_pre = "game.yule.fishdntg.src"	
local cmd = module_pre .. ".models.CMD_DNTGGame"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var

PreLoading.bLoadingFinish   = false             -- 是否读取完成
PreLoading.loadingPer       = 0                 -- 进度条进度
PreLoading.bFishData        = false             -- 
PreLoading.FishTypeNum      = 28                -- 鱼的种类数
PreLoading.iLayerTag        = 2000              -- 图层Tag
PreLoading.plistPath = {    "game_res/fishdntg_game.plist",  
					        "game_res/fishdntg_game_lockfish.plist",
                            "game_res/fishdntg_fish_0.plist",
                            "game_res/fishdntg_fish_1.plist",
                            "game_res/fishdntg_fish_2.plist",
                            "game_res/fishdntg_fish_3.plist",
                            "game_res/fishdntg_fish_4.plist",
                            "game_res/fishdntg_fish_5.plist",
                            "game_res/fishdntg_fish_6.plist",
                            "game_res/fishdntg_fish_7.plist",
                            "game_res/fishdntg_fish_8.plist",
                            "game_res/fishdntg_fish_9.plist",
                            "game_res/fishdntg_fish_10.plist",
                            "game_res/fishdntg_fish_11.plist",
                            "game_res/fishdntg_fish_12.plist",
                            "game_res/fishdntg_fish_13.plist",
                            "game_res/fishdntg_fish_14.plist",
                            "game_res/fishdntg_fish_15.plist",
                            "game_res/fishdntg_fish_16.plist",
                            "game_res/fishdntg_fish_17.plist",
                            "game_res/fishdntg_fish_18.plist",
                            "game_res/fishdntg_fish_19.plist",
                            "game_res/whater.plist",
                            "game_res/watch.plist",
                            "game_res/wave.plist",
                            "game_res/image.plist",
                            "game_res/fishdntg_game1.plist"      }

PreLoading.pngPath = {      "game_res/fishdntg_game.png",  
					        "game_res/fishdntg_game_lockfish.png",
                            "game_res/fishdntg_fish_0.png",
                            "game_res/fishdntg_fish_1.png",
                            "game_res/fishdntg_fish_2.png",
                            "game_res/fishdntg_fish_3.png",
                            "game_res/fishdntg_fish_4.png",
                            "game_res/fishdntg_fish_5.png",
                            "game_res/fishdntg_fish_6.png",
                            "game_res/fishdntg_fish_7.png",
                            "game_res/fishdntg_fish_8.png",
                            "game_res/fishdntg_fish_9.png",
                            "game_res/fishdntg_fish_10.png",
                            "game_res/fishdntg_fish_11.png",
                            "game_res/fishdntg_fish_12.png",
                            "game_res/fishdntg_fish_13.png",
                            "game_res/fishdntg_fish_14.png",
                            "game_res/fishdntg_fish_15.png",
                            "game_res/fishdntg_fish_16.png",
                            "game_res/fishdntg_fish_17.png",
                            "game_res/fishdntg_fish_18.png",
                            "game_res/fishdntg_fish_19.png",
                            "game_res/whater.png",
                            "game_res/watch.png",
                            "game_res/wave.png",
                            "game_res/image.png",
                            "game_res/fishdntg_game1.png"    }

function PreLoading.resetData()                 -- 重置进度条界面数据
    PreLoading.bLoadingFinish = false
	PreLoading.loadingPer = 0
	PreLoading.bFishData = false
end

function PreLoading.StopAnim(bRemove)           -- GameViewLayer调用  bRemove是否删除进度条界面
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

function PreLoading.addEvent(scene)
    local function eventListener(event)   -- 通知监听
        cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(g_var(cmd).Event_FishCreate)
        PreLoading.Finish(scene)
    end

    local listener = cc.EventListenerCustom:create(g_var(cmd).Event_FishCreate, eventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function PreLoading.Finish(scene)
    PreLoading._scene = scene
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
                PreLoading._scene:BuildSceneKindTrace()
            end)
			layer:stopAllActions()
			layer:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),fishTrace,callfunc))
		end
	end
end

function PreLoading.updatePercent(percent)
	if nil ~= PreLoading.loadingBar then
		local dt = 1.0
		if percent == 100 then
			dt = 2.0
		end

        PreLoading.loadingBar:stopAllActions()
		PreLoading.loadingBar:runAction(cc.ProgressTo:create(dt, percent))

        PreLoading.fish:stopActionByTag(1)
		local move =  cc.MoveTo:create(dt,cc.p(1073*(percent/100)-36, PreLoading.loadingBar:getContentSize().height/2))
		move:setTag(1)
		PreLoading.fish:runAction(move)
	end
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

function PreLoading.loadTextures(scene)         -- GameViewLayer调用  scene = GameLayer
    local m_nImageOffset = 0                    -- 当前已加载的资源数量
	local totalSource = 27                      -- 总共需加载的资源数量

    local function imageLoaded(texture)
        m_nImageOffset = m_nImageOffset + 1
        PreLoading.loadingPer = m_nImageOffset*3
        PreLoading.updatePercent(PreLoading.loadingPer) 

        if m_nImageOffset == totalSource then
            for i = 1, #PreLoading.plistPath do
                cc.SpriteFrameCache:getInstance():addSpriteFrames(PreLoading.plistPath[i])
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
        else
            cc.Director:getInstance():getTextureCache():addImageAsync(PreLoading.pngPath[m_nImageOffset+1], imageLoaded)
        end
    end

	PreLoading.GameLoadingView()    -- 进度条
    cc.Director:getInstance():getTextureCache():addImageAsync(PreLoading.pngPath[1], imageLoaded)
	PreLoading.addEvent(scene)
end

function PreLoading.unloadTextures( )
    for i = 1, #PreLoading.plistPath do
	    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(PreLoading.plistPath[i])
        cc.Director:getInstance():getTextureCache():removeTextureForKey(PreLoading.pngPath[i])
    end
	
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function PreLoading.removeAllActions()
    for index=0,PreLoading.FishTypeNum - 1 do
		cc.AnimationCache:getInstance():removeAnimation(string.format("fish_%d_yd", index))
    	cc.AnimationCache:getInstance():removeAnimation(string.format("fish_%d_die", index))
	end
    
    cc.AnimationCache:getInstance():removeAnimation("bglu_gun_1")
    cc.AnimationCache:getInstance():removeAnimation("bglu_gun_2")
    cc.AnimationCache:getInstance():removeAnimation("bglu_gun_3")
    cc.AnimationCache:getInstance():removeAnimation("bglu_str_1")
    cc.AnimationCache:getInstance():removeAnimation("bglu_str_2")
    cc.AnimationCache:getInstance():removeAnimation("bglu_str_3")
    cc.AnimationCache:getInstance():removeAnimation("LChainFlag")
    cc.AnimationCache:getInstance():removeAnimation("GreenLight")
    cc.AnimationCache:getInstance():removeAnimation("BlueLight")
    cc.AnimationCache:getInstance():removeAnimation("FishCoin")
    cc.AnimationCache:getInstance():removeAnimation("WaterAnim")
    cc.AnimationCache:getInstance():removeAnimation("watchAnim")
    cc.AnimationCache:getInstance():removeAnimation("WaveAnim")
    cc.AnimationCache:getInstance():removeAnimation("GoldAnim")
    cc.AnimationCache:getInstance():removeAnimation("FishBall")
    cc.AnimationCache:getInstance():removeAnimation("FishLight")

    -- 奖励金动画
    cc.AnimationCache:getInstance():removeAnimation("animation_reward_box")
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
    --                          0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16 17  18  19  20 21 22 23  24  25  26  27
	local fishFrameDeadNum = {  5,  3,  3, 10,  3,  6,  3,  6,  4,  7,  4,  4,  4,  3,  6,  6,  4, 3, 10,  0,  9, 4, 4, 4, 12,  9,  0, 13}
    local fishFrameMoveNum = { 12, 16, 12, 12, 12, 13, 37, 20, 12, 16, 12, 12, 12, 10, 12, 12, 12, 9,  5, 15, 15, 9, 9, 9, 19,  8, 18,  9}
    local ydAnimtime = 0.1
    local dieAnimtime = 0.05
	for index = 0, PreLoading.FishTypeNum - 1 do   --鱼游动动画
        PreLoading.readFishAnimation("fish_%d_yd_%d.png" , "fish_%d_yd" , index, fishFrameMoveNum[index+1], ydAnimtime)
		PreLoading.readFishAnimation("fish_%d_die_%d.png", "fish_%d_die", index, fishFrameDeadNum[index+1], dieAnimtime)
	end
    
   	PreLoading.readAnimation("fishex_27_die_1_" , "bglu_gun_1"  , 23  , 0.1  , 1)
   	PreLoading.readAnimation("fishex_27_die_2_" , "bglu_gun_2"  , 27  , 0.1  , 1)
   	PreLoading.readAnimation("fishex_27_die_3_" , "bglu_gun_3"  , 16  , 0.1  , 1)
   	PreLoading.readAnimation("fishex_27_str_1_" , "bglu_str_1"  , 15  , 0.1  , 1)
   	PreLoading.readAnimation("fishex_27_str_2_" , "bglu_str_2"  ,  9  , 0.1  , 1)
   	PreLoading.readAnimation("fishex_27_str_3_" , "bglu_str_3"  , 12  , 0.1  , 1)
   	PreLoading.readAnimation("LChainFlag_"      , "LChainFlag"  ,  4  , 0.1  , 1)
   	PreLoading.readAnimation("Light_Green_"     , "GreenLight"  ,  5  , 0.1  , 1)
   	PreLoading.readAnimation("Light_Blue_"      , "BlueLight"   ,  5  , 0.1  , 1)
   	PreLoading.readAnimation("dntg_gold_coin_"  , "FishCoin"    ,  7  , 0.08 , 1)
   	PreLoading.readAnimation("water_"           , "WaterAnim"   ,  12 , 0.12 , 1)
    PreLoading.readAnimation("watch_"           , "watchAnim"   ,  24 , 0.08 , 1)
    PreLoading.readAnimation("wave"             , "WaveAnim"    ,  2  , 0.5  , 1)
    PreLoading.readAnimation("dntg_gold_coin_"  , "GoldAnim"    ,  7  , 0.08 , 1)
    PreLoading.readAniByFileName("game_res/fish_bomb_ball.png"  ,  70 , 70   , 2, 5, "FishBall")
    PreLoading.readAniByFileName("game_res/fish_bomb_light.png" ,  40 , 256  , 1, 6, "FishLight")
end

function PreLoading.GameLoadingView()                                   -- 创建读取界面(读取界面图层, 背景图, 进度条背景, 进度条, 鱼)
    local xoffset = 0  --大屏手机偏移量
    if yl.WIDTH > yl.DESIGN_WIDTH then 
        xoffset = (yl.WIDTH - yl.DESIGN_WIDTH)/2
    end
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
	loadingBarBG:setPosition(cc.p(yl.WIDTH/2, 90))
	layer:addChild(loadingBarBG)
                                                                        -- 设置进度条
	PreLoading.loadingBar = cc.ProgressTimer:create(cc.Sprite:create("loading/loading_cell.png"))
	PreLoading.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	PreLoading.loadingBar:setMidpoint(cc.p(0,0.5))
	PreLoading.loadingBar:setBarChangeRate(cc.p(1,0))
    PreLoading.loadingBar:setPosition(cc.p(loadingBarBG:getContentSize().width/2,loadingBarBG:getContentSize().height/2))
    PreLoading.loadingBar:runAction(cc.ProgressTo:create(0.2,20))       -- 默认读取到20
    loadingBarBG:addChild(PreLoading.loadingBar)

    PreLoading.fish = cc.Sprite:create("loading/loading_1.png")         -- 设置读取界面鱼(标签)
    PreLoading.fish:setAnchorPoint(cc.p(0.5,0.5))
    PreLoading.fish:setPosition(cc.p(-36, PreLoading.loadingBar:getContentSize().height/2))
    loadingBarBG:addChild(PreLoading.fish)
    PreLoading.fish:stopAllActions()

	local frames = {}                                                   -- 设置鱼动画
   	local actionTime = 0.1
	for i = 1, 6 do
		local frameName = string.format("loading/loading_".."%d.png", i)
		local frame = cc.SpriteFrame:create(frameName,cc.rect(0,0,180,80))
		table.insert(frames, frame)
	end
                                                                        -- 循环播放动画
	local animation = cc.Animation:createWithSpriteFrames(frames,actionTime)
    local action = cc.RepeatForever:create(cc.Animate:create(animation))
	PreLoading.fish:runAction(action)
                                                                        -- 移动到进度条20得位置
	local move = cc.MoveTo:create(0.2, cc.p(1073*(20/100)-36, PreLoading.loadingBar:getContentSize().height/2))
    move:setTag(1)
    PreLoading.fish:runAction(move)
    
    local moveTime = 0.1
    local letterName = { "loading/loading_str_1.png", 
                         "loading/loading_str_2.png", 
                         "loading/loading_str_3.png", 
                         "loading/loading_str_4.png", 
                         "loading/loading_str_5.png", 
                         "loading/loading_str_6.png", 
                         "loading/loading_str_7.png", 
                         "loading/loading_str_8.png", 
                         "loading/loading_str_8.png", 
                         "loading/loading_str_8.png", }

    local letterPosY = { yl.HEIGHT/2-235, 
                         yl.HEIGHT/2-235,  
                         yl.HEIGHT/2-235,  
                         yl.HEIGHT/2-235 + 1,  
                         yl.HEIGHT/2-235 + 1,  
                         yl.HEIGHT/2-235 + 1,  
                         yl.HEIGHT/2-235 + 1,  
                         yl.HEIGHT/2-242,  
                         yl.HEIGHT/2-242,  
                         yl.HEIGHT/2-242, }

    local posX = yl.WIDTH/2 - 194/2
    for i = 1, 10 do
        local letter = display.newSprite(letterName[i])
        letter:setAnchorPoint(cc.p(0, 0.5))
        letter:setPosition(cc.p(posX, letterPosY[i]))
        layer:addChild(letter)
        letter:runAction(
            cc.Sequence:create(
                cc.DelayTime:create((i-1)*moveTime), 
                cc.CallFunc:create(function(sender)
                    sender:runAction(
                        cc.RepeatForever:create(
                            cc.Sequence:create(
                                cc.MoveBy:create(moveTime, cc.p(0, 10)), 
                                cc.MoveBy:create(moveTime, cc.p(0, -10)), 
                                cc.DelayTime:create(moveTime*9)
                            )
                        )
                    )
                end)
            )
        )
        posX = posX + letter:getContentSize().width + 1
    end
    
    local light = display.newSprite("loading/loading_icon_5.png")
    light:setPosition(cc.p(315+xoffset, 448))
    layer:addChild(light)
    
    local sunwukong = display.newSprite("loading/loading_icon_2.png")
    sunwukong:setAnchorPoint(cc.p(0.5, 0))
    sunwukong:setScale(0.8)
    sunwukong:setPosition(cc.p(257+xoffset, 323))
    sunwukong:runAction(
        cc.Sequence:create(
            cc.EaseExponentialOut:create(
                cc.Spawn:create(
                    cc.MoveTo:create(1, cc.p(556+xoffset, 462)), 
                    cc.ScaleTo:create(1, 1)
                )
            ),
            cc.CallFunc:create(function(sender)
                sender:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create(
                            cc.MoveTo:create(1, cc.p(556+xoffset, 482)), 
                            cc.MoveTo:create(1, cc.p(556+xoffset, 442))
                        )
                    )
                )
            end)
        )
    )
    layer:addChild(sunwukong)
    
    local title = display.newSprite("loading/loading_icon_1.png")
    title:setPosition(cc.p(yl.WIDTH/2, 400))
    layer:addChild(title)

    local fish1 = display.newSprite("loading/loading_icon_3.png")
    fish1:setPosition(cc.p(276+xoffset, 316))
    fish1:setAnchorPoint(cc.p(0.68, 0.47))
    fish1:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.Spawn:create(cc.RotateTo:create(1, 5), cc.MoveTo:create(1, cc.p(276+xoffset, 336))), 
                cc.Spawn:create(cc.RotateTo:create(1, -5), cc.MoveTo:create(1, cc.p(276+xoffset, 296)))
            )
        )
    )
    layer:addChild(fish1)

    local fish2 = display.newSprite("loading/loading_icon_4.png")
    fish2:setPosition(cc.p(1031+xoffset, 274))
    fish2:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.Spawn:create(cc.ScaleTo:create(1, 1.05), cc.MoveTo:create(1, cc.p(1031+xoffset, 294))), 
                cc.Spawn:create(cc.ScaleTo:create(1, 0.95), cc.MoveTo:create(1, cc.p(1031+xoffset, 254)))
            )
        )
    )
    layer:addChild(fish2)

end

return PreLoading