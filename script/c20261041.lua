--混沌时空 王冠（Keter）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--同调召唤条件：「混沌时空」同调+包含光属性同调调整的怪兽2只以上
	aux.AddSynchroProcedure(c,s.tunerfilter,2,99,s.matcheck)
	c:EnableReviveLimit()
	--同调召唤时可把对方场上最多1只怪兽作为素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(0,0xff)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e0:SetValue(s.synmatval)
	c:RegisterEffect(e0)
	--①：同调召唤的这张卡在怪兽区，对方怪兽只能攻击这张卡，不能把混沌时空卡作为效果对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.attlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.immfilter)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--②：同调召唤成功时，双方卡组顶堆10
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.m2con)
	e3:SetTarget(s.m2tg)
	e3:SetOperation(s.m2op)
	c:RegisterEffect(e3)
	--③：双方主要阶段，双方墓地合计10张回卡组，对方怪兽攻守变0
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(s.m3con)
	e4:SetTarget(s.m3tg)
	e4:SetOperation(s.m3op)
	c:RegisterEffect(e4)
	--④：连锁2以后，双方墓地合计10张回卡组（cost），无效并破坏连锁上对方全部发动
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e5:SetCost(s.m4cost)
	e5:SetCondition(s.m4con)
	e5:SetTarget(s.m4tg)
	e5:SetOperation(s.m4op)
	c:RegisterEffect(e5)
end

function s.tunerfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER)
end
function s.matcheck(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x986)
end
function s.synmatval(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end

--①
function s.attlimit(e,c)
	return c~=e:GetHandler()
end
function s.immfilter(e,c)
	return c:IsSetCard(0x986)
end
function s.immval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

--②
function s.m2con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.m2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,10) and Duel.IsPlayerCanDiscardDeck(1-tp,10) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,10)
end
function s.extra_splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT))
end
function s.m2op(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,10,REASON_EFFECT)
	Duel.DiscardDeck(1-tp,10,REASON_EFFECT)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.extra_splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--③
function s.m3con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.todeckfilter(c)
	return c:IsAbleToDeck()
end
function s.m3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.todeckfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return g:GetCount()>=10 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,10,PLAYER_ALL,LOCATION_GRAVE)
end
function s.m3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.todeckfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,10,10,nil)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		--对方场上怪兽攻守变0
		local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		for oc in aux.Next(og) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			oc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			oc:RegisterEffect(e2)
		end
	end
end

--④
function s.m4con(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()<2 then return false end
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
function s.m4cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.todeckfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return g:GetCount()>=10 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,10,10,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.m4tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsOnField() and tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	if dg:GetCount()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
	end
end
function s.m4op(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.Destroy(dg,REASON_EFFECT)
end
