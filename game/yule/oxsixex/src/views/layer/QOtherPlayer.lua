--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local QBasePlayer = import(".QBasePlayer")
local QOtherPlayer = class("QOtherPlayer",QBasePlayer)
local cmd = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.bean.CardSprite")
local NGResources = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.NGResources")
function QOtherPlayer:ctor(scene, viewID,vpos,cardPos)
    QOtherPlayer.super.ctor(self)
    self.scene = scene
    if viewID then
        self.m_nViewID_ = viewID
    end

    if vpos then
        self.vHeadPos = vpos
    end

    if cardPos then
        self.m_tCardPos_ = cardPos
    end

    self:initContain()
    self:initBackAct()
    self.m_CardIndex_ = 1
    self.m_tCardData = {}
    self.m_noOXPos_ = {}
end

function QOtherPlayer:flushCard()
    self.m_pImageBack_[self.m_CardIndex_]:setPosition(cc.p(self.m_tCardPos_.x + (self.m_CardIndex_-1) * self.m_pImageBack_[1]:getContentSize().width/2,self.m_tCardPos_.y))
    self.m_pImageBack_[self.m_CardIndex_]:setVisible(true)
    
    if self.m_CardIndex_ == 5 then
        self.m_CardIndex_ = 1
    else
        self.m_CardIndex_ = self.m_CardIndex_ + 1
    end
end 

function QOtherPlayer:setCardAnimation(cbCardData)
    self.m_tCardData = cbCardData
    self.m_bCardAnimation = true
end

function QOtherPlayer:removeThis()
    for i,v in pairs(self.m_pImageBack_) do
        v:setVisible(false)
    end   
    self:showHandCardUI(self.m_tCardData)
    self.m_bCardAnimation = false
end

function QOtherPlayer:showHandCardUI(cbCardData)
    self.m_pNodeContain_:removeAllChildren()
    self.m_noOXPos_ = {}
    local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sCardPath)
    local pSprite = nil
 
    for i=1,cmd.MAX_COUNT do
        local cardRect = cc.rect(2*110.0,4*150.0,110,150);
	    pSprite = cc.Sprite:createWithTexture(pTexture,cardRect)
        pSprite:setScale(0.8)        
        pSprite:setPosition(cc.p((i-1) * pSprite:getContentSize().width/2,0))
        pSprite:setAnchorPoint(cc.p(0,0))
        pSprite:setTag(i)
        self.m_pNodeContain_:addChild(pSprite)
        table.insert(self.m_noOXPos_,pSprite:getPositionX())  
    end
end
function QOtherPlayer:showDeskCardAni()
    local open_frames = {}
    for k = 1, 3 do
        local frameName =string.format("oxsixex_opencard_%d.png",k)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(open_frames, frame)
    end
    local open_ani = cc.Animation:createWithSpriteFrames(open_frames, 0.1) 
    for i = 1 ,cmd.MAX_COUNT do 
        obj = self.m_pNodeContain_:getChildByTag(i)
        seqAn = cc.Sequence:create(cc.DelayTime:create(i*0.1),
                                        cc.Animate:create(open_ani),                                                 
                                        cc.CallFunc:create(function(ref)
                                            ref:removeFromParent()
                                        end),
                                        cc.RemoveSelf:create())
        obj:runAction(seqAn)
    end
end
function QOtherPlayer:showDeskCardUI(cbCardData,bOx)
    --self:showDeskCardAni()
    local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sCardPath)
    local open_frames = {}
    for k = 1, 3 do
        local frameName =string.format("oxsixex_opencard_%d.png",k)  
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
        table.insert(open_frames, frame)
    end
    local open_ani = cc.Animation:createWithSpriteFrames(open_frames, 0.1) 

    for i = 1 ,cmd.MAX_COUNT do      
        obj = self.m_pNodeContain_:getChildByTag(i)         
        obj:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.1),
                                            cc.Animate:create(open_ani),                                                                                        
                                            cc.CallFunc:create(function(ref)    
                                                local pNode = CardSprite:create(cbCardData[i],pTexture,CardSprite.CARD_TYPE_HNAD) 
                                                pNode:setAnchorPoint(cc.p(0,0)) 
                                                pNode:setScale(0.8)  
                                                pNode:setPosition(ref:getPositionX(),0)                    
                                                ref:getParent():addChild(pNode,i)  
                                            end),
                                            cc.RemoveSelf:create()))
    end
end

return QOtherPlayer