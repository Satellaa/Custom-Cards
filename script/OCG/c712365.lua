--Angel with Eyes of Blue
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Upon link summon, Add 1 card that lists "Blue-Eyes White Dragon"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Effect Light Protection
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(HINTMSG_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.intg)
	e3:SetOperation(s.inop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BLUE_EYES}
s.listed_names={CARD_BLUEEYES_W_DRAGON,23995346}

function s.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_TUNER,lc,sumtype,tp) and c:IsRace(RACE_SPELLCASTER,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_LIGHT,lc,sumtype,tp)
	end
--Filter for Blue-Eyes White Dragon 
function s.tgfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() or ((c:ListsCode(CARD_BLUEEYES_W_DRAGON) or c:ListsCode(23995346))  and c:IsSpellTrap()) and c:IsAbleToHand()
end
	--If link summoned
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g>0 then
  Duel.SendtoHand(g,tp,REASON_EFFECT)
  Duel.ConfirmCards(1-tp,g)
   end
end
function s.intg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttribute,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_LIGHT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsAttribute,tp,LOCATION_MZONE,0,1,1,nil,ATTRIBUTE_LIGHT)
end
function s.inop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1,true)
	end
end