--混沌时空 王国（Malchut）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.EnablePendulumAttribute(c)
	--灵摆永续锁
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
	--灵摆永续：攻守上升墓地混沌时空数量×100
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--不能通常召唤；解放包含3种类以上混沌时空的全部自己怪兽才能特召
	c:EnableReviveLimit()
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EFFECT_SPSUMMON_PROC)
	e6:SetRange(LOCATION_HAND)
	e6:SetCondition(s.spcon)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	--怪兽①：特召成功时，支付一半LP，解放对方全部怪兽，攻守上升
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_RELEASE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCost(s.lpcost)
	e7:SetTarget(s.rltg)
	e7:SetOperation(s.rlop)
	c:RegisterEffect(e7)
	--怪兽②：直接攻击伤害步骤结束时，除外10种类，攻守×10，追加攻击
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_BATTLE_DAMAGE)
	e8:SetCondition(s.bcon)
	e8:SetCost(s.bcost)
	e8:SetTarget(s.btg)
	e8:SetOperation(s.bop)
	c:RegisterEffect(e8)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x986)
end
function s.gyfilter(c)
	return c:IsSetCard(0x986)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroup(s.gyfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil):GetCount()*100
end

--特召条件
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if #g==0 then return false end
	local chaosg=g:Filter(Card.IsSetCard,nil,0x986)
	return chaosg:GetClassCount(Card.GetCode)>=3
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	Duel.Release(g,REASON_COST)
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	c:CompleteProcedure()
end

--怪兽①
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasable,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.Release(g,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(ct*100)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end

--怪兽②
function s.bcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and Duel.GetAttacker()==c and c:GetBattleTarget()==nil
end
function s.bfilter(c)
	return c:IsSetCard(0x986) and c:IsAbleToRemove()
end
function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.bfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(aux.dncheck,10,10) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,10,10)
	if #sg>0 then
		Duel.Remove(sg,POS_FACEDOWN,REASON_COST)
	end
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,10,tp,LOCATION_GRAVE)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(c:GetBaseAttack()*10)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(c:GetBaseDefense()*10)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EXTRA_ATTACK)
		e3:SetValue(1)
		e3:SetReset(RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e3)
	end
end
