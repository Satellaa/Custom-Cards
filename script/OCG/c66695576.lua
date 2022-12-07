--Sillva, War Overlord of Dark World
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),s.matfilter)
	--lizard check
	Auxiliary.addLizardCheck(c)
	--Target 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.retcon)
	e1:SetTarget(s.rettg)
	e1:SetOperation(s.retop)
	c:RegisterEffect(e1)
	--Discard up to 2 cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.disccon)
	e2:SetTarget(s.disctg)
	e2:SetOperation(s.discop)
	c:RegisterEffect(e2)
end
s.material_setcode={SET_DARK_WORLD}
	function s.matfilter(c)
	local lv=c:GetLevel()
	return c:HasLevel() and (lv==5 or lv==6) and c:IsSetCard(SET_DARK_WORLD)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
  if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
	if tc==0 or Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	local sg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) and #sg>0 then
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.disccon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetReasonPlayer()~=tp and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.disctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil,e,tp) end
end
function s.discop(e,tp,eg,ep,ev,re,r,rp)
	local discard=Duel.DiscardHand(tp,nil,1,2,REASON_EFFECT+REASON_DISCARD)
	if discard==0 then return end
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=dg:Select(1-tp,1,discard,nil)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
end
