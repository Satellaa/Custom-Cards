 --Mystic Factor Melchior
local s,id=GetID()
function s.initial_effect(c)
	--Apply the effects of a "Fusion/Polymerization" spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--its name can be treated as 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.annop)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
end
s.listed_series={0x46,0x290f}
function s.copfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x46) and (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL) and c:CheckActivateEffect(true,true,false)~=nil 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if not Duel.SendtoGrave(g,REASON_COST) then return end
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		end
	end
	function s.filter(c)
	return c:IsSetCard(0x290f) and c:HasLevel(10)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	     if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	          end
		end
	end
	function s.annop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	local code=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code)
	c:RegisterEffect(e1)
end
