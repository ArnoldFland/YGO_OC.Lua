-- 星界之魔术师
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,20241028)
	-- Pendulum attribute
	aux.EnablePendulumAttribute(c)
	-- P1:Pendulum Effect bingo
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20241028,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,20241028)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	-- m1:Special Summon from hand or extra deck bingo
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20241028,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e2:SetCountLimit(1, {20241028, 1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- m2:
	-- Quick Effect for Xyz Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MSET+TIMING_STANDBY_PHASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,20241028+EFFECT_COUNT_CODE_DUEL)
	e3:SetCost(aux.spcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(s,ACTIVITY_SPSUMMON,s.counterfilter)
end
--
--p1 m1 bingo:
function s.penfilter(c)
	return (c:IsSetCard(0x98) or c:IsSetCard(0x985)) and c:IsType(TYPE_PENDULUM) and not c:IsCode(20241028) and not c:IsForbidden()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() 
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			local opt=0
			if tc:IsAbleToHand() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
				opt=Duel.SelectOption(tp,aux.Stringid(20241028,0),aux.Stringid(20241028,1))
			elseif tc:IsAbleToHand() then
				opt=0
			else
				opt=1
			end
			if opt==0 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.penfilter2(c)
	return (c:IsSetCard(0x98) or c:IsSetCard(0x985) or c:IsCode(37803970) or c:IsCode(278136610) or c:IsCode(53208660) or c:IsCode(11481610) or c:IsCode(74850403) or c:IsCode(1344018) or c:IsCode(7799906) or c:IsCode(40318957) or c:IsCode(73511233) or c:IsCode(56675280)) or c:IsCode(76794549) or c:IsCode(12289247) and not c:IsCode(20241028) and c:IsType(TYPE_MONSTER + TYPE_SPELL + TYPE_TRAP) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.penfilter2,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- m2 XyzSummon
function s.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end