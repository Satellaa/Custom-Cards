--Blue-Skies Metaphys Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTuner(nil),1,99)
		--negate special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Special Summon itself after being banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.selfspcond)
	e2:SetCost(s.selfspcost)
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0
end
function s.disfilter(c)
 return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
 end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	local sc=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if #sc>0 then
 local tc=sc:Select(tp,1,1,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_COST)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
  Duel.Destroy(eg,REASON_EFFECT)
end
function s.selfspcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
function s.costfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT)
        and ((c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost())
            or (c:IsAbleToGraveAsCost() and c:IsLocation(LOCATION_HAND) or c:IsFaceup()))
end
function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local all_locs=LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE
    local rg=Duel.GetMatchingGroup(s.costfilter,tp,all_locs,0,nil)
    if chk==0 then return #rg>1 and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0) end
    local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,aux.Stringid(id,0))
    local g1,g2=g:Split(Card.IsLocation,nil,LOCATION_GRAVE)
    if #g1>0 then
        Duel.Remove(g1,nil,REASON_COST)
    end
    if #g2>0 then
        Duel.SendtoGrave(g2,REASON_COST)
    end
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_REMOVED)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end