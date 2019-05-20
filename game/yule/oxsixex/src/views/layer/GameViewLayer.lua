local GameViewLayer = class("GameViewLayer",function(scene)
    local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

local module_pre        = "game.yule.oxsixex.src"
local QBasePlayer       = import(".QBasePlayer")
local QMyPlayer         = import(".QMyPlayer")
local QOtherPlayer      = import(".QOtherPlayer")
local SettingLayer      = import(".SettingLayer")
local PopWaitLayer      = import(".PopWaitLayer")
local cmd               = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local GameLogic         = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.GameLogic")
local NGResources       = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.NGResources")
local PopupInfoHead     = appdf.req(appdf.CLIENT_SRC.."external.PopupInfoHead")
local ExternalFun       = appdf.req(appdf.EXTERNAL_SRC.."ExternalFun")
local GameChatLayer     = appdf.req(appdf.PUB_GAME_VIEW_SRC.."GameChatLayer")
local PromptLayer       = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.layer.PromptLayer")
local HelpLayer         = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.cocosUiPath = "game/csb/gameLayer.csb"
GameViewLayer.TAG_NAME = 1
GameViewLayer.TAG_MONEY = 2
GameViewLayer.TAG_HEAD = 3
GameViewLayer.TAG_ZHUANG = 4
GameViewLayer.TAG_HEAD_BOTTOM = 5
GameViewLayer.RES_PATH  = "game/yule/oxsixex/res/"
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

GameViewLayer.TAG_CLOCK = 200

--第一张背景图下面的资源
GameViewLayer.UiTag = {
    eImageBj                = 0,
    eBtnBack                = 1,
    eBtnSet                 = 2,
    eBtnHelp                = 3,
    eBtnChangeDesk          = 4,
    eBtnStart               = 5,    -- 准备
    eBtnLiangPai            = 8,    -- 摊牌
    eBtnTishi               = 9,
    eImageHeadBjBegin       = 10,
    eImageHeadBjMy          = 13,
    eImageHeadBjEnd         = 15,
    eLayerZhunBei           = 20,
    eImageAdNiuK            = 21,
    eImageTipsWaitOxCard    = 22,
    --eBtnSoundOff          = 23,
    eBtnAutoGame            = 25,
    eBtnDownFrame           = 26,
    eBtnIntroduce           = 27,
    eBtnWinUser             = 28,
    eBtnMessage             = 99,
    eBtnChat                = 100
}

function GameViewLayer:onExit()
    print("GameViewLayer onExit") 
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/game.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game/game.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("game/effect.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("game/effect.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function GameViewLayer:ctor(scene)
	self._scene = scene
    self.m_pClockLayer_ = nil
    self.m_wait = nil
    self.m_bAutoGame_ = false
    self.m_pUserItem_ = self._scene._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem_.wTableID
    self.m_nChairID = self.m_pUserItem_.wChairID	
    self.m_pPlayers = {}
    self.m_tHeadMovePos_ = {}
    self.m_tHeadMovePos_[0] = cc.p(409,850)
    self.m_tHeadMovePos_[1] = cc.p(-100,489)
    self.m_tHeadMovePos_[2] = cc.p(-100,294)
    self.m_tHeadMovePos_[3] = cc.p(426,-100)
    self.m_tHeadMovePos_[4] = cc.p(1434,294)
    self.m_tHeadMovePos_[5] = cc.p(1434,489)
    self.m_tHeadPos_ = {}
    self.m_tHeadPos_[0] = cc.p(409,657)
    self.m_tHeadPos_[1] = cc.p(95,489)
    self.m_tHeadPos_[2] = cc.p(95,291)
    self.m_tHeadPos_[3] = cc.p(426,110)
    self.m_tHeadPos_[4] = cc.p(1240,291)
    self.m_tHeadPos_[5] = cc.p(1240,489)
    self.m_tCardPos_ = {}
    self.m_tCardPos_[0] = cc.p(520,500)
    self.m_tCardPos_[1] = cc.p(175,425)
    self.m_tCardPos_[2] = cc.p(175,225)
    self.m_tCardPos_[3] = cc.p(515,45)
    self.m_tCardPos_[4] = cc.p(850,225)
    self.m_tCardPos_[5] = cc.p(850,425)
    self.ptWaitFlag = cc.p(667,500)
    self:initUi()
    self.m_tCardPile = {}
    ExternalFun.registerNodeEvent(self) -- 节点事件
    ExternalFun.setBackgroundAudio("sound_res/oxsixex_bgm.mp3")
end

function GameViewLayer:getGameLayerObj()
    return self._scene
end

function GameViewLayer:getHeadPos()
    return self.m_tHeadPos_
end

function GameViewLayer:initUi()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("game/effect.plist")

    self.rootLayer, self.resourceNode_ = ExternalFun.loadRootCSB(self.cocosUiPath, self)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
	
    self.m_pChatLayer_ = GameChatLayer:create(self._scene._gameFrame):addTo(self, 3)

    self:initBtn()
    self.m_pNodeScore = self.resourceNode_:getChildByName("m_pNodeScore")
    local qImage = nil

    qImage = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eImageBj)
    if qImage then
        qImage:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    end

    --头像背景
    for i=GameViewLayer.UiTag.eImageHeadBjBegin,GameViewLayer.UiTag.eImageHeadBjEnd do
        qImage = self.resourceNode_:getChildByTag(i)
        if qImage then
            qImage:setVisible(false)
            qImage:getChildByName("nickname_text"):setFontName(appdf.FONT_FILE)
            qImage:getChildByName("coin_text"):setFontName(appdf.FONT_FILE)
        end
    end

     --准备层
    local pLayer = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eLayerZhunBei)
    if pLayer then
        for i = 1, cmd.GAME_PLAYER	 do
            local ready = pLayer:getChildByTag(i - 1)
            ready:setVisible(false)
        end
    end

    self:showPlayerInfo(cmd.MY_VIEW_CHAIRID,self.m_pUserItem_)
    -- 玩家头像
	self.m_bNormalState = {}
    self.IsShowWait = false
    self.m_WaitFlag = nil
    self.ShowWaitPlayer = {}
     --加载6个玩家
    local playerObj = nil
	for i = 1,cmd.GAME_PLAYER do
        local iViewID = i-1
        if iViewID == cmd.MY_VIEW_CHAIRID then
            playerObj = QMyPlayer:create(self, self.m_tHeadPos_[iViewID],self.m_tCardPos_[iViewID])
        else
            playerObj = QOtherPlayer:create(self, iViewID,self.m_tHeadPos_[iViewID],self.m_tCardPos_[iViewID])
        end
        self.m_pPlayers[iViewID] = playerObj     
        self.m_pNodeScore:addChild(playerObj)
        --等待操作
        self.ShowWaitPlayer[i] = false
    end
    
    --点击牌显示点数的框
    qImage = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eImageAdNiuK)
    if qImage then
        qImage:setVisible(false)
    end

    --等待摊牌
    qImage = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eImageTipsWaitOxCard)
    if qImage then
        qImage:setVisible(false)
    end

    --clock
    self.m_pImageClock_ = ccui.ImageView:create(NGResources.GameRes.sClockBjPath,ccui.TextureResType.plistType)
    self.m_pImageClock_:setPosition(cc.p(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2))
    self.m_pImageClock_:setVisible(false)
    self.m_pImageClock_:setLocalZOrder(2)
    self:addChild(self.m_pImageClock_)

    self.m_pTextClock_ = ccui.ImageView:create(NGResources.GameRes.sClockTextPath,ccui.TextureResType.plistType)
    self.m_pTextClock_:setPosition(cc.p(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2+90))
    self.m_pTextClock_:setVisible(false)
    self.m_pTextClock_:setLocalZOrder(2)
    self:addChild(self.m_pTextClock_)

    self.m_pNumClock_ = ccui.Text:create("", "", 32)
    self.m_pNumClock_:setColor(cc.c3b(197, 0, 0))
    self.m_pNumClock_:setPosition(cc.p(self.m_pImageClock_:getContentSize().width/2,self.m_pImageClock_:getContentSize().height/2-7))   
    self.m_pImageClock_:addChild(self.m_pNumClock_)

    --下拉按钮
    self.spDownPanelBg = self.resourceNode_:getChildByName("panel_down"):setScale(0) 
    self.spDownPanelBg:removeFromParent()
    self:addChild(self.spDownPanelBg,11)

    -- 说明按钮
    self.spIntroducePanelBg = self.resourceNode_:getChildByName("panel_introduce"):setScale(0)  
    self.spIntroducePanelBg:removeFromParent()
    self:addChild(self.spIntroducePanelBg,11)

    -- 底注
    self.cellScore = self.resourceNode_:getChildByName("panel_antes"):getChildByName("txt_antex")
    self.cellScore:setFontName(appdf.FONT_FILE)
    --创建准备按钮
    self:createStartBtn()

     --彩池帮助按钮
    self.resourceNode_:getChildByName("panel_gold"):setVisible(false)
    self.m_lBtnGoldHelp = self.resourceNode_:getChildByName("panel_gold"):getChildByName("btn_gold_help")
    self.m_lTxtGold = self.resourceNode_:getChildByName("panel_gold"):getChildByName("txt_lottery")
    self.m_lBtnGoldHelp:addTouchEventListener(handler(self,self.goldHelpClick))
    self.goldIntroduce = self.resourceNode_:getChildByName("panel_gold_introduce")
    self.goldIntroduce:removeFromParent()
    self:addChild(self.goldIntroduce,10)
    self.goldIntroduceClose = self.goldIntroduce:getChildByName("btn_close_gold")
    self.goldIntroduceClose:addTouchEventListener(handler(self,self.goldCloseClick))

    --中彩用户按钮
    self.goldWin = self.resourceNode_:getChildByName("panel_win_glod") 
    self.goldWin:removeFromParent()
    self:addChild(self.goldWin,10)
    self.goldWinClose = self.goldWin:getChildByName("btn_close_win_gold") 
    self.goldWinClose:addTouchEventListener(handler(self,self.goldCloseClick))

    self.Toast = self.resourceNode_:getChildByName("tips_wait_opencard")
    self.Toast:removeFromParent()
    self:addChild(self.Toast,11)
