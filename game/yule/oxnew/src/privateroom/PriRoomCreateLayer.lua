--
-- Author: zhong
-- Date: 2016-12-17 14:07:02
--
-- 十三水私人房创建界面
local CreateLayerModel = appdf.req(PriRoom.MODULE.PLAZAMODULE .."models.CreateLayerModel")

local PriRoomCreateLayer = class("PriRoomCreateLayer", CreateLayerModel)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

-- 十三水AA制提示界面
local TransitionLayer = appdf.req(appdf.EXTERNAL_SRC .. "TransitionLayer")
local PriRoomAAPayLayer = class("PriRoomAAPayLayer", TransitionLayer)
PriRoomCreateLayer.PriRoomAAPayLayer = PriRoomAAPayLayer

local cmd = import('..models.CMD_Game')

local BTN_CLOSE = 1
local BTN_HELP = 2
local BTN_CREATE = 4
local BTN_CREATE_1 = 5
local BTN_ENTERGAME = 6
local CELL_BEGIN = 100  --底分选择
local PLAYER_BEGIN = 200 --人数选择
local CBT_BEGIN = 300   --局数选择

local CBT_ONE_PAY  = 10          -- 一人支付
local CBT_AA_PAY   = 11           -- AA

    -- 密码配置
local CBT_NEEDPASSWD   = 20       -- 需要密码
local CBT_NOPASSWD     = 21       -- 不需要密码

local CBT_TONGBI    = 30        --经典通比
local CBT_BAWANG    = 31        --霸王庄模式

local CBT_GUN1   =  40          --打枪+1
local CBT_GUN2   = 41           --打枪+2

local CBT_PLAYER2 = 50          --两人场
local CBT_PLAYER3 = 51          --三人场
local CBT_PLAYER4 = 52          --四人场

local MENU_DROPDOWN_1 = 55    -- 下拉菜单1
local MASK_DROPDOWN_1 = 56   -- 下拉背景1
local MENU_DROPDOWN_2 = 57   -- 下拉菜单2
local MASK_DROPDOWN_2 = 58     -- 下拉背景2
local MENU_DROPDOWN_3 = 59   -- 下拉菜单3
local MASK_DROPDOWN_3 = 60     -- 下拉背景3

local dropDownMenuYPox = {51, 121, 191, 261, 331}
local dropDownBgHeight = {98, 168, 238, 308, 378}

local dropDownUpBtnPic = {
    down =          "room/sparrowgd_pribtn_arrow_down_0.png",
    down_press =    "room/sparrowgd_pribtn_arrow_down_1.png",
    up =            "room/sparrowgd_pribtn_arrow_up_0.png",
    up_press =      "room/sparrowgd_pribtn_arrow_up_1.png",
}

