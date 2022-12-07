--Absloute Stygian Judge
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
		--2nd Effect 
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_GRAVE)
  e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.damcon2)
	e4:SetTarget(s.damtg2)
	e4:SetOperation(s.damop2)
	c:RegisterEffect(e4)
end
s.listed_series={SET_RED_DRAGON_ARCHFIEND}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return #eg==1 and tc:IsControler(tp) and tc:IsSetCard(SET_RED_DRAGON_ARCHFIEND)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local atk=eg:GetFirst():GetBattleTarget():GetAttack()
	if atk<0 then atk=0 end
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.filter(c,tp)
    return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp) and re and re:GetHandler():IsSetCard(SET_RED_DRAGON_ARCHFIEND) and re:GetHandler():IsMonster() 
	  and re:GetHandler():IsControler(tp)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) end
	local g=eg:Filter(s.filter,nil,e,1-tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,g,1,0,0)
end
function s.spcfilterchk(c,tp)
	return c:IsPreviousControler(tp) or c:IsPreviousControler(1-tp)
end
function s.atkfilter(c)
		return c:GetPreviousAttackOnField()
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e):Filter(s.spcfilterchk,nil,tp)
	g:KeepAlive()
  local mg,atk=g:GetMaxGroup(s.atkfilter)
		local dam=Duel.Damage(1-tp,atk,REASON_EFFECT)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return #eg==1 and tc:IsControler(tp) and tc:IsSetCard(SET_RED_DRAGON_ARCHFIEND)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local dam=500
	if dam<0 then dam=0 end
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.damfilter(c,tp)
    return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE)
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil,1-tp) and re and re:GetHandler():IsSetCard(SET_RED_DRAGON_ARCHFIEND) and re:GetHandler():IsMonster() 
	 and re:GetHandler():IsControler(tp)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) end
	local g=eg:Filter(s.damfilter,nil,e,1-tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,g,1,0,0)
end
function s.damfilterchk(c,tp)
	return c:IsPreviousControler(tp) or c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e):Filter(s.damfilterchk,nil,tp)
	local ct=g:GetCount()
  		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end