end

function GameViewLayer:goldCloseClick(sender,type)
    ExternalFun.btnEffect(sender, type)
    if type == ccui.TouchEventType.ended then
        if self.goldWin:isVisible() then 
            self.goldWin:runAction(cc.Sequence:create(
                               cc.ScaleTo:create(0.2, 0, 0, 0),
		                       cc.CallFunc:create(function(ref)   
                                    self.goldWin:stopAllActions()                            
                                    self.goldWin:setVisible(false)
                               end)))        
        end
        if self.goldIntroduce:isVisible() then 
            self.goldIntroduce:runAction(cc.Sequence:create(
                               cc.ScaleTo:create(0.2, 0, 0, 0),
		                       cc.CallFunc:create(function(ref)  
                                    self.goldIntroduce:stopAllActions()                               
                                    self.goldIntroduce:setVisible(false)
                               end))) 
        end                          
    end
end

function GameViewLayer:showWinUser(t_data)
    self.goldWin:setScale(0)
    self.goldWin:setVisible(true)

    local lv_tab = self.goldWin:getChildByName("list_win_user")
    lv_tab:removeAllChildren()
    lv_tab:setScrollBarEnabled( false )    -- 隐藏滚动条

    if #t_data == 0 then
        self.Toast:setVisible(true)
        self.Toast:setScale(0)
        self.Toast:getChildByName("text"):setString("暂时没有中奖用户")
        self.Toast:runAction(cc.Sequence:create(
                           cc.ScaleTo:create(0.25, 1),
                           cc.DelayTime:create(0.8),
                           cc.ScaleTo:create(0.25, 0),
		                   cc.CallFunc:create(function(ref)
                                self.Toast:setVisible(false)
                           end)))
        return
    else
        -- 创建列表
        local index = 1
        for i,v in pairs(t_data) do
            local item = self.resourceNode_:getChildByName("panel_frame")
            local itemClone = item:clone()
            if index%2 == 1 then
                display.newSprite("#oxsixexgold_bg_septum.png"	,{scale9 = true ,capInsets=cc.rect(243,19,106,12)})
                        :setContentSize(cc.size(790, 50))  
                        :setAnchorPoint(0,0)
                        :setPosition(0,0)
                        :setLocalZOrder(-1)
                        :addTo(itemClone)
            end
            index =  index+1
            local item_time1= itemClone:getChildByName("txt1")
            local item_time2= itemClone:getChildByName("txt2")
            local item_name= itemClone:getChildByName("txt3")
            local item_goldtemp= itemClone:getChildByName("txt4")
            item_time1:setFontName(appdf.FONT_FILE)
            item_time2:setFontName(appdf.FONT_FILE)
            item_name:setFontName(appdf.FONT_FILE) 
            item_goldtemp:setVisible(false)
            item_time1:setString(os.date("%Y/%m/%d", v.time))
            item_time2:setString(os.date("%H:%M:%S", v.time))
            item_name:setString(v.szNickName)
            lv_tab:pushBackCustomItem(itemClone)

            local item_gold = cc.LabelAtlas:_create("0000000", GameViewLayer.RES_PATH.."game/oxsixex_fonts_num_gold.png", 18, 25, string.byte("*"))
            :setPosition(item_goldtemp:getPosition())
            :setAnchorPoint(cc.p(0.5, 0.5))
            :addTo(itemClone)
            item_gold:setString(v.winGold)

        end
    end

    local goldLight = self.goldWin:getChildByName("sprite_light_win")
    goldLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    self.goldWin:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1, 1, 1)))
end

function GameViewLayer:goldHelpClick(sender,type)
    ExternalFun.btnEffect(sender, type)
    if type == ccui.TouchEventType.ended then
        self:OnIntroduce(nil,ccui.TouchEventType.began)
        self:OnDownFrame(nil,ccui.TouchEventType.began) 
        self.goldWin:setVisible(false)
        --遮罩层
        local btcallback = function(ref, tType) 
            ExternalFun.btnEffect(ref, tType)
            if type == ccui.TouchEventType.ended then
                if self.goldIntroduce:isVisible() == true then 
                    self.goldIntroduce:setVisible(false)
                    return 
                end 
                self.touchEnable:removeFromParent()                
            end
        end
        
        self.touchEnable = ccui.Layout:create()
        self.touchEnable:setContentSize(cc.size(yl.DESIGN_WIDTH, yl.DESIGN_HEIGHT))
        self.touchEnable:setAnchorPoint(cc.p(0.5, 0.5))
        self.touchEnable:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
        self.touchEnable:addTouchEventListener(btcallback)
        self.touchEnable:setTouchEnabled(true)
        self.touchEnable:setSwallowTouches(true)
        
        self:addChild(self.touchEnable,9)

        self.goldIntroduce:setScale(0)
        self.goldIntroduce:setVisible(true)

        local goldLight = self.goldIntroduce:getChildByName("sprite_light")

        self.goldIntroduce:runAction(cc.Sequence:create(
                                cc.ScaleTo:create(0.2, 1, 1, 1),
                                cc.DelayTime:create(2.3),
		                        cc.CallFunc:create(function(ref)
                                end)))

        goldLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    end
end

function GameViewLayer:createStartBtn()
    self.startBtn = ccui.Button:create("oxsixex_btn_m1bottom_normal.png","oxsixex_btn_m1bottom_normal.png","oxsixex_btn_m1bottom_normal.png",ccui.TextureResType.plistType)
                    :setAnchorPoint(0.5,0.5)
                    :setPosition(yl.DESIGN_WIDTH/2,270)
                    :setVisible(false)
                    :setTag(GameViewLayer.UiTag.eBtnStart)
                    :setScale9Enabled(true)
                    :setContentSize(cc.size(170,78))
                    :addTo(self)
                    
    display.newSprite("#oxsixex_txt_alread.png")
        :setAnchorPoint(0.5,0.5)
        :setPosition(self.startBtn:getContentSize().width/2,self.startBtn:getContentSize().height/2)
        :addTo(self.startBtn)
    self.startBtn:addTouchEventListener(handler(self,self.menuClick))
end

function GameViewLayer:initBtn()
    local qBtn = nil
    for i = GameViewLayer.UiTag.eBtnLiangPai,GameViewLayer.UiTag.eBtnTishi do
        qBtn = self.resourceNode_:getChildByTag(i)
        if qBtn then
            if i == GameViewLayer.UiTag.eBtnLiangPai then
                qBtn:setVisible(false)
            elseif i == GameViewLayer.UiTag.eBtnTishi then
                qBtn:setVisible(false)
            end

            qBtn:addTouchEventListener(handler(self,self.menuClick))
        end
    end

    qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnAutoGame)
    if qBtn then
        qBtn:addTouchEventListener(handler(self,self.OnAutoGame))
    end

    qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnDownFrame)
    if qBtn then
        qBtn:addTouchEventListener(handler(self,self.OnDownFrame))
    end

    qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnIntroduce)
    if qBtn then
        qBtn:addTouchEventListener(handler(self,self.OnIntroduce))
    end

    qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnMessage)
    if qBtn then
        qBtn:addTouchEventListener(handler(self,self.OnChat))
    end

    qBtn = self.resourceNode_:getChildByName("btn_win_user")
    if qBtn then
        qBtn:setTag(GameViewLayer.UiTag.eBtnWinUser)
        qBtn:setVisible(false)
        qBtn:addTouchEventListener(handler(self,self.menuClick))
    end
   
    self:onTouch(handler(self,self.leftTopClick))
