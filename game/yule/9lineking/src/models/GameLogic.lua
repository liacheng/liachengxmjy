local GameLogic = GameLogic or {}

--数目定义
GameLogic.ITEM_COUNT 				= 14            -- 图标数量
GameLogic.ITEM_X_COUNT				= 5				-- 图标横坐标数量
GameLogic.ITEM_Y_COUNT				= 3				-- 图标纵坐标数量
GameLogic.LINE_COUNT                = 9				-- 压线数量
--逻辑类型
GameLogic.CT_YINGTAO                = 0				-- 樱桃
GameLogic.CT_PINGGUO                = 1				-- 苹果
GameLogic.CT_XIANGJIAO              = 2				-- 香蕉
GameLogic.CT_JUZI                   = 3				-- 橘子
GameLogic.CT_BOLUO                  = 4				-- 菠萝
GameLogic.CT_XIGUA                  = 5				-- 西瓜
GameLogic.CT_PUTAO			        = 6				-- 葡萄
GameLogic.CT_LIZHI			        = 7				-- 荔枝
GameLogic.CT_CAOMEI			        = 8				-- 草莓
GameLogic.CT_SHANZHU                = 9				-- 山竹
GameLogic.CT_777			        = 10            -- 777
GameLogic.CT_BAR			        = 11            -- bar
GameLogic.CT_ZUANSHI                = 12            -- 钻石
GameLogic.CT_BAOXIANG               = 13            -- 宝箱

-- 可能中奖的位置线
GameLogic.m_ptXian = {}
GameLogic.m_ptXian[1] = {{x=2,y=1},{x=2,y=2},{x=2,y=3},{x=2,y=4},{x=2,y=5}} -- 第一条线 直线
GameLogic.m_ptXian[2] = {{x=1,y=1},{x=1,y=2},{x=1,y=3},{x=1,y=4},{x=1,y=5}}	-- 第二条线 直线
GameLogic.m_ptXian[3] = {{x=3,y=1},{x=3,y=2},{x=3,y=3},{x=3,y=4},{x=3,y=5}}	-- 第三条线 直线
GameLogic.m_ptXian[4] = {{x=1,y=1},{x=2,y=2},{x=3,y=3},{x=2,y=4},{x=1,y=5}}	-- 第四条线 v
GameLogic.m_ptXian[5] = {{x=3,y=1},{x=2,y=2},{x=1,y=3},{x=2,y=4},{x=3,y=5}}	-- 第五条线 倒v
GameLogic.m_ptXian[6] = {{x=1,y=1},{x=1,y=2},{x=2,y=3},{x=3,y=4},{x=3,y=5}}	-- 第六条线 
GameLogic.m_ptXian[7] = {{x=3,y=1},{x=3,y=2},{x=2,y=3},{x=1,y=4},{x=1,y=5}} -- 第七条线 
GameLogic.m_ptXian[8] = {{x=2,y=1},{x=1,y=2},{x=2,y=3},{x=3,y=4},{x=2,y=5}} -- 第八条线 
GameLogic.m_ptXian[9] = {{x=2,y=1},{x=3,y=2},{x=2,y=3},{x=1,y=4},{x=2,y=5}} -- 第九条线 
----------------------------------------------------------
-- 判断是否全屏奖
function GameLogic:GetZhongJiangAll(cbItemInfo)
    local nTime = 0
	local bSingle = true
	local ptFirstIndex = {x=0xFF,y=0xFF}

	for i=1,GameLogic.ITEM_Y_COUNT do
		for j=1,GameLogic.ITEM_X_COUNT do
			if ptFirstIndex.x == 0xFF then
				ptFirstIndex.x = i
				ptFirstIndex.y = j
			elseif cbItemInfo[ptFirstIndex.x][ptFirstIndex.y] ~= cbItemInfo[i][j] then
				print("cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]",cbItemInfo[ptFirstIndex.x][ptFirstIndex.y])
				if cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]/3 ~= cbItemInfo[i][j]/3 or cbItemInfo[ptFirstIndex.x][ptFirstIndex.y] >= GameLogic.CT_TITIANXINGDAO or cbItemInfo[i][j] >= GameLogic.CT_TITIANXINGDAO then
					return 0
				end
				bSingle = false
			end
		end
	end

	if not bSingle then
		local tempType = math.floor(cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]/3)
		if  tempType == 0  then
			nTime = 15
		elseif tempType == 1 then
			nTime = 50
		else
			return 0
		end
	else
		local tempType = cbItemInfo[ptFirstIndex.x][ptFirstIndex.y]
		if tempType == GameLogic.CT_FUTOU then
			nTime = 50
		elseif tempType == GameLogic.CT_YINGQIANG then
			nTime = 100
		elseif tempType == GameLogic.CT_DADAO then
			nTime = 150
		elseif tempType == GameLogic.CT_LU then
			nTime = 250
		elseif tempType == GameLogic.CT_LIN then
			nTime = 400
		elseif tempType == GameLogic.CT_SONG then
			nTime = 500
		elseif tempType == GameLogic.CT_TITIANXINGDAO then
			nTime = 1000
		elseif tempType == GameLogic.CT_ZHONGYITANG then
			nTime = 2500
		elseif tempType == GameLogic.CT_SHUIHUZHUAN then
			nTime = 5000
		else
			return 0
		end
	end
	return nTime
