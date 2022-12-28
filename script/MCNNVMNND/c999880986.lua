-- Evil HERO Supreme King Neos
local s,id=GetID()
function s.initial_effect(c)
    --Add 1 Super Polymerization or Dark Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.addcost)
    e1:SetCondition(s.addcon)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	c:RegisterEffect(e1)
    --Fusion Summon
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0x8),Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial,nil,nil,nil,nil,nil,FUSPROC_NOLIMIT}
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e2)
end
s.listed_names={CARD_DARK_FUSION}
s.listed_codes={48130397}
s.listed_series={0x6008,0x9,0xf8}
function s.addcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
    if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
	and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTarget(s.splimit)
    Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    e3:SetTarget(s.splimit)
    Duel.RegisterEffect(e3,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x6008)
end
function s.gyfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end
function s.thfilter(c,cd)
	return (c:IsCode(48130397) or Card.ListsCode(c,CARD_DARK_FUSION)) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0
		and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_GRAVE)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg) 
   end
 end
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	end
	return nil
end