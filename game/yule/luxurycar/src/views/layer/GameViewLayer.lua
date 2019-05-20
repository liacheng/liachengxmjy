--
-- Author: Tang
-- Date: 2016-10-11 17:22:24
--

--[[

	游戏交互层
]]

local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.luxurycar.src"

--external
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
--
local  BankerList = module_pre..".views.layer.BankerList"
local  UserList = module_pre..".views.layer.UserList"
local  SettingLayer = module_pre..".views.layer.SettingLayer"
local  Chat = module_pre..".views.layer.Chat"
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local QueryDialog = require("app.views.layer.other.QueryDialog")
local BankLayer = appdf.req(module_pre .. ".views.layer.BankLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")
local GameSystemMessage = require(appdf.EXTERNAL_SRC .. "GameSystemMessage")
GameViewLayer.TAG_GAMESYSTEMMESSAGE = 6751

local TAG_ZORDER = 
{	
	CLOCK_ZORDER = 10,
	BANK_ZORDER	 = 30,
	SET_ZORDER	 = 40,
	HELP_ZORDER	 = 50
}

local TAG_ENUM = 
{
	TAG_USERNICK = 1000,
	TAG_USERSCORE = 2000
}

--申请庄家
GameViewLayer.unKnown = 0
GameViewLayer.unApply = 1	--未申请
GameViewLayer.applyed = 2	--已申请

function GameViewLayer:ctor(scene)
    self.lUserScore = 0
    self._scene = scene
    self.oneCircle	= 16		--一圈16个豪车
    self.index = 2				--豪车索引	
    self.time = 0.05			--转动时间间隔
    self.count = 0				--转动次数
    self.endindex = -1			--停止位置
    self.JettonIndex = -1
    self.bContinueRecord = true  
    self.bAnimate		 = false
    self.bPoints		 = false

    self._bank = nil             --银行
    self._bankerView= nil        --上庄列表
    self._UserView = nil         --玩家列表
    self._ChatView = nil         --聊天

    self.m_cbGameStatus = 0
    self.m_eApplyStatus = GameViewLayer.unApply

    self:gameDataInit()
    --初始化csb界面
    self:initCsbRes()
    self:initTableJettons({0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0})
    self:showMyselfInfo()
    self:initTableview()
	
    --注册事件
    ExternalFun.registerTouchEvent(self,true)	
    ExternalFun.setBackgroundAudio("sound_res/luxurycar_bgm.mp3")
end

function GameViewLayer:restData()
    self.index = 2			
    self.time = 0.05
    self.count = 0
    self.endindex = -1
    self.bAnimate = true
    self:SetJettonIndex(-1)
 	
    if self:GetJettonRecord() == 0 then
        self.bContinueRecord = true
    else
        self.bContinueRecord = false
    end
end

function GameViewLayer:getTimeQueue(index)
    local a1 = 0.1
    local a96 = ((self._scene.m_cbLeftTime-(0.1*32))*2)/96 - a1
    local per = (a96 - a1)/(96-1)
    local  time  = a1 + (index - 1) * per

    --[[print("a96 is ========== >"..a96)
    print("per is ================>"..per)
    print("time is =================== >"..time..",index is ================= >"..index)]]
    return time
end

function GameViewLayer:setTimePer()
    local percent = self._scene.m_cbLeftTime / 20
    self.time = self.time * percent
end

function GameViewLayer:gameDataInit(  )
    --加载资源
    self:loadRes()
end

function GameViewLayer:getParentNode( )
    return self._scene;
end

function GameViewLayer:getDataMgr( )
    return self:getParentNode():getDataMgr()
end

function GameViewLayer:showPopWait( )
    self:getParentNode():showPopWait()
end

function GameViewLayer:dismissPopWait( )
    self:getParentNode():dismissPopWait()
end

function GameViewLayer:loadRes()

end

function GameViewLayer:initTableview()
    local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
    self._bankerView = g_var(BankerList):create(self._scene._dataModle)
    self._bankerView:setContentSize(cc.size(260, 310))
    self._bankerView:setAnchorPoint(cc.p(0.0,0.0))
    self._bankerView:setPosition(cc.p(10, 21))
    bankerBG:addChild(self._bankerView)
end

function GameViewLayer:showMyselfInfo()
    local useritem = self._scene:GetMeUserItem()

    --玩家头像
    local head = g_var(PopupInfoHead):createNormal(useritem, 118)
    head:setPosition(72,70)
    self:addChild(head)
    --head:enableInfoPop(true)

    --玩家昵称
    local nick =  g_var(ClipText):createClipText(cc.size(120, 20),useritem.szNickName);
    nick:setAnchorPoint(cc.p(0.0,0.5))
    nick:setPosition(135, 65)
    self:addChild(nick)

    --用户游戏币
    self.m_scoreUser = 0
    if nil ~= useritem then
        self.m_scoreUser = useritem.lScore;
    end	

--    local str = ExternalFun.numberThousands(0)
--    if string.len(str) > 11 then
--        str = string.sub(str,1,11) .. "...";
--    end

    local coin =  cc.Label:createWithTTF(ExternalFun.formatScoreText(self.m_scoreUser), appdf.FONT_FILE, 20)
    coin:setTextColor(cc.c3b(71,255,255))
    coin:setTag(TAG_ENUM.TAG_USERSCORE)
    coin:setAnchorPoint(cc.p(0.0,0.5))
    coin:setPosition(180, 28)
    self:addChild(coin)
end

function GameViewLayer:updateScore(score)   --更新分数
    self.m_scoreUser = score
--    local str = ExternalFun.numberThousands(score);
--    if string.len(str) > 11 then
--        str = string.sub(str,1,11) .. "...";
--    end

    local userScore = self:getChildByTag(TAG_ENUM.TAG_USERSCORE)
    userScore:setString(ExternalFun.formatScoreText(self.m_scoreUser))
end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes()
    local rootLayer, csbNode = ExternalFun.loadRootCSB("game_res/Game.csb",self)
    self._rootNode = csbNode
    self:resetRollCarPos()

    self:setClockTypeIsVisible(false)
    self:initButtons()
end

