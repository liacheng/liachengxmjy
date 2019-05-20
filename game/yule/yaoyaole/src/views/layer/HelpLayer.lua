--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--幫助界面
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HelpLayer = class("HelpLayer", cc.Layer)

HelpLayer.BT_CLOSE = 1
HelpLayer.RES_PATH = "game/yule/yaoyaole/res/"
function HelpLayer:ctor(scene, nKindId, nType)
    
    if nil == nKindId or nil == nType then
        return nil
    end
    self._scene = scene
    ExternalFun.registerNodeEvent(self)

    --加载csb资源
    local csbNode = ExternalFun.loadCSB(HelpLayer.RES_PATH.."game/HelpLayer.csb", self)
    local function btnEvent( sender, eventType )
        ExternalFun.btnEffect(sender, eventType)
	    if eventType == ccui.TouchEventType.ended then
		    self:onBtnClick(sender:getTag(), sender)
	    end
    end

    local csbBg = csbNode:getChildByName("m_pNodeHelp")
    ExternalFun.showLayer(self, self,true,true,csbBg,false)
    --关闭按钮
    local btn = csbBg:getChildByName("m_pBtnCloseHelp")
    btn:setTag(HelpLayer.BT_CLOSE)
    btn:addTouchEventListener(btnEvent)

    local textBg = csbBg:getChildByName("m_pIconHelpTextBg")
    -- 界面
    local tmp = textBg:getChildByName("m_pTextHelp")
    -- 读取文本
    self._scrollView = ccui.ScrollView:create()
                          :setContentSize(tmp:getContentSize())
                          :setPosition(tmp:getPosition())
                          :setAnchorPoint(tmp:getAnchorPoint())
                          :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
                          :setBounceEnabled(true)
                          :setScrollBarEnabled(false)
                          :addTo(textBg)
    tmp:removeFromParent()

    self.m_listener = cc.EventListenerCustom:create("__Introduce_http_req_Listener__",handler(self, self.onEvent))
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self)
    if nil ~= scene and type(scene.showPopWait) == "function" then
        scene:showPopWait()
    end

    --http请求规则文本信息
    local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx?action=getgameintroduce&kindid=" .. nKindId   .. "&typeid="  .. nType             
    appdf.onHttpJsionTable(url ,"GET","",function(jstable,jsdata)
        if type(jstable) == "table" then
            local data = jstable["data"]
            local msg = jstable["msg"]
            if type(data) == "table" then
                local content = data["Content"]
                if type(content) == "string" then
                    msg = nil
                    self:refreshIntroduce(content)
                    local event = cc.EventCustom:new("__Introduce_http_req_Listener__")
                    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
                end
            end
        end
        if nil ~= scene and type(scene.dismissPopWait) == "function" then
            scene:dismissPopWait()
        end
        if type(msg) == "string" and "" ~= msg then
            showToast(image_bg, msg, 2)
        end
    end)
    
    return self
end

function HelpLayer:refreshIntroduce(szTips)
    local viewSize = self._scrollView:getContentSize()
    self._strLabel = cc.Label:createWithTTF(szTips, appdf.FONT_FILE, 25)
                             :setLineBreakWithoutSpace(true)
                             :setMaxLineWidth(viewSize.width)
                             :setTextColor(cc.c4b(255,255,255,255))
                             :setAnchorPoint(cc.p(0.5, 1.0))
                             :addTo(self._scrollView)
    local labelSize = self._strLabel:getContentSize()
    local fHeight = labelSize.height > viewSize.height and labelSize.height or viewSize.height
    self._strLabel:setPosition(cc.p(viewSize.width * 0.5, fHeight))
    self._scrollView:setInnerContainerSize(cc.size(viewSize.width, labelSize.height))
end

function HelpLayer:onEvent(event)
    if nil ~= self.m_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_listener)
        self.m_listener = nil
    end
end

function HelpLayer:onBtnClick(tag, sender)
	if HelpLayer.BT_CLOSE == tag then
        ExternalFun.hideLayer(self, self, false)
	end
end

function HelpLayer:onExit()
    if nil ~= self.m_listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_listener)
        self.m_listener = nil
    end
end

function HelpLayer:onShow()
    ExternalFun.showLayer(self, self,true,true)
end

return HelpLayer