function PriRoomCreateLayer:ctor( scene,param,level )
    PriRoomCreateLayer.super.ctor(self, scene, param, level)
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("room/PrivateRoomCreateLayer.csb", self )
    self.m_csbNode = csbNode

    self._playindex = 0 --玩法
    self._gunnum = 1 --打枪配置

    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(BTN_CLOSE)
    mask:addTouchEventListener( btncallback )

    -- 底板
    local spbg = csbNode:getChildByName("sp_bg")
    self.m_spBg = spbg

    -- -- 帮助按钮
    -- local btn = spbg:getChildByName("btn_tips")
    -- btn:setTag(BTN_HELP)
    -- btn:addTouchEventListener(btncallback)  

    -- 关闭
    local btn = spbg:getChildByName("btn_close")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener(btncallback)

    -- 支付选择
    self.m_nSelectPayMode = self._cmd_pri.define.tabPayMode.ONE_PAY
    self.m_nPayModeIdx = CBT_ONE_PAY
    local paymodelistener = function (sender,eventType)
        self:onPayModeSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabPayModeBox = {}
    -- 一人付
    local checkbx = spbg:getChildByName("check_consume_1")
    checkbx:setTag(CBT_ONE_PAY)
    checkbx:addEventListener(paymodelistener)
    checkbx.nPayMode = self._cmd_pri.define.tabPayMode.ONE_PAY
    checkbx:setSelected(true)
    self.m_tabPayModeBox[CBT_ONE_PAY] = checkbx
    -- AA付
    checkbx = spbg:getChildByName("check_consume_2")
    checkbx:setTag(CBT_AA_PAY)
    checkbx:addEventListener(paymodelistener)
    checkbx.nPayMode = self._cmd_pri.define.tabPayMode.AA_PAY
    self.m_tabPayModeBox[CBT_AA_PAY] = checkbx

    -- 是否密码
    self.m_nSelectPasswd = self._cmd_pri.define.tabPasswdMode.NO_PASSWD
    self.m_nPasswdModeIdx = CBT_NOPASSWD
    local passwdmodelistener = function (sender,eventType)
        self:onPasswdModeSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabPasswdModeBox = {}
    -- 需要密码
    checkbx = spbg:getChildByName("check_passwdmode_1")
    checkbx:setTag(CBT_NEEDPASSWD)
    checkbx:addEventListener(passwdmodelistener)
    checkbx.nPasswdMode = self._cmd_pri.define.tabPasswdMode.SET_PASSWD
    self.m_tabPasswdModeBox[CBT_NEEDPASSWD] = checkbx
    -- 不需要密码
    checkbx = spbg:getChildByName("check_passwdmode_2")
    checkbx:setTag(CBT_NOPASSWD)
    checkbx:addEventListener(passwdmodelistener)
    checkbx.nPasswdMode = self._cmd_pri.define.tabPasswdMode.NO_PASSWD
    checkbx:setSelected(true)
    self.m_tabPasswdModeBox[CBT_NOPASSWD] = checkbx

       -- 下拉菜单1
    btn = spbg:getChildByName("btn_dropdown_1")
    btn:setTag(MENU_DROPDOWN_1)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropDown1 = btn
    -- 下拉箭头1
    btn = spbg:getChildByName("btn_dropdown_arrow_1")
    btn:setTag(MENU_DROPDOWN_1)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropArrow1 = btn
    -- 下拉背景1
    local panel = spbg:getChildByName("dropdown_panel_1")
    panel:setTag(MASK_DROPDOWN_1)
    panel:addTouchEventListener( btncallback )
    panel:setVisible(false)
    self.m_maskDropDown1 = panel
    -- 菜单背景1
    self.m_imageDropDownBg1 = panel:getChildByName("dropdown_1")

    -- 下拉菜单2
    btn = spbg:getChildByName("btn_dropdown_2")
    btn:setTag(MENU_DROPDOWN_2)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropDown2 = btn
    -- 下拉箭头2
    btn = spbg:getChildByName("btn_dropdown_arrow_2")
    btn:setTag(MENU_DROPDOWN_2)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropArrow2 = btn
    -- 下拉背景2
    panel = spbg:getChildByName("dropdown_panel_2")
    panel:setTag(MASK_DROPDOWN_2)
    panel:addTouchEventListener( btncallback )
    panel:setVisible(false)
    self.m_maskDropDown2 = panel
    -- 菜单背景2
    self.m_imageDropDownBg2 = panel:getChildByName("dropdown_2")

    -- 下拉菜单3
    btn = spbg:getChildByName("btn_dropdown_3")
    btn:setTag(MENU_DROPDOWN_3)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropDown3 = btn
    -- 下拉箭头2
    btn = spbg:getChildByName("btn_dropdown_arrow_3")
    btn:setTag(MENU_DROPDOWN_3)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropArrow3 = btn
    -- 下拉背景2
    panel = spbg:getChildByName("dropdown_panel_3")
    panel:setTag(MASK_DROPDOWN_3)
    panel:addTouchEventListener( btncallback )
    panel:setVisible(false)
    self.m_maskDropDown3 = panel
    -- 菜单背景2
    self.m_imageDropDownBg3 = panel:getChildByName("dropdown_3")

    -- 选择规则
    self.m_txtSelectRule = spbg:getChildByName("txt_selectscore")
    self.m_txtSelectRule:setString("")

    -- 选择局数
    self.m_txtSelectRound = spbg:getChildByName("txt_selectround")
    self.m_txtSelectRound:setString("")

     -- 选择人数
    self.m_txtSelectPlayer = spbg:getChildByName("txt_selectsplayer")
    self.m_txtSelectPlayer:setString("")



    --人数选择
    self.m_nPlayerNum = 2
    local playernumCount = {2, 3, 4, 0}
    local playerlistener = function (sender,eventType)
        local tag = sender:getTag()
        self.m_nPlayerNum = playernumCount[tag - PLAYER_BEGIN]
        for k,v in pairs(self.m_playernumlist) do
            if k == tag then
                v:setSelected(true)
            else
                v:setSelected(false)
            end
        end
        print("+++++++++++++",self.m_nPlayerNum)
        if self.m_nPlayerNum == 0 then
            self.m_txtSelectPlayer:setString("2-4人")
        else
            self.m_txtSelectPlayer:setString(self.m_nPlayerNum.."人")
        end
    end

    self.m_playernumlist = {}
    for i = 5, 8 do 
        local checkbx = self.m_imageDropDownBg3:getChildByName("check_rule_" .. i)
        if nil ~= checkbx then
            checkbx:setTag(PLAYER_BEGIN + i - 4)
            checkbx:addEventListener(playerlistener)
            self.m_playernumlist[PLAYER_BEGIN + i - 4] = checkbx
        end
    end
    self.m_playernumlist[PLAYER_BEGIN+1]:setSelected(true)
    self.m_txtSelectPlayer:setString("2人")

    --玩法选择
    local playlistener = function (sender,eventType)
        local tag = sender:getTag()
        for k,v in pairs(self.m_playlist) do
            if k == tag then
                v:setSelected(true)
            else
                v:setSelected(false)
            end
        end
        self.m_nSelectMode = tag+10
    end

    self.m_playlist = {}
    for i=1,3 do
        local checkbox = self.m_spBg:getChildByName("check_rule_"..i)
        if checkbox ~= nil then
            self.m_playlist[i] = checkbox
            checkbox:setTag(i)
            checkbox:addEventListener(playlistener)
        end
    end
    self.m_playlist[1]:setSelected(true)
    self.m_nSelectMode = 11

    --打枪选择yxz
    --[[local gunlistener = function (sender,eventType)
        local tag = sender:getTag()
        for k,v in pairs(self.m_gunlist) do
            if k == tag then
                v:setSelected(true)
            else
                v:setSelected(false)
            end
        end
        self._gunnum = tag
    end

    self.m_gunlist = {}
    for i=1,2 do
        local checkbox = self.m_spBg:getChildByName("check_rule_"..(i+2))
        if checkbox ~= nil then
            self.m_gunlist[i] = checkbox
            checkbox:setTag(i)
            checkbox:addEventListener(gunlistener)
        end
    end
    self.m_gunlist[1]:setSelected(true)
    self._gunnum = 1]]--


    -- 创建费用
    self.m_txtFee = self.m_spBg:getChildByName("txt_createfee")
    self.m_txtFee:setString("")

    -- 创建按钮
    btn = spbg:getChildByName("btn_createroom")
    btn:setTag(BTN_CREATE)
    btn:addTouchEventListener(btncallback)

    -- 代人开房
    btn = spbg:getChildByName("btn_createroom_1")
    btn:setTag(BTN_CREATE_1)
    btn:addTouchEventListener(btncallback)
    
    self:onRefreshOption()

    -- 加载动画
    self:scaleTransitionIn(spbg)