function GameViewLayer:initButtons()  --初始化按钮
    local function callfunc(ref,eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect("luxurycar_click.mp3")
       	    self:btnBankEvent(ref, eventType)
        end
    end

    --银行
    local btn =  self._rootNode:getChildByName("btn_bank")
    btn:addTouchEventListener(callfunc)
    --btn:setEnabled(self._scene._gameFrame:GetServerType()==yl.GAME_GENRE_GOLD)

    --上庄列表
    local banker = self._rootNode:getChildByName("btn_zhuang")
    banker:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
           	    self:BankerEvent(ref, eventType)
            end
        end)

    self:InitBankerInfo()
    --玩家列表
    local userlist = self._rootNode:getChildByName("btn_userlist")
    userlist:setVisible(false)
    userlist:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
           	    self:UserListEvent(ref, eventType)
            end
        end)

    --聊天
    local chat = self._rootNode:getChildByName("btn_chat")
    chat:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
           	    self:ChatEvent(ref, eventType)
            end
        end)

    --下注筹码
    local addview = self._rootNode:getChildByName("add_rect")
    for i=1,g_var(cmd).JETTON_COUNT do
        local btn = addview:getChildByName(string.format("bet_%d", i))
        btn:setTag(100+i)
        btn:setEnabled(false)
        btn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
                self:JettonEvent(ref, eventType)
            end
        end)
    end

    --游戏记录
    local record = self._rootNode:getChildByName("btn_record")
    record:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
           	    self:ShowRecord()
            end
        end)

    --续压按钮
    local continueBtn =  addview:getChildByName("btn_continue")
    continueBtn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
           	    self:ContinueEvent(ref, eventType)
            end
        end)

    --申请庄家
    local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
    local applyBtn = bankerBG:getChildByName("btn_apply")
    applyBtn:addTouchEventListener(function (ref,eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playSoundEffect("luxurycar_click.mp3")
            self:ApplyEvent(ref, eventType)
        end
    end)

    --下注区域
    for i=1,g_var(cmd).AREA_COUNT do
        local btn = addview:getChildByName(string.format("bet_area_%d", i))
        btn:setTag(200+i)
        btn:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.bCanBet == false then return end        --是否可下注判断
                if self:GetJettonIndexInvalid() then
                    local circle = addview:getChildByName(string.format("circle_%d",i))
           	        circle:runAction(cc.Sequence:create(cc.CallFunc:create(function()
           		        circle:setVisible(true)
           	        end),cc.DelayTime:create(0.2),cc.CallFunc:create(function()
           			        circle:setVisible(false)
           	        end)))

           	        self:PlaceJettonEvent(ref,eventType)
                else
       		        if self.m_cbGameStatus == g_var(cmd).GS_PLACE_JETTON then
				        showToast(cc.Director:getInstance():getRunningScene(), "请选择目标筹码", 1)	
       		        end
                end
            end
        end)
    end

    --返回按钮
    local back = self._rootNode:getChildByName("btn_back")
    back:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
           	    self._scene:onKeyBack()--onExitTable()
            end
        end)

    --设置按钮
    local help = self._rootNode:getChildByName("btn_set")
    help:addTouchEventListener(function (ref,eventType)
            if eventType == ccui.TouchEventType.ended then
                
                ExternalFun.playSoundEffect("luxurycar_click.mp3")
  			    local mgr = self._scene._scene:getApp():getVersionMgr()
    		    local verstr = mgr:getResVersion(g_var(cmd).KIND_ID) or "0"
    		    verstr = "游戏版本:" .. appdf.BASE_C_VERSION .. "." .. verstr
		        local set = g_var(SettingLayer):create(verstr)
		        self:addChild(set, TAG_ZORDER.SET_ZORDER)
		        --self:addToRootLayer(set, TAG_ZORDER.SET_ZORDER)
            end
        end)
end

function GameViewLayer:initTableJettons(table0,table1) --初始化下注区域筹码数目
    local addview = self._rootNode:getChildByName("add_rect")
    for i=1,g_var(cmd).AREA_COUNT do
        local jettonNode0 = addview:getChildByName(string.format("Node_%d_1", i))
        local jettonNode1 = addview:getChildByName(string.format("Node_%d_2", i))

        if nil == jettonNode0:getChildByTag(1) then
            local num = cc.Label:createWithTTF(string.format("%d",table0[i]), appdf.FONT_FILE, 20)
            num:setAnchorPoint(cc.p(0.5,0.5))
            num:setTag(1)
            num:setPosition(cc.p(jettonNode0:getContentSize().width/2,jettonNode0:getContentSize().height/2))
            jettonNode0:addChild(num)
        else
            local num = jettonNode0:getChildByTag(1)
            num:setString(string.format("%d",table0[i]))
        end

        if nil == jettonNode1:getChildByTag(1) then
            local num = cc.Label:createWithTTF(string.format("%d",table1[i]), appdf.FONT_FILE, 20)
            num:setAnchorPoint(cc.p(0.5,0.5))
            num:setTextColor(cc.c3b(255,254,143))
            num:setTag(1)
            num:setPosition(cc.p(jettonNode1:getContentSize().width/2,jettonNode1:getContentSize().height/2))
            jettonNode1:addChild(num)
        else
            local num = jettonNode1:getChildByTag(1)
            num:setString(string.format("%d",table1[i]))
        end
    end
end

--校准位置
function GameViewLayer:resetRollCarPos()
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    --转盘半径
    local radius = 295
    local center = cc.p(RollPanel:getContentSize().width/2,RollPanel:getContentSize().height/2)

    --获取转盘上的车
    for i=1,self.oneCircle do
        local radian = math.rad(22.5*(i-1))
        local x = radius * math.sin(radian);
        local y = radius * math.cos(radian);
        local car = RollPanel:getChildByName(string.format("car_index_%d",i))
        car:setPosition(center.x + x, center.y + y)
    end
end

--启动转动动画
function GameViewLayer:rollAction(bSceneMessage)
    print("self.m_cbGameStatus is ================================ >"..self.m_cbGameStatus)
    if self.m_cbGameStatus == g_var(cmd).GS_GAME_END then
        if bSceneMessage then
             self:onGameSceneResult()
             return
        end
        local RollPanel = self._rootNode:getChildByName("Panel_roll")
        if nil == RollPanel then
            print("RollPanel is nil .....")
        end

        local function runCircle()
            self.points = {}
            for i=1,self.oneCircle do
                local car = RollPanel:getChildByName(string.format("car_index_%d",i))
                local pos = cc.p(car:getPositionX(),car:getPositionY())
                table.insert(self.points, pos)
            end
		 	
            self.count = 0
            self:setTimePer()
            self.index = self.oneCircle-math.mod(self.oneCircle-self.endindex+1,self.oneCircle)
            self:RunCircleAction()
        end
        
        runCircle()	
        --20倍开奖 
--        if self:GetViewIndexByEndIndex(self.endindex) < 4 then 
--            local function breathAllCar()
--                for i=1,16 do
--                    local car = RollPanel:getChildByName(string.format("car_index_%d",i))
--                    local circle = cc.Sprite:create("game_res/tubiao39.png")
--                    circle:setTag(1)
--                    if i == 1 or i == 5 or i == 9 or i == 13 then
--                        circle:setOpacity(90)
--                    else
--                        circle:setOpacity(60)
--                    end
--                    circle:setPosition(cc.p(car:getContentSize().width/2,car:getContentSize().height/2))
--                    car:addChild(circle)

--                    local callfunc = cc.CallFunc:create(function()
--                        car:removeChildByTag(1)
--                        car:stopAllActions()
--                    end)

--                    local seq = cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,1.0))
--                    car:runAction(cc.Repeat:create(seq, 100))

--                    local delay = cc.Sequence:create(cc.DelayTime:create(3),callfunc)
--                    car:runAction(delay)		 	
--                end
--            end

--            breathAllCar()
--            self._scene.m_cbLeftTime = self._scene.m_cbLeftTime -3
--            local callfunc = cc.CallFunc:create(function (  )
--		            runCircle()
--            end)

