--Graphack, Chaos Dragon of Dark World
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),2,99,s.matcheck)
	--Add 1 "The Gates of Dark World"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Destroy replace, after that gain atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--special summon rule
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	end
	s.listed_series={SET_DARK_WORLD}
	s.listed_names={33017655,34230334,34230233}
	--Include a "Dark World" monster as link material
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_DARK_WORLD,lc,sumtype,tp)
end
function s.godwchk()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,33017655),0,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(33017655)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.gofdw(c,tp)
	return c:IsCode(33017655) and c:GetActivateEffect()
end
function s.thfilter(c)
	return c:IsSetCard(SET_DARK_WORLD) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
local loc=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE
if chk==0 then
		return Duel.IsExistingMatchingCard(s.gofdw,tp,loc,0,1,nil)
			or (s.godwchk() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil))
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
local loc=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE
		local gdw=Duel.GetMatchingGroup(s.gofdw,tp,loc,0,nil)
	local hg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK,0,nil)
	if (#hg>0 and s.godwchk()) and (s.godwchk()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=hg:Select(tp,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif #gdw>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g2=gdw:Select(tp,1,1,nil):GetFirst()
			aux.PlayFieldSpell(g2,e,tp,eg,ep,ev,re,r,rp)
		end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,SET_DARK_WORLD) end
	local tc=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,nil,SET_DARK_WORLD)
	local atk=tc:GetFirst():GetAttack()
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD+REASON_EFFECT)
		Duel.SetTargetParam(atk)
		return true
     end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFirstTarget()
		local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk/2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
  end
  function s.spfilter1(c)
	return c:IsFaceup() and c:IsSetCard(SET_DARK_WORLD) and c:IsAbleToHandAsCost()
end
function s.spfilter2(c)
	return c:IsFaceup() and c:IsCode(34230334) and c:IsAbleToGraveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(2)(sg,e,tp,mg) and sg:IsExists(s.chk,2,nil,sg,tp)
end
function s.chk(c,sg,tp)
	return s.spfilter1(c,tp) and sg:IsExists(s.spfilter2,1,c)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil)
	local g=g1:Clone()
	g:Merge(g2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #g1>0 and #g2>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil)
	g1:Merge(g2)
	local g=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    local grapha=g:Filter(Card.IsCode,nil,34230334):GetFirst()
    g:RemoveCard(grapha)
    Duel.SendtoHand(g,nil,REASON_COST)
    Duel.SendtoGrave(grapha,REASON_COST)
    --return it to the extra deck if it leaves the field
    local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)
end