--Elemental HERO Divine Neos Future 
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_NEOS,1,s.ffilter,4)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.fuslimit,nil,nil,false)
	--Neos Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Neo-Spacian Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.addcon)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
	--Hero Effect 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetCondition(s.tgcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--Hero Effect 2
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
  s.material_setcode={SET_NEOS,SET_HERO,SET_NEO_SPACIAN}
	s.listed_series={SET_NEOS,SET_HERO,SET_NEO_SPACIAN}
	s.listed_names={CARD_NEOS}
	function s.fuslimit(e,se,sp,st)
    return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
	function s.ffilter(c,fc,sumtype,tp)
	return (c:IsSetCard(SET_HERO,fc,sumtype,tp) or c:IsSetCard(SET_NEOS,fc,sumtype,tp) or c:IsSetCard(SET_NEO_SPACIAN,fc,sumtype,tp)) and c:IsMonster(fc,sumtype,tp)
end
if contact then sumtype=0 end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.atkfilter,1,nil,c)
end
function s.atkfilter(c)
	return c:IsSetCard(SET_NEOS) and not c:IsCode(CARD_NEOS)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e:GetHandler():GetAttack()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c,lv)
	return c:IsAbleToGrave() and (c:IsSetCard(SET_HERO) or c:IsSetCard(SET_NEOS) or c:IsSetCard(SET_NEO_SPACIAN)) and c:IsType(TYPE_MONSTER)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c:GetAttack())
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)~=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=g:GetFirst():GetBaseAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	      end
	end
	function s.addcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.addfilter,1,nil,c)
end
function s.addfilter(c)
	return c:IsSetCard(SET_NEO_SPACIAN) and not c:IsCode(CARD_NEOS)
end
function s.schfilter(c)
	return (c:IsSetCard(SET_HERO) or c:IsSetCard(SET_NEOS) or c:IsSetCard(SET_NEO_SPACIAN)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.schfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.tgfilter,1,nil,c)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_HERO) and not c:IsCode(CARD_NEOS)
end
