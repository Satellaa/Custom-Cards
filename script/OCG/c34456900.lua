--Blue-eyes Quinary Ultimate Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_BLUE_EYES),5)
	c:EnableReviveLimit()
		--cannot be fusion material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Special Summon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Unaffected by Opponent Card Effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.unval)
	c:RegisterEffect(e4)
	--Destroy All monsters your opponent controls 
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_BLUE_EYES}
s.material_setcode={SET_BLUE_EYES}

function s.spfilter1(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsLevel(12) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsAbleToRemoveAsCost()
end
function s.spfilter2(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg)
end
function s.chk(c,sg)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsLevel(12) and c:IsSummonType(SUMMON_TYPE_FUSION) and sg:IsExists(Card.IsSetCard,2,c,SET_BLUE_EYES)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local g=g1:Clone()
	g:Merge(g2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #g1>0 and #g2>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	g1:Merge(g2)
	local g=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE)
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
	Duel.Remove(g,POS_FACEUP,REASON_COST)
		c:SetMaterial(g)
		g:DeleteGroup()
end
function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	--Cannot attack
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,2)
	e:GetHandler():RegisterEffect(e1,true)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