end

--高级配置
function PriRoomCreateLayer:highConfigInit()
    local csbNode = ExternalFun.loadCSB("room/HighConfigLayer.csb", self)

    local function closecallback(sender, tType)
        if tType == ccui.TouchEventType.ended then
           csbNode:removeFromParent()
        end
    end
    local btnclose = csbNode:getChildByName("bt_close")
    btnclose:setVisible(false)
    btnclose:addTouchEventListener(closecallback)

    local bglayout = csbNode:getChildByName("layout_bg")
    bglayout:addTouchEventListener(closecallback)

    local btnensure = csbNode:getChildByName("bt_ensure")
    btnensure:addTouchEventListener(closecallback)

    local function playlistener(ref, tType)
        if tType == ccui.TouchEventType.ended then
            local tag = ref:getTag()
            for k,v in pairs(self.m_playlist) do
                local checkbox = v:getChildByName("im_check")
                if k ~= tag then
                    checkbox:loadTexture("room/bt_pri_check_1.png")
                else
                    checkbox:loadTexture("room/bt_pri_check_0.png")
                end
            end
            self._playindex = tag-1
        end
    end

    self.m_playlist = {}
    for i=1,2 do
        local checkbox = csbNode:getChildByName("bt_play_"..i)
        if checkbox ~= nil then
            self.m_playlist[i] = checkbox
            checkbox:setTag(i)
            checkbox:addTouchEventListener(playlistener)
            if i == self._playindex+1 then
                playlistener(checkbox, ccui.TouchEventType.ended)
            end
        end
    end

    local function gunlistener(ref, tType)
        if tType == ccui.TouchEventType.ended then
            local tag = ref:getTag()
            for k,v in pairs(self.m_gunlist) do
                local checkbox = v:getChildByName("im_check")
                if k ~= tag then
                    checkbox:loadTexture("room/bt_pri_check_1.png")
                else
                    checkbox:loadTexture("room/bt_pri_check_0.png")
                end
            end
            self._gunnum = tag
        end
    end

    self.m_gunlist = {}
    for i=1,2 do
        local checkbox = csbNode:getChildByName("bt_gun_"..i)
        if checkbox ~= nil then
            self.m_gunlist[i] = checkbox
            checkbox:setTag(i)
            checkbox:addTouchEventListener(gunlistener)
            if i == self._gunnum then
                gunlistener(checkbox, ccui.TouchEventType.ended)
            end
        end
    end
