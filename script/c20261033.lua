--混沌时空 仁爱（Chesed）
local s,id=GetID()
local GEVURAH=20261032
function s.initial_effect(c)
	aux.AddCodeList(c,GEVURAH)
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
	--①(起动)：解放1只混沌时空怪兽，特召这张卡；另一刻度有「严厉」时改为从卡组顶堆2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.ptg)
	e3:SetOperation(s.pop)
	c:RegisterEffect(e3)
	--怪兽①：堆3特召调整，同调时可用对方1只怪兽当素材
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetCost(s.m1cost)
	e4:SetTarget(s.m1tg)
	e4:SetOperation(s.m1op)
	c:RegisterEffect(e4)
	--怪兽②：额外卡组·墓地存在，场上有混沌时空同调时，回手，选1个效果
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e5:SetCountLimit(1,id+2)
	e5:SetCondition(s.m2con)
	e5:SetTarget(s.m2tg)
	e5:SetOperation(s.m2op)
	c:RegisterEffect(e5)
end

--召唤·特殊召唤限制
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x986)
end

--发动限制
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x986)
end

--同调素材：只有自己（这张卡的操控者）的同调召唤能用对方怪兽
function s.synmatval(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end

--灵摆①
function s.ptfilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end
function s.gev_chk(e,tp)
	local c=e:GetHandler()
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local other
	if lpz==c then other=rpz else other=lpz end
	return other~=nil and other:IsCode(GEVURAH)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ptfilter(chkc) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.ptfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	Duel.SelectTarget(tp,s.ptfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local btribute=true
	if s.gev_chk(e,tp) and Duel.IsPlayerCanDiscardDeck(tp,2) then
		--有严厉时可选：解放 或 堆2
		local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		if opt==1 then btribute=false end
	end
	if btribute then
		if tc and tc:IsRelateToEffect(e) and tc:IsReleasable() then
			Duel.Release(tc,REASON_EFFECT)
		end
	else
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
	--特召这张卡
	if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
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

--怪兽①
function s.m1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.DiscardDeck(tp,3,REASON_COST)
end
function s.tunerfilter(c,e,tp)
	return c:IsSetCard(0x986) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.m1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tunerfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.m1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		--同调时对方场上1只怪兽可作为素材（视为4星）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,0xff)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
		e1:SetValue(s.synmatval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,0xff)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
		e2:SetValue(4)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
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

--怪兽②
function s.synfieldfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x986) and c:IsType(TYPE_SYNCHRO)
end
function s.m2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.synfieldfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.IsPlayerCanDiscardDeck(1-tp,3)
	Duel.SendtoHand(c,nil,REASON_EFFECT)
	if not b1 and not b2 then return end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		--夺取对方1只怪兽控制权，限制+当作混沌时空
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.GetControl(tc,tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_ADD_SETCODE)
			e4:SetValue(0x986)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
		end
	else
		--双方卡组顶堆3
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
		Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	end
end
