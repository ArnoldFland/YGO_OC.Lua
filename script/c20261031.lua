--混沌时空 美丽（Tiferet）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--Pendulum attribute
	aux.EnablePendulumAttribute(c)
	--①(永续)：在灵摆区域存在时，自己只能召唤·特殊召唤「混沌时空」怪兽，这个效果不会被无效化
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
	--①(起动)：从卡组把「混沌时空」卡任意数量送去墓地（同名卡最多1张），特殊召唤1只等级相同的「混沌时空」灵摆怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.pencost)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	--①：召唤成功时，从卡组把「混沌时空 美丽」以外的1张「混沌时空」卡送去墓地
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.m1tg)
	e4:SetOperation(s.m1op)
	c:RegisterEffect(e4)
	--①：特殊召唤成功时
	local e4b=Effect.CreateEffect(c)
	e4b:SetDescription(aux.Stringid(id,1))
	e4b:SetCategory(CATEGORY_TOGRAVE)
	e4b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4b:SetProperty(EFFECT_FLAG_DELAY)
	e4b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4b:SetCountLimit(1,id+1)
	e4b:SetTarget(s.m1tg)
	e4b:SetOperation(s.m1op)
	c:RegisterEffect(e4b)
	--②：被送去额外卡组的场合（灵摆怪兽从场上送去墓地的场合改为送去额外卡组）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_DECK)
	e5:SetCountLimit(1)
	e5:SetCondition(s.m2con_extra)
	e5:SetTarget(s.m2tg)
	e5:SetOperation(s.m2op)
	c:RegisterEffect(e5)
	--②：被送去墓地的场合（从手卡·卡组送去墓地）
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1)
	e6:SetCondition(s.m2con_grave)
	e6:SetTarget(s.m2tg)
	e6:SetOperation(s.m2op)
	c:RegisterEffect(e6)
end

--召唤·特殊召唤限制（永续）
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x986)
end

--发动限制：不是「混沌时空」卡不能把效果发动
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x986)
end

--灵摆①：cost
function s.cfilter(c)
	return c:IsSetCard(0x986) and c:IsAbleToGraveAsCost()
end
function s.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,g:GetCount())
	if sg and #sg>0 then
		local ct=Duel.SendtoGrave(sg,REASON_COST)
		e:SetLabel(ct)
	else
		e:SetLabel(0)
	end
end

--灵摆①：target
function s.spfilter(c,e,tp,n)
	return c:IsSetCard(0x986) and c:IsType(TYPE_PENDULUM) and c:GetLevel()==n
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local n=e:GetLabel()
	if chk==0 then
		return n>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,n)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--灵摆①：operation
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local n=e:GetLabel()
	if n<=0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,n)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
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

--怪①
function s.m1filter(c)
	return c:IsSetCard(0x986) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.m1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.m1filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.m1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.m1filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
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

--怪②：条件
function s.m2fieldfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x986)
end
function s.m2fieldchk(tp)
	return Duel.IsExistingMatchingCard(s.m2fieldfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.m2con_extra(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and s.m2fieldchk(tp)
end
function s.m2con_grave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and s.m2fieldchk(tp)
end

--怪②：target
function s.setfilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(false)
end
function s.placefilter(c)
	return c:IsSetCard(0x986) and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsForbidden()
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and (Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
				or Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_DECK,0,1,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end

--怪②：operation
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_DECK,0,1,nil)
	if not b1 and not b2 then return end
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end
