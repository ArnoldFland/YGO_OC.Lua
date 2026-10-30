--混沌时空 不存在（Chaosapeiron Ayin）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--只有1张能在场
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetCondition(s.uniquecon)
	c:RegisterEffect(e0)
	--①：自己场上的混沌时空灵摆怪兽不受对方陷阱卡效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE+LOCATION_PZONE,0)
	e1:SetTarget(s.immfilter)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--②：1回合1次，破坏自己1只怪兽，对方场上1张卡回卡组（或夺控制权）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end

function s.uniquecon(e)
	return Duel.IsExistingMatchingCard(s.uniquechk,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e:GetHandler())
end
function s.uniquechk(c,ec)
	return c:IsCode(ec:GetCode()) and c~=ec
end

--①不受陷阱影响
function s.immfilter(e,c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM)
end
function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_TRAP)
end

--②
function s.costfilter(c)
	return c:IsFaceup() and c:IsDestructable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Destroy(g,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsOnField,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsOnField,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.chaos12filter(c)
	return c:IsFaceup() and c:IsSetCard(0x986) and c:IsLevelAbove(12)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local bcontrol = tc:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.chaos12filter,tp,LOCATION_MZONE,0,1,nil)
	if bcontrol and Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1 then
		Duel.GetControl(tc,tp)
	else
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
