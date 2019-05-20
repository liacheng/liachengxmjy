--
-- Author: zhouweixiang
-- Date: 2016-12-27 17:55:44
--
--游戏结算层
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.28gangbattle.src.models.GameLogic")

local GameResultLayer = class("GameResultLayer", cc.Layer)

GameResultLayer.BT_CLOSE = 1

function GameResultLayer:ctor(viewParent)
	self.m_parent = viewParent

	self.m_ResultNode = nil
    self:initResultLayer()
end

function GameResultLayer:initResultLayer()

    local function btnEvent( sender, eventType )
         ExternalFun.btnEffect(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

	local csbNode = ExternalFun.loadCSB("GameResult.csb", self)
	self.m_ResultNode = csbNode

	local temp = csbNode:getChildByName("im_result_bg")
	self.m_spBg = temp

    --庄家名称
    self.m_BankerName = csbNode:getChildByName("txt_bankername")
        :setFontName("fonts/round_body.ttf")
    --庄家输赢分
    self.m_BankerScore = csbNode:getChildByName("txt_bankerscore")
    --玩家名称
    self.m_SelfName = csbNode:getChildByName("txt_selfname")
        :setFontName("fonts/round_body.ttf")
    --玩家输赢分
    self.m_SelfScore = csbNode:getChildByName("txt_selfscore")
    --玩家未下注
	self.m_SelfNoChip = csbNode:getChildByName("im_nochip")

    --关闭按钮
	self.m_BtnClose = csbNode:getChildByName("bt_close")
        :setTag(GameResultLayer.BT_CLOSE)
        :addTouchEventListener(btnEvent)
end


function GameResultLayer:showGameResult(selfscore, chipscore, bankerscore,alScore,tagUserWinRank)
	self.m_lselfscore = selfscore
	self.m_lselfchipscore = chipscore
	self.m_lbankerscore = bankerscore
    self.m_alScore = alScore
    self.m_tagUserWinRank = tagUserWinRank
	ExternalFun.showLayer(self, self,true,true,self.m_spBg,false)
    self:showGameResultData()
end

function GameResultLayer:showGameResultData()
    --设置输赢分数
    self:setWinLoseScore()
    --设置三门牌值
    self:setMenCard()
    --设置三门输赢分数倍数
    self:setMenScore()
    --设置输赢排行榜
    self:setRankScore()
end
function GameResultLayer:setWinLoseScore()
     --庄家名称
    if self.m_parent.m_wBankerUser == yl.INVALID_CHAIR then
        self.m_BankerName:setString("系统坐庄")
    else
        local userItem = self.m_parent:getDataMgr():getChairUserList()[self.m_parent.m_wBankerUser + 1]
        self.m_BankerName:setString(userItem.szNickName)
    end

    local str = ""
    --庄家输赢分
    if self.m_lbankerscore < 0 then         
        str = "/"..math.abs(self.m_lbankerscore)
        self.m_BankerScore:setProperty(str, "28gang_fonts_lose.png", 27, 36, "*")
    else
        str = "."..math.abs(self.m_lbankerscore)
        self.m_BankerScore:setProperty(str, "28gang_fonts_win.png", 27, 36, "*")   
    end

    --玩家名称
    local userItem = self.m_parent:getMeUserItem()
    self.m_SelfName:setString(userItem.szNickName)   
   
    --玩家输赢分
    local bChip = false
    for k,v in pairs(self.m_lselfchipscore) do 
        if v ~= 0 then 
            bChip = true
            break
        end
    end
    if bChip == false then 
        self.m_SelfNoChip:setVisible(true)
        self.m_SelfScore:setVisible(false)
    else
        self.m_SelfNoChip:setVisible(false)
        self.m_SelfScore:setVisible(true)

        if self.m_lselfscore < 0 then            
            str = "/"..math.abs(self.m_lselfscore)
            self.m_SelfScore:setProperty(str, "28gang_fonts_lose.png", 27, 36, "*")
        else     
            str = "."..math.abs(self.m_lselfscore)
            self.m_SelfScore:setProperty(str, "28gang_fonts_win.png", 27, 36, "*")      
        end
    end

	if self.m_lselfscore >= 0 then
		ExternalFun.playSoundEffect("gameWin.wav")
	else
		ExternalFun.playSoundEffect("gameLose.wav")
	end	
end
function GameResultLayer:setMenCard()
    for i = 2,4 do 
        local obj = self.m_ResultNode:getChildByName("node_chip"..i) 
        --牌值图片
        for j = 1 ,2 do
            local im_pai = obj:getChildByName("im_pai"..j) 
            local im_value = im_pai:getChildByName("im_value") 
            im_value:setSpriteFrame(self:getCardImg(i,j))
        end
        --输赢遮罩
        local im_mask = obj:getChildByName("im_mask") 
        if self.m_parent.m_bUserOxCard[i] == -1 then 
            im_mask:setVisible(true)
        else
            im_mask:setVisible(false)          
        end
        --牌点数
        self:setCardPointImg(i,obj)
       
    end
end
function GameResultLayer:getCardImg(menIndex,cardIndex)
    local cardValue = self.m_parent.m_cbTableCardArray[menIndex][cardIndex]
    if cardValue == 16 then 
        return cc.SpriteFrameCache:getInstance():getSpriteFrame("28gang_img_value10.png")
    else
        return cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("28gang_img_value%d.png",cardValue))
    end
