--Reform Ancient Gear Wyvern 
local s,id=GetID()
function s.initial_effect(c)
     c:SetSPSummonOnce(id)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),2)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Special summon procedure (from Extra)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--effect gain
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetCondition(s.efcon)
	e5:SetOperation(s.efop)
	c:RegisterEffect(e5)
end
	s.listed_series={SET_ANCIENT_GEAR}
	
	function s.spfilter(c)
	return c:IsOriginalType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
function s.spfilter1(c,tp)
	return c:IsSetCard(SET_ANCIENT_GEAR) and c:IsMonster() and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local rg2=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil,tp)
	return aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0) and aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil,tp)
	local mg1=aux.SelectUnselectGroup(rg1,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_FMATERIAL,nil,nil,true)
	if #mg1>0 then
		local sg=mg1:GetFirst()
		local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
		rg2:RemoveCard(sg)
		local mg2=aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_FMATERIAL,nil,nil,true)
		mg1:Merge(mg2)
	end
	if #mg1==2 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.ConfirmCards(1-tp,g)
     Duel.Release(g,REASON_COST,REASON_MATERIAL)
 	g:DeleteGroup()
	c:SetMaterial(g)
		g:DeleteGroup()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsSetCard(SET_ANCIENT_GEAR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK+REASON_RITUAL+REASON_SPSUMMON)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():GetReasonCard():IsRace(RACE_MACHINE)
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
	end 
	function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
