--混沌时空 严厉（Gevurah）
local s,id=GetID()
local CHESED=20261033
function s.initial_effect(c)
	aux.AddCodeList(c,CHESED)
	--Pendulum attribute
	aux.EnablePendulumAttribute(c)
	--①(永续)：灵摆区域存在时，自己只能召唤·特殊召唤「混沌时空」怪兽，这个效果不会被无效化
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
	--①(起动)：从卡组选1只「混沌时空」灵摆怪兽放置；那之后破坏这张卡；另一刻度有「仁爱」时改为特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.ptg)
	e3:SetOperation(s.pop)
	c:RegisterEffect(e3)
	--怪兽：这张卡召唤·特殊召唤的回合，自己不是「混沌时空」卡不能把效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(s.sumresop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--怪兽①：同调召唤
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetTarget(s.syntg)
	e6:SetOperation(s.synop)
	c:RegisterEffect(e6)
	--怪兽②：额外卡组·墓地存在时，回卡组底，选1个效果
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e7:SetCountLimit(1,id+2)
	e7:SetCondition(s.m2con)
	e7:SetTarget(s.m2tg)
	e7:SetOperation(s.m2op)
	c:RegisterEffect(e7)
end

--召唤·特殊召唤限制
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x986)
end

--发动限制
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x986)
end

--召唤回合限制：注册本回合的发动限制
function s.sumresop(e,tp,eg,ep,ev,re,r,rp)
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

--灵摆①
function s.pfilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id) and not c:IsForbidden()
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--找另一边的灵摆区域
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local other
	if lpz==c then other=rpz else other=lpz end
	local bchesed=other~=nil and other:IsCode(CHESED)
	--决定这张卡去向：另一刻度有仁爱→特召；否则破坏
	if bchesed and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
	--从卡组放1只到空出的灵摆区域
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
	--这个回合自己不是「混沌时空」卡不能把效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--怪兽①：同调召唤（这张卡 + 卡组的非调整「混沌时空」，等级合计直到8）
function s.ntfilter(c)
	return c:IsSetCard(0x986) and not c:IsType(TYPE_TUNER) and c:IsCanBeSynchroMaterial()
end
function s.synfilter(c,mg)
	return c:IsSetCard(0x986) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(8)
		and c:IsSynchroSummonable(nil,mg)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.ntfilter,tp,LOCATION_DECK,0,c)
	mg:AddCard(c)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.extra_splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x986)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.ntfilter,tp,LOCATION_DECK,0,c)
	mg:AddCard(c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
	local sc=sg:GetFirst()
	if sc then
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
	--这个回合自己不是「混沌时空」怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.extra_splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--怪兽②
function s.chaosfieldfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x986)
end
function s.m2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.chaosfieldfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.optA_filter(c)
	return c:IsFaceup()
end
function s.optB_filter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.IsExistingMatchingCard(s.optA_filter,tp,LOCATION_MZONE,0,1,nil)
	local b2=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.optB_filter,tp,LOCATION_GRAVE,0,1,nil)
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
		--选自己场上1只怪兽当调整
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.optA_filter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		--选自己墓地1只混沌时空灵摆怪兽放置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.optB_filter,tp,LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