end

function GameViewLayer:OnAutoGame(sender,type)
    ExternalFun.btnEffect(sender, type)
    if type == ccui.TouchEventType.ended then        
        if sender then
            if self.m_bAutoGame_ then
                self.m_bAutoGame_ = false
                sender:getChildByName("img_autogame"):setVisible(false)
                sender:getChildByName("img_cancel"):setVisible(true)
                return
            else
                if false == self.m_pPlayers[cmd.MY_VIEW_CHAIRID].m_bCardAnimation then                
                    self.m_bAutoGame_ = true
                    sender:getChildByName("img_autogame"):setVisible(true)
                    sender:getChildByName("img_cancel"):setVisible(false)
                end
            end
        end
        
        local gameStatus = self._scene:getGameStatues()
        if gameStatus ==  cmd.GameStatues.FREE_STATUES then
            self:showBtn(false)
            self._scene:onBtnSendMessage(GameViewLayer.UiTag.eBtnStart)
            self._scene:KillGameClock()
            self:stopHeadClock(3)
        elseif gameStatus == cmd.GameStatues.START_STATUES then
            if true == self.m_pPlayers[cmd.MY_VIEW_CHAIRID].m_bCardAnimation then
                print("发牌动画未执行完成")
            else
                local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,self.m_nChairID)
                if useritem.cbUserStatus == yl.US_PLAYING then 
                    self:OnOpenCard()
                end
            end
        elseif gameStatus == cmd.GameStatues.END_STATUES then
            --self:OnAutoGame(nil,ccui.TouchEventType.ended)
        end
    end
end

function GameViewLayer:menuClick(sender,type)
    ExternalFun.btnEffect(sender, type)
    if type == ccui.TouchEventType.ended then
        local node = sender
		local tar = node:getTag()
        if tar == GameViewLayer.UiTag.eBtnBack  then 
            self:OnDownMenuSwitchAnimate()
            self._scene:onBtnSendMessage(tar)
        elseif tar == GameViewLayer.UiTag.eBtnSet then
            self:OnDownMenuSwitchAnimate()
            if nil == self.layerSet then 
     	        local mgr = self._scene._scene:getApp():getVersionMgr()
	            local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
		        self.layerSet = SettingLayer:create(nVersion)
                self.layerSet:setLocalZOrder(10)
                self:addChild(self.layerSet)                
            else
                self.layerSet:onShow()
            end
        elseif tar == GameViewLayer.UiTag.eBtnHelp then
            self:OnDownMenuSwitchAnimate()
            if nil == self.layerHelp then
                self.layerHelp = HelpLayer:create(self, cmd.KIND_ID, 0)
                self.layerHelp:setLocalZOrder(10)
                self:addChild(self.layerHelp)               
            else
                self.layerHelp:onShow()
            end
        elseif tar == GameViewLayer.UiTag.eBtnChangeDesk then
            self._scene:onBtnSendMessage(tar)
            self:OnDownMenuSwitchAnimate()
        elseif tar == GameViewLayer.UiTag.eBtnChat then
            self.m_pChatLayer_:showGameChat(true)
        elseif tar == GameViewLayer.UiTag.eBtnStart then
            self:showBtn(false)
            self._scene:onBtnSendMessage(tar)
            self:stopHeadClock()
            self._scene:KillGameClock()
        elseif tar == GameViewLayer.UiTag.eBtnLiangPai then
            if true == self.m_pPlayers[cmd.MY_VIEW_CHAIRID].m_bCardAnimation then
                print("发牌动画执行")
            else
                self:OnOpenCard()
            end
        elseif tar == GameViewLayer.UiTag.eBtnTishi then
            if true == self.m_pPlayers[cmd.MY_VIEW_CHAIRID].m_bCardAnimation then
                print("发牌动画执行")
            else
                self:OnHintOx()
            end
        elseif tar == GameViewLayer.UiTag.eBtnWinUser then
            self._scene:onBtnSendMessage(tar)
            self:OnIntroduce(nil,ccui.TouchEventType.began)
            self:OnDownFrame(nil,ccui.TouchEventType.began) 
        end
    end
end

function GameViewLayer:OnDownMenuSwitchAnimate()
    self.bDownBtnInOutside = not self.bDownBtnInOutside
    if self.spDownPanelBg:getScaleX() == 1 then
        self.spDownPanelBg:runAction(cc.ScaleTo:create(0.2, 0))
    elseif self.spDownPanelBg:getScaleX() == 0 then
        self.spDownPanelBg:runAction(cc.ScaleTo:create(0.2, 1))
    end
end

function GameViewLayer:leftTopClick(event)
    if event.name == "began" then
        self:OnIntroduce(nil,ccui.TouchEventType.began)
        self:OnDownFrame(nil,ccui.TouchEventType.began) 
        self:goldCloseClick(nil,ccui.TouchEventType.ended)
    end
    return true
end
-- 聊天按钮
function GameViewLayer:OnChat(sender,type)
    ExternalFun.btnEffect(sender, type)
    if type == ccui.TouchEventType.ended then
        local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        if item ~= nil then
            print("item ~= nil")
            item:resetData()
        else
            print("item new")
            local gameSystemMessage = GameSystemMessage:create()
            gameSystemMessage:setLocalZOrder(100)
            gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
            self:addChild(gameSystemMessage)
        end
    end
end
-- 说明按钮动画
function GameViewLayer:OnIntroduce(sender,type)
    ExternalFun.btnEffect(sender, type)
    local fSpeed = 0.2
    local fScale = 0
    if type == ccui.TouchEventType.ended then
        if self.bIntroduceBtnInOutside then
            fScale = 0
        else
            fScale = 1
            self.spIntroducePanelBg:setVisible(true)
            if self.bDownBtnInOutside then 
                self:OnDownFrame(nil,ccui.TouchEventType.began)
            end
        end

        --背景图移动
        self.bIntroduceBtnInOutside = not self.bIntroduceBtnInOutside
        self.spIntroducePanelBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
    elseif type == ccui.TouchEventType.began then
        if sender == nil then
            self.bIntroduceBtnInOutside = false
            self.spIntroducePanelBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
        end
    end
end

-- 下拉框动画
function GameViewLayer:OnDownFrame(sender,type)
    ExternalFun.btnEffect(sender, type)
    local fSpeed = 0.2
    local fScale = 0
    if type == ccui.TouchEventType.ended then
        if self.bDownBtnInOutside then
            fScale = 0
        else
            fScale = 1
            self:initDownBtn()
            self.spDownPanelBg:setVisible(true)
            if self.bIntroduceBtnInOutside then 
                self:OnIntroduce(nil,ccui.TouchEventType.began)
            end
        end

        --背景图移动
        self.bDownBtnInOutside = not self.bDownBtnInOutside
        self.spDownPanelBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
    elseif type == ccui.TouchEventType.began then
        if sender == nil then
            self.bDownBtnInOutside = false
            self.spDownPanelBg:runAction(cc.ScaleTo:create(fSpeed, fScale, fScale, 1))
        end
    end
end

-- 初始化下拉按钮事件
function GameViewLayer:initDownBtn()
    self.spDownPanelBg:getChildByTag(GameViewLayer.UiTag.eBtnBack):addTouchEventListener(handler(self,self.menuClick))
    self.spDownPanelBg:getChildByTag(GameViewLayer.UiTag.eBtnSet):addTouchEventListener(handler(self,self.menuClick))
    self.spDownPanelBg:getChildByTag(GameViewLayer.UiTag.eBtnHelp):addTouchEventListener(handler(self,self.menuClick))
    self.spDownPanelBg:getChildByTag(GameViewLayer.UiTag.eBtnChangeDesk):addTouchEventListener(handler(self,self.menuClick))
end

function GameViewLayer:OnOpenCard()
    local tData = {}
    tData.bOX = 0
    local m_cbHandCardData = self._scene:getHandCardData()
    local t_hand = m_cbHandCardData[self.m_nChairID+1]
    if GameLogic.GetOxCard(t_hand) then    --有牛
        tData.bOX = 1
    end

    local bIsSuportBonus = self._scene:getGameGoldStatues()
    local iType = GameLogic.GetCardType(t_hand,GameLogic.MAX_COUNT,bIsSuportBonus)
    local iValue = GameLogic.getOxValue(iType)

    
    tData.cbOxCardData = t_hand

    self._scene:onBtnSendMessage(GameViewLayer.UiTag.eBtnLiangPai,tData)
    self._scene:KillGameClock();  
    self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:showCardTypeUI(iValue,iType)
    self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:showHandCardUI(t_hand)
    self:showAdNiuK(false)    
    ExternalFun.playSoundEffect("oxsixex_open_card.mp3")