end    

------
-- 继承/覆盖
------
-- 刷新界面
function PriRoomCreateLayer:onRefreshInfo()
    -- 房卡数更新
end

function PriRoomCreateLayer:onRefreshOption()
    -- 房卡数更新
    local RoomOption = PriRoom:getInstance().m_tabRoomOption
    -- 必须参与
    if 1 == RoomOption.cbIsJoinGame then
        local btn = self.m_spBg:getChildByName("btn_createroom_1")
        btn:setEnabled(false)
        btn:setOpacity(200)
    end
    
    if RoomOption.cbCardOrBean == 0 then
        self.m_spBg:getChildByName('sp_diamond'):setVisible(true)
        self.m_spBg:getChildByName('sp_roomcard'):setVisible(false)
    elseif RoomOption.cbCardOrBean == 1 then
        self.m_spBg:getChildByName('sp_diamond'):setVisible(false)
        self.m_spBg:getChildByName('sp_roomcard'):setVisible(true)
    end
end

function PriRoomCreateLayer:onRefreshFeeList()
    PriRoom:getInstance():dismissPopWait()
    local this = self
    self.m_tabScoreList = {}
    local scoreList = clone(PriRoom:getInstance().m_tabCellScoreList)
    if type(scoreList) ~= "table" then
        scoreList = {}
    end
    local nScoreList = #scoreList
    if 0 == nScoreList then
        scoreList = {10, 20, 30, 40, 50}
        nScoreList = 5
    end
    self.m_scoreList = scoreList
    -- 规则选择
    local rulelistener = function (sender,eventType)
        this:onSelectedScoreEvent(sender:getTag(),sender)
    end
    local yPos = 51
    local bgHeight = 0
    for i = 1, nScoreList do 
        -- y轴位置
        yPos = dropDownMenuYPox[nScoreList - i + 1] or 51

        local score = scoreList[i] or 0
        local checkbx = self.m_imageDropDownBg1:getChildByName("check_cell_" .. i)
        if nil ~= checkbx then
            checkbx:setVisible(true)
            checkbx:setTag(CELL_BEGIN + i)
            checkbx:addEventListener(rulelistener)
            -- 设置位置
            checkbx:setPositionY(yPos)
            self.m_tabScoreList[CELL_BEGIN + i] = checkbx
        end

        local txtScore = self.m_imageDropDownBg1:getChildByName("txt_cell_" .. i)
        if nil ~= txtScore then
            -- 设置底分
            txtScore:setString(score .. "分")
            txtScore:setVisible(true)
            -- 设置位置
            txtScore:setPositionY(yPos)
        end
        if score == 0 then
            checkbx:setVisible(false)
            txtScore:setVisible(false)
        end
    end
    self.m_nSelectScore = nil
    -- 默认选择底分  
    if nScoreList > 0 then
        self.m_nSelectScoreIdx = CELL_BEGIN + 1
        self.m_tabScoreList[self.m_nSelectScoreIdx]:setSelected(true)
        self.m_nSelectScore = scoreList[1]

        self.m_txtSelectRule:setString(string.format("%d分", self.m_nSelectScore))

        bgHeight = dropDownBgHeight[nScoreList] or 0
        self.m_imageDropDownBg1:setContentSize(self.m_imageDropDownBg1:getContentSize().width, bgHeight)
    end

    yPos = 51
    bgHeight = 0
    local cbtlistener = function (sender,eventType)
        this:onSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabCheckBox = {}
    local nConfig = #PriRoom:getInstance().m_tabFeeConfigList
    -- 局数
    for i = 1, nConfig do
        yPos = dropDownMenuYPox[nConfig - i + 1] or 51
        local config = PriRoom:getInstance().m_tabFeeConfigList[i]
        local checkbx = self.m_imageDropDownBg2:getChildByName("check_round_" .. i)
        if nil ~= checkbx then
            checkbx:setVisible(true)
            checkbx:setTouchEnabled(true)
            checkbx:setTag(CBT_BEGIN + i)
            checkbx:addEventListener(cbtlistener)
            checkbx:setSelected(false)
            -- 设置位置
            checkbx:setPositionY(yPos)
            self.m_tabCheckBox[CBT_BEGIN + i] = checkbx
        end

        local txtcount = self.m_imageDropDownBg2:getChildByName("txt_round_" .. i)
        if nil ~= txtcount then
            -- 设置位置
            txtcount:setPositionY(yPos)
            txtcount:setString(config.dwDrawCountLimit .. "局")
            txtcount:setVisible(true)
        end
    end
    -- 选择的玩法    
    self.m_nSelectIdx = CBT_BEGIN + 1
    self.m_tabSelectConfig = nil
    if nConfig > 0 then
        self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[self.m_nSelectIdx - CBT_BEGIN]
        self.m_tabCheckBox[self.m_nSelectIdx]:setSelected(true)
        self.m_txtSelectRound:setString(string.format("%d局", self.m_tabSelectConfig.dwDrawCountLimit))

        -- 更新费用
        self:updateCreateFee()

        bgHeight = dropDownBgHeight[nConfig] or 0
        self.m_imageDropDownBg2:setContentSize(self.m_imageDropDownBg2:getContentSize().width, bgHeight)
    end

    -- 免费判断
    if PriRoom:getInstance().m_bLimitTimeFree then
        local wStart = PriRoom:getInstance().m_tabRoomOption.wBeginFeeTime or 0
        local wEnd = PriRoom:getInstance().m_tabRoomOption.wEndFeeTime or 0
        -- 免费时间
        local szfree = string.format("( 限时免费: %02d:00-%02d:00 )", wStart,wEnd)
        self.m_spBg:getChildByName("txt_feetime"):setString(szfree)

        -- 划线
        local draw = cc.DrawNode:create()
        draw:drawSegment(cc.p(560, 75), cc.p(645, 75), 3, cc.c4f(0.18, 0.18, 0.18, 0.67))
        self.m_spBg:addChild(draw)

        -- 免费
        local szfile = "room/sparrowks_sp_createbtn_free.png"
        if cc.FileUtils:getInstance():isFileExist(szfile) then
            self.m_spBg:getChildByName("sp_create_tips"):setSpriteFrame(cc.Sprite:create(szfile):getSpriteFrame())
        end

        -- 字变灰
        self.m_txtFee:setTextColor(cc.c3b(45, 45, 45))
        self.m_txtFee:enableShadow(cc.c4b(0, 255, 0, 0), cc.size(0, -2))
        -- 钻石变灰
        szfile = "shop/itembuy_sp_diamond_gray.png"
        if cc.FileUtils:getInstance():isFileExist(szfile) then
            self.m_spBg:getChildByName("sp_diamond"):setSpriteFrame(cc.Sprite:create(szfile):getSpriteFrame())
        end
    end

        -- 激活按钮
    self.m_btnDropDown1:setEnabled(true)
    self.m_btnDropArrow1:setEnabled(true)
    self.m_btnDropDown2:setEnabled(true)
    self.m_btnDropArrow2:setEnabled(true)
    self.m_btnDropDown3:setEnabled(true)
    self.m_btnDropArrow3:setEnabled(true)

    self:onRefreshOption()
