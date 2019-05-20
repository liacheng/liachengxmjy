local GameLogic = {}

--点数类型
GameLogic.CARD_ERROR        = 0                     --错误类型
GameLogic.CARD_POINT        = 1                     --点数类型
GameLogic.CARD_SPECIAL_1    = 2                     --二八=2-8
GameLogic.CARD_SPECIAL_2    = 3                     --对子
GameLogic.CARD_SPECIAL_3    = 4                     --白板对子

--大小排序   白板对>对子>二八>点数

--排序类型
GameLogic.HJ_ST_VALUE = 1							--数值排序
GameLogic.HJ_ST_LOGIC = 2							--逻辑排序

-- 获取牌值(1-15)
function GameLogic.GetCardValue(nCardData)
    return yl.POKER_VALUE[nCardData]
end

--获得牌的逻辑值
function GameLogic:GetCardLogicValue( cbCardData )		
    if cbCardData == 16 then 
        return 10 
    end
    return cbCardData 
end

--获取牌点
function GameLogic:GetCardListPip( cbCardData )
	local cbCount = #cbCardData
	local cbPipCount = 0
	local cbCardValue = 0
    local isWhite = false
	for i=1,cbCount do
		cbCardValue = self:GetCardLogicValue(cbCardData[i])
        if cbCardValue == 10 then 
            isWhite = true
        end
		local addvalue = cbCardValue == 10 and 0.5 or cbCardValue
		cbPipCount = cbPipCount + addvalue
	end
    if cbPipCount >= 10 then
        return cbPipCount -10 ,isWhite
    else
        return cbPipCount ,isWhite
    end
	--return math.mod(cbPipCount, 10)
end

--逻辑值排序
function GameLogic:SortCardList( cbCardData, cbCardCount, cbSortType)
	if cbCardCount == 0 then
		return
	end
	local cbSortValue = {}
	if cbSortType == self.HJ_ST_VALUE then
		for i=1,cbCardCount do
        	local value = self.GetCardValue(cbCardData[i])
        	table.insert(cbSortValue, i, value)
    	end
    else
    	for i=1,cbCardCount do
        	local value = self:GetCardLogicValue(cbCardData[i])
        	table.insert(cbSortValue, i, value)
    	end
	end
	--排序操作
    table.sort(cbSortValue,function(a,b)
        return a > b
    end)
    return cbSortValue
end

--获取类型
function GameLogic:GetCardType( cbCardData, cbCardCount)
	if cbCardCount ~= 2 then
		return self.CARD_ERROR
	end
	local cbSortValue = clone(cbCardData)
	cbSortValue = self:SortCardList(cbCardData, cbCardCount, self.HJ_ST_LOGIC)
    --获取点数
    local cbFirstCardValue = self.GetCardValue(cbSortValue[1])
    local cbSecondCardValue = self.GetCardValue(cbSortValue[2])
    
    if cbFirstCardValue == cbSecondCardValue then 
        if cbFirstCardValue == 10 then 
            return self.CARD_SPECIAL_3
        else
            return self.CARD_SPECIAL_2
        end 
    end
    if cbFirstCardValue == 8 and cbSecondCardValue == 2 then 
        return self.CARD_SPECIAL_1
    end

    return self.CARD_POINT
end

-- first > next  返回 -1
-- first < next  返回 1
-- first == next 返回 0
function GameLogic:CompareCard(cbFirstCardData, cbNextCardData)
	local cbFirstCount = #cbFirstCardData
	if cbFirstCount ~= 2 then
		return 0
	end
	local cbNextCount = #cbNextCardData
	if cbNextCount ~= 2 then
		return 0
	end

	--获取牌型
	local cbFirstCardType = self:GetCardType(cbFirstCardData, cbFirstCount)
	local cbNextCardType = self:GetCardType(cbNextCardData, cbNextCount)

	--牌型比较
	if cbFirstCardType ~= cbNextCardType then           --牌型不同
		if cbNextCardType > cbFirstCardType then
			return 1
		else
			return -1
		end
    else                                                --牌型相同
        local cbFirstCardDataTmp, cbNextCardDataTmp = {}
	    cbFirstCardDataTmp = clone(cbFirstCardData)
	    cbNextCardDataTmp = clone(cbNextCardData)
	    cbFirstCardDataTmp = self:SortCardList(cbFirstCardDataTmp, cbFirstCount, self.HJ_ST_LOGIC)
	    cbNextCardDataTmp = self:SortCardList(cbNextCardDataTmp, cbNextCount, self.HJ_ST_LOGIC)
        if cbFirstCardType ==  GameLogic.CARD_POINT  then               --点数牌型
            --获取点数  
	        local cbFirstPip = self:GetCardListPip(cbFirstCardDataTmp)
	        local cbNextPip = self:GetCardListPip(cbNextCardDataTmp)
            if cbFirstPip ~= cbNextPip then                             --点数不同         
		        if cbNextPip > cbFirstPip then
			        return 1                   
                else
                    return -1
		        end
            else                                                        --点数相同
                if cbNextCardDataTmp[1] > cbFirstCardDataTmp[1] then 
                    return  1
                elseif cbNextCardDataTmp[1] == cbFirstCardDataTmp[1] then 
                    return  0
                elseif cbNextCardDataTmp[1] < cbFirstCardDataTmp[1] then 
			        return -1
                end
	        end
        elseif cbFirstCardType ==  GameLogic.CARD_SPECIAL_1  then       --二八牌型
            return 0 
        elseif cbFirstCardType ==  GameLogic.CARD_SPECIAL_2  then       --对子牌型
            if cbNextCardDataTmp[1] > cbFirstCardDataTmp[1] then 
                return  1
            elseif cbNextCardDataTmp[1] == cbFirstCardDataTmp[1] then 
                return  0
            elseif cbNextCardDataTmp[1] < cbFirstCardDataTmp[1] then 
			    return -1
            end
        elseif cbFirstCardType ==  GameLogic.CARD_SPECIAL_3  then       --白板对子牌型
            return 0
        end
	end
end
return GameLogic