end

--提示按钮
function GameViewLayer:OnHintOx()
    local m_cbHandCardData = self._scene:getHandCardData()
    
	if GameLogic.GetOxCard(m_cbHandCardData[self.m_nChairID+1]) then    --有牛
        self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:SetShootCard(m_cbHandCardData[self.m_nChairID+1],3)
	else                                                                --无牛
        self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:showCardTypeUI(0)
	end

    self:showAdNiuK(true)
end

function GameViewLayer:showBtn(bShowStart,bShowLiangP,bShowZb)
    local qBtn = nil

    if bShowStart ~= nil then
        self.m_pTextClock_:setVisible(bShowStart)
        self.startBtn:setVisible(bShowStart)
        self.startBtn:setEnabled(bShowStart)
        self.startBtn:setBright(bShowStart)
    end
   
    if bShowLiangP ~= nil then
        qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnLiangPai)
        if qBtn then
            qBtn:setVisible(bShowLiangP)
            qBtn:setEnabled(bShowLiangP)
            qBtn:setBright(bShowLiangP)
        end

        qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnTishi)
        if qBtn then
            qBtn:setVisible(bShowLiangP)
            qBtn:setEnabled(bShowLiangP)
            qBtn:setBright(bShowLiangP)
        end
    end 
end

-- 设置奖池
function GameViewLayer:setGoldScore(cellscore)
    self.resourceNode_:getChildByName("panel_gold"):setVisible(true)
    self.resourceNode_:getChildByName("btn_win_user"):setVisible(true) 
    if not cellscore then
        self.m_lTxtGold:setString("0")
    else
        self.m_lTxtGold:setString(cellscore)
    end
end

-- 设置底注
function GameViewLayer:setCellScore(cellscore)
    if not cellscore then
        self.cellScore:setString("0")
    else
        self.cellScore:setString(""..cellscore)
    end
end

function GameViewLayer:showFreeStatues()
    print("-------------------showFreeStatues-------------------")
    if self.m_wait == nil then
        self:showBtn(true)
    end
    
    self.m_nTableID = self._scene._gameFrame:GetTableID()
    self.m_nChairID = self._scene._gameFrame:GetChairID()
    self:updateUserInfo()

    if GlobalUserItem.isAntiCheat() then    --作弊房间
        local qBtn = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eBtnStart)
        if qBtn then
            qBtn:setVisible(false)
            qBtn:setEnabled(false)
        end
    end
    self._scene:SetGameClock(self.m_nChairID,cmd.IDI_START_GAME,cmd.TIME_USER_START_GAME)
end
function GameViewLayer:showPlayStatues(t_data)
    print("-------------------showPlayStatues-------------------")
    if t_data == nil then
        return
    end

    self.m_pUserItem_ = self._scene._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem_.wTableID
    self.m_nChairID = self.m_pUserItem_.wChairID	

    self:showZhunBei(nil)
    self:showAdNiuK(false)

    --local wBankerUser = self._scene:getBankUser()
    --self:showZhuang(wBankerUser,true)

    local cbPlayStatus = t_data.cbPlayStatus
    local cbCardData = t_data.cbHandCardData
    local cbOxCardData = t_data.cbOxCardData
    local cbDynamicJoin = t_data.cbDynamicJoin
    self:updateUserInfo()

    --显示扑克
	for i = 1,cmd.GAME_PLAYER do
        local iViewID = self:GetPlayViewStation(i-1);
        local bMeDynamicJoin = cbDynamicJoin and cbDynamicJoin ~= 0 and iViewID == cmd.MY_VIEW_CHAIRID
        if cbPlayStatus[i] == 1 and not bMeDynamicJoin then
            if cbCardData[i] then               
                self.m_pPlayers[iViewID]:showHandCardUI(cbCardData[i])
                if self:checkCardData(cbOxCardData[i]) ~= true then
                    self:setHeadClock(iViewID+1,t_data.cbTimeLeave) 
                else
                    if iViewID ~= cmd.MY_VIEW_CHAIRID then
                        self.m_pPlayers[iViewID]:showTipsOpenCard(true)
                    end
                end
            end
            
            if iViewID == cmd.MY_VIEW_CHAIRID then
                self:showBtn(false,true)  
                self._scene:SetGameClock(self.m_nChairID,cmd.IDI_TIME_OPEN_CARD,t_data.cbTimeLeave)
            end            
        end
    end
    
end
function GameViewLayer:checkCardData(CardData)
    local bData = false
    for k,v in pairs(CardData) do 
        if v ~=  0 then 
            return true
        end
    end
    return false
end 
function GameViewLayer:showReady()
    self:showBtn(false,nil)
    self:showZhunBei(cmd.MY_VIEW_CHAIRID,true)
end

function GameViewLayer:showGameStart()
    print("-------------------showGameStart-------------------")
    local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sCardPath)
    local x = yl.DESIGN_WIDTH/2 - self.m_pImageClock_:getContentSize().width/2
    local y = yl.DESIGN_HEIGHT/2 - self.m_pImageClock_:getContentSize().height/2
    if #self.m_tCardPile == 0 then
        local pSprite = nil 
        for i=1, 10 do
            local cardRect = cc.rect(2*110.0,4*150.0,110,150);
	        pSprite = cc.Sprite:createWithTexture(pTexture,cardRect)
            pSprite:setAnchorPoint(cc.p(0, 0))
            pSprite:setPosition(x,y+(i-1)*2)
            pSprite:setScale(0.8)
            pSprite:setVisible(false)
            self:addChild(pSprite)                 
            table.insert(self.m_tCardPile,pSprite)
        end
    else
        self:showCardPile(true)
    end
    
    for i = 1,cmd.GAME_PLAYER do
        self.m_pPlayers[i-1]:removeUI()
    end 
    
    
    self:showZhunBei(nil)
    self.m_pTextClock_:setVisible(false)
    ------------------------------------------------------------
    --local wBankerUser = self._scene:getBankUser()
    --self:showZhuang(wBankerUser,true)

    local cbPlayStatus = self._scene:getPlayStatues()
    local cbCardData = self._scene:getHandCardData()
    --获取当前用户数量
    local userCount = 0
    for i = 1,cmd.GAME_PLAYER do
        if cbPlayStatus[i] == 1 then
            userCount = userCount+1
        end
    end

    --显示扑克
    local curCardCount = 0
    for i = 1, cmd.MAX_COUNT do
        for j = 1, cmd.GAME_PLAYER do
            if cbPlayStatus[j] == 1 then
                if cbCardData[j] then
                    local iViewID = self:GetPlayViewStation(j-1);
                    --創建牌
                    local cardRect = cc.rect(2*110.0,4*150.0,110,150);
                    pSprite = cc.Sprite:createWithTexture(pTexture,cardRect)
                    pSprite:setAnchorPoint(cc.p(0, 0))
                    pSprite:setPosition(890,553)
                    pSprite:setRotation(-70)
                    pSprite:setScale(0.3)
                    pSprite:setVisible(false)
                    self:addChild(pSprite,9)
                    
                    -- 移动目的坐标和缩放比例
                    local pos,otherScale
                    if iViewID == cmd.MY_VIEW_CHAIRID then
                        pos = cc.p(self.m_tCardPos_[iViewID].x + (i-1) * (pSprite:getContentSize().width/2),self.m_tCardPos_[iViewID].y-15)
                        otherScale = 1
                    else
                        pos = cc.p(self.m_tCardPos_[iViewID].x + (i-1) * pSprite:getContentSize().width/2,self.m_tCardPos_[iViewID].y)
                        otherScale = 0.8
                    end
                    --移動動作
                    local open_frames = {}
                    for k = 1, 3 do
                        local frameName =string.format("oxsixex_opencard_%d.png",k)  
                        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
                        table.insert(open_frames, frame)
                    end
                    local open_ani = cc.Animation:createWithSpriteFrames(open_frames, 0.1) 
                    
                    local seqAn = nil
                    local fspeed = 0.2
                    if i == cmd.MAX_COUNT then
                        if iViewID == cmd.MY_VIEW_CHAIRID then 
                            seqAn = cc.Sequence:create(cc.DelayTime:create(curCardCount*0.1),
                                                        cc.Show:create(),
                                                        cc.CallFunc:create(function() ExternalFun.playSoundEffect("oxsixex_send_card.mp3") end),
                                                        cc.Spawn:create(cc.ScaleTo:create(fspeed,otherScale),cc.MoveTo:create(fspeed,pos),cc.RotateTo:create(fspeed,0)),
                                                        cc.Animate:create(open_ani),                                                 
                                                        cc.CallFunc:create(function()
                                                             self.m_pPlayers[iViewID]:flushCard()
                                                             self.m_pPlayers[iViewID]:removeThis()
                                                             if j == userCount then
                                                                 self:showCardPile(false)
                                                             end
                                                             self:showBtn(false,true)
                                                        end),
                                                        cc.RemoveSelf:create())
                        else
                            seqAn = cc.Sequence:create(cc.DelayTime:create(curCardCount*0.1),
                                                        cc.Show:create(),
                                                        cc.CallFunc:create(function() ExternalFun.playSoundEffect("oxsixex_send_card.mp3") end),
                                                        cc.Spawn:create(cc.ScaleTo:create(fspeed,otherScale),cc.MoveTo:create(fspeed,pos),cc.RotateTo:create(fspeed,0)),                                          
                                                        cc.CallFunc:create(function()
                                                             self.m_pPlayers[iViewID]:flushCard()
                                                             self.m_pPlayers[iViewID]:removeThis()
                                                             if j == userCount then
                                                                 self:showCardPile(false)
                                                             end
                                                        end),
                                                        cc.RemoveSelf:create())
                        end
                    else
                        if iViewID == cmd.MY_VIEW_CHAIRID then 
                            seqAn = cc.Sequence:create(cc.DelayTime:create(curCardCount*0.1),
                                                        cc.Show:create(),
                                                        cc.CallFunc:create(function() ExternalFun.playSoundEffect("oxsixex_send_card.mp3") end),
                                                        cc.Spawn:create(cc.ScaleTo:create(fspeed,otherScale),cc.MoveTo:create(fspeed,pos),cc.RotateTo:create(fspeed,0)),
                                                        cc.Animate:create(open_ani),
                                                        cc.CallFunc:create(function()
                                                             self.m_pPlayers[iViewID]:flushCard()
                                                        end),
                                                        cc.RemoveSelf:create())
                        else
                            seqAn = cc.Sequence:create(cc.DelayTime:create(curCardCount*0.1),
                                                        cc.Show:create(),
                                                        cc.CallFunc:create(function() ExternalFun.playSoundEffect("oxsixex_send_card.mp3") end),
                                                        cc.Spawn:create(cc.ScaleTo:create(fspeed,otherScale),cc.MoveTo:create(fspeed,pos),cc.RotateTo:create(fspeed,0)),
                                                        cc.CallFunc:create(function()
                                                             self.m_pPlayers[iViewID]:flushCard()
                                                        end),
                                                        cc.RemoveSelf:create())
                        end
                    end
                    pSprite:runAction(seqAn)
                    curCardCount = curCardCount + 1
                    self.m_pPlayers[iViewID]:setCardAnimation(cbCardData[j])
                    
                end
            end
        end
    end

    --时间设置
    if self.m_bAutoGame_ then
        if userCount > 2 then 
            self._scene:SetGameClock(self.m_nChairID,cmd.IDI_TIME_OPEN_CARD,userCount+1)
        else
            self._scene:SetGameClock(self.m_nChairID,cmd.IDI_TIME_OPEN_CARD,cmd.TIME_USER_AUTO_GAME)
        end
    else
        self._scene:SetGameClock(self.m_nChairID,cmd.IDI_TIME_OPEN_CARD,cmd.TIME_USER_OPEN_CARD)
        self:setHeadClock(nil,cmd.TIME_USER_OPEN_CARD)
    end
