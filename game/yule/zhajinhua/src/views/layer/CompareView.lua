local CompareView  = class("CompareView",function(config)
		local compareView =  display.newLayer(cc.c4b(0, 0, 0, 125))
    return compareView
end)
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local cmd = appdf.req(appdf.GAME_SRC.."yule.zhajinhua.src.models.CMD_Game")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

function CompareView:onExit()
	print("CompareView onExit")
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()	-- body
end

function CompareView:ctor(config)

	local this = self
	self.m_config = config

	ExternalFun.registerNodeEvent(self) -- bind node event

    display.newSprite("#zhajinhua_icon_longtext.png"	,{scale9 = true ,capInsets=cc.rect(196,24,204,26)})
        :setContentSize(cc.size(1270, 340))  
        :setPosition(667,400)
        :addTo(self)

	self.bgLeft = display.newSprite("#zhajinhua_bg_bipai_bg.png")
		:setPosition(442-500,400)
		:addTo(self)
    self.bgRight = display.newSprite("#zhajinhua_bg_bipai_bg.png")
        :rotate(180)
		:setPosition(900+500,400)
		:addTo(self)
    display.newSprite("#zhajinhua_bg_bipai_v.png")
		:setPosition(486,116)
		:addTo(self.bgLeft)
    display.newSprite("#zhajinhua_bg_bipai_s.png")
        :rotate(180)
		:setPosition(478,122)
		:addTo(self.bgRight)

    self.bgHuo = display.newSprite("#zhajinhua_bg_bipai_huo.png")
        :setPosition(644,412)
        :setVisible(false)
        :addTo(self)

	self.m_FirstCard = {}
	self.m_SecondCard = {}

	for i = 1, 3 do
		self.m_FirstCard[i] = display.newSprite("#zhajinhua_card_back.png")
				:setPosition(228 + 50*(i - 1), 118)
				:addTo(self.bgLeft)
		self.m_SecondCard[i] = display.newSprite("#zhajinhua_card_back.png")
				:setPosition(354 - 50*(i - 1), 118)
				:addTo(self.bgRight)
	end
	self.m_bFirstWin = false

	self.m_flushAni = display.newSprite("#zhajinhua_bg_flash1.png")
        :rotate(-90)
		:setVisible(false)
		:setPosition(667,395)
		:addTo(self)

	self.m_LoseFlag = display.newSprite("#zhajinhua_bg_bipailose_title1.png")
		:setVisible(false)
		:addTo(self)

	self.m_UserInfo = {}
	self.m_UserInfo[1] = {}
	self.m_UserInfo[1].head = HeadSprite:createNormal({}, 80)
		:setPosition(52,143)
		:addTo(self.bgLeft)
	self.m_UserInfo[1].name = ccui.Text:create("", appdf.FONT_FILE, 24)
		:setPosition(52,76)
		:addTo(self.bgLeft)
	self.m_UserInfo[2] = {}
	self.m_UserInfo[2].head = HeadSprite:createNormal({}, 80)
        :rotate(180)
		:setPosition(60,103)
		:addTo(self.bgRight)
	self.m_UserInfo[2].name = ccui.Text:create("", appdf.FONT_FILE, 24)
        :rotate(180)
		:setPosition(60,172)
		:addTo(self.bgRight)

	self.m_AniCallBack = nil
end

function CompareView:StopCompareCard()
	self.m_flushAni:stopAllActions()
	self.m_flushAni:setVisible(false)

	self.m_LoseFlag:setVisible(false)
	self.m_LoseFlag:stopAllActions()

end

function CompareView:CompareCard(firstuser,seconduser,firstcard,secondcard,bfirstwin,callback)
    --填充数据
	self.m_AniCallBack = callback
	for i = 1 , 3  do
		self.m_FirstCard[i]:setSpriteFrame("zhajinhua_card_back.png")
		self.m_SecondCard[i]:setSpriteFrame("zhajinhua_card_back.png")
	end

	self.m_bFirstWin = bfirstwin

	self.m_UserInfo[1].head:updateHead(firstuser)
	self.m_UserInfo[2].head:updateHead(seconduser)

	local nickname 
	if firstuser and firstuser.szNickName then
		nickname = firstuser.szNickName
	else
		nickname = "游戏玩家"
	end

	self.m_UserInfo[1].name:setString(string.EllipsisByConfig(nickname,105, self.m_config))

	if seconduser and seconduser.szNickName then
		nickname = seconduser.szNickName
	else
		nickname = "游戏玩家"
	end

	self.m_UserInfo[2].name:setString(string.EllipsisByConfig(nickname,105, self.m_config))

	self:setVisible(true)

    self.bgLeft:setPosition(442-500,400)
    self.bgRight:setPosition(900+500,400)
    self.bgLeft:runAction(cc.MoveTo:create(0.5,cc.p(442,400)))
    self.bgRight:runAction(cc.MoveTo:create(0.5,cc.p(900,400)))
    self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                self.bgHuo:setVisible(true)                           
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                self.bgHuo:setVisible(false)
                self:PlayFlash()                            
            end)))
end
function CompareView:PlayFlash()
    self.m_flushAni:stopAllActions()

	self.m_flushAni:setVisible(true)

	local animation = cc.Animation:create()
	local i = 1
	while true do
        local strVS = string.format("zhajinhua_bg_flash%d.png",i)
		i = i + 1
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strVS)
		if spriteFrame then
			animation:addSpriteFrame(spriteFrame)
		else
			break
		end
	end

	animation:setLoops(3)
	animation:setDelayPerUnit(0.1)
	local animate = cc.Animate:create(animation)
	local animateVS = cc.Spawn:create(animate, cc.CallFunc:create(function()
		--ExternalFun.playSoundEffect(cmd.RES.."sound_res/COMPARE_ING.wav")
    end))

	self.m_flushAni:runAction(cc.Sequence:create(
		animateVS,
		cc.CallFunc:create(
			function()
				self:FlushEnd()
			end)
		))
end
function CompareView:FlushEnd()
	local this = self
	self.m_flushAni:stopAllActions()

	self.m_flushAni:setVisible(false)

	if self.m_bFirstWin == true then
		self.m_LoseFlag:move(887, 395)
	else
		self.m_LoseFlag:move(448, 395)
	end
	self.m_LoseFlag:setVisible(true)
    local animation = cc.Animation:create()
	local i = 1
	while true do
        local strLost = string.format("zhajinhua_bg_bipailose_title%d.png",i)
		i = i + 1
		local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strLost)
		if spriteFrame then
			animation:addSpriteFrame(spriteFrame)
		else
			break
		end
	end    
    animation:setLoops(1)
	animation:setDelayPerUnit(0.1)
    local animate = cc.Animate:create(animation)
    self.m_LoseFlag:runAction(cc.Sequence:create(
            animate,
            cc.CallFunc:create(
			    function()
				    for i = 1 , 3  do
					    if not this.m_bFirstWin then 
						    this.m_FirstCard[i]:setSpriteFrame("zhajinhua_card_break.png")
					    else
						    this.m_SecondCard[i]:setSpriteFrame("zhajinhua_card_break.png")
					    end
				    end
			    end),
		    cc.DelayTime:create(0.5),
		    cc.CallFunc:create(
			    function()
				    this.m_AniCallBack()
			    end
			    )
	    ))                   
end


return CompareView