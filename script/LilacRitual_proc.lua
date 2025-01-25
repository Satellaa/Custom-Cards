if not aux.RitualProcedure then
	aux.RitualProcedure = {}
	Ritual = aux.RitualProcedure
end
if not Ritual then
	Ritual = aux.RitualProcedure
end

EFFECT_EXTRA_RITUAL_LOCATION = EVENT_CUSTOM+200
LOCATION_NOTHAND=LOCATION_DECK|LOCATION_REMOVED|LOCATION_GRAVE

function Card.GetEffect(c,passedeff)
	local effs={c:IsHasEffect(passedeff)}
	if effs then
		for _,eff in ipairs(effs) do
			return eff
		end
	end
end
function Ritual.ExtraLocSingleEffFilter(c,tp,rc)
	local eff=c:GetEffect(EFFECT_EXTRA_RITUAL_LOCATION)
	if not eff then return false end
	local baseefftg=eff:GetTarget() or false
	if baseefftg then
		if not baseefftg(c,rc,tp) then return false end
	end
	return eff:GetType()&EFFECT_TYPE_SINGLE>0
		and eff:CheckCountLimit(tp) 
end
function Ritual.ExtraLocFilter(c,filter,_type,e,tp,m,m2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos,booltype,reqfunc)
	if not (c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER)) or (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,sumpos) then return false end
	if booltype then
		local eff=c:GetEffect(EFFECT_EXTRA_RITUAL_LOCATION)
		if not eff then return false end
		if not (eff:GetType()&EFFECT_TYPE_SINGLE>0 and eff:CheckCountLimit(tp)) then return false end
		local efftg=eff:GetTarget() or false
		if efftg then
			if not efftg(c,e:GetHandler(),tp) then return false end
		end
	else
		if reqfunc then
			if not reqfunc(c,e:GetHandler(),tp) then return false end
		end
	end
	local lv=(lv and (type(lv)=="function" and lv(c)) or lv) or c:GetLevel()
	lv=math.max(1,lv)
	Ritual.SummoningLevel=lv
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2-c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,forcedselection,_type)
	end
	if c.mat_filter then
		mg:Match(c.mat_filter,c,tp)
	end
	if specificmatfilter then
		mg:Match(specificmatfilter,nil,c,mg,tp)
	end
	forcedselection=MergeForcedSelection(c.ritual_custom_check,forcedselection)
	local res=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(c,lv,WrapTableReturn(forcedselection),_type,requirementfunc),0)
	Ritual.SummoningLevel=nil
	return res
