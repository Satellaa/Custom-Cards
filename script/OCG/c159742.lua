--Radiance of The White Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Negate the batteled opponent monster 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ngcon)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
	--Special Summon 1 Level 1 Spellcaster Tuner with 0 Attk/Def from Deck
	local e3=Effect.CreateEffect(c)
  	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.spcond)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON}

	function s.bwfilter(c,e,tp)
	  return c:IsCode(CARD_BLUEEYES_W_DRAGON)and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 
	      and Duel.IsExistingMatchingCard(s.bwfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.bwfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
	   e1:SetType(EFFECT_TYPE_FIELD)
   	 e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	   e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	   e1:SetTargetRange(1,0)
	   e1:SetReset(RESET_PHASE+PHASE_END)
	   Duel.RegisterEffect(e1,tp)
	   end
	end
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if tc:IsFaceup() and tc:IsCode(CARD_BLUEEYES_W_DRAGON) and not bc:IsSummonableCard() then
		e:SetLabelObject(bc)
		return true
	else return false end
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc:IsNegatableMonster() and Duel.GetFlagEffect(tp,id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,bc,1,0,0)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
	  --Negate it's effect 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		bc:RegisterEffect(e2)
		--Also it's Atk Becomes 0
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e3)
	end
end
function s.dbwfilter(c,tp)
	return c:GetPreviousCodeOnField()==CARD_BLUEEYES_W_DRAGON and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.dbwfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT)
	   and c:GetAttack()==0 and c:GetDefense()==0 and c:IsType(TYPE_TUNER) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end