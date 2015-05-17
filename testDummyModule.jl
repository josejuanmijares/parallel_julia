@everywhere function get_global()
  remotecall_fetch(1, ()->gm[1])
end

@everywhere function set_global(newval)
  remotecall_fetch(1, (x)->gm[1]=x, newval)
end

mutex = RemoteRef()
global gm = [5]

@everywhere function do_stuff(mutex::RemoteRef)
  put!(mutex, true) # grab the lock
  x = get_global()
  sleep(0.001)
  set_global( x + 1 )
  take!(mutex) # release the lock
  println("x = $x")
end

np = nprocs()
println("np = $np")

@sync begin
  for p = 1:np
    @async begin
      if p!=myid() || np==1
        remotecall_fetch(p, do_stuff, mutex)
      end
    end
  end
println("inside @sync")
end

println("gm = $gm")






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
