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
	e3:SetCost(s.xyzcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	--Duel.AddCustomActivityCounter(s,ACTIVITY_SPSUMMON,s.counterfilter)
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
		return ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
local code_list={37803970,278136610,53208660,11481610,74850403,1344018,7799906,40318957,73511233,56675280,76794549,12289247}
function s.penfilter2(c)
	return (c:IsSetCard(0x98) or c:IsSetCard(0x985) or c:IsCode(table.unpack(code_list))) and not c:IsCode(20241028) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)) and c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.penfilter2,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
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
function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.xyzfilter(c,e)
	local g=Duel.GetMatchingGroup(function (tc)
		return tc:IsRankAbove(1) and tc:IsFaceup()
	end,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local t={}
	for card in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetValue(function ()
			return c:GetRank()
		end)
		card:RegisterEffect(e1)
		table.insert(t,e1)
	end
	local result=c:IsXyzSummonable(Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_HAND,0,e:GetHandler()))
	for _,v in ipairs(t) do
		v:Reset()
	end
	return result
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e)
	if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		local g=Duel.GetMatchingGroup(function (c) return c:IsRankAbove(1) and c:IsFaceup() end,tp,LOCATION_MZONE,0,nil)
		local t={}
		for card in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_XYZ_LEVEL)
			e1:SetValue(function ()
				return tc:GetRank()
			end)
			card:RegisterEffect(e1)
			table.insert(t,e1)
		end
		local min=tc.min
		local max=tc.max
		local f=tc.f
		::cancle::
		local mg=Duel.SelectXyzMaterial(tp,tc,f,tc:GetRank(),min,max,Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE+LOCATION_HAND,0,nil))
		if not mg or mg:GetCount()==0 then goto cancle end
		local over_group=Group.CreateGroup()
		for mc in aux.Next(mg) do
			over_group:Merge(mc:GetOverlayGroup())
		end
		Duel.SendtoGrave(over_group,REASON_RULE)
		tc:SetMaterial(mg)
		Duel.Overlay(tc,mg)
		Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
		for _,v in ipairs(t) do
			v:Reset()
		end
	end
end