--    self._scene:SetGameClock(self.m_nChairID,cmd.IDI_TIME_OPEN_CARD,cmd.TIME_USER_OPEN_CARD)
--    self:setHeadClock(nil,cmd.TIME_USER_OPEN_CARD)
end

function GameViewLayer:showCardPile(bVisiable)
    for i,v in pairs(self.m_tCardPile) do
        --v:setVisible(bVisiable)
    end
end

function GameViewLayer:showOpenCard(t_data)
    if t_data == nil then
        return
    end

    if t_data.wPlayerID ~= self.m_nChairID then
        local iViewID = self:GetPlayViewStation(t_data.wPlayerID)
        self.m_pPlayers[iViewID]:showTipsOpenCard(true)
        self:stopHeadClock(iViewID)
    else
        self:showBtn(false,false)
        self:showAdNiuK(false)

        local m_cbHandCardData = self._scene:getHandCardData()
        local t_hand = m_cbHandCardData[t_data.wPlayerID+1]
        if t_hand == nil or t_hand[1] ==0 then
            return
        end
        
        self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:showDeskCardUI(t_hand,t_data.bOpen)
        self:stopHeadClock(3)
    end
end

function GameViewLayer:runWinGoldAni(gold,score)
    --遮罩
    local touchEnable = ccui.Layout:create()
    local btcallback = function(ref, tType)
        ExternalFun.btnEffect(ref, tType)
        if type == ccui.TouchEventType.ended then
            self.goldIntroduce:setVisible(false)
            self.goldWin:setVisible(false)
            touchEnable:removeFromParent()
        end
    end

    touchEnable:setContentSize(cc.size(yl.DESIGN_WIDTH, yl.DESIGN_HEIGHT))
    touchEnable:setAnchorPoint(cc.p(0.5, 0.5))
    touchEnable:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    touchEnable:addTouchEventListener(btcallback)
    touchEnable:setTouchEnabled(true)
    touchEnable:setSwallowTouches(true)
    self:addChild(touchEnable,10)

    --恭喜动画
    local Win = display.newSprite("#oxsixex_bg_victory.png")
        :setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2+20))
        :setScale(0)
        :setLocalZOrder(5)
        :addTo(self)
    local WinLight = display.newSprite("#oxsixex_effect_victory.png")
        :setLocalZOrder(-2)
        :setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2-10)
        :addTo(Win)
    local WinLabel = display.newSprite("#oxsixexgold_txt_happy1.png")
        :setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2+20)
        :setScale(0.9)
        :addTo(Win)
    local WinTitle = display.newSprite("#oxsixexgold_txt_happy2.png")
        :setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2-60)
        :setScale(0.3)
        :addTo(Win)
      
    Win:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.2, 1, 1, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function(ref)
			                    Win:setVisible(false)
                                touchEnable:removeFromParent()
		                    end)))
    WinLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    WinTitle:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.ScaleTo:create(0.3, 1, 1, 1)))

    local tempStr = tostring(gold)
    local tempLength = string.len(tempStr)
    local tempWidth = tempLength*84
    local GoldLayer = display.newLayer()
        :setContentSize(tempWidth,102)
        :setPosition(Win:getContentSize().width/2-tempWidth/2,Win:getContentSize().height/2-245)
        :setLocalZOrder(-1)
        :addTo(Win)
    self:getGoldSprite(tempStr,GoldLayer,tempLength)  
                  
    local reward_box_frames = {}
    for i = 1, 7 do
        local frameName =string.format("oxsixexgold_ani_coin%d.png",i)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(reward_box_frames, frame)
    end
    local reward_box_ani = cc.Animation:createWithSpriteFrames(reward_box_frames, 0.1) 
    local WinAniCoin = display.newSprite("#oxsixexgold_ani_coin1.png") 
    WinAniCoin:setPosition(Win:getContentSize().width/2,Win:getContentSize().height/2)
    WinAniCoin:setLocalZOrder(-2)
    WinAniCoin:addTo(Win)
    WinAniCoin:runAction(cc.Animate:create(reward_box_ani)) 
end
function GameViewLayer:getGoldSprite(str,layer,length)
    for i = 1 ,length do 
        local num = string.sub(str,i,i)
        local Text = cc.LabelAtlas:_create("0000000", GameViewLayer.RES_PATH.."game/oxsixex_fonts_num_caijin.png", 84, 102, string.byte("0"))
        Text:setLocalZOrder(-1)
        Text:setPosition(84*(i-1),102/2+300)
        Text:setOpacity(0)
        Text:setScale(5)
        Text:setString(num)
        Text:addTo(layer)
        local offsetX = -2+2*(math.random(1,3)-1)
        local offsetY = -2+2*(math.random(1,3)-1)
        Text:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1*i),
                cc.Spawn:create(
                    cc.FadeIn:create(0.2),
                    cc.ScaleTo:create(0.2,1),
                    cc.MoveTo:create(0.2, cc.p(Text:getPositionX(),102/2))),
                cc.MoveBy:create(0.05, cc.p(offsetX,offsetY)),
                cc.MoveBy:create(0.05, cc.p(-offsetX*2,-offsetY*2)),
                cc.MoveBy:create(0.05, cc.p(offsetX,offsetY))
            ))
    end
