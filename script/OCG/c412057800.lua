--Dark Magic Formula 
local s,id=GetID()
function s.initial_effect(c)
	--Apply effect depending on the target's name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARK_MAGICIAN,SET_MAGICIAN_GIRL}
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(700)
	tc:RegisterEffect(e2)
	--check if "Magician girl " is on the field 
	if tc:IsSetCard(SET_MAGICIAN_GIRL) then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,c)
		for oc in aux.Next(g) do
			--Negate Thier Effects
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			oc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			oc:RegisterEffect(e3)
			if oc:IsType(TYPE_TRAPMONSTER) then
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				oc:RegisterEffect(e4)
			--Check if Dark magician on the field 
		else if tc:IsSetCard(SET_DARK_MAGICIAN) then
		local p=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,c)
		for pc in aux.Next(p) do
		   --Change ATK to 0
				local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			pc:RegisterEffect(e1)
		          end
	          end
         end
		   end
     end  
	end
	