end
function GameResultLayer:setCardPointImg(menIndex,menObj)
    local im_CardType = menObj:getChildByName("im_cardtype")
    local txt_dianshu = menObj:getChildByName("txt_dianshu")
    local im_dianshu1 = menObj:getChildByName("im_dianshu1")
    local im_dianshu2 = menObj:getChildByName("im_dianshu2")
    local cardData = self.m_parent.m_cbTableCardArray[menIndex]
    local cardType = GameLogic:GetCardType(cardData,#cardData)
    if cardType > 1 then 
        im_CardType:setVisible(true)
        txt_dianshu:setVisible(false)
        im_dianshu1:setVisible(false)
        im_dianshu2:setVisible(false)
        im_CardType:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("28gang_img_cardtype%d.png",cardType)))
    else
        im_CardType:setVisible(false)
        txt_dianshu:setVisible(true)
        im_dianshu1:setVisible(true)
        local cardPoint,isWhite = GameLogic:GetCardListPip( cardData )
        if isWhite == true then 
            txt_dianshu:setString(cardPoint-0.5)
            im_dianshu2:setVisible(true)
        else
            txt_dianshu:setString(cardPoint)
            im_dianshu2:setVisible(false)
        end      
    end
end
function GameResultLayer:setMenScore()
    local score = 0
    for i = 2 , 4 do 
        local obj = self.m_ResultNode:getChildByName("node_chip"..i) 
        score = self.m_alScore[1][i]
        local lose = obj:getChildByName("txt_scorelose")
            :setFontName("fonts/round_body.ttf")
        local win =  obj:getChildByName("txt_scorewin")
            :setFontName("fonts/round_body.ttf")
        if score > 0 then 
            lose:setVisible(true)
            lose:setString("-"..math.abs(score))
            win:setVisible(false)            
        else
            lose:setVisible(false)
            win:setVisible(true)
            win:setString(math.abs(score))           
        end
    end
end
function GameResultLayer:setRankScore()
    local rankList = self.m_tagUserWinRank[1]
    local rankNode = self.m_ResultNode:getChildByName("node_ph") 
    for i = 1 ,3 do 
        local objName = rankNode:getChildByName("txt_ph_name"..i)
            :setFontName("fonts/round_body.ttf")
        local objScore = rankNode:getChildByName("txt_ph_score"..i)
            :setFontName("fonts/round_body.ttf")
        local name = ""
        local score = 0
        if rankList[i].lRankWinScore <= 0 then 
            name = "无"
            score = ""
        else
            name = ExternalFun.GetShortName(rankList[i].szNickName,12,10)
            score = "+"..rankList[i].lRankWinScore
        end
        objName:setString(name)
        objScore:setString(score)
    end
end
function GameResultLayer:onButtonClickedEvent(tag, ref)
    if GameResultLayer.BT_CLOSE == tag then
        ExternalFun.hideLayer(self, self, false)
    end
end
function GameResultLayer:clear()
	
end

return GameResultLayer