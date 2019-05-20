--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local QBasePlayer = class("QBasePlayer",function ()
	-- body
	return cc.Layer:create()
end)

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.bean.CardSprite")
local QScrollText = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.bean.QScrollText")
local NGResources = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.NGResources")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.GameLogic")

function QBasePlayer:ctor()
    self.scene = nil
    self.m_nViewID_ = -1
    self.m_pImageHand_ = {}
    self.m_tHandCardData_ = {}
    self.m_pNodeType_ = nil
    self.m_pNodeContain_ = nil
    self.m_pTextJs_ = nil
    self.m_pImageBack_ = {}
    self.m_pImageTipsCard_ = nil
    self.vHeadPos = nil
    self.m_tCardPos_ = nil
    self.m_pImageChat_ = nil
end

function QBasePlayer:setViewID(id)
    self.m_nViewID_ = id
end

function QBasePlayer:initContain()
    if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
        return
    end

    self.m_pNodeContain_ = cc.Node:create()
    self.m_pNodeContain_:setContentSize(cc.size(220.0,120.0))
    self.m_pNodeContain_:setPosition(cc.p(self.m_tCardPos_.x,self.m_tCardPos_.y ))
    self:addChild(self.m_pNodeContain_)
end

function QBasePlayer:initBackAct()
    -- local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sDeskCardPath)
    local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sCardPath)
    local pSprite = nil
    
    for i=1,cmd.MAX_COUNT do
        local cardRect = cc.rect(2*110.0,4*150.0,110,150);
	    pSprite = cc.Sprite:createWithTexture(pTexture,cardRect)
        pSprite:setAnchorPoint(display.LEFT_BOTTOM)
        pSprite:setScale(0.8)
        pSprite:setVisible(false)
        self:addChild(pSprite)
        table.insert(self.m_pImageBack_,pSprite)
    end
end

--显示牛几
function QBasePlayer:showCardTypeUI(iValue,iType)
    if self.m_pNodeType_ then
        self.m_pNodeType_:removeAllChildren()
    else
        self.m_pNodeType_ = cc.Node:create()
        self:addChild(self.m_pNodeType_,10)
    end

    local posX = nil
    local posY = nil
    local scale = 0.9
    if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
        posX = yl.DESIGN_WIDTH/2
        posY = self.m_tCardPos_.y + 30
    elseif self.m_nViewID_ == cmd.VIEW_TOP_MIDDLE then
        posX = yl.DESIGN_WIDTH/2
        posY = self.m_tCardPos_.y + 25
        scale = 0.8
    else    
        posX = self.m_tCardPos_.x + 153
        posY = self.m_tCardPos_.y + 25
        scale = 0.8   
    end
    self.m_pNodeType_:setPosition(cc.p(posX ,posY))
    self:showCardTypeAni(iValue,iType,scale)
--    local pSprite,pSpBg,bOx = self.scene:getCardTypeSprite(iValue,iType)
--    local cSize = pSpBg:getContentSize()
--    self.m_pNodeType_:setContentSize(cc.size(cSize.width*2,cSize.height))
--    self.m_pNodeType_:addChild(pSprite)

end
function QBasePlayer:showCardTypeAni(iValue,iType,scale)
    local pSprite,pSpBg,bOx = self.scene:getCardTypeSprite(iValue,iType)
    if pSprite and pSpBg then 
        local cSize = pSpBg:getContentSize()
        self.m_pNodeType_:setContentSize(cc.size(cSize.width*2,cSize.height))
        self.m_pNodeType_:addChild(pSprite,1)
        self.m_pNodeType_:addChild(pSpBg)
    
        local offsetX = 0
        local offsetY = 0
        if bOx == true then 
            pSprite:setScale(3)
            pSpBg:setScale(0)   
            offsetX = -2+2*(math.random(1,3)-1)
            offsetY = -2+2*(math.random(1,3)-1)
        end
    pSpBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, scale, scale),cc.FadeIn:create(0.2)))
    pSprite:runAction(cc.Sequence:create(
                               cc.Spawn:create(cc.ScaleTo:create(0.3, scale, scale),cc.FadeIn:create(0.2)),
                               cc.MoveBy:create(0.05, cc.p(offsetX,offsetY)),
                               cc.MoveBy:create(0.05, cc.p(-offsetX*2,-offsetY*2)),
                               cc.MoveBy:create(0.05, cc.p(offsetX,offsetY)
                               )))
    end
