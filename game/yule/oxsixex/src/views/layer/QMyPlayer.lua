--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local QBasePlayer = import(".QBasePlayer")
local QMyPlayer = class("QMyPlayer",QBasePlayer)
local cmd = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local CardSprite = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.bean.CardSprite")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.GameLogic")
local NGResources = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.views.NGResources")
QMyPlayer.CARDPILEHEIGHT = 35
function QMyPlayer:ctor(scene, vpos,cardPos)
    QMyPlayer.super.ctor(self)
    self.scene = scene
    self.m_nViewID_ = cmd.MY_VIEW_CHAIRID
    self.m_nShoot = {}
    self.m_TouchIndex_ = 0
    self.m_CardIndex_ = 1
    self.m_bClick_ = false
    
    for i=1,cmd.MAX_COUNT do
        table.insert(self.m_nShoot,false)
    end
    
    if vpos then
        self.vHeadPos = vpos
    end

    if cardPos then
        self.m_tCardPos_ = cardPos
    end

    self:initContain()
    self:initBackAct()
    self:enableNodeEvents()

    -- 发牌动画
    self.m_bCardAnimation = false
    self.m_tCardData = {}
end

function QMyPlayer:onEnter()
    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(false)
    self.m_pListener:registerScriptHandler( function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	self.m_pListener:registerScriptHandler( function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    self.m_pListener:registerScriptHandler( function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_pListener, self)

    --self:addGuessBackKey()
end

function QMyPlayer:onExit()

end

function QMyPlayer:setCardAnimation(cbCardData)
    self.m_tCardData = cbCardData
    self.m_bCardAnimation = true
    print("self.m_bCardAnimation = false")
end

function QMyPlayer:flushCard() 
    print("QMyPlayer:flushCard() ")   
    self.m_pImageBack_[self.m_CardIndex_]:setVisible(true)
    self.m_pImageBack_[self.m_CardIndex_]:setScale(1)
    self.m_pImageBack_[self.m_CardIndex_]:setPosition(cc.p(self.m_tCardPos_.x + (self.m_CardIndex_-1) * (self.m_pImageBack_[1]:getContentSize().width/2),QMyPlayer.CARDPILEHEIGHT))
    self:showHandCardUI(self.m_tCardData,true)
    if self.m_CardIndex_ == 5 then
        self.m_CardIndex_ = 1
    else
        self.m_CardIndex_ = self.m_CardIndex_ + 1
    end
end 

function QMyPlayer:removeThis()
    for i,v in pairs(self.m_pImageBack_) do
        v:setVisible(false)
    end
    self.m_bCardAnimation = false
    print("self.m_bCardAnimation = true")
    
    --self:showHandCardUI(self.m_tCardData)
end

function QMyPlayer:showHandCardUI(cbCardData,bSingle)
    local pTexture  = cc.Director:getInstance():getTextureCache():addImage(NGResources.GameRes.sCardPath)
    local pNode = nil
    if bSingle then
         pNode = CardSprite:create(cbCardData[self.m_CardIndex_],pTexture,CardSprite.CARD_TYPE_HNAD)
         pNode:setPosition(cc.p(self.m_tCardPos_.x + (self.m_CardIndex_-1) * (pNode:getContentSize().width/2) , QMyPlayer.CARDPILEHEIGHT))
         self:addChild(pNode,2)
         table.insert(self.m_pImageHand_,pNode)
    else
        self:removeHandCardUI()
        
        for i,v in pairs(cbCardData) do
            pNode = CardSprite:create(v,pTexture,CardSprite.CARD_TYPE_HNAD)
            pNode:setPosition(cc.p(self.m_tCardPos_.x + (i-1) * (pNode:getContentSize().width/2) , QMyPlayer.CARDPILEHEIGHT))
            self:addChild(pNode,2)
            table.insert(self.m_pImageHand_,pNode)
        end
    end
    self.m_tHandCardData_ = clone(cbCardData)
end

function QMyPlayer:showDeskCardUI(cbCardData,bOx)
    if bOx == 0 or bOx == 255 then
        return
    end
    local x1,y1 = 0,0
    for i=1,cmd.MAX_COUNT do
        if self.m_pImageHand_[i] then
            self.m_pImageHand_[i]:stopAllActions()
            local posX = self.m_tCardPos_.x + (i-1) * self.m_pImageHand_[i]:getContentSize().width/2
            self.m_pImageHand_[i]:setPosition(posX,QMyPlayer.CARDPILEHEIGHT)
        end
--        if i>=4 then
--            if self.m_pImageHand_[i] then
--                self.m_pImageHand_[i]:stopAllActions()
--                x1 = self.m_pImageHand_[1]:getPositionX() + self.m_pImageHand_[i]:getContentSize().width/4 + (i-4)*self.m_pImageHand_[i]:getContentSize().width/2
--                y1= QMyPlayer.CARDPILEHEIGHT + self.m_pImageHand_[i]:getContentSize().height/2
--                self.m_pImageHand_[i]:setPosition(cc.p(x1,y1))
--                self.m_pImageHand_[i]:setZOrder(1)
--            end
--        else
--            if self.m_pImageHand_[i] then
--                self.m_pImageHand_[i]:stopAllActions()
--                local posX =self.vHeadPos.x + 130 + (i-1) * self.m_pImageHand_[i]:getContentSize().width/2
--                self.m_pImageHand_[i]:setPosition(posX,QMyPlayer.CARDPILEHEIGHT)
--            end
--        end
    end
end

function QMyPlayer:SetShootCard(bCardDataIndex,dwCardCount)
    local iNum = table.nums(bCardDataIndex)
    if iNum < dwCardCount then  
        return
    end

    self:selectCardDown(false)

	--弹起扑克
	for j=1,dwCardCount do
		for i,v in pairs(self.m_tHandCardData_) do
			if v==bCardDataIndex[j] then
                local pImage = self.m_pImageHand_[i]
		        if pImage then
			        pImage:setSelectCard(true)
                end
				break;
			end
		end
	end
end

function QMyPlayer:GetShootCard(bShoot)
    local t_data = {}
    for i,v in pairs(self.m_pImageHand_) do
        if v:getSelectBool() == bShoot then
            table.insert(t_data,self.m_tHandCardData_[i])
        end
    end

    return t_data
end

function QMyPlayer:selectCardDown()
    for i,v in pairs(self.m_pImageHand_) do
        v:setSelectCard(false)
    end
end

function QMyPlayer:judgeCardType()
    self.m_nCardColor_ = GameLogic.GetCardColor(cardData)
    self.m_nCardValue_ = GameLogic.GetCardLogicValue(cardData)
    local bNoN = false
    local tData = self:GetShootCard(true)
    if #tData == 3 then
        if GameLogic.GetCardLogicValue(tData[1])+GameLogic.GetCardLogicValue(tData[2])+GameLogic.GetCardLogicValue(tData[3])%10 == 0 then
            local tData1 = self:GetShootCard(false)
            local cbValue = (GameLogic.GetCardLogicValue(tData1[1]) + GameLogic.GetCardLogicValue(tData1[2])) % 10;
            self:showCardTypeUI(cbValue)
            bNoN = true
        end 
    end

    if not bNoN then
        self:removeCardTypeUI()
    end
end

function QMyPlayer:isCanTouch()
    if self.scene:getGameLayerObj():getGameStatues() == cmd.GameStatues.START_STATUES then
        return true
    end
    return false
end
function QMyPlayer:onTouchBegan(touch, event)
    if not self:isCanTouch() then
        return false
    end
    local beginPoint = self:convertToNodeSpace(touch:getLocation())
    --print("beginPoint.x===%f,beginPoint.y=====%f",beginPoint.x,beginPoint.y)
    for i=#self.m_pImageHand_,1,-1 do
        if true == self.m_pImageHand_[i]:isTouchCard(beginPoint) then
            self.m_TouchIndex_ = i
            self.m_bClick_ = true
            print("self.m_TouchIndex_====" .. self.m_TouchIndex_)
            return true
		end
    end
    return true
end

function QMyPlayer:onTouchMoved(touch, event)

end

function QMyPlayer:onTouchEnded(touch, event)
	if self.m_bClick_ then
        local endPoint = self:convertToNodeSpace(touch:getLocation())
        local pImage = self.m_pImageHand_[self.m_TouchIndex_]
		if pImage and true == pImage:isTouchCard(endPoint) then
			pImage:setSelectCard(true)
            print("self.m_TouchIndex_====" .. self.m_TouchIndex_)
            self.scene:showAdNiuK(true)
        end
        self.m_bClick_ = false;
	end
	
end

return QMyPlayer