end

-- 取得中奖分数
function GameLogic:GetZhongJiangTime(nLineType, nLineCount)
    if nLineType == 0xFF then
        return
    end

    local nTime = 0
	if     nLineType == GameLogic.CT_YINGTAO then
        nTime = (nLineCount == 3 and 5 or (nLineCount == 4 and 15 or 75))
	elseif nLineType == GameLogic.CT_PINGGUO then
        nTime = (nLineCount == 3 and 6 or (nLineCount == 4 and 30 or 50))
	elseif nLineType == GameLogic.CT_XIANGJIAO then
        nTime = (nLineCount == 3 and 8 or (nLineCount == 4 and 35 or 85))
	elseif nLineType == GameLogic.CT_JUZI then
        nTime = (nLineCount == 3 and 5 or (nLineCount == 4 and 40 or 90))
	elseif nLineType == GameLogic.CT_BOLUO then
        nTime = (nLineCount == 3 and 6 or (nLineCount == 4 and 20 or 100))
	elseif nLineType == GameLogic.CT_XIGUA then
        nTime = (nLineCount == 3 and 8 or (nLineCount == 4 and 20 or 150))
	elseif nLineType == GameLogic.CT_PUTAO then
        nTime = (nLineCount == 3 and 10 or (nLineCount == 4 and 20 or 200))
	elseif nLineType == GameLogic.CT_LIZHI then
        nTime = (nLineCount == 3 and 15 or (nLineCount == 4 and 25 or 250))
	elseif nLineType == GameLogic.CT_CAOMEI then
        nTime = (nLineCount == 3 and 20 or (nLineCount == 4 and 50 or 300))
	elseif nLineType == GameLogic.CT_SHANZHU then
        nTime = (nLineCount == 3 and 50 or (nLineCount == 4 and 200 or 2000))
	elseif nLineType == GameLogic.CT_777 then
        nTime = (nLineCount == 3 and 1000 or (nLineCount == 4 and 3000 or 5000))
	elseif nLineType == GameLogic.CT_BAR then
        nTime = (nLineCount == 2 and 5 or (nLineCount == 3 and 100 or ((nLineCount == 4 and 900 or 6000))))
	elseif nLineType == GameLogic.CT_ZUANSHI then
        nTime = (nLineCount == 3 and 9 or (nLineCount == 4 and 18 or 36))
	elseif nLineType == GameLogic.CT_BAOXIANG then
        nTime = (nLineCount == 3 and 10 or (nLineCount == 4 and 30 or 50))
	end

	return nTime
end

-- 单线中奖
function GameLogic:GetZhongJiangXian(cbItemInfo, cbIndex, ptZhongJiang)
	local ptXian = GameLogic.m_ptXian[cbIndex]
	local ItemXCount = GameLogic.ITEM_X_COUNT                   -- 横向个数
	local nLinkCount = 1                                        -- 连线数量
	local nLinkType  = cbItemInfo[ptXian[1].x][ptXian[1].y]     -- 起始下标
	local nRetrunCount = 0                                      -- 数量
    local nReturnType  = 0xFF                                   -- 类型
	local nReturnTime  = 0                                      -- 倍率

	for i = 1, ItemXCount do
		ptZhongJiang[i] = {}
		ptZhongJiang[i].x = 0xFF
		ptZhongJiang[i].y = 0xFF
	end

	--中奖线
    local curType = 0xFF
	for i = 2, ItemXCount do
        curType = cbItemInfo[ptXian[i].x][ptXian[i].y]
        if (curType == nLinkType or (curType == GameLogic.CT_BAR and nLinkType ~= GameLogic.CT_777 and nLinkType ~= GameLogic.CT_ZUANSHI and nLinkType ~= GameLogic.CT_BAOXIANG)) then
            nLinkCount = nLinkCount+1
        else
            break
        end
	end

	if nLinkCount >= 3 or (nLinkCount >= 2 and nLinkType == GameLogic.CT_BAR) then
		for i = 1, nLinkCount do
			ptZhongJiang[i].x = ptXian[i].x
			ptZhongJiang[i].y = ptXian[i].y
		end
		nRetrunCount = math.min(5, nLinkCount)
        nReturnType  = nLinkType
        nReturnTime  = self:GetZhongJiangTime(nReturnType, nRetrunCount)
	end
    
	return nReturnType, nRetrunCount, nReturnTime
end

-----------------------------------------------------------------------------------

-- 拷贝表
function GameLogic:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
 end


return GameLogic