--            self:runAction(cc.Sequence:create(cc.DelayTime:create(3),callfunc))
--        else
--            runCircle()	
--        end
    end
end

--初始化菜单按钮
function GameViewLayer:InitMenu()
	
end

function GameViewLayer:onResetView()
	self:gameDataReset()
end

function GameViewLayer:onExit()
    self:onResetView()
end

function GameViewLayer:gameDataReset(  )
    --资源释放
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("bank_res.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("bank_res.png")
    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()
end

----------------------------------------------------------------------------------------
--庄家信息
function GameViewLayer:InitBankerInfo()
    --昵称
    local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
    local info = {"昵称:","成绩:","筹码:","当前庄数:"}
    for i=1,4 do
        local node = bankerBG:getChildByName(string.format("Node_%d", i))
        local lb =  cc.Label:createWithTTF(info[i], appdf.FONT_FILE, 20)
        lb:setAnchorPoint(cc.p(1.0,0.5))
        lb:setTextColor(cc.c3b(36,236,255))
        lb:setPosition(node:getContentSize().width + 80, node:getContentSize().height/2)
        node:addChild(lb)
    end
end

--更新庄家信息
function GameViewLayer:ShowBankerInfo(info)
    if (type(info) ~= "table") or (#info==0) then
        return
    end
    local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
    bankerBG:removeChildByTag(2)
    local colors = {cc.c3b(255,255,255),cc.c3b(0,255,42),cc.c3b(255,204,0),cc.c3b(0,255,210)}
    dump(info)

    if info[1] == "系统坐庄" then
        info[2] = ""
        info[3] = ""
    end
    --昵称、成绩、筹码、当前庄数
    for i=1,4 do
        local node = bankerBG:getChildByName(string.format("Node_%d_1", i))
        local label = node:getChildByTag(2)
        if nil == label then
            if 1 == i or 3 == i then
                label =  g_var(ClipText):createClipText(cc.size(140, 20),info[i])
            else
                label =  cc.Label:createWithTTF(info[i], appdf.FONT_FILE, 20)
            end
			
            label:setAnchorPoint(cc.p(0.0,0.5))
            label:setTag(2)
            label:setTextColor(colors[i])
            label:setPosition(20, node:getContentSize().height/2)
            node:addChild(label)
        else
            label:setString(info[i])
        end
    end

    --玩家头像
    local headBG = ccui.ImageView:create("game_res/dikuang6.png")
    bankerBG:removeChildByTag(5)
    headBG:setAnchorPoint(cc.p(0.0,1.0))
    headBG:setTag(5)
    headBG:setPosition(cc.p(30,bankerBG:getContentSize().height - 100))
    bankerBG:addChild(headBG)

    local useritem = info[5]
    if useritem then
        local head = g_var(PopupInfoHead):createNormal(useritem, 46)
        head:setPosition(cc.p(headBG:getContentSize().width/2,headBG:getContentSize().height/2))
        head:setTag(1)
        headBG:addChild(head)
    else
        local head = display.newSprite("#userinfo_head_0.png")
        head:setPosition(cc.p(headBG:getContentSize().width/2,headBG:getContentSize().height/2))
        head:setScale(0.29)
		head:setTag(1)
        headBG:addChild(head)
    end		
end
----------------------------------------------------------------------------------------
function GameViewLayer:popHelpLayer()
    if nil == self.layerHelp then
        self.layerHelp = HelpLayer:create(self, g_var(cmd).KIND_ID, 0)
        self:addChild(self.layerHelp)
        self.layerHelp:setLocalZOrder(TAG_ZORDER.HELP_ZORDER)
    else
        self.layerHelp:onShow()
    end
end

function GameViewLayer:addRecordAssert(cbCarIndex)
    if cbCarIndex <=0 or cbCarIndex > 16 then
        error("24",0)
    end

    if #self._scene.m_RecordAssert < g_var(cmd).RECORD_MAX then --少于8条记录	
        table.insert(self._scene.m_RecordAssert, cbCarIndex)
    else
        --删除第一条记录
        table.remove(self._scene.m_RecordAssert,1)
        table.insert(self._scene.m_RecordAssert, cbCarIndex)
    end
end

function GameViewLayer:freshRecord()
    local info  = self._scene._info
    self:ShowBankerInfo(info)
    self:SetEndView(true)

    self._scene.m_RecordList = {}
    for i=1,#self._scene.m_RecordAssert do
        local cardIndex = self._scene.m_RecordAssert[i]
        table.insert(self._scene.m_RecordList,cardIndex)
    end

    local record = self._rootNode:getChildByName("record_cell")
    if not self.bPoints then
        self.bPoints = true
        self._points = {}
        for i=1,8 do
            local pos = cc.p(50 + (i-1)*60,38)
            table.insert(self._points,pos)
        end
    end

    if record:isVisible() then
        record:removeAllChildren()
        --刷新记录
        for i=1,#self._scene.m_RecordList do
            local viewIndex = 0
            local list = self._scene.m_RecordList[i]

            viewIndex = self:GetViewIndexByEndIndex(list)
            local cell = ccui.ImageView:create("game_res/"..string.format("record_%d.png",viewIndex))
            cell:setPosition(self._points[i])
            record:addChild(cell)
        end
    end
end

--游戏记录
function GameViewLayer:addRcord( cbCarIndex )
    if cbCarIndex <=0 or cbCarIndex > 16 then
        error("24",0)
    end

    if #self._scene.m_RecordList < g_var(cmd).RECORD_MAX then --少于8条记录
        table.insert(self._scene.m_RecordList, cbCarIndex)
    else
        --删除第一条记录
        table.remove(self._scene.m_RecordList,1)
        table.insert(self._scene.m_RecordList, cbCarIndex)
    end

    local record = self._rootNode:getChildByName("record_cell")
    if not self.bPoints then
        self.bPoints = true
        self._points = {}
        for i=1,8 do
            local pos = cc.p(50 + (i-1)*60,38)
            table.insert(self._points,pos)
        end
    end

    if record:isVisible() then
        record:removeAllChildren()
        --刷新记录
        for i=1,#self._scene.m_RecordList do
            local viewIndex = 0
            local list = self._scene.m_RecordList[i]

            viewIndex = self:GetViewIndexByEndIndex(list)
            local cell = ccui.ImageView:create("game_res/"..string.format("record_%d.png",viewIndex))
            cell:setPosition(self._points[i])
            record:addChild(cell)
        end
    end
end

function GameViewLayer:GetViewIndexByEndIndex( list )
    local viewIndex = 0
    if list == 1 then 
        --玛莎拉蒂
        viewIndex = 0 
    elseif list == 2 or list == 12 or list == 16 then
        --宝马
        viewIndex = 5
    elseif list == 3 or list == 6 or list == 15 then
        --奔驰
        viewIndex = 7
    elseif list == 4 or list == 7 or list == 10 then
        --捷豹
        viewIndex = 6	
    elseif list == 5 then
        --法拉利
        viewIndex = 1	
    elseif list == 9 then
        --保时捷
        viewIndex = 3		
    elseif list == 8 or list == 11 or list == 14 then
        --路虎
        viewIndex = 4	
    elseif list == 13 then
        --兰博基尼
        viewIndex = 2				
    end

    return viewIndex
end

function GameViewLayer:HiddenRecord()
    local record = self._rootNode:getChildByName("record_cell")
    record:setVisible(false)
end

function GameViewLayer:ShowRecord()
    local record = self._rootNode:getChildByName("record_cell")
    if record:isVisible() then
        record:setVisible(false)
        return
    end

    record:setVisible(true)
    record:removeAllChildren()

    --刷新记录
    for i=1,#self._scene.m_RecordList do
        local viewIndex = 0
        local list = self._scene.m_RecordList[i]

        viewIndex = self:GetViewIndexByEndIndex(list)

        local cell = ccui.ImageView:create("game_res/"..string.format("record_%d.png",viewIndex))
        cell:setPosition(self._points[i])
        record:addChild(cell)
    end
end

--更新区域筹码
function GameViewLayer:UpdateAreaJetton()
    local table = self:ConvertToViewAreaIndex(self._scene.m_lAllJettonScore)
    self:initTableJettons(table,self._scene.m_lCurrentAddscore)
end

--转换成视图索引
function GameViewLayer:ConvertToViewAreaIndex(param)
    if type(param) ~= "table"  or #param ~= g_var(cmd).AREA_COUNT then
        return
    end

    local table = {0,0,0,0,0,0,0,0}
    table[1] = param[g_var(cmd).ID_BMW]
    table[2] = param[g_var(cmd).ID_BENZ]
    table[3] = param[g_var(cmd).ID_JAGUAR]
    table[4] = param[g_var(cmd).ID_LANDROVER]
    table[5] = param[g_var(cmd).ID_MASERATI]
    table[6] = param[g_var(cmd).ID_FERRARI]
    table[7] = param[g_var(cmd).ID_LAMBORGHINI]
    table[8] = param[g_var(cmd).ID_PORSCHE]

    return table
end

--重置下注
function GameViewLayer:CleanAllBet()
    local addview = self._rootNode:getChildByName("add_rect")
    for i=1,g_var(cmd).AREA_COUNT do
        local jettonNode0 = addview:getChildByName(string.format("Node_%d_1", i))
        local jettonNode1 = addview:getChildByName(string.format("Node_%d_2", i))

        if nil ~= jettonNode0:getChildByTag(1) then
            local num = jettonNode0:getChildByTag(1)
            num:setString("0")
        end

        if nil ~= jettonNode1:getChildByTag(1) then
            local num = jettonNode1:getChildByTag(1)
            num:setString("0")
        end
    end
end

-------------------------------------------------------------------------------------------
--玩家列表
function GameViewLayer:UserListEvent( ref,eventType )
    if self._UserView == nil then
        self._UserView = g_var(UserList):create(self._scene._dataModle)
        self:addChild(self._UserView,30)
        self._UserView:reloadData()
    else
        self._UserView:setVisible(true)
        self._UserView:reloadData()
    end
end

--按钮事件
function GameViewLayer:BankerEvent(ref,eventType)
    --打开上庄列表界面
    local bankerView = self._rootNode:getChildByName("zhuang_listBG")
    bankerView:setVisible(true)

    --隐藏聊天
    local chatView = self._rootNode:getChildByName("chat_BG")
    chatView:setVisible(false)
end

function GameViewLayer:ChatEvent(ref,eventType)
    --隐藏上庄列表界面
    local bankerView = self._rootNode:getChildByName("zhuang_listBG")
    bankerView:setVisible(false)

    print("聊天按钮被点击")
    local item = self:getChildByTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
    if item ~= nil then
        print("item ~= nil")
        item:resetData()
    else
        print("item new")
        local gameSystemMessage = GameSystemMessage:create()
        gameSystemMessage:setOnCloseCallBack(function () self:BankerEvent() end)
        gameSystemMessage:setLocalZOrder(100)
        gameSystemMessage:setTag(GameViewLayer.TAG_GAMESYSTEMMESSAGE)
        self:addChild(gameSystemMessage)
    end
end
--------------------------------------------------------------------------------------------

--银行操作成功
function GameViewLayer:onBankSuccess( )
    if self._bankLayer and not tolua.isnull(self._bankLayer) then
        self._bankLayer:onBankSuccess()
    end
end

--银行操作失败
function GameViewLayer:onBankFailure( )
    if self._bankLayer and not tolua.isnull(self._bankLayer) then
        self._bankLayer:onBankFailure()
    end
end

function GameViewLayer:onGetBankInfo(bankinfo)
    if self._bankLayer and not tolua.isnull(self._bankLayer) then
        self._bankLayer:onGetBankInfo(bankinfo)
    end
end

--银行
function GameViewLayer:btnBankEvent(ref,eventType)
    if eventType == ccui.TouchEventType.ended then
        local rom = GlobalUserItem.GetRoomInfo()
		if nil ~= rom then
			if rom.wServerType ~= yl.GAME_GENRE_GOLD then
				showToast(cc.Director:getInstance():getRunningScene(), "当前房间禁止操作银行!", 1)
				return
			end
		end	
        if 0 == GlobalUserItem.tabAccountInfo.cbInsureEnabled then
            showToast(cc.Director:getInstance():getRunningScene(), "初次使用，请先开通银行！", 1)
            return 
        end
        if self._bankLayer == nil then
            self._bankLayer=BankLayer:create(self) 
            self:addChild(self._bankLayer,10)
        else
            self._bankLayer:onShow()
        end
    end
end
---------------------------------------------------------------------------------------------
--加注
function GameViewLayer:JettonEvent( ref ,eventType )
    if eventType == ccui.TouchEventType.ended then
        local btn = ref
        local index = btn:getTag() - 100 
        self:SetJettonIndex(index)
    end
end

--续压
function GameViewLayer:ContinueEvent( ref,eventType )
    --当前庄家是自己
    if self._scene:GetMeUserItem().wChairID == self._scene.m_wBankerUser then
        return
    end

    if self:GetJettonRecord() > self.m_scoreUser then
        local runScene = cc.Director:getInstance():getRunningScene()
        showToast(runScene, "下注筹码不足", 1)
        self.bContinueRecord = true
        self:updateControl(g_var(cmd).Continue)
        return
    end

    self.bContinueRecord = true
    for i=1,#self._scene.m_lContinueRecord do  
        if self._scene.m_lContinueRecord[i] > 0 then
            --发送加注 i是逻辑索引
            self._scene:sendUserBet(i,self._scene.m_lContinueRecord[i])

            --视图索引
            local areaIndex = self:GetViewAreaIndex(i)
            self._scene.m_lCurrentAddscore[areaIndex] = self._scene.m_lCurrentAddscore[areaIndex] + self._scene.m_lContinueRecord[i]
            self._scene.m_lAllJettonScore[i] = self._scene.m_lAllJettonScore[i] + self._scene.m_lContinueRecord[i]
        end
    end

    --刷新桌面坐标
    self:UpdateAreaJetton()
    --刷新操作按钮
    self:updateControl(g_var(cmd).Jettons)
    self:updateControl(g_var(cmd).Continue)
end

--申请庄家
function GameViewLayer:ApplyEvent( ref,eventType )
    --if self.m_eApplyStatus == GameViewLayer.unKnown then
    --	return
    --end

    local userItem = self._scene:GetMeUserItem()
    if self.m_eApplyStatus == GameViewLayer.unApply then 
        --发送申请
        local cmddata = ExternalFun.create_netdata(g_var(cmd).CMD_S_ApplyBanker)
        cmddata:pushword(userItem.wChairID)
        self._scene:SendData(g_var(cmd).SUB_C_APPLY_BANKER, cmddata)
    elseif self.m_eApplyStatus == GameViewLayer.applyed then	
        --发送取消
        local cmddata = ExternalFun.create_netdata(g_var(cmd).CMD_S_ApplyBanker)
        cmddata:pushword(userItem.wChairID)
        self._scene:SendData(g_var(cmd).SUB_C_CANCEL_BANKER, cmddata)
    end
    --self.m_eApplyStatus = GameViewLayer.unKnown
end

function GameViewLayer:PlaceJettonEvent( ref,eventType )
    local btn = ref
    local areaIndex = btn:getTag() - 200	--转换成视图索引
    local userItem = self._scene:GetMeUserItem()

    --当前庄家是自己
    if userItem.wChairID == self._scene.m_wBankerUser then
        return
    end

    local logicAreaIndex = self:GetLogicAreaIndex(areaIndex)	--逻辑索引
    if self:GetTotalCurrentPlaceJetton() + self._scene.BetArray[self.JettonIndex] > self._scene.m_lUserMaxScore  then
        return
    end

    if self._scene.BetArray[self.JettonIndex] > userItem.lScore*self._scene.m_nMultiple  then
        return
    end

    self._scene.m_lCurrentAddscore[areaIndex] = self._scene.m_lCurrentAddscore[areaIndex] + self._scene.BetArray[self.JettonIndex]
    self._scene.m_lAllJettonScore[logicAreaIndex] = self._scene.m_lAllJettonScore[logicAreaIndex] + self._scene.BetArray[self.JettonIndex]

    --发送加注
    self._scene:sendUserBet(logicAreaIndex,self._scene.BetArray[self.JettonIndex])
    --刷新桌面坐标
    self:UpdateAreaJetton()
    --刷新操作按钮
    self:updateControl(g_var(cmd).Jettons)
    self:updateControl(g_var(cmd).Continue)
    ExternalFun.playSoundEffect("luxurycar_add_score.mp3")
end
-------------------------------------------------------------------------------------------------------------------------------------

function GameViewLayer:SetJettonIndex( index )	--筹码索引
    local addview = self._rootNode:getChildByName("add_rect")
    self.JettonIndex = index

    if index <= 0 or index > g_var(cmd).JETTON_COUNT then
        local lightCircle = addview:getChildByTag(200)
        if nil ~= lightCircle then
            lightCircle:setVisible(false)
        end
        return
    end

    --选择的目标筹码
    local jetton = addview:getChildByName(string.format("bet_%d", index))
    if not addview:getChildByTag(200) then  --光圈
        local lightCircle = ccui.ImageView:create("game_res/tubiao35.png")
        lightCircle:setAnchorPoint(cc.p(0.5,0.5))
        lightCircle:setPosition(cc.p(jetton:getPositionX(),jetton:getPositionY()))
        lightCircle:setTag(200)
        addview:addChild(lightCircle)
    else
        local lightCircle = addview:getChildByTag(200)
        lightCircle:setVisible(true)
        lightCircle:setPosition(cc.p(jetton:getPositionX(),jetton:getPositionY()))
    end
end

function GameViewLayer:GetJettonIndexInvalid() --获取索引
    if self.JettonIndex <= 0 or self.JettonIndex > g_var(cmd).JETTON_COUNT then
        return false
    end

    return true
end

function GameViewLayer:SetClockType(timetype) --设置倒计时
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    local typeImage = RollPanel:getChildByName("time_type")
    typeImage:setVisible(true)
    if timetype == g_var(cmd).CLOCK_FREE then
        self:updateScore(self.m_scoreUser)
        typeImage:loadTexture("game_res/tubiao42.png")
    elseif timetype == g_var(cmd).CLOCK_ADDGOLD then
        typeImage:loadTexture("game_res/tubiao41.png")
    else
        typeImage:loadTexture("game_res/tubiao40.png")
    end
end

function GameViewLayer:SetApplyStatus( status )
    if self.m_eApplyStatus == status then
        return
    end

    self.m_eApplyStatus = status
    self:SetApplyTexture()
end

function GameViewLayer:SetApplyTexture()
    local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
    local applyBtn = bankerBG:getChildByName("btn_apply")

    if self.m_eApplyStatus == GameViewLayer.unApply then 
        applyBtn:loadTextureNormal("game_res/anniu9.png")
    elseif self.m_eApplyStatus == GameViewLayer.applyed then
        applyBtn:loadTextureNormal("game_res/anniu11.png")	
    end
end

function GameViewLayer:setClockTypeIsVisible(visible) --倒计时类型
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    local typeImage = RollPanel:getChildByName("time_type")
    typeImage:setVisible(visible)
end

function GameViewLayer:setClockGameEnd() --倒计时类型
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    if self.m_pClock ~= nil and self.m_pClock:getParent() ~= nil then
        if self.m_pClock:getPositionY() ~= yl.DESIGN_HEIGHT/2-130 then 
            local clockStr = self.m_pClock:getString()
            self.m_pClock:removeFromParent()
            self.m_pClock = nil
        
            self.m_pClock = cc.LabelAtlas:create(clockStr,"game_res/shuzi3.png",130,108,string.byte("0"))
            self.m_pClock:setAnchorPoint(0.5,0.5)
            self.m_pClock:setScale(0.4)
            self.m_pClock:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2-130)
            RollPanel:addChild(self.m_pClock, TAG_ZORDER.CLOCK_ZORDER)
        end
    end
end

function GameViewLayer:SetEndView(visible)
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    local endview = RollPanel:getChildByName("endView")
    endview:setVisible(visible)
    
--    if visible then
--        if self.lUserScore > 0 then
--            ExternalFun.playSoundEffect("luxurycar_game_win.mp3")
--            ExternalFun.playSoundEffect("luxurycar_game_win1.mp3")
--        elseif self.lUserScore < 0 then
--            ExternalFun.playSoundEffect("luxurycar_game_lose.mp3")
--        end
--    end
    --获取车名
    local cartype = endview:getChildByName("Car_Type")
    if self.endindex == 1 then 
        --玛莎拉蒂
        endview:loadTexture("game_res/tubiao47.png")
        cartype:loadTexture("game_res/biaoti23.png")
    elseif self.endindex == 2 or self.endindex == 12 or self.endindex == 16 then
        --宝马
        endview:loadTexture("game_res/tubiao44.png")
        cartype:loadTexture("game_res/biaoti24.png")
    elseif self.endindex == 3 or self.endindex == 6 or self.endindex == 15 then
        --奔驰
        endview:loadTexture("game_res/tubiao45.png")
        cartype:loadTexture("game_res/biaoti25.png")
    elseif self.endindex == 4 or self.endindex == 7 or self.endindex == 10 then
        --捷豹
        endview:loadTexture("game_res/tubiao46.png")
        cartype:loadTexture("game_res/biaoti27.png")
    elseif self.endindex == 5 then
        --法拉利
        endview:loadTexture("game_res/tubiao48.png")
        cartype:loadTexture("game_res/biaoti22.png")
    elseif self.endindex == 9 then
        --保时捷
        endview:loadTexture("game_res/tubiao43.png")
        cartype:loadTexture("game_res/biaoti20.png")
    elseif self.endindex == 8 or self.endindex == 11 or self.endindex == 14 then
        --路虎
        endview:loadTexture("game_res/tubiao49.png")
        cartype:loadTexture("game_res/biaoti26.png")
    elseif self.endindex == 13 then
        --兰博基尼
        endview:loadTexture("game_res/tubiao50.png")
        cartype:loadTexture("game_res/biaoti21.png")		
    end
end

function GameViewLayer:SetEndInfo(lBankerScore,lUserScore)
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    local endview = RollPanel:getChildByName("endView")
    local infoBG = endview:getChildByName("end_detail")
    if nil ~= infoBG then
        infoBG:removeChildByTag(1)
        infoBG:removeChildByTag(2)

        lBankerScore = lBankerScore * self._scene.m_nMultiple
        lUserScore = lUserScore * self._scene.m_nMultiple

        self.lUserScore = lUserScore
        local str 
        if lBankerScore >= 0 then
            str = "+"..ExternalFun.numberThousands(lBankerScore)
        else
            str = ExternalFun.numberThousands(lBankerScore)
        end

        local str1 
        if lUserScore >= 0 then
            str1 = "+"..ExternalFun.numberThousands(lUserScore)
        else
            str1 = ExternalFun.numberThousands(lUserScore)
        end

        --庄家输赢
        local BankerWinScore = cc.Label:createWithTTF(str, appdf.FONT_FILE, 20)
        BankerWinScore:setTag(1)
        BankerWinScore:setTextColor(cc.c3b(36,236,255))
        BankerWinScore:setAnchorPoint(cc.p(0.0,0.0))
        BankerWinScore:setPosition(125,42)
        infoBG:addChild(BankerWinScore)

        --玩家输赢
        local UserWinScore = cc.Label:createWithTTF(str1, appdf.FONT_FILE, 20)
        UserWinScore:setTag(2)
        UserWinScore:setTextColor(cc.c3b(255,204,0))
        UserWinScore:setAnchorPoint(cc.p(0.0,1.0))
        UserWinScore:setPosition(125,38)
        infoBG:addChild(UserWinScore)
    end
end


function GameViewLayer:GetLogicAreaIndex( cbArea )
    local logicIndex = -1
    if cbArea == 1 then
        --宝马
        logicIndex = g_var(cmd).AREA_BMW
    elseif cbArea == 2 then
        --奔驰
        logicIndex = g_var(cmd).AREA_BENZ
    elseif cbArea == 3 then
        --捷豹
        logicIndex = g_var(cmd).AREA_JAGUAR
    elseif cbArea == 4 then
        --路虎
        logicIndex = g_var(cmd).AREA_LANDROVER
    elseif cbArea == 5 then
        --玛莎拉蒂
        logicIndex = g_var(cmd).AREA_MASERATI	
    elseif cbArea == 6 then
        --法拉利
        logicIndex = g_var(cmd).AREA_FERRARI
    elseif cbArea == 7 then
        --兰博基尼
        logicIndex = g_var(cmd).AREA_LAMBORGHINI
    elseif cbArea == 8 then
        --保时捷
        logicIndex = g_var(cmd).AREA_PORSCHE
    end

    return logicIndex + 1
end

function GameViewLayer:GetViewAreaIndex( logicIndex )
    logicIndex = logicIndex - 1
    local viewIndex = -1
    if logicIndex == g_var(cmd).AREA_BMW then
        --宝马
        viewIndex = 1
    elseif logicIndex == g_var(cmd).AREA_BENZ then
        --奔驰
        viewIndex = 2
    elseif logicIndex == g_var(cmd).AREA_JAGUAR then
        --捷豹
        viewIndex = 3
    elseif logicIndex == g_var(cmd).AREA_LANDROVER then
        --路虎
        viewIndex = 4
    elseif logicIndex == g_var(cmd).AREA_MASERATI then
        --玛莎拉蒂
        viewIndex = 5
    elseif logicIndex == g_var(cmd).AREA_FERRARI then
        --法拉利
        viewIndex = 6
    elseif logicIndex == g_var(cmd).AREA_LAMBORGHINI then
        --兰博基尼
        viewIndex = 7
    elseif logicIndex == g_var(cmd).AREA_PORSCHE then
        --保时捷
        viewIndex = 8
    end

    return viewIndex
end

function GameViewLayer:GetTotalCurrentPlaceJetton()
    local cur = 0
    for i=1,#self._scene.m_lCurrentAddscore do
        cur = cur + self._scene.m_lCurrentAddscore[i]
    end
    return cur
end

function GameViewLayer:GetAllPlaceJetton()
    local total = 0
    for i=1,#self._scene.m_lAllJettonScore do
        total = total + self._scene.m_lAllJettonScore[i]
    end
    return total
end

function GameViewLayer:GetJettonRecord()
    local record = 0
    for i=1,#self._scene.m_lContinueRecord do
        record = record + self._scene.m_lContinueRecord[i]
    end
    return record
end
----------------------------------------------------------------------------------------------------------------------------------------
function GameViewLayer:TouchUserInfo()  --点击用户头像显示信息
	
end

--------------------------------------------------------------

--------------------------------------------------------------
--倒计时
function GameViewLayer:createClockView(time,viewtype)
    if nil ~= self.m_pClock then
        self.m_pClock:removeFromParent()
        self.m_pClock = nil
    end

    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    if viewtype == 0 then --转盘界面
        self.m_pClock = cc.LabelAtlas:create(string.format("%d",time),"game_res/shuzi3.png",130,108,string.byte("0"))
        self.m_pClock:setAnchorPoint(0.5,0.5)
        self.m_pClock:setPosition(yl.DESIGN_WIDTH/2,yl.DESIGN_HEIGHT/2)
        RollPanel:addChild(self.m_pClock, TAG_ZORDER.CLOCK_ZORDER)
    else  --下注界面
        local addview = self._rootNode:getChildByName("add_rect")
        self.m_pClock = cc.LabelAtlas:create(string.format("%d",time),"game_res/shuzi4.png",17,21,string.byte("0"))
        self.m_pClock:setAnchorPoint(0.5,0.5)
        self.m_pClock:setPosition(258,75)
        addview:addChild(self.m_pClock)
    end
end

function GameViewLayer:UpdataClockTime(clockTime)
    if nil ~= self.m_pClock then
        self.m_pClock:setString(string.format("%d",clockTime))
    end

    if clockTime <= 5 then
        ExternalFun.playSoundEffect("luxurycar_clock_time.mp3")
    end

    if clockTime == 0 then
        self:LogicTimeZero()
    end
end

function GameViewLayer:LogicTimeZero()  --倒计时0处理
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    local typeImage = RollPanel:getChildByName("time_type")
    typeImage:setVisible(false)

    if nil ~= self.m_pClock then
        self._scene:KillGameClock()
        self.m_pClock:removeFromParent()
        self.m_pClock = nil
    end

    if self.m_cbGameStatus == g_var(cmd).GAME_SCENE_FREE then
        self:removeAction()
        self:restData()
        self:RollDisAppear()
        self:AddViewSlipToShow()
    elseif self.m_cbGameStatus ==  g_var(cmd).GS_PLACE_JETTON then
        self:AddViewSlipToHidden()
        ExternalFun.playSoundEffect("luxurycar_stop_gold.mp3")
        ExternalFun.playSoundEffect("luxurycar_stop_gold1.mp3")
    elseif self.m_cbGameStatus == g_var(cmd).GS_GAME_END then
        local info  = self._scene._info
        self:ShowBankerInfo(info)
        self:SetEndView(true)		
        --隐藏时间类型
        self:setClockTypeIsVisible(false)
        if self._scene.m_bAllowJoin then
            --插入记录
            self:addRcord(self.endindex)
        end

        --移除倒计时
        if nil ~= self.m_pClock then
            self._scene:KillGameClock()
            self.m_pClock:removeFromParent()
            self.m_pClock = nil
        end
    end
end

--------------------------------------------------------------
function GameViewLayer:GetJettons()		--下注筹码
    local btns = {}
    local addview = self._rootNode:getChildByName("add_rect")
    for i=1,g_var(cmd).JETTON_COUNT do
        local btn = addview:getChildByName(string.format("bet_%d", i))
        table.insert(btns, btn)
    end

    return btns
end

function GameViewLayer:updateControl(ButtonType)  --更新按钮状态
    local userItem = self._scene:GetMeUserItem()
    if ButtonType == g_var(cmd).Apply then         --申请庄家按钮
        local bankerBG =  self._rootNode:getChildByName("zhuang_listBG")
        local applyBtn = bankerBG:getChildByName("btn_apply")

        if userItem.lScore * self._scene.m_nMultiple < self._scene.m_lApplyBankerCondition  then
            applyBtn:setEnabled(false)
        else
            if self.m_cbGameStatus ~= g_var(cmd).GAME_SCENE_FREE and userItem.wChairID == self._scene.m_wBankerUser or not self._scene.bEnableSysBanker then
                applyBtn:setEnabled(false)
                return
            end
            applyBtn:setEnabled(true)
        end
    elseif ButtonType == g_var(cmd).Jettons then   --加注按钮
        local totalCurrentAddScore = 0
        for i=1,#self._scene.m_lCurrentAddscore do
            totalCurrentAddScore = totalCurrentAddScore + self._scene.m_lCurrentAddscore[i]
        end

        local btns = self:GetJettons()
        if self.m_cbGameStatus == g_var(cmd).GS_PLACE_JETTON then
            local bOutScore = false
            for i=1,#btns do
                if self._scene.BetArray[i] > self._scene.m_lUserMaxScore-totalCurrentAddScore or self._scene.BetArray[i] > userItem.lScore*self._scene.m_nMultiple or not self._scene.bEnableSysBanker then
                    btns[i]:setEnabled(false)
                    if self.JettonIndex == i then
                        bOutScore = true
                    end
                else
                    btns[i]:setEnabled(true)
                end
            end
            --自动切换小一点的筹码
            if self.JettonIndex>0 and bOutScore then
                for i=self.JettonIndex-1, 1,-1 do
                    if btns[i]:isEnabled() then
                        self:SetJettonIndex(i)
                        bOutScore = false
                        break
                    end
                end
            end
            if bOutScore then
                self:SetJettonIndex(-1)
            end
        else
            for i=1,#btns do
                btns[i]:setEnabled(false)
                if self.JettonIndex == i then 
                    self:SetJettonIndex(-1)
                end
            end
        end
    elseif ButtonType == g_var(cmd).Continue then  --续压按钮
        --dump(self._scene.m_lContinueRecord, "self._scene.m_lContinueRecord is =========>	", 6)
        local addview = self._rootNode:getChildByName("add_rect")
        local ContinueBtn = addview:getChildByName("btn_continue")

        if self.bContinueRecord then --每局续压只能一次
            ContinueBtn:setEnabled(false)
            return
        end

        if self.m_cbGameStatus ~= g_var(cmd).GS_PLACE_JETTON  or self:GetJettonRecord() == 0 then 
            ContinueBtn:setEnabled(false)
        else
            ContinueBtn:setEnabled(true)
        end
    end	
end

------------------------------------------------------------------------------------------------------------
--动画
function GameViewLayer:RollApear(bSceneMessage) --转盘出现
    self:SetEndView(false)
    self:CleanAllBet()

    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    local callfunc = cc.CallFunc:create(function()
        self:rollAction(bSceneMessage)
    end)

    if not self.bAnimate  then 
        RollPanel:setPosition(cc.p(667,385))
        self:rollAction(bSceneMessage)
        return
    end

    RollPanel:stopAllActions()
    RollPanel:runAction(cc.Sequence:create(cc.MoveTo:create(0.4,cc.p(667,385)),callfunc))
end

function GameViewLayer:RollDisAppear() --转盘弹出
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    if not self.bAnimate then 
        RollPanel:setPosition(cc.p(667,980))
        return
    end
    RollPanel:stopAllActions()
    RollPanel:runAction(cc.MoveTo:create(0.4,cc.p(667,980)))
end

--加注界面弹出
function GameViewLayer:AddViewSlipToShow() --下注界面
    self.bCanBet = true
    local addview = self._rootNode:getChildByName("add_rect")
    if not self.bAnimate then 
        addview:setPosition(cc.p(840,365))
        return
    end
    addview:stopAllActions()
    addview:runAction(cc.MoveTo:create(0.4,cc.p(840,365)))
end

--加注界面隐藏
function GameViewLayer:AddViewSlipToHidden()
    self.bCanBet = false
    local addview = self._rootNode:getChildByName("add_rect")
    if not self.bAnimate then 
        addview:setPosition(cc.p(1600,365))
        return
    end
    addview:stopAllActions()
    addview:runAction(cc.MoveTo:create(0.4,cc.p(1600,365)))
end

function GameViewLayer:RunCircleAction()	--转动动画
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    ExternalFun.playSoundEffect("luxurycar_run_point.mp3")
    --光圈默认位置
    if nil == self.firstRoll then
        self.firstRoll = cc.Sprite:create("game_res/tubiao37.png")
        self.firstRoll:setPosition(self.points[1].x, self.points[1].y)
        self.firstRoll:setTag(1)
        RollPanel:addChild(self.firstRoll)

        self.secondRoll = cc.Sprite:create("game_res/tubiao38.png")
        self.secondRoll:setPosition(self.points[16].x, self.points[16].y)
        self.secondRoll:setTag(2)
        RollPanel:addChild(self.secondRoll)

        self.thirdRoll = cc.Sprite:create("game_res/tubiao39.png")
        self.thirdRoll:setPosition(self.points[15].x, self.points[15].y)
        self.thirdRoll:setTag(3)
        RollPanel:addChild(self.thirdRoll)
    end
 	
    local delay = cc.DelayTime:create(self.time)
    local call = cc.CallFunc:create(function()
        if self.firstRoll == nil then
            return
        end

        self.firstRoll:setPosition(cc.p(self.points[self.index].x,self.points[self.index].y))
        local index = self.oneCircle-math.mod(self.oneCircle-self.index + 1,self.oneCircle)

        if nil ~= self.secondRoll then
            self.secondRoll:setPosition(cc.p(self.points[index].x,self.points[index].y))
        end

        if nil ~= self.thirdRoll then
            index = self.oneCircle-math.mod(self.oneCircle-index+1,self.oneCircle)
            self.thirdRoll:setPosition(cc.p(self.points[index].x,self.points[index].y))
        end

        local car = RollPanel:getChildByName(string.format("car_index_%d",self.index))
        --car:removeChildByTag(1)
        car:stopAllActions()
        car:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.1,1.0)))
        self.index = math.mod(self.index,self.oneCircle) + 1
        self.count = self.count + 1

        local tempEndIndex = math.mod(self.endindex, self.oneCircle) + 1
	
        if self.count == self.oneCircle * 5 then 	
            self.secondRoll:removeFromParent()
            self.thirdRoll:removeFromParent()
            self.secondRoll = nil
            self.thirdRoll  = nil

        elseif self.count > self.oneCircle * 5 and self.count < self.oneCircle*6 then
            self.time = self:getTimeQueue(self.count-self.oneCircle * 2)
        elseif self.count >= self.oneCircle*6 then
            self.time = 0.8
            if self.index  == tempEndIndex then
                self:EndBreath(car)
                local info  = self._scene._info
                self:ShowBankerInfo(info)

                self:SetEndView(true)
                --隐藏时间类型
                self:setClockTypeIsVisible(false)

                if self._scene.m_bAllowJoin then
                    --插入记录
                    self:addRcord(self.endindex)
                    m_bAllowJoin = false
                end

                --移除倒计时
                if nil ~= self.m_pClock then
                    self._scene:KillGameClock()
                    self.m_pClock:removeFromParent()
                    self.m_pClock = nil
                end
                return
            end
        end

        self:RunCircleAction()
    end)

    self:runAction(cc.Sequence:create(delay,call))
end
function GameViewLayer:onGameSceneResult()
    local RollPanel = self._rootNode:getChildByName("Panel_roll")
    self.points = {}
    for i=1,self.oneCircle do
        local car = RollPanel:getChildByName(string.format("car_index_%d",i))
        local pos = cc.p(car:getPositionX(),car:getPositionY())
        table.insert(self.points, pos)
    end

    --光圈默认位置
    if nil == self.firstRoll then
        self.firstRoll = cc.Sprite:create("game_res/tubiao37.png")
        self.firstRoll:setPosition(self.points[1].x, self.points[1].y)
        self.firstRoll:setTag(1)
        RollPanel:addChild(self.firstRoll)

        self.secondRoll = cc.Sprite:create("game_res/tubiao38.png")
        self.secondRoll:setPosition(self.points[16].x, self.points[16].y)
        self.secondRoll:setTag(2)
        RollPanel:addChild(self.secondRoll)

        self.thirdRoll = cc.Sprite:create("game_res/tubiao39.png")
        self.thirdRoll:setPosition(self.points[15].x, self.points[15].y)
        self.thirdRoll:setTag(3)
        RollPanel:addChild(self.thirdRoll)
    end

    if nil ~= self.secondRoll then
        self.firstRoll:setPosition(cc.p(self.points[self.endindex].x,self.points[self.endindex].y))
    end

    if nil ~= self.secondRoll then
        self.secondRoll:setPosition(cc.p(self.points[self.endindex].x,self.points[self.endindex].y))
    end

    if nil ~= self.thirdRoll then
        self.thirdRoll:setPosition(cc.p(self.points[self.endindex].x,self.points[self.endindex].y))
    end

    local car = RollPanel:getChildByName(string.format("car_index_%d",self.endindex ))
    car:removeChildByTag(1)
    car:stopAllActions()
    car:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.1,1.0)))
    self:EndBreath(car)
    local info  = self._scene._info
    self:ShowBankerInfo(info)

   self:SetEndView(true)
   --隐藏时间类型
   --self:setClockTypeIsVisible(false)

   if self._scene.m_bAllowJoin then
   --插入记录
      self:addRcord(self.endindex)
      m_bAllowJoin = false
   end

   --移除倒计时
   if nil ~= self.m_pClock then
      --self._scene:KillGameClock()
      self:setClockGameEnd()
   end
end

--目标位置
function GameViewLayer:EndBreath(car)
    local callfunc = cc.CallFunc:create(function()
        self:EndBreath(car)
    end)

    car:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,1.2),cc.ScaleTo:create(0.4,1.0),callfunc))
end

--停止动作
function GameViewLayer:removeAction()
    local RollPanel = self._rootNode:getChildByName("Panel_roll")

    for i=1,16 do
        local car = RollPanel:getChildByName(string.format("car_index_%d",i))
        if nil ~= car then
            car:stopAllActions()
        end
    end

    self:stopAllActions()
    if nil ~= self.firstRoll then
        self.firstRoll:removeFromParent()
        self.firstRoll = nil
    end

    if nil ~= self.secondRoll then
        self.secondRoll:removeFromParent()
        self.secondRoll = nil
    end

    if nil ~= self.thirdRoll then
        self.thirdRoll:removeFromParent()
        self.thirdRoll = nil
    end
end

-----------------------------------------------------------------------------------------------------------------
--用户聊天
function GameViewLayer:userChat(nick, chatstr)
    if not self._ChatView or not  self._ChatView.onUserChat then
        return
    end
    self._ChatView:onUserChat(nick,chatstr)
end

--用户表情
function GameViewLayer:userExpression(nick, index)
    if not self._ChatView or not self._ChatView.onUserExpression  then
        return
    end

    self._ChatView:onUserExpression(nick,index)
end

----------------------------------------------------------------------------------------------------------------------
function GameViewLayer:onTouchBegan(touch, event)
    print("luxurycar onTouchBegan...")
    return true
end

function GameViewLayer:onTouchMoved(touch, event)
    print("luxurycar onTouchMoved...")
end

function GameViewLayer:onTouchEnded(touch, event )
    print("luxurycar onTouchEnded...")
end

-----------------------------------------------------------------------------------------------------------------------
function GameViewLayer:playEffect( file )
    ExternalFun.playSoundEffect(file)
end

function GameViewLayer:playBackGroundMusic(cbStatus)

end

return GameViewLayer