--Mystic Deus Gate
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
c:EnableUnsummonable()
Pendulum.AddProcedure(c)
c:SetUniqueOnField(1,0,id)
--Cannot Special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(s.splimit)
	c:RegisterEffect(e3)
--Special summon Condition
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2407147,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.deuscon)
	e4:SetOperation(s.deusop)
	c:RegisterEffect(e4)
	--That Special summon cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	--SpecialSummon Effect 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.cond2)
	e4:SetTarget(s.tg2)
	e4:SetOperation(s.op2)
	c:RegisterEffect(e4)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Place 1 "Mystic gate" in PZone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.pctg)
	e2:SetCountLimit(1,id+1)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
	--Unaffected
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		c:RegisterEffect(e1)
		--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetCountLimit(1,id+2)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Mystic Gate 
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x190f))
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Mystic Gate Pendulum 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+3)
	e2:SetTarget(s.pntg)
	e2:SetOperation(s.pnop)
	c:RegisterEffect(e2)
	--Destroy all cards 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id+4)
	e3:SetTarget(s.target2)
	e3:SetCondition(s.condition2)
	e3:SetOperation(s.operation2)
	c:RegisterEffect(e3)
	--Scale change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id+5)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		s[2]={}
		s[3]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x190f}
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x190f) and c:IsFaceup() and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g1=eg:Filter(s.cfilter,nil,tp)
	local g2=eg:Filter(s.cfilter,nil,1-tp)
	local tc1=g1:GetFirst()
	while tc1 do
		if s[tp]==0 then
			s[2+tp][1]=tc1:GetAttribute()
			s[tp]=s[tp]+1
		else
			local chk=true
			for i=1,s[tp]+1 do
				if s[2+tp][i]==tc1:GetAttribute() then
					chk=false
				end
			end
			if chk then
				s[2+tp][s[tp]+1]=tc1:GetAttribute()
				s[tp]=s[tp]+1
			end
		end
		tc1=g1:GetNext()
	end
	while tc2 do
		if s[1-tp]==0 then
			s[2+1-tp][1]=tc2:GetAttribute()
			s[1-tp]=s[1-tp]+1
		else
			local chk=true
			for i=1,s[1-tp]+1 do
				if s[2+1-tp][i]==tc2:GetAttribute() then
					chk=false
				end
			end
			if chk then
				s[2+1-tp][s[1-tp]+1]=tc2:GetAttribute()
				s[1-tp]=s[1-tp]+1
			end
		end
		tc2=g2:GetNext()
	end
end
function s.deuscon(e,tp,eg,ep,ev,re,r,rp)
	return s[tp]>=6
end
function s.deusop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)
end
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(id)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Destroy(c,REASON_EFFECT)
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.atkfilter(c)
	return c:IsSetCard(0x190f) and c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function s.atkval(e,c)
local loc=LOCATION_GRAVE|LOCATION_MZONE|LOCATION_EXTRA|LOCATION_SZONE
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),loc,0,nil)*1000
end
function s.pcfilter(c)
	return c:IsSetCard(0x190f) and c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
	local tc=g:GetFirst()
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
      local effs={tc:GetCardEffect()}
      for _,eff in ipairs(effs) do
  if eff:IsHasType(EFFECT_TYPE_IGNITION) then
     local e2=eff:Clone()
    e2:SetRange(LOCATION_MZONE+LOCATION_PZONE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
                 break
            end
        end
    end
end
function s.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE) and rp~=tp
		and (not c:IsReason(REASON_EFFECT))
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,LOCATION_PZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,0,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
function s.pntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.pnop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
	local tc=g:GetFirst()
	Duel.ConfirmCards(1-tp,tc)
		Duel.SendtoHand(tc,nil,REASON_EFFECT) 
		end
	end
	function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c)
	return c:IsSetCard(0x90f)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,0,1,nil) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,0,nil)
		if Duel.Destroy(sg,REASON_EFFECT)then
		local pg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(pg,REASON_EFFECT)
		--Limit of Pendulum monsters
		local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.aclimit)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e4,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END,2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		e1:SetLabelObject(c)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp) then
		local seq=0
		if c:GetPreviousSequence()==7 or c:GetPreviousSequence()==4 then seq=1 end
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,c:GetPreviousPosition(),true,(1<<seq))
			end 
      end
function s.aclimit(e,re,tp)
    return re:IsActiveType(TYPE_PENDULUM)
end
function s.setlimit(e,c,tp)
	return c:IsType(TYPE_FIELD)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local sc=Duel.AnnounceNumber(tp,1,2,3,4,5,6,7,8,9,10,11,12,13)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(sc)
		c:RegisterEffect(e1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RSCALE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(sc)
		c:RegisterEffect(e1)
	end
	