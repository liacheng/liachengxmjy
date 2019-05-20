local GameEndView =  class("GameEndView",function(config)
        local gameEndView =  display.newLayer(cc.c4b(0, 0, 0, 0))
    return gameEndView
end)
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

--GameEndView.BT_CLOSE = 1
GameEndView.BT_GAME_CONTINUE = 2
GameEndView.BT_CHANGE_TABLE = 3


function GameEndView:ctor(config)
	local this = self

	--按钮回调
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
			this:OnButtonClickedEvent(ref:getTag(),ref)
        end
    end

    self.m_config = config

    self._endViewBg = display.newSprite("#zhajinhua_bg_kuang.png",{scale9 = true ,capInsets=cc.rect(68,83,53,88)})
        :setContentSize(cc.size(823, 472))
        :setPosition(666,390)
        :addTo(self)

    local btnChangeChair = ccui.Button:create("zhajinhua_btn_green_normal.png","zhajinhua_btn_green_normal.png","",ccui.TextureResType.plistType)
    btnChangeChair:setTag(GameEndView.BT_CHANGE_TABLE)
    btnChangeChair:move(667-221,197)
    btnChangeChair:setVisible(true)
    btnChangeChair:addTo(self)
    btnChangeChair:addTouchEventListener(btcallback)
    display.newSprite("#zhajinhua_btntab_changetable.png")
        :setPosition(btnChangeChair:getContentSize().width/2,btnChangeChair:getContentSize().height/2)
        :addTo(btnChangeChair)
    if GlobalUserItem.bPrivateRoom then --私有房不支持换桌
        -- 设置倒计时
        -- btnChangeChair:setVisible(false)
    end  

    local btnGoOn = ccui.Button:create("zhajinhua_btn_yellow_normal.png","zhajinhua_btn_yellow_normal.png","",ccui.TextureResType.plistType)
    btnGoOn:setTag(GameEndView.BT_GAME_CONTINUE)
    btnGoOn:move(667+221,197)
    btnGoOn:addTo(self)
    btnGoOn:addTouchEventListener(btcallback)
    display.newSprite("#zhajinhua_btntab_jixu.png")
        :setPosition(btnGoOn:getContentSize().width/2,btnGoOn:getContentSize().height/2)
        :addTo(btnGoOn)
    if GlobalUserItem.bPrivateRoom then
        -- 设置倒计时
        btnGoOn:move(667, 197)
    end 
    
    self.UserBg = {}
    self.m_UserScore = {}
    self.m_UserName = {}
    self.m_UserHead = {}
    self.m_UserResult = {}
    self.m_UserCard = {}
    self.m_CardType = {}

    local ptBg = {cc.p(345,418),cc.p(506,418),cc.p(667,418),cc.p(828,418),cc.p(989,418)}
    local ptHead = {cc.p(345,535),cc.p(506,535),cc.p(667,535),cc.p(828,535),cc.p(989,535)}
    local ptName = {cc.p(345,475),cc.p(506,475),cc.p(667,475),cc.p(828,475),cc.p(989,475)}
    local ptFlag = {cc.p(345,435),cc.p(506,435),cc.p(667,435),cc.p(828,435),cc.p(989,435)}
    local ptCard = {cc.p(315,340),cc.p(476,340),cc.p(637,340),cc.p(798,340),cc.p(959,340)}
    local ptType = {cc.p(345,331),cc.p(506,331),cc.p(667,331),cc.p(828,331),cc.p(989,331)}
    local ptScore = {cc.p(345,260),cc.p(506,260),cc.p(667,260),cc.p(828,260),cc.p(989,260)}
    for i = 1 , 5 do
        --背景
        display.newSprite("#zhajinhua_bg_end_kuang.png")
            :setPosition(ptBg[i])
            :addTo(self)

        self.m_UserHead[i] = HeadSprite:createNormal({}, 80)
            :move(ptHead[i])
            :addTo(self)

        self.m_UserName[i] = ccui.Text:create("", appdf.FONT_FILE, 24)
            :move(ptName[i])
            :addTo(self)

        self.m_UserScore[i] = ccui.Text:create("", appdf.FONT_FILE, 24)
            :move(ptScore[i])
            :addTo(self)

        self.m_UserResult[i] = display.newSprite("#zhajinhua_icon_endwin.png")
        --display.newSprite("#game_end_flagwin.png")
            :move(ptFlag[i])
            :addTo(self)

        self.m_UserCard[i] = {}
        for j = 1 , 3 do
            self.m_UserCard[i][j] = display.newSprite("#zhajinhua_card_back.png")
                :move(ptCard[i].x + (j-1)*30,ptCard[i].y)
                :setScale(0.7)
                :addTo(self)
        end

        self.m_CardType[i] = display.newSprite("#zhajinhua_icon_cardtype_0.png")
            :move(ptType[i])
            --:setScale(0.7)
            :addTo(self)
    end
    
    self.spLight = display.newSprite("#zhajinhua_endlight_win.png")
        :setPosition(650,640)
        :addTo(self)
    

    display.newSprite("#zhajinhua_bg_tipstitle.png")
        :setPosition(660,623)
        :addTo(self)

    display.newSprite("#zhajinhua_bg_endtitle.png")
        :setPosition(660,645)
        :addTo(self)   