end
function GameViewLayer:showGameEnd(t_data)
    if t_data == nil then
        return
    end
    self:showZhunBei(nil)
    local score = t_data.lGameScore[self.m_nChairID+1] 
    
    if t_data.lSubBobus[self.m_nChairID+1] > 0 then
        if score ~= 0 then
            self:runWinGoldAni(t_data.lSubBobus[self.m_nChairID+1],score)
        end
    else
        if score ~= 0 then
            --self:runWinLoseAnimate(score) 
        elseif score == 0 then
            self:showBtn(true,false,false)
        end          
    end

    for i = 1,cmd.GAME_PLAYER do
        self.m_pPlayers[i-1]:showTipsOpenCard(false)
    end
    
    --self._scene:SetGameClock(self.m_nChairID,cmd.IDI_START_GAME,cmd.TIME_USER_START_GAME)

    local cbPlayStatus = self._scene:getPlayStatues()
    local tOx = self._scene:getOx()
    local m_cbHandCardData = self._scene:getHandCardData()
    local myPointFile = ""
    --显示扑克
	for i = 1,cmd.GAME_PLAYER do
        if cbPlayStatus[i] == 1 then
            local iViewID = self:GetPlayViewStation(i-1);
            if t_data.cbCardData[i] then
                self.m_pPlayers[iViewID]:showDeskCardUI(t_data.cbCardData[i],tOx[i])
            end
            --显示牛几
            local t_hand = m_cbHandCardData[i]
            if i ~= self.m_nChairID+1 then
                if tOx[i] == 0 or tOx[i] == 255 then
                    self.m_pPlayers[iViewID]:showCardTypeUI(0)
                else
                    if t_hand ~= nil and t_hand[1] ~=0 then
                        if GameLogic.GetOxCard(t_hand) then    --有牛
                            local bIsSuportBonus = self._scene:getGameGoldStatues()
                            local iType = GameLogic.GetCardType(t_hand,GameLogic.MAX_COUNT,bIsSuportBonus)
                            local iValue = GameLogic.getOxValue(iType)
                            self.m_pPlayers[iViewID]:showCardTypeUI(iValue,iType)
                        end    
                    end
                end
            else
                --自己方播放牛几音效
                if t_hand ~= nil and t_hand[1] ~= 0 then
                    local bIsSuportBonus = self._scene:getGameGoldStatues()
                    local iType = GameLogic.GetCardType(t_hand,GameLogic.MAX_COUNT,bIsSuportBonus)
                    local iValue = GameLogic.getOxValue(iType)
                    if iValue <= 10 then
                        if iType == GameLogic.OX_FIVE_KING 
                        or iType == GameLogic.OX_FIVE_KING_SOFT 
                        or iType == GameLogic.OX_FIVE_KING_HAND then
                            myPointFile = "BOY/oxsixex_ox_11.mp3"
                        else
                            myPointFile = "BOY/oxsixex_ox_".. iValue .. ".mp3"
                        end
                    end
                end
            end
        end
    end

    --显示结算 刷新钱
    local iMoney = 0
    local tScore = t_data.lGameScore
    appdf.printTable(tScore)
    local winChair = nil
    for i = 1,cmd.GAME_PLAYER do
        if cbPlayStatus[i] == 1 and tScore[i] ~= 0 then
            local iViewID = self:GetPlayViewStation(i-1)
            self.m_pPlayers[iViewID]:showJskUI(tScore[i])
            if iViewID == cmd.MY_VIEW_CHAIRID then
                self.m_pUserItem_.lScore = self.m_pUserItem_.lScore + tScore[i]
                iMoney = self.m_pUserItem_.lScore
                self:setUserMoney(iViewID,iMoney)
                --自己是否赢了
                if tScore[i] > 0 then
                    ExternalFun.playSoundEffect("oxsixex_game_win.mp3")
                else
                    if myPointFile ~= "" then
                        ExternalFun.playSoundEffect(myPointFile)
                    end
                end
            else
                local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)
                if useritem then
                    useritem.lScore = useritem.lScore + tScore[i]
                    iMoney = useritem.lScore
                    self:setUserMoney(iViewID,iMoney)
                end
            end
            if tScore[i] > 0 then 
                winChair = iViewID
            end
        end
    end
    self:runGoldAnimate(cbPlayStatus,winChair)
    self:showAdNiuK(false)
    --清除数据
    self._scene:onResetData()
    if self.m_bAutoGame_ then
        self:OnAutoGame(nil,ccui.TouchEventType.ended)
        self:showBtn(false,false)
    else
        self:showBtn(true,false)
    end
end
--运行输赢动画
function GameViewLayer:runGoldAnimate(cbPlayStatus,winChair)
     for i = 1,cmd.GAME_PLAYER do       
        if cbPlayStatus[i] == 1 then
            local iViewID = self:GetPlayViewStation(i-1)
            local posE = self.m_tHeadPos_[winChair]
            if iViewID ~= winChair then 
                local posB = self.m_tHeadPos_[iViewID]
                for j = 1 ,8 do 
                local sGold = display.newSprite("#oxsixex_img_scoin.png")
                    :setLocalZOrder(5)
                    :setPosition(posB)
                    :addTo(self)
                sGold:runAction(cc.Sequence:create(cc.MoveTo:create(0.5+j*0.1, posE), cc.CallFunc:create(function(ref)
			            ref:removeFromParent()
		            end)))
                end
            end
        end
    end
end
--运行输赢动画
function GameViewLayer:runWinLoseAnimate(score)
     --遮罩
    local btcallback = function(ref, tType)
        if type == ccui.TouchEventType.ended then
            self.goldIntroduce:setVisible(false)
            self.goldWin:setVisible(false)
        end
    end
    local touchEnable = ccui.Layout:create()
    touchEnable:setContentSize(cc.size(yl.DESIGN_WIDTH, yl.DESIGN_HEIGHT))
    touchEnable:setAnchorPoint(cc.p(0.5, 0.5))
    touchEnable:setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    touchEnable:addTouchEventListener(btcallback)
    touchEnable:setTouchEnabled(true)
    touchEnable:setSwallowTouches(true)
    self:addChild(touchEnable,10)

    --胜利失败动画
    local WinLose = display.newSprite("#oxsixex_bg_fail.png")
        :setPosition(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
        :setScale(0)
        :setLocalZOrder(5)
        :addTo(self)
    local WinLoseLight = display.newSprite("#oxsixex_effect_fail.png")
        :setLocalZOrder(-2)
        :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2)
        :addTo(WinLose)
    local WinLoseTitle = display.newSprite("#oxsixex_txt_fail.png")
        :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2+15)
        :setScale(0.3)
        :addTo(WinLose)
    local WinLoseTab = display.newSprite("#oxsixex_bg_failbottom.png")
        :setLocalZOrder(-1)
        :setPosition(WinLose:getContentSize().width/2,WinLose:getContentSize().height/2-20)
        :addTo(WinLose)
    local WinLoseGold = display.newSprite("#oxsixex_img_mcoin.png")
        :addTo(WinLoseTab)

    local bgFram
    local lightFrame
    local TitleFrame
    local TabFrame
    local WinLoseText
    if score > 0 then
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_bg_victory.png")
        lightFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_effect_victory.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_txt_victory.png")
        TabFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_bg_victorybottom.png")
        WinLoseText = cc.LabelAtlas:_create(".0000000", GameViewLayer.RES_PATH.."game/oxsixex_fonts_num_win.png", 27, 36, string.byte("*"))
            :setPosition(WinLoseTab:getContentSize().width/2-50,WinLoseTab:getContentSize().height/2)
            :setAnchorPoint(cc.p(0, 0.5))
            :addTo(WinLoseTab)
        WinLoseText:setString("."..score)
    else
        bgFram = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_bg_fail.png")
        lightFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_effect_fail.png")
        TitleFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_txt_fail.png")
        TabFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("oxsixex_bg_failbottom.png")
        WinLoseText = cc.LabelAtlas:_create("/0000000", GameViewLayer.RES_PATH.."game/oxsixex_fonts_num_lose.png", 27, 36, string.byte("*"))
            :setPosition(WinLoseTab:getContentSize().width/2-50,WinLoseTab:getContentSize().height/2)
            :setAnchorPoint(cc.p(0, 0.5))
            :addTo(WinLoseTab)
        WinLoseText:setString("/"..math.abs(score))
    end
    local length = (WinLoseGold:getContentSize().width + WinLoseText:getContentSize().width)/2
    WinLoseGold:setPosition(WinLoseTab:getContentSize().width/2 - length ,WinLoseTab:getContentSize().height/2)
    WinLoseText:setPosition(WinLoseGold:getPositionX() + WinLoseGold:getContentSize().width,WinLoseTab:getContentSize().height/2)
    WinLose:setSpriteFrame(bgFram) 
    WinLoseLight:setSpriteFrame(lightFrame) 
    WinLoseTitle:setSpriteFrame(TitleFrame) 
    WinLoseTab:setSpriteFrame(TabFrame) 

    WinLose:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.2, 1, 1, 1),
                            cc.DelayTime:create(2.3),
		                    cc.CallFunc:create(function(ref)
                                touchEnable:removeFromParent()
			                    WinLose:setVisible(false)
                                self:showAdNiuK(false)
                                --清除数据
                                self._scene:onResetData()
                                if self.m_bAutoGame_ then
                                    self:OnAutoGame(nil,ccui.TouchEventType.ended)
                                    self:showBtn(false,false)
                                else
                                    self:showBtn(true,false)
                                end
		                    end)))
    WinLoseLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    WinLoseTitle:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.ScaleTo:create(0.3, 1, 1, 1)))
    WinLoseTab:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.MoveBy:create(0.5, cc.p(0,10-WinLose:getContentSize().height/2))))  