end

function PriRoomCreateLayer:onLoginPriRoomFinish()
    local meUser = PriRoom:getInstance():getMeUserItem()
    if nil == meUser then
        return false
    end
    -- 发送创建桌子
    if ((meUser.cbUserStatus == yl.US_FREE or meUser.cbUserStatus == yl.US_NULL or meUser.cbUserStatus == yl.US_PLAYING or meUser.cbUserStatus == yl.US_SIT)) then
        if PriRoom:getInstance().m_nLoginAction == PriRoom.L_ACTION.ACT_CREATEROOM then
            -- 创建登陆
            local buffer = ExternalFun.create_netdata(self._cmd_pri_game.CMD_GR_CreateTable)
            buffer:setcmdinfo(self._cmd_pri_game.MDM_GR_PERSONAL_TABLE,self._cmd_pri_game.SUB_GR_CREATE_TABLE)
            buffer:pushscore(self.m_nSelectScore)   --lCellScore
            buffer:pushdword(self.m_tabSelectConfig.dwDrawCountLimit)
            buffer:pushdword(self.m_tabSelectConfig.dwDrawTimeLimit)
            buffer:pushword(0)  -- wJoinGamePeopleCount
            buffer:pushdword(0) -- dwRoomTax
            buffer:pushbyte(0)  -- 支付方式--[[self.m_nSelectPayMode]]
            -- 是否代开
            buffer:pushbyte(PriRoom:getInstance().m_bCreateForOther==true and 1 or 0)
            buffer:pushstring("", yl.LEN_PASSWORD)

            buffer:pushbyte(1)
            buffer:pushbyte(self.m_nPlayerNum)
            buffer:pushbyte(self.m_nSelectMode)
            --buffer:pushbyte(self._gunnum)
            for i = 1, 96 do
                buffer:pushbyte(0)
            end
            PriRoom:getInstance():getNetFrame():sendGameServerMsg(buffer)
            return true
        end        
    end
    return false