end

function GameEndView:OnButtonClickedEvent(tag,ref)
    self:setVisible(false)
    if tag == GameEndView.BT_GAME_CONTINUE then
        if  self:getParent()._scene.m_bNoScore then
            local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
            local msg = self:getParent()._scene.m_szScoreMsg or "你的金币不足，无法继续游戏"
            local query = QueryDialog:create(msg, function(ok)
                if ok == true then
                    self:getParent()._scene:onExitTable()
                end
            query = nil
            end, 32, QueryDialog.QUERY_SURE):setCanTouchOutside(false)
            :addTo(self:getParent()._scene)
        else
            self:getParent():onBtnStart()
        end
    elseif tag == GameEndView.BT_CHANGE_TABLE then
        --防作弊判断
        if self:getParent()._scene._gameFrame.bEnterAntiCheatRoom == true and GlobalUserItem.isForfendGameRule() then
            showToast(cc.Director:getInstance():getRunningScene(), "游戏进行中无法换桌...", 2)
        else
            self:getParent()._scene:onChangeDesk()
        end
    end

end

function GameEndView:ReSetData()

    for i = 1 , 5 do
        self.m_UserHead[i]:setVisible(false)
        self.m_UserName[i]:setVisible(false)
        self.m_UserScore[i]:setVisible(false)
        self.m_UserResult[i]:setVisible(false)
        for j = 1 , 3 do
            self.m_UserCard[i][j]:setVisible(false)
        end
        self.m_CardType[i]:setVisible(false)
    end
    self.spLight:runAction(cc.RotateBy:create(25, 3600))
end

function GameEndView:SetUserScore(viewid , score)
    self.m_UserScore[viewid]:setVisible(true)
    local szScore = (score > 0 and "+" or "")..score
    self.m_UserScore[viewid]:setColor((score>0) and cc.c4b(252,255,0,255) or cc.c4b(0,208,253,255))
    self.m_UserScore[viewid]:setString(string.EllipsisByConfig(szScore,125, self.m_config))
end

function GameEndView:SetUserInfo(viewid,useritem)
    self.m_UserHead[viewid]:setVisible(true)
    self.m_UserHead[viewid]:updateHead(useritem)

    self.m_UserName[viewid]:setVisible(true)
    if useritem and useritem.szNickName then
        self.m_UserName[viewid]:setString(string.EllipsisByConfig(useritem.szNickName,125, self.m_config))
    else
        self.m_UserName[viewid]:setString("游戏玩家")
    end
end

GameEndView.RES_CARD_TYPE = {"zhajinhua_icon_cardtype_0.png","zhajinhua_icon_cardtype_1.png","zhajinhua_icon_cardtype_2.png","zhajinhua_icon_cardtype_3.png","zhajinhua_icon_cardtype_4.png","zhajinhua_icon_cardtype_5.png"}

function GameEndView:SetUserCard(viewid,cardData,cardtype,isbreak)
    for i = 1, 3 do
        local spCard = self.m_UserCard[viewid][i]
        if not cardData or not cardData[i] or cardData[i] == 0 or cardData[i] == 0xff  then
            spCard:setSpriteFrame(not isbreak and "zhajinhua_card_back.png" or"zhajinhua_card_break.png")
        else
            local strCard = string.format("zhajinhua_card_player_%02d.png",cardData[i])
            spCard:setSpriteFrame(strCard)
        end
        spCard:setVisible(true)
    end

    if cardtype and cardtype >= 1 and cardtype <= 6 then 
        self.m_CardType[viewid]:setSpriteFrame(GameEndView.RES_CARD_TYPE[cardtype])
        self.m_CardType[viewid]:setVisible(true)
    else
        self.m_CardType[viewid]:setVisible(false)
    end

end

function GameEndView:SetWinFlag(viewid,score,cardtype)
    self.m_UserResult[viewid]:setVisible(true)
    if 0 == score then
        self.m_UserResult[viewid]:setVisible(true)
    end
    self.m_UserResult[viewid]:setSpriteFrame(score < 0 and "zhajinhua_icon_endlose.png" or "zhajinhua_icon_endwin.png")

    if score > 0 then
        if cardtype > 1 and cardtype <= 6 then
            local soundStr = "zhajinhua_card_type" .. cardtype .. ".mp3"
            ExternalFun.playSoundEffect(soundStr)
        end
    end
end

function GameEndView:GetMyBoundingBox()
    return self._endViewBg:getBoundingBox()
end

return GameEndView