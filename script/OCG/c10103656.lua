--Galaxy Guard
local s,id=GetID()
function s.initial_effect(c)
--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Send 1 monster to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sendtg)
	e2:SetOperation(s.sendop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GALAXY,SET_PHOTON}
  function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GALAXY) and c:IsType(TYPE_MONSTER) and c:HasLevel()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	elseif c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return false end
	end
function s.tgfilter(c)
	return (c:IsSetCard(SET_GALAXY) or c:IsSetCard(SET_PHOTON)) and c:IsMonster() and c:IsAbleToGrave()
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
  if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end 
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c) 
	and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c)
	if #g>0 then
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local tg=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
		local tc=Duel.GetFirstTarget()
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end
