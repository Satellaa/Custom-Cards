--Hope With Eyes of Blue
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
  --Activate 
  local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Make Deep-Eyes White Dragon cannot be Tributed or targeted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BLUE_EYES}
s.listed_names={CARD_DEEP_EW_DRAGON}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if tp==ep then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg and tc>0
end
function s.tgfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and c:IsAbleToGrave()
end
function s.dewdfilter(c)
	return c:IsCode(CARD_DEEP_EW_DRAGON) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) 
	      and Duel.IsExistingMatchingCard(s.dewdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
			local g1=Duel.SelectMatchingCard(tp,s.dewdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if #g1>0 then
			 Duel.SendtoHand(g1,tp,REASON_EFFECT)
			 end
		end
end
function s.filter(c,e)
	return c:IsCode(CARD_DEEP_EW_DRAGON) and (not e or c:IsRelateToEffect(e))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and eg:IsExists(s.filter,1,nil,nil) end
	local g=eg:Filter(s.filter,nil,nil)
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local g=eg:Filter(s.filter,nil,e)
	local tc=g:GetFirst()
	if not tc then return end
	--cannot release
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	tc:RegisterEffect(e2)
	--Cannot be targeted by opp card effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(aux.tgoval)
	tc:RegisterEffect(e3)
end