end
function QBasePlayer:showJskUI(iScore)
    self.m_pTextJs_ = nil
    local WinLoseTitle = nil    
    if iScore >=0 then
        WinLoseTitle = cc.LabelAtlas:_create(".0000000", NGResources.GameRes.sTextWinScore, 27, 36, string.byte("*"))
        WinLoseTitle:setString("."..iScore)
        self.m_pTextJs_ = display.newSprite("#oxsixex_bg_score1.png")
                            :setAnchorPoint(cc.p(0.5,0.5))
                            :addChild(WinLoseTitle)
        --赢的玩家闪光   
        local reward_box_frames = {}
        for i = 1, 8 do
            local frameName =string.format("oxsixexgold_effect_win%d.png",i)  
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
            table.insert(reward_box_frames, frame)
        end
        local reward_box_ani = cc.Animation:createWithSpriteFrames(reward_box_frames, 0.15) 
        display.newSprite()
	        :move(self.vHeadPos.x,self.vHeadPos.y)
	        :addTo(self)
            :runAction(cc.Sequence:create(cc.Animate:create(reward_box_ani), cc.CallFunc:create(function(ref)
	    	            ref:removeFromParent()
	                end)))       
    else
        WinLoseTitle = cc.LabelAtlas:_create("/0000000", NGResources.GameRes.sTextLoseScore, 27, 36, string.byte("*")) 
        WinLoseTitle:setString("/"..math.abs(iScore)) 
        self.m_pTextJs_ = display.newSprite("#oxsixex_bg_score.png")
                            :setAnchorPoint(cc.p(0.5,0.5))
                            :addChild(WinLoseTitle)                  
    end
    local GoldImg = nil
    GoldImg = display.newSprite("#oxsixex_img_endscore.png")
        :setPosition(0,self.m_pTextJs_:getContentSize().height/2)
        :addTo(self.m_pTextJs_)
    WinLoseTitle:setAnchorPoint(cc.p(0, 0.5))
    WinLoseTitle:setPosition(50 , self.m_pTextJs_:getContentSize().height/2)
    self.scene:addChild(self.m_pTextJs_,3)

    if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then                       
          self.m_pTextJs_:setPosition(cc.p(self.m_tCardPos_.x+180,self.m_tCardPos_.y + 95))
    else                                                                     
          self.m_pTextJs_:setPosition(cc.p(self.m_tCardPos_.x+180,self.m_tCardPos_.y + 80))
    end
    WinLoseTitle:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.FadeOut:create(0.5),
                                                cc.CallFunc:create(function(ref)
			                                        ref:removeFromParent()
		                                         end)))
    GoldImg:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.FadeOut:create(0.5),
                                                cc.CallFunc:create(function(ref)
			                                        ref:removeFromParent()
		                                         end)))
    self.m_pTextJs_:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
                                                 cc.MoveTo:create(1, cc.p(self.m_pTextJs_:getPositionX(),self.m_pTextJs_:getPositionY() + 70)),
                                                 cc.DelayTime:create(2), 
                                                 cc.FadeOut:create(0.5)))
end

function QBasePlayer:showTipsOpenCard(bShow)
    if self.m_nViewID_ == cmd.MY_VIEW_CHAIRID then
        return
    end

    if self.m_pImageTipsCard_ then
        self.m_pImageTipsCard_:setVisible(bShow)
    else
        if bShow then
             self.m_pImageTipsCard_ = display.newSprite("#oxsixex_img_alread.png")
             self:addChild(self.m_pImageTipsCard_,11)

            if self.m_nViewID_ ~= cmd.MY_VIEW_CHAIRID  then
                self.m_pImageTipsCard_:setPosition(cc.p(self.m_tCardPos_.x+140,self.m_tCardPos_.y+55))  
            end
        end
    end
end

function QBasePlayer:removeCardTypeUI()
    if self.m_pNodeType_ then
        self.m_pNodeType_:removeAllChildren()
    end
end

function QBasePlayer:removeHandCardUI()
    for i,v in pairs(self.m_pImageHand_) do
        v:removeFromParent()
        v = nil
    end

    self.m_pImageHand_ = {}
    self.m_tHandCardData_ = {}
end

function QBasePlayer:removeDeskCardUI()
    if self.m_pNodeContain_ then
        self.m_pNodeContain_:removeAllChildren()
    end
end

function QBasePlayer:removeJskUI()
    if self.m_pTextJs_ then 
        self.m_pTextJs_:setVisible(false)
    end
end
function QBasePlayer:removeTipsOpenCardUI()
    if self.m_pImageTipsCard_ then 
        self.m_pImageTipsCard_:setVisible(false)
    end
end
function QBasePlayer:showChat(strChat)
    if self.m_pImageChat_ == nil then
        if self.m_nViewID_ == cmd.VIEW_MIDDLE_RIGHT or self.m_nViewID_ == cmd.VIEW_TOP_RIGHT then
            self.m_pImageChat_ = ccui.ImageView:create(NGResources.GameRes.sChatBj2,ccui.TextureResType.plistType)
            self.m_pImageChat_:setAnchorPoint(display.RIGHT_BOTTOM)
        else
            self.m_pImageChat_ = ccui.ImageView:create(NGResources.GameRes.sChatBj1,ccui.TextureResType.plistType)
            self.m_pImageChat_:setAnchorPoint(display.LEFT_BOTTOM)
        end
        self.m_pImageChat_:setPosition(cc.p(self.vHeadPos.x,self.vHeadPos.y + 55.0))
        self:addChild(self.m_pImageChat_,20)

        local pChat = QScrollText:create(strChat, 22.0, 7)
	    pChat:setAnchorPoint(display.LEFT_CENTER)
	    pChat:setPosition(cc.p(9.0, 24.0))
	    self.m_pImageChat_:addChild(pChat,1,1)
    else
        local pChat = self.m_pImageChat_:getChildByTag(1)
        if pChat then
            pChat:showStr(strChat)
        end

        self.m_pImageChat_:setVisible(true)
    end


end

function QBasePlayer:removeUI()
    self:removeCardTypeUI()
    self:removeHandCardUI()
    self:removeDeskCardUI()
    self:removeJskUI()
    self:removeTipsOpenCardUI()
end

return QBasePlayer

