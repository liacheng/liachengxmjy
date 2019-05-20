
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local module_pre = "game.yule.baccaratnew.src"
local BankLayer=class("BankLayer",cc.Layer)

BankLayer.BT_GIVEMIN 		= 1
BankLayer.BT_GIVEMAX 		= 2
BankLayer.BT_TRANSFER		= 3
BankLayer.BT_CLOSE			= 4

function BankLayer:ctor(parentNode)
	self._parentNode=parentNode
	self.csbNode=ExternalFun.loadCSB("game/BankLayer.csb",self)   
    self.bg=appdf.getNodeByName(self.csbNode,"bg")
	self.curCoinLabel = self.bg:getChildByName("m_pTextMyScore")
    self.insureLabel = self.bg:getChildByName("m_pTextMyBank")
    self.m_textTips = self.bg:getChildByName("m_textTips")
    self.m_pTakeMoney = self.bg:getChildByName("img_take")
    self.m_pTakePassWord = self.bg:getChildByName("img_pw")
     --金额输入
    local editHanlder = function(event,editbox)
		self:onEditEvent(event,editbox)
	end
	self.text_GiveScore = ccui.EditBox:create(cc.size(605,30),"")
		:move(430,31)
		--:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(25)
		:setPlaceholderFontSize(25)
		:setMaxLength(13)
		:setFontColor(cc.c4b(255,255,255,255))
		:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
		:setPlaceHolder("输入取款金额")
        :setTag(1)
		:addTo(self.m_pTakeMoney)
	self.text_GiveScore:registerScriptEditBoxHandler(editHanlder)

	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(605,60), "")
		:move(430,31)
		:setFontName(appdf.FONT_FILE)
		:setPlaceholderFontName(appdf.FONT_FILE)
		:setFontSize(25)
		:setPlaceholderFontSize(25)
		:setMaxLength(10)
		:setFontColor(cc.c4b(255,255,255,255))
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder("输入取款密码")
        :setTag(2)
		:addTo(self.m_pTakePassWord)
    --金额
    self.text_GiveFormatScore = self.bg:getChildByName("txt_synchroscore")
    --滑动百分比
    self._silderValueGive = self.bg:getChildByName("panel_middle"):getChildByName("txt_middle")
    --滑动条
    self._silderGive = self.bg:getChildByName("Slider")
    self._silderGive:setPercent(0)
    self:setGiveSilder()
    local function silder_changed(Ref, EventType)
        if EventType == ccui.SliderEventType.percentChanged then
            self:setGiveSilder()
        end
    end
    self._silderGive:addEventListener(silder_changed)
    --最大最小按钮
    local function btncallback(ref, type)
        ExternalFun.btnEffect(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end 
    self._btnGiveMin = self.bg:getChildByName("btn_min")
        :setTag(BankLayer.BT_GIVEMIN)
        :addTouchEventListener(btncallback)
    self._btnGiveMax = self.bg:getChildByName("btn_max")
        :setTag(BankLayer.BT_GIVEMAX)
        :addTouchEventListener(btncallback)
    self._btnTransfer = self.bg:getChildByName("Button_2")
        :setTag(BankLayer.BT_TRANSFER)
        :addTouchEventListener(btncallback)
    self._btnClose = self.bg:getChildByName("Button_1")
         :setTag(BankLayer.BT_CLOSE)
         :addTouchEventListener(btncallback)
    self.bgShade=appdf.getNodeByName(self.csbNode,"Button_Shade")
        :setVisible(false)
	self._parentNode:getParent():sendRequestBankInfo()

    ExternalFun.showLayer(self, self, true, true,self.bg,false)
end

--输入框监听
function BankLayer:onEditEvent(event,editbox)
    if editbox:getTag() == 2 then
        return
    end
    local score = string.gsub(editbox:getText(),"([^0-9])","")

    if event == "return" then 
        if score == "" then 
            editbox:setText(score)
            return 
        end
        if tonumber(score) > GlobalUserItem.lUserInsure then
            score = GlobalUserItem.lUserInsure          
        end
        editbox:setText(tonumber(score))
    elseif event == "changed" then   
        if score == "" or score == "0" or GlobalUserItem.lUserInsure == 0 then
            score = 0
            self.text_GiveFormatScore:setString("")
            self._silderValueGive:setString(score.."%")
            self._silderGive:setPercent(score)
            return 
        else
            if tonumber(score) > GlobalUserItem.lUserInsure then
                score = GlobalUserItem.lUserInsure          
            end
            local value = math.ceil(score/GlobalUserItem.lUserInsure*100)
            self._silderValueGive:setString(value.."%")
            self._silderGive:setPercent(value)
            --self:setGiveSilder()
        end
    end
end

function BankLayer:setGiveSilder()
    local value = self._silderGive:getPercent()
    self._silderValueGive:setString(value.."%")
    local score = math.floor(GlobalUserItem.lUserInsure*(value/100)) 
    self.text_GiveScore:setText(""..score)
    if score ~= 0 then 
        self.text_GiveFormatScore:setString("("..ExternalFun.numberTransiform(score)..")")
    else
        self.text_GiveFormatScore:setString("")
    end
end

function BankLayer:onButtonClickedEvent(tag,sender)
    if tag == BankLayer.BT_TRANSFER then
        self:onTakeScore()
    elseif tag ==  BankLayer.BT_CLOSE then
        ExternalFun.playClickEffect()
        ExternalFun.hideLayer(self, self, false)
    elseif tag == BankLayer.BT_GIVEMIN then
        self._silderGive:setPercent(1)
        self:setGiveSilder()
    elseif tag == BankLayer.BT_GIVEMAX then
        self._silderGive:setPercent(100)
        self:setGiveSilder()
    end
end

--取款
function BankLayer:onTakeScore()

    --参数判断
    local szScore = string.gsub(self.text_GiveScore:getText(),"([^0-9])","")
    local szPass = self.edit_Password:getText()
    if tonumber(szScore) == 0  or szScore == "" then
        showToast(cc.Director:getInstance():getRunningScene(),"请输入正确金额！",2)
        return
    end
    if #szPass < 1 then 
        showToast(cc.Director:getInstance():getRunningScene(),"请输入保险柜密码！",2)
        return
    end
    if #szPass <6 then
        showToast(cc.Director:getInstance():getRunningScene(),"密码必须大于6个字符，请重新输入！",2)
        return
    end

    self._parentNode:getParent():sendTakeScore(szScore,szPass)
end

--刷新银行游戏币
function BankLayer:refreshBankScore( )
    --携带游戏币
    local str = ""..GlobalUserItem.tabAccountInfo.lUserScore
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.curCoinLabel:setString(str)

    --银行存款
    str = GlobalUserItem.tabAccountInfo.lUserInsure..""
    if string.len(str) > 19 then
        str = string.sub(str, 1, 19)
    end
    self.insureLabel:setString(str)

    self.text_GiveScore:setText("")
    self.edit_Password:setText("")
end
------

--银行操作成功
function BankLayer:onBankSuccess( )
    local bank_success = self._parentNode:getParent().bank_success
    if nil == bank_success then
        return
    end

    self:refreshBankScore()

    showToast(cc.Director:getInstance():getRunningScene(), bank_success.szDescribrString, 2)
end

--银行操作失败
function BankLayer:onBankFailure( )
    local bank_fail = self._parentNode:getParent().bank_fail
    if nil == bank_fail then
        return
    end

    showToast(cc.Director:getInstance():getRunningScene(), bank_fail.szDescribeString, 2)
end

--银行资料
function BankLayer:onGetBankInfo(bankinfo)
    local str = ""
    if bankinfo.wRevenueTake ~= 0 and bankinfo.wRevenueTake ~= nil then
        str = "温馨提示:取款将扣除" .. bankinfo.wRevenueTake .. "‰的手续费"
    end
    self.m_textTips:setString(str)
    self.curCoinLabel:setString(GlobalUserItem.tabAccountInfo.lUserScore)
    self.insureLabel:setString(GlobalUserItem.tabAccountInfo.lUserInsure)
end
function BankLayer:onShow()
    ExternalFun.showLayer(self, self, true, true)
end
return BankLayer