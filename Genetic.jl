function InitPopulation(Pb::Problem,N::Int32)
   Population  = Vector{Genome}(N)
   min::Float64 = typemax(Float64)
   for i in 1:1:N
      Population[i]= Genome(0.0,0.0,0.0,rand(0:1,Pb.Preci),rand(0:1,Pb.Preci))
      Population[i].Valx1 = BitStringToFloat(Pb,Population[i].x1)
      Population[i].Valx2 = BitStringToFloat(Pb,Population[i].x2)
      Population[i] = EvaluateSol(Pb,Population[i])
      if Population[i].CurrObj < Pb.MinObj
         Pb.MinObj = Population[i].CurrObj
         println("New minimum :",Pb.MinObj)
      end
   end
   return Population,Pb
end
function EvaluateSol(Pb::Problem,Indi::Genome)
   val1::Float64 = 0
   val2::Float64 = 0
   for i = 1:1:5
      val1 += (i*cos((i+1)*Indi.Valx1 +i))
      val2 += (i*cos((i+1)*Indi.Valx2 +i))
   end
   #println("Val 1 :",val1, " Val 2 : ",val2)
   Indi.CurrObj = val1 * val2
   return Indi
end
function BitStringToFloat(Pb::Problem,BitString::Vector{Int32})
   val = 0
   for i = 1:1:length(BitString)
      val += BitString[i] * 2^(i-1)
   end
   val2 = Pb.MinVal + val * ((Pb.Delta)/((2^Pb.Preci)-1))
   return val2
end
function Evolution(Population::Vector{Genome},Pb::Problem,NPop::Int32,Ngen::Int32,stoplimit::Float64)
   it = 0
   save::Int32 = 1
   SaveResultPop = Array{Vector{Genome}}(Ngen+1)
   SaveResultPop[1] = deepcopy(Population)
   for i  = 1:1:Ngen
       for j = 1:2:NPop
         #here repair and mutate
         ProbMut = rand(RdSeed)
         if ProbMut > 0.3
            p1,p2          = BinaryTourmanent(Population,NPop,Pb)
            child1,child2  = CrossoverMethod(Pb,[Population[p1],Population[p2]])

            if child1.Solution != Population[p1].Solution && child1.Solution != Population[p2].Solution
               child1 = RepairAndMutationSparse(Pb,child1)
               child1 = AugmentIndividual(Pb,child1)
            end
            if child2.Solution != Population[p1].Solution && child2.Solution != Population[p2].Solution
               child2 = RepairAndMutationSparse(Pb,child2)
               child2 = AugmentIndividual(Pb,child2)
            end

            InsertAndReplace(Pb,Population,child1)
            InsertAndReplace(Pb,Population,child2)
         end
         it += 2
      end
      SaveResultPop[i+1] = deepcopy(Population)
      save = i
      println("###################### Generation Info #####################")
      println("# Generation : ",i)
      println("# Moyenne : ",round(Pb.SumObj/NPop,2))
      println("# MIN : ", Pb.MinObj, " | MAX : ",Population[1].CurrObj)
      println("# Time spend : ",time, "s | ",round((it/(Ngen*NPop))*100,2),"% done")
      println("############################################################")
      if ((Population[1].CurrObj - Population[NPop].CurrObj) / (Pb.SumObj/NPop)) < stoplimit
         break
      end
   end
   return save,SaveResultPop,Population
end
function RepairAndMutationSparse(Pb::Problem,Indi::Genome)

end

function AugmentIndividual(Pb::Problem,Indi::Genome)

end

function RouletteSelection(Population::Vector{Genome},N::Int32,Pb::Problem)
   Value::Float64 = 0.0
   p1::Int32 = 0
   p2::Int32 = 0
   Rand1::Float64 = rand(RdSeed)
   Rand2::Float64 = rand(RdSeed)
   TotDec = Pb.SumObj - (N*Pb.MinObj)
   for i = 1:1:N
      # REMPLACER PB MIN OBJ PAR la f(x) du dernier element du vecteur pop
      Value += (Population[i].CurrObj-Pb.MinObj)/TotDec
      if Rand1 < Value
         p1 = i
      end
      if Rand2 < Value
         p2 = i
      end
      if p1 != 0 && p2 != 0
         return p1,p2
      end
   end
   return rand(RdSeed,1:N),rand(RdSeed,1:N)
end
function BinaryTourmanent(Population::Vector{Genome},N::Int32,Pb::Problem)
   #Mode = true ==> Same Probability for each individual
   p1::Int32=0;  p2::Int32=0
   p3::Int32=0;  p4::Int32=0

   p1,p2 = RouletteSelection(Population,N,Pb)
   p3,p4 = RouletteSelection(Population,N,Pb)

   if Population[p1].CurrObj > Population[p2].CurrObj
      if Population[p3].CurrObj > Population[p4].CurrObj
         return p1,p3
      else
         return p1,p4
      end
   end

   if Population[p3].CurrObj > Population[p4].CurrObj
      return p2,p3
   end
   return p2,p4
end
#  FUsion operator yeah it rock
function CrossoverMethod(Pb::Problem,Parents::Vector{Genome})
   Child1 = Genome(Pb.Bonus,zeros(Int64,Pb.NBvariables))
   Child2 = Genome(Pb.Bonus,zeros(Int64,Pb.NBvariables))
   #Soyons malin utilisons les probabilites
   for i in 1:1:Pb.NBvariables
      if Parents[1].Solution[i]  == Parents[2].Solution[i]
         Child1.Solution[i] = Parents[1].Solution[i]
         Child2.Solution[i] = Parents[1].Solution[i]
      else
         Probk1 = rand(RdSeed,1:2)
         Probk2 = 0
         if Probk1 == 1
            Probk2 = 2
         else
            Probk2 = 1
         end
         pk = Parents[Probk1].CurrObj / ( Parents[1].CurrObj + Parents[2].CurrObj)
         pkPrim = Parents[Probk2].CurrObj / ( Parents[1].CurrObj + Parents[2].CurrObj)
         if rand(RdSeed) <= pk
            Child1.Solution[i] = Parents[Probk1].Solution[i]
         else
            Child1.Solution[i] = Parents[Probk2].Solution[i]
         end
         if rand(RdSeed) <= pkPrim
            Child2.Solution[i] = Parents[Probk2].Solution[i]
         else
            Child2.Solution[i] = Parents[Probk1].Solution[i]
         end
      end
      if Child1.Solution[i] == 1
         Child1.CurrObj += Pb.Variables[i]
      end
      if Child2.Solution[i] == 1
         Child2.CurrObj += Pb.Variables[i]
      end
   end
   #println("###################### Crossover Info ######################")
   #println("# Parent 1 : ",Parents[1].CurrObj," | Parent 2 :",Parents[2].CurrObj)
   #println("# Child 1 : ",Child1.CurrObj," | Child 2 : ",Child2.CurrObj)
   #println("############################################################")
   return Child1,Child2
end

function InsertAndReplace(Pb::Problem,Population::Vector{Genome},Indi::Genome)
   index = searchsortedfirst(Population,Indi,by=x->x.CurrObj,rev=true)
   insert!(Population,index,Indi)
   Pb.SumObj += Indi.CurrObj
   PopSize = length(Population)
   Pb.SumObj -= Population[PopSize].CurrObj
   deleteat!(Population,PopSize)
   Pb.MinObj = Population[PopSize-1].CurrObj
end