end

--强行退出
function GameViewLayer:dealGameExit(wPlayid)
    if wPlayid == nil then
        return
    end
    local iViewID = self:GetPlayViewStation(wPlayid)
    self.m_pPlayers[iViewID]:removeUI()
    self:showPlayerInfo(iViewID,nil,false)
end

function GameViewLayer:showChat(tData)
    if tData == nil then
        return
    end

    self.m_pChatLayer_:showGameChat(false)
    for i=1,cmd.GAME_PLAYER do
        local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)
        if useritem then
            if useritem.dwUserID  == tData.dwSendUserID  then
                local viewID = self:GetPlayViewStation(i-1)
                local qImageHeadbj = self.resourceNode_:getChildByTag(viewID+10)
                if qImageHeadbj:isVisible() then
                    self.m_pPlayers[viewID]:showChat(tData)
                end
                return
            end
        end
    end
end

function GameViewLayer:GetPlayViewStation(id)
    if id == self.m_nChairID then
		return cmd.MY_VIEW_CHAIRID
	else
		return (id - self.m_nChairID + cmd.MY_VIEW_CHAIRID + cmd.GAME_PLAYER)%cmd.GAME_PLAYER
	end
end

function GameViewLayer:updateUserInfo(charID)
    local useritem = nil
    local viewID = 0
    if charID then
        useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,charID)
        viewID = self:GetPlayViewStation(charID)
        if useritem then
            self:showPlayerInfo(viewID,useritem)
            if useritem.cbUserStatus == yl.US_READY then
                self:showZhunBei(viewID,true)
            end
        else
            self:showPlayerInfo(viewID,nil,false)
            self:showZhunBei(viewID,false)
        end
        return
    end

    for i=1,cmd.GAME_PLAYER do
        useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)
        viewID = self:GetPlayViewStation(i-1)
        if viewID ~= GameViewLayer.UiTag.eImageHeadBjMy then
            if useritem then
                self:showPlayerInfo(viewID,useritem)
                if useritem.cbUserStatus == yl.US_READY then
                    self:showZhunBei(viewID,true)
                end
            else
                self:showPlayerInfo(viewID,nil,false)
                self:showZhunBei(viewID,false)
            end
        else
            self:showPlayerInfo(cmd.MY_VIEW_CHAIRID,self.m_pUserItem_)
        end
    end	
end

-----------------------------------------------------------------------------------------------------
function GameViewLayer:setUserNickname(viewid, nickname)
    local qImagebj = self.resourceNode_:getChildByTag(viewid+10)
    if qImagebj == nil then
        return
    end

    qImagebj:setVisible(true)
    local pText = qImagebj:getChildByTag(GameViewLayer.TAG_NAME)
    if not pText then
        print("the user name is nil!!")
        return
    end

    local name = string.EllipsisByConfig(nickname, 105, string.getConfig(appdf.FONT_FILE, 20))
    pText:setString(name)
    --pText:setAnchorPoint(cc.p(0.5, 0.5))
    --pText:move(61, 52)

    --限制宽度
    -- local width = pText:getContentSize().width
    -- if width > 107 then
    --     pText:setScaleX(107/width)
    -- elseif pText:getScaleX() ~= 1 then
    --     pText:setScaleX(1)
    -- end
end

function GameViewLayer:ShowMyPopWait(szTips, callfun)
    self.m_wait = PopWaitLayer:create(szTips, callfun)		
    self.resourceNode_:addChild(self.m_wait)
    self.m_wait:setLocalZOrder(9)
end

function GameViewLayer:CloseMyPopWait()
    if self.m_wait ~= nil then
        self.m_wait:removeFromParent()
		self.m_wait = nil    
    end
end

function GameViewLayer:setUserMoney(viewid,iMoney)
    local qImagebj = self.resourceNode_:getChildByTag(viewid+10)
    if qImagebj == nil then
        return
    end

    qImagebj:setVisible(true)
    pText = qImagebj:getChildByTag(GameViewLayer.TAG_MONEY)
    if not pText then
        print("the user money is nil!!")
        return
    end
    pText:setString(ExternalFun.formatScoreText(iMoney))
    
    --限制宽度
    local fixedWidth = 85
    local textWidth = pText:getContentSize().width
    if textWidth > fixedWidth then
        pText:setScaleX(fixedWidth/textWidth)
    elseif pText:getScaleX() ~= 1 then
        pText:setScaleX(1)
    end
end

function GameViewLayer:showPlayerInfo(id,useritem,bShow)
    local qImagebj = self.resourceNode_:getChildByTag(id+10)
    if qImagebj == nil then
        return
    end

    if bShow == false then
        --self:OutHead(id)
        qImagebj:setVisible(false)       
        self:showHead(qImagebj,nil,nil,true)
    elseif useritem then
        qImagebj:setVisible(true)
        self:showHead(qImagebj,useritem,id)
        self:setUserNickname(id, useritem.szNickName)
        self:setUserMoney(id, useritem.lScore)
    end
end

function GameViewLayer:showHead(pImage,userObj,viewid,bRemove)
    local pHeadImage = pImage:getChildByTag(GameViewLayer.TAG_HEAD)
    local sprite = pImage:getChildByTag(GameViewLayer.TAG_HEAD_BOTTOM)
    if bRemove then
        if pHeadImage then
            pHeadImage:removeFromParent()
            sprite:removeFromParent()
            sprite = nil
            pHeadImage = nil
        end
        return
    end
    
    --以存在就不需要绘制
    if pHeadImage then
        if userObj.cbUserStatus == yl.US_OFFLINE then
			if self.m_bNormalState[viewid] then
				convertToGraySprite(pHeadImage.m_head.m_spRender)
                self.ShowWaitPlayer[viewid] = true
			end
			self.m_bNormalState[viewid] = false
		else
			if not self.m_bNormalState[viewid] then
				convertToNormalSprite(pHeadImage.m_head.m_spRender)
                self.ShowWaitPlayer[viewid] = false
			end
			self.m_bNormalState[viewid] = true
		end
        return
    end

    pHeadImage = PopupInfoHead:createNormal(userObj, 90)
    pHeadImage:setAnchorPoint(cc.p(yl.DESIGN_WIDTH/2, yl.DESIGN_HEIGHT/2))
    pHeadImage:setPosition(cc.p(0, 0))
    sprite = display.newSprite("#userinfo_head_frame.png")
    sprite:setPosition(cc.p(0, 0))
    sprite:setScale(0.55,0.55)
    pImage:addChild(sprite)
	pImage:addChild(pHeadImage)
    pHeadImage:setTag(GameViewLayer.TAG_HEAD)
    sprite:setTag(GameViewLayer.TAG_HEAD_BOTTOM)
end

--显示庄家标志
function GameViewLayer:showZhuang(charID,show)
    local qImagebj = nil
    local qImageZhuang = nil
    for i=1,cmd.GAME_PLAYER do
        qImagebj = self.resourceNode_:getChildByTag(i-1+10)
        if qImagebj then
            qImageZhuang = qImagebj:getChildByTag(GameViewLayer.TAG_ZHUANG)
            if qImageZhuang then
                qImageZhuang:setVisible(false)
            end
        end
    end

    if show and charID then
        local allCharId = self._scene:getPlayStatues()
        if allCharId[charID+1] == 0 then
            print("showZhuang!!!!!!ERROR")
            return
        end
        local viewID = self:GetPlayViewStation(charID)
        qImagebj = self.resourceNode_:getChildByTag(viewID+10)
        if qImagebj then
            qImageZhuang = qImagebj:getChildByTag(GameViewLayer.TAG_ZHUANG)
            if qImageZhuang then
                qImageZhuang:setLocalZOrder(1)
                --qImageZhuang:setVisible(show)
                print("showZhuang!!!!!!")
            end
        end
    end
end

