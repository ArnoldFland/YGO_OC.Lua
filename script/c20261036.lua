--混沌时空 基础（Yesod）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.EnablePendulumAttribute(c)
	--①(永续)：只能召唤·特殊召唤「混沌时空」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	--①(代替)：额外·墓地特召的混沌时空怪兽被战斗·效果破坏时代替，从卡组送1只混沌时空去墓地
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	--怪兽①：召唤·特殊召唤成功时，墓地1只混沌时空灵摆特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.m1tg)
	e4:SetOperation(s.m1op)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--怪兽②：额外·墓地存在+场上有混沌时空魔陷时，回卡组底，选1个效果
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e6:SetCountLimit(1,id+2)
	e6:SetCondition(s.m2con)
	e6:SetTarget(s.m2tg)
	e6:SetOperation(s.m2op)
	c:RegisterEffect(e6)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x986)
end
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x986)
end

--灵摆①代替破坏
function s.repfilter(c,tp)
	if not (c:IsFaceup() and c:IsSetCard(0x986) and c:IsControler(tp)) then return false end
	if not (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) then return false end
	local loc=c:GetSummonLocation()
	return loc==LOCATION_EXTRA or loc==LOCATION_GRAVE
end
function s.deckfilter(c)
	return c:IsSetCard(0x986) and c:IsAbleToGrave()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK,0,1,nil)
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2))
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--怪兽①
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.m1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.m1op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--怪兽②
function s.stfilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.m2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_SZONE,0,1,nil)
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.gyretfilter(c)
	return c:IsSetCard(0x986) and c:IsAbleToDeck()
end
function s.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM)
		and not c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave()
end
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.IsExistingMatchingCard(s.gyretfilter,tp,LOCATION_GRAVE,0,3,nil)
	local b2=Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil)
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	if not b1 and not b2 then return end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.gyretfilter,tp,LOCATION_GRAVE,0,3,3,nil)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
