--
-- Author: zhong
-- Date: 2016-12-17 14:07:02
--
-- 包含(创建界面、aa制付款提示界面)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

-- 斗地主私人房创建界面
local CreateLayerModel = appdf.req(PriRoom.MODULE.PLAZAMODULE .."models.CreateLayerModel")
local PriRoomCreateLayer = class("PriRoomCreateLayer", CreateLayerModel)

-- 斗地主AA制提示界面
local TransitionLayer = appdf.req(appdf.EXTERNAL_SRC .. "TransitionLayer")
local PriRoomAAPayLayer = class("PriRoomAAPayLayer", TransitionLayer)

local cmd = import('..models.CMD_Game')

PriRoomCreateLayer.PriRoomAAPayLayer = PriRoomAAPayLayer

local TAG_START             = 100
local enumTable = 
{
    "BTN_CLOSE",            -- 关闭按钮
    "TAG_MASK",             -- 遮罩
    "BTN_HELP",             -- 帮助
    "BTN_CHARGE",           -- 充值
    "BTN_MYROOM",           -- 自己房间
    "BTN_CREATE",           -- 立即开局
    "BTN_CREATE_1",         -- 代人开房
    "BTN_ENTERGAME",        -- 进入游戏
    "CBT_ONE_PAY",          -- 一人支付
    "CBT_AA_PAY",           -- AA

    -- 密码配置
    "CBT_NEEDPASSWD",       -- 需要密码
    "CBT_NOPASSWD",         -- 不需要密码

    "MENU_DROPDOWN_1",      -- 下拉菜单1
    "MASK_DROPDOWN_1",      -- 下拉背景1
    "MENU_DROPDOWN_2",      -- 下拉菜单2
    "MASK_DROPDOWN_2",      -- 下拉背景2
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(TAG_START, enumTable)
local CBT_RULEBEGIN = 200
local CBT_BEGIN = 400

local dropDownMenuYPox = {51, 121, 191, 261, 331}
local dropDownBgHeight = {98, 168, 238, 308, 378}

local dropDownUpBtnPic = {
    down =          "room/land_pribtn_arrow_down_0.png",
    down_press =    "room/land_pribtn_arrow_down_1.png",
    up =            "room/land_pribtn_arrow_up_0.png",
    up_press =      "room/land_pribtn_arrow_up_1.png",
}

-- 创建界面
function PriRoomCreateLayer:ctor( scene,param,level )
    local this = self
    PriRoomCreateLayer.super.ctor(self, scene, param, level)
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("room/PrivateRoomCreateLayer.csb", self )
    self.m_csbNode = csbNode

    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(TAG_ENUM.TAG_MASK)
    mask:addTouchEventListener( btncallback )

    -- 底板
    local spbg = csbNode:getChildByName("sp_bg")
    self.m_spBg = spbg

    -- 关闭
    local btn = spbg:getChildByName("btn_close")
    btn:setTag(TAG_ENUM.BTN_CLOSE)
    btn:addTouchEventListener(btncallback)

    -- 支付选择
    self.m_nSelectPayMode = self._cmd_pri.define.tabPayMode.ONE_PAY
    self.m_nPayModeIdx = TAG_ENUM.CBT_ONE_PAY
    local paymodelistener = function (sender,eventType)
        this:onPayModeSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabPayModeBox = {}
    -- 一人付
    local checkbx = spbg:getChildByName("check_consume_1")
    checkbx:setTag(TAG_ENUM.CBT_ONE_PAY)
    checkbx:addEventListener(paymodelistener)
    checkbx.nPayMode = self._cmd_pri.define.tabPayMode.ONE_PAY
    checkbx:setSelected(true)
    self.m_tabPayModeBox[TAG_ENUM.CBT_ONE_PAY] = checkbx
    -- AA付
    checkbx = spbg:getChildByName("check_consume_2")
    checkbx:setTag(TAG_ENUM.CBT_AA_PAY)
    checkbx:addEventListener(paymodelistener)
    checkbx.nPayMode = self._cmd_pri.define.tabPayMode.AA_PAY
    self.m_tabPayModeBox[TAG_ENUM.CBT_AA_PAY] = checkbx
    
    -- 是否密码
    self.m_nSelectPasswd = self._cmd_pri.define.tabPasswdMode.NO_PASSWD
    self.m_nPasswdModeIdx = TAG_ENUM.CBT_NOPASSWD
    local passwdmodelistener = function (sender,eventType)
        this:onPasswdModeSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabPasswdModeBox = {}
    -- 需要密码
    checkbx = spbg:getChildByName("check_passwdmode_1")
    checkbx:setTag(TAG_ENUM.CBT_NEEDPASSWD)
    checkbx:addEventListener(passwdmodelistener)
    checkbx.nPasswdMode = self._cmd_pri.define.tabPasswdMode.SET_PASSWD
    self.m_tabPasswdModeBox[TAG_ENUM.CBT_NEEDPASSWD] = checkbx
    -- 不需要密码
    checkbx = spbg:getChildByName("check_passwdmode_2")
    checkbx:setTag(TAG_ENUM.CBT_NOPASSWD)
    checkbx:addEventListener(passwdmodelistener)
    checkbx.nPasswdMode = self._cmd_pri.define.tabPasswdMode.NO_PASSWD
    checkbx:setSelected(true)
    self.m_tabPasswdModeBox[TAG_ENUM.CBT_NOPASSWD] = checkbx

    -- 立即创建
    btn = spbg:getChildByName("btn_createroom")
    btn:setTag(TAG_ENUM.BTN_CREATE)
    btn:addTouchEventListener(btncallback)

    -- 代人开房
    btn = spbg:getChildByName("btn_createroom_1")
    btn:setTag(TAG_ENUM.BTN_CREATE_1)
    btn:addTouchEventListener(btncallback)

    -- 下拉菜单1
    btn = spbg:getChildByName("btn_dropdown_1")
    btn:setTag(TAG_ENUM.MENU_DROPDOWN_1)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropDown1 = btn
    -- 下拉箭头1
    btn = spbg:getChildByName("btn_dropdown_arrow_1")
    btn:setTag(TAG_ENUM.MENU_DROPDOWN_1)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropArrow1 = btn
    -- 下拉背景1
    local panel = spbg:getChildByName("dropdown_panel_1")
    panel:setTag(TAG_ENUM.MASK_DROPDOWN_1)
    panel:addTouchEventListener( btncallback )
    panel:setVisible(false)
    self.m_maskDropDown1 = panel
    -- 菜单背景1
    self.m_imageDropDownBg1 = panel:getChildByName("dropdown_1")

    -- 下拉菜单2
    btn = spbg:getChildByName("btn_dropdown_2")
    btn:setTag(TAG_ENUM.MENU_DROPDOWN_2)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropDown2 = btn
    -- 下拉箭头2
    btn = spbg:getChildByName("btn_dropdown_arrow_2")
    btn:setTag(TAG_ENUM.MENU_DROPDOWN_2)
    btn:addTouchEventListener(btncallback)
    btn:setEnabled(false)
    self.m_btnDropArrow2 = btn
    -- 下拉背景2
    panel = spbg:getChildByName("dropdown_panel_2")
    panel:setTag(TAG_ENUM.MASK_DROPDOWN_2)
    panel:addTouchEventListener( btncallback )
    panel:setVisible(false)
    self.m_maskDropDown2 = panel
    -- 菜单背景2
    self.m_imageDropDownBg2 = panel:getChildByName("dropdown_2")

    -- 选择规则
    self.m_txtSelectRule = spbg:getChildByName("txt_selectrule")
    self.m_txtSelectRule:setString("")

    -- 选择局数
    self.m_txtSelectRound = spbg:getChildByName("txt_selectround")
    self.m_txtSelectRound:setString("")

    -- 创建费用
    self.m_txtFee = self.m_spBg:getChildByName("txt_createfee")
    self.m_txtFee:setString("")

    self:onRefreshOption()

    -- 注册事件监听
    self:registerEventListenr()
    -- 加载动画
    self:scaleTransitionIn(spbg)
end

------
-- 继承/覆盖
------
-- 刷新界面
function PriRoomCreateLayer:onRefreshInfo()
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

-- 刷新费用列表
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
        local checkbx = self.m_imageDropDownBg1:getChildByName("check_rule_" .. i)
        if nil ~= checkbx then
            checkbx:setVisible(true)
            checkbx:setTag(CBT_RULEBEGIN + i)
            checkbx:addEventListener(rulelistener)
            -- 设置位置
            checkbx:setPositionY(yPos)
            self.m_tabScoreList[CBT_RULEBEGIN + i] = checkbx
        end

        local txtScore = self.m_imageDropDownBg1:getChildByName("txt_rule_" .. i)
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
        self.m_nSelectScoreIdx = CBT_RULEBEGIN + 1
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

        -- 消耗隐藏
        self.m_spBg:getChildByName("txt_createfee_0"):setVisible(false)
        -- 费用隐藏
        self.m_txtFee:setVisible(false)
        -- 钻石隐藏
        self.m_spBg:getChildByName("sp_diamond"):setVisible(false)
    end

    -- 激活按钮
    self.m_btnDropDown1:setEnabled(true)
    self.m_btnDropArrow1:setEnabled(true)
    self.m_btnDropDown2:setEnabled(true)
    self.m_btnDropArrow2:setEnabled(true)

    self:onRefreshOption()
end

function PriRoomCreateLayer:onLoginPriRoomFinish()
    local meUser = PriRoom:getInstance():getMeUserItem()
    if nil == meUser then
        return false
    end
    -- 发送创建桌子
    if ((meUser.cbUserStatus == yl.US_FREE 
        or meUser.cbUserStatus == yl.US_NULL 
        or meUser.cbUserStatus == yl.US_PLAYING
        or meUser.cbUserStatus == yl.US_SIT)) then
        if PriRoom:getInstance().m_nLoginAction == PriRoom.L_ACTION.ACT_CREATEROOM then
            -- 创建登陆
            local buffer = ExternalFun.create_netdata(self._cmd_pri_game.CMD_GR_CreateTable)
            buffer:setcmdinfo(self._cmd_pri_game.MDM_GR_PERSONAL_TABLE,self._cmd_pri_game.SUB_GR_CREATE_TABLE)
            buffer:pushscore(self.m_nSelectScore)
            buffer:pushdword(self.m_tabSelectConfig.dwDrawCountLimit)
            buffer:pushdword(self.m_tabSelectConfig.dwDrawTimeLimit)
            buffer:pushword(3)  -- wJoinGamePeopleCount
            buffer:pushdword(0) -- dwRoomTax
            -- 支付方式
            buffer:pushbyte(self.m_nSelectPayMode)  -- 支付方式
            -- 是否代开
            buffer:pushbyte(PriRoom:getInstance().m_bCreateForOther==true and 1 or 0)
            -- 密码设置
            --buffer:pushbyte(self.m_nSelectPasswd)
            buffer:pushstring("", yl.LEN_PASSWORD)

            -- 附加信息
            buffer:pushbyte(0)
            -- 附加分数
            buffer:pushbyte(self.m_nSelectScore)
            for i = 1, 98 do
                buffer:pushbyte(0)
            end
            PriRoom:getInstance():getNetFrame():sendGameServerMsg(buffer)
            return true
        end        
    end
    return false
end

function PriRoomCreateLayer:getInviteShareMsg( roomDetailInfo )
    local szGameName = '斗地主'
    
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
    local szRoomID = roomDetailInfo.szRoomID or "0"
    return {content = string.format("斗地主, 房号[%06d],您的好友喊你打牌了!", tonumber(szRoomID))}
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
    if TAG_ENUM.TAG_MASK == tag or TAG_ENUM.BTN_CLOSE == tag then
        self:scaleTransitionOut(self.m_spBg)
    elseif TAG_ENUM.BTN_HELP == tag then
        --self._scene:popHelpLayer2(cmd.KIND_ID, 1)
    elseif TAG_ENUM.BTN_CREATE == tag
    or TAG_ENUM.BTN_CREATE_1 == tag then 
        if self.m_bLow then
             PriRoom:getInstance():showShop(self._scene, true)
            return
        end
        if nil == self.m_tabSelectConfig or table.nums(self.m_tabSelectConfig) == 0 then
            showToast(self, "未选择玩法配置!", 2)
            return
        end
        if nil == self.m_nSelectScore or table.nums(self.m_scoreList) == 0 then
            showToast(self, "未选择游戏底分!", 2)
            return
        end
        -- 是否代开
        PriRoom:getInstance().m_bCreateForOther = (TAG_ENUM.BTN_CREATE_1 == tag)
        -- 创建房间
        PriRoom:getInstance():showPopWait()
        PriRoom:getInstance():getNetFrame():onCreateRoom()
    elseif TAG_ENUM.MENU_DROPDOWN_1 == tag then
        self.m_maskDropDown1:setVisible(true)
        -- 更新箭头
        self.m_btnDropArrow1:loadTextureDisabled(dropDownUpBtnPic.up)
        self.m_btnDropArrow1:loadTextureNormal(dropDownUpBtnPic.up)
        self.m_btnDropArrow1:loadTexturePressed(dropDownUpBtnPic.up_press)
    elseif TAG_ENUM.MASK_DROPDOWN_1 == tag then
        self.m_maskDropDown1:setVisible(false)
        -- 更新箭头
        self.m_btnDropArrow1:loadTextureDisabled(dropDownUpBtnPic.down)
        self.m_btnDropArrow1:loadTextureNormal(dropDownUpBtnPic.down)
        self.m_btnDropArrow1:loadTexturePressed(dropDownUpBtnPic.down_press)
    elseif TAG_ENUM.MENU_DROPDOWN_2 == tag then
        self.m_maskDropDown2:setVisible(true)
        -- 更新箭头
        self.m_btnDropArrow2:loadTextureDisabled(dropDownUpBtnPic.up)
        self.m_btnDropArrow2:loadTextureNormal(dropDownUpBtnPic.up)
        self.m_btnDropArrow2:loadTexturePressed(dropDownUpBtnPic.up_press)
    elseif TAG_ENUM.MASK_DROPDOWN_2 == tag then
        self.m_maskDropDown2:setVisible(false)
        -- 更新箭头
        self.m_btnDropArrow2:loadTextureDisabled(dropDownUpBtnPic.down)
        self.m_btnDropArrow2:loadTextureNormal(dropDownUpBtnPic.down)
        self.m_btnDropArrow2:loadTexturePressed(dropDownUpBtnPic.down_press)
    end
end

function PriRoomCreateLayer:onSelectedScoreEvent(tag, sender)
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
    self.m_nSelectScore = self.m_scoreList[self.m_nSelectScoreIdx - CBT_RULEBEGIN]
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
    mask:setTag(TAG_ENUM.TAG_MASK)
    mask:addTouchEventListener( touchFunC )

    -- 底板
    local spbg = csbNode:getChildByName("sp_bg")
    self.m_spBg = spbg

    -- 关闭
    local btn = spbg:getChildByName("btn_close")
    btn:setTag(TAG_ENUM.BTN_CLOSE)
    btn:addTouchEventListener( touchFunC )
    btn:setPressedActionEnabled(true)

    -- 进入
    btn = spbg:getChildByName("btn_entergame")
    btn:setTag(TAG_ENUM.BTN_ENTERGAME)
    btn:addTouchEventListener( touchFunC )
    btn:setPressedActionEnabled(true)

    -- 房间id
    local roomid = tonumber(self._param.szRoomID or "0")
    spbg:getChildByName("txt_roomid"):setString(string.format("%06d", roomid))

    -- 消耗钻石
    local consume = self._param.lDiamondFee or 0
    spbg:getChildByName("txt_consume"):setString(consume .. "")

    -- 局数
    local ncount = self._param.dwDrawCountLimit or 0
    spbg:getChildByName("txt_jushu"):setString(ncount .. "局")
    local buffer = self._param.buffer
    if nil ~= buffer and nil ~= buffer.readbyte then
        -- 读底分
        local lscore = buffer:readbyte()
        -- 玩法
        spbg:getChildByName("txt_wanfa"):setString(lscore .. "")
    end
    self:scaleTransitionIn(spbg)
end

function PriRoomAAPayLayer:onButtonClickedEvent( tag,sender )
    if tag == TAG_ENUM.TAG_MASK or tag == TAG_ENUM.BTN_CLOSE then
        -- 断开
        PriRoom:getInstance():closeGameSocket()

        self:scaleTransitionOut(self.m_spBg)
    elseif tag == TAG_ENUM.BTN_ENTERGAME then
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