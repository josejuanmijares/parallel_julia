@everywhere function get_global(gm::SharedArray)
	println( "get_global@gm = $(gm[1])")
	return gm[1]
  #remotecall_fetch(1, ()->gm[1])
end

@everywhere function set_global(newval::Int64,gm::SharedArray)
	gm[1] = newval;
  #remotecall_fetch(1, (x)->gm[1]=x, newval)
end

mutex = RemoteRef()
@everywhere gm = SharedArray(Int,(1,1));

#global gm = [5]

@everywhere function do_stuff(mutex::RemoteRef, gm::SharedArray)
	#println("do_stuff_0@whos()= $(whos())")
  	put!(mutex, true) # grab the lock
  	#println("do_stuff_1@gm = $gm")
  	sleep(1)
  	x = get_global(gm)
  	sleep(0.001)
  	set_global( x + 1, gm )
  	take!(mutex) # release the lock
  	println("x = $x")
end

np = nprocs()
println("np = $np")

gm[1] =5;


@sync begin
  println( "inside sync @ gm = $(gm[1])")
  for p = 1:np
    @async begin
      if p!=myid() || np==1
		  # fetch( remotecall(...))
		  # fetch - Wait for and get the value of a remote reference.
		  # remotecall -  Calls a function asynchronously on the given arguments on the specified process.
		  # 
		  # for SharedArray, you need to pass the reference of the array, since it is not visible to all of the processes
		  remotecall_fetch(p, do_stuff, mutex,gm)
		  
		  # fetch( @spawnat (...))
		  # fetch - Wait for and get the value of a remote reference.
		  #	@spawnat runs (evaluates) a expression asynchronously
		  #
		  
		  
		  
      end
    end
  end
println("inside @sync")
end

println("at the end @ gm = $gm")






# myworkers = workers();
# @everywhere using DummyModule
#
# for s in myworkers
# 	@spawnat s 	begin
# 					ref = @task longrun(10^8)
# 					println("ref = $ref, pid = $s")
# 				end
# end
#
#
#
#
#
#
# # println("Hello")
# #
# # function source()
# #   println("source start")
# #   produce("start")
# #   produce("stop")
# #   println("source end")
# # end
# #
# # function sink(p::Task)
# #   println("sink start")
# #   for s in p
# #     println(s)
# #   end
# #   println("sink end")
# # end
# #
# # @sync begin
# #    a = @async source()
# #    @async sink(a)
# #  end
# #
# # println("Goodbye")
