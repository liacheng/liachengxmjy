--[[游戏的设置界面当前只支持音乐音效]]
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameSetLayer = class("GameSetLayer", function(version, index)
    local gamesetlayer = display.newLayer()
    return gamesetlayer
end)

GameSetLayer.TAG_BACKGROUND  =  0   
GameSetLayer.TAG_MUSIC_OPEN  =  1   
GameSetLayer.TAG_MUSIC_CLOSE =  2
GameSetLayer.TAG_SOUND_OPEN  =  3
GameSetLayer.TAG_SOUND_CLOSE =  4
GameSetLayer.TAG_CLOSE       =  5

-- 进入场景而且过渡动画结束时候触发。
function GameSetLayer:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function GameSetLayer:onExitTransitionStart()
	self:unregisterScriptTouchHandler()
    return self
end

function GameSetLayer:ctor(version)
    if version == nil then
        return nil
    end

	--回调函数
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			self:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			self:onExitTransitionStart()
		end
	end)

	--按键监听
	local onBtnCallBack = function(ref, type)
        if ref:getTag() == GameSetLayer.TAG_CLOSE then
            ExternalFun.btnEffect(ref, type)
        end

        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    
	self.m_pNode = cc.CSLoader:createNode("game/GameSetLayer.csb")
    self.m_pNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pNode:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
	self:addChild(self.m_pNode)

    local bgNode = self.m_pNode:getChildByName("m_pIconBg1")
    
    self.m_pBtnMusicOpen = self.m_pNode:getChildByName("m_pBtnMusicOpen")
    self.m_pBtnMusicClose = self.m_pNode:getChildByName("m_pBtnMusicClose")
    self.m_pBtnSoundOpen = self.m_pNode:getChildByName("m_pBtnSoundOpen")
    self.m_pBtnSoundClose = self.m_pNode:getChildByName("m_pBtnSoundClose")
    self.m_pBtnClose = self.m_pNode:getChildByName("m_pBtnClose")

    self.m_pBtnMusicOpen:setTag(GameSetLayer.TAG_MUSIC_OPEN)
    self.m_pBtnMusicClose:setTag(GameSetLayer.TAG_MUSIC_CLOSE)
    self.m_pBtnSoundOpen:setTag(GameSetLayer.TAG_SOUND_OPEN)
    self.m_pBtnSoundClose:setTag(GameSetLayer.TAG_SOUND_CLOSE)
    self.m_pBtnClose:setTag(GameSetLayer.TAG_CLOSE)

    self.m_pBtnMusicOpen:addTouchEventListener(onBtnCallBack)
    self.m_pBtnMusicClose:addTouchEventListener(onBtnCallBack)
    self.m_pBtnSoundOpen:addTouchEventListener(onBtnCallBack)
    self.m_pBtnSoundClose:addTouchEventListener(onBtnCallBack)
    self.m_pBtnClose:addTouchEventListener(onBtnCallBack)
    
    --版本号
    local verstr = "当前版本: ver " .. appdf.BASE_C_VERSION .. "." .. version
    self.m_pTextVersion = self.m_pNode:getChildByName("m_pTextVersion")
    self.m_pTextVersion:setFontName("fonts/round_body.ttf")
    self.m_pTextVersion:setString(verstr)

    ExternalFun.showLayer(self, self.m_pNode, true, true)
    self:updateBtnState()
end

--按键点击
function GameSetLayer:onButtonClickedEvent(tag, ref)
	if self.isDiss == true then
		return
	end

    if tag == GameSetLayer.TAG_CLOSE then
        ExternalFun.playClickEffect()
        ExternalFun.hideLayer(self, self.m_pNode, false)
    elseif tag == GameSetLayer.TAG_MUSIC_OPEN then
		GlobalUserItem.setMusicVolume(100)
    elseif tag == GameSetLayer.TAG_MUSIC_CLOSE then
        GlobalUserItem.setMusicVolume(0)
    elseif tag == GameSetLayer.TAG_SOUND_OPEN then
		GlobalUserItem.setSoundVolume(100)
    elseif tag == GameSetLayer.TAG_SOUND_CLOSE then
		GlobalUserItem.setSoundVolume(0)
    end
    self:updateBtnState()
end

function GameSetLayer:updateBtnState()
    -- 检测当前音乐音效是否开启
    self.m_pBtnMusicOpen:setVisible(GlobalUserItem.nMusic == 0)
    self.m_pBtnMusicClose:setVisible(GlobalUserItem.nMusic == 100)
    self.m_pBtnSoundOpen:setVisible(GlobalUserItem.nSound == 0)
    self.m_pBtnSoundClose:setVisible(GlobalUserItem.nSound == 100)
end

function GameSetLayer:onShow()
    ExternalFun.showLayer(self, self.m_pNode, true, true)
end

return GameSetLayer
