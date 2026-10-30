--混沌时空 无休止（Chaosapeiron Einsof）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--只有1张能在场（同卡名不能重复发动）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetCondition(s.uniquecon)
	c:RegisterEffect(e0)
	--永续：自己也可以把墓地中的怪兽灵摆召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.pendvalue)
	c:RegisterEffect(e1)
	--①：自己场上的混沌时空灵摆怪兽不受对方魔法卡效果影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_PZONE,0)
	e2:SetTarget(s.immfilter)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--②：1回合1次，混沌时空灵摆怪兽被送去墓地时，从卡组1只混沌时空卡加手/送墓/特召
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.m2con)
	e3:SetTarget(s.m2tg)
	e3:SetOperation(s.m2op)
	c:RegisterEffect(e3)
end

function s.uniquecon(e)
	return Duel.IsExistingMatchingCard(s.uniquechk,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e:GetHandler())
end
function s.uniquechk(c,ec)
	return c:IsCode(ec:GetCode()) and c~=ec
end

--灵摆召唤墓地
function s.pendvalue(e,c)
	return c:IsLocation(LOCATION_GRAVE)
end

--①不受魔法影响
function s.immfilter(e,c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM)
end
function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end

--②
function s.gyfilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM)
end
function s.m2con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gyfilter,1,nil)
end
function s.deckfilter(c,e,tp)
	return c:IsSetCard(0x986) and (c:IsAbleToHand() or c:IsAbleToGrave() or (c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToHand()
	local b2=tc:IsAbleToGrave()
	local b3=tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local op=0
	if b1 and b2 and b3 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 and b3 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))
	elseif b2 and b3 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	elseif b2 then
		op=0
	else
		op=0
	end
	if b1 and op==0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif b2 and op==1 then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif b3 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
