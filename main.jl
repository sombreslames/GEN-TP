
#Ferrari Leon
#M1 ORO
#Version de test
#Julia JuMP
#DM1 - Metaheuristiques
using JuMP, GLPKMathProgInterface,Gadfly,DataFrames
#tHIS STRUCT DESCRIBE THE COMMON CHARACTERISTICS OF THE PROBLEM
# IN ORDER TO USE SMALLER INDIVIDUAL I USE PROBLEM AND INDIVIDUAL
type Problem
   Preci::Int32
   Delta::Float64
   MinVal::Float64
   MinObj::Float64
end
#Individual two --> Containing only the solution
#We will have to make our solution feasible at each move
type Genome
   CurrObj::Float64
   Valx1::Float64
   Valx2::Float64
   x1::Vector{Int32}
   x2::Vector{Int32}
end
RdSeed = RandomDevice()
include("ToolsAndPlot.jl")
include("Genetic.jl")
function main()
   Pb       =  Problem(25,20,-10.0,typemax(Float64))
   Time::Float64        = 0.0
   AVG                  = 0
   N::Int32             = 500
   Ngen::Int32          = 60
   println("Beginning evolution #IDONTBELIEVEINIT")
   Population,Pb = InitPopulation(Pb,N)
   #println("Max : ",max ," | Min : ",min)
   #println("Average time : ", round(Time,2))
   #println("Average known value is ",round(AVG,2))
   #PlotGeneticAlgorithm(sv,N,ngen,filename)
end

main()
