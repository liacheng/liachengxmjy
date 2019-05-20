--
-- Author: tom
-- Date: 2017-02-27 17:26:42
--
local PromptLayer = class("PromptLayer", function(scene)
	local promptLayer = display.newLayer()
	return promptLayer
end)

PromptLayer.POP_TAG_MONEY = "buyPage"
PromptLayer.POP_TAG_LEAVE = "exitPage"
local TAG_BT_CANCEL = 3
local TAG_BT_BUY = 2
local TAG_BT_EXIT = 1
local popInfo =
{
    [PromptLayer.POP_TAG_MONEY] = {image1 = "oxsixex_txt_cancel.png", image2 = "oxsixex_txt_sure.png",tag1 = TAG_BT_EXIT ,tag2 = TAG_BT_BUY },
    [PromptLayer.POP_TAG_LEAVE] = {image1 = "oxsixex_txt_exit.png", image2 = "oxsixex_txt_buy.png", tag1 = TAG_BT_CANCEL ,tag2 = TAG_BT_EXIT },
}

local cmd = appdf.req(appdf.GAME_SRC.."yule.oxsixex.src.models.CMD_Game")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

function PromptLayer:onInitData(tag,pour)
    if tag  == PromptLayer.POP_TAG_MONEY then
        self.desc = string.format("您的游戏币少于%d，不能继续游戏！",pour)
    else
        self.desc = "您正在游戏中，确定要离开吗？"
    end
end

function PromptLayer:onResetData()
end

local this
function PromptLayer:ctor(scene,tag,pour)
	this = self
	self._scene = scene
	self:onInitData(tag,pour)

	self.colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 125))
		:setContentSize(display.width, display.height)
		:addTo(self)
	self.colorLayer:setTouchEnabled(false)
	self.colorLayer:registerScriptTouchHandler(function(eventType, x, y)
		return this:onTouch(eventType, x, y)
	end)

	local funCallback = function(ref)
		this:onButtonCallback(ref:getTag(), ref)
	end
	--UI
	self._csbNode = cc.CSLoader:createNode(self._scene.RES_PATH.."game/csb/popLayer.csb")
		:addTo(self, 1)
    local desc = self._csbNode:getChildByName("desc")
        :setString(self.desc)

	local btn1 = self._csbNode:getChildByName("btn_cancel")
		:setTag(popInfo[tag].tag1)
	btn1:addClickEventListener(funCallback)
    btn1:getChildByName("img_cancel"):loadTextures(popInfo[tag].image1,popInfo[tag].image1)

    local btn2 = self._csbNode:getChildByName("btn_sure")
		:setTag(popInfo[tag].tag2)
	btn2:addClickEventListener(funCallback)
    btn2:getChildByName("img_sure"):loadTextures(popInfo[tag].image1,popInfo[tag].image2)

	self.sp_layerBg = self._csbNode:getChildByName("panel_exit")

	self:setVisible(false)
end

function PromptLayer:onButtonCallback(tag, ref)
	if tag == TAG_BT_BUY then
		print("购买")
	elseif tag == TAG_BT_CANCEL then
		print("取消")
		self:hideLayer()
	elseif tag == TAG_BT_EXIT then
		print("离开")
	end
end

function PromptLayer:onTouch(eventType, x, y)
	if eventType == "began" then
		return true
	end

	local pos = cc.p(x, y)
    local rectLayerBg = self.sp_layerBg:getBoundingBox()
    if not cc.rectContainsPoint(rectLayerBg, pos) then
    	self:hideLayer()
    end

    return true
end

function PromptLayer:showLayer()
	self.colorLayer:setTouchEnabled(true)
	self:setVisible(true)
end

function PromptLayer:hideLayer()
	self.colorLayer:setTouchEnabled(false)
	self:setVisible(false)
	self:onResetData()
end

return PromptLayer