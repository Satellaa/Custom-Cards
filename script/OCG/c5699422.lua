--Ultimate Asura Utopia Ray
--Scripted by Eerie Code
Duel.LoadCardScript("c56840427.lua")
local s,id=GetID()
function s.initial_effect(c)
--Xyz Summon
Xyz.AddProcedure(c,nil,5,3)
c:EnableReviveLimit()
--Attach ZW
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.zwcost)
	e1:SetTarget(s.zwtg) 
	e1:SetOperation(s.zwop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--negate
	  e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_names={56840427}
s.listed_series={SET_ZW}
s.xyz_number=39
function s.filter(c,tc,tp)
	if not (c:IsSetCard(SET_ZW) and not c:IsForbidden()) then return false end
	local effs={c:GetCardEffect(75402014)}
	for _,te in ipairs(effs) do
		if te:GetValue()(tc,c,tp) then return true end
	end
	return false
end
function s.zwcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.zwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp)end
   end
	function s.zwop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,2,nil,c,tp)
	if #g>0 then
	Duel.Overlay(c,g)
	end
end
function s.discfilter(c)
	return c:IsSetCard(SET_ZW) and c:GetOriginalType() & TYPE_MONSTER ~= 0
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
 return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and 
            re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev) and e:GetHandler():GetOverlayGroup():IsExists(s.discfilter,1,99)
    end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetOverlayGroup():FilterSelect(tp,Card.IsSetCard,1,1,nil,SET_ZW)
	local tc=g:GetFirst()
	if #g>0 then
		Duel.Equip(tp,g:GetFirst(),c)
		Duel.ConfirmCards(1-tp,g) end
	local tc=g:GetFirst()
	if tc then
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then 
		Duel.Destroy(eg,REASON_EFFECT) 
		local eff=tc:GetCardEffect(75402014)
		eff:GetOperation()(tc,eff:GetLabelObject(),tp,c)
		end
  end
end