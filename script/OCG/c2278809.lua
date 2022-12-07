--Mystic Atlantis Gate
local s,id=GetID()
function s.initial_effect(c)
--pendulum summon
	Pendulum.AddProcedure(c)
	--Battle Damage to 0
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37780349,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(s.dmcon)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.dmtg)
	e4:SetOperation(s.dmop)
	c:RegisterEffect(e4)
	--Negate Effect Damage
	local e1=e4:Clone()
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.con)
	e1:SetCountLimit(1,id+1)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={0x190f}
	function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0
end
function s.filter(c)
	return c:IsSetCard(0x190f)
end
	function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_PZONE,0,1,1,nil)
	local tc=g:GetFirst()
		Duel.Destroy(tc,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetLabel(tc:GetScale())
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=e:GetLabel()*300
	Duel.ChangeBattleDamage(ep,math.max(Duel.GetBattleDamage(tp)-dam,0))
	Duel.Recover(tp,ev-dam,REASON_EFFECT)
        end
        function s.con(e,tp,eg,ep,ev,re,r,rp)
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex and (cp==tp or cp==PLAYER_ALL) then
		e:SetLabel(cv)
		return true
	end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if ex and (cp==tp or cp==PLAYER_ALL) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER) then
		e:SetLabel(cv)
		return true
	end
	return false
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
local cid=e:GetLabel()
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.SetTargetParam(cid)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,val,r,rc)
local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
local ed=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_PZONE,0,1,1,nil)
	local tc=g:GetFirst()
		Duel.Destroy(tc,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid,tc:GetScale()*300)
	e1:SetValue(s.damcon)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	Duel.Recover(tp,ed-(tc:GetScale()*300),REASON_EFFECT)
    end
function s.damcon(e,re,val,r,rp,rc)
   local cid,dam=e:GetLabel()
	local cc=Duel.GetCurrentChain()
	if cc==0 or (r&REASON_EFFECT)==0 then return val end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return math.max(0,val-dam)
    end 