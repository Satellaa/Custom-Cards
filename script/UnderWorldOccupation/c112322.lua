
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon

	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE) 
	--EFFECT_FLAG_SINGLE_RANGE: chỉ tác động một lần/ affect once
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	--All monsters become FIRE
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e3)
	--Special 1 Level 3 and retrict
	local e4=Effect.CreateEffect(c)
	--e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	--e4:SetProperty(EFFECT_)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.spfitg) --special fiend target
	e4:SetOperation(s.spfiop) --special fiend operation;
	c:RegisterEffect(e4)

end

--e1 + e2
function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FIEND,fc,sumtype,tp)
end 

function s.spfilter(c)
	return c:IsLevel(3) and c:IsAttack(1000)
end
	

function s.hspcon(e,c)
	if c==nil then return true end
	
	local tp=c:GetControler()

	--return Duel.CheckReleaseGroup(c:GetControler(),s.spfilter,1,false,1,true,c,c:GetControler(),nil,false,nil)
	local g1=Duel.CheckReleaseGroup(tp, s.spfilter, 2,false,1,true,c,tp,nil,false,nil)

 	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	return #g>=2 
		and g1 == true
end


function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	--local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,nil,nil,false,nil)
	local g=Duel.SelectReleaseGroup(tp, s.spfilter , 2, 2,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	c:SetMaterial(g)
	g:DeleteGroup()
end
 --e4
 function s.spfifilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end

function s.spfitg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget( s.spfifilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp, s.spfifilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spfiop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_UNRELEASABLE_SUM)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		e5:SetValue(1)
		tc:RegisterEffect(e5)
		local e6=e5:Clone()
		e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e6)
		local e3=e5:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		tc:RegisterEffect(e3)
		local e8=e5:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e8)
		local e9=e5:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e9)
		local e10=e5:Clone()
		--lock lock lock
		e10:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e10:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e10)
		


		Duel.SpecialSummonComplete()
	end	
end