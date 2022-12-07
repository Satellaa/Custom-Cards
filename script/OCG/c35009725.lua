--Lord of Blue-Eyes
local s,id=GetID()
function s.initial_effect(c)
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetValue(17985575)
	c:RegisterEffect(e1)
	--Special summon This card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
  e2:SetCountLimit(3,id,EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(s.spcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Cannot be target by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tgtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Shuffle 1 "Blue-eyes" or 1 level 1 light tuner
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)  
end
 s.listed_series={SET_BLUE_EYES}
 
function s.spfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsMonster()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spfilter,1,nil,tp)
end
function s.bwfilter(c)
  return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=Duel.GetMatchingGroup(s.bwfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	 Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
	local g=Duel.SelectMatchingCard(tp,s.bwfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
	 Duel.SendtoHand(g,tp,REASON_EFFECT)
	 Duel.BreakEffect()
	 Duel.ConfirmCards(1-tp,g)
	     end
   end
end
function s.tgtg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(SET_BLUE_EYES) and c:IsMonster()
end
function s.tdfilter(c,e,tp,chk,sp)
    return ((c:IsSetCard(SET_BLUE_EYES) and c:IsMonster()) or (c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER)) 
       or c:IsRace(RACE_DRAGON)) and c:IsAbleToDeck() and ((chk==0 or sp) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,c,e,tp))
      or (chk==1 and not sp)
end
 function s.spfilter2(c,e,tp)
   return ((c:IsSetCard(SET_BLUE_EYES) and c:IsLevelBelow(8) and c:IsMonster()) or (c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER)))
   and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
      end
 function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp,0) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sp=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)>1 
    and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp,1,sp)
    if g then
        Duel.ConfirmCards(1-tp,g)
        if Duel.SendtoDeck(g,tp,2,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp)
            if #g2>0 then
            Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
       end
     end
   end
end