function GameViewLayer:getCardTypeSprite(iValue,iType)   
    local pSprite = nil
    local pSpBg = nil
    local bOx = false
    if iType == GameLogic.OX_FIVE_KING then
        pSprite = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype11.png")
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        bOx = true
    elseif iType == GameLogic.OX_FIVE_KING_SOFT then
        pSprite = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype12.png")
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        bOx = true
    elseif iType == GameLogic.OX_FIVE_KING_HAND then
        pSprite = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype13.png")
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        bOx = true
    elseif iType == GameLogic.OX_VALUE_GOURD then
        pSprite = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype15.png")
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        bOx = true
    elseif iType == GameLogic.OX_FOUR_BAR then
        pSprite = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype16.png")
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        bOx = true
    elseif iType == GameLogic.OX_THREE_BAR then
        pSprite = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype14.png")
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        bOx = true
    elseif iValue == 0 then
        pSprite = cc.Sprite:createWithSpriteFrameName(string.format("oxsixex_img_cardtype%d.png", iValue))
        pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg0.png")
        bOx = false
    else
        pSprite = cc.Sprite:createWithSpriteFrameName(string.format("oxsixex_img_cardtype%d.png", iValue))
        if iValue < 10 then 
            pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg1.png")
        else
            pSpBg = cc.Sprite:createWithSpriteFrameName("oxsixex_img_cardtype_bg2.png")
        end
        bOx = true
    end

    return pSprite,pSpBg,bOx
end

function GameViewLayer:showAdNiuK(bShow)
    local qImage = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eImageAdNiuK)
    if qImage == nil then
        return
    end
    if bShow == false then
        qImage:setVisible(false)
        return
    end

    local pLay = qImage:getChildByTag(10)
    local pText = nil
    local cUpCard = self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:GetShootCard(true) 
    local upCount = #cUpCard
    if upCount == 0 then
        qImage:setVisible(false)
        return
    end
    if upCount<3 then
        for i=upCount+1,3 do
            pText = qImage:getChildByTag(i)
            if pText then
                pText:setString("")
            end
        end

        for i=1,upCount do
            local value = GameLogic.GetCardLogicValue(cUpCard[i])
            pText = qImage:getChildByTag(i)
            if pText then
                pText:setString(tostring(value))
            end
        end

        if pLay then
            pLay:setVisible(false)
        end
    else
        if upCount>3 then
            upCount = 3
        end

        for i=1,upCount do
            local value = GameLogic.GetCardLogicValue(cUpCard[i])
            pText = qImage:getChildByTag(i)
            if pText then
                pText:setString(tostring(value))
            end
        end

        local cDown = self.m_pPlayers[cmd.MY_VIEW_CHAIRID]:GetShootCard(false) 
        for i,v in pairs(cDown) do
            table.insert(cUpCard,v)
        end
        local bIsSuportBonus = self._scene:getGameGoldStatues()
        local iType = GameLogic.GetCardType(cUpCard,GameLogic.MAX_COUNT,bIsSuportBonus)
        local iValue = GameLogic.getOxValue(iType)

        local pSprite = self:getCardTypeSprite(iValue,iType)
        if pLay then
            pLay:removeAllChildren()
            if pSprite then
                pSprite:setPosition(cc.p(0, 0))                
                pLay:addChild(pSprite)                
            end
            pLay:setVisible(true)
        end
    end

    qImage:setVisible(true)
end

function GameViewLayer:showStudioChild(tag,bShow)
    local pNode = self.resourceNode_:getChildByTag(tag)
    if pNode then
        pNode:setVisible(bShow)
    end
end

function GameViewLayer:showZhunBei(viewId,bShow)
    local pLayer = self.resourceNode_:getChildByTag(GameViewLayer.UiTag.eLayerZhunBei)
    if pLayer == nil then
        return
    end

    local pImage = nil
    if viewId == nil then
        for i=1,cmd.GAME_PLAYER do
            pImage = pLayer:getChildByTag(i-1)
            if pImage then
                pImage:setVisible(false)
            end
        end
    else
        pImage = pLayer:getChildByTag(viewId)
        if pImage then
            pImage:setVisible(bShow == true)
        end
    end
end
function GameViewLayer:OutHead(viewId)
    local playerNode = self.resourceNode_:getChildByTag(viewId+10)   
    if playerNode:isVisible() then 
        playerNode:runAction(cc.Sequence:create(
                                cc.MoveTo:create(0.3,self.m_tHeadMovePos_[viewId]),
                                cc.CallFunc:create(function(ref)
                                    ref:setVisible(false)
                                    self:showHead(ref,nil,nil,true)
                                end)))   
    end
end
function GameViewLayer:MoveHead()
    for i = 1 ,cmd.GAME_PLAYER do  
        local playerNode = self.resourceNode_:getChildByTag(i+9)              
        if playerNode:isVisible() then  
            playerNode:stopAllActions() 
            playerNode:setPosition(self.m_tHeadMovePos_[i-1])    
            playerNode:runAction(cc.MoveTo:create(0.3,self.m_tHeadPos_[i-1]))                    
        end
    end 
end
function GameViewLayer:OnUpdataClockView(viewid,time)
    if self.m_pImageClock_ == nil or self.m_pNumClock_ == nil then
        return
    end
    if self.m_wait == nil then
        if not viewid or not time or viewid == yl.INVALID_CHAIR then
		    self.m_pImageClock_:setVisible(false)
		    self.m_pNumClock_:setString("")
            if viewid ~= cmd.MY_VIEWID then 
                self:setWaitPlayer(true)
            end
	    else		    
            self.m_pImageClock_:setVisible(false)
		    self.m_pNumClock_:setString("")
            self:setHeadClock(viewid,time)          
            if self.IsShowWait == true then           
                self:setWaitPlayer(false)
            end  
	    end
    end
end
function GameViewLayer:setWaitPlayer(bShow)
    for k,v in pairs(self.ShowWaitPlayer) do 
        if bShow == true then 
            if v == true then 
                self:ViewWaitPlayer(bShow)
                return 
            end
        else
            self.ShowWaitPlayer[k] = bShow
            self:ViewWaitPlayer(bShow)
        end
    end
end
function GameViewLayer:ViewWaitPlayer(bShow)
    if self.m_WaitFlag == nil then 
        self.m_WaitFlag = ExternalFun.CreateWaitPlayerFlag(self)
        self.m_WaitFlag:setPosition(self.ptWaitFlag)
    end
    self.m_WaitFlag:setVisible(bShow)
    self.IsShowWait = bShow
end
function GameViewLayer:setHeadClock(viewid,time)
    if time == 0 then return end
    local resSprite = display.newSprite("#oxsixexgold_img_time.png")
    if viewid then 
        local playerNode = self.resourceNode_:getChildByName("FileNode_"..viewid-1)  
        if playerNode:getChildByTag(GameViewLayer.TAG_CLOCK) == nil then 
            ExternalFun.CreateHeadClock(resSprite,"game/oxsixex_time.plist",GameViewLayer.TAG_CLOCK,cc.p(0,-5),playerNode,time,nil)
        end
    else
        for i = 1, cmd.GAME_PLAYER do
            local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)  
            if useritem then
                local viewID = self:GetPlayViewStation(i-1)
                local playerNode = self.resourceNode_:getChildByName("FileNode_"..viewID)
                if playerNode:getChildByTag(GameViewLayer.TAG_CLOCK) == nil then 
                    ExternalFun.CreateHeadClock(resSprite,"game/oxsixex_time.plist",GameViewLayer.TAG_CLOCK,cc.p(0,-5),playerNode,time,nil)
                end
            end
        end
    end
end
function GameViewLayer:stopHeadClock(viewid)
    if viewid then         
        if viewid ~= yl.INVALID_CHAIR then 
            local playerNode = self.resourceNode_:getChildByName("FileNode_"..viewid)  
            ExternalFun.RemoveHeadClock(GameViewLayer.TAG_CLOCK,playerNode)
        else
            self:stopAllClock()
        end
    else
        self:stopAllClock()
    end
end
function GameViewLayer:stopAllClock()
    for i = 1, cmd.GAME_PLAYER do    
        local useritem = self._scene._gameFrame:getTableUserItem(self.m_nTableID,i-1)
        if useritem then    
            local viewID = self:GetPlayViewStation(i-1)
            local playerNode = self.resourceNode_:getChildByName("FileNode_"..viewID)  
            ExternalFun.RemoveHeadClock(GameViewLayer.TAG_CLOCK,playerNode)
        end
    end
end
function GameViewLayer:onResetView()
    self:showBtn(false,false,false)    
    self:showAdNiuK(false)
    self:showCardPile(false)
    self:stopHeadClock()
	for i = 1, cmd.GAME_PLAYER do
        local viewID = self:GetPlayViewStation(i-1)
        self:showPlayerInfo(viewID,nil,false)
        self.m_pPlayers[viewID]:removeUI()
        self:showZhunBei(viewID,false)
	end
end

function GameViewLayer:showPopWait( )
	self._scene:showPopWait()
end

function GameViewLayer:dismissPopWait( )
	self._scene:dismissPopWait()
end

return GameViewLayer