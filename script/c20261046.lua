--混沌时空 创造（Beri'ah）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.AddSynchroProcedure(c,s.tunerfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(0,0xff)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e0:SetValue(s.synmatval)
	c:RegisterEffect(e0)
	--①：有其它混沌时空同调时，自己混沌时空卡不会被对方效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.indesfilter)
	e1:SetValue(s.indesval)
	c:RegisterEffect(e1)
	--②：同调召唤成功时，墓地5张天使·光回卡组，抽2，回复
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.m2con)
	e2:SetCost(s.m2cost)
	e2:SetTarget(s.m2tg)
	e2:SetOperation(s.m2op)
	c:RegisterEffect(e2)
end
function s.tunerfilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_TUNER)
end
function s.synmatval(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
--①
function s.otherfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x986) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
end
function s.indesfilter(e,c)
	return c:IsSetCard(0x986) and c:IsControler(e:GetHandlerPlayer())
end
function s.indesval(e,re,rp)
	return rp~=e:GetHandlerPlayer() and Duel.IsExistingMatchingCard(s.otherfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--②
function s.m2con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.m2filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckAsCost()
end
function s.m2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.m2filter,tp,LOCATION_GRAVE,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.m2filter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	if ct>0 then
		local rec=0
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		while tc do
			if tc:IsLocation(LOCATION_HAND) and tc:IsType(TYPE_MONSTER) then rec=rec+1000 end
			tc=g:GetNext()
		end
		if rec>0 then Duel.Recover(p,rec,REASON_EFFECT) end
	end
end