end

function PriRoomCreateLayer:getInviteShareMsg( roomDetailInfo )
    local szGameName = '四人牛牛'
    
    local szRoomID = roomDetailInfo.szRoomID or "0"
    local turnCount = roomDetailInfo.dwPlayTurnCount or 0
    local passwd = roomDetailInfo.dwRoomDwd or 0

    local content = string.format("%s约战 房间ID:%s 局数:%d，%s精彩刺激, 一起来玩吧!", szGameName, szRoomID, turnCount, szGameName)
    local friendC = string.format("%s房间ID:%s 局数:%d", szGameName, szRoomID, turnCount)
    local title = string.format("%s约战", szGameName)
    local url = yl.getPriInviteURL(cmd.KIND_ID, szRoomID, passwd)
    return {title = title, content = content, friendContent = friendC, url = url}
end

function PriRoomCreateLayer:getCopyShareMsg(roomDetailInfo)
    local szRoomID = roomDetailInfo.szRoomID or ""
    return {content = string.format("四人牛牛, 房号[%s],您的好友喊你打牌了!", szRoomID)}
end

function PriRoomCreateLayer:onExit()
    --cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("room/land_room.plist")
    --cc.Director:getInstance():getTextureCache():removeTextureForKey("room/land_room.png")
end

function PriRoomCreateLayer:animationRemove()
    self:scaleTransitionOut(self.m_spBg)
end


------
-- 继承/覆盖
------

