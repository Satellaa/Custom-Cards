--Odd-Eyes Venom Dragon - Overlord 
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION),aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	Pendulum.AddProcedure(c,false)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--pendulum
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)
	--Fusion Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.pntg)
	e3:SetOperation(s.pnop)
	c:RegisterEffect(e3) 
	end
	s.listed_series={SET_STARVING_VENOM,SET_PREDAPLANT}
	if contact then sumtype=0 end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
     local c=e:GetHandler()
	return (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.pmfilter,1,nil,c)
end
function s.pmfilter(c,sc)
	return c:IsType(TYPE_FUSION) and c:GetOriginalLevel()==10
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		local atk=g:GetSum(Card.GetBaseAttack)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		end
		function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.penfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.fusfilter(c,e,tp,m,f)
  local self=e:GetHandler()
	return c:IsType(TYPE_FUSION) and (c:IsSetCard(SET_STARVING_VENOM) or c:IsSetCard(SET_PREDAPLANT)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,self,tp)
end
function s.pntg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
	if chk==0 then 
	  local mg1=Duel.GetFusionMaterial(tp)
	  local res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil)
	  if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(c,ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		return res and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
	function s.pnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	local exmat=false
	exmat=true
		local sg1=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil)
	Fusion.CheckAdditional=nil
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then Fusion.CheckAdditional=s.fcheck end
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,tp)
			Fusion.CheckAdditional=nil
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,tp)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
