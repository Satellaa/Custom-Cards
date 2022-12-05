local s,id=GetID()
function s.initial_effect(c)
	--send
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	--e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.spfifilter(c)
    return c:IsLevelAbove(0) and c:IsAbleToGrave(nil)
end   
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    local tg=Duel.GetMatchingGroup(s.spfifilter,tp,0,LOCATION_DECK,nil)
    return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and #tg > 0
end    

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end 


function s.operation(e,tp,eg,ep,ev,re,r,rp)
    
    local tg=Duel.GetMatchingGroup(s.spfifilter,tp,0,LOCATION_DECK,nil)
    if #tg==0 then return end
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
    local g=tg:Select(1-tp,1,5,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
        if #g == 5 then 
        Duel.SetTargetPlayer(1-tp)
        Duel.SetTargetParam(1)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Draw(p,d,REASON_EFFECT)
        else 
        	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	    Duel.SetTargetPlayer(1-tp)
	    Duel.SetTargetParam(500)
	    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	    Duel.Damage(p,d,REASON_EFFECT)
        end
    end
end