function PriRoomCreateLayer:onButtonClickedEvent( tag, sender)
    if BTN_HELP == tag then
        --self._scene:popHelpLayer2(7, 1)
    elseif BTN_CLOSE == tag then
        self:scaleTransitionOut(self.m_spBg)
    elseif BTN_CREATE == tag or BTN_CREATE_1 == tag then 
        if self.m_bLow and not PriRoom:getInstance().m_bLimitTimeFree then
            PriRoom:getInstance():showShop(self._scene, true)
            return
        end
        if nil == self.m_tabSelectConfig or table.nums(self.m_tabSelectConfig) == 0 then
            showToast(cc.Director:getInstance():getRunningScene(), "未选择玩法配置!", 2)
            return
        end
          -- 是否代开
        PriRoom:getInstance().m_bCreateForOther = (BTN_CREATE_1 == tag)
        PriRoom:getInstance():showPopWait()
        PriRoom:getInstance():getNetFrame():onCreateRoom()
    elseif MENU_DROPDOWN_1 == tag then
        self.m_maskDropDown1:setVisible(true)
        -- 更新箭头
        self.m_btnDropArrow1:loadTextureDisabled(dropDownUpBtnPic.up)
        self.m_btnDropArrow1:loadTextureNormal(dropDownUpBtnPic.up)
        self.m_btnDropArrow1:loadTexturePressed(dropDownUpBtnPic.up_press)
    elseif MASK_DROPDOWN_1 == tag then
        self.m_maskDropDown1:setVisible(false)
        -- 更新箭头
        self.m_btnDropArrow1:loadTextureDisabled(dropDownUpBtnPic.down)
        self.m_btnDropArrow1:loadTextureNormal(dropDownUpBtnPic.down)
        self.m_btnDropArrow1:loadTexturePressed(dropDownUpBtnPic.down_press)
    elseif MENU_DROPDOWN_2 == tag then
        self.m_maskDropDown2:setVisible(true)
        -- 更新箭头
        self.m_btnDropArrow2:loadTextureDisabled(dropDownUpBtnPic.up)
        self.m_btnDropArrow2:loadTextureNormal(dropDownUpBtnPic.up)
        self.m_btnDropArrow2:loadTexturePressed(dropDownUpBtnPic.up_press)
    elseif MASK_DROPDOWN_2 == tag then
        self.m_maskDropDown2:setVisible(false)
        -- 更新箭头
        self.m_btnDropArrow2:loadTextureDisabled(dropDownUpBtnPic.down)
        self.m_btnDropArrow2:loadTextureNormal(dropDownUpBtnPic.down)
        self.m_btnDropArrow2:loadTexturePressed(dropDownUpBtnPic.down_press)
    elseif MENU_DROPDOWN_3 == tag then
        self.m_maskDropDown3:setVisible(true)
        -- 更新箭头
        self.m_btnDropArrow3:loadTextureDisabled(dropDownUpBtnPic.up)
        self.m_btnDropArrow3:loadTextureNormal(dropDownUpBtnPic.up)
        self.m_btnDropArrow3:loadTexturePressed(dropDownUpBtnPic.up_press)
    elseif MASK_DROPDOWN_3 == tag then
        self.m_maskDropDown3:setVisible(false)
        -- 更新箭头
        self.m_btnDropArrow3:loadTextureDisabled(dropDownUpBtnPic.down)
        self.m_btnDropArrow3:loadTextureNormal(dropDownUpBtnPic.down)
        self.m_btnDropArrow3:loadTexturePressed(dropDownUpBtnPic.down_press)
    end
end

function PriRoomCreateLayer:onSelectedScoreEvent(tag, sender)
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", tag)
    if self.m_nSelectScoreIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nSelectScoreIdx = tag
    for k,v in pairs(self.m_tabScoreList) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
    self.m_nSelectScore = self.m_scoreList[self.m_nSelectScoreIdx - CELL_BEGIN]
    self.m_txtSelectRule:setString(string.format("%d分", self.m_nSelectScore))
end

function PriRoomCreateLayer:onPayModeSelectedEvent( tag, sender )
    if self.m_nPayModeIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nPayModeIdx = tag
    for k,v in pairs(self.m_tabPayModeBox) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
    if nil ~= sender.nPayMode then
        self.m_nSelectPayMode = sender.nPayMode
    end
    -- 更新费用
    self:updateCreateFee()
end

function PriRoomCreateLayer:onPasswdModeSelectedEvent( tag, sender )
    if self.m_nPasswdModeIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nPasswdModeIdx = tag
    for k,v in pairs(self.m_tabPasswdModeBox) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
    if nil ~= sender.nPasswdMode then
        self.m_nSelectPasswd = sender.nPasswdMode
    end
end

