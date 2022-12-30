-- DDD勇戦王アキレウス
-- D/D/D Martial King Achilles
-- Scripted by Lilac
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
        Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xaf),2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
        e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
        e1:SetCondition(s.descon)
        e1:SetTarget(s.destg)
        e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
        e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
        e2:SetTarget(s.thtg)
        e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x10af,0xaf,0xae}
s.listed_names={33814281}
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if #sg>0 then
	local ct=Duel.Destroy(sg,REASON_EFFECT)
        if ct>2 then
        local send_ct=ct//2
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,send_ct,send_ct,nil)
        if #g>0 then
	local ct2=Duel.Destroy(g,REASON_EFFECT)
	if ct2>0 then
			Duel.BreakEffect()
                        local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct2*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			e:GetHandler():RegisterEffect(e1)
    end
   end
  end
 end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsEnvironment(33814281) or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,2,nil))
end
function s.thfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.thfilter3(c)
	return (c:ListsArchetype(0xaf) or c:ListsArchetype(0x10af) or c:ListsArchetype(0xae)) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
  local dg=Duel.GetMatchingGroup(s.thfilter3,tp,LOCATION_DECK,0,nil)
  return dg:GetClassCount(Card.GetCode)>=3 end
  local ct=Duel.GetMatchingGroupCount(s.thfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0,nil)
	Duel.SetTargetPlayer(tp)
        Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,ct*1000)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(s.thfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0,nil)
	if Duel.Damage(p,ct*1000,REASON_EFFECT) then
	local g=Duel.GetMatchingGroup(s.thfilter3,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,sg1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg2=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,sg2:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg3=g:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		Duel.ConfirmCards(1-tp,sg1)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local cg=sg1:Select(1-tp,1,1,nil)
		local tc=cg:GetFirst()
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        else
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        end
        sg1:RemoveCard(tc)
        Duel.SendtoGrave(sg1,REASON_EFFECT)
     end
  end
end
