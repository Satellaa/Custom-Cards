--Odd-Eyes Wing Dragon - Overlord 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--custom synchro summon
	if s.synchro_type==nil then
		s.synchro_type=1
		s.synchro_parameters={nil,1,1,Synchro.NonTuner(nil),1,99}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1172)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.CustomSynchroCondition(nil,1,1,Synchro.NonTuner(nil),1,99))
	e1:SetTarget(s.CustomSynchroTarget(nil,1,1,Synchro.NonTuner(nil),1,99))
	e1:SetOperation(Synchro.Operation)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
	--If synchro summoned using a synchro monster,  Negate all monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetCondition(s.tncon)
	e1:SetTarget(s.disable)
	c:RegisterEffect(e1)
	--pendulum zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
	--destroy to perform a Synchro Summon 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCost(s.pfuscost)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SYNCHRO_DRAGON,SET_SPEEDROID,SET_CLEAR_WING}
function s.CustomSynchroCondition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local dg
				local lv=c:GetLevel()
				local g
				local mgchk
				if mg then
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
					mgchk=true
				else
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
					mgchk=false
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if not g:Includes(pg) or pg:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
				if smat then
					if smat:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
					pg:Merge(smat)
					g:Merge(smat)
				end
				if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
					--if there is a monster with EFFECT_SYNCHRO_CHECK (Genomix Fighter/Mono Synchron)
					local g2=g:Clone()
					if not mgchk then
						local thg=g2:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
						local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
						for thc in aux.Next(thg) do
							local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
							local val=te:GetValue()
							local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil) --tuner
							g2:Merge(ag)
						end
					end
					local res=g2:IsExists(Synchro.CustomCheckP31,1,nil,g2,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
					local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					Duel.AssumeReset()
					return res
				else
					--no race change
					local tg
					local ntg
					if mgchk then
						tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
						ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
					else
						tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
						ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
						local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
						thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
						local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
						for thc in aux.Next(thg) do
							local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
							local val=te:GetValue()
							local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
							local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
							tg:Merge(thag)
							ntg:Merge(nthag)
						end
					end
					local lv=c:GetLevel()
					local res=tg:IsExists(s.CustomCheckP41,1,nil,tg,ntg,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
					local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					return res
				end
				return false
			end
end
function s.CustomCheckP31(c,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
		for i=1,#teg do
			local te=teg[i]
			local val=te:GetValue()
			local tg=g:Filter(function(mc) return val(te,mc) end,nil)
			rg=tg:Filter(function(mc) return not Synchro.TunerFilter(mc,f1,sub1,sc,tp) and not Synchro.NonTunerFilter(mc,f2,sub2,sc,tp) end,nil)
		end
	end
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg1=g:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg1)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res,trg,ntrg2=tgchk(te,c,sg,g,g,tsg,ntsg)
				--if not res then return false end
				if res then
					rg:Merge(trg)
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,g,g,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	g:Sub(rg)
	tsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	if max and (tsg_count>max or (max-tsg_count)<min2) then
		res = false
	elseif max and (max-tsg_count)==min2 then
		res=tsg:IsExists(Synchro.TunerFilter,tsg_count,nil,f1,sub1,sc,tp) and (not req1 or req1(tsg,sc,tp)) 
			and g:IsExists(s.CustomCheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<min1 then
		res=g:IsExists(s.CustomCheckP31,1,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<max1 then
		res=g:IsExists(s.CustomCheckP31,1,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or (tsg:IsExists(Synchro.TunerFilter,tsg_count,nil,f1,sub1,sc,tp) and (not req1 or req1(tsg,sc,tp)) 
				and g:IsExists(s.CustomCheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max))
	else
		res=tsg:IsExists(Synchro.TunerFilter,tsg_count,nil,f1,sub1,sc,tp) and (not req1 or req1(tsg,sc,tp)) 
			and g:IsExists(s.CustomCheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	end
	g:Merge(rg)
	tsg:RemoveCard(c)
	sg:RemoveCard(c)
	if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
		Duel.AssumeReset()
	end
	return res
end
function s.CustomCheckP32(c,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
		for i=1,#teg do
			local te=teg[i]
			local val=te:GetValue()
			local tg=g:Filter(function(mc) return val(te,mc) end,nil)
			rg=tg:Filter(function(mc) return not Synchro.NonTunerFilter(mc,f2,sub2,sc,tp) end,nil)
		end
	end
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg2=g:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg2)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res,trg2,ntrg2=tgchk(te,c,sg,Group.CreateGroup(),g,tsg,ntsg)
				--if not res then return false end
				if res then
					rg:Merge(ntrg2)
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,Group.CreateGroup(),g,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	g:Sub(rg)
	ntsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	local ntsg_count=#ntsg
	if max and (tsg_count+ntsg_count)>max then
		res = false
	elseif ntsg_count<min2 then
		res=g:IsExists(s.CustomCheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif ntsg_count<max2 then
		res=g:IsExists(s.CustomCheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or ((not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
				and ntsg:IsExists(Synchro.NonTunerFilter,ntsg_count,nil,f2,sub2,sc,tp) 
				and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,sc,tp))
	else
		res=(not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
			and ntsg:IsExists(Synchro.NonTunerFilter,ntsg_count,nil,f2,sub2,sc,tp)
			and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,sc,tp)
	end
	g:Merge(rg)
	ntsg:RemoveCard(c)
	sg:RemoveCard(c)
	if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
		Duel.AssumeReset()
	end
	return res
end
function s.CustomCheckP41(c,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local trg=Group.CreateGroup()
	local ntrg=Group.CreateGroup()
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg1=tg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			local sg2=ntg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			trg:Merge(sg1)
			ntrg:Merge(sg2)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(teg) do
				local tgchk=te:GetTarget()
				local res,trg2,ntrg2=tgchk(te,c,sg,tg,ntg,tsg,ntsg)
				--if not res then return false end
				if res then
					trg:Merge(trg2)
					ntrg:Merge(ntrg2)
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,tg,ntg,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	tg:Sub(trg)
	ntg:Sub(ntrg)
	tsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	if max and (tsg_count>max or (max-tsg_count)<min2) then
		res = false
	elseif max and (max-tsg_count)==min2 then
		res=(not req1 or req1(tsg,sc,tp)) 
			and ntg:IsExists(s.CustomCheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<min1 then
		res=tg:IsExists(s.CustomCheckP41,1,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<max1 then
		res=tg:IsExists(s.CustomCheckP41,1,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or ((not req1 or req1(tsg,sc,tp)) and ntg:IsExists(s.CustomCheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max))
	else
		res=(not req1 or req1(tsg,sc,tp)) 
			and ntg:IsExists(s.CustomCheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	end
	tg:Merge(trg)
	ntg:Merge(ntrg)
	tsg:RemoveCard(c)
	sg:RemoveCard(c)
	return res
end
function s.CustomCheckP42(c,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local ntrg=Group.CreateGroup()
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg2=ntg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			ntrg:Merge(sg2)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res,trg2,ntrg2=tgchk(te,c,sg,Group.CreateGroup(),ntg,tsg,ntsg)
				--if not res then return false end
				if res then
					ntrg:Merge(ntrg2)
					hanchk=true
					break
				end
				if not hanchk then return false end
			end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,Group.CreateGroup(),ntg,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	ntg:Sub(ntrg)
	ntsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	local ntsg_count=#ntsg
	if max and (tsg_count+ntsg_count)>max then
		res = false
	elseif ntsg_count<min2 then
		res=ntg:IsExists(s.CustomCheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif ntsg_count<max2 then
		res=ntg:IsExists(s.CustomCheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or ((not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
				and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,sc,tp))
	else
		res=(not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
			and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,sc,tp)
	end
	ntg:Merge(ntrg)
	ntsg:RemoveCard(c)
	sg:RemoveCard(c)
	return res
end
function s.CustomCheckP43(tsg,ntsg,sg,lv,sc,tp)
	if sg:IsExists(Synchro.CheckHand,1,nil,sg) then return false end
	local lvchk=false
	if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM) then
		local g=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		for tc in aux.Next(g) do
			local teg={tc:GetCardEffect(EFFECT_SYNCHRO_MATERIAL_CUSTOM)}
			for _,te in ipairs(teg) do
				local op=te:GetOperation()
				local ok,tlvchk=op(te,tg,ntg,sg,lv,sc,tp)
				if not ok then return false end
				lvchk=lvchk or tlvchk
			end
		end
	end
	return (not Synchro.CheckAdditional or Synchro.CheckAdditional(tp,sg,sc))
	and (lvchk or sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc) or s.customchk(sc,sg,lv,tp))
	and ((sc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0)
		or (not sc:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,sg,tp)>0))
end
function s.customchk(sc,sg,lv,tp)
	local g = sg:Filter(function(tc) return tc:IsSetCard(SET_SYNCHRO_DRAGON,sc,SUMMON_TYPE_SYNCHRO,tp) and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) end, nil)
	if #g==0 then return false end
	if #g==#sg then
		return #g<=lv
	elseif #g<#sg then
		local ng=sg:Filter(aux.TRUE,g)
		local sum,altsum=0,0
		for tc in aux.Next(ng) do
			local ntlv=tc:GetSynchroLevel(sc)
			local ntlv1=ntlv&0xffff
			local ntlv2=ntlv>>16
			sum = sum + ntlv1
			if ntlv2>0 then
				altsum = altsum + ntlv2
			else
				altsum = altsum + ntlv1
			end
		end
		if sum>=lv and (altsum==0 or altsum>=lv) then return false end
		return #g<=(lv-sum)
	end
	return false
end
function s.CheckFilter(c,sc,lv)
	local ntlv=c:GetSynchroLevel(sc)
	local ntlv1=ntlv&0xffff
	local ntlv2=ntlv>>16
	return ntlv1>=lv and (ntlv2<=0 or ntlv2>=lv)
end
function s.CustomSynchroTarget(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local sg=Group.CreateGroup()
				local lv=c:GetLevel()
				local mgchk
				local g
				local dg
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if smat then
					pg:Merge(smat)
					g:Merge(smat)
				end
				local tg
				local ntg
				if mgchk then
					tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
					ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
				else
					tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
					ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
					local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
						local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
						tg:Merge(thag)
						ntg:Merge(nthag)
					end
				end
				local lv=c:GetLevel()
				local tsg=Group.CreateGroup()
				local selectedastuner=Group.CreateGroup()
				if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
					local ntsg=Group.CreateGroup()
					local tune=true
					local g2=Group.CreateGroup()
					while #ntsg<max2 do
						local cancel=false
						local finish=false
						if tune then
							cancel=not mgchk and Duel.IsSummonCancelable() and #tsg==0
							local g3=ntg:Filter(s.CustomCheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							g2=g:Filter(s.CustomCheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp)) then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,false,cancel)
							if not tc then
								if #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp))
									and ntg:Filter(s.CustomCheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
								else
									return false
								end
							end
							if not sg:IsContains(tc) then
								if g3:IsContains(tc) then
									ntsg:AddCard(tc)
									tune = false
								else
									tsg:AddCard(tc)
								end
								selectedastuner:AddCard(tc)
								sg:AddCard(tc)
								if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
									local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
									for i=1,#teg do
										local te=teg[i]
										local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
									end
								end
							else
								selectedastuner:RemoveCard(tc)
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
								if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
									Duel.AssumeReset()
								end
							end
							if g:FilterCount(s.CustomCheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
								tune=false
							end
						else
							if (#ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp)) 
								and ntsg:IsExists(Synchro.NonTunerFilter,#ntsg,nil,f2,sub2,c,tp)
								and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,c,tp)) then
									finish=true
							end
							cancel = (not mgchk and Duel.IsSummonCancelable()) and #sg==0
							g2=g:Filter(s.CustomCheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g2==0 then break end
							local g3=g:Filter(s.CustomCheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #(ntsg-selectedastuner)==0 and #tsg<max1 then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp)) 
									and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,c,tp) then break end
								return false
							end
							if not selectedastuner:IsContains(tc) then
								if not sg:IsContains(tc) then
									ntsg:AddCard(tc)
									sg:AddCard(tc)
									if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
										local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
										for i=1,#teg do
											local te=teg[i]
											local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
										end
									end
								else
									ntsg:RemoveCard(tc)
									sg:RemoveCard(tc)
									if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
										Duel.AssumeReset()
									end
								end
							elseif #(ntsg-selectedastuner)==0 then
								tune=true
								selectedastuner:RemoveCard(tc)
								ntsg:RemoveCard(tc)
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
							end
						end
					end
					Duel.AssumeReset()
				else
					local ntsg=Group.CreateGroup()
					local tune=true
					local g2=Group.CreateGroup()
					while #ntsg<max2 do
						local cancel=false
						local finish=false
						if tune then
							cancel=not mgchk and Duel.IsSummonCancelable() and #tsg==0
							local g3=ntg:Filter(s.CustomCheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							g2=tg:Filter(s.CustomCheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #tsg>=min1 and (not req1 or req1(tsg,c,tp)) then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #tsg>=min1 and (not req1 or req1(tsg,c,tp))
									and ntg:Filter(s.CustomCheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
								else
									return false
								end
							else
								if not sg:IsContains(tc) then
									if g3:IsContains(tc) then
										ntsg:AddCard(tc)
										tune = false
									else
										tsg:AddCard(tc)
									end
									selectedastuner:AddCard(tc)
									sg:AddCard(tc)
								else
									selectedastuner:RemoveCard(tc)
									tsg:RemoveCard(tc)
									sg:RemoveCard(tc)
								end
							end
							if tg:FilterCount(s.CustomCheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
								tune=false
							end
						else
							if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
								and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,c,tp) then
								finish=true
							end
							cancel=not mgchk and Duel.IsSummonCancelable() and #sg==0
							g2=ntg:Filter(s.CustomCheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g2==0 then break end
							local g3=tg:Filter(s.CustomCheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #(ntsg-selectedastuner)==0 and #tsg<max1 then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
									and sg:Includes(pg) and s.CustomCheckP43(tsg,ntsg,sg,lv,c,tp) then break end
								return false
							end
							if not selectedastuner:IsContains(tc) then
								if not sg:IsContains(tc) then
									ntsg:AddCard(tc)
									sg:AddCard(tc)
								else
									ntsg:RemoveCard(tc)
									sg:RemoveCard(tc)
								end
							elseif #(ntsg-selectedastuner)==0 then
								tune=true
								selectedastuner:RemoveCard(tc)
								ntsg:RemoveCard(tc)
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
							end
						end
					end
				end
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				if sg then
					local subtsg=tsg:Filter(function(_c) return sub1 and sub1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) and ((f1 and not f1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) or not _c:IsType(TYPE_TUNER)) end,nil)
					local subc=subtsg:GetFirst()
					while subc do
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_ADD_TYPE)
						e1:SetValue(TYPE_TUNER)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						subc:RegisterEffect(e1,true)
						subc=subtsg:GetNext()
					end
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
     local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(s.pmfilter,1,nil,c)
end
function s.pmfilter(c,sc)
	return c:IsType(TYPE_SYNCHRO) and c:GetOriginalLevel()==8
end
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,c)
		if #g>0 then
		local ng=g:Filter(aux.disfilter1,nil)
		for nc in aux.Next(ng) do
		local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.disable)
	e3:SetCode(EFFECT_DISABLE)
	nc:RegisterEffect(e3)
			end
		end
	end
	function s.disable(e,c)
	return c:IsType(TYPE_MONSTER) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.pfuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable(e) end
	Duel.Destroy(e:GetHandler(),REASON_COST)
	end
function s.spfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_SYNCHRO)
	return #pg<=0 and (c:IsSetCard(SET_CLEAR_WING) or c:IsSetCard(SET_SPEEDROID)) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end