function PriRoomCreateLayer:onSelectedEvent(tag, sender)
    if self.m_nSelectIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nSelectIdx = tag
    for k,v in pairs(self.m_tabCheckBox) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
    self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[tag - CBT_BEGIN]
    if nil == self.m_tabSelectConfig then
        return
    end
    self.m_txtSelectRound:setString(string.format("%d局", self.m_tabSelectConfig.dwDrawCountLimit))
    -- 更新费用
    self:updateCreateFee()
end

function PriRoomCreateLayer:updateCreateFee()
    local bIsAA = self.m_nSelectPayMode == self._cmd_pri.define.tabPayMode.AA_PAY
    local kFeeInfo = PriRoom:getInstance():GetFeeInfo(self.m_tabSelectConfig, { bIsAA = bIsAA })
    self.m_bLow = kFeeInfo.lack
    self.m_txtFee:setString( kFeeInfo.fee_text )
end

-- AA制界面
function PriRoomAAPayLayer:ctor( scene, param, level )
    PriRoomAAPayLayer.super.ctor( self, scene, param, level )

    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("room/PrivateRoomAAPayLayer.csb", self)
    local touchFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(), ref)            
        end
    end

    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(BTN_CLOSE)
    mask:addTouchEventListener( touchFunC )

    -- 底板
    local spbg = csbNode:getChildByName("sp_bg")
    self.m_spBg = spbg

    -- 关闭
    local btn = spbg:getChildByName("btn_close")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener( touchFunC )
    btn:setPressedActionEnabled(true)

    -- 进入
    btn = spbg:getChildByName("btn_entergame")
    btn:setTag(BTN_ENTERGAME)
    btn:addTouchEventListener( touchFunC )
    btn:setPressedActionEnabled(true)

    -- 房间id
    local roomid = self._param.szRoomID or 0
    spbg:getChildByName("txt_roomid"):setString(string.format("%06d", roomid))

    -- 消耗钻石
    local consume = self._param.lDiamondFee or 0
    spbg:getChildByName("txt_consume"):setString(consume .. "")

    -- 玩法
    local wanfa = spbg:getChildByName("txt_wanfa")

    -- 规则
    local guize = spbg:getChildByName("txt_guize")
    local buffer = self._param.buffer
    if nil ~= buffer and nil ~= buffer.readbyte then
        -- 读前两个规则
        buffer:readbyte()

        -- 游戏玩法
        local cbMode = buffer:readbyte()
        local szBaiDa = "经典通比（无庄家）"
        if 1 == cbMode then
            szBaiDa = "庄家比模式（霸王庄）"
        end

        -- 打枪
        local cbGunnum = buffer:readbyte()
        local szDongNan = "打枪加分+1"
        if 2 == cbGunnum then
            szDongNan = "打枪加分+2"
        end

        -- 玩法
        spbg:getChildByName("txt_wanfa"):setString(szBaiDa)
        -- 规则
        spbg:getChildByName("txt_guize"):setString(szDongNan)
    end

    -- 局数
    local ncount = self._param.dwDrawCountLimit or 0
    spbg:getChildByName("txt_jushu"):setString(ncount .. "局")

    self:scaleTransitionIn(spbg)
end

function PriRoomAAPayLayer:onButtonClickedEvent( tag,sender )
    if  tag == BTN_CLOSE then
        -- 断开
        PriRoom:getInstance():closeGameSocket()

        self:scaleTransitionOut(self.m_spBg)
    elseif tag == BTN_ENTERGAME then
        print("self userid ", GlobalUserItem.tabAccountInfo.dwUserID ~= self._param.dwRommerID)
        -- 判断是否密码, 且非房主
        if self._param.bRoomPwd and GlobalUserItem.tabAccountInfo.dwUserID ~= self._param.dwRommerID then
            PriRoom:getInstance():passwdInput()
        else
            PriRoom:getInstance().m_nLoginAction = PriRoom.L_ACTION.ACT_SEARCHROOM
            PriRoom:getInstance():showPopWait()
            PriRoom:getInstance():getNetFrame():sendEnterPrivateGame()
        end
    end
end

function PriRoomAAPayLayer:animationRemove()
    self:scaleTransitionOut(self.m_spBg)
end


return PriRoomCreateLayer