end
Ritual.Target = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	local locationfrom=location
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
					--add that forcedselection to the one of the Ritual Spell, if any
					local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					local func=forcedselection
					--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
					--used as material
					local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
					if #extra_mat_g>0 then
						func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
					end
					if #extra_eff_g>0 then
						local prev_repl_function=nil
						for tmp_c in extra_eff_g:Iter() do
							local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
							for _,eff in ipairs(effs) do
								local repl_function=eff:GetLabelObject()
								if repl_function and prev_repl_function~=repl_function[1] then
									prev_repl_function=repl_function[1]
									func=MergeForcedSelection(func,repl_function[1])
								end
							end
						end
					end
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
					-- custom ----
					local FinalGroup=Group.CreateGroup()
					local BaseGroup=Duel.GetMatchingGroup(Ritual.Filter,tp,location,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
					FinalGroup:Merge(BaseGroup)
					local ExtraLocSingleEffGroup=Duel.GetMatchingGroup(Ritual.ExtraLocFilter,tp,LOCATION_NOTHAND,0,e:GetHandler(),filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos,true)
					if #ExtraLocSingleEffGroup>0 then
						FinalGroup:Merge(ExtraLocSingleEffGroup)
						for tc in ExtraLocSingleEffGroup:Iter() do
							if (locationfrom&tc:GetLocation())==0 and (tc:GetLocation()&LOCATION_DECK)==0 then
								locationfrom=locationfrom|tc:GetLocation()
							end
						end
					end
					local ExtraLocEff=Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_RITUAL_LOCATION)
					if ExtraLocEff and ExtraLocEff:CheckCountLimit(tp) then
						local ExtraLoc=ExtraLocEff:GetValue()
						if (locationfrom&ExtraLoc)==0 and (ExtraLoc&LOCATION_DECK)==0 then
							locationfrom=locationfrom|ExtraLoc
						end
						local ReqFunc=ExtraLocEff:GetTarget() or false
						local ExtraLocGroup=Duel.GetMatchingGroup(Ritual.ExtraLocFilter,tp,ExtraLoc,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos,false,ReqFunc)
						FinalGroup:Merge(ExtraLocGroup)
					end
					return #FinalGroup>0
					--------------
				end
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,locationfrom)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","specificmatfilter","requirementfunc","sumpos","extratg")
Ritual.Operation = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
				--add that forcedselection to the one of the Ritual Spell, if any
				local func=forcedselection
				local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
				if #extra_eff_g>0 then
					local prev_repl_function=nil
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							local repl_function=eff:GetLabelObject()
							if repl_function and prev_repl_function~=repl_function[1] then
								prev_repl_function=repl_function[1]
								func=MergeForcedSelection(func,repl_function[1])
							end
						end
					end
				end
				--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
				--used as material
				local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
				if #extra_mat_g>0 then
					func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
				end
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				-- Custom ----
				local ExtraLocEff=Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_RITUAL_LOCATION)
				local tg=nil
				local ExtraLoc=nil
				local FinalGroup=Group.CreateGroup()
				local BaseLocGroup=Duel.GetMatchingGroup(aux.NecroValleyFilter(Ritual.Filter),tp,location,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
				local ExtraLocSingleEffGroup=Duel.GetMatchingGroup(aux.NecroValleyFilter(Ritual.ExtraLocFilter),tp,LOCATION_NOTHAND,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos,true)
				FinalGroup:Merge(BaseLocGroup)
				if #ExtraLocSingleEffGroup>0 then
					FinalGroup:Merge(ExtraLocSingleEffGroup)
				end
				if ExtraLocEff and ExtraLocEff:CheckCountLimit(tp) then
					ExtraLoc=ExtraLocEff:GetValue()
					local ReqFunc=ExtraLocEff:GetTarget() or false
					local ExtraLocGroup=Duel.GetMatchingGroup(aux.NecroValleyFilter(Ritual.ExtraLocFilter),tp,ExtraLoc,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos,false,ReqFunc)
					FinalGroup:Merge(ExtraLocGroup)
				end
				if #FinalGroup>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					tg=FinalGroup:Select(tp,1,1,nil)
				end
				if #tg>0 then
					if ExtraLocEff and ExtraLocEff:CheckCountLimit(tp) and tg:GetFirst():IsLocation(ExtraLoc) then
						ExtraLocEff:UseCountLimit(tp)
					end
					if tg:IsExists(Ritual.ExtraLocSingleEffFilter,1,nil,tp,e:GetHandler()) then
						tg:GetFirst():GetEffect(EFFECT_EXTRA_RITUAL_LOCATION):UseCountLimit(tp)
					end
				--------
					local tc=tg:GetFirst()
					local lv=(lv and (type(lv)=="function" and lv(tc)) or lv) or tc:GetLevel()
					lv=math.max(1,lv)
					Ritual.SummoningLevel=lv
					local mat=nil
					mg:Match(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if specificmatfilter then
						mg:Match(specificmatfilter,nil,tc,mg,tp)
					end
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,func,_type)
						mat=tc:GetMaterial()
					else
						func=MergeForcedSelection(tc.ritual_custom_check,func)
						if tc.mat_filter then
							mg:Match(tc.mat_filter,tc,tp)
						end
						if ft>0 and not func then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							if _type==RITPROC_EQUAL then
								mat=mg:SelectWithSumEqual(tp,requirementfunc or Card.GetRitualLevel,lv,1,#mg,tc)
							else
								mat=mg:SelectWithSumGreater(tp,requirementfunc or Card.GetRitualLevel,lv,tc)
							end
						else
							mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(tc,lv,WrapTableReturn(func),_type,requirementfunc),1,tp,HINTMSG_RELEASE,Ritual.Finishcon(tc,lv,requirementfunc,_type))
						end
					end
					--check if a card from an "once per turn" EFFECT_EXTRA_RITUAL_MATERIAL effect was selected
					local extra_eff_g=mat:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							--if eff is OPT and tmp_c is not returned
							--by the Ritual Spell's exrafil
							--then use the count limit and register
							--the flag to turn the extra eff OFF
							--requires the EFFECT_EXTRA_RITUAL_MATERIAL effect
							--to check the flag in its condition
							local _,max_count_limit=eff:GetCountLimit()
							if max_count_limit>0 and not mg2:IsContains(tmp_c) then
								eff:UseCountLimit(tp,1)
								Duel.RegisterFlagEffect(tp,eff:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1)
							end
						end
					end
					if not customoperation then
						tc:SetMaterial(mat)
						if extraop then
							extraop(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
						else
							Duel.ReleaseRitualMaterial(mat)
						end
						Duel.BreakEffect()
						Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,sumpos)
						tc:CompleteProcedure()
						if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
					end
					Ritual.SummoningLevel=nil
				end
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos")